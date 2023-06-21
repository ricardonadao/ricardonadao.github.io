---
author: Ricardo Adao
published: true
post_date: 2019-06-08 22:30:00
last_modified_at: null
header:
  teaser: /assets/images/featured/macos-mojave-150x150.png
title: MAC OS - Configuring multiple DNS resolvers
categories:
  - macos
tags:
  - macos
  - dns
  - vpn
toc: true
slug: mac-os-configuring-multiple-dns-resolvers
lastmod: 2023-06-21T08:14:34.681Z
---
New company, new gear and the plain/fun of going through the hassle of setting up your laptop and all tweaks and preferences that you love.

# Challenge

My new laptop has a _VPN client_ installed that push _DNS settings_ overriding my _home network DNS_, that stops me from solving the _internal FQDNs_ for my local network.

This is a normal behavior for the majority of _VPN clients_, when there is a conscious security policy in place.
 
This setup is perfectly fine for majority of the users that do not really bother to setup DNS on their home network, or just have a good memory to remember which device has IP X.X.X.X.

Well my problem is that I am in none of these two groups, since lets face it, I am really bad remembering what IPs my devices at home have configured or what IPs were assigned to them by _DHCP_, and I do have _internal DNS_ setup at home to be able to use _FQDNs_ instead of IPs.

Hence my challenge when your _VPN client_ changes the  _/etc/resolv.conf_ removing my _internal DNS_ from the config.

# Solution

## Initial state of my _resolv.conf_

```shell
domain home
nameserver 192.168.0.1
nameserver 192.168.0.2
```

## State of _resolv.conf_ after connecting _VPN client_

```shell
search mycompany.com it.mycompany.com
nameserver 10.30.20.10
nameserver 10.30.20.11
```

### At this point all my _internal DNS_ resolution is gone

```shell
$ ping mydevice.home

ping: cannot resolve mydevice.home: Unknown host
```

## To solve the problem we need to add an additional _resolv.conf_

The additional configuration is similar to any other _resolv.conf_ file that we add to _/etc/resolver/_ directory.

For example, to our _**home**_ domain we need a config file:

```shell
domain home
nameserver 192.168.0.1
nameserver 192.168.0.2
```

### Checking again if we now can use _FQDN_  instead of IP

```shell
$ ping mydevice.home -c 2

PING mydevice.home (192.168.0.5): 56 data bytes
64 bytes from 192.168.0.5: icmp_seq=0 ttl=64 time=7.756 ms
64 bytes from 192.168.0.5: icmp_seq=1 ttl=64 time=2.554 ms

--- mydevice.home ping statistics ---
2 packets transmitted, 2 packets received, 0.0% packet loss
round-trip min/avg/max/stddev = 2.554/5.155/7.756/2.601 ms
```

Seems that it works :)

# Summary

The solution is pretty simple as explained.

1. Get the config that you would need in a normal _/etc/resolv.conf_ file for your domain
2. Create an additional config file in _/etc/resolver/_
3. Reconnect _VPN client_ or restart network config