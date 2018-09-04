---
ID: 647
post_title: 'Practical NSX: DHCP and DHCP Relay'
author: Amine
post_excerpt: ""
layout: post
permalink: >
  https://vrandombites.co.uk/2018/09/nsx/practical-nsx-dhcp-and-dhcp-relay/
published: true
post_date: 2018-09-01 12:42:39
---
Another service that is offered by NSX is DHCP and DHCP relay. The Edge will listens for DHCP requests on the internal interfaces and offers leases to the requesting clients. Let's have a look on how to configure it.

Below is a diagram of the environment we will be using. Scenario one is APP1 which is connected directly to the edge, Scenario two is the web VMs which are connected into the DLR. These two scenarios will allow us to test DHCP and DHCP relay.

<a href="https://vrandombites.co.uk/wp-content/uploads/2018/09/visio_dhcp.png" target="_blank" rel="noopener"><img class="alignnone wp-image-650 size-medium" src="https://vrandombites.co.uk/wp-content/uploads/2018/09/visio_dhcp-274x300.png" alt="" width="274" height="300" /></a>

&nbsp;
<h2>Configuring DHCP on the Edge</h2>
Double click on the edge you will working with &gt; Manage &gt; DHCP

<a href="https://vrandombites.co.uk/wp-content/uploads/2018/09/dhcp1.png" target="_blank" rel="noopener"><img class="alignnone wp-image-651 size-medium" src="https://vrandombites.co.uk/wp-content/uploads/2018/09/dhcp1-300x52.png" alt="" width="300" height="52" /></a>

I have added a couple of pools and enabled the service.

Pool 192.168.1.x will service the web segment while Pool 192.168.3.x will service the app segment.

<a href="https://vrandombites.co.uk/wp-content/uploads/2018/09/dhcp2.png" target="_blank" rel="noopener"><img class="alignnone wp-image-652 size-medium" src="https://vrandombites.co.uk/wp-content/uploads/2018/09/dhcp2-236x300.png" alt="" width="236" height="300" /></a><a href="https://vrandombites.co.uk/wp-content/uploads/2018/09/dhcp3.png" target="_blank" rel="noopener"><img class="alignnone wp-image-653 size-medium" src="https://vrandombites.co.uk/wp-content/uploads/2018/09/dhcp3-233x300.png" alt="" width="233" height="300" /></a>

Please note that the gateway for 192.168.3.x pool is an interface on the edge while the gateway configured on the 192.168.1.x segment is an interface on the DLR.
<h2>Configuring DHCP Relay on the DLR</h2>
Double click on your DLR  &gt; Manage &gt; DHCP Relay

This is the IP address of the edge interface we will be relaying to.

<a href="https://vrandombites.co.uk/wp-content/uploads/2018/09/dhcp5.png" target="_blank" rel="noopener"><img class="alignnone wp-image-654 size-medium" src="https://vrandombites.co.uk/wp-content/uploads/2018/09/dhcp5-300x144.png" alt="" width="300" height="144" /></a>

This is the segment that will be receiving the DHCP offers, in this is instance it's the web segment.

<a href="https://vrandombites.co.uk/wp-content/uploads/2018/09/dhcp6.png" target="_blank" rel="noopener"><img class="alignnone wp-image-655 size-medium" src="https://vrandombites.co.uk/wp-content/uploads/2018/09/dhcp6-300x67.png" alt="" width="300" height="67" /></a>

We are all set!
<h2>Testing with the APP Segment</h2>
App01 vm is currently connected to the APP logical switch.

<a href="https://vrandombites.co.uk/wp-content/uploads/2018/09/dhcp7.png" target="_blank" rel="noopener"><img class="alignnone wp-image-656 size-medium" src="https://vrandombites.co.uk/wp-content/uploads/2018/09/dhcp7-300x58.png" alt="" width="300" height="58" /></a>

I logged on the edge and issue a <strong>show log follow</strong> command and reboot App01. We can see the whole DHCP process below.

<a href="https://vrandombites.co.uk/wp-content/uploads/2018/09/dhcp8.png" target="_blank" rel="noopener"><img class="alignnone wp-image-658 size-medium" src="https://vrandombites.co.uk/wp-content/uploads/2018/09/dhcp8-300x51.png" alt="" width="300" height="51" /></a>

Checking the App vm, we can confirm that it has received an IP address from the DHCP pool.

<a href="https://vrandombites.co.uk/wp-content/uploads/2018/09/dhcp10.png" target="_blank" rel="noopener"><img class="alignnone wp-image-660 size-medium" src="https://vrandombites.co.uk/wp-content/uploads/2018/09/dhcp10-300x55.png" alt="" width="300" height="55" /></a>
<h2>Testing DHCP Relay</h2>
Web03 vm is currently connected to the Web logical switch

<a href="https://vrandombites.co.uk/wp-content/uploads/2018/09/dhcp11.png" target="_blank" rel="noopener"><img class="alignnone wp-image-661 size-medium" src="https://vrandombites.co.uk/wp-content/uploads/2018/09/dhcp11-300x65.png" alt="" width="300" height="65" /></a>

I logged on the edge and issue a <strong>show log follow</strong> command and reboot App01. We can see the whole DHCP process below.

<a href="https://vrandombites.co.uk/wp-content/uploads/2018/09/dhcp13.png" target="_blank" rel="noopener"><img class="alignnone wp-image-662 size-medium" src="https://vrandombites.co.uk/wp-content/uploads/2018/09/dhcp13-300x91.png" alt="" width="300" height="91" /></a>

Checking the Web vm, we can confirm that it has received an IP address from the DHCP pool so the relay is working (

<a href="https://vrandombites.co.uk/wp-content/uploads/2018/09/dhcp14.png"><img class="alignnone wp-image-663 size-medium" src="https://vrandombites.co.uk/wp-content/uploads/2018/09/dhcp14-300x44.png" alt="" width="300" height="44" /></a>

That's all there is to it folks! Be social share! (: