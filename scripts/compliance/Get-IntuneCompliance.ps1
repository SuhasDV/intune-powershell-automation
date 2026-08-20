#requires -Version 7.0

<#
.SYNOPSIS
    Retrieves Microsoft Intune device compliance information.

.DESCRIPTION
    Connects to Microsoft Graph and retrieves managed device
    compliance information from Microsoft Intune.

    This is a portfolio demonstration project.
    No employer-specific, confidential, or production credentials
    are included.

.AUTHOR
    Suhas DV

.NOTES
    Required Microsoft Graph permission:
    DeviceManagementManagedDevices.Read.All
#>

Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "       Microsoft Intune Compliance Report" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""

# Check whether Microsoft Graph module is installed
if (-not (Get-Module -ListAvailable -Name Microsoft.Graph.DeviceManagement)) {

    Write-Host "Microsoft.Graph.DeviceManagement module is not installed." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Install it using:" -ForegroundColor Yellow
    Write-Host "Install-Module Microsoft.Graph.DeviceManagement -Scope CurrentUser"
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
Write-Host "Retrieving device compliance information..." -ForegroundColor Cyan

$Devices = Get-MgDeviceManagementManagedDevice -All

if (-not $Devices) {

    Write-Host "No managed devices were returned." -ForegroundColor Yellow

}
else {

    Write-Host ""
    Write-Host "Total managed devices: $($Devices.Count)" -ForegroundColor Green
    Write-Host ""

    # Create compliance report
    $ComplianceReport = $Devices |
        Select-Object `
            DeviceName,
            UserPrincipalName,
            OperatingSystem,
            OSVersion,
           
