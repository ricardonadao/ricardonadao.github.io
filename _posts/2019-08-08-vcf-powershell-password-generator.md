---
author: Ricardo Adao
published: true
post_date: 2019-08-08 21:00:00

header:
  teaser: /assets/images/featured/vcf-150x150.png
title: VCF - Powershell password generator function for VMware Cloud Foundation
categories:
  - vcf
tags:
  - vcf
  - vmware
  - coding
  - automation
  - powershell
  - sddc
toc: true
slug: vcf-powershell-password-generator-function-vmware-cloud-foundation
last_modified_at: 2023-06-21T08:14:28.253Z
---
Anyone that worked with _VMware Cloud Foundation (VCF)_ knows that passwords and _valid special characters_ can be a tricky business.

In summary, the set of _special characters_ allowed by _VCF_, is a *subset* of the ones that some of the individual products admit.

When I was developing some automation to deploy _VCF Nested Labs_ there was the need of generation some random passwords on demand instead of using the same passwords for all the _nested environments_.

After some search and some stumbling around, I found a good base to start from and to implement my own random password generator function.

[_Code based on_ **New-RandomPassword.ps1**](https://github.com/PaoloFrigo/scriptinglibrary/blob/master/Blog/PowerShell/New-RandomPassword.ps1)
{: .notice--info}

# Objective

Having a function that generates random passwords with the necessary complexity and size to use in _VCF_ deployments.

## Complexity Requirements
{: #complexity_requirements }

* Length - 8-20 characters
* At least one Uppercase, lowercase, number & special character
* Special characters allowed: _@ ! # $ % ? ^_

## Password validation _regular expression_

Generating random passwords is easy, the difficulty is in validating that password against our complexity requirements.

An _regular expression_ is probably one of the ways of doing it.

The _regexp_ used by the function and based in [*New-RandomPassword.ps1*](https://github.com/PaoloFrigo/scriptinglibrary/blob/master/Blog/PowerShell/New-RandomPassword.ps1)

```powershell
^((?=.*[a-z])(?=.*[A-Z])(?=.*[^A-Za-z0-9]))([A-Za-z\d@!#$%?^]){8,20}$
```

* The _regular expression_ validates the [_complexity requirements_](#complexity_requirements) listed above.

## Some additional randomization by making the order of the characters in _seed array_ random

To remove some of the non-valid characters from ASCII table, we create a _seed array_ to be the source of our characters for the passwords.
We shuffle the array just to get some extra _randomization_ (not that it makes an huge difference).

And we created a list of the valid chars for our password generation.

```powershell
$seedArray = (48..57) + (65..90) + (97..122) + @(33, 36, 37, 94)
$seedArray = $seedArray | Sort-Object Get-Random

$asciiCharsList = @()
foreach ($a in $seedArray){
    $asciiCharsList += , [char][byte]$a 
}
```

## Now we generate passwords based on our _character list_ until we get one valid one

```powershell
do {
        $password = ""
        $loops = 1..$length
        Foreach ($loop in $loops) {
            $password += $asciiCharsList | Get-Random
        }
    } until ($password -match $regExp )
```

## Entire function

```powershell
function New-RandomPassword {
    <#
    .SYNOPSIS
        Random Password Generator function

    .DESCRIPTION
        Random Password Generator function

    .PARAMETER length
        Length of the password to generate (defaults to 16)

    .EXAMPLE

    .NOTES
        Original code from https://github.com/PaoloFrigo/scriptinglibrary/blob/master/Blog/PowerShell/New-RandomPassword.ps1
    #>
    Param(
        [ValidateRange(8, 32)]
        [int] $length = 16
    )  

    # Add some extra randomization by creating the "seed array" randomly
    # Remove double quotes and slash and black slash
    $seedArray = (48..57) + (65..90) + (97..122) + @(33, 36, 37, 94)
    $seedArray = $seedArray | Sort-Object Get-Random

    $asciiCharsList = @()
    foreach ($a in $seedArray){
        $asciiCharsList += , [char][byte]$a 
    }
    #regExp allowing only special characters @!#$%?^ as per VCF/VMware
    $regExp = "^((?=.*[a-z])(?=.*[A-Z])(?=.*[^A-Za-z0-9]))([A-Za-z\d@!#$%?^]){8,20}$"

    do {
        $password = ""
        $loops = 1..$length
        Foreach ($loop in $loops) {
            $password += $asciiCharsList | Get-Random
        }
    } until ($password -match $regExp )

    return $password  
}
```
