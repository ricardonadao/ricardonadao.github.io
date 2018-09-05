---
# Feel free to add content and custom Front Matter to this file.
# To modify the layout, see https://jekyllrb.com/docs/themes/#overriding-theme-defaults

layout: default
author: Ricardo Adao
published: true
post_date: 2018-09-05 14:07:00
categories: []
tags: []
---

 **We are moving to gihub pages so still a bit under maintenance.**

 ![Under Construction](assets/under.construction.png){:width="600px" height="400px"}

<ul class="posts">
	  {% for post in site.posts %}
	    <li><span>{{ post.date | date_to_string }}</span> » <a href="{{ post.url }}" title="{{ post.title }}">{{ post.title }} </a></li>
	  {% endfor %}
</ul>

<ul class="archive">
	{% include archive.html %}
</ul>