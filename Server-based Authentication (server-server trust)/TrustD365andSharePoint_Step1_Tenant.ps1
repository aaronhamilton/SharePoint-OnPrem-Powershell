# STEP 1
#
# This only needs to be run ONCE for each SharePoint web application
#
# Run the following on any PC that permits you to connect to SharePoint Online Services
#
# Sources: https://docs.microsoft.com/en-us/power-platform/admin/configure-server-based-authentication-sharepoint-on-premises
#
# --------------------------------------------------------------
# Step 1 - Set SharePoint host name
# --------------------------------------------------------------

$HostName = "argon.oct.ca"

# --------------------------------------------------------------
# Step 2 - Prepare Powershell Session
# --------------------------------------------------------------
Enable-PSRemoting -force  
New-PSSession  
Import-Module MSOnline -force  
Import-Module MSOnlineExt -force

# --------------------------------------------------------------
# Step 3 - Connect to Office 365
# --------------------------------------------------------------

# $msolcred = get-credential  # ahamilton@oct.ca
connect-msolservice # -credential $msolcred  


# --------------------------------------------------------------
# Step 4 - Get Office 365 object id (tenant id) and SharePoint Server Service Principal Name (SPN)
# --------------------------------------------------------------
$SPOAppId = "00000003-0000-0ff1-ce00-000000000000" # Office 365 SharePoint Online

$SPOContextId = (Get-MsolCompanyInformation).ObjectID  # 403b5de9-f888-4fef-9eea-bd256ecec060" # octoeeo.microsoft.com
$SPOContextId = "403b5de9-f888-4fef-9eea-bd256ecec060" # hardcode for convenience
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

