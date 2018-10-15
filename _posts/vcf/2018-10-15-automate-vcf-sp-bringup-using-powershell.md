---
layout: post
author: Ricardo Adao
published: true
post_date: 2018-10-15 08:00:00
title: VCF - Automate VMware Cloud Foundation - Service Provider - bringup process using PowerShell
categories: [ vcf ]
tags: [ vcf, powershell, vmware, coding, automation ]
comments: true
---
[_VMware Cloud Foundation (VCF)_](https://docs.vmware.com/en/VMware-Cloud-Foundation/index.html) is an integrated software stack that uses [_SDDC Manager_](https://docs.vmware.com/en/VMware-Cloud-Foundation/2.2/com.vmware.vcf.ovdeploy.doc_22/GUID-F16F5CA4-ABF1-4282-974D-7CBB96028964.html) as a tool to automate the deployment and lifecycle management.

One of the main diferences in the _VCF SP_ version is the lack of _web interface_ to initiate the bringup process, everything in _VCF SP_ version is done through the _API_.

The post will be a quick runthrough the automation of the _bringup_ process using _Powershell_.

All the code snippets have the objective to help creating your own _bringup automation script_, even being a _working piece_ of code if _copy&pasted_ there are parts where more code is needed, as an example, there is no code or reference in how to generate the _JSON payload_ (possible a future post) so you will need to fill the gap between having the info and getting it to a _VCF SP_ valid _JSON payload_. 

# Initial Challenge

When planning the process there is a first challenge that we need to address will be how to to reach the _API_, since the _API service_ is only listening in the _127.0.0.1 (localhost)_ port _9080_.

After some research found a nice _Powershell_ module that would help with _SSH_ connectivity - [Posh-SSH](https://www.powershellgallery.com/packages/Posh-SSH/2.0.2)

There were 2 options how to address _SSH_ connectivity:

* _SSH_ into the _bringup box_ and then run the commands through the shell
* Initiate a _SSH_ session and then use it as a tunnel to forward the traffic via a _port forward_

We will be using the second approach since the initial idea was to use _Powershell_.

## Step 1 - Establishing SSH tunnel and setup portforward

### Initiating SSH conection

```powershell
# Variables
$deployVMIP       = "192.168.0.30" # FQDN/IP
$deployVMUsername = "root"         # SSH username
$deployVMPassword = "password"     # SSH password

# Setting up tunnel
$sshConnection = New-SSHConnection -destination $deployVMIP `
    -username $deployVMUsername -password $deployVMPassword
```

### Setting up the _portforward_

```powershell
# Variables
$localPort       = 9000 # Local port to use
$deployVMTCPPort = 9080 # Remote port
$sshConnection          # SSH connection established

# Setup Portforward
New-SSHLocalPortForward -BoundHost "127.0.0.1" -BoundPort $localPort `
    -RemoteAddress "127.0.0.1" -RemotePort $deployVMTCPPort `
    -SSHSession $sshConnection
```

## Step 2 - Checkup if _bingup service_ is up and running

From now on, since we have a _SSH_ connection and a _local portforward_, we will use the _localhost and localPort_ in the URLs for the _API_ calls instead of _deploy VM_ address.

```powershell
# Variables
$url = "http://localhost:$localPort/bringup-app/bringup/about"
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Content-Type" , "application/json")

# GET Rest API Call to check if bringup service is up
if (($request = Get-RestAPICall -url $url -headers $headers).name -notmatch "BRINGUP") {
    Write-Host "--> bringup - Bringup service is not UP <--" -ForegroundColor Red
    Exit
} else {
    Write-Host "--> bringup - Bringup service is UP and running <--" `
        -ForegroundColor Green
    Write-Host "--> bringup - $($request.name) - $($request.serviceId) - $($request.version) <--" `
        -ForegroundColor Green
}
```

> _**Get-RestAPICall**_ is one of the wrapping functions already exemplified in an earlier post [Powershell - Wrapping GET and POST Rest API calls]({{ site.url }}{% link _posts/powershell/2018-10-10-powershell-wrapping-get-post-rest-api-calls.md %})

## Step 3 - Start bringup process

Now that we checked if the _bringup service_ is running and our _ssh tunnel/portforwarding_ is good, we can start the _bringup process_ by using a _POST_ request.

```powershell
# Variables
$vcfJSON = <JSON payload> # More info in the note below

$url = "http://localhost:$localPort/bringup-app/bringup/sddcs"
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Content-Type" , "application/json")
$headers.Add("Content-Accept" , "application/json")

$request = Post-RestAPICall -url $url -headers $headers -payload $vcfJSON

# Store the bringup_ID process to be used later to check the progress
$bringupId = $request.id
```

> _**$vcfJSON**_ - will have the JSON payload that we will send in the _POST_ command to the _API_, there will be multiple ways of creating this payload either by using a template and replace the fields with string replacemente or even building the full JSON payload from scratch using _Powershell_, didn't detail any of the options, since it would be a familiar process to someone working with _VCF SP_

> _**Post-RestAPICall**_ is one of the wrapping functions already exemplified in an earlier post [Powershell - Wrapping GET and POST Rest API calls]({{ site.url }}{% link _posts/powershell/2018-10-10-powershell-wrapping-get-post-rest-api-calls.md %})

## Step 4 - Waiting till _VCF_ finishes the deployment

The _VCF_ deployment process can take some time to finish, since it will perform multiple validations and some of the installations processes will take its time.

In our particular case, being this our _Nested Lab Environemnt_, it tipically take 2h30/3h30 to deploy, depending on the current _physical cluster_ utilization:

* 4 Nested ESXi
* 1 Platform Service Constroller (PSC)
* 1 vCenter (VCSA)
* 1 NSX Manager
* 1 NSX Controller cluster (3x NSX Controllers)

Setting up a simple _waiting cycle_ to wait for the _bringup process_ to finish, instead of chasing the progress from time to time.

```powershell
# Variables
$counter = 0               # Counter to keep track of elapsed time (no guaranteed accuracy)
$BRINGUP_WAIT_TIMEOUT = 60 # Timer in seconds between checks

do {
    Start-Sleep -Seconds $BRINGUP_WAIT_TIMEOUT
    $counter++
    if ((($counter * $BRINGUP_WAIT_TIMEOUT) % 600) -eq 0) {
        $ts = [timespan]::fromseconds( $counter * $BRINGUP_WAIT_TIMEOUT )
        Write-Host "($($ts.Hours.ToString("00"))h$($ts.Minutes.ToString("00"))m)" -ForegroundColor Yellow
    } else {
        Write-Host -NoNewline "#" -ForegroundColor Yellow
    }

    # Check if SSH tunnel is UP and Portforward is setup, since we will need it to keep checking
    if ( !($sshTunnelSession.Connected) ) {
        # tunnel down lets reconnect and recreate the port forward
        Write-Host "--> bringup - Tunnel Down - Reconnect <--" -ForegroundColor Red
        $sshTunnelSession = New-SSHConnection -destination $deployVMIP `
            -username $deployVMUsername -password $deployVMPassword
    } else {
        # Check portforward
        if (!(Get-SSHPortForward -SSHSession $sshTunnelSession | `
            Where-Object { ($_.BoundPort -match $localPort) -and ($_.IsStarted) } )) {
                # Setup Portforward
                New-SSHLocalPortForward -BoundHost "127.0.0.1" -BoundPort $localPort `
                    -RemoteAddress "127.0.0.1" -RemotePort $deployVMTCPPort `
                    -SSHSession $sshTunnelSession
        }
    }

    $request = Get-RestAPICall -headers $headers -url $url
} while($request -match "IN_PROGRESS")

switch ($request){
    "COMPLETED_WITH_FAILURE" {
        Write-Host "`n-> VCF Bringup COMPLETED WITH FAILURE - $request <-" `
            -ForegroundColor Red
    }
    "COMPLETED_WITH_SUCCESS" {
        Write-Host "`n-> VCF Bringup FINISHED OK - $request <-" `
            -ForegroundColor Green
    }
    default {
        Write-Host "`n-> VCF Bringup FINISHED - Unexpected State - $request <-" `
            -ForegroundColor Blue
    }
}
```

## Step 5 - Kill the _SSH tunnel/porforward_

Once we finished the bringup, we can _shut_ the _SSH tunnel_

```powershell
# Kill SSH Tunnel
$null = Remove-SSHSession $sshTunnelSession
```
