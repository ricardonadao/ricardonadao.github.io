---
author: Ricardo Adao
published: true
lastmod: 2023-06-21T09:52:52.686Z
date: 2023-03-17T00:00:00.0Z
header:
  teaser: /assets/images/featured/blog-150x150.png
title: Advanced Design VMware NSX-T Data Center 3.0 (3V0-42.20) - Remote Proctored Exam Experience and Preparation
categories:
  - blog
tags:
  - blog
  - social
toc: true
draft: true
mathjax: false
slug: advanced-design-vmware-nsx-data-center-3-0-3v0-42-20-remote-proctored-exam-experience-preparation
---
It seems that I got another **Badge**.

[![VCAP NV Design 2023 Badge]({{ relative_url }}/assets/images/cert_badges/vmware-vcap-nv-design-2023-150x150.png){:.align-center :class="img-responsive"}]({{ relative_url }}/assets/images/cert_badges/vmware-vcap-nv-design-2023.png)

However since I had already another badge to match this one.

[![VCAP NV Deploy 2023 Badge]({{ relative_url }}/assets/images/cert_badges/vmware-vcap-nv-deploy-2023-150x150.png){:.align-center :class="img-responsive"}]({{ relative_url }}/assets/images/cert_badges/vmware-vcap-nv-deploy-2023.png)

I ended up with an extra "free" badge.

[![VCIX NV 2023 Badge]({{ relative_url }}/assets/images/cert_badges/vmware-vcix-nv-2023-150x150.png){:.align-center :class="img-responsive"}]({{ relative_url }}/assets/images/cert_badges/vmware-vcix-nv-2023.png)

But this post is not about trading badges so lets go.

The [VCAP NV Design 3.0 (3V0-42.20)](https://www.vmware.com/learning/certification/vcap-nv-design-3-0-exam.html) was not my first *remote proctored exam*, I have done in the past the [VCAP NV Deploy](https://www.vmware.com/learning/certification/vcap-dcv-deploy-7x-exam.html) already, but there was some challenges with the checkin process so I decided to wait for the next one to give a fair chance to the process, I will leave that for another post.

## Booking and Scheduling process
Nothing new here, pretty easy to follow and was fairly easy to get a slot in the day I wanted.

## Checkin process
Fairly straight forward and it is a three (3) stage process:

* Stage 1
  * Open the exam link that will give you a code that will be your process/exam ID for the rest of the process
  * You start the _OnVue_ application
  * Some system checks are done (some of these are also done if you do the pre checks before you start the checkin), these are tests to make sure your laptop has enough resources to handle the exam, audio and camera are working since you will be recorded/monitored during the exam
    * Any applicatios that need to be shutdown?
    * Network speed/bandwidth is adequate?
    * Microphone working?
    * Audio working?
    * Camera works?
* Stage 2
  * This one can be done with a mobile the application gives you multiple options to get this part of the process done through the mobile
  * Take photos of the ID document
  * Take photos of the space where you are taking the exam
* Stage 2
  * After all the photos are taken you are added to a queue to wait for a human to do some last final checks:
    * Space around the _exam area_
      * you cannot have any extra screens (plugged in) around your _exam area_
      * no mobile at arms reach
      * funny enough, if you have photos visible to the camera it could be a challenge since it gets detected sometimes as extra persons, I ended up turning a lot of the photos and even our _Google Nest_ needed to be powered off
      * In summary, your _exam area_ needs to be cleaned of distractions
    * If there is anything than can be used to invalidate the exam
    * In summary, checking if you will not be cheating in the exam

## Exam experience
The exam is delivered through the _OnVue_ application and once the exam content is download it is a pretty smooth process. You will have 57 questions and 135 minutes to go through the exam.

I normally go through all the questions first, mark the ones that I want to review later and then spend the time that is left to review the answers. This makes sure that I do not leave questions answered and also keeps it easier to manage the stress when you spend too much time in a question and then you see the time running out.

Overall, the experience with the exam was quite positive since at no point I was stuck in the app or something did not work as expected. The delivery was smooth and you end up being a bit more relaxed since it is a familiar environment and not a strange environment that some times add more stress to the entire situation.

## Exam Preparation
Being a _VCAP Design exam_ the preparation needs to be slightly different from the _VCAP Deploy exam_ and also from the _VCPs_.
The focus of the exam is to validate that you have advanced knowledge to be able to recommend and design VMware solutions to meet specific goals and requirements.

A good place to start when you start preparing for any exam will be the _Exam Guide_, in this case [_Advanced Design VMware NSX-T Data Center 3.0 - Exam Guide_](https://www.vmware.com/content/dam/digitalmarketing/vmware/en/pdf/certification/vmw-vcap-nv-design-exam-preparation-guide.pdf).
The _Exam Guide_ will normally will give details about the exam:
* *Number of questions* - _57 items_ for this one
* *Passing score* - Normally _300_ for _VMware Exams_
* *Duration* - _135 minutes_ (2h15m), sometimes there is an extension for _non-native_ English speakers, but that does not apply for this one

The exam guide recommends to attend [_VMware NSX-T Data Center: Design [V3.2]_](https://mylearn.vmware.com/gw/mylearn/course/course-details/98404).

It is a five-day course and covers the considerations and practices that we need to consider when design a NSX-T environment.
The course will go through design principles, processes and frameworks to help the student acquire a deeper understanding of the NSX-T Data Center architecture to provide and create solutions to address the requirements and needs of a software-defined data center.

One of the good things about the design courses is that also covers some transversal principles and processes that would help you across any design process.

There are also some documentation that will be quite helpful:
* NSX-T Reference Design Guide 3.2 : [PDF](https://communities.vmware.com/t5/VMware-NSX-Documents/VMware-NSX-T-Reference-Design/ta-p/2778093?attachment-id=111634)
* NSX-T Multi-Location Design Guide (Federation + Multisite) [PDF](https://communities.vmware.com/t5/VMware-NSX-Documents/NSX-T-Multi-Location-Design-Guide-Federation-Multisite/ta-p/2810327?attachment-id=112921)
* NSX-T Data Center Quick Start Guide : [PDF](https://docs.vmware.com/en/VMware-NSX-T-Data-Center/3.2/nsxt_32_quick_start.pdf) [_docs.vmware.com_](https://docs.vmware.com/en/VMware-NSX-T-Data-Center/3.2/quick_start/GUID-78489E7A-1F6F-4317-BD8B-DDF59FEF9860.html)
* NSX-T Data Center Installation Guide : [PDF](https://docs.vmware.com/en/VMware-NSX-T-Data-Center/3.2/nsxt_32_install.pdf) [_docs.vmware.com_](https://docs.vmware.com/en/VMware-NSX-T-Data-Center/3.2/installation/GUID-3E0C4CEC-D593-4395-84C4-150CD6285963.html)
* NSX-T Data Center Administration Guide : [PDF](https://docs.vmware.com/en/VMware-NSX-T-Data-Center/3.2/nsxt_32_admin.pdf) [_docs.vmware.com_](https://docs.vmware.com/en/VMware-NSX-T-Data-Center/3.2/administration/GUID-FBFD577B-745C-4658-B713-A3016D18CB9A.html)
* NSX-T Data Center Upgrade Guide : [PDF](https://docs.vmware.com/en/VMware-NSX-T-Data-Center/3.2/nsxt_32_upgrade.pdf) [_docs.vmware.com_](https://docs.vmware.com/en/VMware-NSX-T-Data-Center/3.2/upgrade/GUID-E04242D7-EF09-4601-8906-3FA77FBB06BD.html)
* NSX-T Data Center Migration Guide : [PDF](https://docs.vmware.com/en/VMware-NSX-T-Data-Center/3.2/nsxt_32_migrate.pdf) [_docs.vmware.com_](https://docs.vmware.com/en/VMware-NSX-T-Data-Center/3.2/migration/GUID-7899A104-2662-4FC9-87B2-F4688FAEBBBA.html)
* Deploying and Managing the VMware NSX Application Platform : [PDF](https://docs.vmware.com/en/VMware-NSX-T-Data-Center/3.2/nsx-application-platform32.pdf) [_docs.vmware.com_](https://docs.vmware.com/en/VMware-NSX-T-Data-Center/3.2/nsx-application-platform/GUID-658D30E1-64B3-40B8-8FD4-ED2AE2A6FF7A.html)
* NSX Security Quick Start Guide : [PDF](https://docs.vmware.com/en/VMware-NSX-T-Data-Center/3.2/nsx-security-quick-start.pdf) [_docs.vmware.com_](https://docs.vmware.com/en/VMware-NSX-T-Data-Center/3.2/nsx-security-quick-start/GUID-FFBA52E4-8BCF-42AC-9D30-D158E9369C5F.html)
* NSX-T Data Center CLI Guide : [link](https://vdc-download.vmware.com/vmwb-repository/dcr-public/8bc4a9b3-b4fb-447a-a97b-1452c22d6d5d/8537fe7f-36fd-4122-b1a4-fab306cc279d/cli_doc/index.html)
* NSX-T Data Center API Guide : [link](https://developer.vmware.com/apis/1198/nsx-t)
* NSX-T Data Center Global Policy API Guide : [link](https://developer.vmware.com/apis/1230/nsx-t-global-manager)