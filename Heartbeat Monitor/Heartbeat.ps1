<#
    This script checked for a 'heartbeat' to ensure iSTAR's SharePoint repository is up and running
#>

try {
    if ((Get-PSSnapin "Microsoft.SharePoint.PowerShell" -ErrorAction SilentlyContinue) -eq $null)  
    { 
        Add-PSSnapin "Microsoft.SharePoint.PowerShell" 
    } 
} catch {}

## Set current folder path ##
$currentFolder = $PSScriptRoot
Set-Location -Path $currentFolder

# declare path to your Logs
$logPath = "$currentFolder\Logs"

# create path if not exists
if (-Not(Test-Path -Path $logPath)) {
    New-Item -Path $logPath -ItemType directory 
}


# Start transcript of headless Powershell session
$logOutput = Start-Transcript -OutputDirectory $logPath 
$split = $logOutput.split(" ")
$logOutputFilePath = $split[$split.Length-1]

$GlobalStartTime = $(get-date)

# == BEGIN ===============================================

$statusCode = wget https://krypton.oct.ca/docs/165 | % {$_.StatusCode}
write-host $statusCode

<#
$webURL = "https://xenon.oct.ca/docs/1"
$web = Get-SPWeb -Identity $webURL
$spDocumentLibrary  = $webURL + "/Case Stage Documents"  
$list = $web.GetList($spDocumentLibrary)
#$items = $list.GetItems()
$count = $list.Items.Count

foreach ($item in $items)
{
    #do whatever you need to do
}

# == END ===============================================
#>

$globalElapsedTime = $(get-date) - $GlobalStartTime; $GlobalTotalTime = "{0:HH:mm:ss}" -f ([datetime]$globalElapsedTime.Ticks)

Write-Host
Write-Host "Elapsed time: $globalElapsedTime " -ForegroundColor Gray

Stop-Transcript

