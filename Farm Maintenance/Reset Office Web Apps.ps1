# RUN THIS ENTIRE SCRIPT TO RE-SET THE CONNECTION TO OWA SERVER 'Orion' 

if(-not(Get-PSSnapin | where { $_.Name -eq "Microsoft.SharePoint.PowerShell"}))
{
      Add-PSSnapin Microsoft.SharePoint.PowerShell;
}

Function ConnectToOWA{
    Write-Host -f Cyan "Connecting this server to OWA..."
    New-SPWOPIBinding -ServerName Orion -AllowHTTP 
    Set-SPWopiZone internal-http

    Write-Host -f Cyan "Current OAuthOverHTTPSetting Set to:"

    Get-SPWOPIZone 
    (Get-SPSecurityTokenServiceConfig).AllowOAuthOverHttp

    $config = (Get-SPSecurityTokenServiceConfig)
    
    $config.AllowOAuthOverHttp = $true
    $config.Update()

    (Get-SPSecurityTokenServiceConfig).AllowOAuthOverHttp
    Write-Host -f Cyan "Reset OAuthOverHTTPSetting to 'True' "

    Write-Host -f Cyan "OWA connection Complete"
}

Function ResetOWA{
     Remove-SPWOPIBinding –All:$true
      Write-Host -f Cyan "Removed Current OWA configurations "
     ConnectToOWA
}

ResetOWA -ServerName "orion" -AllowHTTP $true



