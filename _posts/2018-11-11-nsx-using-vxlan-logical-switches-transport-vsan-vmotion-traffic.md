---
author: Ricardo Adao
published: true
post_date: 2018-11-11 20:00:00
last_modified_at:
header:
  teaser: /assets/images/featured/nsx-150x150.png
title: NSX - Using VXLAN logical switches to transport vSAN and vMotion traffic
categories: [ nsx ]
tags: [ nsx, networking, vmware, nested, vsan, sddc ]
toc: true
---
The title seems weird and at first glance we will think... **NO WAY**

However lets dig a bit more in what is the idea behind it?

# Context

The title sounds weird and could also be misleading.

So lets clear it a bit, to be easier to understand what would be discussed in the post.

We will not be running _VMware vSAN_ and _VMware vMotion (vMotion)_ traffic on top of the _VXLAN VTEPs_ VMKernel.

What we will be doing instead, is running _Nested Hypervisor clusters_ on top of _Logical switches_.

The main objective here was to leverage _VMware NSX (NSX)_ software defined solution to reduce the number of changes in the _physical underlay_ and speed up the _Nested Hypervisors cluster_ process.

**Remember this is a _Lab environment_**, definitely not recommend to use this in a _Production Environment_. Some of the configurations and tweaks neeed touch or cross the line of _unsupported production solutions_.
{: .notice--warning}

# Analysis

We will go through the analysis of some key points of this post to justify some of the conclusions and why all of this works.

## VXLAN

The _Virtual Extensible LAN (VXLAN)_ is an encapsulation protocol that provides a way to extend _L2 network_ over a _L3 infrastructure_ by using _MAC-in-UDP_ encapsulation and tunneling.

[![VXLAN frame]({{ relative_url }}/assets/images/posts/2018/11/vxlan-frame.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2018/11/vxlan-frame.png)

At this point we have the ability to present _L2 networks_ to the _Nested Hypervisors cluster_ as if it was a normal _VLAN_ or _L2 network_.

![Green Check Mark]({{ relative_url }}/assets/images/common/green-check-mark-25x25.png){:class="img-responsive"} So for now, there is no _show stopper_ to what we are doing, since from the _Nested Hypervisors cluster_ view there is no difference.

We kept digging and checking what are the _vSAN_ and _vMotion_ requirements from the networking point of view.

## _vSAN_ network requirements

[![Network Requirements for vSAN]({{ relative_url }}/assets/images/posts/2018/11/vsan-network-requirements.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2018/11/vsan-network-requirements.png)

[_link: VMware Docs - Networking Requirements for vSAN_](https://docs.vmware.com/en/VMware-vSphere/6.7/com.vmware.vsphere.vsan-planning.doc/GUID-AFF133BC-F4B6-4753-815F-20D3D752D898.html)

* Bandwidth
  * Dedicated 1Gbps for hybrid configurations
  * Dedicated or shared 10Gbps for all-flash configurations
* Connection between hosts
  * Each host in _vSAN_ cluster needs a VMKernel network adapter for _vSAN_ traffic
* Host network
  * All hosts in _vSAN_ cluster must be connected to a _vSAN_ L2 or L3 network
* IPv4 and IPv6 support
  * _vSAN_ network supports both IPV4 or IPV6

![Green Check Mark]({{ relative_url }}/assets/images/common/green-check-mark-25x25.png){:class="img-responsive"} Going through the requirements seems that a _Logical Switch_ still fullfill all the basic requirements, so we should be ok, potentially we will have some performance hit, but it should work.

## vMotion network requirements

[![Networking Best Practices for vSphere vMotion]({{ relative_url }}/assets/images/posts/2018/11/vmotion-network-best-practices.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2018/11/vmotion-network-best-practices.png)

[_link: VMware Docs - vSphere vMotion Networking Requirements_](https://docs.vmware.com/en/VMware-vSphere/6.5/com.vmware.vsphere.vcenterhost.doc/GUID-3B41119A-1276-404B-8BFB-A32409052449.html)

[_link: Networking Best Practices for vSphere vMotion _](https://docs.vmware.com/en/VMware-vSphere/6.5/com.vmware.vsphere.vcenterhost.doc/GUID-7DAD15D4-7F41-4913-9F16-567289E22977.html)

* Bandwidth
  * _vMotion_ network limits
  [![Network Limits for Migration with vMotion]({{ relative_url }}/assets/images/posts/2018/11/vmotion-network-limits.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2018/11/vmotion-network-limits.png)
* Connection between hosts
  * Each host in the cluster needs a _VMKernel vMotion_ portgroup configured
* Host Network
  * At least one network interface for _vMotion_ traffic
* IPv4 and IPv6 support
  * _vMotion_ supports both IPv4 and IPv6

![Green Check Mark]({{ relative_url }}/assets/images/common/green-check-mark-25x25.png){:class="img-responsive"} Seems that we are still ok from _vMotion_ point of view.

# Conclusion

Since _Logical switches_ seem to fullfill all the _vSAN_ and _vMotion_ requirements we should be ok to use them for the _L2 underlay_ for the _Nested Hypervisors cluster_.

By removing the need of changes in the _physical underlay_ will be easier to automate the _Nested Environments_ provisioning process.

I will go through some of those automation bits in following posts.

**But to summarize all the post**, in theory we should not have any problems running _vSAN_ and _vMotion_ on top of _logical switches_ for the _Nested Hypervisors cluster_.
