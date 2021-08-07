---
author: Ricardo Adao
published: true
post_date: 2018-06-03 10:42:02
last_modified_at:
header:
  teaser: /assets/images/featured/esxi-150x150.png
title: Filtering/Excluding log entries in VMware vSphere ESXi
categories: [ esxi ]
tags: [ esxi, hypervisor, vmware, vsphere, syslog ]
toc: true
---
In our Homelabs, or even in production environments, we always have some harmless log entries that we would be happy to stop them from filling up our logs.

**Caution:** Reducing/suppressing/filtering log entries on an ESXi could introduce some "blind spots" or even hide issues when troubleshooting
{: .notice--warning}

In ESXi 6.x, VMware introduced the ability to filter or exclude log entries from the system logs using _regular expressions_ ([_Filtering logs in VMware vSphere ESXi (2118562)_](https://kb.vmware.com/kb/2118562)).

# To use log filtering we need to enable it first #

* Log in to the ESXi via SSH or console, using a user with _root_ privileges.

* We will change _/etc/vmsyslog.conf_ so lets back it up

```shell
cp /etc/vmsyslog.conf /etc/vmsyslog.orig
```

* Now we can edit the file, since we back it up

```shell
vi /etc/vmsyslog.conf

Add the config:
   enable_logfilters = true
```

[![Backup vmsyslog.conf]({{ relative_url }}/assets/images/posts/2018/06/filtering-excluding-backup-vmsyslog.edited.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2018/06/filtering-excluding-backup-vmsyslog.edited.png)

# Get the _filters_ configured #

* The _filters_ are setup in _/etc/vmware/logfilters_ and there is a specific syntax

```shell
numLogs | ident | logRegexp
```

* _**Parameters**_
  * _numLogs_ - how many times the log entry can appear before being filtered (_setting 0 will filter all_)
  * _ident_ - used to identity the source of the log entry. The available sources will be found under _/etc/vmsyslog.conf.d/*.conf_
  * _logRegexp_ - it will be the regular expression (_Python regexp syntax_) that will match the log entries to filter

* Configuring some filters in _/etc/vmware/logfilters_ as an example:

```shell
vi /etc/vmware/logfilters
```

* Filtering some _harmless SCSI log entries_ result of local storage rescanning

```python
0 | vmkernel | 0x1a.* H:0x0 D:0x2 P:0x0 Valid sense data: 0x5 0x2[04] 0x0
0 | vmkernel | 0x85.* H:0x0 D:0x2 P:0x0 Valid sense data: 0x5 0x20 0x0
0 | vmkernel | 0x12.* H:0x0 D:0x2 P:0x0 Valid sense data: 0x5 0x24 0x0
0 | vmkernel | 0x9e.* H:0x0 D:0x2 P:0x0 Valid sense data: 0x5 0x20 0x0
0 | vmkernel | bad CDB .* scsi_op=0x9e
0 | vmkernel | 0x4d.* H:0x0 D:0x2 P:0x0 Valid sense data: 0x5 0x20 0x0</pre>
```

* _To check SCSI Codes_:
  * [_Understanding SCSI Check Conditions in VMkernel logs during rescan operations (1010244)_](https://kb.vmware.com/kb/1010244)
  * [_Interpreting SCSI sense codes in VMware ESXi and ESX (289902)_](https://kb.vmware.com/kb/289902)

* Filters configured
  [![vmsyslog.conf example]({{ relative_url }}/assets/images/posts/2018/06/filtering-excluding-vmsyslog-logfilters-example.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2018/06/filtering-excluding-vmsyslog-logfilters-example.png)

# Reloading _syslog_ to activate our filters #

```shell
esxcli system syslog reload
```

# Lets check the result #

* Before we can see a consistent log entry every ~10/15 minutes

[![Before Setting up the filters]({{ relative_url }}/assets/images/posts/2018/06/filtering-excluding-before.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2018/06/filtering-excluding-before.png)

* Reloading syslog config and a timestamp to use as a reference

[![Syslog Service reload]({{ relative_url }}/assets/images/posts/2018/06/filtering-excluding-test-reload.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2018/06/filtering-excluding-test-reload.png)

* After ~30 minutes, we would have some log entries, let see if they got filtered

[![After setting up filters]({{ relative_url }}/assets/images/posts/2018/06/filtering-excluding-after.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2018/06/filtering-excluding-after.png)

* <span style="color: #008000;">**OK no log entries**</span>, but did anything else got logged during that period, lets grep for that period removing the entry logs that we want to filter and count the _newlines

[![Count log entries logged during testing period]({{ relative_url }}/assets/images/posts/2018/06/filtering-excluding-after-logcount-notfiltered.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2018/06/filtering-excluding-after-logcount-notfiltered.png)

## **Syslog** logged 129 new log lines after we activated the filtering ##  

**Caution:** Reducing/suppressing/filtering log entries on an ESXi could introduce some "blind spots" or even hide issues when troubleshooting
{: .notice--warning}