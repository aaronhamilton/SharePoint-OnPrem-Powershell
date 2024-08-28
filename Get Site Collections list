<# 
Get all Site collections with Owner Emails    
#>

Add-PSSnapin microsoft.sharepoint.powershell

Get-SPWebApplication "http://site.domain.ca" | Get-SPSite | foreach-object { Write-host $_.Url - $_.Owner.Email}
