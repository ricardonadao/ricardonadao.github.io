---
author: Ricardo Adao
published: true
date: 2020-03-18 20:00:00
header:
  teaser: /assets/images/featured/vsphere-150x150.png
title: VMware vCenter - Setting up vCenter Appliance SNMP monitoring
categories:
  - vcenter
tags:
  - vcenter
  - appliance
  - vsphere
  - monitoring
  - homelab
  - vmware
toc: true
slug: vmware-vcenter-setting-vcenter-appliance-snmp-monitoring
last_modified_at: 2025-01-07 12:23:00
---
I started to run a _[Cacti](https://www.cacti.net/) server_ in my _Homelab_ just for fun and to have an overview of some key metrics of the virtual machines, servers, switches, storage and any other _SNMP capable_ piece of kit at home.

However, over the years made me learning some things whenever some special configuration was needed or some more when you would need create your own data collectors and dependencies.

So at the moment it is monitoring 35 devices.

But let's get back to the topic of the post.

# Setting up _SNMP_ monitoring in _VMware vCenter Appliance_

## Connect via SSH to _vCenter_

The configuration will be done through the _vCenter Appliance Shell_.

To get to the shell you will need to SSH to the _vCenter Appliance_, to be able to run a couple of _shell commands_.

[![Connect to vCenter via SSH]({{ relative_url }}/assets/images/posts/2020/03/vcenter-snmp-setup-connect-ssh.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2020/03/vcenter-snmp-setup-connect-ssh.png)

> In case you login directly to _BASH_ shell you can re-activate the _Appliance shell_ again with the following
> ```shellscript
chsh -s /bin/appliancesh root
> ```
> More detailed info in _[KB 2100508 - Toggling the vCenter Server Appliance 6.x default shell](https://kb.vmware.com/s/article/2100508)_
> {:.notice--info}

## Check the initial state

You can check the vCenter SNMP initial configuration using `snmp.get` command on the _Appliance Shell_

[![Check vCenter SNMP initial config]({{ relative_url }}/assets/images/posts/2020/03/vcenter-snmp-setup-snmp-get.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2020/03/vcenter-snmp-setup-snmp-get.png)

## Setting it up

We will setup a basic configuration to be able to use _SNMP v2_ and a _community string_.
The shell commands to use will be:

* Setup SNMP v2 community string

  ```shellscript
  snmp.set --communities <community string>
  ```

* Setup contact info

  ```shellscript
  snmp.set --syscontact <user contact>
  ```

* Setup a location name/id

  ```shellscript
  snmp.set --syslocation <location name/id>
  ```

  [![Setup vCenter SNMP]({{ relative_url }}/assets/images/posts/2020/03/vcenter-snmp-setup-snmp-setup.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2020/03/vcenter-snmp-setup-snmp-setup.png)

## Last step - Enabling it

To enable it we need to run `snmp.enable` in the _Appliance shell_.

[![Enable vCenter SNMP service]({{ relative_url }}/assets/images/posts/2020/03/vcenter-snmp-setup-snmp-enable.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2020/03/vcenter-snmp-setup-snmp-enable.png)

## Checking if our setup works

Testing with a _snmpwalk_ command line utility.

[![SNMP walk test]({{ relative_url }}/assets/images/posts/2020/03/vcenter-snmp-setup-snmpwalk-check.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2020/03/vcenter-snmp-setup-snmpwalk-check.png)

Checking our _[Cacti](https://www.cacti.net/) server_ 

[![Cacti Check - CPU]({{ relative_url }}/assets/images/posts/2020/03/vcenter-snmp-setup-cacti-cpu.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2020/03/vcenter-snmp-setup-cacti-cpu.png)

[![Cacti Check - Ethernet and Used Space]({{ relative_url }}/assets/images/posts/2020/03/vcenter-snmp-setup-cacti-ethernet-used-space.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2020/03/vcenter-snmp-setup-cacti-ethernet-used-space.png)

It seems that all is **good to go** and my _[Cacti](https://www.cacti.net/) server_ is now showing some pretty graphs.