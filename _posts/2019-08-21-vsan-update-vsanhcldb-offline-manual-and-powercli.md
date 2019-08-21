---
author: Ricardo Adao
published: true
post_date: 2019-08-21 08:00:00
last_modified_at:
header:
  teaser: /assets/images/featured/vsan-150x150.png
title: vSAN - Update vSAN HCL DB Offline using manual process and PowerCLI
categories: [ vsan ]
tags: [ vsan, powercli, vmware, coding, automation, powershell, sddc, vcf ]
toc: true
---
# **_Internet Access_ is overrated**

## Context

As we know one of the most important recommended practices for _VMware vSAN_ is to keep as close as possible to [_VSAN HCL_](https://www.vmware.com/resources/compatibility/search.php?deviceCategory=vsan).

To make our life easier _VMWare vCenter_ has the functionality of validating if the hardware, drivers and firmware installed are aligned with that _HCL_, removing the operational pain of checking it manually in a regular basis, since the same way that items are added to the _HCL_, some items are also removed or stop being supported after _ESXi_ upgrades.

This functionality requires that _vCenter_ has_internet access_ to download the _vSAN HCL DB file_ that is kept in _json_ format [@_vSAN HCL DB file_](https://partnerweb.vmware.com/service/vsan/all.json
).

However... sometimes _Internet Access_ is not an option, not even via _proxy_, so the only option is to download the file using our desktop, as an example, and then upload it to the _vCenter_.

## Can we download _vSAN HCL DB file_ and then update our vCenter vSAN HCL DB offline?
{: #vsan_hcl_db_manual_update }

### Yes, we can do it

The process is relatively simple and quiet well documented in [_VMware KB 2145116_](https://kb.vmware.com/s/article/2145116).

In summary the process has *4 simple steps*, as described in the _VMware KB article_ mentioned before.

1. Log in to a workstation where you have internet access.
2. Open the below link in browser:
   [_https://partnerweb.vmware.com/service/vsan/all.json_](https://partnerweb.vmware.com/service/vsan/all.json)
3. Save the file as all.json. If you are unable to save the file, you must copy the entire content and create a new file with extension "*.json".
4. Copy the file to another workstation which connects to the vCenter.  Log in to vCenter server from there, and upload the file to the vCenter.

As we can see, is not a difficult process.

## If it is an easy process and well documented, why script it then ???

### Because we can... ihihihih

When it is a case of one or two _vCenters_ probably it would be a bit overkill to do it.

However, if it is a recurring task, or if we need to upload the _vSAN HCL DB file_ to an hand full of _vCenters_ why not script it instead.

Let's start building our script from the simple _use case_ of a single _vCenter_,  to a _use case_ where we have multiple _vCenters_ that share the same credentials.

### The magic _cmdlet_ - _Update-VsanHclDatabase_

We can upload a _vSAN HCL DB file_ using _PowerCLI cmdlet_ - [_Update-VsanHclDatabase_](https://code.vmware.com/doc/preview?id=6330#/doc/Update-VsanHclDatabase.html)

```powershell
PS > get-help Update-VsanHclDatabase

NAME
    Update-VsanHclDatabase

SYNOPSIS
    This cmdlet updates the vSAN hardware compatibility list (HCL)
    database.

SYNTAX
    Update-VsanHclDatabase [-FilePath <String>] [-RunAsync]
        [-Server <VIServer[]>] [-Confirm] [-WhatIf]
        [<CommonParameters>]
```

### Simple case - single _vCenter_
{: #vsan_hcl_db_scripted_simple }

These is an example how we can build a quick _Powershell/PowerCLI_ script to upload _vSAN HCL DB file_ to a single _vCenter_  

* 4 Input parameters:
  * **$vcenter**       - _vCenter_ FQDN/IP to connect to
  * **$username**      - _vCenter username_ with enough privileges to manage _vCenter_ and _vSAN_ configuration
  * **$password**      - _vCenter password_ to be used (password is hidden while being typed and then encrypted inside the script)
  * **$vsanHCLDBFile** - downloaded _vSAN HCL DB file_ complete path

The download of the _vSAN HCL DB file_ could also be scripted, but is not covered in this post assuming the file is download beforehand.
{: .notice--info}

```powershell
param(
    [Parameter(Position=1,
        Mandatory = $true, ValueFromPipeline = $true)] [string]$vcenter,
    [Parameter(Position=2,
        Mandatory = $true, ValueFromPipeline = $true)] [string]$username,
    [Parameter(Position=3,
        Mandatory = $true, ValueFromPipeline = $true)] [System.Security.SecureString]$password,
    [Parameter(Position=4,
        Mandatory = $true, ValueFromPipeline = $true)] [string]$vsanHCLDBFile
)

Write-Host "-> Connect to vCenter $vcenter" -ForegroundColor Green

$vcenterConnection = Connect-VIServer -Server $vcenter -User $username `
    -Password ([System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($password)))

Write-Host "--> Upload vSAN HCL file $vsanHCLFile" -ForegroundColor Cyan

Update-VsanHclDatabase -FilePath $vsanHCLDBFile

Write-Host "-> Disconnect from vCenter - $vcenter - WLD $wld" -ForegroundColor Green
Disconnect-VIServer -Server $vcenterConnection -Confirm:$false -ErrorAction SilentlyContinue
```

### And if we have more than one _vCenter_
{: #vsan_hcl_db_scripted_plus }

For this _use case_ and to make it more interesting, let's use a _VMware Cloud Foundation (VCF)_ deployment as an example of multiple _vCenters_  connected to the same _SSO/PSC_.

In a _VCF_ deployment, you can have multiple _Workload Domains (WLD)_, and each of these _WLD_ will have their own _vCenter_.

To simplify the script let's agree with a _naming convention_ for the _vCenters_ _FQDN_:

* **vc-< dc name >-< wld >-< dc # >.lab.local**
  * _< dc name >_ - datacenter identifier, in our example: **dc01**
  * _< wld >_     - _WLD_ name, in our example: **mgmt, prod, stg, qa, dev**
  * _< dc # >_    - datacenter # id, in our example: **20**  

* 4 Input parameters:
  * **$dcName**        - _datacenter name to be used
  * **$username**      - _vCenter username_ with enough privileges to manage _vCenter_ and _vSAN_ configuration
  * **$password**      - _vCenter password_ to be used (password is hidden while being typed and then encrypted inside the script)
  * **$vsanHCLDBFile** - downloaded _vSAN HCL DB file_ complete path

The download of the _vSAN HCL DB file_ could also be scripted, but is not covered in this post assuming the file is download beforehand.
{: .notice--info}

```powershell
param(
    [Parameter(Position=1,
        Mandatory = $true, ValueFromPipeline = $true)] [string]$dcName,
    [Parameter(Position=2,
        Mandatory = $true, ValueFromPipeline = $true)] [string]$username,
    [Parameter(Position=3,
        Mandatory = $true, ValueFromPipeline = $true)] [System.Security.SecureString]$password,
    [Parameter(Position=4,
        Mandatory = $true, ValueFromPipeline = $true)] [string]$vsanHCLDBFile
)

 # Our workload domain names
 $wlds = @("mgmt", "prod", "stg", "qa", "dev")

 # Our datacenter ID
 $dcID = "20"

 # Our vCenter naming convention
 $vcenterNameTemplate = "vc-$dcName-{{ WLD }}-$dcID.lab.local"

 Write-Host "-> Update vSAN HCL DB list of datacenter $dcName (ID $dcID) vCenters" -ForegroundColor Green

 # Cycle through all our WLDs
 foreach($wld in $wlds) {
    # replace {{ WLD }} with the WLD name to finish of vCenter FQDN to connect to
    $vcenter = $vcenterNameTemplate.Replace("{{ WLD }}", $wld)

    Write-Host "--> Connect to vCenter - $vcenter - WLD $wld" -ForegroundColor Green
    $vcenterConnection = Connect-VIServer -Server $vcenter -User $username `
        -Password ([System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($password)))

    Write-Host "---> Upload vSAN HCL file $vsanHCLFile" -ForegroundColor Cyan
    Update-VsanHclDatabase -FilePath $vsanHCLDBFile

    Write-Host "--> Disconnect from vCenter - $vcenter - WLD $wld" -ForegroundColor Green
    Disconnect-VIServer -Server $vcenterConnection -Confirm:$false -ErrorAction SilentlyContinue
 }
```

Some of the _scripts_ shown above can be done in _one liners_, but for the sake of structure and clarity I kept it this way.
{: .notice--info}

## Summary

 This post gives a quick look in how to keep up-to-date _vCenter_ _vSAN HCL DB_ when _internet connectivity_ is not available.

 The post details three options:

* [_**Manual Process**_](#vsan_hcl_db_manual_update) - using [_VMware KB 2145116_](https://kb.vmware.com/s/article/2145116)
* [_**Scripted for a simple case**_](#vsan_hcl_db_scripted_simple)
* [_**Scripted for multiple vCenters**_](#vsan_hcl_db_scripted_plus)
