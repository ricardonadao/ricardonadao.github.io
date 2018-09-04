---
ID: 548
post_title: 'NSX &#8211; How to automate a 3 Tier App deployment &#8211; Part 1'
author: Ricardo Adao
post_excerpt: ""
layout: post
permalink: >
  https://vrandombites.co.uk/2018/09/nsx/nsx-how-to-automate-3-tier-app-deployment-part1/
published: true
post_date: 2018-09-02 08:00:28
---
<!-- wp:paragraph -->
<p>One of the big advantages of the NSX is to a Software Defined Network (SDN) solution given us the ability to code once and execute as many times.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>NSX has a really rich and complete <em>REST API</em> documented at <a href="https://code.vmware.com/apis/329/nsx-for-vsphere">VMware API Explorer - NSX 6.4</a>.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>There are multiple options to leverage the <em>NSX API</em>:</p>
<!-- /wp:paragraph -->

<!-- wp:list -->
<ul><li>Using a <em>REST API Client</em>, as <a href="https://www.getpostman.com/"><em>Postman</em></a> for example</li><li>Going <em>old school</em> with <em>curl</em></li><li>Using <em>Powershell</em> using cmdlets similar to <em>Invoke-RestMethod</em> or <em>Invoke-WebRequest</em></li><li>Using <em>python</em> mapping all the API calls similar to what would be done with any other programming language that we would prefer</li><li>Using <a href="https://powernsx.github.io/">PowerNSX</a> powershell module that abstracts all the hassle of payload creation and API calls</li></ul>
<!-- /wp:list -->

<!-- wp:paragraph -->
<p>In these series of posts we will leverage <em><a style="background-color: transparent; box-sizing: border-box; color: #007fac; font-family: Noto Serif,serif; font-size: 16px; font-style: normal; font-variant: normal; font-weight: 400; letter-spacing: normal; orphans: 2; outline-color: invert; outline-style: none; outline-width: 0px; text-align: left; text-decoration: underline; text-indent: 0px; text-transform: none; transition-duration: 0.05s; transition-property: border, background, color; transition-timing-function: cubic-bezier(0.42, 0, 0.58, 1); -webkit-text-stroke-width: 0px; white-space: normal; word-spacing: 0px;" href="https://powernsx.github.io/">PowerNSX</a></em> module to simplify the interaction with the <em>NSX Rest</em> API.</p>
<!-- /wp:paragraph -->

<!-- wp:heading -->
<h2>Objective</h2>
<!-- /wp:heading -->

<!-- wp:paragraph -->
<p>The main objective of this series will be to demonstrate how can we leverage some of the <em>NSX</em> capabilities to facilitate the provision of multiple similar environments in an automated way.</p>
<!-- /wp:paragraph -->

<!-- wp:heading -->
<h2>Scenario</h2>
<!-- /wp:heading -->

<!-- wp:paragraph -->
<p>We want to be able to deploy and destroy multiple copies of the <em>standardized solution</em>, that we will reference through the series as <em>vPOD</em>. Each of these <em>vPODs</em> will be able to host a <em>3 Tier App Solution</em>. The main goal is to minimize the deployment/redeployment manual effort to the bare minimum.<br /></p>
<!-- /wp:paragraph -->

<!-- wp:heading {"level":4} -->
<h4>Network Diagram</h4>
<!-- /wp:heading -->

<!-- wp:paragraph -->
<p>Let us kick this off with a simple network diagram of our <em>vPOD</em> that we will automate in the next few posts:</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><img class="wp-image-571" style="width: 586px;" src="https://vrandombites.co.uk/wp-content/uploads/2018/08/nsx-create.edge_.example.png" alt="" height="491"/></p>
<!-- /wp:paragraph -->

<!-- wp:heading {"level":4} -->
<h4>Requirements</h4>
<!-- /wp:heading -->

<!-- wp:list -->
<ul><li>Each tier will have their own network segment</li><li>Each segment will have their own subnet</li><li>Inter and Intra segment traffic need to be fully secured</li><li>Tiers:<ul><li><em>WebApp</em> - Webservers/FrontEnd Servers<br /><ul><li>will be the only tier exposed to the public</li><li>tier provides HTTP services</li><li>front-end services will be load balanced across multiple servers</li></ul></li><li><em>App</em> - Application/MidTier servers<ul><li>tier to host all the app servers</li><li>app servers will be load balanced across multiple servers</li></ul></li><li><em>DB </em>- Database tier<br /><ul><li>tier hosting all the databases servers with the data used by the app servers</li></ul></li></ul></li></ul>
<!-- /wp:list -->

<!-- wp:heading {"level":4} -->
<h4>Instead of long post lets divide these in multiple parts:<br /></h4>
<!-- /wp:heading -->

<!-- wp:list -->
<ul><li>Create Logical Switches</li><li>Create NSX Edge Service Gateway</li><li>Create NSX Distributed Logic Router</li><li>Configure NSX Edge Service Gateway<ul><li>Configure SNATs &amp; DNATs</li><li>Configure Firewall Rules</li></ul></li><li>Configure Distributed Firewall</li></ul>
<!-- /wp:list -->

<!-- wp:paragraph -->
<p>The division of the entire process in smaller posts will give some room to detail each step and create a more modular process, where each scripted step can be used individually and re-used.<br /></p>
<!-- /wp:paragraph -->