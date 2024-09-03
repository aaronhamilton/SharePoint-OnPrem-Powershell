<#
SharePoint SPUtility class has SendEmail method which is used to send email to any email address. 
 - By default, SPUtility.SendEmail() method picks the ‘From address’ from Outgoing E-Mail Settings in Central administration.
 - Use SPUtility.IsEmailServerSet method to check if server is configured with SMTP mail settings.

 - LIMITATIONS
   - Message body should not exceed 2048 characters.
   - No support for attachments
      - use System.Net.Mail instead
      - To retrieve Outbound SMTP Server Use new MailAddress(WebApplication.OutboundMailSenderAddress, fromName);
#>

# Overload 1 - header fields as string dictionary + body
$success = SPUtility.SendEmail Method (SPWeb, StringDictionary, String) # https://learn.microsoft.com/en-us/previous-versions/office/developer/sharepoint-2010/ms460489(v=office.14)

# Overload 2 - header fields as string dictionary  + body + append footer (SEE EXAMPLE BELOW)
$success = SPUtility.SendEmail Method (SPWeb, StringDictionary, String, Boolean) # https://learn.microsoft.com/en-us/previous-versions/office/developer/sharepoint-2010/ms454274(v=office.14)

# Overload 3 - append HTML flag, HTMLEncode, subject, htmlbody (SEE EXAMPLE BELOW)
$success = SPUtility.SendEmail Method (SPWeb, Boolean, Boolean, String, String, String) # https://learn.microsoft.com/en-us/previous-versions/office/developer/sharepoint-2010/ms411989(v=office.14)

# Overload 4 - append HTML flag, HTMLEncode, subject, htmlbody, append footer
$success = SPUtility.SendEmail Method (SPWeb, Boolean, Boolean, String, String, String, Boolean) # https://learn.microsoft.com/en-us/previous-versions/office/developer/sharepoint-2010/ms477270(v=office.14)

# OVERLOAD 2 EXAMPLE

$web = Get-SPWeb (Read-Host "Input SPWeb URL using http://")

$headers = @{}
$headers.Add('from','sender@domain.com')
$headers.Add('to','receiver@domain.com')
$headers.Add('bcc','SharePointAdmin@domain.com')
$headers.Add('subject','Welcome to SharePoint')
$headers.Add('fAppendHtmlTag','True') # To enable HTML format

$htmlBody = "<span style='color:red;'> Welcome to SharePoint!!! </span>"

$success = [Microsoft.SharePoint.Utilities.SPUtility]::SendEmail($web, $headers, $htmlBody);

# OVERLOAD 3 EXAMPLE

Add-PSSnapin Microsoft.SharePoint.Powershell

#Parameters
$isHTML = $false
$encodeHTML = $false
$web = Get-SPWeb (Read-Host "Input SPWeb URL using http://")
$recipient = (Read-Host "Input E-mail recipient")
$subject = (Read-Host "Input E-mail Subject")
$body = (Read-Host "Input E-mail Body")

# check if email is configured
$configured = SPUtility.IsEmailServerSet
if ($configured) {
  $success = [Microsoft.SharePoint.Utilities.SPUtility]::SendEmail($web,$isHTML,$encodeHTML,$recipient,$subject,$body)
}

