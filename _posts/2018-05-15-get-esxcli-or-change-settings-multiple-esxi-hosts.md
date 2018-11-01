---

author: Ricardo Adao
published: true
post_date: 2018-05-15 08:11:14
title: PowerCLI - Using Get-EsxCli to get settings or change settings in multiple ESXi hosts at a time
categories: [ powercli ]
tags: [ coding, esxi, hypervisor, oneliner, powercli, powershell, vmware ]
---

Following the earlier post [_PowerCLI - Check MTU size configured in all hosts physical nics of a cluster_]({% post_url 2018-05-13-powercli-check-mtu-size-configured-all-hosts-physical-nics-cluster %}) lets see what more can we do with _Get-EsxCli_ cmdlet.

_Get-EsxCli_ is a cmdlet to run the _esxcli_ command present in any ESXi shell, but from a _Powershell_ shell.  
    _Reference_: [_Get-EsxCli_](https://code.vmware.com/docs/6702/cmdlet-reference#/doc/Get-EsxCli.html)

Having that in mind lets use examples to show how we can leverage it to get, or set, some host configuration in multiple hosts connected to a vCenter using Powershell scripting.

Lets check what is available to us:
[![Get-EsxCli list Available commands]({{ site.url }}/assets/images/posts/2018/05/getesxcli-list-commands-available.png){:class="img-responsive"}]({{ site.url }}/assets/images/posts/2018/05/getesxcli-list-commands-available.png)

Lets now compare what is available in _esxcli_ via command line:
[![Get-EsxCli list Available commands]({{ site.url }}/assets/images/posts/2018/05/esxcli-list-commands-available.png){:class="img-responsive"}]({{ site.url }}/assets/images/posts/2018/05/esxcli-list-commands-available.png)

They are similar which will allow us to use the _Get-EsxCli_ to get any information that we would be able to get via the _esxcli_ in the ESXi shell.

Lets compare side by side the differences of using the two:
[![Esxcli Get-EsxCli side by side]({{ site.url }}/assets/images/posts/2018/05/esxcli.getesxcli.sidebyside.png){:class="img-responsive"}]({{ site.url }}/assets/images/posts/2018/05/esxcli.getesxcli.sidebyside.png)

  **Note**: as stated in the [_Get-EsxCli_](https://code.vmware.com/docs/6702/cmdlet-reference#/doc/Get-EsxCli.html) reference the use of -v2 is advised, since it is the only way of guarantee compatibility across different ESXi versions.  
  Being the info the same we should be able to use _Get-EsxCli_ cmdlet to get/set the same information in multiple hosts.  
  There is a difference in the _syntax_ as you can double check in the pictures above, but it is pretty straight forward to understand that the _command tree_ is pretty much the same.

So now how can we use the _Get-EsxCli_ cmdlet to configure something the same way we would do it with _esxcli_.

Lets use the example above and change the _"Remote Host"_ value:
[![Set Esxcli Get-EsxCli side by side]({{ site.url }}/assets/images/posts/2018/05/set.esxcli.getesxcli.sidebyside.png){:class="img-responsive"}]({{ site.url }}/assets/images/posts/2018/05/set.esxcli.getesxcli.sidebyside.png)

It becomes a bit more complicated however, it would be easier to create a simple oneliner Powershell script to get this change applied to an entire VMware cluster:
[![Set Esxcli syslog cluster change]({{ site.url }}/assets/images/posts/2018/05//set.esxcli.syslog.cluster.change.png){:class="img-responsive"}]({{ site.url }}/assets/images/posts/2018/05//set.esxcli.syslog.cluster.change.png)

Summary of the commands used above:

```powershell
Get-Cluster -Name "{cluster name}" | Get-VMHost | `
   %{ Write-Host $_.Name ; `
   (Get-Esxcli -v2 -VMHost $_).system.syslog.config.get.Invoke()}

Get-Cluster -Name "{cluster name}" | Get-VMHost | `
   %{ Write-Host $_.Name ; `
   (Get-Esxcli -v2 -VMHost $_).system.syslog.config.set.Invoke(@{loghost="{syslog IP/FQDN}"})}
```
