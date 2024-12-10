<#
.SYNOPSIS
    This script checks for changes in Active Directory attributes for user or computer accounts across all domain controllers.

.DESCRIPTION
    The script identifies which properties have changed over a specified number of days for a given user or computer account. It queries all domain controllers and outputs a consolidated list of changes.

.PARAMETER DaysToCheck
    The number of days in the past to check for changes. If greater than 0, it will be converted to a negative value.

.PARAMETER AccountName
    The name of the user or computer account to check.

.PARAMETER ObjectType
    The type of account to check. Valid values are "User" and "Computer".

.EXAMPLE
    & 'C:\Scripts\PSFile.ps1' -DaysToCheck 7 -AccountName "jdoe" -ObjectType "User"
    This example checks for changes in the past 7 days for the user account "jdoe".

.EXAMPLE
    & 'C:\Scripts\PSFile.ps1' -DaysToCheck 7 -AccountName "COMP01" -ObjectType "Computer"
    This example checks for changes in the past 7 days for the computer account "COMP01".
#>

param (
    [Parameter(Mandatory=$true)]
    [int]$DaysToCheck,

    [Parameter(Mandatory=$true)]
    [string]$AccountName,

    [Parameter(Mandatory=$true)]
    [ValidateSet("User", "Computer")]
    [string]$ObjectType
)

if ($DaysToCheck -gt 0) {
    $DaysToCheck = -$DaysToCheck
}

$displayDays = [Math]::Abs($DaysToCheck)

Write-Output "Trying to find which properties changed in the past $displayDays days, for the $ObjectType account $AccountName. Please wait. `n"
$date = (Get-Date).AddDays($DaysToCheck)

if ($ObjectType -eq "User") {
    $account = Get-ADUser -Identity "$AccountName"
} elseif ($ObjectType -eq "Computer") {
    $account = Get-ADComputer -Identity "$AccountName"
}

$domainControllers = Get-ADDomainController -Filter *
$results = @()

foreach ($dc in $domainControllers) {
    try {
        $metadata = Get-ADReplicationAttributeMetadata -Object $account.DistinguishedName -Server $dc.HostName | Where-Object {$_.LastOriginatingChangeTime -gt $date -and $_.AttributeName -ne "lastLogonTimestamp"}
        foreach ($entry in $metadata) {
            $results += [PSCustomObject]@{
                AttributeName = $entry.AttributeName
                LastChangeTime = $entry.LastOriginatingChangeTime
                DomainController = $dc.HostName
            }
        }
    } catch {
        Write-Host "Error querying $($dc.HostName): $_"
    }
}

$results
param (
    [Parameter(Mandatory=$true)]
    [int]$DaysToCheck,

    [Parameter(Mandatory=$true)]
    [string]$AccountName,

    [Parameter(Mandatory=$true)]
    [ValidateSet("User", "Computer")]
    [string]$ObjectType
)

if ($DaysToCheck -gt 0) {
    $DaysToCheck = -$DaysToCheck
}

$displayDays = [Math]::Abs($DaysToCheck)

Write-Output "Trying to find which properties changed in the past $displayDays days, for the $ObjectType account $AccountName. Please wait. `n"
$date = (Get-Date).AddDays($DaysToCheck)

if ($ObjectType -eq "User") {
    $account = Get-ADUser -Identity "$AccountName"
} elseif ($ObjectType -eq "Computer") {
    $account = Get-ADComputer -Identity "$AccountName"
}

$domainControllers = Get-ADDomainController -Filter *
$results = @()

foreach ($dc in $domainControllers) {
    try {
        $metadata = Get-ADReplicationAttributeMetadata -Object $account.DistinguishedName -Server $dc.HostName | Where-Object {$_.LastOriginatingChangeTime -gt $date -and $_.AttributeName -ne "lastLogonTimestamp"}
        foreach ($entry in $metadata) {
            $results += [PSCustomObject]@{
                AttributeName = $entry.AttributeName
                LastChangeTime = $entry.LastOriginatingChangeTime
                DomainController = $dc.HostName
            }
        }
    } catch {
        Write-Host "Error querying $($dc.HostName): $_"
    }
}

$results