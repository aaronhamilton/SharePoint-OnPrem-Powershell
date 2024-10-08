<#
    Copy documents between Libraries by date range using ShareGate Migrate module (formerly called ShareGate Desktop)

    NOTE: ShareGate Migrate must be installed on your machine for the ShareGate PowerShell commands to work, and the module is automatically available on your system when you install it.   
    SEE ALSO: https://documentation.sharegate.com/hc/en-us/articles/115006079028-Use-Import-Module-when-you-launch-PowerShell-through-Windows
#>

Add-PSSnapin microsoft.Sharepoint.powershell

Import-Module Sharegate	

$thresholdInKiloBytes = 1000 # KB
$thresholdByDocCount = 1000 # documents
$srcURL = "http://site.domain.ca"
$srcLibraryTitle = "Help Guides"
$destURL = "http://site.domain.ca"
$destLibraryTitle = "Help Guides BACKUP"

<# -- Source library ------------------ #>
$srcSite = Connect-Site -Url $srcURL 
$srcList = Get-List -Site $srcSite -name $srcLibraryTitle
#$srcList

<# -- Destination library ------------------ #>
$dstSite = Connect-Site -Url $destURL
$dstList = Get-List -Site $dstSite -name $destLibraryTitle

Write-Host "You are about to copy from..."
Write-Host "$srcURL/$srcLibraryTitle" -ForegroundColor Cyan -NoNewline
Write-Host " to " -NoNewline
Write-Host "$destURL/$destLibraryTitle" -ForegroundColor Cyan  
$prompt = Read-Host -Prompt "Proceed? (y/n)"

if ($prompt -ne 'y') {
    return
} 

$stopwatch = [System.Diagnostics.Stopwatch]::startNew()
$stopwatch.Start()

# STEP 1 - Start date (previous batch's end date + 1)
$startDate = "2013-06-21"

# STEP 2 - define batch of records based on total file size
    # loop from StartDate, adding file sizes until you reach $thresholdInKB or $thresholdByDocCount
    # note the date as $endDate

$endDate = "2013-06-21"

# STEP 3

$copySettings = New-CopySettings -OnContentItemExists IncrementalUpdate -OnSiteObjectExists Merge 

$propertyTemplate = New-PropertyTemplate -From $startDate -To "2014-12-31" -AuthorsAndTimestamps -VersionHistory -Permissions -CheckInAs SameAsCurrent  -WebParts -NoLinkCorrection 
#-VersionLimit 5 

$result = Copy-Content -SourceList $srcList -DestinationList $dstList -CopySettings $copySettings -Template $propertyTemplate 	
$result 
#Export-Report -CopyResult $result -Path "C:\Reports\MyCopyListContentReports.xlsx"	

$stopwatch.Elapsed.Seconds
$stopwatch.Stop()

#$srcWeb = Get-SPWeb -Identity $srcURL
#$source==
#$web.Lists | select Name, Title






