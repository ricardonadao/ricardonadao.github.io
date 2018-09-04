---
ID: 666
post_title: 'Practical NSX: Restful API'
author: Amine
post_excerpt: ""
layout: post
permalink: >
  https://vrandombites.co.uk/2018/09/nsx/practical-nsx-restful-api/
published: true
post_date: 2018-09-01 14:33:34
---
REST API allows us to  programmatically control NSX, using REST API requests we can install, configure, monitor, and maintain NSX. The API calls typically use HTTP or HTTPS as the communication protocol, the payload itself is in JSON or XML format. VMware provides a beefy document that goes through all the various API calls and functionality available. If you are using NSX 6.3 like me, the guide can be found <a href="https://docs.vmware.com/en/VMware-NSX-for-vSphere/6.3/nsx_63_api.pdf">here</a>.

There are various Rest API clients out there, in this blog post you will be using Postman which can be downloaded from <a href="https://www.getpostman.com" target="_blank" rel="noopener">here</a>.

Once you have launched Postman, we will need to make a couple of configuration changes. Namely the Authorization type and adding a custom header which is needed for POST calls.
<h2>Configuring Postman</h2>
Launch Postman, click on Authorization, change the type to Basic, then enter your NSX Manager credentials.

<a href="https://vrandombites.co.uk/wp-content/uploads/2018/09/postman1.png" target="_blank" rel="noopener"><img class="alignnone wp-image-667 size-medium" src="https://vrandombites.co.uk/wp-content/uploads/2018/09/postman1-300x107.png" alt="" width="300" height="107" /></a>

Navigate to the headers menu

Add Content-Type as key and Application/xml as value

<a href="https://vrandombites.co.uk/wp-content/uploads/2018/09/postman2.png" target="_blank" rel="noopener"><img class="alignnone wp-image-668 size-medium" src="https://vrandombites.co.uk/wp-content/uploads/2018/09/postman2-300x42.png" alt="" width="300" height="42" /></a>

One last thing to mention here is that we will be using the https protocol to interact with the NSX manager. In my case I will be using https://192.168.0.44 to interact with my NSX Manager.

We are now ready to use Postman.
<h2>API Requests</h2>
Below is a list of the requests that are possible to use, however in my experience, you will find yourself using <strong>GET</strong>, <strong>POST</strong>, <strong>PUT</strong>, <strong>DELETE</strong> more frequently than the others.

<a href="https://vrandombites.co.uk/wp-content/uploads/2018/09/postman3.png" target="_blank" rel="noopener"><img class="alignnone wp-image-669 size-medium" src="https://vrandombites.co.uk/wp-content/uploads/2018/09/postman3-101x300.png" alt="" width="101" height="300" /></a>

<strong>GET</strong>: To read information

<strong>PUT</strong>: To update configuration.

<strong>POST</strong>: To change configuration

<strong>DELETE</strong>: To delete
<h2>Examples</h2>
<strong>Query my NSX controllers</strong>: https://192.168.0.44/api/2.0/vdn/controller

<a href="https://vrandombites.co.uk/wp-content/uploads/2018/09/postman4.png" target="_blank" rel="noopener"><img class="alignnone wp-image-670 size-medium" src="https://vrandombites.co.uk/wp-content/uploads/2018/09/postman4-300x242.png" alt="" width="300" height="242" /></a>

<strong>Query my SSO configuration</strong>: https://192.168.0.44/api/2.0/services/ssconfig

<a href="https://vrandombites.co.uk/wp-content/uploads/2018/09/postman5.png" target="_blank" rel="noopener"><img class="alignnone wp-image-671 size-medium" src="https://vrandombites.co.uk/wp-content/uploads/2018/09/postman5-300x100.png" alt="" width="300" height="100" /></a>

<strong>Query my logical switches</strong>: https://192.168.0.44/api/2.0/vdn/virtualwires

<a href="https://vrandombites.co.uk/wp-content/uploads/2018/09/postman6.png" target="_blank" rel="noopener"><img class="alignnone wp-image-672 size-medium" src="https://vrandombites.co.uk/wp-content/uploads/2018/09/postman6-290x300.png" alt="" width="290" height="300" /></a>

<strong>Create a logical switch</strong>:

As we all know,  a logical switch needs to belong to a transport zone, I will therefore need to find it's scope id as it's part of the logical switch creation call.

<strong>Query my transport zones </strong>: https://192.168.0.44/api/2.0/vdn/scopes

<a href="https://vrandombites.co.uk/wp-content/uploads/2018/09/postman8.png" target="_blank" rel="noopener"><img class="alignnone wp-image-673 size-medium" src="https://vrandombites.co.uk/wp-content/uploads/2018/09/postman8-300x143.png" alt="" width="300" height="143" /></a>

Now that we have our transport zone scope id  vdnscope-1, let's create our logical switch.

https://192.168.0.44/api/2.0/vdn/scopes/vdnscope-1/virtualwires

<strong>Body of our call</strong>

&lt;virtualWireCreateSpec&gt;
&lt;name&gt;LS_API&lt;/name&gt;
&lt;description&gt;REST API LS&lt;/description&gt;
&lt;tenantId&gt;&lt;/tenantId&gt;
&lt;controlPlaneMode&gt;UNICAST_MODE&lt;/controlPlaneMode&gt;
&lt;/virtualWireCreateSpec&gt;

<a href="https://vrandombites.co.uk/wp-content/uploads/2018/09/postman11.png" target="_blank" rel="noopener"><img class="alignnone wp-image-674 size-medium" src="https://vrandombites.co.uk/wp-content/uploads/2018/09/postman11-300x75.png" alt="" width="300" height="75" /></a>

Checking in our NSX environment we can see that the logical has indeed been created.

<a href="https://vrandombites.co.uk/wp-content/uploads/2018/09/postman12.png"><img class="alignnone wp-image-675 size-medium" src="https://vrandombites.co.uk/wp-content/uploads/2018/09/postman12-300x3.png" alt="" width="300" height="3" /></a>

<strong>Delete a logical switch</strong>

Let's first find it's object id: https://192.168.0.44/api/vdn/virtualwires &lt;virtualWire&gt;

&lt;objectId&gt;<strong>virtualwire-59</strong>&lt;/objectId&gt;
&lt;objectTypeName&gt;VirtualWire&lt;/objectTypeName&gt;
&lt;vsmUuid&gt;422A55B6-E2C7-A8A0-3E16-1D83B9C55220&lt;/vsmUuid&gt;
&lt;nodeId&gt;d17fc929-b712-4b69-b597-7f7fa4861dc8&lt;/nodeId&gt;
&lt;revision&gt;2&lt;/revision&gt;
&lt;type&gt;
&lt;typeName&gt;VirtualWire&lt;/typeName&gt;
&lt;/type&gt;
&lt;name&gt;<strong>LS_API</strong>&lt;/name&gt;

Now we can delete the logical switch: https://192.68.0.44<span style="font-family: Consolas, Monaco, monospace;">/api/2.0/vdn/virtualwires/virtualwire-59</span>

<a href="https://vrandombites.co.uk/wp-content/uploads/2018/09/postman14.png" target="_blank" rel="noopener"><img class="alignnone wp-image-676 size-medium" src="https://vrandombites.co.uk/wp-content/uploads/2018/09/postman14-300x29.png" alt="" width="300" height="29" /></a>