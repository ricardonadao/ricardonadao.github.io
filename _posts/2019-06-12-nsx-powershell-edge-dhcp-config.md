---
author: Ricardo Adao
published: true
post_date: 2019-06-12 08:00:00

header:
  teaser: /assets/images/featured/nsx-150x150.png
title: NSX - Configure a _DHCP_ service in an _Edge Security Gateway_ using _Powershell_
categories:
  - nsx
tags:
  - nsx
  - nsx-v
  - networking
  - vmware
  - coding
  - automation
  - powercli
  - powershell
  - sddc
toc: true
slug: nsx-configure-dhcp-service-edge-security-gateway-powershell
last_modified_at: 2023-06-21T08:14:32.082Z
---
This is a quick snippet explaining how to use _Powershell_ to configure the _DHCP service_ in an _Edge Security Gateway (ESG)_.

# Objective

Setting up a simple _DHCP_ server with a single _IP pool_ - _192.168.0.100/24 - 192.168.0.200/24_ - in an _ESG_ using _Powershell_.

[![ESG Example]({{ relative_url }}/assets/images/posts/2019/06/nsx-powershell-powernsx-esg-dhcp.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2019/06/nsx-powershell-powernsx-esg-dhcp.png)

We will use an existing _ESG_ instead of creating a new one, similar to what we did in [NSX - Configure a Load Balancer in an Edge Security Gateway using Powershell/PowerNSX]({{ relative_url }}{% link _posts/2019-06-10-nsx-powershell-powernsx-edge-lb-config.md %})
{: .notice--info}

The _DHCP service_ will be listening in the _ESG internal interface (Transit - VXLAN X)_.

# Setup

Let's set it up, step by step.

## Challenge

Our prefered _Powershell_ module _PowerNSX (v 3.0.1125)_, unfortunatelly do not have any cmdlets to help us with the _DHCP service_ configuration, so we will need to fallback to the _XML_ and _Invoke-NSXWebRequest_ method.

```powershell
PS /Users/radao> get-help Invoke-NsxWebRequest

NAME
    Invoke-NsxWebRequest
    
SYNOPSIS
    Constructs and performs a valid NSX REST call and returns a response object
    including response headers.
    
    
SYNTAX
    Invoke-NsxWebRequest [-method <String>] [-URI <String>] 
      [-body <String>] [-connection <PSObject>] [-extraheader <Hashtable>]
       [-Timeout <Int32>] [<CommonParameters>]
    
    Invoke-NsxWebRequest -cred <PSCredential> -server <String> -port <Int32>
      -protocol <String> -UriPrefix <String> -ValidateCertificate <Boolean>
      -method <String> -URI <String> [-body <String>] [<CommonParameters>]
```

## Preparing the _XML_ payload needed for the call

We will need to get the following info to a _XML_ payload/format that we can push to _Invoke-NSXWebRequest_ cmdlet:
  - Enable service
  - Range      = _192.168.0.100-192.168.0.200_
  - Gateaway   = _192.168.0.1_
  - Subnet     = _255.255.255.0_
  - Lease Time = _86400_

```powershell
$xmlPayload = "
  <dhcp>
    <enabled>true</enabled>
    <ipPools>
      <ipPool>
        <ipRange>192.168.0.100-192.168.0.200</ipRange>
        <defaultGateway>192.168.0.1</defaultGateway>
        <subnetMask>255.255.255.0</subnetMask>
        <leaseTime>86400</leaseTime>
        <autoConfigureDNS>false</autoConfigureDNS>
      </ipPool>
    </ipPools>
    <logging><enable>true</enable>
    <logLevel>info</logLevel></logging>
  </dhcp>"
```

## Make the _Invoke-NSXWebRequest_ call done with the _XML payload_ that we just created

Get the _ESG ID_ that we need to get the current object information.

```powershell
    $edgeID = (Get-NsxEdge -Name "vPOD-Edge").Id
```

Setting up the call _URL_:

```powershell
    $uri = "/api/4.0/edges/$($edgeID)/dhcp/config"
```

Execute and call _Invoke-NSXWebRequest:
```powershell
    $null = invoke-nsxwebrequest -method "put" `
      -uri $uri -body $xmlPayload -connection $nsxConnection
```

The _$nsxConnection_ is the object produced by the _Connect-NSXServer_ when connecting to the _NSX manager_ of the solution.
{: .notice--info}

# Summary

A quick summary of what we setup

1. Enable _DHCP_ service in the _ESG
2. Prepare the _XML payload_
3. Make the _PUT_ call _Invoke-NSXWebRequest_