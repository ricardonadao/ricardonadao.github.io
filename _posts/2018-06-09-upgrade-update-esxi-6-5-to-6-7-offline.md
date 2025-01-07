---
author: Ricardo Adao
published: true
date: 2018-06-09 11:59:58

header:
  teaser: /assets/images/featured/vsphere-150x150.png
title: Upgrade/Update ESXi 6.5 to 6.7 Offline
categories:
  - esxi
tags:
  - esxi
  - hypervisor
  - vmware
  - vsphere
  - update
  - upgrade
toc: true
slug: upgrade-update-esxi-6-5-6-7-offline
last_modified_at: 2025-01-07 12:23:00
---
In our _Homelabs_, we normally make some "architecture compromises" that add some extra complexity when we need to upgrade it.

And in my particular case, was starting with a "single host" with enough resources to run a couple of _Nested Environments_, there are plans  to add one or two more hosts, but for now has been enough for the current use.

Running everything from a single host creates some challenges when is time for BIOS/Firmware updates and ESXi upgrade/update.

# Let's go through the process to upgrade an ESXi hypervisor offline #

Remember your mileage may vary in some of the parts, but the process should work for more than _ESXi 6.5_ to _ESXi 6.7_ upgrade
{: .notice}

1. **Download the offline bundle and upload to a local datastore**

1. **Will not describing the download process and upload, since there are different ways to achieve this**

[![ESXi Upgrade - Offline patch]({{ relative_url }}/assets/images/posts/2018/06/esxi-upgrade-offlinePatch.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2018/06/esxi-upgrade-offlinePatch.png)

{:start="3"}

1. **Shutdown all your VMs**

1. **Do a dry run just to make sure**

```shellscript
esxcli software profile update
   -d /vmfs/volumes/<local>/VMware-ESXi-6.7.0-8169922-depot.zip
   -p ESXi-6.7.0-8169922-standard --dry-run
```

[![ESXi Upgrade - dryrun]({{ relative_url }}/assets/images/posts/2018/06/esxi-upgrade-dryrun.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2018/06/esxi-upgrade-dryrun.png)

{:start="5"}

1. **This _dry-run_ will give us a list of what will be applied and installed**

1. **Enter _Maintenance Mode_**

```shellscript
esxcli system maintenanceMode get
esxcli system maintenanceMode set --enable=true
esxcli system maintenanceMode get
```

[![ESXi Upgrade - Enter Maintenance Mode]({{ relative_url }}/assets/images/posts/2018/06/esxi-upgrade-enterMaintenanceMode.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2018/06/esxi-upgrade-enterMaintenanceMode.png)

{:start="7"}

1. **And we are ready for the upgrade**

   1. Lets kick off the upgrade

```shellscript
esxcli software profile update
  -d /vmfs/volumes/<local>/VMware-ESXi-6.7.0-8169922-depot.zip
  -p ESXi-6.7.0-8169922-standard --dry-run
```

[![ESXi Upgrade - Start]({{ relative_url }}/assets/images/posts/2018/06/esxi-upgrade-start.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2018/06/esxi-upgrade-start.png)

{:start="2"}

   1. The command is not too verbose, but we can open a 2nd SSH session and tail the _esxupdate.log_ file

[![ESXi Upgrade tail esxupdate]({{ relative_url }}/assets/images/posts/2018/06/esxi-upgrade-tail-esxupdate.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2018/06/esxi-upgrade-tail-esxupdate.png)

{:start="3"}

   1. Will give you a quick report, similar to the _dry-run_, but now with the actual changes

[![ESXi Upgrade - Finished]({{ relative_url }}/assets/images/posts/2018/06/esxi-upgrade-finished.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2018/06/esxi-upgrade-finished.png)

{:start="8"}

1. **Reboot**

   * Now, we need to reboot the host to get the upgrade finished

   [![ESXi Upgrade - Reboot]({{ relative_url }}/assets/images/posts/2018/06/esxi-upgrade-reboot.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2018/06/esxi-upgrade-reboot.png)

{:start="9"}

1. **Take out of _Maintenance Mode_**

   * Let's remove it from _Maintenance Mode_

[![ESXi Upgrade - ESXi FirstBoot]({{ relative_url }}/assets/images/posts/2018/06/esxi-upgrade-firstBoot.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2018/06/esxi-upgrade-firstBoot.png)

```shellscript
esxcli system maintenanceMode get
esxcli system maintenanceMode set --enable=false
esxcli system maintenanceMode get
```

[![ESXi Upgrade - Exit Maintenance Mode]({{ relative_url }}/assets/images/posts/2018/06/esxi-upgrade-exitMaintenanceMode.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2018/06/esxi-upgrade-exitMaintenanceMode.png)

{:start="10"}

1. **All done** and a final picture with our Upgraded/Updated ESXi

[![ESXi Upgrade - ESXi Upgraded screenshot]({{ relative_url }}/assets/images/posts/2018/06/esxi-upgrade-UpdatedESXi.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2018/06/esxi-upgrade-UpdatedESXi.png)