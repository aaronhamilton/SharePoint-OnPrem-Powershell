<#
    Suspend or Resume the Search Service 
#>

Add-PSSnapin Microsoft.SharePoint.Powershell

$name = Get-SPEnterpriseSearchServiceApplication | Select Name
$ssa = Get-SPEnterpriseSearchServiceApplication -Identity $name

# Suspend
$ssa | Suspend-SPEnterpriseSearchServiceApplication

# Resume
$ssa | Resume-SPEnterpriseSearchServiceApplication  
