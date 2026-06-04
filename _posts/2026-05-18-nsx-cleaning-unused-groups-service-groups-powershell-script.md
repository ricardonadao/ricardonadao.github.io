---
author: Ricardo Adao
published: true
last_modified_at: 2026-05-18 14:58:02.227000+00:00
date: 2026-05-18 14:58:02.227000+00:00
header:
  teaser: /assets/images/featured/nsx-150x150.png
title: NSX - Removing Unused Groups and Service Groups with PowerShell Script
categories:
  - nsx
tags:
  - nsx
  - powercli
  - powershell
  - vmware
slug: nsx-removing-unused-groups-service-groups-powershell-script
toc: true
draft: false
mathjax: false
---
You can use _PowerShell_ to automate cleanup tasks in your _NSX_ environment, helping maintain optimal performance and organization.

In _NSX_, as you create and modify security policies, groups, and service groups over time, unused objects can accumulate. These unused objects consume resources and can clutter your environment, making management more difficult.

The _NSX_ documentation provides guidance on managing objects through the UI and API, but there's no built-in automated way to identify and remove unused objects based on their actual usage in security policies.

# Use Case

* _NSX environment_ has accumulated many groups and service groups over time
* _Security administrators_ need to identify objects not referenced in any firewall rules
* _System objects_ (like DefaultNodeGroup) and objects referenced in security policies must be preserved
* _WhatIf mode_ is desired for safe analysis before actual deletion
* _Logging and reporting_ capabilities are needed for audit trails
* _Batch processing_ with configurable delays helps prevent API overload

{: .notice}

# Solution

The solution is a PowerShell script that connects to the NSX Policy API, identifies unused groups and service groups, and optionally removes them.

## Script Features

* **Sequential processing** for reliability and ease of debugging
* **WhatIf mode** (-Apply switch required for actual deletion)
* **System object preservation** - automatically skips DefaultNodeGroup and other system objects
* **Usage analysis** - checks all firewall rules to determine actual object usage
* **Configurable batching** - control batch size and delays between batches
* **Retry mechanism** - handles transient API failures with configurable retries
* **Detailed logging** - optional log file with timestamps and severity levels
* **JSON export** - optional backup of deleted objects for potential recovery
* **Progress reporting** - visual feedback during long-running operations

## Prerequisites

* PowerShell 5.0+ (tested with PowerShell 7.x)
* Access to NSX 3.x/4.x Policy API
* Appropriate permissions to read and delete objects
* Network connectivity to NSX Manager

## Script Parameters

| Parameter | Description |
|-----------|-------------|
| `NsxManager` | NSX Manager hostname or IP address (e.g., "nsx01.example.com") |
| `Credential` | PSCredential object for authentication (prompted if omitted) |
| `Groups` | Process groups for deletion analysis/removal |
| `ServiceGroups` | Process service groups for deletion analysis/removal |
| `Apply` | Actually perform deletions (without this, runs in WhatIf mode) |
| `LogFile` | Optional path to log file (e.g., "nsx-cleanup.log") |
| `BackupDeleteObjectsFile` | Optional path to save deleted objects as JSON (e.g., "deleted.json") |
| `MaxRetries` | Maximum API retry attempts (default: 5) |
| `BatchSize` | Number of objects to delete per API batch (default: 50) |
| `BatchDelayMs` | Delay between batches in milliseconds (default: 200) |
| `SkipCertificateCheck` | Skip SSL certificate validation (useful for self-signed certs) |
| `DebugMode` | Enable debug logging for troubleshooting |

## Usage Examples

### 1. Analyze what would be deleted (Recommended First Step)

```powershell
nsx_delete_object-v0.3-singlethreaded.ps1 -NsxManager "nsx01.example.com"
```

### 2. Delete unused groups with logging

```powershell
nsx_delete_object-v0.3-singlethreaded.ps1 -NsxManager "nsx01.example.com" -Groups -Apply -LogFile "cleanup.log"
```

### 3. Delete unused service groups with backup for recovery

```powershell
nsx_delete_object-v0.3-singlethreaded.ps1 -NsxManager "nsx01.example.com" -ServiceGroups -Apply -BackupDeleteObjectsFile "backup.json"
```

### 4. Full cleanup with all options

```powershell
nsx_delete_object-v0.3-singlethreaded.ps1 -NsxManager "nsx01.example.com" -Groups -ServiceGroups -Apply -LogFile "full-cleanup.log" -BackupDeleteObjectsFile "full-backup.json"
```

## How It Works

### 1. Connection and Authentication

The script establishes a connection to the NSX Policy API using basic authentication. It handles SSL certificate validation appropriately for different PowerShell versions and editions.

### 2. Data Collection (Sequential)

The script fetches all necessary data in sequence:
- Domains
- Groups from all domains
- Service groups
- Security policies and their rules

### 3. Usage Analysis

The script analyzes all collected data to determine object usage:
- Extracts group and service group references from firewall rules
- Identifies system objects that should always be preserved
- Marks objects as "in use" if referenced in any rule
- Categorizes objects as used/unused and system/non-system-owned

### 4. Deletion Process (If -Apply Specified)

When the `-Apply` switch is used:
- Processes objects in batches to prevent API overload
- Implements configurable delays between batches
- Provides real-time progress reporting
- Logs each deletion attempt with success/failure status
- Records deleted objects for optional JSON export
- Handles transient failures with retry mechanism

### 5. Reporting and Cleanup

After processing:
- Flushes any buffered log entries to disk
- Exports deleted objects to JSON if requested
- Displays final summary with statistics and execution time
- Provides clear indication of completion status

## Safety Features

The script includes multiple safety mechanisms to prevent accidental data loss:

1. **WhatIf Mode Default**: By default, the script runs in analysis mode only - no deletions occur without the `-Apply` switch
2. **System Object Protection**: Objects marked as system-owned (like DefaultNodeGroup) or located in `/infra/defaults/` paths are never deleted
3. **Usage Verification**: Only objects with zero references in firewall rules are considered for deletion
4. **Detailed Logging**: All actions are logged for audit and troubleshooting purposes
5. **Optional Backup**: Deleted objects can be saved as JSON for potential recovery
6. **Progress Visibility**: Real-time feedback shows exactly what's being processed

## Sample Output

When run in WhatIf mode:
```
============================================
NSX Unused Groups and Services Cleanup Tool
============================================

[1/4] Fetching domains...
[OK] Connection successful
[2/4] Fetching groups from all domains...
[3/4] Fetching service groups...
[4/4] Fetching security policies and rules...

============================================
Analyzing Group Usage...
============================================
GROUPS IN USE: 45
  - Used Non-System-Owned: 32
GROUPS NOT IN USE: 18
  - Unused Non-System-Owned: 12

============================================
Analyzing Service Group Usage...
============================================
SERVICE GROUPS IN USE: 28
  - Used Non-System-Owned: 20
SERVICE GROUPS NOT IN USE: 15
  - Unused Non-System-Owned: 10

Group deletion candidates: 12
WHATIF MODE - No groups will be deleted
Service group deletion candidates: 10
WHATIF MODE - No service groups will be deleted

============================================
OPERATION COMPLETE
============================================

SUMMARY:
  Groups processed:            63
  Service groups processed:    43
  Security policies processed: 12
  DFW rules processed:         342
  Total execution time:        15.23 seconds

============================================
TASK COMPLETED SUCCESSFULLY
============================================
```

When run with `-Apply`:
```
============================================
NSX Unused Groups and Services Cleanup Tool
============================================

[1/4] Fetching domains...
[OK] Connection successful
[2/4] Fetching groups from all domains...
[3/4] Fetching service groups...
[4/4] Fetching security policies and rules...

============================================
Analyzing Group Usage...
============================================
GROUPS IN USE: 45
  - Used Non-System-Owned: 32
GROUPS NOT IN USE: 18
  - Unused Non-System-Owned: 12

============================================
Analyzing Service Group Usage...
============================================
SERVICE GROUPS IN USE: 28
  - Used Non-System-Owned: 20
SERVICE GROUPS NOT IN USE: 15
  - Unused Non-System-Owned: 10

Group deletion candidates: 12
Deleting Groups: 12
Service group deletion candidates: 10
Deleting Service Groups: 10

============================================
OPERATION COMPLETE
============================================

SUMMARY:
  Groups processed:            63
  Service groups processed:    43
  Security policies processed: 12
  DFW rules processed:         342
  Total execution time:        28.47 seconds

============================================
TASK COMPLETED SUCCESSFULLY
============================================
```

## Customization Options

The script can be easily customized for different environments:

* Adjust `$InitialDelayMs` for different retry backoff strategies
* Modify `$BatchSize` and `$BatchDelayMs` for different API rate limits
* Change the `$GROUP_PROPERTIES` array if using different rule structures
* Extend the `Test-IsSystemObject` function for additional system objects to preserve
* Modify the output formatting in the `Write-Log` function for different log formats

## Troubleshooting

Common issues and solutions:

**Connection Failures**
* Verify NSX Manager hostname/IP is correct
* Check network connectivity and firewall rules
* Confirm API services are running on NSX Manager
* Validate credentials have sufficient permissions

**Authentication Errors**
* Ensure username/password are correct
* Verify account has appropriate NSX API permissions
* Check for account lockout or password expiration

**API Rate Limiting**
* Increase `BatchDelayMs` value
* Decrease `BatchSize` value
* Check NSX Manager API rate limit configurations

**Permission Issues**
* Confirm account has `enterprise_admin` or equivalent role
* Verify propagation of permissions to all relevant objects
* Check for any denied actions in audit logs

## Conclusion

This PowerShell script provides a reliable, safe way to maintain your NSX environment by identifying and removing unused groups and service groups. By following the recommended workflow of first running in WhatIf mode to review what would be deleted, then proceeding with actual deletion when confident, you can keep your NSX environment clean and efficient without risking accidental removal of critical objects.

The sequential processing approach ensures maximum reliability and ease of debugging, while the comprehensive logging and reporting features provide the visibility needed for operational excellence and audit compliance.

* Download: [NSX Delete Unused Objects Script]({{ relative_url }}/assets/downloads/scripts/powershell/nsx/nsx_delete_object-v0.3-singlethreaded.ps1)