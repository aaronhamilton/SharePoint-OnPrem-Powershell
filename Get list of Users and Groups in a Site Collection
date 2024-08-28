<#
    Get all Groups and Users in a Site Collection
    Output to CSV file
#>

Add-PSSnapin microsoft.sharepoint.powershell

$sites = Get-SPWebApplication http://site.domain.ca | Get-SPSite -limit all
"Site Collection`t Group`t User Name`t User Login" | out-file groupmembersreport.csv
foreach($site in $sites)
{
	$sitegroups = $site.RootWeb.SiteGroups #|?{$_.Name -EQ "Power Users"}
    foreach ($group in $sitegroups) {
	    foreach($user in $group.Users)
		    {	
		    "$($site.url) `t $($group.Name) `t $($user.displayname) `t $($user) " 
		    "$($site.url) `t $($group.Name) `t $($user.displayname) `t $($user) " | out-file groupmembersreport.csv -append
		    }
        }
    $site.Dispose()
}
