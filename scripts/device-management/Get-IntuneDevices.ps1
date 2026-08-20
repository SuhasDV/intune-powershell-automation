#requires -Version 7.0

<#
.SYNOPSIS
    Retrieves Microsoft Intune managed devices using Microsoft Graph API.

.DESCRIPTION
    Connects to Microsoft Graph and retrieves managed device information
    from Microsoft Intune.

    This is a portfolio demonstration project.
    No employer-specific, confidential, or production credentials are used.

.AUTHOR
    Suhas DV

.NOTES
    Required Microsoft Graph permissions:
    - DeviceManagementManagedDevices.Read.All

    Microsoft Graph PowerShell SDK:
    Microsoft.Graph.DeviceManagement
#>

Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "       Microsoft Intune Device Report" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""

# Check whether Microsoft Graph module is installed
if (-not (Get-Module -ListAvailable -Name Microsoft.Graph.DeviceManagement)) {

    Write-Host "Microsoft.Graph.DeviceManagement module is not installed." -ForegroundColor Yellow
    Write-Host "Install it using:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Install-Module Microsoft.Graph.DeviceManagement -Scope CurrentUser" -ForegroundColor White
    Write-Host ""

    exit
}

# Import Microsoft Graph module
Import-Module Microsoft.Graph.DeviceManagement

# Connect to Microsoft Graph
Write-Host "Connecting to Microsoft Graph..." -ForegroundColor Cyan

Connect-MgGraph -Scopes "DeviceManagementManagedDevices.Read.All"

Write-Host "Connected successfully." -ForegroundColor Green
Write-Host ""

# Retrieve Intune managed devices
Write-Host "Retrieving Intune managed devices..." -ForegroundColor Cyan

$Devices = Get-MgDeviceManagementManagedDevice -All

# Check whether devices were returned
if (-not $Devices) {

    Write-Host "No Intune managed devices were returned." -ForegroundColor Yellow

}
else {

    Write-Host ""
    Write-Host "Total managed devices: $($Devices.Count)" -ForegroundColor Green
    Write-Host ""

    # Select useful device information
    $DeviceReport = $Devices |
        Select-Object `
            DeviceName,
            OperatingSystem,
            OSVersion,
            Manufacturer,
            Model,
            ComplianceState,
            ManagementAgent,
            LastSyncDateTime

    # Display report
    $DeviceReport |
        Format-Table -AutoSize
}

# Disconnect from Microsoft Graph
Disconnect-MgGraph

Write-Host ""
Write-Host "Microsoft Graph session disconnected." -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Cyan
