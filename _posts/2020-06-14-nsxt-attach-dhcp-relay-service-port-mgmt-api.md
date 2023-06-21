---
author: Ricardo Adao
published: true
post_date: 2020-06-14 08:00:00
last_modified_at: 2020-09-30 23:00:00
header:
  teaser: /assets/images/featured/nsx-150x150.png
title: NSX-T Data Center - Attaching a DHCP Relay service to a NSX-T Logical Router Service Interface or Centralized Service Port (CSP)
categories:
  - nsx
tags:
  - nsx-t
  - nsx
  - powercli
  - powershell
  - vmware
toc: true
slug: nsx-data-center-attaching-dhcp-relay-service-nsx-logical-router-service-interface-centralized-service-port-csp
lastmod: 2023-06-21T08:14:01.474Z
---
You can use _DHCP_ (_Dynamic Host Configuration Protocol_) to dynamically assign IP addresses and other network configuration to our devices.

In _NSX-T Data Center_ you have two (2) flavours that you can use:

* _**DHCP Server**_ - The _DHCP Service_ and the configurations are managed and run within and by _NSX-T_ managed component
* _**DHCP Relay**_  - The _DHCP Service_ and the configuration run outside of the _NSX-T_ managed components, for example in a virtual machine, and _NSX-T_ only relays the _DHCP Requests_ to our _DHCP_ server

The _NSX-T_ documentation document the setup of both pretty well:

* Using the Simplified UI
  * NSX-T 2.5 - [IP Address Management (IPAM)](https://docs.vmware.com/en/VMware-NSX-T-Data-Center/2.5/administration/GUID-A27DF20A-5162-40F5-B7D5-2DF8B6AE5DBE.html)
  * NSX-T 3.0 - [IP Address Management (IPAM)](https://docs.vmware.com/en/VMware-NSX-T-Data-Center/3.0/administration/GUID-A27DF20A-5162-40F5-B7D5-2DF8B6AE5DBE.html)

* Using the Advanced Network&Security UI
  * NSX-T 2.5 - [Advanced DHCP](https://docs.vmware.com/en/VMware-NSX-T-Data-Center/2.5/administration/GUID-3C79297C-BFAC-4F25-ADDA-A5F3E524A569.html)
  * NSX-T 3.0 - [DHCP in Manager Mode](https://docs.vmware.com/en/VMware-NSX-T-Data-Center/3.0/administration/GUID-3C79297C-BFAC-4F25-ADDA-A5F3E524A569.html)

# Ooopss... we have an edge case in hands

The _NSX-T_ documentation well how to configure the _Edge_ builtin _DHCP Server_ functionality and how to configure a _DHCP Relay_ server for a _T0_ or _T1_ gateway.

_**What if we want to add a DHCP Relay Service to a Service Interface of a T0 or T1 router?**_

Documentation do not cover this use case and you do not have a way of doing it through the _Simplified UI_, neither through _Advanced&Security UI_.

Which will leave us with the option to explore the _RestAPI_ option.

# Use Case

* _DHCP Clients_ are connected to _VLAN 59_
* _VLAN 59_ is connected to a _T0 - Service Interface_
* _T0 - Service Interface_ is configured as _VLAN 59_ gateway
* _DHCP Relay_ service will be setup in _T0 - Service Interface_ to relay _DHCP Requests_ to _DHCP Server_
* _T0s_ and _T1s_ are in different edge clusters (this is a design preference, we can use a single edge cluster/edge)
* Route redistribution is enabled between _T0_ and _T1_ (static routing can be used)
* _DHCP Server_ is a virtual machine running in an overlay segment connected to _T1 - Downlink_
  * Note: our use case setup the _DHCP Relay_ in the _T0 - Service Interface_, but we could use a _T1 - Service Interface_ also
{: .notice}

  [![DHCP Relay Lab Topology]({{ relative_url }}/assets/images/posts/2020/06/nsxt-attach-dhcp-relay-service-lab-topology.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2020/06/nsxt-attach-dhcp-relay-service-lab-topology.png)

# Solution

The configuration can be done using _NSX-T RESTApis_, but we will be using the _NSX-T UI_ when possible.

## Setting up the basics using the Simplified UI

### Creating our _DHCP Client_ segment and _T0 - Service Interface_

#### Create our _DHCP Client_ segment (NVDS VLAN backed)

* Networking -> Segments -> Add Segment
  [![Create DHCP Client Segment]({{ relative_url }}/assets/images/posts/2020/06/nsxt-attach-dhcp-relay-create-vlan59-segment.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2020/06/nsxt-attach-dhcp-relay-create-vlan59-segment.png)

#### Create the _T0 - Service Interface_ interface

* Networking -> Tier-0 Gateway -> Edit the T0 Gateway -> Edit Interfaces (Click in the Interface count) -> Add Interface
  [![Edit T0 Gateway]({{ relative_url }}/assets/images/posts/2020/06/nsxt-attach-dhcp-relay-create-vlan59-gw-1.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2020/06/nsxt-attach-dhcp-relay-create-vlan59-gw-1.png)

  [![Add Service Interface]({{ relative_url }}/assets/images/posts/2020/06/nsxt-attach-dhcp-relay-create-vlan59-gw-2.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2020/06/nsxt-attach-dhcp-relay-create-vlan59-gw-2.png)

  [![Service Interface Created]({{ relative_url }}/assets/images/posts/2020/06/nsxt-attach-dhcp-relay-create-vlan59-gw-3.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2020/06/nsxt-attach-dhcp-relay-create-vlan59-gw-3.png)

### Creating _DHCP Server_ segment and connecting it to our desired _T1 Gateway_

#### Create our overlay segment for the _DHCP Server_

* Networking -> Segments -> Add Segment
  [![Create DHCP Server segment]({{ relative_url }}/assets/images/posts/2020/06/nsxt-attach-dhcp-relay-create-dhcp-server-segment-1.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2020/06/nsxt-attach-dhcp-relay-create-dhcp-server-segment-1.png)

  * Setting up segment subnet (-> Set Subnets)
    [![Setup segment subnet]({{ relative_url }}/assets/images/posts/2020/06/nsxt-attach-dhcp-relay-create-dhcp-server-segment-2.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2020/06/nsxt-attach-dhcp-relay-create-dhcp-server-segment-2.png)

    [![Setup segment subnet]({{ relative_url }}/assets/images/posts/2020/06/nsxt-attach-dhcp-relay-create-dhcp-server-segment-3.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2020/06/nsxt-attach-dhcp-relay-create-dhcp-server-segment-3.png)

#### Creating our _DHCP Relay service_ using Advanced Network&Security UI

In _NSX-T 2.5_ you have two (2) options to setup a _DHCP Relay_ service using the UI - Simplified UI or Advanced&Security UI.

This changes in _NSX-T 3.0_ but the post is covering the UI setup for _NSX-T 2.5_ only, since at the moment my Homelab is locked in that version, potentially a future update of the post will happen once I update the Homelab to _NSX-T 3.0_.
{: .notice--info}

Since we will need to leverage the _NSX-T Management API_ instead of the new _NSX-T Policy API_, the _DHCP Relay_ configuration will need to be done through the _Advanced Network&Security UI_.

##### Setting up our DHCP Relay Profile and DHCP Relay Service

First step creating a _DHCP Relay Profile_

* Advanced Network&Security -> DHCP -> Relay Profiles
  [![Create DHCP Relay Profile]({{ relative_url }}/assets/images/posts/2020/06/nsxt-attach-dhcp-relay-create-dhcp-relay-1.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2020/06/nsxt-attach-dhcp-relay-create-dhcp-relay-1.png)

* Create the DHCP Relay Profile to use our DHCP Server (Advanced Network&Security -> DHCP -> Relay Profiles -> Add)
  [![Create DHCP Relay Profile]({{ relative_url }}/assets/images/posts/2020/06/nsxt-attach-dhcp-relay-create-dhcp-relay-2.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2020/06/nsxt-attach-dhcp-relay-create-dhcp-relay-2.png)

Create the _DHCP Relay service_

* Advanced Network&Security -> DHCP -> Relay Services
  [![Create DHCP Relay Profile]({{ relative_url }}/assets/images/posts/2020/06/nsxt-attach-dhcp-relay-create-dhcp-relay-services-1.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2020/06/nsxt-attach-dhcp-relay-create-dhcp-relay-services-1.png)

* Create the DHCP Relay Service to use our DHCP Server Profile that we created previously (Advanced Network&Security -> DHCP -> Relay Services -> Add)
  [![Create DHCP Relay Profile]({{ relative_url }}/assets/images/posts/2020/06/nsxt-attach-dhcp-relay-create-dhcp-relay-services-2.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2020/06/nsxt-attach-dhcp-relay-create-dhcp-relay-services-2.png)

## Gather the information needed using NSX-T Management API

I will be using [_Postman_](https://www.postman.com) since it is easier do describe the process, but there will be a _Powershell_ script in the end that will achieve the same result.

* List DHCP Relay Services

  `GET https://<NSX-T Manager>/api/v1/dhcp/relays`

  NSX-T 2.5 API Documentation - [GET /api/v1/dhcp/relays](https://vdc-download.vmware.com/vmwb-repository/dcr-public/6c24b5c0-396a-4152-9125-bd10a795836b/74043a09-7320-40ac-ac85-9416d0f9cd01/nsx_25_api.html#Methods.ListDhcpRelays)
  {: .notice--info}

  ```json
  {
    "results": [
      {
        "dhcp_relay_profile_id": "083d2a17-67ea-417b-96cd-b20f3f80a297",
        "resource_type": "DhcpRelayService",
        "id": "7f541ee6-5c3c-4cfd-9d1b-0acb8f2746f0",
        "display_name": "ADV-DHCP-T0",
        "_create_user": "admin",
        "_create_time": 1588777188827,
        "_last_modified_user": "admin",
        "_last_modified_time": 1588777188827,
        "_system_owned": false,
        "_protection": "NOT_PROTECTED",
        "_revision": 0
      }
    ],
    "result_count": 1
  }
  ```

* List Logical Router Ports

  `GET https://<NSX-T Manager>/api/v1/logical-router-ports/`

  NSX-T 2.5 API Documentation - [GET /api/v1/logical-router-ports/](https://vdc-download.vmware.com/vmwb-repository/dcr-public/6c24b5c0-396a-4152-9125-bd10a795836b/74043a09-7320-40ac-ac85-9416d0f9cd01/nsx_25_api.html#Methods.ListLogicalRouterPorts)
  {: .notice--info}

  ```json
  {
    "results": [
      {
        "linked_logical_switch_port_id": {
          "target_id": "7499425d-24f7-4958-b9a7-4a1f9e82415b"
        },
        "subnets": [
          {
            "ip_addresses": [
              "10.10.102.1"
            ],
            "prefix_length": 24
          }
        ],
        "urpf_mode": "STRICT",
        "enable_netx": false,
        "resource_type": "LogicalRouterCentralizedServicePort",
        "id": "97f9c944-0c46-4a43-9add-36b3588a3a44",
        "display_name": "DHCP-Client-VLAN59-GW",
        "description": "Logical router port for interface /infra/tier-0s/T0-GW-AP-01/locale-services/b4ccdd40-5687-11ea-9fa9-99aa5ce534ea/interfaces/DHCP-Client-VLAN59-GW",
        "tags": [
          {
            "scope": "policyPath",
            "tag": "/infra/tier-0s/T0-GW-AP-01/locale-services/b4ccdd40-5687-11ea-9fa9-99aa5ce534ea/interfaces/DHCP-Client-VLAN59-GW"
          }
        ],
        "logical_router_id": "a8b32d77-a665-4c27-b76d-c41022e180f0",
        "_create_user": "nsx_policy",
        "_create_time": 1592053513339,
        "_last_modified_user": "nsx_policy",
        "_last_modified_time": 1592053513339,
        "_system_owned": false,
        "_protection": "REQUIRE_OVERRIDE",
        "_revision": 0
      },
    <...>
    ],
    "result_count": 11
  }
  ```

## Attaching _DHCP Relay service_ to _Service Interface_

The configuration will be done by doing a _PUT_ _REST API_ call using the _Management API_ that will attach a new service to an existing Service Interface.

Some information from previous calls will be needed to be able to put together the _JSON payload_ required to do our setup.

* Retrieve _Service Interface_ current configuration

  `GET https://<NSX-T Manager>/api/v1/logical-router-ports/<logical-router-port-id>/`

  NSX-T 2.5 API Documentation - [GET /api/v1/logical-router-ports/logical-router-port-id](https://vdc-download.vmware.com/vmwb-repository/dcr-public/6c24b5c0-396a-4152-9125-bd10a795836b/74043a09-7320-40ac-ac85-9416d0f9cd01/nsx_25_api.html#Methods.ReadLogicalRouterPort)
  {: .notice--info}

  We will use the ID information that we retrieved before and get the _Service Interface_ current configuration, since we will use it as the base of our _JSON payload_ for the configuration call.

  ```json
  <...>
  "id": "97f9c944-0c46-4a43-9add-36b3588a3a44",
  "display_name": "DHCP-Client-VLAN59-GW",
  <...>
  ```

  * `GET https://<NSX-T Manager>/api/v1/logical-router-ports/97f9c944-0c46-4a43-9add-36b3588a3a44/`

    ```json
    {
      "linked_logical_switch_port_id": {
        "target_id": "7499425d-24f7-4958-b9a7-4a1f9e82415b"
      },
      "subnets": [
        {
          "ip_addresses": [
            "10.10.102.1"
          ],
          "prefix_length": 24
        }
      ],
      "urpf_mode": "STRICT",
      "enable_netx": false,
      "resource_type": "LogicalRouterCentralizedServicePort",
      "id": "97f9c944-0c46-4a43-9add-36b3588a3a44",
      "display_name": "DHCP-Client-VLAN59-GW",
      "description": "Logical router port for interface /infra/tier-0s/T0-GW-AP-01/locale-services/b4ccdd40-5687-11ea-9fa9-99aa5ce534ea/interfaces/DHCP-Client-VLAN59-GW",
      "tags": [
        {
          "scope": "policyPath",
          "tag": "/infra/tier-0s/T0-GW-AP-01/locale-services/b4ccdd40-5687-11ea-9fa9-99aa5ce534ea/interfaces/DHCP-Client-VLAN59-GW"
        }
      ],
      "logical_router_id": "a8b32d77-a665-4c27-b76d-c41022e180f0",
      "_create_user": "nsx_policy",
      "_create_time": 1592053513339,
      "_last_modified_user": "nsx_policy",
      "_last_modified_time": 1592053513339,
      "_system_owned": false,
      "_protection": "REQUIRE_OVERRIDE",
      "_revision": 0
    }
    ```

* Build our _JSON payload_ to attach our _DHCP Relay service_ to the _Service Interface_

  * Our configuration call will be

    `PUT https://<NSX-T Manager>/api/v1/logical-router-ports/<logical-router-port-id>/`

    NSX-T 2.5 API Documentation - [PUT /api/v1/logical-router-ports/logical-router-port-id/](https://vdc-download.vmware.com/vmwb-repository/dcr-public/6c24b5c0-396a-4152-9125-bd10a795836b/74043a09-7320-40ac-ac85-9416d0f9cd01/nsx_25_api.html#Methods.UpdateLogicalRouterPort)
    {: .notice--info}

  * Our _JSON payload_ will be based in the _current Service Interface configuration_ that we just retrieved, plus an additional property called _service\_bindings_ that will can be one or more [_Service Binding_](https://vdc-download.vmware.com/vmwb-repository/dcr-public/6c24b5c0-396a-4152-9125-bd10a795836b/74043a09-7320-40ac-ac85-9416d0f9cd01/nsx_25_api.html#Type.ServiceBinding)

    ```json
    {
      "service_id": {
        "target_display_name": "Display Name of NSX Resource",
        "is_valid": true, (false if element been deleted)
        "target_type": "Type of NSX Resource",
        "target_id": "ID of NSX Resource"
      }
    }
    ```
  
  * Our _Service Binding_ element will have the information of our _DHCP Relay Service_

    ```json
    "service_bindings": [
      {
        "service_id": {
          "target_display_name": "ADV-DHCP-T0",
          "is_valid": true,
          "target_type": "DhcpRelayService",
          "target_id": "7f541ee6-5c3c-4cfd-9d1b-0acb8f2746f0"
        }
      }
    ]
    ```

  * Our final _JSON payload_ will be then

    ```json
    {
      "linked_logical_switch_port_id": {
        "target_id": "7499425d-24f7-4958-b9a7-4a1f9e82415b"
      },
      "subnets": [
        {
          "ip_addresses": [
            "10.10.102.1"
          ],
          "prefix_length": 24
        }
      ],
      "urpf_mode": "STRICT",
      "enable_netx": false,
      "resource_type": "LogicalRouterCentralizedServicePort",
      "id": "97f9c944-0c46-4a43-9add-36b3588a3a44",
      "display_name": "DHCP-Client-VLAN59-GW",
      "description": "Logical router port for interface /infra/tier-0s/T0-GW-AP-01/locale-services/b4ccdd40-5687-11ea-9fa9-99aa5ce534ea/interfaces/DHCP-Client-VLAN59-GW",
      "tags": [
        {
          "scope": "policyPath",
          "tag": "/infra/tier-0s/T0-GW-AP-01/locale-services/b4ccdd40-5687-11ea-9fa9-99aa5ce534ea/interfaces/DHCP-Client-VLAN59-GW"
        }
      ],
      "service_bindings": [
        {
          "service_id": {
            "target_display_name": "ADV-DHCP-T0",
            "is_valid": true,
            "target_type": "DhcpRelayService",
            "target_id": "7f541ee6-5c3c-4cfd-9d1b-0acb8f2746f0"
          }
        }
      ],
      "logical_router_id": "a8b32d77-a665-4c27-b76d-c41022e180f0",
      "_create_user": "nsx_policy",
      "_create_time": 1592053513339,
      "_last_modified_user": "nsx_policy",
      "_last_modified_time": 1592053513339,
      "_system_owned": false,
      "_protection": "REQUIRE_OVERRIDE",
      "_revision": 0
    }
    ```
  
  * One last detail before we apply our new configuration

    In the _Service Interface_ configuration schema, there is a property named **_protection**. This property indicates the protection status of the resource.
    That property can have one of the following values

    * **PROTECTED** - the client who retrieved the entity is not allowed to modify it
    * **NOT_PROTECTED** - the client who retrieved the entity is allowed to modify it
    * **REQUIRE_OVERRIDE** - the client who retrieved the entity is a super user and can modify it, but only when providing the request header _X-Allow-Overwrite=true_
    * **UNKNOWN** - the _protection field could not be determined for this entity

    In our case we have a **REQUIRE_OVERRIDE** value, which means that we will need to provide the extra request header - _X-Allow-Overwrite=true_ - in our _PUT_ call to be able to modify the current configuration

    [![X-Allow-Overwrite Header]({{ relative_url }}/assets/images/posts/2020/06/nsxt-attach-dhcp-relay-x-allow-overwrite.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2020/06/nsxt-attach-dhcp-relay-x-allow-overwrite.png)

    If we do not add this extra request header, _NSX-T API_ will reply with

    ```json
    {
      "httpStatus": "BAD_REQUEST",
      "error_code": 289,
      "module_name": "common-services",
      "error_message": "Principal 'admin' with role '[enterprise_admin]' attempts to delete or modify an object of type LRPort it doesn't own. (createUser=nsx_policy, allowOverwrite=null)"
    }
    ```

* Now we are ready to attach our _DHCP Relay service_ to the _Service Interface_

  Our request will be

  `PUT https://nsxtm/api/v1/logical-router-ports/97f9c944-0c46-4a43-9add-36b3588a3a44/`

  And the body/payload of the request will be our prepared _JSON payload_ with the _DHCP Relay service_ configuration added.

  [![PUT Request]({{ relative_url }}/assets/images/posts/2020/06/nsxt-attach-dhcp-relay-put-1.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2020/06/nsxt-attach-dhcp-relay-put-1.png)

  If all goes well, you will have a _HTTP 200_ result

  [![PUT HTTP 200 Result]({{ relative_url }}/assets/images/posts/2020/06/nsxt-attach-dhcp-relay-put-2.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2020/06/nsxt-attach-dhcp-relay-put-2.png)

  And the new _Service Interface_ configuration in the response body, with the service binding added

  ```json
  {
    <...>
    "resource_type": "LogicalRouterCentralizedServicePort",
    "id": "97f9c944-0c46-4a43-9add-36b3588a3a44",
    "display_name": "DHCP-Client-VLAN59-GW",
    <...>
    "service_bindings": [
      {
        "service_id": {
          "target_id": "7f541ee6-5c3c-4cfd-9d1b-0acb8f2746f0",
          "target_display_name": "ADV-DHCP-T0",
          "target_type": "DhcpRelayService",
          "is_valid": true
        }
      }
    ],
    <...>
    "_create_user": "nsx_policy",
    "_create_time": 1592053513339,
    "_last_modified_user": "admin",
    "_last_modified_time": 1592088370061,
    "_system_owned": false,
    "_protection": "REQUIRE_OVERRIDE",
    "_revision": 3
  }
  ```

  We can also double check the configuration using the Advanced Network&Security UI

  Advanced Network&Security -> Routers -> Select targeted Router -> Configuration -> Router Ports

  [![Router Port UI view]({{ relative_url }}/assets/images/posts/2020/06/nsxt-attach-dhcp-relay-put-3.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2020/06/nsxt-attach-dhcp-relay-put-3.png

# The Result

And the only part missing... Testing it...

We have multiple points in the path between the _DHCP Client_ and _DHCP Server_ to monitor and capture our traffic, but we will just check the server side and if our client acquires a IP.

## Virtual Machines configuration

* Client and Server virtual machines

  | [![DHCP Client]({{ relative_url }}/assets/images/posts/2020/06/nsxt-attach-dhcp-relay-dhcp-client-vm.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2020/06/nsxt-attach-dhcp-relay-dhcp-client-vm.png) |[![DHCP Server]({{ relative_url }}/assets/images/posts/2020/06/nsxt-attach-dhcp-relay-dhcp-server-vm.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2020/06/nsxt-attach-dhcp-relay-dhcp-server-vm.png) |

## Check _DHCP Server_

Lets do a packet capture in the listening interface and limit the ports to _port 67/UDP_ and _port 68/UDP_, since they are the ports involved in the DHCP flow from the server side.

* Basic capture
  [![DHCP Server Capture]({{ relative_url }}/assets/images/posts/2020/06/nsxt-attach-dhcp-relay-dhcp-server-vm-capture-simple.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2020/06/nsxt-attach-dhcp-relay-dhcp-server-vm-capture-simple.png)

  Seems that we have some communication between our _DHCP Client GW_ (_Service Interface_ - 10.10.102.1) interface where the _DHCP Relay service_ is attached and our _DHCP Server_ (IP - 10.10.103.2).

* Checking in more detail the capture to check if the [_DHCP Operation flow_](https://en.wikipedia.org/wiki/Dynamic_Host_Configuration_Protocol) is complete

  [![DHCP Server Capture - 1]({{ relative_url }}/assets/images/posts/2020/06/nsxt-attach-dhcp-relay-dhcp-server-vm-capture-1.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2020/06/nsxt-attach-dhcp-relay-dhcp-server-vm-capture-1.png)
  [![DHCP Server Capture - 2]({{ relative_url }}/assets/images/posts/2020/06/nsxt-attach-dhcp-relay-dhcp-server-vm-capture-2.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2020/06/nsxt-attach-dhcp-relay-dhcp-server-vm-capture-2.png)

  Yeap, we seem to see the all process - Discovery -> Offer -> Request -> ACK

  [![DHCP Flow]({{ relative_url }}/assets/images/posts/2020/06/nsxt-attach-dhcp-relay-dhcp-flow.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2020/06/nsxt-attach-dhcp-relay-dhcp-flow.png)

## Check _DHCP Client_

In the _DHCP Client_ side, lets just check if the virtual machine got the desired configuration after the DHCP exchange

[![DHCP Client End State]({{ relative_url }}/assets/images/posts/2020/06/nsxt-attach-dhcp-relay-dhcp-client-vm-ifconfig.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2020/06/nsxt-attach-dhcp-relay-dhcp-client-vm-ifconfig.png)

# FAQ

## I followed the steps and my _DHCP Client_ do not get an IP?

There are multiple factors that could be affecting this, however if the _Use Case_ is similar to the one described in the post there is a possibility of the issue being related to the _Segment Profiles_ applied to our _Edge VMs trunks_, in case we are using _NVDS VLAN backed segments_ for it (if using _DVS portgroups_ it will work fine, potentially with _VDS 7.0_ will be slightly different, but as explained before, Homelab is waiting for an upgrade).

By default, any segment created using _NSX-T UI_ will get a set of _default Segment Profiles_.

[![Default Segment Profiles]({{ relative_url }}/assets/images/posts/2020/06/nsxt-attach-dhcp-relay-segment-profiles-1.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2020/06/nsxt-attach-dhcp-relay-segment-profiles-1.png)

[![DHCP Client Segment]({{ relative_url }}/assets/images/posts/2020/06/nsxt-attach-dhcp-relay-segment-profiles-2.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2020/06/nsxt-attach-dhcp-relay-segment-profiles-2.png)

The solution is to create a new _Segment Profile_ of the type _Segment Security Profile_ with the _DHCP Server Block_ disabled.

[![New Segment Profile]({{ relative_url }}/assets/images/posts/2020/06/nsxt-attach-dhcp-relay-segment-profiles-3.png){:class="img-responsive"}]({{ relative_url }}/assets/images/posts/2020/06/nsxt-attach-dhcp-relay-segment-profiles-3.png)

{% capture notice-note-troubleshoot %}
**Note**

I spent some time figuring it out and troubleshooting this issue.

In summary the _DHCP Client_ never receives the _DHCP Offer packet_, since the packet is blocked by the default security policies between the _Service Interface_ and the _DHCP Client_.

With the new _Security Segment Profile_ with the _DHCP Server Block_ disabled all works as expected.
{% endcapture %}

<div class="notice--info">{{ notice-note-troubleshoot | markdownify }}</div>

## Will it work for _Logical Switches_ segments too?

In our Use Case, we have our _DHCP Clients_ connected to a _NVDS VLAN Backed_ segment, but this solution will also works if _DHCP Clients_ are connected to a _NVDS Logical Switch (overlay)_.

## Can we script it?

Yes, it is a question of choosing your preferred programming language and you can script this partially or the entire process.

Since there is a part of the process that can be done easily using the _NSX-T UI_, I just script using Powershell (PShell 6 or above) the part where we need to leverage the _Management API_. It is not the prettiest powershell coding that you will ever see, but will do the job and show the process.

* Download: [NSX-T Service Interface Attach DHCP Relay script]({{ relative_url }}/assets/downloads/scripts/powershell/nsx-t/nsxt-service-port-dhcp-relay.ps1)