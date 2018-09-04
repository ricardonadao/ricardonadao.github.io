---
ID: 516
post_title: A quick look at NSX Controllers
author: Amine
post_excerpt: ""
layout: post
permalink: >
  https://vrandombites.co.uk/2018/07/nsx/a-quick-look-at-nsx-controllers/
published: true
post_date: 2018-07-24 12:21:04
---
NSX Controller is an advanced distributed state management system that provides control plane functions for NSX logical switching and routing functions. The controller cluster is responsible for managing the distributed switching and routing modules in the hypervisor, the gathered network information is distributed to hosts.  Please note: The controller does not have any dataplane traffic passing through it, therfore loosing the controllers should not have an impact on the traffic flow.

<strong>A couple of requirements:</strong>
<ul>
 	<li>VMware requires that each NSX Controller cluster contain three controller nodes. Having a different number of controller nodes is not supported.</li>
 	<li>The cluster requires that each controller's disk storage system has a peak write latency of less than 300ms, and a mean write latency of less than 100ms.</li>
</ul>
<strong>NSX Controllers Provide:</strong>
<ul>
 	<li>VXLAN distribution and DLR workload handling</li>
 	<li>Information to ESXi hosts.</li>
 	<li>Workload distribution through slicing dynamically amongst all controllers</li>
 	<li>Removal of multicast</li>
 	<li>ARP broadcast traffic suppression in VXLAN networks</li>
</ul>
<strong>NSX Controllers store:</strong>
<ul>
 	<li>ARP Table (Per VNI): ARP requests are intercepted by the hosts and sent to NSX controllers.</li>
 	<li>VTEP table (Per VNI): A VTEP IP to MAC mapping</li>
 	<li>MAC table (Per VNI): A VM MAC to VTEP IP mapping.</li>
 	<li>Routing table: Obtained from the DRL control VM</li>
</ul>
<strong>An Example:</strong>

In the example below a have a couple of VMs attached to a logical switch. Let's have a look at what information the master controller has stored.The VMs I am tetsing with here are web01 and web02.

<a href="https://vrandombites.co.uk/wp-content/uploads/2018/07/nsx1.png"><img class="alignnone wp-image-517 size-medium" src="https://vrandombites.co.uk/wp-content/uploads/2018/07/nsx1-300x275.png" alt="" width="300" height="275" /></a>

VMs are in different clusters

<a href="https://vrandombites.co.uk/wp-content/uploads/2018/07/nsx2.png"><img class="alignnone wp-image-518 size-medium" src="https://vrandombites.co.uk/wp-content/uploads/2018/07/nsx2-300x73.png" alt="" width="300" height="73" /></a>

VMs are attached to the LS-WEB logical switch. The assigned VNI is 5003.

<a href="https://vrandombites.co.uk/wp-content/uploads/2018/07/nsx3.png"><img class="alignnone wp-image-519 size-medium" src="https://vrandombites.co.uk/wp-content/uploads/2018/07/nsx3-300x52.png" alt="" width="300" height="52" /></a>

<a href="https://vrandombites.co.uk/wp-content/uploads/2018/07/nsx4.png"><img class="alignnone wp-image-520 size-medium" src="https://vrandombites.co.uk/wp-content/uploads/2018/07/nsx4-300x56.png" alt="" width="300" height="56" /></a>

VMs are able to ping each other.

Let's log on to the controllers:

<a href="https://vrandombites.co.uk/wp-content/uploads/2018/07/nsx5.png"><img class="alignnone wp-image-521 size-medium" src="https://vrandombites.co.uk/wp-content/uploads/2018/07/nsx5-300x26.png" alt="" width="300" height="26" /></a>

Controller with IP 192.168.0.46 is the master controller.

<a href="https://vrandombites.co.uk/wp-content/uploads/2018/07/nsx6.png"><img class="alignnone wp-image-522 size-medium" src="https://vrandombites.co.uk/wp-content/uploads/2018/07/nsx6-300x31.png" alt="" width="300" height="31" /></a>

The ARP Table for VNI 5003 shows the IP/MAC mapping of web01 and web02

<a href="https://vrandombites.co.uk/wp-content/uploads/2018/07/nsx7.png"><img class="alignnone wp-image-523 size-medium" src="https://vrandombites.co.uk/wp-content/uploads/2018/07/nsx7-300x21.png" alt="" width="300" height="21" /></a>

The VTEP table for VNI 5003 shows the IP/MAC mapping to the hosts that web01 and web02 are running on.

<a href="https://vrandombites.co.uk/wp-content/uploads/2018/07/nsx8.png"><img class="alignnone wp-image-524 size-medium" src="https://vrandombites.co.uk/wp-content/uploads/2018/07/nsx8-300x28.png" alt="" width="300" height="28" /></a>

The mac-table shows the mapping of the MACs  of web01 and web02 to their VTEPS.

That's all there is to it!

<strong>If you found this useful, please share.</strong>

&nbsp;