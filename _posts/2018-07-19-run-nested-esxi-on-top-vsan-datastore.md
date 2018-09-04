---
ID: 483
post_title: >
  Run Nested ESXi on top of a vSAN
  datastore
author: Ricardo Adao
post_excerpt: ""
layout: post
permalink: >
  https://vrandombites.co.uk/2018/07/vsan/run-nested-esxi-on-top-vsan-datastore/
published: true
post_date: 2018-07-19 18:20:14
---
Nested ESXi's are part of the gear that we all have around for labs/study purposes.

At this time stumbled in an error that was a bit a surprise, however in your troubleshooting process you end up checking logs and then going to your blogs of reference searching for answers.

And for me, <a href="https://www.virtuallyghetto.com">virtuallyGhetto</a> comes as one of the first places to look for answers for Nested Virtualization issues.

Link to the original post <a href="https://www.virtuallyghetto.com/2013/11/how-to-run-nested-esxi-on-top-of-vsan.html"><em>How to run Nested ESXi on top of a VSAN datastore?</em></a> from <a href="https://www.virtuallyghetto.com/author/lamw">William Lam</a>.

Back to the problem and solution.

Installing some ESXi 6.5 Nested Hypervisors that are running on top of a vSAN datastore, the installation process was bombing out complaining that it was unable to format the disks.

<a href="https://vrandombites.co.uk/wp-content/uploads/2018/07/nested-hyp-vsan-problem.png"><img class="alignnone size-full wp-image-486" src="https://vrandombites.co.uk/wp-content/uploads/2018/07/nested-hyp-vsan-problem.png" alt="" width="561" height="477" /></a>

After the search we got the answer from <a href="https://www.virtuallyghetto.com/author/lamw">William Lam</a> in <a href="https://www.virtuallyghetto.com/2013/11/how-to-run-nested-esxi-on-top-of-vsan.html"><em>How to run Nested ESXi on top of a VSAN datastore?</em></a>

In summary, vSAN do not support <em>SCSI-2 Reservations</em> and since <em>VMware</em> internal development teams use heavily <em>Nested Virtualization</em> the <em>vSAN</em> team added a "workaround" to allow vSAN to <em>fake SCSI Reservations</em>.

This workaround is enabled by setting up an advanced property in each ESXi part of the vSAN cluster:
<pre lang="shellscript">esxcli system settings advanced set -o /VSAN/FakeSCSIReservations -i 1</pre>
Now that we have the answer and we have a couple of ESXi to setup this up, lets powershell it to make it quicker.

To check the current status:
<pre lang="powershell">get-cluster -Name "{cluster name}" | Get-VMHost | `
  Sort-Object Name | `
  Select-Object Name, @{N="FakeSCSIResevations"; E={$_ | Get-AdvancedSetting -Name "VSAN.FakeSCSIReservations"}} | `
  Format-Table -AutoSize</pre>

To set it up:
<pre lang="powershell">get-cluster -Name "{cluster name}" | Get-VMHost | `
  Get-AdvancedSetting -Name "VSAN.FakeSCSIReservations" | `
  Set-AdvancedSetting -Value 1</pre>