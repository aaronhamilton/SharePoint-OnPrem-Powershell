<#
    Update value of Access Request email for all web applications 
#>

cls

$prompt = Read-Host -Prompt "Are you sure you want to update Access Request Emails for all web applications and sites in this Farm (Y or N)?"
Write-Host 

if (($prompt -eq "y") -or ($prompt -eq "Y")) {
    Write-Host "Scanning sites and updating Access Request emails...";
    Write-Host 
} else {
    Write-Host "Don't worry, just about to list all site for you...";
    Write-Host 
}

# Get All Web Application
$webApp=Get-SPWebApplication 

# Get All site collections
foreach ($SPsite in $webApp.Sites)
{

    # get the collection of webs
    foreach($SPweb in $SPsite.AllWebs)
    {
        $SPWeb.Url

        if (($prompt -eq "y") -or ($prompt -eq "Y")) {
            if ($SPweb.HasUniquePerm) {

                if ($SPWeb.Url -match "/my/") {
                    Write-Host " - Ignoring MySites" -ForegroundColor Yellow
                }
                elseif ($SPweb.RequestAccessEnabled) {
                    $SPweb.RequestAccessEmail = "request@domain.ca"
                    $SPweb.Update()
                }
            }

        } else {

            # if a site inherits permissions, then the Access request mail setting also will be inherited
            if (!$SPweb.HasUniquePerm) {
                Write-Host " - Inheriting from Parent site"
            }
            else {
                
                if (!$SPweb.RequestAccessEnabled) {
                    #$SPweb.RequestAccessEnabled = $true;
                    Write-Host " - Request Access enabled: " $SPweb.RequestAccessEnabled -ForegroundColor Yellow
                } else {
                    Write-Host " - Request Access enabled: " $SPweb.RequestAccessEnabled 
                }
                Write-Host " - Request Access contact: " $SPweb.RequestAccessEmail
            }
                
        }

    }
}

$web.Dispose()
$site.Dispose()

