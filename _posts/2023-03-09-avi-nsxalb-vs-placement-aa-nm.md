---
author: Ricardo Adao
published: true
lastmod: 2023-06-21T08:13:41.808Z
date: 2023-03-09T17:21:51.156Z
header:
  teaser: /assets/images/featured/avi-150x150.png
title: Avi/NSX ALB - Virtual Service placement in A/A and N+M Elastic HA modes
categories:
  - avi
tags:
  - avi
  - nsxalb
  - load balance
  - networking
  - nsx
  - vmware
  - homelab
toc: true
draft: false
mathjax: true
slug: avi-nsx-alb-virtual-service-placement-elastic-ha-modes
---
One of the main challenges when we are designing and implementing _**Avi/NSX Advanced Load Balancer**_ configurations will be the decision between which of the _**Elastic HA Mode**_ to use and what are the differences between the two.

We are not covering the _**Legacy HA**_ since normally do not represent a challenge being a well established topology.

[Legacy HA for Avi Service Engines](https://avinetworks.com/docs/latest/legacy-ha-for-avi-service-engines/)

## Basic Concepts

### Placement

* The _Controller_ is the component responsible to decide where to place a _Virtual Service_
* Each _Virtual Service_ has a property defining the minimum number of _Service Engines_ for the _VS_ to be placed
* The _placement algorithm_ will be run multiple times by the _Controller_ for each _new/enabled VS_ until the minimum number of _Service Engines_ configured for that _VS_ is achieved
* In a _Write Access cloud_, the outcome of the placement algorithm could involve creation of new _Service Engines_ and network _"plumbing"_ changes to provide the necessary connectivity
* In case of a _Service Engine_ failure, the affected _VSs_ will be re-placed using the same algorithm

### SE Group Parameters

There are some _Service Engine Group_ parameters that also influence the _VS_ placement:

* **Max SEs per group**
  * Max number of SEs that can be provisioned in the SE Group. (Applicable only in _Write-Access_ cloud)
* **Max VS per SE (_v_)**
  * Max number of VSs than can be place in each individual SE
* **Min scale per VS**
  * Number minimum of SEs that a VS will be placed
* **Max scale per VS**
  * Number of maximum of SEs that a VS will be placed
* **Buffer (_b_)**
  * Additional _SE_ capacity that should be available for _HA_. This parameter determines the number of _SE_ failures that we can handle in the _SE group_ before we drop below our desired _HA_ threshold, considering the __Max VS per SE__ that we configured.

### Some calculations

The _Controller_ (_SE Resource Manager_ ) takes care to calculate how much capacity is needed in each _SE group_.

The capacity required in each _SE group_ is calculated based in the number of _VSs_ and their respective current scale out.
Assuming for simplicity that each _VS_ counts has one (1) slot, for example:
 * a _VS_ scaled out to two (2) _SEs_ will consume two (2) slots
 * a _VS_ scaled out to a single _SE_ will consume one (1) slot

The calculations done by _Resource Manager_ will use a simple formula to calculate the number of _SEs_ (**N**) that are needed to meet the capacity required to place our _VSs_, taking in consideration the _**SE group**_  parameters that we mentioned before in [_SE Group Parameters_](#se-group-parameters)

<center>$ n = \lceil{\large\frac{c}{v}}\rceil+{b} $</center>

_Note: $ \lceil $ and $ \rceil $ is the _ceiling_ function to round up to the nearest whole number_

* Two quick examples
  * _SE Group_ A
      * three (3) _VSs_ scaled out to two (2) _SEs_
      * one (1) _VS_ scaled out to a single _SE_
    * Capacity required for our _VSs_ is \\( c = 9 \\)
    * Using our simple formula to calculate the number _SEs_ (_n_) needed:
      * $ n = \lceil{\large\frac{9}{4}}\rceil+{1} $
      * $ n = 4 $, meaning that we need four (4) _SEs_ to accommodate our _VSs_ needs
  * _SE Group_ B
    * \\( v = 8 \\) and \\( b = 1 \\)
    * _Virtual Services_
      * three (3) _VSs_ scaled out to two (2) _SEs_
      * one (1) _VS_ scaled out to a single _SE_
    * Capacity required for our _VSs_ is \\( c = 9 \\)
    * Using our simple formula to calculate the number _SEs_ (_n_) needed:
      * $ n = \lceil{\large\frac{9}{8}}\rceil+{1} $
      * $ n = 3 $, meaning that we need three (3) _SEs_ to accommodate our _VSs_ needs

### Some factors that are considered when placing a _VS_ in an _SE_

We are not listing all the factors that could affect the _VS_ placement in an _SE_, since the idea is to give an idea and not going into all the detail that is taken in consideration.

* Particular _VSs_ that need to be placed together
  * VIP Sharing
  * SNI Parent/Child
* VIP/Pool reachability
  * Static placement
  * Network topology
* Nic limitations
  * Virtual machines have a limited number of interfaces (Virtual machines in VMware limited to ten (10) virtual network cards)
  * Limited number of IP addresses allowed per nic (AWS limits for example)

### Distributed versus Compact placement mechanism

There are two (2) different placement mechanism that will affect how the _VS_ will be placed and in _Write-Access cloud_ could affect the number of _SEs_ that will be deploy, or not, during the process of placing the _VSs_.

* **Distributed**
  * Distributed aims to distribute _VSs_ across as many _SEs_ as possible. In _Write-Access cloud_ it could hit the _maximum number of SEs_ threshold in a _SE group_ before starting to add _VSs_ to existing _SEs_
  * Placement algorithm
    1. If there is a _SE_ without any _VS_ on it, place the new _VS_ on the _SE_
    1. If _Write-Access cloud_ and the _number of deployed SEs_ $ \lt $ _Maximum SEs in SE group_ and _VS_ not scaled out on another _SE_ already, try to deploy a new _SE_ and re-run the placement algorithm again
    1. Place the _VS_ in the least-loaded _SE_ from the ones that are valid candidates for the _VS_
    1. If the _VS_ is still not placed and if _Write-Access cloud_ and the _number of deployed SEs_ $ \lt $ _Maximum SEs in SE group_, create a new _SE_ and re-run the placement algorithm again
    1. If the _VS_ is still not placed, consider _SEs_ that would normally be ineligible due anti-affinity
* **Compact with Buffer $ = $ 0**
  * Compact aims to squeeze as much _VSs_ as possible onto existing _SEs_ where possible
  * Placement algorithm
    1. If there is a _SE_ without any _VS_ on it, place the new _VS_ on the _SE_
    1. If _Write-Access cloud_ and the _number of deployed SEs_ $ \lt $ _Maximum SEs in SE group_ and _VS_ not scaled out on another _SE_ already, try to deploy a new _SE_ and re-run the placement algorithm again
    1. Place the _VS_ on the least-loaded _SE_ from the ones that are valid candidates for the _VS_
    1. If the _VS_ is still not placed and if _Write-Access cloud_ and the _number of deployed SEs_ $ \lt $ _Maximum SEs in SE group_, create a new _SE_ and re-run the placement algorithm again
    1. If the _VS_ is still not placed, consider _SEs_ that would normally be ineligible due anti-affinity
* **Compact with Buffer $ \neq $ 0**
  * Compact aims to squeeze as much _VSs_ as possible onto existing _SEs_ where possible without impacting the configured _buffer_ threshold
  * Placement algorithm
    1. Calculates how many _SEs_ in the _SE group_ are needed to support the existing _VSs_ plus the new extra capacity for the new _VSs_ to be placed (_n_)
    1. If _n_ $ \gt $ _number of deployed SEs_ and $ \lt $ _Maximum SEs in SE group_ and _Write-Access cloud_, trigger a deployment of a new _SE_ and if successful re-run the placement algorithm
    1. If _n_ $ \geq $ _number of deployed SEs_, place the _VS_ on the least-loaded _SE_ from the ones that are valid candidates for the _VS_. Empty _SEs_ are considered
    1. If _n_ $ \leq $ _number of deployed SEs_, place the _VS_ on the least-loaded _SE_ from the ones that are valid candidates for the _VS_. Empty _SEs_ are not considered, except if they are the only option
    1. If _Write-Access cloud_ and the _number of deployed SEs_ $ \lt $ _Maximum SEs in SE group_, trigger a deployment of a new _SE_ (if not attempted already on this interaction) and if successful re-run the placement algorithm
    1. If the _VS_ is still not placed, consider _SEs_ that would normally be ineligible due anti-affinity

### Creation/Deletion of SEs in Write-Access cloud

In a _Write-Access cloud_ the creation and deletion of _SEs_ is managed automatically by the controller plane based in the capacity required by the _VSs_.

* An _SE_ is **created** when (number of _SEs_ in a _SE group_ is limited by the _Maximum SEs in a SE group_ parameter)
  * Explicit request by the user when a _VS_ is scaled out or migrated
  * Triggered by the placement algorithm
  * By the controller if the number of deployed _SEs_ drops under number of _SEs_ required to fulfil our capacity requirements of the enabled _VSs_, taking the _buffer_ parameter in consideration for this calculation
  * Controller attempts to deploy the _SE VM_ on the most suitable host taking resources and anti-affinity in consideration (initial placement)
* An _SE_ is **deleted**
  * When explicitly requested by user (a user will not be allowed to delete aa _SE_ with _VSs_)
  * When the timeout _Delete Unused Service Engines After_ defined in the _SE group_ is reached, and no _VSs_ are placed in the _SE_ and if we still keep the number of _SEs_ over the defined capacity threshold
  
### Default settings of Active/Active vs H+M HA Modes

In the UI selecting the preferred _HA mode_ will set some default parameters of the _SE group_, once we select the _SE group_ _HA mode_ that setting cannot be changed without redoing the _SE group_.

* **Active/Active**
  * _**Min Scale per VS**_ $ = $ 2 (minimum is 2)
  * _**Distributed placement**_ strategy as default
  * _**Buffer**_ $ = $ 0
* **N+M**
  * _**Min Scale per VS**_ $ = $ 1
  * _**Compact placement**_ strategy as default
  * _**Buffer**_ $ = $ 1

## VS Placement Examples

We will use the same _SE group_ with the following configuration for our examples.

* _**Max #VS per SE**_ $ = $ 3
* _**Max #SEs**_ $ = $ 4

### Compact + Buffer $ = $ 0 + Min Scale per VS $ = $ 1

Lets see what happens when we try to place thirteen (13) _VSs_ in our _SE group_ considering our parameters. We will assume that the _VSs_ will be placed in sequence from _VS01_ to _VS13_.

 [![Example01]({{ relative_url }}/assets/images/posts/2023/03/avi-nsxalb-vs-placement-aa-nm-example01.jpg){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2023/03/avi-nsxalb-vs-placement-aa-nm-example01.jpg)

### Distributed + Buffer $ = $ 0 + Min Scale per VS $ = $ 1

Same as the previous example, lets try to place our _VSs_ now in a _SE group_ with a _Distributed_ policy instead of _Compact_.

 [![Example02]({{ relative_url }}/assets/images/posts/2023/03/avi-nsxalb-vs-placement-aa-nm-example02.jpg){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2023/03/avi-nsxalb-vs-placement-aa-nm-example02.jpg)

### Compact + Buffer $ = $ 1 + Min Scale per VS $ = $ 1

Now lets go back to _Compact_ but increasing the _Buffer_ to one (1).

 [![Example03]({{ relative_url }}/assets/images/posts/2023/03/avi-nsxalb-vs-placement-aa-nm-example03.jpg){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2023/03/avi-nsxalb-vs-placement-aa-nm-example03.jpg)

### Compact + Buffer $ = $ 2 + Min Scale per VS $ = $ 1

Now lets still go _Compact_ but increasing the _Buffer_ to two (2).

 [![Example04]({{ relative_url }}/assets/images/posts/2023/03/avi-nsxalb-vs-placement-aa-nm-example04.jpg){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2023/03/avi-nsxalb-vs-placement-aa-nm-example04 .jpg)

### Distributed + Buffer $ = $ 0 + Min Scale per VS $ = $ 2

Still using the same _SE Group_ base parameters, but now lets increase our _VS minimum scale_ to two (2) and use a _Distributed_ policy as per our _Active/Active_ config toggle.
From the get go we know that we will not be able to fit the thirteen (13) _VSs_ since for that we will need a capacity of $n = 13 \cdot 2 = 26 $, and we know that our maximum capacity is $ Max cap = 4 \cdot 3 = 12 $.

 [![Example05]({{ relative_url }}/assets/images/posts/2023/03/avi-nsxalb-vs-placement-aa-nm-example05.jpg){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2023/03/avi-nsxalb-vs-placement-aa-nm-example05.jpg)

### Distributed + Buffer $ = $ 1 + Min Scale per VS $ = $ 2

Just to exemplify cases where adding a _Buffer_ do not have a benefit, lets use a similar example as the one before _Distributed + Buffer $ = $ 0 + Min Scale per VS $ = $ 2_ but now with _Buffer_ bumped to one (1).

In this example the result will be pretty much the same since with the _Min Scale per VS_ $ = $ 2 and _Distributed_ policy, the _SEs_ will be deployed as soon as we try to place _VS02_.

 [![Example06]({{ relative_url }}/assets/images/posts/2023/03/avi-nsxalb-vs-placement-aa-nm-example06.jpg){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2023/03/avi-nsxalb-vs-placement-aa-nm-example06.jpg)

### Compact + Buffer $ = $ 1 + Min Scale per VS $ = $ 2

So lets now check what happens if we use a _Compact_ policy instead of _Distributed_ when we set the _Min scale per VS_ $ = $ 2.

 [![Example07]({{ relative_url }}/assets/images/posts/2023/03/avi-nsxalb-vs-placement-aa-nm-example07.jpg){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2023/03/avi-nsxalb-vs-placement-aa-nm-example07.jpg)

### Compact + Buffer $ = $ 2 + Min Scale per VS $ = $ 2

And to terminate the use cases lets bump the _Buffer_ to two (2).

 [![Example08]({{ relative_url }}/assets/images/posts/2023/03/avi-nsxalb-vs-placement-aa-nm-example08.jpg){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2023/03/avi-nsxalb-vs-placement-aa-nm-example08.jpg)
