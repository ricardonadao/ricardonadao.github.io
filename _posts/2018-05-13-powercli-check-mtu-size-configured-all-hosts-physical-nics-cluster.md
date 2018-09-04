---
ID: 164
post_title: 'PowerCLI &#8211; Check MTU size configured in all hosts physical nics of a cluster'
author: Ricardo Adao
post_excerpt: ""
layout: posts
permalink: >
  https://vrandombites.co.uk/2018/05/coding/powercli/powercli-check-mtu-size-configured-all-hosts-physical-nics-cluster/
published: true
post_date: 2018-05-13 10:16:54
---
Nowadays with the quick vSAN and NSX adoption, pushing the MTU configuration out of the 1500 bytes standard is becoming more and more common.

So consistency is important for the MTU configuration across all the hosts physical nics (engaged on vSAN and NSX) on a VMware Cluster is becoming also more relevant.

In the reach of two/three "google clicks" there are multiple options to get this information using PowerCLI, shellscript, python, API calls, and multiple other options.

However, sometimes we just prefer to push us a bit to get that oneliner to get the info that we need, just for bragging rights or just to exercise our skills.

And this post is nothing more than one of those cases, when I decided to check how complicated would be to get this info using a oneliner.

And surprisingly was easier than expected.
<pre lang="powershell">Get-Cluster –Name “{Custer Name}” | Get-VMHost | `
  %{Write-Host $_.Name ; (Get-EsxCli -VMHost $_ -V2).network.nic.list.Invoke() | `
  %{Write-Host "NIC:"$_.Name "MTU:"$_.MTU}}</pre>
[caption id="attachment_178" align="alignleft" width="640"]<a href="http://vrandombites.co.uk/wp-content/uploads/2018/05/powercli.pnic_.mtu_.oneliner.example-e1526202644300.png"><img class="wp-image-178 size-large" src="http://vrandombites.co.uk/wp-content/uploads/2018/05/powercli.pnic_.mtu_.oneliner.example-1024x281.png" alt="Example running using an home lab" width="640" height="176" /></a> Example running using an home lab[/caption]

Of course to get into this we need to do the normal vCenter connection with:
<pre lang="powershell"> Connect-VIServer -Name</pre>