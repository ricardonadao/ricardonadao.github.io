---
author: Ricardo Adao
published: true
date: 2020-02-26 08:00:00
header:
  teaser: /assets/images/featured/nsx-150x150.png
title: NSX-T Data Center - Using NSX-T Policy API to add new segments (VLAN Backed)
categories:
  - nsx
tags:
  - nsx-t
  - nsx
  - powercli
  - powershell
  - vmware
toc: true
slug: nsx-data-center-nsx-policy-api-add-segments-vlan-backed
last_modified_at: 2023-06-21T08:14:19.786Z
---
One of the fundamental tasks of an _NSX-T_ deployment is creating new segments.

If you are just adding an hand full of segments probably the easier way is to use the UI and add the segments through the _Simplified UI_.

However, if you have more than an hand full of segments you will probably check if you can leverage the _NSX-T Policy API_ to reduce the admin effort to create them all.

# PowerCLI NSX-T Policy API CMDlets

The list of NSX-T Policy API CMDlets is not massive.

[![NSX-T Policy API CMDlets]({{ relative_url }}/assets/images/posts/2020/02/powercli-nsxt-cmdlets-list.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2020/02/powercli-nsxt-cmdlets-list.png)

Based in the number of cmdlets available could give the impression that you will not be able to do a lot of things with them, however these four cmdlets are powerful enough to create, remove or modify any object in the _NSX-T Manager_.

## Quick snippet to create a new segment (VLAN Backed)

This post will focus in a quick code snippet to allow us to create multiple segments VLAN backed in NSX-T using the _NSX-T Policy API_.

The cmdlet _Get-NsxtPolicyService_ is the main key to all of it.

## Information needed to setup our snippet

To be able to create the segment in the right transport zone, we will need to collect the _Transport Zone ID_ and the easiest way to retrieve it is through the _simplified UI_.

[![NSX-T Transport Zone ID]({{ relative_url }}/assets/images/posts/2020/02/nsxt-transport-zone-id.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2020/02/nsxt-transport-zone-id.png)

Now that we have the _Transport Zone ID_ we can build the variable that will give us the _path_ for the transport zone object.

```powershell
$transportZone="/infra/sites/default/enforcement-points/default/transport-zones/c8e7a995-573f-4001-9288-f4d5b5ee8789"
```

## Variables

Since it is a quick code snippet we could keep the list of variables on the top to reduce the need of editing the functional part of the snippet.

```powershell
# Segment information
$segmentIDPrefix = "POD01-VLAN-"

# Transport Zone
$transportZone="/infra/sites/default/enforcement-points/default/transport-zones/c8e7a995-573f-4001-9288-f4d5b5ee8789"

# VLAN IDs to use for the new segments
$vlanIDs = @(10, 11, 12, 13, 14)
```

## Main code snippet body

The main body of the code snippet has two sections:

* _Foreach cycle_ to go through our _VLAN ID_ list
  * Segment creation within the _Foreach cycle_

### _Foreach cycle_ to go through our _VLAN ID_ list

This code snippet assumes that you are already connected to the _NSX-T Manager_ using:

```powershell
Connect-NsxtServer -Server "vcenter.lab" -User "admin" -Password "MyAwesomePassword"
```

```powershell
Foreach ($vlanID in $vlanIDs) {
  # create SegmentID information using the predefined prefix + VLAN ID from the list
  $segmentID = $segmentIDPrefix + $vlanID

  # Pull the current segment information
  $segmentList = Get-NsxtPolicyService -Name com.vmware.nsx_policy.infra.segments

  # Creating a new segment object
  $newSegmentSpec = $segmentList.Help.patch.segment.Create()
  $newSegmentSpec.id = $segmentID
  $newSegmentSpec.vlan_ids = @( $vlanID )
  $newSegmentSpec.transport_zone_path = $transportZone

  # Create the segment
  $segmentList.patch($segmentID, $newSegmentSpec)
}
```

## Result

[![Code Snippet run]({{ relative_url }}/assets/images/posts/2020/02/powercli-nsxt-code-snippet-run.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2020/02/powercli-nsxt-code-snippet-run.png)


[![New Segments List - Simplified UI]({{ relative_url }}/assets/images/posts/2020/02/nsxt-simplified-ui-new-segments-list.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2020/02/nsxt-simplified-ui-new-segments-list.png)
