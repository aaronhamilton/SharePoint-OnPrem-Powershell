<# 
This cmdlet sets the application credential key on a local server for SharePoint by encrypting password for certain features
The application credential key must be identical on each server in the SP farm
#>

Add-PSSnapin microsoft.sharepoint.powershell

Set-SPApplicationCredentialKey -Password (ConvertTo-SecureString "password" -AsPlainText -force)

