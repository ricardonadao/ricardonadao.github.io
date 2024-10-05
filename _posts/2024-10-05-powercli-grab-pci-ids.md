---
author: Ricardo Adao
published: true
header:
  teaser: /assets/images/featured/powercli-150x150.png
title: PowerCLI - Collect PCI IDs, Vendor IDs and other IDs from ESXi Hardware to compare with HCL
categories:
  - powercli
tags:
  - coding
  - esxi
  - hypervisor
  - powercli
  - powershell
  - vmware
  - pci
slug: powercli-collect-pci-ids-vendor-ids-ids-esxi-hardware-compare-hcl
last_modified_at: null
date: 2024-10-05T15:53:10.650Z
toc: true
draft: false
mathjax: false
---
Sometimes we need to quickly grab some of the IDs from ESXi hardware components to compare them with the right item in the [VMware HCLs](https://www.vmware.com/resources/compatibility/search.php).

In my specific case, I needed to get the IDs to check the Network drivers and firmware versions:

[![VMware HCL IO Compabitility List]({{ relative_url }}/assets/images/posts/2024/10/powercli-grab-pci-ids-pic01.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2024/10/powercli-grab-pci-ids-pic01.png)

But the quick script has the option to collect more than just the Network cards, by updating the list named _**deviceClassNamesList**_:

```powershell
$deviceClassNamesList = @("Ethernet")
```

If you want to collect info for some other type of devices you just need to add the string that you are looking from the field/property _DeviceClassName_, for example list also for _SATA controllers_:

```powershell
$deviceClassNamesList = @("Ethernet", "SATA")
```

## Script input file

To make my life easier we use a _CSV_ file as the input, to allow the collection of info across multiple vCenters and multiple vSphere clusters.

| vcenter | cluster |
|-----------|-----------|
| xyz.local | cluster01 |
| abc.local | cluster00 |
| xyz.local | cluster02 |

Input file that would match the above table will be:

```powershell
vcenter,cluster
xyz.local,cluster01
abc.local,cluster00
xyz.local,cluster02
```

There are some _optimisations_ in the script to try to re-use the same _vCente_ connection as much as possible. That will affect the output since info could be in a different order compared to the input file order.
The assumption is that the user account used to login in the _vCenter_ is the same across all the _vCenters_ in the list, but is not much of a stretch to adapt the script to start asking credentials for each new connection, would be just the matter of moving the _get credentials section_ to right before the new _vCenter_ connection.

## Some editable parameters on the script

At the top of the script there are a couple of _variables_ that can be edited to:

* manage the input/output filenames
* some formatting options, because of some differences of how _MacOS_ and _Microsoft Windows_ handle the CSV files
* _DeviceClassNames_ to retrieve info for

```powershell
$csvInputFilename = "cluster_list.csv"
$csvOutputFilename = "esxi_nics_pci-info.csv"
$csvDelimiter = ","

$deviceClassNamesList = @("Ethernet")
```

## The information that we are trying to collect

The info that we want to collect is the info that we can collect by login in to an _ESXi Host_ and run:

* `lspci -v`  
 [![lspci output]({{ relative_url }}/assets/images/posts/2024/10/powercli-grab-pci-ids-pic02.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2024/10/powercli-grab-pci-ids-pic02.png)
* `esxcli hardware pci list`  
 [![esxcli hardware pci list output]({{ relative_url }}/assets/images/posts/2024/10/powercli-grab-pci-ids-pic03.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2024/10/powercli-grab-pci-ids-pic03.png)

## The script

```powershell
$csvInputFilename = "cluster_list.csv"
$csvOutputFilename = "esxi_nics_pci-info.csv"

$csvDelimiter = ","

$deviceClassNamesList = @("Ethernet")

# Edit at your own risk from this point ;)

#Add Credentials
Write-Host "-> vCenter Credentials: $vcenter" -ForegroundColor Red
$credentials = Get-Credential

# Import CSV
if ($csvDelimiter -eq "") {
    $csvDelimiter = ","
}
Write-Host "> Import CSV Delimiter: $($csvDelimiter)" -ForegroundColor DarkGreen
Write-Host "> Input CSV File: $($csvInputFilename)" -ForegroundColor DarkGreen
Write-Host "> Output CSV File: $($csvOutputFilename)" -ForegroundColor DarkGreen
Write-Host "> DeviceClassNamesList: $($deviceClassNamesList)`n" -ForegroundColor DarkGreen

$esxiToCollectInfo = Import-CSV -Delimiter "$($csvDelimiter)" $csvInputFilename | Sort-Object { $_.vcenter }

$currentVCenter = $null
$vcenterSession = $null
$dataReport = @()

foreach($object in $esxiToCollectInfo) {
    if($object.vcenter -ne $currentvCenter) {
        if($currentVCenter) {
            Write-Host "---> Disconnect vCenter: $($currentVCenter) - Disconnect before Connect to vCenter: $($object.vcenter)" -ForegroundColor Magenta
            Disconnect-VIServer $vcenterSession -Confirm
        }
        $currentVCenter = $object.vcenter
        Write-Host "--> Connect vCenter: $($currentVCenter)" -ForegroundColor Cyan
        $vcenterSession = Connect-VIServer -Server $currentVCenter -Credential $credentials
    }

    Write-Host "---> Get Hosts from cluster: $($object.cluster)" -ForegroundColor DarkCyan
    $esxiHosts = Get-Cluster $object.cluster | Get-VMHost

    foreach ($esxi in $esxiHosts) {
        Write-Host "----> Get info from host: $($esxi.Name)" -ForegroundColor Green
        $esxcli = Get-EsxCli -VMHost $esxi -V2
        $pciNicInfo = $esxcli.hardware.pci.list.Invoke()| Where-Object { $_.DeviceClassName | Select-String -Pattern $deviceClassNamesList }
        foreach ($nicInfo in $pciNicInfo) {
            # Prepare object for CSV
            $reportObj = [PSCustomObject]@{
                VCenter             = $currentVCenter
                Cluster             = $object.cluster
                HostName            = $esxi.Name
                DeviceName          = $nicInfo.DeviceName
                DeviceClassName     = $nicInfo.DeviceClassName
                ModuleName          = $nicInfo.ModuleName
                NUMANode            = $nicInfo.NUMANode
                VendorName          = $nicInfo.VendorName
                VendorID            = $nicInfo.VendorID
                DeviceID            = $nicInfo.DeviceID
                SubVendorID         = $nicInfo.SubVendorID
                SubDeviceID         = $nicInfo.SubDeviceID
            }
            # Add the object to the report array
            $dataReport += $reportObj
        }
    }
    $dataReport | Export-Csv -Path $csvOutputFilename -NoTypeInformation -UseCulture 
}

if($currentVCenter) {
    Write-Host "--> Disconnect vCenter: $($currentVCenter) - END" -ForegroundColor Magenta
    Disconnect-VIServer $vcenterSession -Confirm
} else {
    Write-Host "-> Disconnect from all vCenters" -ForegroundColor Red
    Disconnect-VIServer * -Confirm
}
```

### Output

* Script run  
  [![script run]({{ relative_url }}/assets/images/posts/2024/10/powercli-grab-pci-ids-pic04.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2024/10/powercli-grab-pci-ids-pic04.png)
* Output File Result  
  ```Powershell
  "VCenter","Cluster","HostName","DeviceName","DeviceClassName","ModuleName","NUMANode","VendorName","VendorID","DeviceID","SubVendorID","SubDeviceID"
  "vcenter.xxxx","Main Cluster","esx01.xxxx","Xeon E7 v4/Xeon E5 v4/Xeon E3 v4/Xeon D Crystal Beach DMA Channel 7","System peripheral","None","0","Intel Corporation","32902","28455","5593","2100"
  "vcenter.xxxx","Main Cluster","esx01.xxxx","I350 Gigabit Network Connection","Ethernet controller","igbn","0","Intel Corporation","32902","5409","5593","5409"
  ```