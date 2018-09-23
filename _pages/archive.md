---
layout: default
title: Archive
permalink: /archive/
author: Ricardo Adao
published: true
post_date: 2018-09-23 12:30:00
categories: [ blog ]
tags: [ blog ]
---

# Post Archive #

{:.posts}
{% for post in site.posts offset:5 %}

## [![Featured Category](/assets/images/featured/{{ post.categories }}-50x50.png){:display inline;}](/assets/images/featured/{{ post.category }}-150x150.png) _**{{ post.date | date_to_string }}**_ >> [{{ post.title }}]({{ post.url }}) ##

{{ post.content | strip_html | truncatewords:50 }}

[_>> continue  reading_]({{ post.url }})

{% endfor %}