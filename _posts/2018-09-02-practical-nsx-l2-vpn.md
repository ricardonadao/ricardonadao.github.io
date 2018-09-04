---
ID: 681
post_title: 'Practical NSX: L2 VPN'
author: Amine
post_excerpt: ""
layout: post
permalink: >
  https://vrandombites.co.uk/2018/09/nsx/practical-nsx-l2-vpn/
published: true
post_date: 2018-09-02 11:40:43
---
Another feature of the NSX edge is L2VPN which enable stretching layer 2 subnet over layer 3 networks. VLAN to VLAN, VXLAN to VXLAN, VLAN to VXLAN, VXLAN to VLAN are all supported configuration.

One site is configured as the L2 VPN Server and the other as the L2 VPN Client. Let's set this up.

Below is the envirement we will be working with.

<a href="https://vrandombites.co.uk/wp-content/uploads/2018/09/layer2vpndiag.png" target="_blank" rel="noopener"><img class="alignnone wp-image-698 size-medium" src="https://vrandombites.co.uk/wp-content/uploads/2018/09/layer2vpndiag-300x236.png" alt="" width="300" height="236" /></a>
<h2>Setting up the server side</h2>
Double click on your edge &gt; Manage &gt; Settings &gt; Intefaces

The first interface will be an outside facing interface connected to the "vms" portgroup

<a href="https://vrandombites.co.uk/wp-content/uploads/2018/09/l2vpn1.png" target="_blank" rel="noopener"><img class="alignnone wp-image-699 size-medium" src="https://vrandombites.co.uk/wp-content/uploads/2018/09/l2vpn1-300x155.png" alt="" width="300" height="155" /></a>

The second interface will be a trunk interface with a sub-interface configured.  Please note: L2VPN-SERVER is a portgroup on my DVS, l2vpn-server is the logical switch that is connected to my VMs.

<a href="https://vrandombites.co.uk/wp-content/uploads/2018/09/l2vpn2.png" target="_blank" rel="noopener"><img class="alignnone wp-image-700 size-medium" src="https://vrandombites.co.uk/wp-content/uploads/2018/09/l2vpn2-221x300.png" alt="" width="221" height="300" /></a>

Now navigate to Manage &gt; VPN &gt; L2VPN

<a href="https://vrandombites.co.uk/wp-content/uploads/2018/09/l2vpn3.png" target="_blank" rel="noopener"><img class="alignnone wp-image-701 size-medium" src="https://vrandombites.co.uk/wp-content/uploads/2018/09/l2vpn3-300x193.png" alt="" width="300" height="193" /></a>

Check the server L2VPN mode, then choose your listener IP and your encryption.

Now let's setup the site configuration

<a href="https://vrandombites.co.uk/wp-content/uploads/2018/09/l2vpn4.png" target="_blank" rel="noopener"><img class="alignnone wp-image-702 size-medium" src="https://vrandombites.co.uk/wp-content/uploads/2018/09/l2vpn4-300x156.png" alt="" width="300" height="156" /></a>

Choose a user id and a password and add the sub-interface created ealier.

Enable the service and pubish the changes.
<h2>Setting up the client side</h2>
You will be creating similar interfaces to the ones we created on the server side.

Double click on your edge &gt; Manage &gt; Settings &gt; Intefaces

<a href="https://vrandombites.co.uk/wp-content/uploads/2018/09/l2vpn5.png" target="_blank" rel="noopener"><img class="alignnone wp-image-703 size-medium" src="https://vrandombites.co.uk/wp-content/uploads/2018/09/l2vpn5-300x31.png" alt="" width="300" height="31" /></a>

One the interfaces created,  navigate to Manage &gt; VPN &gt; L2VPN

Check the client L2VPN mode then choose your listener IP and your encryption.

<a href="https://vrandombites.co.uk/wp-content/uploads/2018/09/l2vpn6.png" target="_blank" rel="noopener"><img class="alignnone wp-image-704 size-medium" src="https://vrandombites.co.uk/wp-content/uploads/2018/09/l2vpn6-300x146.png" alt="" width="300" height="146" /></a>

Enter the same user id and password that you used on the server side and add the sub-interface. Finally enable the service.

If evertthing has been enabled correctly your vpn should be showing a status of up.

<a href="https://vrandombites.co.uk/wp-content/uploads/2018/09/l2vpn7.png" target="_blank" rel="noopener"><img class="alignnone wp-image-705 size-medium" src="https://vrandombites.co.uk/wp-content/uploads/2018/09/l2vpn7-300x103.png" alt="" width="300" height="103" /></a>

Our test vms should also be able to ping each other.

<a href="https://vrandombites.co.uk/wp-content/uploads/2018/09/l2vpn8.png" target="_blank" rel="noopener"><img class="alignnone wp-image-706 size-medium" src="https://vrandombites.co.uk/wp-content/uploads/2018/09/l2vpn8-300x141.png" alt="" width="300" height="141" /></a>

You can also check your VPN statistics from any of your edges

<a href="https://vrandombites.co.uk/wp-content/uploads/2018/09/l2vpn9.png" target="_blank" rel="noopener"><img class="alignnone wp-image-707 size-medium" src="https://vrandombites.co.uk/wp-content/uploads/2018/09/l2vpn9-300x144.png" alt="" width="300" height="144" /></a>

I hope this post has been informative, please be social share (: