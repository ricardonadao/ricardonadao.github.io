---
ID: 600
post_title: 'Practical NSX: Routing using BGP'
author: Amine
post_excerpt: ""
layout: post
permalink: >
  https://vrandombites.co.uk/2018/08/nsx/nsx-routing-using-bgp/
published: true
post_date: 2018-08-25 22:46:12
---
<!-- wp:paragraph -->
<p></p><p>As you probably all know, NSX out of the box supports a couple of routing protocols, namely OSPF and BGP. IS-IS used to be supported but has since been removed. &nbsp;BGP is technically an Exterior Gateway Protocol or EGP and is designed to interact with devices outside of the network boundaries. OSPF and IS-IS on the other hand should be used inside the network boundaries. I am guessing that's the reason why BGP cannot configured on the LDR and is only available on the EDGE.</p>
<p>Configuring BGP on NSX is quite simple. All you need is your neighbour's details and the AS numbers of the devices involved and you are good to go! One thing I need to mention as it will have an impact on the configuration, is that I will be using iBGP instead of eBGP hence both my routers will be on the same AS. For those of you want to learn more about the differences between iBGP and eBGP please have a look this great article from&nbsp;<a href="https://www.packetdesign.com/blog/network-basics-what-are-ibgp-and-ebgp/">Packet Design</a>.</p>
<p>In this article, I will be setting up BGP between an NSX Edge and a Vyos virtual router.&nbsp;</p>
<p><strong>Vyos Configuration</strong></p>
<p>Below are the interfaces that are configured.&nbsp;</p>
<p><a href="https://vrandombites.co.uk/wp-content/uploads/2018/08/bgp1.png"><img class="alignnone wp-image-604 size-medium" src="https://vrandombites.co.uk/wp-content/uploads/2018/08/bgp1-300x73.png" alt="" width="300" height="73"/></a></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p></p><p>Let's add the vyos-bgp-lif (192.168.16.2) as a neighbour with a remote AS of 6500&nbsp;</p>
<p><a href="https://vrandombites.co.uk/wp-content/uploads/2018/08/bgp3.png"><img class="alignnone wp-image-607 size-medium" src="https://vrandombites.co.uk/wp-content/uploads/2018/08/bgp3-300x27.png" alt="" width="300" height="27"/></a></p>
<p>Resulting config:</p>
<p><a href="https://vrandombites.co.uk/wp-content/uploads/2018/08/bgp4.png"><img class="alignnone wp-image-609 size-medium" src="https://vrandombites.co.uk/wp-content/uploads/2018/08/bgp4-300x54.png" alt="" width="300" height="54"/></a></p>
<p><strong>EDGE Configuration</strong></p>
<p><a href="https://vrandombites.co.uk/wp-content/uploads/2018/08/bgp2.png"><img class="alignnone wp-image-605 size-medium" src="https://vrandombites.co.uk/wp-content/uploads/2018/08/bgp2-300x22.png" alt="" width="300" height="22"/></a></p>
<p>Double click on your Edge and navigate to <strong>Manage &gt; Routing &gt; BGP&nbsp;</strong></p>
<p>Enable BGP and configure your Local AS</p>
<p><a href="https://vrandombites.co.uk/wp-content/uploads/2018/08/bgp5.png"><img class="alignnone wp-image-610 size-medium" src="https://vrandombites.co.uk/wp-content/uploads/2018/08/bgp5-300x283.png" alt="" width="300" height="283"/></a></p>
<p>Now let's configure our neighbour which is the Vyos router. Please note that I am using the same AS.</p>
<p><a href="https://vrandombites.co.uk/wp-content/uploads/2018/08/bgp6.png"><img class="alignnone wp-image-611 size-medium" src="https://vrandombites.co.uk/wp-content/uploads/2018/08/bgp6-293x300.png" alt="" width="293" height="300"/></a></p>
<p>The last piece to take care of is the route distribution&nbsp;</p>
<p><a href="https://vrandombites.co.uk/wp-content/uploads/2018/08/bgp7.png"><img class="alignnone wp-image-612 size-medium" src="https://vrandombites.co.uk/wp-content/uploads/2018/08/bgp7-300x36.png" alt="" width="300" height="36"/></a></p>
<p><a href="https://vrandombites.co.uk/wp-content/uploads/2018/08/bgp8.png"><img class="alignnone wp-image-613 size-medium" src="https://vrandombites.co.uk/wp-content/uploads/2018/08/bgp8-300x291.png" alt="" width="300" height="291"/></a></p>
<p>That's it! The configuration is now complete on both sides. Looking at both the Edge and the Vyos routers we can see that they are both speaking BGP and exchanging routes.</p>
<p><strong>Vyos Side:</strong></p>
<p><a href="https://vrandombites.co.uk/wp-content/uploads/2018/08/bgp9.png"><img class="alignnone size-thumbnail wp-image-614" src="https://vrandombites.co.uk/wp-content/uploads/2018/08/bgp9-150x150.png" alt="" width="150" height="150"/></a></p>
<p><a href="https://vrandombites.co.uk/wp-content/uploads/2018/08/bgp10.png"><img class="alignnone wp-image-615 size-medium" src="https://vrandombites.co.uk/wp-content/uploads/2018/08/bgp10-300x91.png" alt="" width="300" height="91"/></a></p>
<p><strong>NSX Edge:</strong></p>
<p><a href="https://vrandombites.co.uk/wp-content/uploads/2018/08/bgp11.png"><img class="alignnone wp-image-616 size-medium" src="https://vrandombites.co.uk/wp-content/uploads/2018/08/bgp11-300x60.png" alt="" width="300" height="60"/></a></p>
<p><strong>Please note:</strong> I have no networks added to the interface on the Vyos router hence we are not seeing any BGP route entries on the Edge.</p>
<p><a href="https://vrandombites.co.uk/wp-content/uploads/2018/08/bgp12.png"><img class="alignnone wp-image-617 size-medium" src="https://vrandombites.co.uk/wp-content/uploads/2018/08/bgp12-300x100.png" alt="" width="300" height="100"/></a></p>
<!-- /wp:paragraph -->