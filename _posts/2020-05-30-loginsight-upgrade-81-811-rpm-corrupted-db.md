---
author: Ricardo Adao
published: true
post_date: 2020-05-30 08:00:00
header:
  teaser: /assets/images/featured/vmware-log-insight-150x150.png
title: VMware Log Insight - Upgrade from 8.1.0 to 8.1.1 and corrupted RPM db
categories:
  - loginsight
tags:
  - loginsight
  - vmware
  - homelab
  - upgrade
  - issue
  - vrli
toc: true
slug: vmware-log-insight-upgrade-8-1-0-8-1-1-corrupted-rpm-db
last_modified_at: 2023-07-04T15:22:37.801Z
---
The initial idea of this post was to do a quick walkthrough of the upgrade of _VMware Log Insight_ from 8.1.0 to 8.1.1, however the upgrade gone sideways and I ended up troubleshooting and fixing an issue with the _RPM db_ of the appliance.

After some digging, seems that the issue could happen in any of the _CentOS, RHEL, or SUSE based_ appliances, since it is related to the _RPM_ package management db **being corrupted**.

## Starting the Upgrade

The _VMware Log Insight_ upgrade process is pretty straight forward

* Login to the UI with a user with _Admin_ privileges
  [![Step 1]({{ relative_url }}/assets/images/posts/2020/05/loginsight-upgrade-810-811-step1.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2020/05/loginsight-upgrade-810-811-step1.png)
* Go to _Administration_ -> _Cluster_
  [![Step 2]({{ relative_url }}/assets/images/posts/2020/05/loginsight-upgrade-810-811-step2.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2020/05/loginsight-upgrade-810-811-step2.png)
* Click _Upgrade Cluster_
  [![Step 3]({{ relative_url }}/assets/images/posts/2020/05/loginsight-upgrade-810-811-step3.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2020/05/loginsight-upgrade-810-811-step3.png)
* Select the desired _.pak_ file and wait...
  [![Step 4]({{ relative_url }}/assets/images/posts/2020/05/loginsight-upgrade-810-811-step4.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2020/05/loginsight-upgrade-810-811-step4.png)

## _**OOOPPPPSSSS**_.... Something went wrong

[![OOpppps]({{ relative_url }}/assets/images/posts/2020/05/loginsight-upgrade-810-811-oopps.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2020/05/loginsight-upgrade-810-811-oopps.png)

Once the upgrade progress bar filled up completely and when I expected to be ready to start playing around with the new _VMware Log Insight_ version, I was awarded with this error.

The error is pretty descriptive and potentially a bit overwhelming to some extent. However, when we start looking into it there are some hints giving some direction on the troubleshoot.

```text
Failed to upgrade: Failed to read installed version: error: rpmdb: BDB0113 Thread/process 4858/139939578443968 failed: BDB1507 Thread died in Berkeley DB library error: db5 error(-30973) from dbenv->failchk: BDB0087 DB_RUNRECOVERY: Fatal error, run database recovery error: cannot open Packages index using db5 - (-30973) error: cannot open Packages database in /var/lib/rpm error: rpmdb: BDB0113 Thread/process 4858/139939578443968 failed: BDB1507 Thread died in Berkeley DB library error: db5 error(-30973) from dbenv->failchk: BDB0087 DB_RUNRECOVERY: Fatal error, run database recovery error: cannot open Packages index using db5 - (-30973) error: cannot open Packages database in /var/lib/rpm
```

The error information seems to be pointing out to an issue/corruption with the _RPM database_ that it is stopping the upgrade to finish successfully.

I did not dig into the real reason why this got to this state, however I cannot say that is the most _Production Ready_ environment. But lets fix it since the plan is to upgrade the _VMware Log Insight_ 8.1.0 from 8.1.1.

## Solution

So we need to recover the _RPM database_ using the following steps.

1. Taking a snapshot of the VM just to have a _quick rollback_ if needed
1. First lets login to the _VMware Log Insight_  console using the _root_ user

   [![Login]({{ relative_url }}/assets/images/posts/2020/05/loginsight-upgrade-810-811-db-step1.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2020/05/loginsight-upgrade-810-811-db-step1.png)

1. Making a backup of _/var/lib/rpm_ files, before we start

   ```shell
mkdir /var/lib/rpm/backup
cp -a /var/lib/rpm/__db.* /var/lib/rpm/backup/
```

   [![Backup RPM DB]({{ relative_url }}/assets/images/posts/2020/05/loginsight-upgrade-810-811-db-step2.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2020/05/loginsight-upgrade-810-811-db-step2.png)

1. Remove the existing database files to avoid stale locks

   ```shell
rm -f /var/lib/rpm/__db.*
rpm --quiet -qa
```
   [![Remove old RPM DB]({{ relative_url }}/assets/images/posts/2020/05/loginsight-upgrade-810-811-db-step3.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2020/05/loginsight-upgrade-810-811-db-step3.png)

   [![Rebuild RPM DB]({{ relative_url }}/assets/images/posts/2020/05/loginsight-upgrade-810-811-db-step4.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2020/05/loginsight-upgrade-810-811-db-step4.png)

1. Rebuild the RPM database

   ```shell
rpm --rebuilddb
yum clean all
```

   [![Rebuild RPM DB]({{ relative_url }}/assets/images/posts/2020/05/loginsight-upgrade-810-811-db-step5.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2020/05/loginsight-upgrade-810-811-db-step5.png)

   [![yum clean all]({{ relative_url }}/assets/images/posts/2020/05/loginsight-upgrade-810-811-db-step6.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2020/05/loginsight-upgrade-810-811-db-step6.png)

And we are ready to try to upgrade our _VMware Log Insight_ again.

## Upgrade - TAKE 2

* We go back to _VMware Log Insight_ UI.

  [![Upgrade TAKE 2 - Step 1]({{ relative_url }}/assets/images/posts/2020/05/loginsight-upgrade-810-811-take2-step1.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2020/05/loginsight-upgrade-810-811-take2-step1.png)

* And we wait...

  [![Upgrade TAKE 2 - Step 2]({{ relative_url }}/assets/images/posts/2020/05/loginsight-upgrade-810-811-take2-step2.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2020/05/loginsight-upgrade-810-811-take2-step2.png)

* Wait... this looks better now...

  [![Upgrade TAKE 2 - Step 3]({{ relative_url }}/assets/images/posts/2020/05/loginsight-upgrade-810-811-take2-step3.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2020/05/loginsight-upgrade-810-811-take2-step3.png)

* We click _Accept_ after going through the _EULA_, and we kick off the upgrade process

  [![Upgrade TAKE 2 - Step 4]({{ relative_url }}/assets/images/posts/2020/05/loginsight-upgrade-810-811-take2-step4.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2020/05/loginsight-upgrade-810-811-take2-step4.png)

* And after waiting for a while the upgrade is successfully done

  [![Upgrade TAKE 2 - Success]({{ relative_url }}/assets/images/posts/2020/05/loginsight-upgrade-810-811-take2-upgrade-success.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2020/05/loginsight-upgrade-810-811-take2-upgrade-success.png)

  To tidy up, we can get rid of the VM Snapshot that was done before we started and the backup folder that we made.


## Conclusion

In this case, we are just upgrading a single node _VMware Log Insight_, however I suspect that would be a similar process for a clustered deployment, with the same steps in each of the nodes, since the upgrade process of a cluster will upgrade all the nodes.

While searching for a solution I found a similar issue documented for _VMware AppDefense_ appliances and some of steps, or probably all, were taken from it, so the issue seems to affect potentially any of the appliances with a CentOS, RHEL, or SUSE platform.
