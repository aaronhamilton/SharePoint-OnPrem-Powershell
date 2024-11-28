<#
  Following the installation of Cumulative Updates (but before you run Sp Configuration Wizard) 
  you should run this script on each farm server to update the schema of each content database.
  
  Why use this script?
  Because you can run in parallel on multiple servers in your farm to shorten the time
  Otherwise you could let Config Wizard do it, but it won't be in parallel and will taken longer.

  If this still is not fast enough... 
    1. Dismount all content databases
        Dismount-SPContentDatabase -Identity 
    2. Apply patches to farm (using Russ Max's script)
    3. Run PSConfig to upgrade farm 
    4. Re-attach all databases to farm - without build-to-build upgrade
        Mount-SPContentDatabase -SkipSiteUpgrade 
  SOURCE: https://tishenko.com/speed-up-sharepoint-patching-by-disconnecting-content-database
#>

Add-PSSnapin Microsoft.SharePoint.Powershell

<# PREPARATION
1. Open this script on all three SP servers
2. Do not run the script from beginning to end - you must run the commands one-at-a-time
3. As you go, be mindful of which server you are on
#>

# STEP 1 - Run the following to collect all DB Names 
$DBsAll = Get-SPContentDatabase | select Name, Id, Server, WebApplication 
Write-Host "Total Content DBs: $($DBsAll.Count)"

# STEP 2 - run the following to commence database update process from this server 
$stopwatch = [System.Diagnostics.Stopwatch]::new(); $stopwatch2 = [System.Diagnostics.Stopwatch]::new()
$stopwatch.Reset(); $stopwatch.Start()
write-Host "Starting Content DB Updates..."
$counter = 0;
foreach ($db in $DBsAll) {
    $stopwatch2.Reset(); $stopwatch2.Start()
    $counter++
    write-host "$($counter) - $($db.Name) $($db.id)" -nonewline
    Upgrade-SPContentDatabase -Name $db.name -WebApplication $db.WebApplication -confirm:$false
    Write-Host "   $($stopwatch2.Elapsed.Minutes) minutes $($stopwatch2.Elapsed.Seconds) seconds" -foregroundcolor Green
}
Write-Host "TOTAL ELAPSED MINUTES: $($stopwatch.Elapsed.Minutes) minutes $($stopwatch.Elapsed.Seconds) seconds"
$stopwatch.Stop()

# STEP 3 - when all three servers have completed upgrading their databases
# psconfigui.exe   # --->  NOTE: run on server running Central Admin first

