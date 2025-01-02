##################################################################
#
# Automate Setup of the vSAN storage policies for post-VCF config
#
##################################################################
<#
.SYNOPSIS
    Automate Setup of the vSAN storage policies

.DESCRIPTION
    Create vSAN storage policies

.PARAMETER vcenter
Specifies FQDN/IP of the vCenter

.PARAMETER vcenterUsername
Specifies username to use to login to the vCenter

.PARAMETER vcenterPassword
Specifies password for vCenterUsername (passed encrypted as a parameter or leave it blank to be asked)

.EXAMPLE
    C:\PS> 
    . setup.vsan.storage.policies.ps1
.NOTES
    Author: Ricardo Adao
    Date:   Jun 12, 2018
#>

param(
    [Parameter(Position=1, Mandatory = $true, ValueFromPipeline = $true)] [string]$vcenter,
    [Parameter(Position=2, Mandatory = $true, ValueFromPipeline = $true)] [string]$vcenterUsername,
    [Parameter(Position=3, Mandatory = $true, ValueFromPipeline = $true)] [System.Security.SecureString]$vcenterPassword
)

# Utility variables/constants
# Locations where the vms will be and policy to assign
# - Locations here are ResourcePools, since the script was done with a VCF Consolidated Cluster design implementation
# - Code can be easily adapted to change the "locations" to be any relevant object parent of vms
$vmLocations = @(
    @{
        location = "X-ResourcePool" ;
        policy   = "management"
    } ; 
    @{
        location = "Y-ResourcePool" ;
        policy   = "raid5"
    }
)

# expreg with the name of the VMs that we do not want to change the assigned storage policy
$vmsToExcludeStoragePolicyChanges = "(DoNotChange_VM.*)|(NSX-Controller.*)"

# List of VSAN capabilities
#PS C:\Users\rica5203\Documents> Get-SpbmCapability VSAN*
#Name                                     ValueCollectionType ValueType
#----                                     ------------------- ---------
#VSAN.cacheReservation                                        System.Int32
#VSAN.checksumDisabled                                        System.Boolean
#VSAN.forceProvisioning                                       System.Boolean
#VSAN.hostFailuresToTolerate                                  System.Int32
#VSAN.iopsLimit                                               System.Int32
#VSAN.proportionalCapacity                                    System.Int32
#VSAN.replicaPreference                                       System.String
#VSAN.stripeWidth                                             System.Int32

# Policy definition
$vsanPoliciesProperties = @{
    "management" = @{
        "name"        = "Management VMs Storage Policy" ;
        "description" = "Used for all management vms" ;
        "rulesets"    = @(
            @{
                "name"  = "Rule-set 1: VSAN" ;
                "rules" = @(
                    @{
                        "capability" = "VSAN.hostFailuresToTolerate" ;
                        "value"      = 1
                    } ,
                    @{
                        "capability" = "VSAN.replicaPreference" ;
                        "value"      = "RAID-1 (Mirroring) - Performance"
                    }
                )
            }
        )
    } ;
    "raid5" = @{
        "name"        = "VM Storage Policy - RAID5" ;
        "description" = "RAID5" ;
        "rulesets"    = @(
            @{
                "name"  = "Rule-set 1: VSAN" ;
                "rules" = @(
                    @{
                        "capability" = "VSAN.hostFailuresToTolerate" ;
                        "value"      = 1
                    } ,
                    @{
                        "capability" = "VSAN.replicaPreference" ;
                        "value"      = "RAID-5/6 (Erasure Coding) - Capacity"
                    }
                )
            }
        )
    }
}

# Main Body

# Connect to vCenter
if (!($vcenterConnection = Connect-VIServer  -Server $vcenter -User $vcenterUsername -Password ([System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($vcenterPassword))) -ErrorAction SilentlyContinue)) { #DevSkim: ignore DS104456 
$exceptionError = $Error[0]
switch ($exceptionError.CategoryInfo.Category) {
    "ObjectNotFound" {
        switch ($exceptionError.CategoryInfo.Reason) {
            "ViServerConnectionException" {
                Write-Host "=> setup.vsan.policies -> vCenter not found - $vcenter <=" -ForegroundColor Red
            }
            default {
                Write-Host "=> setup.vsan.policies -> ObjectNotFound - Default - vcenter: $vcenter <=" -ForegroundColor Red
            }
        }
        Write-Host "=> Error Category:" $exceptionError.CategoryInfo.Category -ForegroundColor Yellow
        Write-Host "=> Error Message:" $exceptionError.Message -ForegroundColor Yellow
        Write-Host ""
        Exit
    }
    "NotSpecified" {
        switch ($exceptionError.CategoryInfo.Reason) {
            "InvalidLogin" {
                Write-Host "=> setup.vsan.policies -> Invalid Credentials - vcenter: $vcenter - username: $username <=" -ForegroundColor Red
            }
            default {
                Write-Host "=> setup.vsan.policies -> NotSpecified - Default - vcenter: $vcenter <=" -ForegroundColor Red
            }
        }
        Write-Host "=> Error Category:" $exceptionError.CategoryInfo.Category -ForegroundColor Yellow
        Write-Host "=> Error Reason:" $exceptionError.CategoryInfo.Reason -ForegroundColor Yellow
        Write-Host "=> Error Message:" $exceptionError.Exception.Message -ForegroundColor Yellow
        Exit
    }

    default {
        Write-Host "=> setup.vsan.policies -> Default - $vcenter <=" -ForegroundColor Red
        Write-Host "=> Error Category:" $exceptionError.CategoryInfo.Category -ForegroundColor Yellow
        Write-Host "=> Error Reason:" $exceptionError.CategoryInfo.Reason -ForegroundColor Yellow
        Write-Host "=> Error Message:" $exceptionError.Exception.Message -ForegroundColor Yellow
        Exit
    }
}
}

# Setup policies
Write-Host "=> Setup vSAN storage policies <=" -ForegroundColor Green
Foreach($policyName in $vsanPoliciesProperties.Keys) {
    # Get specific properties for the policy to configure
    $policyProperties = $vsanPoliciesProperties.$policyName

    # Get and create rulesets
    $ruleSets = New-Object System.Collections.ArrayList
    Foreach($ruleSet in $policyProperties.rulesets ) {
        # Create array with the rules of each ruleset
        $rules = New-Object System.Collections.ArrayList
        Foreach( $rule in $ruleSet.rules ) {
            $rules += New-SpbmRule -Capability (Get-SpbmCapability -Name $rule.capability) -Value $rule.value
        }
        $ruleSets += New-SpbmRuleSet -Name $ruleSet.name -AllOfRules $rules
    }
    # Create policy
    New-SpbmStoragePolicy -Name $policyProperties.name -Description $policyProperties.description -AnyOfRuleSets $ruleSets
}

$clusters = Get-Cluster
Foreach($cluster in $clusters) {
    
    # Change VSAN storage policy for Management VMs
    Write-Host "=> Setup vSAN storage policies - $($vsanPoliciesProperties.management.name) <=" -ForegroundColor Green

    # For each of the Resource Pools with Management VMs
    Foreach($vmLocation in $vmLocations) {
        # for each resourcePool
        $vms = $cluster | Get-ResourcePool -Name $vmLocation.location | Get-VM | Where-Object { $_.Name -notmatch $vmsToExcludeStoragePolicyChanges}
        if($vms.Count) {
            Write-Host "==> Setup vSAN storage policies - Virtual Machines in $($vmLocation.location) - Policy: $($vsanPoliciesProperties.($vmLocation.policy).name) <==" -ForegroundColor Green
            # Set VMs Storage Policy
            $vms | Set-SpbmEntityConfiguration -SpbmEnabled $true -StoragePolicy (Get-SpbmStoragePolicy -Name ($vsanPoliciesProperties.($vmLocation.policy).name)) | `
            Select-Object Name, StoragePolicy | Format-Table -AutoSize
            # Set VMs All vDisks
            $vms | Get-HardDisk | `
            Set-SpbmEntityConfiguration -SpbmEnabled $true -StoragePolicy (Get-SpbmStoragePolicy -Name ($vsanPoliciesProperties.($vmLocation.policy).name)) | `
            Select-Object @{N="VM Name";E={Get-VM -Id ($_.Id).Split("/")[0]}}, Name, StoragePolicy | Format-Table -AutoSize
        }
    }
}

Disconnect-viserver -Server $vcenter -Confirm:$false -ErrorAction SilentlyContinue