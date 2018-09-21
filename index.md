---
layout: default
author: Ricardo Adao
published: true
post_date: 2018-09-05 14:07:00
categories: []
tags: []
---

# Posts #

{:.posts}
{% for post in site.posts %}

## [![Featured Category](/assets/images/featured/{{ post.categories }}-50x50.png){:display inline;}](/assets/images/featured/{{ post.category }}-150x150.png) _**{{ post.date | date_to_string }}**_ >> [{{ post.title }}]({{ post.url }}) ##

{{ post.content | strip_html | truncatewords:50 }} [_Read More_]({{ post.url }})

{% endfor %}
