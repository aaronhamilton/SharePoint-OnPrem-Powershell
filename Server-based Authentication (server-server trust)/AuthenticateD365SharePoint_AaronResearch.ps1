# Sources
# Reference provided by D365 -  
# Current documentati9on - https://docs.microsoft.com/en-us/power-platform/admin/configure-server-based-authentication-sharepoint-on-premises

# --------------
# Azure
# --------------

# --------------------------------------------------------------
# Step 1 - Prepare Powershell Session
# --------------------------------------------------------------
Enable-PSRemoting -force  
New-PSSession  
Import-Module MSOnline -force  
Import-Module MSOnlineExt -force

# --------------------------------------------------------------
# Step 2 - Connect to Office 365
# --------------------------------------------------------------

$msolcred = get-credential  # ahamilton@oct.ca
connect-msolservice -credential $msolcred 

# --------------------------------------------------------------
# Step 3 - Set SharePoint host name
# --------------------------------------------------------------

$HostName = "krypton.oct.ca"

# --------------------------------------------------------------
# Step 4 - Get Office 365 object id (tenant id) and SharePoint Server Service Principal Name (SPN)
# --------------------------------------------------------------
$SPOAppId = "00000003-0000-0ff1-ce00-000000000000" # Office 365 SharePoint Online

$SPOContextId = (Get-MsolCompanyInformation).ObjectID  
# 403b5de9-f888-4fef-9eea-bd256ecec060" # octoeeo.microsoft.com
$SharePoint = Get-MsolServicePrincipal -AppPrincipalId $SPOAppId  
$ServicePrincipalName = $SharePoint.ServicePrincipalNames
# 00000003-0000-0ff1-ce00-000000000000/argon.oct.ca
# https://microsoft.sharepoint-df.com
# 00000003-0000-0ff1-ce00-000000000000/*.sharepoint.com
# 00000003-0000-0ff1-ce00-000000000000

# --------------------------------------------------------------
# Step 5 - set the SharePoint Service Principal Name in Azure AD
# --------------------------------------------------------------

$ServicePrincipalName.Add("$SPOAppId/$HostName") # adding 00000003-0000-0ff1-ce00-000000000000/krypton.oct.ca
Set-MsolServicePrincipal -AppPrincipalId $SPOAppId -ServicePrincipalNames $ServicePrincipalName

# ---------------------------------------------------------------------------------------------------
# Step 6 - STEPS TO RUN ON SHAREPOINT FARM - Save a reference to old auth realm
# ---------------------------------------------------------------------------------------------------
   
$oldRealm = Get-SPAuthenticationRealm

# oldRealm
# 0df386f1-9fef-4002-9c9b-c4264cc9edde  <-- this is the old auth realm GUID, which we're about to change

# ---------------------------------------------------------------------------------------------------
# Step 7 - update the SharePoint Realm to match that of SharePoint Online
# ---------------------------------------------------------------------------------------------------

# running this command requires SP farm administrator membership
# running this command sets the authentication realm
# if you farm has a pre-existing security token service (STS) this may cause unexpected behavior

Set-SPAuthenticationRealm -Realm $SPOContextId # i.e. 403b5de9-f888-4fef-9eea-bd256ecec060

# ---------------------------------------------------------------------------------------------------
# Step 8 - enable Powershell service to make changes to security token service for the SharePoint farm
# ---------------------------------------------------------------------------------------------------

$c = Get-SPSecurityTokenServiceConfig 
$c.AllowMetadataOverHttp = $true
$c.AllowOAuthOverHttp = $true
$c.Update()  

# ---------------------------------------------------------------------------------------------------
# Step 9 - set the metadata endpoint 
# ---------------------------------------------------------------------------------------------------

$metadataEndpoint = "https://accounts.accesscontrol.windows.net/" + $SPOContextId + "/metadata/json/1"  
$acsissuer = "00000001-0000-0000-c000-000000000000@" + $SPOContextId  
$issuer = "00000007-0000-0000-c000-000000000000@" + $SPOContextId

# ---------------------------------------------------------------------------------------------------
# Step 10 - create the new token control service application proxy in Azure Active Directory
# ---------------------------------------------------------------------------------------------------

# you may receive an error that a proxy with same name already exists - ignore this error
New-SPAzureAccessControlServiceApplicationProxy -Name "Internal" -MetadataServiceEndpointUri $metadataEndpoint -DefaultProxyGroup 

# ------------------------------------------------------------------------------------------------------------
# Step 11 - Create the new token control service issuer in SharePoint on-premises for Azure Active Directory.
# -------------------------------------------------------------------------------------------------------------

# Check if you already have an issuer in place
Get-SPTrustedSecurityTokenIssuer

# if it doesn't already exist, create it
$acs = New-SPTrustedSecurityTokenIssuer –Name "ACSInternal" –IsTrustBroker:$true –MetadataEndpoint $metadataEndpoint -RegisteredIssuerName $acsissuer 

# ------------------------------------------------------------------------------------------------------------
# Step 11 - STEPS TO RUN ON EVERY SITE COLLECTION - Grant customer engagement apps permission to access SharePoint and configure the claims-based authentication mapping
# -------------------------------------------------------------------------------------------------------------

# 1.Register customer engagement apps with the SharePoint site collection.
$siteURL = "https://krypton.oct.ca"
$spSite = Get-SPSite $siteURL   # "https://krypton.oct.ca/docs/1/" https://krypton.oct.ca/sites/phoenix-docs-03  
Register-SPAppPrincipal -site $spSite.RootWeb -NameIdentifier $issuer -DisplayName "Phoenix Docs"  

# 2.Grant customer engagement apps access to the SharePoint site.
$app = Get-SPAppPrincipal -NameIdentifier $issuer -Site $spSite.Rootweb 
Set-SPAppPrincipalPermission -AppPrincipal $app -Site $spSite.Rootweb -Scope "sitecollection" -Right "FullControl"  # -EnableAppOnlyPolicy

# 3.Set the claims-based authentication mapping type.
$map1 = New-SPClaimTypeMapping -IncomingClaimType "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress" -IncomingClaimTypeDisplayName "EmailAddress" -SameAsIncoming

$spSite.Dispose()

# ---------------------------------------
# Troubleshooting - remove app principal
# ---------------------------------------

$siteURL = "https://krypton.oct.ca"
$spSite = Get-SPSite $siteURL    

$appPrincipal = Get-SPAppPrincipal -Site $spSite.RootWeb  -NameIdentifier $issuer 

$spSite = Get-SPSite -Identity $site
Remove-SPAppPrincipalPermission -AppPrincipal $appPrincipal -Site $spSite.RootWeb -Scope SiteCollection # Site
$spSite.Dispose()

