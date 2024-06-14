---
author: Ricardo Adao
published: true
date: 2018-12-18 10:00:00
header:
  teaser: /assets/images/featured/homelab-150x150.png
title: Setting up a _Nested Internet_ for our Homelab - Part 1
categories:
  - homelab
tags:
  - homelab
  - nested
  - linux
  - networking
  - cumulus
  - frr
  - pfsense
toc: true
slug: setting-nested-internet-homelab-part-1
last_modified_at: 2023-06-21T08:14:37.322Z
---
Title seems a bit strange and even a bit overly optimistic.

However, we are not **reinventing the Internet**, what we are doing is just **simulating a small scale Fake Internet** to allow us to play around with some **dynamic routing** and simulate **inter-datacenter connections** inside our **Homelab** without the need of multiple physical sites.

<figure class="half">
  <a href="{{ relative_url }}/assets/images/posts/2018/12/networking-datacenters.png"><img src="{{ relative_url }}/assets/images/posts/2018/12/networking-datacenters.png"></a>
  <a href="{{ relative_url }}/assets/images/posts/2018/12/networking-datacenters-nested-interconnects.png"><img src="{{ relative_url }}/assets/images/posts/2018/12/networking-datacenters-nested-interconnects.png"></a>
  <figcaption>Our target setup</figcaption>
</figure>

In this post we will focus in the **Logical Level** of the setup, leaving the details for following posts.

## Creating our _**"Fake Internet"**_

Since we are doing this in a **HomeLab** and everything will be **nested datacenters**, we will need to create our own _"Fake Internet"_ to allow us to simulate our **_inter-DC connections**.

<figure>
  <a href="{{ relative_url }}/assets/images/posts/2018/12/networking-fake-internet.png"><img src="{{ relative_url }}/assets/images/posts/2018/12/networking-fake-internet.png"></a>
  <figcaption>Our <b><em>"Fake Internet"</em></b></figcaption>
</figure>

### A _**Fake Internet**_ will need _**Fake Providers**_ and _**Fake Peering**_

In our case we will use **Lab Router** as our _**Fake Provider**_ peer, and will us _BGP_ to keep it similar to the _Real Internet_.

For our **Fake Internet** will use _Autonomous System Numbers (AS)_ from the _private range_: 64512 – 65534

We will give to each of our **nested datacenters** their own _AS number_ to allow us to give each of them a _Public Segment_ and to play around with some _BGP_.

Also we will use some _IP private ranges_ for our **Fake Internet** and _Nested DCs_ public address space.

<figure>
  <a href="{{ relative_url }}/assets/images/posts/2018/12/networking-fake-internet-bgp-addresspaces.png"><img src="{{ relative_url }}/assets/images/posts/2018/12/networking-fake-internet-bgp-addresspaces.png"></a>
  <figcaption>Our AS's and Adressing Space in our <em>"Fake Internet"</em></figcaption>
</figure>

### BGP Peering between our _datacenters_ and our _"Internet"_

Lets use _DC01_ as our example of how we will setup the _BGP peering_ between our _datacenters_ and _"Internet"_.

<figure>
  <a href="{{ relative_url }}/assets/images/posts/2018/12/networking-fake-internet-bgp-dc01-peering.png"><img src="{{ relative_url }}/assets/images/posts/2018/12/networking-fake-internet-bgp-dc01-peering.png"></a>
  <figcaption>DC01 to "Internet" BGP peering</figcaption>
</figure>

For each of our **datacenters** we will setup an _eBGP peering_ with our _**"Internet Provider/Carrier"**_ router **(Lab-Router)**.
We will be propagating using _BGP_ all the **"Public Segments"** assigned to each of the **datacenters** (in <span style="color:limegreen">green</span>).

## How will we do it

We will be using [_VMware vSphere_ ](https://www.vmware.com/uk/products/vsphere.html) as our **Virtualization platform** since it will give us all the performance, flexibility and stability that we will need for this, and also it is the current installed platform in my **Homelab**.

For the **network components** of the solution we will be using:

* [_Free Range Routing (FRR)_](https://frrouting.org/)
* [_Cumulus VX_](https://cumulusnetworks.com/products/cumulus-vx/)
* [_pfSense_](https://www.pfsense.org/)
* _VMware NSX - [NSX-v](https://www.vmware.com/products/nsx.html) and NSX-T)_

I will not cover the installation of each of these components on this series, since there are multiple ways of installing it and multiple flavours to choose.

In my personal case, for example, being a [_Slackware_](http://www.slackware.com/) user, some compiling and tweaking was needed to get [_FRR_](https://frrouting.org/) up and running on my **DC01 router**, since I decided to use my _Home Network gateway_ as the **DC01 router** instead of installing an additional appliance.

However, most of the installations are straight forward if we keep under the "supported options".

## Goal

Our main goal with this setup, in first instance, is to use _BGP routing_ to propagate our _Public DC segments_ throughout our **Fake Internet** and make those segments **reachable** from any **datacenter**.

This will allow us to create **inter-datacenter** connections over our **Fake Internet**.

Once we get that working, we will kick off with the **2nd part** of our setup, which will be setting up IPSEC tunnels between **datacenters** to allow us to reach their **internal management networks**.

In summary, we will be setting up a _SD-WAN wannabee solution_ to allow us to setup **full inter-datacenter connectivity**.