---
author: Ricardo Adao
published: true
post_date: 2020-03-11 08:00:00
header:
  teaser: /assets/images/featured/nsx-150x150.png
title: NSX-T Data Center - Using NSX-T Policy API to add new overlay segments
categories:
  - nsx
tags:
  - nsx-t
  - nsx
  - powercli
  - powershell
  - vmware
toc: true
slug: nsx-data-center-nsx-policy-api-add-overlay-segments
last_modified_at: 2023-06-21T08:14:16.970Z
---
One of the fundamental tasks of an _NSX-T_ deployment is creating new segments.

In a [_previous post_]({% post_url 2020-02-26-nsxt-using-nsxt-policy-api-to-add-new-segments-vlan-backed %}) we created a snippet to add new VLAN Backed segments using the _NSX-T Policy API_. This time we will create a quick snippet to add _Overlay segments_.

As in the [_previous post_]({% post_url 2020-02-26-nsxt-using-nsxt-policy-api-to-add-new-segments-vlan-backed %}) we will not connect the new segment to any _T0/T1_, we will do that in a later post covering overlay and vlan segments. 

# Quick reminder of the PowerCLI NSX-T Policy API CMDlets

The list of NSX-T Policy API CMDlets is not massive.

[![NSX-T Policy API CMDlets]({{ relative_url }}/assets/images/posts/2020/02/powercli-nsxt-cmdlets-list.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2020/02/powercli-nsxt-cmdlets-list.png)

Based in the number of cmdlets available could give the impression that you will not be able to do a lot of things with them, however these four cmdlets are powerful enough to create, remove or modify any object in the _NSX-T Manager_.

## Quick snippet to create a new overlay segment

As mentioned, this post will focus in a quick code snippet to allow us to create multiple overlay segments in NSX-T using the _NSX-T Policy API_.

The cmdlet _Get-NsxtPolicyService_ is the main key to all of it.

## Information needed to setup our snippet

### Transport Zone

To be able to create the segment in the right transport zone, we will need to collect the _Transport Zone ID_ and the easiest way to retrieve it is through the _simplified UI_.

[![NSX-T Transport Zone ID]({{ relative_url }}/assets/images/posts/2020/03/powercli-nsxt-overlay-transport-zone.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2020/03/powercli-nsxt-overlay-transport-zone.png)

Now that we have the _Transport Zone ID_ we can build the variable that will give us the _path_ for the transport zone object.

```powershell
$transportZone="/infra/sites/default/enforcement-points/default/transport-zones/ce028afd-c95f-4ed8-8fdb-1ecb06fb4bde"
```

## Variables

Since it is a quick code snippet we could keep the list of variables on the top to reduce the need of editing the functional part of the snippet.

```powershell
# Segment information
$segmentIDPrefix = "POD01-"
$segmentIDSuffix = "-Overlay-TZ-01"

# Transport Zone
$transportZone="/infra/sites/default/enforcement-points/default/transport-zones/ce028afd-c95f-4ed8-8fdb-1ecb06fb4bde"

# Segment Individual Name
$segmentIDs = @("segmentA", "segmentB", "segmentC", "segmentD")
```

## Main code snippet body

The main body of the code snippet has two sections:

* _Foreach cycle_ to go through our _Segment Individual ID_ list
  * Segment creation within the _Foreach cycle_

### _Foreach cycle_ to go through our _Segment Individual ID_ list

This code snippet assumes that you are already connected to the _NSX-T Manager_ using:

```powershell
Connect-NsxtServer -Server "vcenter.lab" -User "admin" -Password "MyAwesomePassword"
```

```powershell
Foreach ($segmentID in $segmentIDs) {
  # create SegmentID information using the predefined prefix + Segment Individual ID + suffix from the list
  $segmentID = $segmentIDPrefix + $segmentID + $segmentIDSuffix

  # Pull the current segment information
  $segmentList = Get-NsxtPolicyService -Name com.vmware.nsx_policy.infra.segments

  # Creating a new segment object
  $newSegmentSpec = $segmentList.Help.patch.segment.Create()
  $newSegmentSpec.id = $segmentID
  $newSegmentSpec.transport_zone_path = $transportZone

  # Create the segment
  $segmentList.patch($segmentID, $newSegmentSpec)
}
```

## Result

[![Code Snippet run]({{ relative_url }}/assets/images/posts/2020/03/powercli-nsxt-new-overlay-segments-code-snippet-run.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2020/03/powercli-nsxt-new-overlay-segments-code-snippet-run.png)

[![New Overlay Segments List - Simplified UI]({{ relative_url }}/assets/images/posts/2020/03/powercli-nsxt-overlay-new-overlay-segments.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2020/03/powercli-nsxt-overlay-new-overlay-segments.png)
