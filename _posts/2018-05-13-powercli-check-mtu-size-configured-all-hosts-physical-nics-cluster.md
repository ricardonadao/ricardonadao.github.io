---
author: Ricardo Adao
published: true
date: 2018-05-13 10:16:54

header:
  teaser: /assets/images/featured/powercli-150x150.png
title: PowerCLI - Check MTU size configured in all hosts physical nics of a cluster
categories:
  - powercli
tags:
  - coding
  - esxi
  - hypervisor
  - nsx
  - oneliner
  - powercli
  - powershell
  - vmware
  - vsan
  - networking
slug: powercli-check-mtu-size-configured-hosts-physical-nics-cluster
last_modified_at: 2023-06-21T08:15:28.835Z
---
Nowadays with the quick vSAN and NSX adoption, pushing the MTU configuration out of the 1500 bytes standard is becoming more and more common.

So consistency is important for the MTU configuration across all the hosts physical nics (engaged on vSAN and NSX) on a VMware Cluster is becoming also more relevant.

With a couple of _google searchs_ there are multiple options to get this information, using _PowerCLI_, _shellscript_, _python_, _API calls_ and others, definitely one of the cases where you just need to pick your poison.

However, sometimes we just prefer to push us a bit to get that oneliner to get the info that we need, just for bragging rights or just to exercise our skills.

And this post is nothing more than one of those cases, when I decided to check how complicated would be to get this info using a oneliner.

And surprisingly was easier than expected.

```powershell
Get-Cluster –Name “{Custer Name}” | Get-VMHost | `
  %{Write-Host $_.Name ; (Get-EsxCli -VMHost $_ -V2).network.nic.list.Invoke() | `
  %{Write-Host "NIC:"$_.Name "MTU:"$_.MTU}}
```

[![HomeLab example]({{ relative_url }}/assets/images/posts/2018/05/powercli-pnic.mtu.oneliner.example-1024x281.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2018/05/powercli-pnic.mtu.oneliner.example-1024x281.png)

Of course to get into this we need to do the normal vCenter connection:

```powershell
Connect-VIServer -Name <vCenterName>
```