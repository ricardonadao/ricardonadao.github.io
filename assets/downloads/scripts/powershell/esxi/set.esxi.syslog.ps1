##################################################################
#
# Setup remote syslog in all the hypervisors of a Cluster
#
##################################################################
<#
.SYNOPSIS
    Change the remote syslog setting in all the hypervisors of a cluster

.DESCRIPTION
    Change the remote syslog setting in all the hypervisors of a cluster

.PARAMETER vcenter
Specifies FQDN/IP of the vCenter

.PARAMETER vcenterUsername
Specifies username to use to login to the vCenter

.PARAMETER vcenterPassword
Specifies password for vCenterUsername (passed encrypted as a parameter or leave it blank to be asked)

.PARAMETER cluster
Specifies the cluster containing the hypervisors to be reconfigured (optional)

.PARAMETER remoteSyslog
Specify FQDN/IP of remote syslog to configure

.PARAMETER syslogPort
Specify syslog Port to use (default: 514) (optional)


.EXAMPLE
    C:\PS>
    . set.esxi.syslog.ps1 -vcenter <vcenter IP/FQDN> -vcenterUsername <vcenter username>
       -vcenterPassword <password> -cluster <clusterName> -remoteSyslog <syslog FQDN/IP>
       -syslogPort <port to use>
.NOTES
    Author: Ricardo Adao
    Date:   Jul 15, 2018
#>

param(
    [Parameter(Position=1, Mandatory = $true, ValueFromPipeline = $true)] [string]$vcenter,
    [Parameter(Position=2, Mandatory = $true, ValueFromPipeline = $true)] [string]$vcenterUsername,
    [Parameter(Position=3, Mandatory = $true, ValueFromPipeline = $true)] [System.Security.SecureString]$vcenterPassword,
    [Parameter(Position=4, Mandatory = $true, ValueFromPipeline = $true)] [string]$remoteSyslog,
    [Parameter(Position=5, Mandatory = $false, ValueFromPipeline = $true)] [string]$syslogPort = 514,
    [Parameter(Position=6, Mandatory = $false, ValueFromPipeline = $true)] [string]$cluster
)

# Connect to vCenter
if (!($vcenterConnection = Connect-VIServer  -Server $vcenter -User $vcenterUsername -Password ([System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($vcenterPassword))) -ErrorAction SilentlyContinue)) { #DevSkim: ignore DS104456 
    $exceptionError = $Error[0]
    switch ($exceptionError.CategoryInfo.Category) {
        "ObjectNotFound" {
            switch ($exceptionError.CategoryInfo.Reason) {
                "ViServerConnectionException" {
                    Write-Host "=> set.esxi.power.settings -> vCenter not found - $vcenter <=" -ForegroundColor Red
                }
                default {
                    Write-Host "=> set.esxi.power.settings -> ObjectNotFound - Default - vcenter: $vcenter <=" -ForegroundColor Red
                }
            }
            Write-Host "=> Error Category:" $exceptionError.CategoryInfo.Category -ForegroundColor Yellow
            Write-Host "=> Error Message:" $exceptionError.Message -ForegroundColor Yellow
            Write-Host ""
            Exit
        }
        "NotSpecified" {
            switch ($exceptionError.CategoryInfo.Reason) {
                "InvalidLogin" {
                    Write-Host "=> set.esxi.power.settings -> Invalid Credentials - vcenter: $vcenter - username: $username <=" -ForegroundColor Red
                }
                default {
                    Write-Host "=> set.esxi.power.settings -> NotSpecified - Default - vcenter: $vcenter <=" -ForegroundColor Red
                }
            }
            Write-Host "=> Error Category:" $exceptionError.CategoryInfo.Category -ForegroundColor Yellow
            Write-Host "=> Error Reason:" $exceptionError.CategoryInfo.Reason -ForegroundColor Yellow
            Write-Host "=> Error Message:" $exceptionError.Exception.Message -ForegroundColor Yellow
            Exit
        }   
        default {
            Write-Host "=> set.esxi.power.settings -> Default - $vcenter <=" -ForegroundColor Red
            Write-Host "=> Error Category:" $exceptionError.CategoryInfo.Category -ForegroundColor Yellow
            Write-Host "=> Error Reason:" $exceptionError.CategoryInfo.Reason -ForegroundColor Yellow
            Write-Host "=> Error Message:" $exceptionError.Exception.Message -ForegroundColor Yellow
            Exit
        }
    }
}

# Show the current config
Write-Host "--> Current Settings:`n"
if (!$cluster) {
    $vmHosts = Get-VMHost | Sort-Object $_.Name
} else {
    $vmHosts = Get-Cluster -Name $cluster | Get-VMHost | Sort-Object $_.Name
}

# Show current config
$vmHosts | ForEach-Object {
    Write-Host $_.Name
    Get-VMHostSysLogServer -VMHost $_
}

# Set syslog config in hypervisors
$vmHosts | ForEach-Object {
    Write-Host $_.Name
    Set-VMHostSysLogServer -SysLogServer $remoteSyslog":"$syslogPort -VMHost $_
}

# Restart syslog and set the allow rules in the ESXi
$vmHosts | ForEach-Object {
    Write-Host $_.Name
    (Get-Esxcli -v2 -VMHost $_).system.syslog.reload.Invoke()
    (Get-Esxcli -v2 -VMHost $_).network.firewall.ruleset.set.Invoke(@{rulesetid='syslog'; enabled=$true})
    (Get-Esxcli -v2 -VMHost $_).network.firewall.refresh.Invoke()
}


Disconnect-viserver -Server $vcenter -Confirm:$false -ErrorAction SilentlyContinue