<#
Use Send-MailMessage, a cmdlet to send emails from PowerShell, as well as other ways to handle this. 
#>

# Basic 
Send-MailMessage -To '<recipient’s email address>' -From '<sender’s email address>' -Subject 'Your message subject' -Body 'Some important plain text!' -SmtpServer '<smtp server>' -Port 25

# Multiple recipients
$recipients = @('johnsmith@test.com','janedoe@example.com') 
Send-MailMessage -To $recipients -From '<sender’s email address>' -Subject 'Your message subject' -Body 'Some important plain text!' -SmtpServer '<smtp server>' -Port 25

# Prompts for credentials
Send-MailMessage -To '<recipient’s email address>' -From '<sender’s email address>' -Subject 'Your message subject' -Body 'Some important plain text!' -Credential (Get-Credential) -SmtpServer '<smtp server>' -Port 25

# Using other parameters, such as attachment, concatenation of body text
$From = "mother-of-dragons@houseoftargaryen.net"
$To = "jon-snow@winterfell.com", "jorah-mormont@night.watch"
$Cc = "tyrion-lannister@westerlands.com"
$Attachment = "C:\Temp\Drogon.jpg"
$Subject = "Photos of Drogon"
$Body = "<h2>Guys, look at these pics of Drogon!</h2><br><br>"
$Body += "He is so cute!"
$SMTPServer = "live.smtp.mailtrap.io"
$SMTPPort = "587"
Send-MailMessage -From $From -to $To -Cc $Cc -Subject $Subject -Body $Body -BodyAsHtml -SmtpServer $SMTPServer -Port $SMTPPort -UseSsl -Credential (Get-Credential) -Attachments $Attachment

# All parameters

Parameter  Description
-To        Email address of a recipient or recipients
-Bcc	     Email address of a BCC recipient or recipients
-Cc	       Email address of a CC recipient or recipients
-From	     Sender’s email address
-Subject   Email subject
-Body	     Email body text
-BodyAsHtml	 Defines that email body text contains HTML
-Attachments Filenames to be attached and the path to them
-Credential	 Authentication to send the email from the account
-SmtpServer	 Name of the SMTP server
-Port        Port of the SMTP server
-DeliveryNotificationOption	 The sender(s) specified in the Form parameter will be notified on the email delivery.
                             Here are the options:
                                None – notifications are off (default parameter) 
                                OnSuccess – notification of a successful delivery 
                                OnFailure – notification of an unsuccessful delivery 
                                Delay – notification of a delayed delivery
                                Never – never receive notifications
-Encoding    The encoding for the body and subject
-Priority    Defines the level of priority of the message.
             Valid options are:
                Normal (default parameter)
                Low
                High
-UseSsl      Connection to the SMTP server will be established using the Secure Sockets Layer (SSL) protocol

# Some alternate SMTP servers
Service	    SMTP server	            Port	Connection
Gmail	      smtp.gmail.com	        587 (TLS), 25(TLS), 465 (SSL)
Office 365  smtp.office365.com	    587, 25	TLS
Outlook.com smtp-mail.outlook.com	  587, 25	TLS
Yahoo mail	smtp.mail.yahoo.com	    587, 25 TLS 465	SSL
Windows Live Hotmail	smtp.live.com	587, 25	TLS
