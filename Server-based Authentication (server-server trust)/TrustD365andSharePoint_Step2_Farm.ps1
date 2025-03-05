# STEP 2
#
# This only needs to be run ONCE for each SharePoint web application
#
# Run the following on your on-prem SharePoint environment as Farm Administrator
#
# Sources: https://docs.microsoft.com/en-us/power-platform/admin/configure-server-based-authentication-sharepoint-on-premises
#

# --------------------------------------------------------------
# Step 1 - Bring in values from Step 1
# --------------------------------------------------------------

$SPOContextId = "403b5de9-f888-4fef-9eea-bd256ecec060" # your tenant's context ID

# ---------------------------------------------------------------------------------------------------
# Step 2 - STEPS TO RUN ON SHAREPOINT FARM - Save a reference to old auth realm
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

Write-Host "Copy this value for use in Step 3: ACSIssuer = $acsissuer"
