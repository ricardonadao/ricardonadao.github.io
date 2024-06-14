---
author: Ricardo Adao
published: true
post_date: 2019-12-26 08:00:00

header:
  teaser: /assets/images/featured/powercli-150x150.png
title: PowerCLI - Install Powershell and PowerCLI in MacOS
categories:
  - powercli
tags:
  - powercli
  - powershell
  - macos
  - vmware
toc: true
slug: powercli-install-powershell-powercli-macos
last_modified_at: 2023-06-21T08:14:22.466Z
---
This post is not a _new method_ or even new information, it is more a consolidated run through on how to get _VMware PowerCLI_ modules installed in _MAC OS_.

Installing _VMware PowerCLI_ _Powershell_ modules is almost a _must do_ task for any _VMware user_, since it gives the ability to automate/script almost any task available through the management frontends, and a lot more that sometimes are not simply available through it.

This post goes through the necessary tasks to get _VMware PowerCLI_ modules installed and ready to use in your _MAC OS_.

# Pre-requirements to install _VMware PowerCLI_

To install _VMware PowerCLI_ modules you need to first install _Powershell Core_ for _MAC OS_.

There are two (2) methods to install _Powershell Core_ in _MAC OS_:

* Using _Homebrew_ package manager
* Downloading _Powershell_ install package from [_Powershell_ Github](https://github.com/PowerShell/PowerShell) and install it

Some detailed information in how to install _Powershell Core_ in _MAC OS_ - [_Microsoft Documentation_ website](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-macos?WT.mc_id=thomasmaurer-blog-thmaure&view=powershell-6)
{: .notice--info}

## **Method 1**: Using _Homebrew_ package manager

To install _Powershell_ using [_Homebrew_](https://brew.sh) package manager you will need to install some tools before hand.

### Install _MAC OS_ command line tools - _Xcode_

```shell
xcode-select –install
```

### Installing _Homebrew_ package manager

* After you install _Xcode_ command line tools you will need to install _Homebrew_ if not already installed.

  ```shell
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  ```

  [![Install _Homebrew_]({{ relative_url }}/assets/images/posts/2019/12/powercli-install-powercli-macos-install-homebrew.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2019/12/powercli-install-powercli-macos-install-homebrew.png)

* Then you need to install _Homebrew-Cask_ to extend _Homebrew_.

  ```shell
  brew tap homebrew/cask
  ```

### Install _Powershell_ using _Homebrew_

```shell
brew cask install powershell
```

[![Install _Powershell_ using _Homebrew]({{ relative_url }}/assets/images/posts/2019/12/powercli-install-powercli-macos-brew_install_powershell.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2019/12/powercli-install-powercli-macos-brew_install_powershell.png)

## **Method 2**: Using _Powershell_ install package

### Downloading the install package

You can download the installation package from the [_Powershell Github_](https://github.com/PowerShell/PowerShell) page.

You can download the stable or preview versions depending how brave you are.

[![Download Install Package]({{ relative_url }}/assets/images/posts/2019/12/powercli-install-powercli-macos-download-install-packages.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2019/12/powercli-install-powercli-macos-download-install-packages.png)

### Installing _Powershell_ package

* Run installation package

  The installation package will need to be allowed through the security framework before it allows you to install.

  [![Run Install Package]({{ relative_url }}/assets/images/posts/2019/12/powercli-install-powercli-macos-run-install-packages.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2019/12/powercli-install-powercli-macos-run-install-packages.png)

* Allowing the installation package through system security policies

  [![Security & Privacy - Open Anyway]({{ relative_url }}/assets/images/posts/2019/12/powercli-install-powercli-macos-security_privacy_step1-install-packages.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2019/12/powercli-install-powercli-macos-security_privacy_step1-install-packages.png)

  [![Security & Privacy - Enter password or use TouchID]({{ relative_url }}/assets/images/posts/2019/12/powercli-install-powercli-macos-security_privacy_step2-install-packages.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2019/12/powercli-install-powercli-macos-security_privacy_step2-install-packages.png)

* Re-Open installation package

  [![Re-Open the installation package]({{ relative_url }}/assets/images/posts/2019/12/powercli-install-powercli-macos-reopen-install-packages.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2019/12/powercli-install-powercli-macos-reopen-install-packages.png)

* Install _Powershell_ using installation package
  * Step 1
  [![Install Wizard - Step 1]({{ relative_url }}/assets/images/posts/2019/12/powercli-install-powercli-macos-run-install-package-step1.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2019/12/powercli-install-powercli-macos-run-install-package-step1.png)

  * Step 2
  [![Install Wizard - Step 2]({{ relative_url }}/assets/images/posts/2019/12/powercli-install-powercli-macos-run-install-package-step2.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2019/12/powercli-install-powercli-macos-run-install-package-step2.png)

  * Step 3
  [![Install Wizard - Step 3]({{ relative_url }}/assets/images/posts/2019/12/powercli-install-powercli-macos-run-install-package-step3.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2019/12/powercli-install-powercli-macos-run-install-package-step3.png)

  * Step 4
  [![Install Wizard - Step 4]({{ relative_url }}/assets/images/posts/2019/12/powercli-install-powercli-macos-run-install-package-step4.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2019/12/powercli-install-powercli-macos-run-install-package-step4.png)

## Run _Powershell_
{: #run_powershell_ref}

* Find _Powershell_ app icon in the _Application folder_ or run from a _shell_

  * [![Find _Powershell_ app icon]({{ relative_url }}/assets/images/posts/2019/12/powercli-install-powercli-macos-run-powershell-step1.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2019/12/powercli-install-powercli-macos-run-powershell-step1.png)

  * Or run from a _shell_

    ```shell
    pwsh
    ```

    [![Run from _shell_]({{ relative_url }}/assets/images/posts/2019/12/powercli-install-powercli-macos-run-powershell-from-shell.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2019/12/powercli-install-powercli-macos-run-powershell-from-shell.png)

* _Powershell_ window
[![_Powershell_ application window]({{ relative_url }}/assets/images/posts/2019/12/powercli-install-powercli-macos-run-powershell-step2.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2019/12/powercli-install-powercli-macos-run-powershell-step2.png)

# Install _VMware PowerCLI_ _Powershell_ modules

Once we get _Powershell_ installed we can install _VMware PowerCLI_ modules.

Since _VMware PowerCLI_ modules are now available from _PSGallery repository_ we can install it directly from within a _Powershell environment_.

1. First we need to start a _Powershell_ instance

   We can use any of the methods described before in [_Run Powershell section_](#run_powershell_ref)

   [![_Powershell_ application window]({{ relative_url }}/assets/images/posts/2019/12/powercli-install-powercli-macos-run-powershell-step2.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2019/12/powercli-install-powercli-macos-run-powershell-step2.png)

2. Let us check what _VMware Powershell_ modules are available to be installed through _PSGallery_

   ```powershell
   Find-Module VMware.*
   ```

   [![Check _VMware Powershell_ modules available]({{ relative_url }}/assets/images/posts/2019/12/powercli-install-powercli-macos-find-vmware-modules.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2019/12/powercli-install-powercli-macos-find-vmware-modules.png)

3. We will install _**VMware.PowerCLI**_

   ```powershell
   Install-Module -Name "VMware.PowerCLI" -Scope "CurrentUser"
   ```

   We are installing _VMware PowerCLI_ modules only for the current user, hence _-Scope "CurrentUser"_ parameter
   {: .notice--info}

   [![Install _VMware PowerCLI_ modules]({{ relative_url }}/assets/images/posts/2019/12/powercli-install-powercli-macos-install-powercli-modules.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2019/12/powercli-install-powercli-macos-install-powercli-modules.png)

   We could set _PSGallery repository_ to be _Trusted_ using _Set-PSRepository -Name "PSGallery" -InstallationPolicy "Trusted"_, however I personally prefer to keep it _Untrusted_ and answer the question when needed
   {: .notice--info}

4. Let us check if _VMware PowerCLI_ module is ready to go

   ```powershell
   Get-Module "VMware.PowerCLI" -ListAvailable | FT -AutoSize
   ```

   [![Check _VMware PowerCLI_ modules]({{ relative_url }}/assets/images/posts/2019/12/powercli-install-powercli-macos-check-powercli-modules.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2019/12/powercli-install-powercli-macos-check-powercli-modules.png)

We seem to have all the _VMware.PowerCLI_ modules that we need installed, so we should be ready to go.