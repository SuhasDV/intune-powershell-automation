<#
.SYNOPSIS
    Retrieves Intune managed device details using Microsoft Graph API.

.DESCRIPTION
    This script connects to Microsoft Graph and retrieves read-only
    information about devices managed by Microsoft Intune.

    The script demonstrates:
    - Microsoft Graph PowerShell
    - Intune managed device API
    - Device inventory retrieval
    - OData filtering
    - PowerShell objects
    - CSV reporting

.NOTES
    Portfolio Project
    Read-only operation
    No device configuration or modification is performed.

.REQUIRED PERMISSIONS
    DeviceManagementManagedDevices.Read.All

.EXAMPLE
    .\Get-GraphDeviceDetails.ps1

.EXAMPLE
    .\Get-GraphDeviceDetails.ps1 -ExportPath "C:\Temp\IntuneDevices.csv"

.EXAMPLE
    .\Get-GraphDeviceDetails.ps1 -OperatingSystem Windows
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [ValidateSet("Windows", "macOS", "iOS", "Android")]
    [string]$OperatingSystem,

    [Parameter(Mandatory = $false)]
    [string]$ExportPath
)

# ------------------------------------------------------------
# Configuration
# ------------------------------------------------------------

$GraphModule = "Microsoft.Graph.Authentication"
$GraphEndpoint = "https://graph.microsoft.com/v1.0/deviceManagement/managedDevices"

# ------------------------------------------------------------
# Function: Test-GraphModule
# ------------------------------------------------------------

function Test-GraphModule {

    Write-Host ""
    Write-Host "Checking Microsoft Graph PowerShell module..." -ForegroundColor Cyan

    if (-not (Get-Module -ListAvailable -Name $GraphModule)) {

        Write-Host ""
        Write-Host "Microsoft Graph PowerShell module is not installed." `
            -ForegroundColor Yellow

        Write-Host ""
        Write-Host "Install it using:" -ForegroundColor White
        Write-Host "Install-Module Microsoft.Graph -Scope CurrentUser" `
            -ForegroundColor Gray

        return $false
    }

    Write-Host "Microsoft Graph module found." -ForegroundColor Green

    return $true
}

# ------------------------------------------------------------
# Function: Connect-ToGraph
# ------------------------------------------------------------

function Connect-ToGraph {

    Write-Host ""
    Write-Host "Connecting to Microsoft Graph..." -ForegroundColor Cyan

    try {

        Connect-MgGraph `
            -Scopes "DeviceManagementManagedDevices.Read.All" `
            -NoWelcome

        $Context = Get-MgContext

        if ($null -eq $Context) {

            Write-Host ""
            Write-Host "Microsoft Graph authentication failed." `
                -ForegroundColor Red

            return $false
        }

        Write-Host ""
        Write-Host "Connected successfully." -ForegroundColor Green

        Write-Host "Account : $($Context.Account)" `
            -ForegroundColor Gray

        Write-Host "Tenant  : $($Context.TenantId)" `
            -ForegroundColor Gray

        return $true
    }
    catch {

        Write-Host ""
        Write-Host "Graph authentication error:" `
            -ForegroundColor Red

        Write-Host $_.Exception.Message `
            -ForegroundColor Red

        return $false
    }
}

# ------------------------------------------------------------
# Function: Get-IntuneManagedDevices
# ------------------------------------------------------------

function Get-IntuneManagedDevices {

    param(
        [string]$OperatingSystem
    )

    Write-Host ""
    Write-Host "Retrieving Intune managed devices..." `
        -ForegroundColor Cyan

    try {

        $SelectProperties = @(
            "id",
            "deviceName",
            "operatingSystem",
            "osVersion",
            "manufacturer",
            "model",
            "serialNumber",
            "userPrincipalName",
            "userDisplayName",
            "managedDeviceOwnerType",
            "complianceState",
            "managementAgent",
            "lastSyncDateTime",
            "enrolledDateTime",
            "azureADDeviceId"
        )

        $SelectQuery = $SelectProperties -join ","

        $Uri = "$GraphEndpoint" +
               "?`$select=$SelectQuery"

        if ($OperatingSystem) {

            $Filter = [System.Uri]::EscapeDataString(
                "operatingSystem eq '$OperatingSystem'"
            )

            $Uri = "$Uri&`$filter=$Filter"
        }

        $Devices = @()

        do {

            $Response = Invoke-MgGraphRequest `
                -Method GET `
                -Uri $Uri

            if ($Response.value) {

                $Devices += $Response.value
            }

            $Uri = $Response.'@odata.nextLink'

        } while ($Uri)

        Write-Host ""
        Write-Host "Devices retrieved: $($Devices.Count)" `
            -ForegroundColor Green

        return $Devices
    }
    catch {

        Write-Host ""
        Write-Host "Unable to retrieve Intune devices." `
            -ForegroundColor Red

        Write-Host $_.Exception.Message `
            -ForegroundColor Red

        return $null
    }
}

# ------------------------------------------------------------
# Function: Format-DeviceResults
# ------------------------------------------------------------

function Format-DeviceResults {

    param(
        [array]$Devices
    )

    $Results = foreach ($Device in $Devices) {

        [PSCustomObject]@{

            DeviceName          = $Device.deviceName
            OperatingSystem     = $Device.operatingSystem
            OSVersion           = $Device.osVersion
            Manufacturer        = $Device.manufacturer
            Model               = $Device.model
            SerialNumber        = $Device.serialNumber
            User                = $Device.userDisplayName
            UserPrincipalName   = $Device.userPrincipalName
            Ownership           = $Device.managedDeviceOwnerType
            ComplianceState     = $Device.complianceState
            ManagementAgent     = $Device.managementAgent
            LastSync            = $Device.lastSyncDateTime
            EnrolledDate        = $Device.enrolledDateTime
            AzureADDeviceId     = $Device.azureADDeviceId
            IntuneDeviceId      = $Device.id
        }
    }

    return $Results
}

# ------------------------------------------------------------
# Function: Export-DeviceReport
# ------------------------------------------------------------

function Export-DeviceReport {

    param(
        [array]$Data,
        [string]$Path
    )

    try {

        $Directory = Split-Path `
            -Path $Path `
            -Parent

        if ($Directory -and -not (Test-Path $Directory)) {

            New-Item `
                -ItemType Directory `
                -Path $Directory `
                -Force | Out-Null
        }

        $Data | Export-Csv `
            -Path $Path `
            -NoTypeInformation `
            -Encoding UTF8

        Write-Host ""
        Write-Host "Report exported successfully:" `
            -ForegroundColor Green

        Write-Host $Path -ForegroundColor Gray
    }
    catch {

        Write-Host ""
        Write-Host "CSV export failed." `
            -ForegroundColor Red

        Write-Host $_.Exception.Message `
            -ForegroundColor Red
    }
}

# ------------------------------------------------------------
# MAIN EXECUTION
# ------------------------------------------------------------

Write-Host ""
Write-Host "============================================" `
    -ForegroundColor Cyan

Write-Host "   INTUNE GRAPH DEVICE DETAILS TOOLKIT" `
    -ForegroundColor Cyan

Write-Host "============================================" `
    -ForegroundColor Cyan

Write-Host ""

# Check Graph module

if (-not (Test-GraphModule)) {
    return
}

# Import authentication module

Import-Module Microsoft.Graph.Authentication -ErrorAction Stop

# Connect to Microsoft Graph

if (-not (Connect-ToGraph)) {
    return
}

# Retrieve devices

$Devices = Get-IntuneManagedDevices `
    -OperatingSystem $OperatingSystem

if ($null -eq $Devices -or $Devices.Count -eq 0) {

    Write-Host ""
    Write-Host "No Intune managed devices were returned." `
        -ForegroundColor Yellow

    Disconnect-MgGraph | Out-Null

    return
}

# Format results

$Results = Format-DeviceResults `
    -Devices $Devices

# Display results

Write-Host ""
Write-Host "============================================" `
    -ForegroundColor Cyan

Write-Host "DEVICE INVENTORY" `
    -ForegroundColor Cyan

Write-Host "============================================" `
    -ForegroundColor Cyan

$Results |
    Select-Object `
        DeviceName,
        OperatingSystem,
        OSVersion,
        Manufacturer,
        Model,
        User,
        ComplianceState,
        LastSync |
    Format-Table -AutoSize

# Export if requested

if ($ExportPath) {

    Export-DeviceReport `
        -Data $Results `
        -Path $ExportPath
}

# Disconnect

Write-Host ""
Write-Host "Disconnecting from Microsoft Graph..." `
    -ForegroundColor Cyan

Disconnect-MgGraph | Out-Null

Write-Host ""
Write-Host "Script completed successfully." `
    -ForegroundColor Green

Write-Host ""
