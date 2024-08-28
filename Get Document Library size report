<#
    Get Document Library size report
#>


cls

$Site = Get-SPsite "http://site.domain.ca/web"
 
#Returns a DataTable similar to "Storage Management Page" in Site settings
$DataTable = $Site.StorageManagementInformation(2,0x11,0,0)
 
#Loop through the Rows and Fetch the row matching "Shared Documents" in subsite "team"
foreach($Row in $DataTable.Rows)
{
    #if ($Row.Title -eq "OpinionsDatabase" ) #-and $Row.Directory -eq "team")
    #    {
     #       $LibrarySize = [Math]::Round(($Row.Size/1MB),2)
      #      Write-Host $row.WebUrl $Row.Title $LibrarySize "MB"
    #    }
}

foreach($Row in $DataTable.Rows)
{
    #if ($Row.Title -eq "OpinionsDatabase" ) #-and $Row.Directory -eq "team")
    #    {
            $LibrarySize = [Math]::Round(($Row.Size/1MB),2)
            Write-Host "$($row.WebUrl)`t$($Row.Title)`t$($LibrarySize)`tMB";
    #    }
}

#Read more: https://www.sharepointdiary.com/2013/01/get-sharepoint-library-size-powershell.html#ixzz8B9JK9eeB
