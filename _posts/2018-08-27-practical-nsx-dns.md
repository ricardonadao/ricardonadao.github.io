---
ID: 627
post_title: 'Practical NSX: DNS'
author: Amine
post_excerpt: ""
layout: post
permalink: >
  https://vrandombites.co.uk/2018/08/nsx/practical-nsx-dns/
published: true
post_date: 2018-08-27 00:17:17
---
Amongst the various services that the NSX Edge provide is DNS forwarding. A NSX edge  relay name resolution requests from clients to external DNS servers. In this blog post, we will go through the configuration the we will test that all is working as expected.

<a href="https://vrandombites.co.uk/wp-content/uploads/2018/08/dns.png"><img class="alignnone wp-image-628 size-medium" src="https://vrandombites.co.uk/wp-content/uploads/2018/08/dns-300x279.png" alt="" width="300" height="279" /></a>

The setup is quite simple. I have a couple of VMs connected to a logical switch which is then connected to an LDR. The LDR is connected to an Edge via a transit LS. The Edge is exchanging routes with a Vyatta router using OSPF. Static routes are configured on the Edge to reach the networks attached to the LDR. My DNS server is Windows box that lives outside my NSX environment.

In NSX, <strong>double click on your Edge &gt; Settings &gt; Configuration </strong>

Enter your DNS details and configure how much cache you would like to reserve. Logging can also be turned on if required.

<a href="https://vrandombites.co.uk/wp-content/uploads/2018/08/dns1.png"><img class="alignnone size-thumbnail wp-image-632" src="https://vrandombites.co.uk/wp-content/uploads/2018/08/dns1-150x150.png" alt="" width="150" height="150" /></a>

That is all that is needed from the Edge side! It can't be any easier can it? (:

Let's test if all is working using one of my web VMs.

Below is the web01 configuration:

<a href="https://vrandombites.co.uk/wp-content/uploads/2018/08/dns2.png"><img class="alignnone wp-image-633 size-medium" src="https://vrandombites.co.uk/wp-content/uploads/2018/08/dns2-300x56.png" alt="" width="300" height="56" /></a>

<a href="https://vrandombites.co.uk/wp-content/uploads/2018/08/dns3.png"><img class="alignnone wp-image-634 size-medium" src="https://vrandombites.co.uk/wp-content/uploads/2018/08/dns3-300x29.png" alt="" width="300" height="29" /></a>

I checked my DNS server and I can confirm that an A record does exist for web02 which we will be using to test if DNS forwarding is working.

<a href="https://vrandombites.co.uk/wp-content/uploads/2018/08/dns4.png"><img class="alignnone wp-image-635 size-medium" src="https://vrandombites.co.uk/wp-content/uploads/2018/08/dns4-300x23.png" alt="" width="300" height="23" /></a>

On my web01 vm, I am going to run a nslookup on web02 to check if resolution is working as expected.

<a href="https://vrandombites.co.uk/wp-content/uploads/2018/08/dns5.png"><img class="alignnone wp-image-636 size-medium" src="https://vrandombites.co.uk/wp-content/uploads/2018/08/dns5-300x59.png" alt="" width="300" height="59" /></a>

We can see that are receiving the correct record for web02 and that the Edge is the one that is doing the forwarding.
<h3>Troubleshooting DNS</h3>
Logon to your Edge and check the service is running

<a href="https://vrandombites.co.uk/wp-content/uploads/2018/08/dns8.png" target="_blank" rel="noopener"><img class="alignnone wp-image-643 size-medium" src="https://vrandombites.co.uk/wp-content/uploads/2018/08/dns8-300x189.png" alt="" width="300" height="189" /></a>

We can also the configuration by issuing the command <strong>show dns configuration </strong>

<a href="https://vrandombites.co.uk/wp-content/uploads/2018/08/dns9.png" target="_blank" rel="noopener"><img class="alignnone wp-image-644 size-medium" src="https://vrandombites.co.uk/wp-content/uploads/2018/08/dns9-300x290.png" alt="" width="300" height="290" /></a>

If you need to check the logs, use the <strong>show log</strong> command

Thank you for reading.