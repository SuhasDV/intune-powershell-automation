#requires -Version 7.0

<#
.SYNOPSIS
    Retrieves Microsoft Intune applications using Microsoft Graph API.

.DESCRIPTION
    Connects to Microsoft Graph and retrieves application information
    configured in Microsoft Intune.

    This is a portfolio demonstration project.
    No employer-specific, confidential, or production credentials are used.

.AUTHOR
    Suhas DV

.NOTES
    Required Microsoft Graph permission:
    DeviceManagementApps.Read.All
#>

Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "       Microsoft Intune Application Report" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""

# Check Microsoft Graph module
if (-not (Get-Module -ListAvailable -Name Microsoft.Graph.DeviceManagement)) {

    Write-Host "Microsoft Graph Device Management module is not installed." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Install it using:" -ForegroundColor Yellow
    Write-Host "Install-Module Microsoft.Graph.DeviceManagement -Scope CurrentUser"
    Write-Host ""

    exit
}

Import-Module Microsoft.Graph.DeviceManagement

# Connect to Microsoft Graph
Write-Host "Connecting to Microsoft Graph..." -ForegroundColor Cyan

Connect-MgGraph -Scopes "DeviceManagementApps.Read.All"

Write-Host "Connected successfully." -ForegroundColor Green
Write-Host ""

# Retrieve Intune applications
Write-Host "Retrieving Intune applications..." -ForegroundColor Cyan

$Applications = Get-MgDeviceAppManagementMobileApp -All

if (-not $Applications) {

    Write-Host "No Intune applications were returned." -ForegroundColor Yellow

}
else {

    Write-Host ""
    Write-Host "Total applications: $($Applications.Count)" -ForegroundColor Green
    Write-Host ""

    $ApplicationReport = $Applications |
        Select-Object `
            DisplayName,
            Description,
            Publisher,
            CreatedDateTime,
            LastModifiedDateTime,
            PublishingState

    $ApplicationReport |
        Format-Table -AutoSize
}

# Disconnect from Microsoft Graph
Disconnect-MgGraph

Write-Host ""
Write-Host "Microsoft Graph session disconnected." -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Cyan
