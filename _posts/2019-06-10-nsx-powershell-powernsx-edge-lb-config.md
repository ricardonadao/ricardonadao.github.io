---
author: Ricardo Adao
published: true
post_date: 2019-06-10 08:00:00
last_modified_at: 2019-06-10 08:20:00
header:
  teaser: /assets/images/featured/nsx-150x150.png
title: NSX - Configure a _Load Balancer_ in an _Edge Security Gateway_ using _Powershell/PowerNSX_
categories: [ nsx ]
tags: [ nsx, nsx-v, networking, vmware, coding, automation, powercli, powershell, powernsx, sddc ]
toc: true
---
This is a quick snippet explaining how to use _Powershell_ and _[PowerNSX](https://powernsx.github.io/)_ to configure a _Load Balancer (LB)_ in an _Edge Security Gateway (ESG)_.

# Objective

Setting up a simple _DNS LB_ using _Powershell_ and _[PowerNSX](https://powernsx.github.io/)_ with the following specs:

* 1x VIP - _ESG - Internal interface_  
  * _10.0.0.1/29_ _(VXLAN X)_
* 2x pool members - _ESG - External interface_  
  * _172.16.52.10/24_ and _172.16.52.11/24_ _(VLAN X)_
* _LB_ policy - Round-Robin
* Transparent

We will not create a new _ESG_ in the post, hence we will use an existing one and add the _LB_ configuration to it.
{: .notice--info}

[![ESG Example]({{ site.url }}/assets/images/posts/2019/06/nsx-powershell-powernsx-esg-lb.png){:class="img-responsive"}]({{ site.url }}/assets/images/posts/2019/06/nsx-powershell-powernsx-esg-lb.png)

We will be setting up the _LB_ in the internal interface _(Transit - 10.0.0.1)_.

The final objective is to allow any host/client in the _Transit_ network _(10.0.0.0/29)_, to use _ESG LB IP (10.0.0.1)_ has _DNS server_.
And load balancing the requests across the two _DNS servers_ _(172.16.52.10 and 172.16.52.11)_.

# Setup

Let's set it up, step by step.

## Enabling _LB service_ of the _ESG_

To get the LB working we need to _enable_ the _LB_ service in the edge.

### Enabling _LB_ service

```powershell
$null = Get-NsxEdge -Name "vPOD-Edge" | `
  Get-NsxLoadBalancer | Set-NsxLoadBalancer -Enabled
```

### Enabling _LB_ service acceleration

Enabling _LB Acceleration_ gets the _ESG LB_ to use the faster _L4 LB_ engine instead of the _L7 LB_ engine.

```powershell
$null = Get-NsxEdge -Name "vPOD-Edge" | `
  Get-NsxLoadBalancer | Set-NsxLoadBalancer -EnableAcceleration
```

## Creating _Application profile_

We need to create an _Application profile_ to define the behaviour of a particular type of network traffic, in our case _DNS_ is _UDP_.

```powershell
$dnsAppProfile = Get-NsxEdge -Name "vPOD-Edge" | Get-NsxLoadBalancer | `
  New-NsxLoadBalancerApplicationProfile -Name "DNS LB" -Type UDP
```

## Creating _Server Pool_

### Create an object with our _pool members_

Create an _object_ with our _pool members_ with each of the objects being an _hash_ to be make it simple to add additionally entries if we need.

```powershell
$lbPoolMembers = @(
  @{ name = "dns01"; ip = "172.16.52.10" },
  @{ name = "dns02"; ip = "172.16.52.11" }
)
```

### Create an object with _LoadBalancerMember_ objects to create our _server pool_ configuration

```powershell
$lbPool = @()
foreach ($member in $lbPoolMembers) {
    $lbPool += New-NsxLoadBalancerMemberSpec -name $member.name `
    -IpAddress $member.ip -Port 53 -MonitorPort 53
}
```

### Create our _server pool_ with the objects created above

```powershell
$dnsServerPool = Get-NsxEdge -Name "vPOD-Edge" | `
  Get-NsxLoadBalancer | `
  New-NsxLoadBalancerPool -name "DNSpool" `
    -Description "Local DNS pool" `
    -Transparent:$true -Algorithm round-robin `
    -Memberspec $lbPool
```

## Configure _LB VIP_

```powershell
$null = Get-NsxEdge -Name $edgeName | Get-NsxLoadBalancer | `
  Add-NsxLoadBalancerVip -name "LAB06_Local_DNS_LB" `
    -Description "VIP LB for LAB06 Local DNS/DC servers" `
    -ipaddress "10.0.0.1" `
    -Protocol udp -Port 53 -ApplicationProfile $dnsAppProfile `
    -DefaultPool $dnsServerPool -AccelerationEnabled
```

# Summary

A quick summary of what we setup

1. We enable _LB_ service in the _ESG_
2. Create an _Application profile_ to define our particular traffic behaviour
3. Create a _server pool_ with our two _pool members_
4. Last we configure our _LB VIP_