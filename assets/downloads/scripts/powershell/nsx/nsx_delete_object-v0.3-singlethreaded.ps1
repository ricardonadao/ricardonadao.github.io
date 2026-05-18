<#
.SYNOPSIS
    Identifies and removes unused NSX groups and service groups.

.DESCRIPTION
    This script helps clean up NSX environments by identifying and removing
    groups and service groups that are not referenced by any firewall rules.
    It operates sequentially for simplicity and reliability.

    .VERSION - v0.3

    System objects (like DefaultNodeGroup) and any objects referenced in
    security policies are automatically preserved.

    .PARAMETER NsxManager -Description "NSX Manager hostname or IP address (e.g., 'nsx01.example.com')"
    NSX Manager hostname or IP address (e.g., "nsx01.example.com").

    .PARAMETER Credential -Description "PSCredential object for authentication. If omitted, you'll be prompted."
    PSCredential object for authentication. If omitted, you'll be prompted.

.PARAMETER Groups -Description 'Process groups for deletion analysis/removal.'
    Process groups for deletion analysis/removal.

.PARAMETER ServiceGroups -Description 'Process service groups for deletion analysis/removal.'
    Process service groups for deletion analysis/removal.

.PARAMETER Apply -Description 'Actually perform deletions. Without this switch, runs in WhatIf mode.'
    Actually perform deletions. Without this switch, runs in WhatIf mode.

.PARAMETER LogFile -Description 'Optional path to log file (e.g., "nsx-cleanup.log").'
    Optional path to log file (e.g., "nsx-cleanup.log").

.PARAMETER BackupDeleteObjectsFile -Description 'Optional path to save deleted objects as JSON (e.g., "deleted.json").'
    Optional path to save deleted objects as JSON (e.g., "deleted.json").


.PARAMETER BatchSize -Description 'Number of objects to delete per API batch (default: 100).'
    Number of objects to delete per API batch (default: 100).

.PARAMETER BatchDelayMs -Description 'Delay between batches in milliseconds (default: 200).'
    Delay between batches in milliseconds (default: 200).

.EXAMPLE
    # First, analyze what would be deleted (recommended first step)
    .\nsx_delete_objects-v0.3-singlethreaded.ps1 -NsxManager "nsx01.example.com"

.EXAMPLE
    # Delete unused groups with logging
    .\nsx_delete_objects-v0.3-singlethreaded.ps1 -NsxManager "nsx01.example.com" -Groups -Apply -LogFile "cleanup.log"

.EXAMPLE
    # Delete unused service groups with backup for recovery
    .\nsx_delete_objects-v0.3-singlethreaded.ps1 -NsxManager "nsx01.example.com" -ServiceGroups -Apply -BackupDeleteObjectsFile "backup.json"

.NOTES
    - Requires PowerShell 5.0+ and access to NSX 3.x/4.x Policy API
    - Default behavior is WhatIf mode - use -Apply to actually delete objects
    - Runs sequentially (not parallel) for maximum reliability and ease of debugging
    - Always preserves system objects and objects referenced in firewall rules
#>

param(
    [Parameter(Mandatory=$false)]
    [string]$NsxManager = "",

    [Parameter(Mandatory=$false)]
    [PSCredential]$Credential = $null,

    [Parameter(Mandatory=$false)]
    [switch]$Groups,

    [Parameter(Mandatory=$false)]
    [switch]$ServiceGroups,

    [Parameter(Mandatory=$false)]
    [switch]$Apply,

    [Parameter(Mandatory=$false)]
    [switch]$SkipCertificateCheck,

    [Parameter(Mandatory=$false)]
    [switch]$DebugMode,

    [Parameter(Mandatory=$false)]
    [string]$LogFile = "",

    [Parameter(Mandatory=$false)]
    [string]$BackupDeleteObjectsFile = "",

    [Parameter(Mandatory=$false)]
    [ValidateRange(1, 500)]
    [int]$BatchSize = 50,

    [Parameter(Mandatory=$false)]
    [int]$BatchDelayMs = 200
)

# SSL certificate handling for PowerShell < 7
if ($PSVersionTable.PSVersion.Major -lt 7) {
    $skipCert = $SkipCertificateCheck -or $PSVersionTable.PSEdition -eq "Core"
    if ($skipCert) {
        try {
            if (-not ([System.Management.Automation.PSTypeName]'TrustAllCertsPolicy').Type) {
                Add-Type -Language CSharp -TypeDefinition @'
using System.Net;
using System.Security.Cryptography.X509Certificates;
public class TrustAllCertsPolicy : ICertificatePolicy {
    public bool CheckValidationResult(ServicePoint sp, X509Certificate cert, WebRequest req, int problem) { return true; }
}
'@
            }
            [System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
        } catch { }
    }
}

# ============================================
# SCRIPT VARIABLES INITIALIZATION
# ============================================

$script:CancelRequested = $false
$script:BatchSize = $BatchSize
$script:BatchDelayMs = $BatchDelayMs

# Initialize script variables
$script:BaseUrl = $null
$script:Headers = $null
$script:SkipCert = $false
$script:StartTime = Get-Date
$script:LogFilePath = $LogFile
$script:BackupDeleteObjectsFile = $BackupDeleteObjectsFile

# Buffered log writing
$script:LogBuffer = [System.Text.StringBuilder]::new()
$script:LogBufferFlushThreshold = 100

# Track deleted objects for JSON export
$script:DeletedObjectsList = [System.Collections.Generic.List[object]]::new()

# In-memory cache
$script:AllGroups = @()
$script:AllServiceGroups = @()
$script:AllPolicies = @()
$script:AllRules = @()

# Constants
$Script:GROUP_PROPERTIES = @("destination_groups", "source_groups", "scope")
$Script:SYSTEM_PATH_PATTERN = "/infra/defaults/"

# Compiled regex for group ID extraction
$Script:RegexGroupIdExtractor = [regex]::new('.*/([^/]+)$', [System.Text.RegularExpressions.RegexOptions]::Compiled)

# ============================================
# HELPER FUNCTIONS
# ============================================

function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Level] $Message"

    # Write to logfile if enabled
    if ($script:LogFilePath) {
        try {
            Add-Content -Path $script:LogFilePath -Value $logEntry -ErrorAction SilentlyContinue
        } catch {
            # If we can't write to logfile, we don't want to break the script, so we just ignore.
        }
    }

    # Write to console with color
    switch ($Level) {
        "ERROR"   { Write-Host $logEntry -ForegroundColor Red }
        "WARNING" { Write-Host $logEntry -ForegroundColor Yellow }
        "SUCCESS" { Write-Host $logEntry -ForegroundColor Green }
        "DEBUG"   { if ($DebugMode) { Write-Host $logEntry -ForegroundColor Magenta } }
        default   { Write-Host $logEntry }
    }
}

function Record-DeletedObject {
    param(
        [string]$ObjectType,
        [string]$ObjectId,
        [string]$DisplayName,
        [string]$Status,
        [string]$Message,
        [string]$Path = "",
        [string]$Description = ""
    )
    [void]$script:DeletedObjectsList.Add([PSCustomObject]@{
        object_type = $ObjectType
        object_id = $ObjectId
        display_name = $DisplayName
        status = $Status
        message = $Message
        path = $Path
        description = $Description
        deleted_at = (Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ")
    })
}

function Export-DeletedObjects {
    if ($script:BackupDeleteObjectsFile -and $script:DeletedObjectsList.Count -gt 0) {
        try {
            $json = $script:DeletedObjectsList | ConvertTo-Json -Depth 10
            $json | Out-File -FilePath $script:BackupDeleteObjectsFile -Encoding UTF8 -Force
            Write-Log "Exported $($script:DeletedObjectsList.Count) deleted objects to: $script:BackupDeleteObjectsFile" -Level "SUCCESS"
        } catch {
            Write-Log "Failed to export deleted objects: $_" -Level "ERROR"
        }
    }
}

function Test-IsSystemObject {
    param([object]$Object)
    if ($Object._system_owned -eq $true) { return $true }
    if ($Object.resource_type -eq "DefaultNodeGroup") { return $true }
    if ($Object.path -and $Object.path.Contains('/infra/defaults/')) { return $true }
    return $false
}

function Get-NSXAllPages {
    param(
        [string]$Endpoint,
        [string]$ResultKey = "results",
        [int]$PageSize = 1000
    )

    $allResults = [System.Collections.Generic.List[object]]::new()
    $cursor = $null
    $morePages = $true
    $separator = if ($Endpoint -match '\?') { "&" } else { "?" }
    $currentUri = "$script:BaseUrl${Endpoint}${separator}page_size=${PageSize}"

    while ($morePages) {
        if ($script:CancelRequested) { break }

        try {
            $params = @{
                Uri = $currentUri
                Method = "GET"
                Headers = $script:Headers
                ContentType = "application/json"
            }
            if ($script:SkipCert) { $params.SkipCertificateCheck = $true }

            $response = Invoke-RestMethod @params -ErrorAction Stop

            if ($response.$ResultKey) {
                [void]$allResults.AddRange($response.$ResultKey)
            }

            $cursor = $response.cursor
            if ($cursor -and $cursor -ne '') {
                $currentUri = "$script:BaseUrl${Endpoint}${separator}cursor=${cursor}&page_size=${PageSize}"
            } elseif ($response._links -and $response._links.next) {
                $currentUri = $response._links.next
            } else {
                $morePages = $false
            }
        } catch {
            Write-Log "Error calling $currentUri : $_" -Level "ERROR"
            $morePages = $false
        }
    }
    return $allResults
}

function Get-GroupReferences {
    param([object]$Rules)

    Write-Log "Extracting group references from $($Rules.Count) rules" -Level "DEBUG"

    $groupRefs = [System.Collections.Generic.HashSet[string]]::new()
    $regex = $Script:RegexGroupIdExtractor

    foreach ($rule in $Rules) {
        if (-not $rule) { continue }
        foreach ($prop in $Script:GROUP_PROPERTIES) {
            if ($rule.$prop) {
                foreach ($group in $rule.$prop) {
                    $match = $regex.Match($group)
                    if ($match.Success) {
                        [void]$groupRefs.Add($match.Groups[1].Value)
                    }
                }
            }
        }
    }

    Write-Log "Extracted $($groupRefs.Count) unique group references" -Level "DEBUG"
    return $groupRefs
}

# ============================================
# MAIN SCRIPT LOGIC
# ============================================

Write-Log "============================================" -Level "INFO"
Write-Log "NSX Unused Groups and Services Cleanup Tool" -Level "INFO"
Write-Log "============================================" -Level "INFO"
Write-Log "" -Level "INFO"

# Get credentials if not provided
if (-not $NsxManager) {
    $NsxManager = Read-Host "NSX Manager hostname or IP"
}

if ($Credential) {
    $Username = $Credential.UserName
    $Password = $Credential.GetNetworkCredential().Password
} elseif (-not $Username -or -not $Password) {
    $Credential = Get-Credential -Message "Enter NSX Manager credentials"
    $Username = $Credential.UserName
    $Password = $Credential.GetNetworkCredential().Password
}

# Create auth header
$base64Auth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("${Username}:${Password}"))
$script:Headers = @{
    "Content-Type" = "application/json"
    "Accept" = "application/json"
    "Authorization" = "Basic ${base64Auth}"
}

$script:BaseUrl = "https://${NsxManager}/policy/api/v1"
$script:SkipCert = ($PSVersionTable.PSVersion.Major -ge 7 -or $PSVersionTable.PSEdition -eq "Core" -or $SkipCertificateCheck)

Write-Log "" -Level "INFO"
Write-Log "Connecting to NSX Manager: $NsxManager" -Level "SUCCESS"
Write-Log "API Base URL: $script:BaseUrl" -Level "INFO"

# Test connection
try {
    $testUri = "${script:BaseUrl}/infra/domains?page_size=1"
    $testParams = @{ Uri = $testUri; Headers = $script:Headers; ErrorAction = "Stop" }
    if ($script:SkipCert) { $testParams.SkipCertificateCheck = $true }
    $null = Invoke-RestMethod @testParams
    Write-Log "[OK] Connection successful" -Level "SUCCESS"
} catch {
    Write-Log "[ERROR] Connection failed: $_" -Level "ERROR"
    exit 1
}
Write-Log "" -Level "INFO"

# ============================================
# FETCH ALL DATA (Sequential)
# ============================================

Write-Log "[1/4] Fetching domains..." -Level "INFO"
$domains = Get-NSXAllPages -Endpoint "/infra/domains"
Write-Log "Found $($domains.Count) domains" -Level "SUCCESS"

Write-Log "[2/4] Fetching groups from all domains..." -Level "INFO"
$allGroups = [System.Collections.Generic.List[object]]::new()
foreach ($domain in $domains) {
    Write-Log "Fetching groups from domain: $($domain.id)" -Level "DEBUG"
    $domainGroups = Get-NSXAllPages -Endpoint "/infra/domains/$($domain.id)/groups"
    [void]$allGroups.AddRange($domainGroups)
}
$script:AllGroups = $allGroups
Write-Log "Total groups fetched: $($allGroups.Count)" -Level "SUCCESS"

Write-Log "[3/4] Fetching service groups..." -Level "INFO"
$script:AllServiceGroups = Get-NSXAllPages -Endpoint "/infra/services"
Write-Log "Total service groups fetched: $($script:AllServiceGroups.Count)" -Level "SUCCESS"

Write-Log "[4/4] Fetching security policies and rules..." -Level "INFO"
$script:AllPolicies = [System.Collections.Generic.List[object]]::new()
$script:AllRules = [System.Collections.Generic.List[object]]::new()

foreach ($domain in $domains) {
    $domainPolicies = Get-NSXAllPages -Endpoint "/infra/domains/$($domain.id)/security-policies"
    foreach ($policy in $domainPolicies) {
        $policy | Add-Member -NotePropertyName "domain_id" -NotePropertyValue $domain.id -Force
        [void]$script:AllPolicies.Add($policy)
        
        $rules = Get-NSXAllPages -Endpoint "/infra/domains/$($domain.id)/security-policies/$($policy.id)/rules"
        foreach ($rule in $rules) {
            [void]$script:AllRules.Add($rule)
        }
    }
}
Write-Log "Total policies fetched: $($script:AllPolicies.Count)" -Level "SUCCESS"
Write-Log "Total DFW rules fetched: $($script:AllRules.Count)" -Level "SUCCESS"

# ============================================
# ANALYZE OBJECT USAGE
# ============================================

# ============================================
# ANALYZE OBJECT USAGE
# ============================================

Write-Log "" -Level "INFO"
Write-Log "============================================" -Level "INFO"
Write-Log "Analyzing Group Usage..." -Level "INFO"
Write-Log "============================================" -Level "INFO"
Write-Log "" -Level "INFO"

$groupInfoMap = @{}
$systemOwnedGroups = [System.Collections.Generic.HashSet[string]]::new()
$nonSystemOwnedGroups = [System.Collections.Generic.HashSet[string]]::new()

foreach ($group in $script:AllGroups) {
    $isSystem = Test-IsSystemObject -Object $group
    $groupDomain = "default"
    if ($group.path -match '/infra/domains/([^/]+)/') {
        $groupDomain = $Matches[1]
    }

    $groupInfoMap[$group.id] = @{
        id = $group.id
        display_name = $group.display_name
        description = $group.description
        path = $group.path
        domain_id = $groupDomain
        is_system_owned = $isSystem
        in_use = $false
    }

    if ($isSystem) {
        [void]$systemOwnedGroups.Add($group.id)
    } else {
        [void]$nonSystemOwnedGroups.Add($group.id)
    }
}

# Extract group references from rules
Write-Progress -Activity "Analyzing Groups" -Status "Checking rule references" -PercentComplete 50
$groupRefs = Get-GroupReferences -Rules $script:AllRules

foreach ($groupId in $groupRefs) {
    if ($groupInfoMap.ContainsKey($groupId)) {
        $groupInfoMap[$groupId].in_use = $true
    }
}

# Categorize groups
$usedGroups = @()
$unusedGroups = @()
$usedNonSystem = @()
$unusedNonSystem = @()

foreach ($groupId in $groupInfoMap.Keys) {
    $info = $groupInfoMap[$groupId]
    if ($info.in_use) {
        $usedGroups += $info
        if (-not $info.is_system_owned) { $usedNonSystem += $info }
    } else {
        $unusedGroups += $info
        if (-not $info.is_system_owned) { $unusedNonSystem += $info }
    }
}

Write-Progress -Activity "Analyzing Groups" -Completed

Write-Log "" -Level "INFO"
Write-Log "GROUPS IN USE: $($usedGroups.Count)" -Level "SUCCESS"
Write-Log "  - Used Non-System-Owned: $($usedNonSystem.Count)" -Level "INFO"
Write-Log "GROUPS NOT IN USE: $($unusedGroups.Count)" -Level "WARNING"
Write-Log "  - Unused Non-System-Owned: $($unusedNonSystem.Count)" -Level "INFO"

# ============================================
# ANALYZE SERVICE GROUP USAGE
# ============================================

# ============================================
# ANALYZE SERVICE GROUP USAGE
# ============================================

Write-Log "" -Level "INFO"
Write-Log "============================================" -Level "INFO"
Write-Log "Analyzing Service Group Usage..." -Level "INFO"
Write-Log "============================================" -Level "INFO"

$serviceGroupInfoMap = @{}
$usedServiceGroups = @()
$unusedServiceGroups = @()
$usedNonSystemSG = @()
$unusedNonSystemSG = @()

$serviceRefs = [System.Collections.Generic.HashSet[string]]::new()
foreach ($rule in $script:AllRules) {
    if ($rule.services) {
        foreach ($service in $rule.services) {
            $match = $Script:RegexGroupIdExtractor.Match($service)
            if ($match.Success) {
                [void]$serviceRefs.Add($match.Groups[1].Value)
            }
        }
    }
}

foreach ($sg in $script:AllServiceGroups) {
    $isSystem = Test-IsSystemObject -Object $sg
    $inUse = $serviceRefs.Contains($sg.id)

    $serviceGroupInfoMap[$sg.id] = @{
        id = $sg.id
        display_name = $sg.display_name
        description = $sg.description
        path = $sg.path
        is_system_owned = $isSystem
        in_use = $inUse
    }

    if ($inUse) {
        $usedServiceGroups += $serviceGroupInfoMap[$sg.id]
        if (-not $isSystem) { $usedNonSystemSG += $serviceGroupInfoMap[$sg.id] }
    } else {
        $unusedServiceGroups += $serviceGroupInfoMap[$sg.id]
        if (-not $isSystem) { $unusedNonSystemSG += $serviceGroupInfoMap[$sg.id] }
    }
}

Write-Log "" -Level "INFO"
Write-Log "SERVICE GROUPS IN USE: $($usedServiceGroups.Count)" -Level "SUCCESS"
Write-Log "  - Used Non-System-Owned: $($usedNonSystemSG.Count)" -Level "INFO"
Write-Log "SERVICE GROUPS NOT IN USE: $($unusedServiceGroups.Count)" -Level "WARNING"
Write-Log "  - Unused Non-System-Owned: $($unusedNonSystemSG.Count)" -Level "INFO"

function Remove-NSXObject {
    param(
        [string]$ObjectType,
        [string]$ObjectId,
        [string]$DisplayName,
        [string]$Path,
        [string]$DomainId
    )

    if ($ObjectType -eq "Group") {
        $uri = "$script:BaseUrl/infra/domains/$DomainId/groups/$ObjectId"
    } else {
        $uri = "$script:BaseUrl/infra/services/$ObjectId"
    }

    try {
        $params = @{
            Uri = $uri
            Method = "DELETE"
            Headers = $script:Headers
            ErrorAction = "Stop"
        }
        if ($script:SkipCert) { $params.SkipCertificateCheck = $true }
        $null = Invoke-RestMethod @params
        return @{ Success = $true; StatusCode = 200 }
    } catch {
        $statusCode = 0
        if ($_.Exception.Response) { $statusCode = $_.Exception.Response.StatusCode.value__ }
        if ($statusCode -eq 404) { return @{ Success = $true; StatusCode = 200 } }
        return @{ Success = $false; Error = $_.Exception.Message }
    }
}

# ============================================
# PERFORM DELETIONS
# ============================================

# Group deletion
if ($Groups) {
    $groupsToDelete = $unusedNonSystem | Where-Object { -not $_.is_system_owned -and -not $_.in_use }

    Write-Log "" -Level "INFO"
    Write-Log "Group deletion candidates: $($groupsToDelete.Count)" -Level "INFO"

    if (-not $Apply) {
        Write-Log "WHATIF MODE - No groups will be deleted" -Level "WARNING"
        foreach ($g in $groupsToDelete) {
            Record-DeletedObject -ObjectType "Group" -ObjectId $g.id -DisplayName $g.display_name -Status "WHATIF" -Message "Would be deleted (whatif mode)" -Path $g.path -Description $g.description
        }
    } else {
        $deleted = 0
        $failed = 0

        for ($i = 0; $i -lt $groupsToDelete.Count; $i += $BatchSize) {
            $batch = $groupsToDelete[$i..[Math]::Min($i + $BatchSize - 1, $groupsToDelete.Count - 1)]
            Write-Progress -Activity "Deleting Groups" -Status "Batch $($batch.Count) objects" -PercentComplete (($i / $groupsToDelete.Count) * 100)

            foreach ($g in $batch) {
                $result = Remove-NSXObject -ObjectType "Group" -ObjectId $g.id -DisplayName $g.display_name -Path $g.path -DomainId $g.domain_id
                if ($result.Success) {
                    $deleted++
                    Write-Log "DELETED: $($g.display_name)" -Level "SUCCESS"
                    Record-DeletedObject -ObjectType "Group" -ObjectId $g.id -DisplayName $g.display_name -Status "DELETED" -Message "Successfully deleted" -Path $g.path -Description $g.description
                } else {
                    $failed++
                    Write-Log "FAILED: $($g.display_name) - $($result.Error)" -Level "ERROR"
                    Record-DeletedObject -ObjectType "Group" -ObjectId $g.id -DisplayName $g.display_name -Status "FAILED" -Message $result.Error -Path $g.path -Description $g.description
                }
            }

            if ($BatchDelayMs -gt 0 -and $i + $BatchSize -lt $groupsToDelete.Count) {
                Start-Sleep -Milliseconds $BatchDelayMs
            }
        }
        Write-Progress -Activity "Deleting Groups" -Completed
        Write-Log "" -Level "INFO"
        Write-Log "Groups Deleted: $deleted" -Level "SUCCESS"
        if ($failed -gt 0) { Write-Log "Groups Failed: $failed" -Level "ERROR" }
    }
}

# Service group deletion
if ($ServiceGroups) {
    $sgToDelete = $unusedNonSystemSG

    Write-Log "" -Level "INFO"
    Write-Log "Service group deletion candidates: $($sgToDelete.Count)" -Level "INFO"

    if (-not $Apply) {
        Write-Log "WHATIF MODE - No service groups will be deleted" -Level "WARNING"
        foreach ($sg in $sgToDelete) {
            Record-DeletedObject -ObjectType "ServiceGroup" -ObjectId $sg.id -DisplayName $sg.display_name -Status "WHATIF" -Message "Would be deleted (whatif mode)" -Path $sg.path -Description $sg.description
        }
    } else {
        $deleted = 0
        $failed = 0

        for ($i = 0; $i -lt $sgToDelete.Count; $i += $BatchSize) {
            $batch = $sgToDelete[$i..[Math]::Min($i + $BatchSize - 1, $sgToDelete.Count - 1)]

            foreach ($sg in $batch) {
                $result = Remove-NSXObject -ObjectType "ServiceGroup" -ObjectId $sg.id -DisplayName $sg.display_name -Path $sg.path -DomainId ""
                if ($result.Success) {
                    $deleted++
                    Write-Log "DELETED: $($sg.display_name)" -Level "SUCCESS"
                    Record-DeletedObject -ObjectType "ServiceGroup" -ObjectId $sg.id -DisplayName $sg.display_name -Status "DELETED" -Message "Successfully deleted" -Path $sg.path -Description $sg.description
                } else {
                    $failed++
                    Write-Log "FAILED: $($sg.display_name) - $($result.Error)" -Level "ERROR"
                    Record-DeletedObject -ObjectType "ServiceGroup" -ObjectId $sg.id -DisplayName $sg.display_name -Status "FAILED" -Message $result.Error -Path $sg.path -Description $sg.description
                }
            }

            if ($BatchDelayMs -gt 0 -and $i + $BatchSize -lt $sgToDelete.Count) {
                Start-Sleep -Milliseconds $BatchDelayMs
            }
        }
        Write-Log "" -Level "INFO"
        Write-Log "Service Groups Deleted: $deleted" -Level "SUCCESS"
        if ($failed -gt 0) { Write-Log "Service Groups Failed: $failed" -Level "ERROR" }
    }
}

# ============================================
# FINAL SUMMARY
# ============================================

Export-DeletedObjects

$endTime = Get-Date
$duration = $endTime - $script:StartTime

Write-Log "" -Level "INFO"
Write-Log "============================================" -Level "INFO"
Write-Log "OPERATION COMPLETE" -Level "INFO"
Write-Log "============================================" -Level "INFO"
Write-Log "" -Level "INFO"

Write-Log "SUMMARY:" -Level "INFO"
Write-Log "  Groups processed:            $($script:AllGroups.Count)" -Level "INFO"
Write-Log "  Service groups processed:    $($script:AllServiceGroups.Count)" -Level "INFO"
Write-Log "  Security policies processed: $($script:AllPolicies.Count)" -Level "INFO"
Write-Log "  DFW rules processed:         $($script:AllRules.Count)" -Level "INFO"
Write-Log "  Total execution time:        $([math]::Round($duration.TotalSeconds, 2)) seconds" -Level "INFO"
Write-Log "" -Level "INFO"

Write-Log "============================================" -Level "INFO"
Write-Log "TASK COMPLETED SUCCESSFULLY" -Level "SUCCESS"
Write-Log "============================================" -Level "INFO"
