---
ID: 194
post_title: 'PowerCLI &#8211; Using Get-EsxCli to get settings or change settings in multiple ESXi hosts at a time'
author: Ricardo Adao
post_excerpt: ""
layout: post
permalink: >
  https://vrandombites.co.uk/2018/05/coding/powercli/get-esxcli-get-change-settings-multiple-esxi-hosts/
published: true
post_date: 2018-05-15 08:11:14
---
Following the earlier post (<a href="https://vrandombites.co.uk/2018/05/coding/vmware-powercli/vmware-powercli-check-mtu-size-configured-all-hosts-physical-nics-cluster/">Checking MTU size</a>) lets see what more can we do with <em>Get-EsxCli</em> cmdlet.

<em>Get-EsxCli</em> is a way of using the <em>esxcli</em> command present in any ESXi shell, but from a Powershell shell.

<em>       Reference: <a href="https://code.vmware.com/docs/6702/cmdlet-reference#/doc/Get-EsxCli.html">PowerCLI Get-EsxCli</a></em>

Having that in mind lets use examples to show how we can leverage it to get, or set, some host configuration in multiple hosts connected to a vCenter using Powershell scripting.

Lets check what is available to us:

<a href="https://vrandombites.co.uk/wp-content/uploads/2018/05/getesxcli-list-commands-available.png"><img class="size-full wp-image-196 aligncenter" src="https://vrandombites.co.uk/wp-content/uploads/2018/05/getesxcli-list-commands-available.png" alt="" width="958" height="566" /></a>

Lets now compare what is available in <em>esxcli</em> via command line:

<a href="https://vrandombites.co.uk/wp-content/uploads/2018/05/esxcli-list-commands-available.png"><img class="aligncenter size-full wp-image-197" src="https://vrandombites.co.uk/wp-content/uploads/2018/05/esxcli-list-commands-available.png" alt="" width="978" height="442" /></a>

They are the same meaning that we will be able to use the <em>Get-EsxCli</em> to get any information that we would be able to get via the <em>esxcli</em> in the ESXi shell.

Lets compare side by side the differences of using the two:

<a href="https://vrandombites.co.uk/wp-content/uploads/2018/05/esxcli.getesxcli.sidebyside.png"><img class="aligncenter size-full wp-image-199" src="https://vrandombites.co.uk/wp-content/uploads/2018/05/esxcli.getesxcli.sidebyside.png" alt="" width="820" height="239" />
</a>

<em>            <strong>Note</strong>: as stated in the <a href="https://code.vmware.com/docs/6702/cmdlet-reference#/doc/Get-EsxCli.html">Get-EsxCli</a> reference the use of -v2 is advised, since it is the only way of guarantee compatibility across different ESXi versions</em>

Being the info the same we should be able to use <em>Get-EsxCli</em> cmdlet to get/set the same information in multiple hosts.

There is a difference in the "command syntax" as you can see in the pictures above, but it is pretty straight forward to understand that the "<em>command path</em>" is pretty much the same.

&nbsp;

So now how can we use the <em>Get-EsxCli</em> cmdlet to configure something the same way we would do it with <em>esxcli</em>.

Lets use the example above and change the "<em>Remote Host</em>" value:

<a href="https://vrandombites.co.uk/wp-content/uploads/2018/05/set.esxcli.getesxcli.sidebyside.png"><img class="aligncenter size-large wp-image-201" src="https://vrandombites.co.uk/wp-content/uploads/2018/05/set.esxcli.getesxcli.sidebyside-1024x615.png" alt="" width="640" height="384" /></a>

It becomes a bit more complicated however, it would be easier to create a simple oneliner Powershell script to get this change applied to an entire VMware cluster:

<a href="https://vrandombites.co.uk/wp-content/uploads/2018/05/set.esxcli.syslog.cluster.change.png"><img class="aligncenter wp-image-202 size-large" src="https://vrandombites.co.uk/wp-content/uploads/2018/05/set.esxcli.syslog.cluster.change-1024x856.png" alt="" width="640" height="535" /></a>

Summary of the commands used above:
<pre lang="powershell">Get-Cluster -Name "{cluster name}" | Get-VMHost | `
   %{ Write-Host $_.Name ; `
   (Get-Esxcli -v2 -VMHost $_).system.syslog.config.get.Invoke()}

Get-Cluster -Name "{cluster name}" | Get-VMHost | `
   %{ Write-Host $_.Name ; `
   (Get-Esxcli -v2 -VMHost $_).system.syslog.config.set.Invoke(@{loghost="{syslog IP/FQDN}"})}
</pre>