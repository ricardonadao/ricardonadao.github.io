---
author: Ricardo Adao
published: true
date: 2025-01-06 17:00:00
last_modified_at: null
header:
  teaser: /assets/images/featured/powercli-150x150.png
title: PowerCLI - Configure syslog server in multiple ESXi
categories:
  - powercli
tags:
  - coding
  - esxi
  - powercli
  - powershell
  - vcenter
  - vmware
  - syslog
toc: true
draft: false
mathjax: false
slug: powercli-configure-syslog-server-multiple-esxi
---
This is a quick powershell script to setup the _remote syslog_ in all the hosts of a cluster or vCenter.

Normally this task is simplified when using the integration of _VMware Log Insight/VMware Aria Operations for Logs (VRLI)_, however this options sometimes is not always available, for example in the extreme cases where a need of an *External Load Balancer* needs to be used for _VRLI_ or if we are not even using it as our logging collector, hence sometimes we could need to setup the syslog for multiple _ESXi_ in one go.

# Script parameters #

* **Mandatory**
  * _**vCenter**_ - vCenter FQDN/IP to connect too
  * _**vCenterUsername**_ - vCenter Username to be used
  * _**vCenterPassword**_ - corresponding password
  * _**RemoteSyslog**_ - FQDN/IP of the syslog server to use

* **Optional**
  * _**cluster**_ - Cluster name if we want to change the hosts from a single cluster
  * _**syslogPort**_  In case of using an alternative port, will use _514_ as default

## Similar to earlier posts the code is pretty simple, so we will focus in the relevant bits ##

* List the current status

```powershell
# Show current config
$vmHosts | ForEach-Object {
    Write-Host $_.Name
    Get-VMHostSysLogServer -VMHost $_
}
```

* Set the remoteSyslog server in each ESXi

```powershell
# Set syslog config in hypervisors
$vmHosts | ForEach-Object {
    Write-Host $_.Name
    Set-VMHostSysLogServer -SysLogServer $remoteSyslog":"$syslogPort -VMHost $_
}
```

* Restart syslog and set the allow rules using Get-Esxcli

```powershell
# Restart syslog and set the allow rules in the ESXi
$vmHosts | ForEach-Object {
    Write-Host $_.Name
    (Get-Esxcli -v2 -VMHost $_).system.syslog.reload.Invoke()
    (Get-Esxcli -v2 -VMHost $_).network.firewall.ruleset.set.Invoke(@{rulesetid='syslog'; enabled=$true})
    (Get-Esxcli -v2 -VMHost $_).network.firewall.refresh.Invoke()
}
```

## _Github_ Link for the entire script **>>** [set.esxi.syslog.ps1]({{ relative_url }}/assets/downloads/scripts/powershell/esxi/set.esxi.syslog.ps1) ##
