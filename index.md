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

* _**{{ post.date | date_to_string }}**_ » [{{ post.title }}]({{ post.url }})

{% endfor %}
