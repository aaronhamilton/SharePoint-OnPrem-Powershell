<# 
Get list of all webs within a specified Site collection
#>

Add-PSSnapin microsoft.sharepoint.powershell

$web = Get-SPWeb -Identity http://site.domain.ca

$childwebs = $web.Webs

cls
foreach ($child in $childwebs) {
    Write-Host "$child`t$($child.Url)" | format-table
    #return
}
