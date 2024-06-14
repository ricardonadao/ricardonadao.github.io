---
author: Ricardo Adao
published: true
date: 2018-07-02 09:23:49

header:
  teaser: /assets/images/featured/powercli-150x150.png
title: PowerCLI - Configure multiple ESXi Power Policy
categories:
  - powercli
tags:
  - coding
  - powercli
  - esxi
  - powershell
  - vcenter
  - vmware
  - powersaving
toc: true
slug: powercli-configure-multiple-esxi-power-policy
last_modified_at: 2023-06-21T08:14:49.979Z
---

This is a quick powershell script that setups up ESXi _Power Policies_ in all the hosts in a cluster or vCenter.

# Script Parameters #

* **Mandatory**
  * _**vCenter**_ >> vCenter FQDN/IP to connect too
  * _**vCenterUsername**_ >> vCenter Username
  * _**vCenterPassword**_ >> corresponding password
  * _**powerProfile**_ >> _Power Profile_ config to use:
    * _High Performance_
    * _Balanced_
    * _Low Power_
    * _Custom_

* **Optional**
  * _**cluster**_ >> Cluster name if we want to change the hosts from a single cluster

## The code is pretty simple, but it worth to point out the relevant parts of it ##

* _Hash Table_ to adapt/translate the common name of the _Power Policies_ to the right value needed by the _ConfigurePowerPolicy method_

```powershell
# Keys for the values needed for the ConfigurePowerPolicy method
$powerProfiles =  @{
    "High Performance" = 1 ;
    "Balanced"         = 2 ;
    "Low Power"        = 3 ;
    "Custom"           = 4
}
```

* List the current status

```powershell
$currentState = $vmHosts | Sort-Object $_.Name| `
 Select Name,@{ N="CurrentPolicy"; `
    E={$_.ExtensionData.config.PowerSystemInfo.CurrentPolicy.ShortName}}, `
    @{ N="CurrentPolicyKey"; `
      E={$_.ExtensionData.config.PowerSystemInfo.CurrentPolicy.Key}}, `
    @{ N="AvailablePolicies"; `
    E={$_.ExtensionData.config.PowerSystemCapability.AvailablePolicy.ShortName}}

 $currentState | Format-Table -AutoSize
 ```

* Change effectively the _Power Policy_

```powershell
# Set the PowerProfile to the desired state
(Get-View ($vmHosts | `
    Get-View).ConfigManager.PowerSystem).ConfigurePowerPolicy($powerProfiles.$powerProfile)
```

### _Github_ Link for the entire script **>>** [set.esxi.power.settings.ps1](https://github.com/ricardonadao/vrandombites.co.uk/blob/master/ESXi/set.esxi.power.settings.ps1) ###