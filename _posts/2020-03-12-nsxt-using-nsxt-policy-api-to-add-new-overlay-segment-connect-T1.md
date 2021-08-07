---
author: Ricardo Adao
published: true
post_date: 2020-03-12 08:00:00  
last_modified_at:
header:
  teaser: /assets/images/featured/nsx-150x150.png
title: NSX-T Data Center - Using NSX-T Policy API to add a new overlay segment connected to a T1 router
categories: [ nsx ]
tags: [ nsx-t, nsx, powercli, powershell, vmware ]
toc: true
---
In previous posts:

* [Create _VLAN backed_ segment using _NSX-T Policy API_]({% post_url 2020-02-26-nsxt-using-nsxt-policy-api-to-add-new-segments-vlan-backed %})
* [Create _Overlay_ segment using _NSX-T Policy API_]({% post_url 2020-03-11-nsxt-using-nsxt-policy-api-to-add-new-overlay-segment %})

## Information needed to setup our snippet

### Transport Zone

To be able to create the segment in the right transport zone, we will need to collect the _Transport Zone ID_ and the easiest way to retrieve it is through the _simplified UI_.

[![NSX-T Transport Zone ID]({{ relative_url }}/assets/images/posts/2020/03/powercli-nsxt-overlay-transport-zone.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2020/03/powercli-nsxt-overlay-transport-zone.png)

Now that we have the _Transport Zone ID_ we can build the variable that will give us the _path_ for the transport zone object.

```powershell
# Example: /infra/sites/default/enforcement-points/default/transport-zones/<transport zone ID>
$transportZone = "/infra/sites/default/enforcement-points/default/transport-zones/ce028afd-c95f-4ed8-8fdb-1ecb06fb4bde"
```

### _T1_ Router information

We will use a _T1 router_ that we have already created, we will cover the _T1 router_ creation in a future post.

To check the _T1 router ID_, and the information of the _T1 router path_ object, we can use the following call to list all _T1 routers_:

```powershell
(Get-NsxtPolicyService -Name com.vmware.nsx_policy.infra.tier1s).list().results | Select display_name, id, parent_path
```

* Result
  [![NSX-T Router T1s list]({{ relative_url }}/assets/images/posts/2020/03/powercli-nsxt-list-t1s-routers.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2020/03/powercli-nsxt-list-t1s-routers.png)

```powershell
# path - /infra/tier-1s/<router ID>
$routerT1Path = "/infra/tier-1s/_T1-GW-AP-01_"
```

### New segment gateway

To connect the new overlay segment to the _T1 router_ a _gateway IP_ needs to be setup also.

```powershell
# Gateway IP will need to use CIDR format (IP/PrefixLength)
$newSegmentGateway = "10.10.103.1/24"
```

## Variables

Since it is a quick code snippet we could keep the list of variables on the top to reduce the need of editing the functional part of the snippet.

```powershell
# Segment information
$segmentID = "POD01-SegmentA-Overlay-TZ-01"

# Transport Zone
$transportZone="/infra/sites/default/enforcement-points/default/transport-zones/ce028afd-c95f-4ed8-8fdb-1ecb06fb4bde"

# Router Path
$routerT1Path = "/infra/tier-1s/_T1-GW-AP-01_"

# Segment Gateway
$newSegmentGateway = "10.10.103.1/24"
```

## Main code snippet body

This code snippet assumes that you are already connected to the _NSX-T Manager_ using:

```powershell
Connect-NsxtServer -Server "vcenter.lab" -User "admin" -Password "MyAwesomePassword"
```

```powershell
# Pull the current segment information
$segmentList = Get-NsxtPolicyService -Name com.vmware.nsx_policy.infra.segments

# Creating a new segment object
$newSegmentSpec = $segmentList.Help.patch.segment.Create()
$newSegmentSpec.id = $segmentID
$newSegmentSpec.transport_zone_path = $transportZone
$newSegmentSpec.connectivity_path = $routerT1Path

# Retrieve a Subnet object from the segment structure
$newSubnetSpec = $segmentList.Help.patch.segment.subnets.Element.Create()
$newSubnetSpec.gateway_address = $newSegmentGateway

# Add subnet object to our new segment spec
$newSegmentSpec.subnets.Add($newSubnetSpec)

# Create the segment
$segmentList.patch($segmentID, $newSegmentSpec)
```

## Result

[![Code Snippet run]({{ relative_url }}/assets/images/posts/2020/03/powercli-nsxt-new-overlay-segment-t1-router-connected-code-snippet-run.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2020/03/powercli-nsxt-new-overlay-segment-t1-router-connected-code-snippet-run.png)

[![New Overlay Segments T1 connected - Simplified UI]({{ relative_url }}/assets/images/posts/2020/03/powercli-nsxt-new-overlay-segment-t1-router-connected-result-01.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2020/03/powercli-nsxt-new-overlay-segment-t1-router-connected-result-01.png)

[![New Overlay Segments T1 connected - Subnet - Simplified UI]({{ relative_url }}/assets/images/posts/2020/03/powercli-nsxt-new-overlay-segment-t1-router-connected-result-02.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2020/03/powercli-nsxt-new-overlay-segment-t1-router-connected-result-02.png)
