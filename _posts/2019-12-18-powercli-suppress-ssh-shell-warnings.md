---
author: Ricardo Adao
published: true
post_date: 2019-12-18 21:00:00
last_modified_at: null
header:
  teaser: /assets/images/featured/powercli-150x150.png
title: PowerCLI - Suppress SSH and ESXi shell warnings
categories:
  - powercli
tags:
  - powercli
  - powershell
  - vmware
  - coding
  - automation
toc: true
slug: powercli-suppress-ssh-esxi-shell-warnings
lastmod: 2023-06-21T08:14:23.733Z
---
When we deploy a set of ESXi's most of the times we endup enabling SSH and ESXi shell to help troubleshooting.

But that simple tweak leaves a _warning_ in each of the ESXi's.

[![SSH/Shell Warning Example]({{ relative_url }}/assets/images/posts/2019/12/esxi-ssh-shell-warning.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2019/12/esxi-ssh-shell-warning.png)

This is a pretty simple manual task since it will be just a question of going through each of the ESXi's in vCenter and _click_ suppress.

But while is a quick task when it is a small cluster, it could become a repetitive task when you are deploying multiple ESXi's through some an automated deployed process.

Let us put some _Powershell_ lines together to suppress the warnings in multiple ESXi's in one go.

## PowerCLI cmdlets - _Set-AdvancedSetting_ and _Get-AdvancedSetting_

We will use cmdlets:

* [_Set-AdvancedSetting_](https://code.vmware.com/docs/10197/cmdlet-reference/doc/Get-AdvancedSetting.html)
* [_Get-AdvancedSetting_](https://code.vmware.com/docs/10197/cmdlet-reference/doc/Set-AdvancedSetting.html).

## Host _Advanced Setting_ to change

To suppress the _alerts/warnings_ we will need to change _UserVars.SuppressShellWarning_ .

## Checking host _Advanced Setting_ current value

To check the current value in each hypervisor of a cluster we can quickly use _Get-AdvancedSetting_ cmdlet:

```powershell
$cluster = Get-Cluster -Name <Cluster Name>

Write-Host "> Cluster - $cluster" -ForegroundColor Red

$hosts = $cluster | Get-VMHost

foreach($hyp in $hosts) {
    Write-Host "-> Host -> $hyp" -ForegroundColor Yellow

    # Suppress SSH/Shell Warnings
    $currentStatus = Get-AdvancedSetting `
        -Entity (Get-VMHost -Name $hyp.Name) `
        -Name UserVars.SuppressShellWarning

    Write-Host "##> Suppress SSH/Shell Warnings " `
        "- Current Status = $currentStatus" -ForegroundColor Cyan
}
```

A quick check to validate the current setting status:

[![Check setting current status Example]({{ relative_url }}/assets/images/posts/2019/12/esxi-ssh-shell-script-current-status.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2019/12/esxi-ssh-shell-script-current-status.png)

## Changing the setting

We can use _Set-AdvancedSetting_ cmdlet to change the advanced setting to suppress the warnings.

```powershell
    # Suppress SSH/Shell Warnings
    $currentStatus = Get-AdvancedSetting `
        -Entity (Get-VMHost -Name <ESXi Name>)  `
        -Name UserVars.SuppressShellWarning

    Write-Host "##> Suppress SSH/Shell Warnings " `
        "- Current Status = $currentStatus" -ForegroundColor Cyan

    # Setting AdvancedSetting to 1
    #   0 = No Suppression
    #   1 = Suppress warnings
    $null = $currentStatus | `
        Set-AdvancedSetting -Value 1 -Confirm:$false

    $lastStatus = Get-AdvancedSetting `
        -Entity (Get-VMHost -Name <ESXi Name>)  `
        -Name UserVars.SuppressShellWarning

    Write-Host "##> Suppress SSH/Shell Warnings " `
        "- Last Status = $lastStatus" -ForegroundColor Green
```

Let us change the setting and check the result after:

[![Change Setting Example]({{ relative_url }}/assets/images/posts/2019/12/esxi-ssh-shell-script-status-change.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2019/12/esxi-ssh-shell-script-status-change.png)

ESXi suppressed warnings/alerts:

[![ESXi Warnings/Errors Example]({{ relative_url }}/assets/images/posts/2019/12/esxi-ssh-shell-warning-suppressed.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2019/12/esxi-ssh-shell-warning-suppressed.png)

## Getting a quick script together

```powershell
param(
    [Parameter(Position=1, Mandatory = $true, `
        ValueFromPipeline = $true)] [string]$vcenter,
    [Parameter(Position=2, Mandatory = $true, `
        ValueFromPipeline = $true)] [string]$username,
    [Parameter(Position=3, Mandatory = $true, `
        ValueFromPipeline = $true)] [System.Security.SecureString]$password
)

Write-Host "-> Connect to site $vcenter" -ForegroundColor Green

$vcenterConnection = Connect-VIServer -Server $vcenter `
    -User $username `
    -Password ([System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($password)))

$clusters = Get-Cluster -Server $vcenterConnection

foreach($cluster in $clusters) {
    Write-Host "--> Cluster - $cluster" -ForegroundColor Green

    $hosts = Get-Cluster -Name $cluster | Get-VMHost

    foreach($hyp in $hosts) {
        Write-Host "---> Host -> $hyp" -ForegroundColor Green

        # Suppress SSH/Shell Warnings
        $statusBefore = Get-AdvancedSetting `
            -Entity (Get-VMHost -Name $hyp.Name) `
            -Name UserVars.SuppressShellWarning

        $null = $resultBefore | `
            Set-AdvancedSetting -Value 1 -Confirm:$false

        $statusAfter = Get-AdvancedSetting `
            -Entity (Get-VMHost -Name $hyp.Name) `
            -Name UserVars.SuppressShellWarning

        Write-Host "---# Suppress SSH/Shell Warnings - Status = " `
            "Before:$(($statusBefore).Value) - " `
            "After:$(($statusAfter).Value)" -ForegroundColor Red
    }
}

Disconnect-VIServer -Server $vcenterConnection `
    -Confirm:$false -ErrorAction SilentlyContinue
```
