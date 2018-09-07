---
layout: default
author: Ricardo Adao
published: true
post_date: 2018-09-05 14:07:00
categories: []
tags: []
---

**We are moving to gihub pages so still a bit under maintenance.**

![Under Construction](assets/images/under.construction.png){:width="600px" height="400px"}

# Posts #

{:.posts}
{% for post in site.posts %}

* {{ post.date | date_to_string }} » [{{ post.title }}]({{ post.url }})

{% endfor %}
