---
author: Ricardo Adao
published: true
post_date: 2022-12-31 23:00:00
last_modified_at: 2023-01-08 23:00:00
header:
  teaser: /assets/images/featured/avi-150x150.png
title: Avi/NSX ALB - Setting up a Virtual Service with Backup Pools
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
slug: avi-nsx-alb-setting-virtual-service-backup-pools
lastmod: 2023-06-21T08:13:44.381Z
---
Setting up a _Virtual Service_ in a _Load Balancer_ is normally a simple task:

* We setup a _server pool_ with the servers running the application to be load balanced
* We setup a _virtual service_, and associate a _VIP_, to make the load balanced application available

## Simple Example

* Load Balancing an NTP service
  * Create _Virtual Service_ - _**ntp_lb**_
  * Create _Server Pool_ with our two (2) internal ntp servers - _**ntp_lb_internal_pool**_

  [![Load Balance NTP]({{ relative_url }}/assets/images/posts/2022/12/avi-vs-backup-pool-simple-setup.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2022/12/avi-vs-backup-pool-simple-setup.png)

## What if

What if ... we want to give our _Virtual Service_ the ability to use a _backup pool_ in case of the _primary server pool_ fails?

## Solution

One way of implementing this in _Avi/NSX ALB_ you can use the _pool groups_ functionality.

As an example we will setup a _NTP Load Balancer service_ that will use an internal pool as the primary pool and will fallback to public _NTP servers_ in case no internal _NTP_ server is available.

### Pool Groups

Quickly explained a _pool group_ in _Avi/NSX ALB_ is a _pool_ where the members of the _pool_ are another _pools_.

The idea will be to setup multiple _server pools_ to define different groups of _NTP servers_ and then assign different priorities that will be used in case of the members of an higher priority pool becomes unavailable.

[![Load Balance - Full Setup]({{ relative_url }}/assets/images/posts/2022/12/avi-vs-backup-pool-groups-setup.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2022/12/avi-vs-backup-pool-groups-setup.png)

### Creating Pools for Pool Groups

We setup two (2) pools:
 * **ntp-lb-internal-pool** - in this pool will use our _internal NTP servers_ as members
 * **ntp-lb-public-pool** - in this pool we will configure a couple of _public NTP servers_ as members

This is a simple configuration we create two (2) pools, in our example we setup an _internal pool_ with two (2) members and _public pool_ with sixteen (16) members.

[![Pools]({{ relative_url }}/assets/images/posts/2022/12/avi-vs-backup-pools-setup.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2022/12/avi-vs-backup-pools-setup.png)

### Creating Pool Group

We will add the two (2) pools with different priorities.

* _**Pools**_
  * _**NTP internal pool**_ - will have a priority of **100**
  [![Internal Pool]({{ relative_url }}/assets/images/posts/2022/12/avi-vs-backup-pool-group-internal-config.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2022/12/avi-vs-backup-pool-group-internal-config.png)

  * _**NTP public pool**_ - will have a priority of **50**
  [![Public Pool]({{ relative_url }}/assets/images/posts/2022/12/avi-vs-backup-pool-group-public-config.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2022/12/avi-vs-backup-pool-group-public-config.png)

* _**Pool Group**_
  * The _higher priority pools_ will be used, and ratios can be applied across pools with the same priority to distribute the load between the pools
  * If an _higher priority pool_ becomes unavailable the _pools_ in the next priority will be used, in our example, if all the members of the _NTP internal pool_ become unavailable then the _NTP public pool_ will be the made available
  * _**Pool group member**_ configuration
  [![Internal Pool - Pool Group Member Configuration]({{ relative_url }}/assets/images/posts/2022/12/avi-vs-backup-pool-group-internal-config.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2022/12/avi-vs-backup-pool-group-internal-config.png)
  [![Public Pool - Pool Group Configuration]({{ relative_url }}/assets/images/posts/2022/12/avi-vs-backup-pool-group-public-config.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2022/12/avi-vs-backup-pool-group-public-config.png)
  * _**Pool group**_ configuration
  [![Pool Group Configuration]({{ relative_url }}/assets/images/posts/2022/12/avi-vs-backup-pool-group-config.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2022/12/avi-vs-backup-pool-group-config.png)

## Now we should test it

Now that we have all the configuration, we should test it.

[![Pool Group - Final config]({{ relative_url }}/assets/images/posts/2022/12/avi-vs-backup-pool-group-final-config.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2022/12/avi-vs-backup-pool-group-final-config.png)

### All pools available
  [![All pools available]({{ relative_url }}/assets/images/posts/2022/12/avi-vs-backup-pools-all-pools-available.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2022/12/avi-vs-backup-pools-all-pools-available.png)
  
  Test a _NTP_ query to our _Virtual Service_
  * Test with _ntpdate_
  [![Test - _ntpdate_ test]({{ relative_url }}/assets/images/posts/2022/12/avi-vs-backup-pools-ntpdate-test.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2022/12/avi-vs-backup-pools-ntpdate-test.png)
  * _Virtual Service_ logs
  [![Test - VS log]({{ relative_url }}/assets/images/posts/2022/12/avi-vs-backup-pools-log-test.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2022/12/avi-vs-backup-pools-log-test.png)

### Fail _primary pool_
  [![Fail _primary pool_]({{ relative_url }}/assets/images/posts/2022/12/avi-vs-backup-pool-primary-pool-fail.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2022/12/avi-vs-backup-pool-primary-pool-fail.png)
  
  Test a _NTP_ query to our _Virtual Service_
  * Test with _ntpdate_
  [![Test - _ntpdate_ test]({{ relative_url }}/assets/images/posts/2022/12/avi-vs-backup-pools-ntpdate-test-failed-pool.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2022/12/avi-vs-backup-pools-ntpdate-test-failed-pool.png)
  * _Virtual Service_ logs
  [![Test - VS log]({{ relative_url }}/assets/images/posts/2022/12/avi-vs-backup-pools-log-test-failed-pool.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2022/12/avi-vs-backup-pools-log-test-failed-pool.png)

### All _Pools_ fail
  * All _pools_ down
  [![All _pools_ failed]({{ relative_url }}/assets/images/posts/2022/12/avi-vs-backup-pools-all-pools-failed.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2022/12/avi-vs-backup-pools-all-pools-failed.png)
  * With all _pools_ down the _Virtual Service_ will also be marked as down
  [![_VS_ down_]({{ relative_url }}/assets/images/posts/2022/12/avi-vs-backup-pools-vs-down.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2022/12/avi-vs-backup-pools-vs-down.png)

  
  Test a _NTP_ query to our _Virtual Service_
  * Test with _ntpdate_
  [![Test - _ntpdate_ test]({{ relative_url }}/assets/images/posts/2022/12/avi-vs-backup-pools-ntpdate-test-vs-fail.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2022/12/avi-vs-backup-pools-ntpdate-test-vs-fail.png)
  * _Virtual Service_ logs
  [![Test - VS log]({{ relative_url }}/assets/images/posts/2022/12/avi-vs-backup-pools-log-test-vs-down.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2022/12/avi-vs-backup-pools-log-test-vs-down.png)

## Conclusion

It seems that we were able to setup what we were aiming for, a _Virtual Service_ that  has a _backup pool_ in case of a failure of our main _pool_.

## References

* [AVI/NSX ALB - Pool Group Documentation](https://avinetworks.com/docs/latest/pool-groups/)
