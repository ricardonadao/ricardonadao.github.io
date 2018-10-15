---
layout: post
author: Ricardo Adao
published: true
post_date: 2018-09-02 08:00:00
title: NSX - How to automate a 3 Tier App deployment - Part 1
categories: [ nsx ]
tags: [ coding, automation, nsx, powercli, powernsx, powershell, sddc, vmware, networking ]
comments: true
---
One of the big advantages of the NSX is to a Software Defined Network (SDN) solution given us the ability to code once and execute as many times.

NSX has a really rich and complete _REST API_ documented at _[VMware API Explorer - NSX 6.4](https://code.vmware.com/apis/329/nsx-for-vsphere)_.

There are multiple options to leverage the _NSX API_:

* Using a _REST API Client_, as _[Postman](https://www.getpostman.com/)_ for example
* Going _old school_ with _curl_
* Using _Powershell_ using cmdlets similar to _Invoke-RestMethod_ or _Invoke-WebRequest_
* Using _python_ mapping all the API calls similar to what would be done with any other programming language that we would prefer
* Using _[PowerNSX](https://powernsx.github.io/)_ powershell module that abstracts all the hassle of payload creation and API calls

In these series of posts we will leverage _[PowerNSX](https://powernsx.github.io/)_ module to simplify the interaction with the _NSX Rest_ API.

# Objective #

The main objective of this series will be to demonstrate how can we leverage some of the _NSX_ capabilities to facilitate the provision of multiple similar environments in an automated way.

## Scenario ##

We want to be able to deploy and destroy multiple copies of the _standardized solution_, that we will reference through the series as _vPOD_. Each of these _vPODs_ will be able to host a _3 Tier App Solution_. The main goal is to minimize the deployment/redeployment manual effort to the bare minimum.

### Network Diagram ###

Let us kick this off with a simple network diagram of our _vPOD_ that we will automate in the next few posts:

[![vPOD Visio]({{ site.url }}/assets/images/posts/2018/09/nsx-create-edge_visio.png){:class="img-responsive"}]({{ site.url }}/assets/images/posts/2018/09/nsx-create-edge_visio.png)

### Requirements ###

* Each tier will have their own network segment
* Each segment will have their own subnet
* Inter and Intra segment traffic need to be fully secured
* Tiers
  * _WebApp_ - Webservers/FrontEnd Servers
    * will be the only tier exposed to the public
    * tier provides HTTP services
    * front-end services will be load balanced across multiple servers
  * _App_ - Application/MidTier servers
    * tier to host all the app servers
    * app servers will be load balanced across multiple servers
  * _DB_- Database tier
    * tier hosting all the databases servers with the data used by the app servers

### Instead of long post lets divide these in multiple parts ###

* Create Logical Switches
* Create NSX Edge Service Gateway
* Create NSX Distributed Logic Router
* Configure Distributed Firewall
* Configure NSX Edge Service Gateway
  * Configure SNATs & DNATs
  * Configure Firewall Rules

The division of the entire process in smaller posts will give some room to detail each step and create a more modular process, where each scripted step can be used individually and re-used.
