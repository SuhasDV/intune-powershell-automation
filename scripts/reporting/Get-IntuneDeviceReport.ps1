#requires -Version 7.0

<#
.SYNOPSIS
    Generates an operational Microsoft Intune device report.

.DESCRIPTION
    Retrieves managed device information from Microsoft Graph
    and generates a CSV report containing device, operating
    system, compliance, and synchronization information.

    This is a portfolio demonstration project.
    No employer-specific, confidential, or production credentials
    are included.

.AUTHOR
    Suhas DV

.NOTES
    Required Microsoft Graph permission:
    DeviceManagementManagedDevices.Read.All

    Output:
    examples/sample-output/Intune-Device-Report.csv
#>

Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "       Microsoft Intune Device Report" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""

# Check Microsoft Graph module
if (-not (Get-Module -ListAvailable -Name Microsoft.Graph.DeviceManagement)) {

    Write-Host "Microsoft.Graph.DeviceManagement module is not installed." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Install it using:" -ForegroundColor Yellow
    Write-Host "Install-Module Microsoft.Graph.DeviceManagement -Scope CurrentUser"
    Write-Host ""

    exit
}

Import-Module Microsoft.Graph.DeviceManagement

# Connect to Microsoft Graph
Write-Host "Connecting to Microsoft Graph..." -ForegroundColor Cyan

Connect-MgGraph -Scopes "DeviceManagementManagedDevices.Read.All"

Write-Host "Connected successfully." -ForegroundColor Green
Write-Host ""

# Retrieve devices
Write-Host "Retrieving Intune managed devices..." -ForegroundColor Cyan

$Devices = Get-MgDeviceManagementManagedDevice -All

if (-not $Devices) {

    Write-Host "No managed devices were returned." -ForegroundColor Yellow

}
else {

    Write-Host "Devices retrieved: $($Devices.Count)" -ForegroundColor Green
    Write-Host ""

    # Create report directory
    $OutputDirectory = Join-Path $PSScriptRoot "../../examples/sample-output"

    if (-not (Test-Path $OutputDirectory)) {
        New-Item -ItemType Directory -Path $OutputDirectory -Force | Out-Null
    }

    # Create device report
    $DeviceReport = $Devices |
        Select-Object `
            DeviceName,
            UserPrincipalName,
            OperatingSystem,
            OSVersion,
            Manufacturer,
            Model,
            ComplianceState,
            ManagementAgent,
            LastSyncDateTime

    # Generate CSV report
    $OutputFile = Join-Path $OutputDirectory "Intune-Device-Report.csv"

    $DeviceReport |
        Export-Csv -Path $OutputFile -NoTypeInformation

    Write-Host "Report generated successfully." -ForegroundColor Green
    Write-Host ""
    Write-Host "Output file:" -ForegroundColor Cyan
    Write-Host $OutputFile -ForegroundColor White
    Write-Host ""

    # Display compliance summary
    Write-Host "========== Compliance Summary ==========" -ForegroundColor Cyan

    $DeviceReport |
        Group-Object -Property ComplianceState |
        Select-Object Name, Count |
        Sort-Object Name |
        Format-Table -AutoSize
}

# Disconnect
Disconnect-MgGraph

Write-Host ""
Write-Host "Microsoft Graph session disconnected." -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Cyan
