#https://blog.meenavalli.in/post/sharepoint2013-email-alerts-search-crawl-errors-powershell/

#Powershell Script which to Send a dialy Alert Mail when an error occurs during Search Crawl.
#This solution is for SharePoint Server 2013 (on-Premises)
#Author : Ram Prasad Meenavalli
#----------------------------------------------------
#Parameters Required
#----------------------------------------------------
$ssaName = "Search Service Application"
$errorsFileName = "errors.csv"
$topErrorsFileName = "toplevelerrors.csv"


#$logMaxRows - This specifies the number of errors to be sent in the mail attachment.
$logMaxRows = 10000


#$contentSourceID - This specifies the Content Source ID where we need to check for Crawl Errors.
#-1 will give crawl errors from all content sources.
$contentSourceID = -1


#----------------------------------------------------


Email Variables

#----------------------------------------------------
$smtp = "smtp-server-address"
$to = "ram@yourmail.com","prasad@yourmail.com"
$from = "no-reply@yourmail.com"
$subject = "Search Crawl Errors"
$body = "Your Search Service has encountered some errors while crawling the content. Please check the attachment/s for more details."


#----------------------------------------------------


Constants

#----------------------------------------------------
$errorID = -1
$currentDate = Get-Date
$startDate = $currentDate.AddDays(-1)
$endDate = (($startDate.AddHours(23)).AddMinutes(59)).AddSeconds(59)


if ((Get-PSSnapin "Microsoft.SharePoint.PowerShell" -ErrorAction SilentlyContinue) -eq $null)
{
Add-PSSnapin Microsoft.SharePoint.PowerShell
}


$ssa = Get-SPEnterpriseSearchServiceApplication -Identity $ssaName
$logs = New-Object Microsoft.Office.Server.Search.Administration.CrawlLog $ssa


$errors = $logs.GetCrawledUrls($true,$logMaxRows,"",$false,$contentSourceID,2,$errorID,$startDate,$endDate)
$topErrors = $logs.GetCrawledUrls($true,$logMaxRows,"",$false,$contentSourceID,4,$errorID,$startDate,$endDate)


if(($errors.Rows[0]["DocumentCount"] -gt 0) -or ($topErrors.Rows[0]["DocumentCount"] -gt 0))
{
$logs.GetCrawledUrls($false,$logMaxRows,"",$false,$contentSourceID,2,$errorID,$startDate,$endDate) | export-csv -notype $errorsFileName
$logs.GetCrawledUrls($false,$logMaxRows,"",$false,$contentSourceID,4,$errorID,$startDate,$endDate) | export-csv -notype $topErrorsFileName


send-MailMessage -SmtpServer $smtp -To $to -From $from -Subject $subject -Body $body -BodyAsHtml -Attachments $errorsFileName,$topErrorsFileName

}

<#

Copy the script above and change the parameters/values appropriately to suit your needs.
Save this script as errorMailAlerts.ps1 or any other relevant name with .ps1 extension and save it on a SharePoint Server.
Schedule the script
This powershell script should be scheduled to run daily using the windows Task Scheduler. Follow the below steps for scheduling a task

Login to the SharePoint Server where the .ps1 file is saved.
Open the Windows Task Scheduler and select the Create Task option.
Enter a name for the task, and give it a description.
In the General tab, go to the Security options heading and specify the user account that the task should be run under. Change the settings so the task will run if the user is logged in or not.
In the Triggers tab add a new trigger for the scheduled task. Select the Start Date and the frequency to run once everyday at 1:00 AM (or any desired time).
In the Actions tab, add a new Action and set it to Start a program.
In the Program/script box enter "PowerShell."
In the Add arguments box enter the value ".\errorMailAlerts.ps1."
In the Start in box, add the complete path of the folder that contains your PowerShell script.
Click OK when all the desired settings are made.
This runs the powershell script daily and the admins will receive a mail with the crawl error details if any.

#>
