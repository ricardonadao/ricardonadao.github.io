---
layout: post
author: Ricardo Adao
published: true
post_date: 2018-09-22 09:00:00
title: Setting up NGINX as reverse proxy to allow vCenter Content Library subscription
categories: [ linux ]
tags: [ linux, vcenter, vmware, nginx, nested ]
comments: true
---
We want to setup a _Content Library_ in our _central vCenter_ and then allow the other _vCenters_ in our _Nested Labs_ to subscribe it without adding a lot of complexity to the configuration.

[![NGINX Nested Lab Scenario](/assets/images/posts/2018/09/nginx-reverse-proxy-to-access-content-library-01-visio.png){:class="img-responsive"}](/assets/images/posts/2018/09/nginx-reverse-proxy-to-access-content-library-01-visio.png)

### Requirements ###

* Allow only access to the _Content Library_ URL
* Configuration need be able to support multiple _nested vCenters_ subscribing the _Content Library_
* All _Nested Environments_ use the same private address space
* Only _NGINX vm_ (nginx-vm.local) should have an interface in both segments: "Transit" and "Physical Management"

### Solution ###

1. First step will be setting up a **DNAT** and a **FW Rule** in each _Nested Lab Edge_ to allow the _nested vCenters_ to subscribe the _Content Library_ using  _192.168.0.1 (Nested Edge Internal Interface)_ instead of connecting directly to the _central vCenter_.

[![Nested Lab Edge DNAT](/assets/images/posts/2018/09/nginx-reverse-proxy-to-access-content-library-02-dnat.png){:class="img-responsive"}](/assets/images/posts/2018/09/nginx-reverse-proxy-to-access-content-library-02-dnat.png)

[![Nested Lab Edge DNAT Config](/assets/images/posts/2018/09/nginx-reverse-proxy-to-access-content-library-02-01-dnat-config.png){:class="img-responsive"}](/assets/images/posts/2018/09/nginx-reverse-proxy-to-access-content-library-02-01-dnat-config.png)

[![Nested Lab Edge FW Rule](/assets/images/posts/2018/09/nginx-reverse-proxy-to-access-content-library-03-fwrule.png){:class="img-responsive"}](/assets/images/posts/2018/09/nginx-reverse-proxy-to-access-content-library-03-fwrule.png)

{:start="2"}

1. Before we setup the _NGINX_ we need to create a self-signed cert to be able to use SSL

```bash
openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
   -keyout /etc/nginx/nginx-cert.key -out /etc/nginx/nginx-cert.cert
```

{:start="3"}

1. Now we can setup the _NGINX_ service, we will focus in the basic configuration to filter the URL to limit the access only to the _Content Library_ vCenter service
> **Note:** we assume that _NGINX_ is installed in the vm already, since there are multiple ways and flavours to install it, depending on the engineer prefered distribution or prefered package management system.

```nginx
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;

# Load dynamic modules. See /usr/share/nginx/README.dynamic.
include /usr/share/nginx/modules/*.conf;

events {
    worker_connections  8096;
    multi_accept        on;
    use                 epoll;
}

http {
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile            on;
    tcp_nopush          on;
    tcp_nodelay         on;
    keepalive_timeout   15;
    types_hash_max_size 2048;

    include             /etc/nginx/mime.types;
    default_type        application/octet-stream;

    # Load modular configuration files from the /etc/nginx/conf.d directory.
    # See http://nginx.org/en/docs/ngx_core_module.html#include
    # for more information.
    include /etc/nginx/conf.d/*.conf;

# Settings for a TLS enabled server.
#
    server {
        # Listening only in the internal interface
        listen       172.16.52.250:443 ssl http2 default_server;
        server_name  ngnix-vm.local;

        ssl on;
        ssl_certificate "/etc/nginx/nginx-cert.cert";
        ssl_certificate_key "/etc/nginx/nginx-cert.key";
        ssl_session_cache shared:SSL:1m;
        ssl_session_timeout  30m;
#        ssl_ciphers HIGH:!aNULL:!MD5;
        ssl_prefer_server_ciphers on;
        ssl_protocols  TLSv1 TLSv1.1 TLSv1.2;
        ssl_ciphers HIGH:!aNULL:!eNULL:!EXPORT:!CAMELLIA:!DES:!MD5:!PSK:!RC4;

        access_log      /var/log/nginx/https.access.log ;

        # This is where we limit the URLs that we want to be available via reverse proxy
        location ~ /cls/(data|vcsp)/* {
                proxy_set_header        Host $host;
                proxy_set_header        X-Real-IP $remote_addr;
                proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_set_header        X-Forwarded-Proto $scheme;

                proxy_pass          https://vcenter00.local;
                proxy_read_timeout  90;

                proxy_redirect      https://vcenter00.local https://$host ;

                proxy_max_temp_file_size 0;
                proxy_buffering off;
        }

        # Any URL that do not match the previous rule, will receive a HTTP 404
        location ~ /* {
                return 404 ;
        }

        error_page 404 /404.html;
            location = /40x.html {
        }
    }
}
```

{:start="4"}

1. Validating that everything works

* Getting the _Content Library_ link to subscribe

[![Content Library Subscription link](/assets/images/posts/2018/09/nginx-reverse-proxy-to-access-content-library-04-content-library-settings.png){:class="img-responsive"}](/assets/images/posts/2018/09/nginx-reverse-proxy-to-access-content-library-04-content-library-settings.png)

* Create new content library in _vcenter01.nested_ via subscription of the one published by _vcenter00.local_

[![Create new Content Library](/assets/images/posts/2018/09/nginx-reverse-proxy-to-access-content-library-05-subscribe-content-library-settings.png){:class="img-responsive"}](/assets/images/posts/2018/09/nginx-reverse-proxy-to-access-content-library-05-subscribe-content-library-settings.png)

* Will prompt to accept the _nginx-vm.local_ certificate

[![New Content Library Certificate](/assets/images/posts/2018/09/nginx-reverse-proxy-to-access-content-library-06-subscribe-content-library-cert.png){:class="img-responsive"}](/assets/images/posts/2018/09/nginx-reverse-proxy-to-access-content-library-06-subscribe-content-library-cert.png)

* Confirm all the details before click _Finish_

[![New Content Library Creation Finish step](/assets/images/posts/2018/09/nginx-reverse-proxy-to-access-content-library-07-subscribe-content-library-readytocomplete.png){:class="img-responsive"}](/assets/images/posts/2018/09/nginx-reverse-proxy-to-access-content-library-07-subscribe-content-library-readytocomplete.png)

* **And all done**, since we configure the new _Content Library_ to download content only when needed the initial footprint is quiet small

[![New Content Library Status](/assets/images/posts/2018/09/nginx-reverse-proxy-to-access-content-library-08-subscribe-content-library-setupdone.png){:class="img-responsive"}](/assets/images/posts/2018/09/nginx-reverse-proxy-to-access-content-library-08-subscribe-content-library-setupdone.png)