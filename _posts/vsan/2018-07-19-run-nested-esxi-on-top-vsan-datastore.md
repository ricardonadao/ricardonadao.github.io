---
layout: post
author: Ricardo Adao
published: true
post_date: 2018-07-19 18:20:14
title: Run Nested ESXi on top of a vSAN datastore
categories: [ vsan ]
tags: [ coding, hypervisor, esxi, powercli, powershell, vcenter, vmware, vsan, nested, oneliner, scsi ]
comments: true
---
Nested ESXi's are part of the gear that we all have around for labs/study purposes.

At this time stumbled in an error that was a bit a surprise, however in your troubleshooting process you end up checking logs and then going to your blogs of 
reference searching for answers.

And for me, _[virtuallyGhetto](https://www.virtuallyghetto.com)_ comes as one of the first places to look for answers for _Nested Virtualization_ issues.
Link to the original post _[How to run Nested ESXi on top of a VSAN datastore?](https://www.virtuallyghetto.com/2013/11/how-to-run-nested-esxi-on-top-of-vsan.html)_ from _[William Lam](https://www.virtuallyghetto.com/author/lamw)_.

Back to the problem and solution.

Installing some ESXi 6.5 Nested Hypervisors that are running on top of a vSAN datastore, the installation process was bombing out complaining that it was unable to format the disks.

[![Nested Hypervisor VSAN problem](/assets/images/posts/2018/07/nested-hyp-vsan-problem.png){:class="img-responsive"}](/assets/images/posts/2018/07/nested-hyp-vsan-problem.png)

In summary, vSAN do not support _SCSI-2 Reservations_ and since _VMware_ internal development teams use heavily _Nested Virtualization_ the _vSAN_ team added a "workaround" to allow vSAN to _fake SCSI Reservations_.
This workaround is enabled by setting up an advanced property in each ESXi part of the vSAN cluster:

```bash
esxcli system settings advanced set -o /VSAN/FakeSCSIReservations -i 1
```

Now that we have the answer and we have a couple of ESXi to setup this up, lets powershell it to make it quicker.

To check the current status:

```powershell
get-cluster -Name "{cluster name}" | Get-VMHost | `
  Sort-Object Name | `
  Select-Object Name, `
    @{N="FakeSCSIResevations"; `
      E={$_ | Get-AdvancedSetting -Name "VSAN.FakeSCSIReservations"}} | `
  Format-Table -AutoSize
```

To set it up:

```powershell
get-cluster -Name "{cluster name}" | Get-VMHost | `
  Get-AdvancedSetting -Name "VSAN.FakeSCSIReservations" | `
  Set-AdvancedSetting -Value 1
```