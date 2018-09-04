---
ID: 57
post_title: VM encryption in vSphere 6.5
author: Amine
post_excerpt: ""
layout: post
permalink: >
  https://vrandombites.co.uk/2018/03/vsphere/vm-encryption/
published: true
post_date: 2018-03-31 20:21:14
---
One of the major new features that vSphere 6.5 introduces is VM encryption both at rest and in transit. The encryption is VM agnostic, easy to implement and to manage. Let’s have a look at few benefits it brings:
<ul>
 	<li>Encryption is done at the hypervisor level therefore works with any guest OS and any storage and no special configuration needed.</li>
 	<li>Encryption is managed via policy, leveraging the existing SPBM framework.</li>
 	<li>Encryption is based on the KMIP protocol, allowing choice and flexibility.</li>
</ul>
<strong>How does VM encryption works</strong>
<ul>
 	<li>User assigns VM Encryption policy at the virtual machine level.</li>
 	<li>For the VM, a random key is generated and encrypted with a key from the key manager (KMS key).</li>
 	<li>When VM is switched on, vCenter server receives the key from the Key Manager and sends it to VM encryption Module on ESXi server, which unlocks the key in the hypervisor.</li>
 	<li>Next, all I/O operations are carried out through encryption module, encrypting all input and output SCSI-commands transparently for guest OS.</li>
</ul>
<strong>Caveats</strong>

The following options are not supported:
<ul>
 	<li>Suspend/resume</li>
 	<li>VM encryption with snapshots and creation of snapshots for encrypted VMs</li>
 	<li>Serial/Parallel port</li>
 	<li>Content library</li>
 	<li>vSphere Replication</li>
</ul>
&nbsp;

&nbsp;

&nbsp;