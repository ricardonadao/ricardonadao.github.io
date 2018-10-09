---
layout: post
author: Ricardo Adao
published: true
post_date: 2018-10-10 00:51:00
title: Powershell - Wrapping GET and POST Rest API calls
categories: [ powershell ]
tags: [ powershell, coding, automation, vcf, vvd ]
comments: true
---
# Code Bits&Pieces and Context

This post is not an _Eureka_ moment, so do not expect any _breakthrough_ or _light bulb moment_.

However, sometimes we forgot one of the basic rules of code development that we learned or read in the past.

Typically, if we re-utilize a bit code more than 3 to 5 times, it could worth to check if that could transformed in a separate function/method to consolidate that bit of code in a single place, making it easier to update or correct if necessary, since it would be a single place to change instead of all the places where that bit was re-utilized.

Adding to that easy to understand advantage it will also be a _code refactoring_ exercise since once that function/method is created, we will be able to optimize or re-code completely that bit of code keeping if we keep the _exterior_ exactly the same.

## Using GET and POST REST API Methods as an example

As an example we can create some _wrapping functions_ to simplify the interaction with a REST API.

We will create 2 functions:

* _**Get-RestAPICall**_
  * **Method** - GET
  * **Parameters** - headers, url

* _**Post-RestAPICall**_
  * **Method** - POST
  * **Parameters** - headers, url, payload

These 2 _wrappers_ will be a way of simplifying the use of _Powershell cmdlet Invoke-RestMethod_ and even handling some of the errors/exceptions.

## Functions code

We added some error/exception handling to the functions to give the functions to make them a bit more than a _passthrough_ to the [_Invoke-RestMethod_](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/invoke-restmethod?view=powershell-6).

### Get-RestAPICall

```powershell
function Get-RestAPICall {
    param(
        [Parameter(Position=0, Mandatory = $true, ValueFromPipeline = $true)] `
            [string]$url,
        [Parameter(Position=1, Mandatory = $false, ValueFromPipeline = $true)] `
            [System.Collections.Generic.Dictionary[[String],[String]]]$headers
    )
    try {
        if ($headers) {
            $request = Invoke-RestMethod -Method GET -Headers $headers -Uri $url
        } else {
            $request = Invoke-RestMethod -Uri $url
        }
    } catch [System.Net.WebException] {
        $exceptionError = $_.Exception

        switch ($exceptionError.Response.StatusCode.value__) {
            "200"   {
                Write-Host "=> Get-RestAPICall -> OK - $url <=" `
                    -ForegroundColor Green
            }
            "400"   {
                Write-Host "=> Get-RestAPICall -> Bad Request - $url <=" `
                    -ForegroundColor Red
                $request = $null
            }
            "404"   {
                Write-Host "=> Get-RestAPICall -> Not Found - $url <=" `
                    -ForegroundColor Red
                $request = $null
            }
            "405"   {
                Write-Host "=> Get-RestAPICall -> Invalid Method - $url <=" `
                    -ForegroundColor Red
                Write-Host "=> StatusCode:" $exceptionError.Response.StatusCode.value__ `
                    -ForegroundColor Yellow
                Write-Host "=> StatusDescription:" $exceptionError.Response.StatusDescription `
                    -ForegroundColor Yellow
                Write-Host "=> Type:" $exceptionError.GetType() -ForegroundColor Yellow
                Exit
            }
            "500"   {
                Write-Host "=> Get-RestAPICall -> Internal Server Error - $url <=" `
                    -ForegroundColor Red
                Write-Host "=> StatusCode:" $exceptionError.Response.StatusCode.value__ `
                    -ForegroundColor Yellow
                Write-Host "=> StatusDescription:" $exceptionError.Response.StatusDescription `
                    -ForegroundColor Yellow
                Write-Host "=> Type:" $exceptionError.GetType() -ForegroundColor Yellow
                Exit
            }
            "503"   {
                Write-Host "=> Get-RestAPICall -> Service Unavailable - $url <=" `
                    -ForegroundColor Red
                Write-Host "=> StatusCode:" $exceptionError.Response.StatusCode.value__ `
                    -ForegroundColor Yellow
                Write-Host "=> StatusDescription:" $exceptionError.Response.StatusDescription `
                    -ForegroundColor Yellow
                Write-Host "=> Type:" $exceptionError.GetType() -ForegroundColor Yellow
                Exit
            }
            default  {
                Write-Host "=> Get-RestAPICall -> Unspecified Error - $url <=" `
                    -ForegroundColor Red
                Write-Host "=> StatusCode:" $exceptionError.Response.StatusCode.value__ `
                    -ForegroundColor Yellow
                Write-Host "=> StatusDescription:" $exceptionError.Response.StatusDescription `
                    -ForegroundColor Yellow
                Write-Host "=> Type:" $exceptionError.GetType() -ForegroundColor Yellow
                Exit
            }
        }
    }

    return $request
}
```

### Post-RestAPICall

```powershell
function Post-RestAPICall {
    param(
        [Parameter(Position=0, Mandatory = $true, ValueFromPipeline = $true)] `
            [string]$url,
        [Parameter(Position=2, Mandatory = $true, ValueFromPipeline = $true)] `
            [string]$payload,
        [Parameter(Position=3, Mandatory = $false, ValueFromPipeline = $true)] `
            [System.Collections.Generic.Dictionary[[String],[String]]]$headers
    )
    # Load constants
    . "$PSScriptRoot\..\shared\shared.constants.ps1"

    try {
        if ($headers) {
            $request = Invoke-RestMethod -Method POST -Headers $headers -Body $payload -Uri $url
        } else {
            $request = Invoke-RestMethod -Body $payload -Uri $url
        }
    } catch [System.Net.WebException] {
        $exceptionError = $_.Exception

        switch ($exceptionError.Response.StatusCode.value__) {
            "200"   {
                Write-Host "=> Post-RestAPICall -> OK - $url <=" -ForegroundColor Green
            }
            "400"   {
                Write-Host "=> Post-RestAPICall -> Bad Request - $url <=" -ForegroundColor Red
                $request = $null
            }
            "500"   {
                Write-Host "=> Post-RestAPICall -> Internal Server Error - $url <=" `
                    -ForegroundColor Red
                Write-Host "=> StatusCode:" $exceptionError.Response.StatusCode.value__ `
                    -ForegroundColor Yellow
                Write-Host "=> StatusDescription:" $exceptionError.Response.StatusDescription `
                    -ForegroundColor Yellow
                Write-Host "=> Type:" $exceptionError.GetType() -ForegroundColor Yellow
                Exit
            }
            default  {
                Write-Host "=> Post-RestAPICall -> Unspecified Error - $url <=" `
                    -ForegroundColor Red
                Write-Host "=> StatusCode:" $exceptionError.Response.StatusCode.value__ `
                    -ForegroundColor Yellow
                Write-Host "=> StatusDescription:" $exceptionError.Response.StatusDescription `
                    -ForegroundColor Yellow
                Write-Host "=> Type:" $exceptionError.GetType() -ForegroundColor Yellow
                Exit
            }
        }
    }

    return $request
}
```

## Examples

Examples how to use the newly defined functions.

The examples below are part of a future post where these _wrapping functions_ will be used to interact with the [_VMware Cloud Foundation(VCF)_](https://docs.vmware.com/en/VMware-Cloud-Foundation/index.html) _bringup appliance_ API, to automate the deployment of a _VMware cluster_, following the _Consolidated Architecture Model_ defined in the [_VMware Validated Designs (VVD)_](https://docs.vmware.com/en/VMware-Validated-Design/index.html).

### Get-RestAPICall

In this example we are just making a quick _GET call_ to the _VCF bringup service_ to check the service version.

```powershell
$url = "http://localhost:9080/bringup-app/bringup/about"
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Content-Type" , "application/json")

if (($request = Get-RestAPICall -url $url -headers $headers).name -notmatch "BRINGUP") {
    Write-Host "--> bringup - Bringup service is not UP <--" -ForegroundColor Red
    Exit
} else {
    Write-Host "--> bringup - Bringup service is UP and running <--" -ForegroundColor Green
    Write-Host "--> bringup - $($request.name) - $($request.serviceId) - $($request.version) <--" -ForegroundColor Green
}
```

### Post-RestAPICall

This example will be a _POST call_ and will require some extra headers and a _payload_.
The extra headers is to specify that the _payload_ will be in _JSON format_.
The _payload_ will be a _JSON_ with all the information needed by the _VCF bringup service_  to deploy the _VMware cluster_.

```powershell
$url = "http://localhost:9080/bringup-app/bringup/sddcs"
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Content-Type" , "application/json")
$headers.Add("Content-Accept" , "application/json")

$request = Post-RestAPICall -url $url -headers $headers -payload $vpodJSON
$bringupId = $request.id
```