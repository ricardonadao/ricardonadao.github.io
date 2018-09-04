---
ID: 529
post_title: NSX Central CLI
author: Amine
post_excerpt: ""
layout: post
permalink: >
  https://vrandombites.co.uk/2018/07/nsx/nsx-central-cli/
published: true
post_date: 2018-07-28 18:27:48
---
Prior to Central CLI if an administrator wanted to gain details on constructs such as the NSX Edge Gateways (as well as the services running on them), Distributed Logical Routers, and Logical Switches, they would require console access to one or more of the following:

• NSX Manager
• NSX Controllers
• NSX Edge Gateways

You will be pleased to know that's no longer the case as you can now do all your monitoring and troubleshooting from one central point via Central CLI. However there is one thing to keep in mind. The commands executed via Central CLI are <strong>Read-only commands.</strong>

The <strong>new NSX Central CLI</strong> leverages existing communication channels (such as netcpa, vswfd, etc.) to retrieve <strong>operational data</strong> such as VTEP/MAC/ARP tables from the NSX Controllers, dynamic routing peer status, routing tables, distributed firewall vNIC rules and stats, edge status, and so on. Let's login to our NSX manager and have a look a few examples.

<strong>List all the commands available</strong>

<a href="https://vrandombites.co.uk/wp-content/uploads/2018/07/nsxcli1.png"><img class="alignnone wp-image-530 size-medium" src="https://vrandombites.co.uk/wp-content/uploads/2018/07/nsxcli1-279x300.png" alt="" width="279" height="300" /></a>

<strong>To List all your clusters</strong>

<a href="https://vrandombites.co.uk/wp-content/uploads/2018/07/nsxcli2.png"><img class="alignnone wp-image-531 size-medium" src="https://vrandombites.co.uk/wp-content/uploads/2018/07/nsxcli2-300x35.png" alt="" width="300" height="35" /></a>

• Cluster Name - The name of the vSphere cluster.
• Cluster ID - Unique identifier for vSphere cluster.
• Datacenter Name - Referring to the vSphere Datacenter for which the cluster
resides in.
• Firewall Status - Whether or not the Distributed Firewall can be utilized on Virtual
Machines in this cluster.

<strong>List hosts in a clusters</strong>

<a href="https://vrandombites.co.uk/wp-content/uploads/2018/07/nsxcli3.png"><img class="alignnone wp-image-532 size-medium" src="https://vrandombites.co.uk/wp-content/uploads/2018/07/nsxcli3-300x59.png" alt="" width="300" height="59" /></a>

• Host Name - The fully qualified domain name (FQDN) of the ESXi host in the
vSphere Cluster.
• Host ID - Unique identifier for the ESXi host.
• Installation Status - Whether or not the necessary network virtualization
components (ESXi VIBs for VXLAN, Distributed Firewall, and Logical Routers)

<strong>Review the health of a specific host</strong>

<a href="https://vrandombites.co.uk/wp-content/uploads/2018/07/nsxcli4.png"><img class="alignnone wp-image-533 size-medium" src="https://vrandombites.co.uk/wp-content/uploads/2018/07/nsxcli4-300x25.png" alt="" width="300" height="25" /></a>

I have changed the ip address of my gw hence the output showing an error. I will need to change it on my hosts at some point!

<strong>List VMs on a host
</strong>

<a href="https://vrandombites.co.uk/wp-content/uploads/2018/07/nsxcli6.png"><img class="alignnone wp-image-536 size-medium" src="https://vrandombites.co.uk/wp-content/uploads/2018/07/nsxcli6-300x42.png" alt="" width="300" height="42" /></a>

• VM Name - The name of the Virtual Machine as it's seen in the vSphere Client.
• VM ID - Unique identifier for the VM.
• Power Status - Whether or not the Virtual Machine is currently powered on.

<strong>List specific VM details
</strong>

<a href="https://vrandombites.co.uk/wp-content/uploads/2018/07/nsxcli5.png"><img class="alignnone wp-image-537 size-medium" src="https://vrandombites.co.uk/wp-content/uploads/2018/07/nsxcli5-300x101.png" alt="" width="300" height="101" /></a>

• Vnic Name - The name of the vNIC as seen on the VM.
• Vnic ID - Unique identifier for this specific vNIC object.
• Filters - This refers to the Distributed Firewall (DFW) Filter ID applied to the VM.

<strong>Specific vNIC Details</strong>

<a href="https://vrandombites.co.uk/wp-content/uploads/2018/07/nsxcli7.png"><img class="alignnone wp-image-538 size-medium" src="https://vrandombites.co.uk/wp-content/uploads/2018/07/nsxcli7-300x179.png" alt="" width="300" height="179" /></a>

• MAC Address - The MAC address of the vNIC on the VM.
• Port Group ID - Unique identifier for the distributed virtual switch portgroup.
• Filters - the unique identifier for the DFW filter.
• VXLAN - Information related to the VXLAN configuration such as ID, Multicast IP,
VTEPs etc.

<strong>List all Logical Switches</strong>

<a href="https://vrandombites.co.uk/wp-content/uploads/2018/07/nsxcli9.png"><img class="alignnone wp-image-539 size-medium" src="https://vrandombites.co.uk/wp-content/uploads/2018/07/nsxcli9-300x32.png" alt="" width="300" height="32" /></a>

• Name - The name of the logical switch.
• UUID - A unique identifier for the logical switch.
• VNI - The VXLAN Network Identifier that the logical switch sits on.
• Trans Zone Name - The name of the transport zone that the Logical Switch
resides in.
• Trans Zone ID - The unique identifier of the transport zone that the Logical Switch
resides in.

<strong>List Logical Switch Details On a Host Verbose
</strong>

<a href="https://vrandombites.co.uk/wp-content/uploads/2018/07/nsxcli10.png"><img class="alignnone wp-image-540 size-medium" src="https://vrandombites.co.uk/wp-content/uploads/2018/07/nsxcli10-277x300.png" alt="" width="277" height="300" /></a>

• Control Plane Sync Status and UDP Port Used for the Control Plane.
• Number of Logical Switches currently recognized by the host.
• Detail specific to a Logical Switch.
• VXLAN Network Identifier (VNI).
• Multicast IP (if the replication mode is set to be Multicast).
• NSX Controller which currently has the slice for the Logical Switch.
• Number of MAC and ARP Entry Counts.

<strong>Logical Switch Details On a Host - Statistics</strong>

<a href="https://vrandombites.co.uk/wp-content/uploads/2018/07/nsxcli11.png"><img class="alignnone size-thumbnail wp-image-541" src="https://vrandombites.co.uk/wp-content/uploads/2018/07/nsxcli11-150x150.png" alt="" width="150" height="150" /></a>

That's it. This is by no means a comprehensive list of the all the commands available but merely a taster of what you can do with the CLI. If you are interested in knowing more I strongler recommend the <a href="https://docs.vmware.com/en/VMware-NSX-for-vSphere/6.4/nsx_64_cli.pdf">command line interface reference guide</a> .

I hope this was useful. Please share.