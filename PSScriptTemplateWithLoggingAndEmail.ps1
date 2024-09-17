<# 
TEMPLATE 
#>
param(
    [boolean]$sendNotificationEmail = $true,
    [string[]]$EmailRecipients = @("ahamilton@oct.ca","jsmith@oct.ca")
    [string]$ScriptRunningOn = "Script: URSA d:\_PSJobs\SPPermissionSync\_Bootstrap",
    [switch]$AlwaysSyncToSP = $true,
    [switch]$PromptBeforeSync = $false
    )

$JobName = "IRIS - SharePoint Permissions Sync - "

$snapin = Get-PsSnapin Microsoft.SharePoint.PowerShell -ea SilentlyContinue

if ($snapin -eq $null) {
    Add-PsSnapin Microsoft.SharePoint.PowerShell
}

try {

    # set current folder to equal execution path of script (if desired)
    $currentFolder = $PSScriptRoot 
    cd $currentFolder

    # add your ps1 includes here... for example,
    . .\CommonFunctions.ps1

    # declare path to your Logs
    $logPath = "$currentFolder\Logs"

    # create path if not exists
    if (-Not(Test-Path -Path $logPath)) {
        New-Item -Path $logPath -ItemType directory 
    }

    # Statrt transcript of headless Powershell session
    $logOutput = Start-Transcript -OutputDirectory $logPath 
    $split = $logOutput.split(" ")
    $logOutputFilePath = $split[$split.Length-1]

    $GlobalStartTime = $(get-date)

    #
    # do all your stuff here
    #

    # Reporting - compile everything into a report for display and email (if required)
    $averageUsersPerSite = [math]::Round($totalUsersAllSites/$counter) #example
    $averageGroupsPerSite = [math]::Round($totalGroupssAllSites/$counter)  #example
    $report = "Users per site: $averageUsersPerSite (across all security groups)"  #example
    $report += "`nGroups per site: $averageGroupsPerSite" #example
    if ($script:NewUsers.Count -gt 0) {  #example
        $report += "`n`nUsers added"  #example
        $report += "`n" + $script:NewUsers   #example
    }  #example
    if ($script:UsersRemoved.Count -gt 0) {  #example
        $report += "`n`nUsers removed"  #example
        $report += "`n" + $script:UsersRemoved  #example
    } #example

    # output report to screen
    Write-host; Write-Host $report

    $globalElapsedTime = $(get-date) - $GlobalStartTime; $GlobalTotalTime = "{0:HH:mm:ss}" -f ([datetime]$globalElapsedTime.Ticks)
    Write-Host; Write-Host "Elapsed time: $globalElapsedTime " -ForegroundColor Gray

    # Send email if necessary 
    [string]$msg = "$JobName - Job completed in $globalElapsedTime"
    [string]$body = "Total time was $globalElapsedTime for $JobName "
    $body += "`n`n$report"
    . .\SendEmail.ps1 -subject $msg -body $body -recipientEmail $EmailRecipient

    Stop-Transcript 
}
catch {
    Write-Host
    $exceptions = "`n"
    $exceptions += $_.Exception.Message + "`n"
    $exceptions += $_.ScriptStackTrace + "`n"
    Write-Host $exceptions -ForegroundColor Red
    $exceptions += "`n`n$ScriptRunningOn`nLog: $logOutputFilePath"
    $msg = "$JobName Exception occurred"
    $body = $exceptions
    . .\SendEmail.ps1 -subject $msg -body $body -recipientEmail $EmailRecipient -BodyAsHTML $false 

    Stop-Transcript 
}


