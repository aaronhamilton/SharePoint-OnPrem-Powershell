<#
    Returns a list of all MySites that contain documents 
    Useful for auditing or migration scenario
#>

Add-PSSnapin microsoft.sharepoint.powershell

function Get-SPMySitesWithData {
[CmdletBinding()]
Param(
[Parameter(Mandatory)][System.String]$MySiteHostUrl
)
Add-PSSnapin microsoft.sharepoint.powershell -ErrorAction stop;
[Object[]] $MySites = New-Object PSObject
$webapp = Get-SPWebApplication $MySiteHostUrl
$webapp.Sites | ForEach-Object {
$spweb = $_.RootWeb
$docsLib = $spweb.Lists["Documents"]
$siteSize = $spweb.Site.Usage.Storage/1MB
$siteSizeInMb = "{0:N2}" -f $siteSize

if($docsLib.Items.Count -gt 0)
{
[Object] $mysite = New-Object Management.Automation.PSObject;
$mysite | Add-Member -MemberType NoteProperty -Name SiteUrl -Value $spweb.Url
$mysite | Add-Member -MemberType NoteProperty -Name ItemCount -Value $docsLib.Items.Count.ToString()
$mysite | Add-Member -MemberType NoteProperty -Name "SiteSize(MB)" -Value $siteSizeInMb
$MySites += $mysite;
}
else
{
#Skipping my sites with 0 items, but if you wanted to do something with them here's where you'd do it!
}
$spweb.Dispose()
}
Write-Output $MySites 
Write-Output $MySites | Format-Table
}

# Run the function 
Get-SPMySitesWithData -MySiteHostUrl http://insite.oct.ca:1000



