---
layout: post
author: Ricardo Adao
published: true
post_date: 2018-06-03 10:42:02
title: Filtering/Excluding log entries in VMware vSphere ESXi
categories: [ esxi ]
tags: [ esxi, hypervisor, vmware, vsphere ]
---
In our Homelabs, or even in production environments, we always have some harmless log entries that we would be happy to stop them from filling up our logs.

>**Caution:** Reducing/suppressing/filtering log entries on an ESXi could introduce some "blind spots" or even hide issues when troubleshooting.

In ESXi 6.x, VMware introduced the ability to filter or exclude log entries from the system logs using _regular expressions_ ([Original KB 2118562](https://kb.vmware.com/kb/2118562)).

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

![Backup vmsyslog.conf](/assets/images/posts/2018/06/filtering-excluding-backup-vmsyslog.edited.png)

# And now we need to configure the _filters_ #

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

![vmsyslog.conf example](/assets/images/posts/2018/06/filtering-excluding-vmsyslog-logfilters-example.png)


<li>Filtering some <em>harmless SCSI log entries </em>result of local storage rescanning:
<pre lang="python">0 | vmkernel | 0x1a.* H:0x0 D:0x2 P:0x0 Valid sense data: 0x5 0x2[04] 0x0
0 | vmkernel | 0x85.* H:0x0 D:0x2 P:0x0 Valid sense data: 0x5 0x20 0x0
0 | vmkernel | 0x12.* H:0x0 D:0x2 P:0x0 Valid sense data: 0x5 0x24 0x0
0 | vmkernel | 0x9e.* H:0x0 D:0x2 P:0x0 Valid sense data: 0x5 0x20 0x0
0 | vmkernel | bad CDB .* scsi_op=0x9e
0 | vmkernel | 0x4d.* H:0x0 D:0x2 P:0x0 Valid sense data: 0x5 0x20 0x0</pre>
<ul>
<li><em>To check SCSI Codes: <a href="https://kb.vmware.com/kb/1010244">Understanding SCSI Check Conditions in VMkernel logs during rescan operations (1010244)</a> and <a href="https://kb.vmware.com/kb/289902">Interpreting SCSI sense codes in VMware ESXi and ESX (289902)</a></em></li>
</ul>
</li>
<li>Filters configured<br />
<a href="https://vrandombites.co.uk/wp-content/uploads/2018/06/filtering-excluding-vmsyslog-logfilters-example.png"><img class="size-full wp-image-344 alignnone" src="{{ site.baseurl }}/assets/filtering-excluding-vmsyslog-logfilters-example.png" alt="" width="558" height="457" /></a></li>
</ul>
</li>
</ol>
</li>
</ol>

<h3>Reloading <em>syslog service</em> configuration to activate our filters</h3>

<ol>
<li>

```shell
esxcli system syslog reload
```

</li>
</ol>

<h3>And lets check the result</h3>
<ol>
<li>Before we can see a consistent log entry every ~10/15 minutes<br />
<a href="https://vrandombites.co.uk/wp-content/uploads/2018/06/filtering-excluding-before.png"><img class="alignnone size-full wp-image-360" src="{{ site.baseurl }}/assets/filtering-excluding-before.png" alt="" width="1641" height="184" /></a></li>
<li>Reloading syslog config and a timestamp to use as a reference<br />
<a href="https://vrandombites.co.uk/wp-content/uploads/2018/06/filtering-excluding-test-reload.png"><img class="alignnone size-full wp-image-362" src="{{ site.baseurl }}/assets/filtering-excluding-test-reload.png" alt="" width="370" height="49" /></a></li>
<li>After ~30 minutes, we would have some log entries, let see if they got filtered:<br />
<a href="https://vrandombites.co.uk/wp-content/uploads/2018/06/filtering-excluding-after-corrected.png"><img class="alignnone size-full wp-image-369" src="{{ site.baseurl }}/assets/filtering-excluding-after-corrected.png" alt="" width="1639" height="195" /></a></li>
<li><span style="color: #008000;"><strong>OK </strong></span> so no log entries, but did anything else got logged during that period, lets grep for that period removing the entry logs that we want to filter and count the <em>newlines:</em><br />
<a href="https://vrandombites.co.uk/wp-content/uploads/2018/06/filtering-excluding-after-logcount-notfiltered-corrected.png"><img class="alignnone wp-image-372 size-full" src="{{ site.baseurl }}/assets/filtering-excluding-after-logcount-notfiltered-corrected.png" alt="" width="1052" height="77" /></a></li>
<li><strong>Syslog logged 129 new log lines after we activated the filtering<br />
</strong></li>
</ol>
<blockquote><p><strong>Caution:</strong> Reducing/suppressing/filtering log entries on an ESXi could introduce some "blind spots" or even hide issues when troubleshooting</p></blockquote>
