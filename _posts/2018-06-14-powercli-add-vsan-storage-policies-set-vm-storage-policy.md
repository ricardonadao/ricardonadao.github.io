---
author: Ricardo Adao
published: true
post_date: 2018-06-14 02:33:26
last_modified_at: null
header:
  teaser: /assets/images/featured/powercli-150x150.png
title: PowerCLI - Add vSAN Storage Policies and Set Virtual Machine Storage Policy
categories:
  - powercli
tags:
  - coding
  - powercli
  - powershell
  - spbm
  - vcenter
  - vcf
  - vmware
  - vsan
toc: true
slug: powercli-add-vsan-storage-policies-set-virtual-machine-storage-policy
lastmod: 2023-06-21T08:14:51.358Z
---
There are multiple ways of adding extra storage policies and apply them to multiple _virtual machines_ and plenty of _VMware_ documentation and others to show how to do it.

But to reduce risk and minimize configuration drift, typically scripting/automating is the way to achieve that.

Hence we will try to quickly describe how to leverage some of the _VMware PowerCLI cmdlets_ that can do this job for us.

And the better way of doing is using an example taken from our experience.

# Objective #

* We want to setup a series of extra _vSAN Storage Policies_
* We want to change the _Storage Policy _assigned to all _Management Virtual Machines_ to one of our new _Storage Policies_
* We want a script that can scale to any number of _Storage Policies_ and _Virtual Machine Locations_

## Scenario ##

* Implementation is done via _VMware Cloud Foundation (VCF)_
* _Consolidate Cluster Design_
* _Management Virtual Machines_ are all under specific _Resource Pools_

## Script Structure ##

* _**some structures and variables**_ - that will make our life easier later if we need to scale out the script
* _**loops**_ - where we create the storage policies and assign to the virtual machines
* _**the entire script**_

### Some structure and variables ###

* Some variables with useful info that will be easier to keep on top to edit that go through the code

```powershell
# Utility variables/constants
# Locations where the vms will be and policy to assign
# - Locations - see notes in the end of the post
$vmLocations = @(
    @{ location = "X-ResourcePool" ; policy = "management" } ;
    @{ location = "Y-ResourcePool" ; policy = "raid5" }
)
# expreg with the name of the VMs that we do not want to change the assigned storage policy
$vmsToExcludeStoragePolicyChanges = "(DoNotChange_VM.*)|(NSX-Controller.*)"
```

* Our structure to define the multiple policies

```powershell
# Policy definition
$vsanPoliciesProperties = @{
    "management" = @{
        "name" = "Management VMs Storage Policy" ;
        "description" = "Used for all management vms" ;
        "rulesets" = @(
            @{
                "name" = "Rule-set 1: VSAN" ;
                "rules" = @(
                    @{ "capability" = "VSAN.hostFailuresToTolerate" ;
                       "value" = 1 } ,
                    @{ "capability" = "VSAN.replicaPreference" ;
                       "value"= "RAID-1 (Mirroring) - Performance" }
                )
            }
        )
    } ;
    "raid5" = @{
        "name" = "VM Storage Policy - RAID5" ;
        "description" = "RAID5" ;
        "rulesets" = @(
            @{
                "name"  = "Rule-set 1: VSAN" ;
                "rules" = @(
                    @{ "capability" = "VSAN.hostFailuresToTolerate" ;
                       "value" = 1 } ,
                    @{ "capability" = "VSAN.replicaPreference";
                       "value"= "RAID-5/6 (Erasure Coding) - Capacity" }
                )
            }
        )
    }
}

# List of VSAN capabilities for reference
#Get-SpbmCapability VSAN*
#Name                                     ValueCollectionType ValueType
#VSAN.cacheReservation                                        System.Int32
#VSAN.checksumDisabled                                        System.Boolean
#VSAN.forceProvisioning                                       System.Boolean
#VSAN.hostFailuresToTolerate                                  System.Int32
#VSAN.iopsLimit                                               System.Int32
#VSAN.proportionalCapacity                                    System.Int32
#VSAN.replicaPreference                                       System.String
#VSAN.stripeWidth                                             System.Int32
```

* _vsanPoliciesProperties_ structure seems a bit too much, but the idea is to give the flexibility to add more _storage policies_ if needed with a minimal change

* Example of adding one extra policy _vsanPoliciesProperties_

```powershell
...
    "newPolicy" = @{
        "name" = "VM Storage Policy - New Policy" ;
        "description" = "Im a example of a new storage policy" ;
        "rulesets" = @(
            @{
                "name"  = "Rule-set 1: VSAN" ;
                "rules" = @(
                    @{ "capability" = "VSAN.iopsLimit" ; "value" = 1000 } ,
                    @{ "capability" = "VSAN.stripeWidth" ; "value"= 2 }
                )
            }
        )
    }
....
```

### Loops ###

* There are 2 loops
  * First creating the _storage policies_ using the information from the structures described above
  * A second where we will assign the virtual machines in each location in _$vmLocations_ the respective _storage policy_

#### Creating _Storage Policies_ ####

```powershell
# Setup policies
Write-Host "=&gt; Setup vSAN storage policies &lt;=" -ForegroundColor Green
Foreach($policyName in $vsanPoliciesProperties.Keys) {
    # Get specific properties for the policy to configure
    $policyProperties = $vsanPoliciesProperties.$policyName

    # Get and create rulesets
    $ruleSets = New-Object System.Collections.ArrayList
    Foreach($ruleSet in $policyProperties.rulesets ) {
        # Create array with the rules of each ruleset
        $rules = New-Object System.Collections.ArrayList
        Foreach( $rule in $ruleSet.rules ) {
            $rules += New-SpbmRule `
               -Capability (Get-SpbmCapability -Name $rule.capability) `
               -Value $rule.value
        }
        $ruleSets += New-SpbmRuleSet -Name $ruleSet.name -AllOfRules $rules
    }
    # Create policy
    New-SpbmStoragePolicy -Name $policyProperties.name `
       -Description $policyProperties.description `
       -AnyOfRuleSets $ruleSets
}
```

#### Assigning _Storage Policies_ ####

```powershell
$clusters = Get-Cluster
Foreach($cluster in $clusters) {
    # Change VSAN storage policy for Management VMs
    Write-Host "=> Setup vSAN storage policies - $($vsanPoliciesProperties.management.name) <=" `
       -ForegroundColor Green
    # For each of the Resource Pools with Management VMs
    Foreach($vmLocation in $vmLocations) {
       # for each resourcePool
       $vms = $cluster | Get-ResourcePool -Name $vmLocation.location | Get-VM | `
          Where-Object { $_.Name -notmatch $vmsToExcludeStoragePolicyChanges}
       if($vms.Count) {
          Write-Host "==> Setup vSAN storage policies - Virtual Machines in $($vmLocation.location) - `
             Policy: $($vsanPoliciesProperties.($vmLocation.policy).name) <==" `
             -ForegroundColor Green
          # Set VMs Storage Policy
          $vms | Set-SpbmEntityConfiguration -SpbmEnabled $true `
            -StoragePolicy (Get-SpbmStoragePolicy `
            -Name ($vsanPoliciesProperties.($vmLocation.policy).name)) | `
            Select-Object Name, StoragePolicy | Format-Table -AutoSize
          # Set VMs All vDisks
          $vms | Get-HardDisk | `
          Set-SpbmEntityConfiguration -SpbmEnabled $true `
            -StoragePolicy (Get-SpbmStoragePolicy `
            -Name ($vsanPoliciesProperties.($vmLocation.policy).name)) | `
            Select-Object @{N="VM Name";E={Get-VM -Id ($_.Id).Split("/")[0]}}, Name, StoragePolicy |`
            Format-Table -AutoSize
        }
    }
}
```

### Last notes ###

* _Consolidate Cluster Design_ means that _Management Virtual Machines_ will be assigned under a _Management Resource Pool_, instead of a _Dedicated VMware Cluster_
* Will be easy to adapt the script to allow the use of any type of _Location_ besides _Resource Pools_ (something that could be covered later in another post)
* Code should have enough comments to be easy to read, however feel free to reach out if needed
* Post do not cover detailed explanation of _VMware PowerCLI cmdlets_, since _VMware_ documentation is really good, some of the links
  * [_Set-SpbmStoragePolicy_](https://pubs.vmware.com/vsphere-6-5/index.jsp?topic=%2Fcom.vmware.powercli.cmdletref.doc%2FSet-SpbmStoragePolicy.html)
  * [_Get-SpbmStoragePolicy_](https://pubs.vmware.com/vsphere-6-5/topic/com.vmware.powercli.cmdletref.doc/Get-SpbmStoragePolicy.html)
  * [_Set-SpbmStoragePolicy_](https://pubs.vmware.com/vsphere-6-5/index.jsp?topic=%2Fcom.vmware.powercli.cmdletref.doc%2FSet-SpbmStoragePolicy.html)
  * [_Get-SpbmEntityConfiguration_](https://pubs.vmware.com/vsphere-6-5/topic/com.vmware.powercli.cmdletref.doc/Get-SpbmEntityConfiguration.html)
  * [_Set-SpbmStoragePolicy_](https://pubs.vmware.com/vsphere-6-5/index.jsp?topic=%2Fcom.vmware.powercli.cmdletref.doc%2FSet-SpbmStoragePolicy.html)

## _Github_ Link for the entire script **>>** [setup.vsan.storage.policies.ps1](https://github.com/ricardonadao/vrandombites.co.uk/blob/master/vSAN/setup.vsan.storage.policies.ps1) ##
