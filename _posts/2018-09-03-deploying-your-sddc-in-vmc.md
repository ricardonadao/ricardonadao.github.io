---
ID: 715
post_title: Deploying your SDDC in VMC
author: Amine
post_excerpt: ""
layout: post
permalink: >
  https://vrandombites.co.uk/2018/09/vmc/deploying-your-sddc-in-vmc/
published: true
post_date: 2018-09-03 20:07:44
---
Deploying a Software Defined Data Center is the first step in making use of the VMware Cloud on AWS service. Let's see how that's done.
<h2>Deploy your first SDDC</h2>
Once you have received your login details, head off to https://vmc.vmware.com and logon.

Once logged in, you will be greeted by the below screen inviting you to create your first SDDC&nbsp; (:

<a href="https://vrandombites.co.uk/wp-content/uploads/2018/09/sddc1.png" target="_blank" rel="noopener"><img class="alignnone wp-image-716 size-medium" src="https://vrandombites.co.uk/wp-content/uploads/2018/09/sddc1-300x117.png" alt="" width="300" height="117"/></a>

Let's do it! Click on the create SDDC button

<a href="https://vrandombites.co.uk/wp-content/uploads/2018/09/sddc2.png" target="_blank" rel="noopener"><img class="alignnone wp-image-717 size-medium" src="https://vrandombites.co.uk/wp-content/uploads/2018/09/sddc2-300x111.png" alt="" width="300" height="111"/></a>

Choose the AWS region where you want your SDDC to be located at

Choose the number of hosts then press next to move on to the next screen

<a href="https://vrandombites.co.uk/wp-content/uploads/2018/09/sddc3.png" target="_blank" rel="noopener"><img class="alignnone wp-image-718 size-medium" src="https://vrandombites.co.uk/wp-content/uploads/2018/09/sddc3-300x60.png" alt="" width="300" height="60"/></a>

As I am using the hands on labs, the option to connect my SDDC to AWS is not availabe however this option is available with a fully fledge VMC account.

The last step is to choose a network subnet for you management devices (vCenter, ESXI, NSX etc..)

<a href="https://vrandombites.co.uk/wp-content/uploads/2018/09/sddc4.png" target="_blank" rel="noopener"><img class="alignnone wp-image-719 size-medium" src="https://vrandombites.co.uk/wp-content/uploads/2018/09/sddc4-300x98.png" alt="" width="300" height="98"/></a>

Click deploy and the system will start provisioning your SDDC.

<a href="https://vrandombites.co.uk/wp-content/uploads/2018/09/sddc5.png" target="_blank" rel="noopener"><img class="alignnone wp-image-720 size-medium" src="https://vrandombites.co.uk/wp-content/uploads/2018/09/sddc5-300x187.png" alt="" width="300" height="187"/></a>

Once the deployement is complete (it will take a while), you will be able to access the SDDC console by clicking on the SDDC name.

<a href="https://vrandombites.co.uk/wp-content/uploads/2018/09/sddc6.png" target="_blank" rel="noopener"><img class="alignnone wp-image-721 size-medium" src="https://vrandombites.co.uk/wp-content/uploads/2018/09/sddc6-300x131.png" alt="" width="300" height="131"/></a>
<h2>Access your vCenter</h2>
One change you will need to make before being able to access your vCenter is to add a rule to the firewall

<a href="https://vrandombites.co.uk/wp-content/uploads/2018/09/sddc7.png" target="_blank" rel="noopener"><img class="alignnone wp-image-722 size-medium" src="https://vrandombites.co.uk/wp-content/uploads/2018/09/sddc7-300x118.png" alt="" width="300" height="118"/></a>

I have added the equivalent of an any to any rule for the vCenter access for now.

<a href="https://vrandombites.co.uk/wp-content/uploads/2018/09/sddc9.png" target="_blank" rel="noopener"><img class="alignnone wp-image-723 size-medium" src="https://vrandombites.co.uk/wp-content/uploads/2018/09/sddc9-300x94.png" alt="" width="300" height="94"/></a>

I can now access the vCenter by clicking on open vCenter and using the credentials provided

<a href="https://vrandombites.co.uk/wp-content/uploads/2018/09/sddc10.png" target="_blank" rel="noopener"><img class="alignnone wp-image-724 size-medium" src="https://vrandombites.co.uk/wp-content/uploads/2018/09/sddc10-300x156.png" alt="" width="300" height="156"/></a>

<a href="https://vrandombites.co.uk/wp-content/uploads/2018/09/sddc11.png" target="_blank" rel="noopener"><img class="alignnone wp-image-725 size-medium" src="https://vrandombites.co.uk/wp-content/uploads/2018/09/sddc11-300x133.png" alt="" width="300" height="133"/></a>

That's all there is to it. In the next blog post, we will take a tour of the VMC console.

I hope you found this post informative, be social please share.