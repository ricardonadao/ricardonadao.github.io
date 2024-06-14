---
author: Ricardo Adao
published: true
header:
  teaser: /assets/images/featured/powercli-150x150.png
title: "PowerCLI - One Line Series #01"
categories:
  - powercli
tags:
  - coding
  - esxi
  - hypervisor
  - vcenter
  - oneliner
  - powercli
  - powershell
  - vmware
slug: powercli-line-series-01
last_modified_at: null
date: 2024-06-14T14:48:39.671Z
toc: true
draft: false
mathjax: false
---
This is probably the first of many of these quick fire posts to track some of the quick oneliners that we end up creating to address immediate challenges.

## Get a list of connected Portgroups/Segments for each Virtual Machines in a vSphere Cluster

```powershell
Get-Cluster -Name <cluster name> | Get-VM `
  | %{ Write-Host -n "--> " $_ ; `
       Get-NetworkAdapter -VM $_ | ft -auto}
```

### Oneliner Output

[![Get a list of the Portgroups/Segments that a Virtual Machines is connected]({{ relative_url }}/assets/images/posts/2024/06/powercli-line-series-01-pic01.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2024/06/powercli-line-series-01-pic01.png)

## Get a list of all Virtual Machines processes running in the hosts in a vSphere Cluster

```powershell
(Get-Cluster -Name <cluster name> | Get-VMHost `
  | %{ Write-Host -n "--> $_"; `
       (Get-esxCli -v2 -VMHost $_).vm.process.list.Invoke() }).DisplayName
```

### Oneliner Output

[![Get a list of Virtual Machines processes running in all the hosts in a cluster]({{ relative_url }}/assets/images/posts/2024/06/powercli-line-series-01-pic02.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2024/06/powercli-line-series-01-pic02.png)

## NSX-T Bridge - Reverse Path Forward Check Promiscuous - Get the current value

```powershell
Get-Cluster -Name <cluster name> | Get-VMHost `
  | %{ Write-Host -n "--> $_"; `
       (Get-AdvancedSetting -Entity $_  -Name "Net.ReversePathFwdCheckPromisc" `
       | ft -AutoSize) }
```

### Oneliner Result

[![Get current value of ReversePathFwdCheckPromisc in all hosts in a vSphere cluster]({{ relative_url }}/assets/images/posts/2024/06/powercli-line-series-01-pic03.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2024/06/powercli-line-series-01-pic03.png)

## NSX-T Bridge - Reverse Path Forward Check Promiscuous - Set the value

```powershell
Get-Cluster -Name <cluster name> | Get-VMHost `
  | %{ Write-Host -n "--> $_"; `
       (Get-AdvancedSetting -Entity $_ -Name "Net.ReversePathFwdCheckPromisc" `
       | Set-AdvancedSetting -Value 1) }
```

### Oneliner Result

[![Set value of ReversePathFwdCheckPromisc in all hosts in a vSphere cluster]({{ relative_url }}/assets/images/posts/2024/06/powercli-line-series-01-pic04.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2024/06/powercli-line-series-01-pic04.png)

   _Reference_: [_NSX-T Bridge - Overlay - VLAN_](https://docs.vmware.com/en/VMware-NSX-T-Data-Center/3.2/administration/GUID-0E28AC86-9A87-47D4-BE25-5E425DAF7585.html)
