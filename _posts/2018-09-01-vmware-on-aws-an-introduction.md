---
ID: 685
post_title: 'VMware on AWS: An introduction'
author: Amine
post_excerpt: ""
layout: post
permalink: >
  https://vrandombites.co.uk/2018/09/vmc/vmware-on-aws-an-introduction/
published: true
post_date: 2018-09-01 23:26:10
---
<h2>What is it?</h2>
VMware Cloud on AWS is a dedicated AWS hosted implementation of VMware’s Cloud Foundation. VMC is running on AWS hardware but supported by VMware via GSS and the customer success team. Virtual machine workloads on VMC can access API endpoints for AWS services such as AWS Lambda,  S3 etc, as well as private resources in the customer’s Amazon VPC such as Amazon EC2.
<h2>Features</h2>
<ul>
 	<li>You can start with just one host!</li>
 	<li>Scale up on demand.</li>
 	<li>Fully featured HTML 5 vSphere client.</li>
 	<li>DRS, Elastic DRS and vSphere HA.</li>
 	<li>Host failures remediation is the responsibility of VMware.</li>
 	<li>vSAN all-flash array with NVMe.</li>
 	<li>Networking is built around NSX.</li>
 	<li>vCenter Hybrid Linked Mode (HLM). HLM allows you to link your VMC vCenter to your on-prem vCenter.</li>
 	<li>VMware Site Recovery: on-demand disaster recovery as a service.</li>
</ul>
<h2>Use Cases</h2>
<ul>
 	<li>Maintain and expand: Keep your workload on-prem but also expand to the public cloud</li>
 	<li>Migrate: Reduce your datacenter footprint.</li>
 	<li>Workload Flexibilty:  bi-directional workload portability</li>
</ul>
<a href="https://vrandombites.co.uk/wp-content/uploads/2018/09/vmc1.png"><img class="alignnone wp-image-686 size-medium" src="https://vrandombites.co.uk/wp-content/uploads/2018/09/vmc1-300x118.png" alt="" width="300" height="118" /></a>
<h2>Things to note:</h2>
<ul>
 	<li>VMC isn’t available in all AWS regions, although they are expanding.</li>
 	<li>It does not have a full NSX implementation but a "simplified" one.</li>
 	<li>No access to the ESXi hosts</li>
 	<li>Limited administrative control. VMware has complete administrative control over the management and infrastructure components. We are limited to managing workload VMs.</li>
</ul>
If you are interested in knowing what's in the pipeline for VMC, check out the <a href="https://cloud.vmware.com/vmc-aws/roadmap">roadmap</a> it's public!

Having just started working with VMC, I can honesty say that I can see it's potential and the value that it brings,  So stay tuned for more VMC blog posts!