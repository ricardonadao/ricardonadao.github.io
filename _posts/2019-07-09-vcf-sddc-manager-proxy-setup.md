---
author: Ricardo Adao
published: true
post_date: 2019-07-09 08:00:00
last_modified_at: 2019-07-09 09:45:00
header:
  teaser: /assets/images/featured/vcf-150x150.png
title: VCF - SDDC Manager proxy configuration
categories:
  - vcf
tags:
  - vcf
  - vmware
  - sddc
toc: true
slug: vcf-sddc-manager-proxy-configuration
lastmod: 2023-06-21T08:14:30.832Z
---
[_VMware Cloud Foundation (VCF)_](https://docs.vmware.com/en/VMware-Cloud-Foundation/index.html) is an integrated software stack that uses [_SDDC Manager_](https://docs.vmware.com/en/VMware-Cloud-Foundation/3.7/com.vmware.vcf.admin.doc_37/GUID-D143F07A-B3FA-4A14-8D03-BFD2C1810D2E.html) as a tool to automate the deployment and lifecycle management.

_SDDC Manager_ keeps a repository of _VCF Bundles_ needed to update all the components managed or deployed using _VCF_.

The easy way to populate the repository is to download the bundles directly from _VMware_.

When _SDDC Manager_ has internet connectivity the setup is quiet straightforward, however when the access is done through an _http proxy_ the configuration require some configurations changes directly in the appliance.

_SDDC Manager_ only supports proxy servers that do not require authentication
{: .notice--warning}

The official _VMware Documentation_ link is at [_Download Bundles With a Proxy Server_](https://docs.vmware.com/en/VMware-Cloud-Foundation/3.7/com.vmware.vcf.admin.doc_37/GUID-BB15EADE-DCD3-4D51-824E-124C9B364D20.html_)
{: .notice--info}

# Connect to _SDDC Manager_ using an _SSH client_

Login to _SDDC Manager_ using _vcf_ user credentials. Then we will need to elevate privileges to _root_:

```shell
su -
```

[![SDDC Manager login]({{ relative_url }}/assets/images/posts/2019/07/vcf-sddc-manager-proxy-setup-login.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2019/07/vcf-sddc-manager-proxy-setup-login.png)

# Change the right configuration file

From _VCF 2.3_ and newer the configuration file is:

```shell
/opt/vmware/vcf/lcm/lcm-app/conf/application-prod.properties
```

Before _VCF 2.3_ the configuration was:

```shell
/home/vrack/lcm/lcm-app/conf/application-evo.properties
```

[![SDDC Manager Config Files]({{ relative_url }}/assets/images/posts/2019/07/vcf-sddc-manager-proxy-setup-config-files.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2019/07/vcf-sddc-manager-proxy-setup-config-files.png)

# Configuration changes

## Changes will be done in properties

```shell
  lcm.depot.adapter.proxyEnabled
  lcm.depot.adapter.proxyHost
  lcm.depot.adapter.proxyPort
```

[![SDDC Manager Config Properties]({{ relative_url }}/assets/images/posts/2019/07/vcf-sddc-manager-proxy-setup-config-properties.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2019/07/vcf-sddc-manager-proxy-setup-config-properties.png)

## Edit them accordingly

[![SDDC Manager Configuration changes]({{ relative_url }}/assets/images/posts/2019/07/vcf-sddc-manager-proxy-setup-config-properties-changed.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2019/07/vcf-sddc-manager-proxy-setup-config-properties-changed.png)

# Restart the service

To get the settings activated we need to restart the _lcm service_.

```shell
system restart lcm
```

[![SDDC Manager Restart LCM service]({{ relative_url }}/assets/images/posts/2019/07/vcf-sddc-manager-proxy-setup-restart-service.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2019/07/vcf-sddc-manager-proxy-setup-restart-service.png)