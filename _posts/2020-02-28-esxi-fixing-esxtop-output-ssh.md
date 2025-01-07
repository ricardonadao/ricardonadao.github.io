---
author: Ricardo Adao
published: true
date: 2020-02-28 08:00:00
header:
  teaser: /assets/images/featured/vsphere-150x150.png
title: ESXi - Fixing esxtop output in a SSH session
categories:
  - esxi
tags:
  - esxi
  - vsphere
  - hypervisor
  - homelab
  - macos
  - vmware
toc: true
slug: esxi-fixing-esxtop-output-ssh-session
last_modified_at: 2025-01-07 12:23:00
---
When you use for ages a _SSH client_ that magically just works and it is pretty simple to setup as [_PuTTY_](https://www.chiark.greenend.org.uk/~sgtatham/putty/).

You take for granted that you open an SSH session and all just works.

However, when when I moved to _macOS_ and start using [_iTerm2_](https://iterm2.com/) as my main terminal emulator, some of my SSH sessions start behaving funny.

And some of the SSH sessions that were playing up were the ones for my Homelab _ESXis_, which made me chase the problem since it was pretty annoying not being able to use one of the tools that is quite useful for any troubleshoot - _**esxtop**_.

# Problem

Everytime I opened an SSH session to one of my Homelab _ESXis_ servers and run _**esxtop**_ the result was something similar to running it in _batch mode_ with output to the _stdout_ (screen).

[![SSH esxtop broken output]({{ relative_url }}/assets/images/posts/2020/02/esxi-esxtop-broken-output.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2020/02/esxi-esxtop-broken-output.png)

# Troubleshooting

When checking the output for clues I noticed the first bit of the output.

[![SSH esxtop broken output clue]({{ relative_url }}/assets/images/posts/2020/02/esxi-esxtop-broken-output-clue.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2020/02/esxi-esxtop-broken-output-clue.png)

It seems that potentially the problem is related to the _**TERM**_ variable that normally helps defining some of the terminal parameters.

In this case, seems that our _ESXi shell_ do not know _xterm256-color_ terminal.
And we easily can verify that looking at _/usr/share/terminfo/x/_ that it makes sense, since no _xterm256-color_ is listed.

[![ESXi SSH terminfo db]({{ relative_url }}/assets/images/posts/2020/02/esxi-esxtop-esxi-ssh-terminfo-db.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2020/02/esxi-esxtop-esxi-ssh-terminfo-db.png)


The _$TERM_ shell variable is inherited from our _terminal emulator_.

* Terminal Emulator

  [![Terminal Emulator $TERM]({{ relative_url }}/assets/images/posts/2020/02/esxi-esxtop-terminal-emulator-term.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2020/02/esxi-terminal-emulator-term.png)

* ESXi SSH

  [![ESXi SSH term]({{ relative_url }}/assets/images/posts/2020/02/esxi-esxtop-esxi-ssh-term.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2020/02/esxi-esxtop-esxi-ssh-term.png)

# Solution

There are three options to solve our problem:

* Change the _$TERM_ in our _macOS_ terminal emulator
* Prefix our command _**esxtop**_ overriding the _$TERM_ value
* Override the inherited _$TERM_ value whenever we login to ESXi via SSH

I personally do not like the first two, since none of them would be permanent solution or did not have any collateral damage.

**So the option of overriding the inherited _$TERM_ in every login to the ESXi was the preferred.**

One of the options to override the _$TERM_ value with something that we know that always work, for example _**xterm**_, would be adding the var assignment to _/etc/profile.local_.

```shell
vi /etc/profile.local
```

[![ESXi profile.local]({{ relative_url }}/assets/images/posts/2020/02/esxi-esxtop-edit-profilelocal.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2020/02/esxi-esxtop-edit-profilelocal.png)

The file _profile.local_ is processed every time you login via SSH as part of the shell setup, hence to take effect we will need to reload it, easiest way is to do a logoff/logon.

# Result

Once we get this done and we logoff/logon, we can check if _$TERM_ was overridden by our changes.

[![ESXi $TERM after change]({{ relative_url }}/assets/images/posts/2020/02/esxi-esxtop-esxi-ssh-term-after-change.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2020/02/esxi-esxtop-esxi-ssh-term-after-change.png)

And lets check if _**esxtop**_ behaves as expected.

[![ESXi esxtop output fixed]({{ relative_url }}/assets/images/posts/2020/02/esxi-esxtop-fixed-output.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2020/02/esxi-esxtop-fixed-output.png)
