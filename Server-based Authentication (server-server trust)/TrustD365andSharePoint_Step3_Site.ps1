# STEP 3
#
# This must be run ONCE for each SharePoint site collection
#
# Run the following on your on-prem SharePoint environment as Farm Administrator
#
# Sources: https://docs.microsoft.com/en-us/power-platform/admin/configure-server-based-authentication-sharepoint-on-premises
#

# --------------------------------------------------------------
# Step 1 - Bring in values from Step 2
#        - Supply URL of your SP site
# --------------------------------------------------------------

$Issuer = "00000007-0000-0000-c000-000000000000@403b5de9-f888-4fef-9eea-bd256ecec060"

$siteURL = "https://krypton.oct.ca/docs/1/"   # e.g. "https://krypton.oct.ca/docs/1/"

# ------------------------------------------------------------------------------------------------------------
# Step 2 - STEPS TO RUN ON EACH SITE COLLECTION - Grants customer engagement apps permission to access SharePoint and configure the claims-based authentication mapping
# -------------------------------------------------------------------------------------------------------------

# 1.Register customer engagement apps with the SharePoint site collection.
$spSite = Get-SPSite $siteURL   # "https://krypton.oct.ca/docs/1/" https://krypton.oct.ca/sites/phoenix-docs-03  
Register-SPAppPrincipal -site $spSite.RootWeb -NameIdentifier $Issuer -DisplayName "Phoenix Docs"  

# 2.Grant customer engagement apps access to the SharePoint site.
$app = Get-SPAppPrincipal -NameIdentifier $Issuer -Site $spSite.Rootweb 
Set-SPAppPrincipalPermission -AppPrincipal $app -Site $spSite.Rootweb -Scope "sitecollection" -Right "FullControl"  # -EnableAppOnlyPolicy

# 3.Set the claims-based authentication mapping type.
$map1 = New-SPClaimTypeMapping -IncomingClaimType "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress" -IncomingClaimTypeDisplayName "EmailAddress" -SameAsIncoming

$spSite.Dispose()

# ---------------------------------------
# Troubleshooting - remove app principal
# ---------------------------------------

$siteURL = "https://krypton.oct.ca"
$spSite = Get-SPSite $siteURL    

$appPrincipal = Get-SPAppPrincipal -Site $spSite.RootWeb  -NameIdentifier $Issuer 

$spSite = Get-SPSite -Identity $site
Remove-SPAppPrincipalPermission -AppPrincipal $appPrincipal -Site $spSite.RootWeb -Scope SiteCollection # Site
$spSite.Dispose()
