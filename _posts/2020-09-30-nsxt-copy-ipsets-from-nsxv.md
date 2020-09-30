---
author: Ricardo Adao
published: true
post_date: 2020-09-30 23:30:00  
last_modified_at:
header:
  teaser: /assets/images/featured/nsx-150x150.png
title: NSX-T Data Center - Using Powershell/PowerCLI to copy/migrate NSX-V IPSets to NSX-T Groups
categories: [ nsx ]
tags: [ nsx-t, nsx, nsx-v, powercli, powershell, powernsx, VtoT, vmware, migration]
toc: true
---
When moving from _NSX-V_ to _NSX-T_ there is the option of using the _NSX-T Migration Coordinator_, however sometimes our _NSX-V_ configuration cannot fit the ones supported by the migration coordinator.
With this in mind there are a couple of options to migrate/copy our customized _NSX-V_ objects to _NSX-T_:

* Manually create them in our _NSX-T_ setup
* Use existing 3rd party tools, as an example [_ReSTNSX - NSX-T Migration Made Easy (MAT)_](https://restnsx.com/mat/)
* Script/develop something to leverage _NSX-V_ and _NSX-T_ APIs

In my case, since I had a decent amount of objects to copy and 1st and 2nd option were not an option, I end up scripting the process using _Powershell/PowerCLI_.

This particular post will focus in copy/migrate all our _NSX-V IPSets_ objects, and more specific in the interaction with the _NSX-T API_ side, since for _NSX-V_ we will leverage [_PowerNSX Powershell module_](https://powernsx.github.io/).

## Retrieving _NSX-V_ IPSets

We need to get the _NSX-V IPSets_ from our _NSX-V_ environment.

As we mentioned we will leverage [_PowerNSX module_](https://powernsx.github.io/) to interact with our _NSX-V Manager_.

```powershell
Get-NSXIpSet
```

[![Get-NSXIpSet]({{ site.url }}/assets/images/posts/2020/09/nsxt-migrating-ipsets-from-nsxv-getnsxipset.png){:class="img-responsive"}]({{ site.url }}/assets/images/posts/2020/09/nsxt-migrating-ipsets-from-nsxv-getnsxipset.png)

At this point we can export the result to a csv file or just use the result to proceed with the creation of the _NSX-T Groups_.

## Running some GET calls using [_Postman REST Client_](https://www.postman.com/) to check the _NSX-T Group_ object

The easy way to check the structure would be to create a couple of _NSX-T Groups_ with the content that we would have.

On this post we are only focused in the _NSX-T Groups_ that contain IP, IP Ranges and IP Networks, since our focus is to copy/migrate our _NSX-V IPSets_ to _NSX-T Groups_.

We can use _Powershell_ to query _NSX-T API_, but to check the object we will just use [_Postman REST Client_](https://www.postman.com/).

* To get all the existing _NSX-T Groups_ we can use:

    [`GET https://<nsx-t manager>/policy/api/v1/infra/domains/default/groups/`](https://vdc-download.vmware.com/vmwb-repository/dcr-public/ec5a04ad-00be-4362-9092-7e934609879b/0c127b7e-6d1f-4730-a6db-5f52cba4daf5/api_includes/method_ListGroupForDomain.html)

* Once we know what are our groups we can check their structure:

    [`GET https://<nsx-t manager>/policy/api/v1/infra/domains/default/groups/<group_id>`](https://vdc-download.vmware.com/vmwb-repository/dcr-public/ec5a04ad-00be-4362-9092-7e934609879b/0c127b7e-6d1f-4730-a6db-5f52cba4daf5/api_includes/method_ReadGroupForDomain.html)

Some _NSX-T Groups_ examples created:

**NSXT-IPGROUP-01** |
|-------------------|-------------------|
[![NSXT-IPGROUP-01 - NSX-T]({{ site.url }}/assets/images/posts/2020/09/nsxt-migrating-ipsets-from-nsxv-nsxt-ipgroup01-nsxt-example.png){:class="img-responsive"}]({{ site.url }}/assets/images/posts/2020/09/nsxt-migrating-ipsets-from-nsxv-nsxt-ipgroup01-nsxt-example.png) | [![NSXT-IPGROUP-01 - JSON]({{ site.url }}/assets/images/posts/2020/09/nsxt-migrating-ipsets-from-nsxv-nsxt-ipgroup01-json-example.png){:class="img-responsive"}]({{ site.url }}/assets/images/posts/2020/09/nsxt-migrating-ipsets-from-nsxv-nsxt-ipgroup01-json-example.png)

**NSXT-IPGROUP-02** |
|-------------------|-------------------|
[![NSXT-IPGROUP-02 - NSX-T]({{ site.url }}/assets/images/posts/2020/09/nsxt-migrating-ipsets-from-nsxv-nsxt-ipgroup02-nsxt-example.png){:class="img-responsive"}]({{ site.url }}/assets/images/posts/2020/09/nsxt-migrating-ipsets-from-nsxv-nsxt-ipgroup02-nsxt-example.png) | [![NSXT-IPGROUP-02 - JSON]({{ site.url }}/assets/images/posts/2020/09/nsxt-migrating-ipsets-from-nsxv-nsxt-ipgroup02-json-example.png){:class="img-responsive"}]({{ site.url }}/assets/images/posts/2020/09/nsxt-migrating-ipsets-from-nsxv-nsxt-ipgroup02-json-example.png)

**NSXT-IPGROUP-03** |
|-------------------|-------------------|
[![NSXT-IPGROUP-03 - NSX-T]({{ site.url }}/assets/images/posts/2020/09/nsxt-migrating-ipsets-from-nsxv-nsxt-ipgroup03-nsxt-example.png){:class="img-responsive"}]({{ site.url }}/assets/images/posts/2020/09/nsxt-migrating-ipsets-from-nsxv-nsxt-ipgroup03-nsxt-example.png) | [![NSXT-IPGROUP-03 - JSON]({{ site.url }}/assets/images/posts/2020/09/nsxt-migrating-ipsets-from-nsxv-nsxt-ipgroup03-json-example.png){:class="img-responsive"}]({{ site.url }}/assets/images/posts/2020/09/nsxt-migrating-ipsets-from-nsxv-nsxt-ipgroup03-json-example.png)

**NSXT-IPGROUP-04** |
|-------------------|-------------------|
[![NSXT-IPGROUP-04 - NSX-T]({{ site.url }}/assets/images/posts/2020/09/nsxt-migrating-ipsets-from-nsxv-nsxt-ipgroup04-nsxt-example.png){:class="img-responsive"}]({{ site.url }}/assets/images/posts/2020/09/nsxt-migrating-ipsets-from-nsxv-nsxt-ipgroup04-nsxt-example.png) | [![NSXT-IPGROUP-04 - JSON]({{ site.url }}/assets/images/posts/2020/09/nsxt-migrating-ipsets-from-nsxv-nsxt-ipgroup04-json-example.png){:class="img-responsive"}]({{ site.url }}/assets/images/posts/2020/09/nsxt-migrating-ipsets-from-nsxv-nsxt-ipgroup04-json-example.png)

From the _JSON_ output it seems that for our object the important fields would be:

* **expression** - will have our object content
* **display_name** - how it will appear in UI
* **id** - our object id to use for our API calls

**NSXT-IPGROUP-03**        | **NSXT-IPGROUP-04**
|-------------------|-------------------|
[![NSXT-IPGROUP-03 - Relevant Fields]({{ site.url }}/assets/images/posts/2020/09/nsxt-migrating-ipsets-from-nsxv-nsxt-ipgroup03-fields.png){:class="img-responsive"}]({{ site.url }}/assets/images/posts/2020/09/nsxt-migrating-ipsets-from-nsxv-nsxt-ipgroup03-fields.png)  |  [![NSXT-IPGROUP-04 - Relevant Fields]({{ site.url }}/assets/images/posts/2020/09/nsxt-migrating-ipsets-from-nsxv-nsxt-ipgroup04-fields.png){:class="img-responsive"}]({{ site.url }}/assets/images/posts/2020/09/nsxt-migrating-ipsets-from-nsxv-nsxt-ipgroup04-fields.png)

## Building our foundation for our script

### How can we get the list of all existing _NSX-T Groups_

To retrieve all the configured groups we will use the following _API Call_ as mentioned previously:

[`GET https://<nsx-t manager>/policy/api/v1/infra/domains/default/groups/`](https://vdc-download.vmware.com/vmwb-repository/dcr-public/ec5a04ad-00be-4362-9092-7e934609879b/0c127b7e-6d1f-4730-a6db-5f52cba4daf5/api_includes/method_ListGroupForDomain.html)

```powershell
$urlGetGroups = "https://$nsxtManager/policy/api/v1/infra/domains/default/groups/"

$nsxtGroups = Invoke-RestMethod -Uri $urlGetGroups `
  -Authentication Basic -Credential $nsxtManagerCredentials `
  -Method Get -ContentType "application/json" `
  -SkipCertificateCheck
```

This will give us the list of all the existing _NSX-T Groups_:

```powershell
$nsxtGroups.results.display_name

  NSXT-IPGROUP-01
  NSXT-IPGROUP-02
  NSXT-IPGROUP-03
  NSXT-IPGROUP-04
```

### How can we get a specific _NSX-T Group_ using the _Group Name_

As we show before there is two (2) ids for the same object in _NSX-T_:

* _display name_ - Name that shows up in the _NSX-T Manager UI_, this ID do not need to be unique, hence you can have two (2) objects with the same name
* _id_           - unique object ID, hence the preferred ID to use in _API calls_

A quick example:

NSX-T Manager UI ID | NSX-T Object ID
|-------------------|------------------|
[![NSX-T Manager Duplicate ID]({{ site.url }}/assets/images/posts/2020/09/nsxt-migrating-ipsets-from-nsxv-nsxt-ip-group-nsxt-manager-duplicate-id-example.png){:class="img-responsive"}]({{ site.url }}/assets/images/posts/2020/09/nsxt-migrating-ipsets-from-nsxv-nsxt-ip-group-nsxt-manager-duplicate-id-example.png) | [![NSX-T API Unique ID]({{ site.url }}/assets/images/posts/2020/09/nsxt-migrating-ipsets-from-nsxv-nsxt-ip-group-nsxt-manager-api-id-example.png){:class="img-responsive"}]({{ site.url }}/assets/images/posts/2020/09/nsxt-migrating-ipsets-from-nsxv-nsxt-ip-group-nsxt-manager-api-id-example.png)

**Quick tip**: if you need to get the _API_ url for the object you can get it from _NSX-T Manager UI_ by right clicking in the _Group Object_ elipses:
 [![Getting API Object URL]({{ site.url }}/assets/images/posts/2020/09/nsxt-migrating-ipsets-from-nsxv-nsxt-ip-group-nsxt-manager-right-click.png){:class="img-responsive"}]({{ site.url }}/assets/images/posts/2020/09/nsxt-migrating-ipsets-from-nsxv-nsxt-ip-group-nsxt-manager-right-click.png)
{:.notice--info}

Let us check the result:

[`GET https://<nsx-t manager>/policy/api/v1/infra/domains/default/groups/<GroupObject ID>`](https://vdc-download.vmware.com/vmwb-repository/dcr-public/ec5a04ad-00be-4362-9092-7e934609879b/0c127b7e-6d1f-4730-a6db-5f52cba4daf5/api_includes/method_DeleteGroup.html)

```powershell
$groupObjectID = "NSXT-IPGROUP-04"
$urlGetGroup = "https://$nsxtManager/policy/api/v1/infra/domains/default/groups/$groupObjectID"

$nsxtGroup = Invoke-RestMethod -Uri $urlGetGroup `
  -Authentication Basic -Credential $nsxtManagerCredentials `
  -Method Get -ContentType "application/json" `
  -SkipCertificateCheck
```

Let us check our _NSX-T Group_ details:

```powershell
> $nsxtGroup

  expression          : {@{ip_addresses=System.Object[]; resource_type=IPAddressExpression; marked_for_delete=False; _protection=NOT_PROTECTED}}
  resource_type       : Group
  id                  : NSXT-IPGROUP-04
  display_name        : NSXT-IPGROUP-04
  path                : /infra/domains/default/groups/NSXT-IPGROUP-04
  relative_path       : NSXT-IPGROUP-04
  parent_path         : /infra/domains/default
  marked_for_delete   : False
  _create_user        : admin
  _create_time        : 1601038849793
  _last_modified_user : admin
  _last_modified_time : 1601038849793
  _system_owned       : False
  _protection         : NOT_PROTECTED
  _revision           : 0

> $nsxtGroup.expression

  ip_addresses                                                     resource_type       marked_for_delete _protection
  ------------                                                     -------------       ----------------- -----------
  {100.100.104.1, 100.100.104.0/24, 100.100.104.10-100.100.104.15} IPAddressExpression             False NOT_PROTECTED
```

### How to check if the _NSX-T Group_ that we want to create already exists to avoid duplicates

At this point we have two (2) alternatives:

* We create our new _NSX-T Groups_ without checking, either because we know that they do not exist or just because we do not mind to have duplicates
* We create. update or replace the _NSX-T Groups_ depending on their existence or not in the target environment

We will follow the second approach, since we want to keep our environment tidy and because it will add an extra challenge.

Since the _Object IDs_ will be different for sure, since we are copying our _NSX-V IPSets_, we will need to use the _IPSet Object Name_ as our common ID between our two (2) environments.

Hence, our search in the current _NSX-T Groups_ list will be done using the _display\_name_ instead of its _unique id_ and once we get our _NSX-T Group_ we can get our _unique id_ to use in our API calls:

```powershell
> $nsxtGroup = $nsxtGroups.results | Where-Object { $_.display_name -eq "NSXT-IPGROUP-04" }

  expression          : {@{ip_addresses=System.Object[]; resource_type=IPAddressExpression; marked_for_delete=False; _protection=NOT_PROTECTED}}
  resource_type       : Group
  id                  : NSXT-IPGROUP-04
  display_name        : NSXT-IPGROUP-04
  path                : /infra/domains/default/groups/NSXT-IPGROUP-04
  relative_path       : NSXT-IPGROUP-04
  parent_path         : /infra/domains/default
  marked_for_delete   : False
  _create_user        : admin
  _create_time        : 1601038849793
  _last_modified_user : admin
  _last_modified_time : 1601038849793
  _system_owned       : False
  _protection         : NOT_PROTECTED
  _revision           : 0

> $nsxtGroup.id

  NSXT-IPGROUP-04
```

### How to create a new _NSX-T Group_ 

When we use the _NSX-T Policy API_ we can either use `PUT` or `PATCH` depending if you are creating an object or updating an existing object.

[`PUT /policy/api/v1/infra/domains/<domain-id>/groups/<group-id>`](https://vdc-download.vmware.com/vmwb-repository/dcr-public/ec5a04ad-00be-4362-9092-7e934609879b/0c127b7e-6d1f-4730-a6db-5f52cba4daf5/api_includes/method_UpdateGroupForDomain.html)

[`PATCH /policy/api/v1/infra/domains/<domain-id>/groups/<group-id>`](https://vdc-download.vmware.com/vmwb-repository/dcr-public/ec5a04ad-00be-4362-9092-7e934609879b/0c127b7e-6d1f-4730-a6db-5f52cba4daf5/api_includes/method_PatchGroupForDomain.html)

A quick reference to a _VMware blog_ post with a nice table explaining the available HTTP "Verbs"/Methods in )_NSX-T Policy API_:
[![HTTP Verbs]({{ site.url }}/assets/images/posts/2020/09/nsxt-migrating-ipsets-from-nsxv-nsxt-http-verbs.png){:class="img-responsive"}]({{ site.url }}/assets/images/posts/2020/09/nsxt-migrating-ipsets-from-nsxv-nsxt-http-verbs.png)
_from [How to Navigate NSX-T Policy APIs for Network Automation](https://blogs.vmware.com/networkvirtualization/2020/06/navigating-nsxt-policy-apis.html/)_
{:.notice}

When updating an existing object `PUT` and `PATCH` have a small difference related to concurrency control that is described in a bit more detail in _NSX-T API Guide_ in [_Optimistic Concurrency Control and the _revision property_](https://code.vmware.com/apis/892/nsx-t).

We will use `PATCH`, since it will work to create and update our objects and would make it easier to script the process.

It is time to test the creation of a new _NSX-T Group_.

#### Creating a new _NSX-T Group_

From the [_API Guide_](https://code.vmware.com/apis/892/nsx-t) and from the examples that we got above we know that our _JSON_ payload would be something similar to:

```json
{
  "expression": [
    {
      "ip_addresses": "<IPs>",
      "resource_type": "IPAddressExpression"
    }
  ],
  "display_name": "<nsxtGroupDisplayName>",
  "description": "<nsxtGroupDescription>"
}
```

```powershell
$groupObjectID = "NSXT-newGroup"
$groupObjectDisplayName = "NSXT-newGroup01"
$groupObjectDescription = "New NSX-T Group Created using API"

#  The function ConvertTo-JSON flattens out any array with
# single element which breaks the expected format, since
# NSX-T removes duplicates we can duplicate our single object
$groupObjectIPS = @()
$groupObjectIPs += "10.10.10.10"
$groupObjectIPs += "10.10.10.10"

$urlPatchGroup = "https://$nsxtManager/policy/api/v1/infra/domains/default/groups/$groupObjectID"

$newGroupObjectJSON = @{
  "expression" = @(
    @{
      "ip_addresses" = $groupObjectIPs;
      "resource_type" = "IPAddressExpression"
    }
  );
  "display_name" = $groupObjectDisplayName;
  "description" = $groupObjectDescription
}

$jsonPayload = ConvertTo-Json -InputObject $newGroupObjectJSON -depth 10 -compress

$httpResponse = Invoke-RestMethod -Uri $urlPatchGroup `
  -Authentication Basic -Credential $nsxtManagerCredentials `
  -Method Patch -ContentType "application/json" `
  -Body $jsonPayload `
  -SkipCertificateCheck
```

## Now putting all together and create a quick _Powershell_ snippet to copy our _NSX-V IPSets_

We will use [_PowerNSX Powershell module_](https://powernsx.github.io/) cmdlet _Get-NSXIPSet_, instead of developing something on purpose for it.

```powershell
> Get-NsxIPset | Select Name

  name
  ----
  NSXV-IPSet01
  NSXV-IPSet02
  NSXV-IPSet03
  NSXV-IPSet04
  NSXV-IPSet05
```

To create our _NSX-T Groups_ we will need the following properties from our _NSX-V IPSets_:

* _name_        - We will use this property as our _display\_name_ and as our ID for object creation
* _description_ - Will keep the same description
* _value_       - Our _IPSet_ values

```powershell
> Get-NsxIPset | Select name, description, value

  name         description              value
  ----         -----------              -----
  NSXV-IPSet01 NSXV-IPSet01 description 100.100.104.1
  NSXV-IPSet02                          100.100.100.3,100.100.100.2
  NSXV-IPSet03                          100.100.200.1-100.100.200.10
  NSXV-IPSet04                          100.100.150.0/24
  NSXV-IPSet05 NSXV-IPSet05 description 100.100.160.1-100.100.160.10,100.100.150.1,100.100.165.10/24
```

Let us create a quick loop to go through our _NSX-V IPSets_ and create the equivalent _NSX-T Groups_

```powershell
$nsxtManager = "nsxtm.adao"
$nsxtManagerCredentials = Get-Credential

$nsxvIPSets = Get-NSXIPSet
$totalNumberIPSets = $nsxvIPSets.Count
$counter = 1

foreach ($nsxvIPSetItem in $nsxvIPSets) {
  Write-Host "-> ($counter/$totalNumberIPSets) Copy NSX-V IPSet" -Foreground Blue
  Write-Host "--> Name - $($nsxvIPSetItem.name)`t`t- Description: $($nsxvIPSetItem.description)" -Foreground Yellow
  Write-Host "--> Value: $($nsxvIPSetItem.Value)" -Foreground Yellow

  #  The function ConvertTo-JSON flattens out any array with
  # single element which breaks the expected format, since
  # NSX-T removes duplicates we can duplicate our single object
  $groupIPs = @()
  $nsxvIPSetIPs = ($nsxvIPSetItem.Value).Split(",")
  if ($nsxvIPSetIPs.Count -eq 1) {
    $groupIPs += $nsxvIPSetIPs
    $groupIPs += $nsxvIPSetIPs
  } else {
    $groupIPs = $nsxvIPSetIPs
  }
  
  $urlPatchGroup = "https://$nsxtManager/policy/api/v1/infra/domains/default/groups/$($nsxvIPSetItem.name)"

  $newGroup = @{
    "expression" = @(
      @{
        "ip_addresses" = $groupIPs;
        "resource_type" = "IPAddressExpression"
      }
    );
    "display_name" = $nsxvIPSetItem.name;
    "description" = $nsxvIPSetItem.description
  }

  $jsonPayload = ConvertTo-Json -InputObject $newGroup -depth 10 -compress

  $httpResponse = Invoke-RestMethod -Uri $urlPatchGroup `
    -Authentication Basic -Credential $nsxtManagerCredentials `
    -Method Patch -ContentType "application/json" `
    -Body $jsonPayload `
    -SkipCertificateCheck

  $counter++
}
```

## Testing our code

We are not covering the _NSX-V Server_ connection in the post, so we assume that it is established and ready to go, will add to post a tidier and clean script later
{:.notice--info}

Running it

[![Snippet run]({{ site.url }}/assets/images/posts/2020/09/nsxt-migrating-ipsets-from-nsxv-nsxt-snippet-run.png){:class="img-responsive"}]({{ site.url }}/assets/images/posts/2020/09/nsxt-migrating-ipsets-from-nsxv-nsxt-snippet-run.png)

And the result from _NSX-V_ and _NSX-T Manager_

Our _NSX-V IPSets_ | Our brand new _NSX-T Groups_
|------------------|-----------------------------|
[![NSX-V IPsets]({{ site.url }}/assets/images/posts/2020/09/nsxt-migrating-ipsets-from-nsxv-nsxt-nsxv-source-ipsets.png){:class="img-responsive"}]({{ site.url }}/assets/images/posts/2020/09/nsxt-migrating-ipsets-from-nsxv-nsxt-nsxv-source-ipsets.png) | [![New NSX-T Groups]({{ site.url }}/assets/images/posts/2020/09/nsxt-migrating-ipsets-from-nsxv-nsxt-new-nsxt-groups.png){:class="img-responsive"}]({{ site.url }}/assets/images/posts/2020/09/nsxt-migrating-ipsets-from-nsxv-nsxt-new-nsxt-groups.png)

Detail of some of them

NSX-V IPSets Details | NSX-T New Groups Details
|------------------|-----------------------------|
[![NSX-V IPSet01 Source]({{ site.url }}/assets/images/posts/2020/09/nsxt-migrating-ipsets-from-nsxv-nsxt-nsxv-source-group-nsxv-ipset01.png){:class="img-responsive"}]({{ site.url }}/assets/images/posts/2020/09/nsxt-migrating-ipsets-from-nsxv-nsxt-nsxv-source-group-nsxv-ipset01.png) | [![New NSX-T Groups NSXV-IPSET01]({{ site.url }}/assets/images/posts/2020/09/nsxt-migrating-ipsets-from-nsxv-nsxt-new-nsxt-group-nsxv-ipset01.png){:class="img-responsive"}]({{ site.url }}/assets/images/posts/2020/09/nsxt-migrating-ipsets-from-nsxv-nsxt-new-nsxt-group-nsxv-ipset01.png)
|------------------|-----------------------------|
[![NSX-V IPSet05 Source]({{ site.url }}/assets/images/posts/2020/09/nsxt-migrating-ipsets-from-nsxv-nsxt-nsxv-source-group-nsxv-ipset05.png){:class="img-responsive"}]({{ site.url }}/assets/images/posts/2020/09/nsxt-migrating-ipsets-from-nsxv-nsxt-nsxv-source-group-nsxv-ipset05.png) | [![New NSX-T Groups NSXV-IPSET01]({{ site.url }}/assets/images/posts/2020/09/nsxt-migrating-ipsets-from-nsxv-nsxt-new-nsxt-group-nsxv-ipset05.png){:class="img-responsive"}]({{ site.url }}/assets/images/posts/2020/09/nsxt-migrating-ipsets-from-nsxv-nsxt-new-nsxt-group-nsxv-ipset05.png)

{% capture end-considerations %}
**Considerations:**
* Since we are using `PATCH` method, groups will be either created if brand new _unique id_ is used, or will be upgraded with the new values in case of an existing _unique id_.
* A more developed script will be added to the post at a later stage.
{% endcapture %}
<div class="notice--info">{{ end-considerations | markdownify }}</div>