# Creating the secure password file (one-time) 
mkdir c:\SecurePasswords
Read-Host -AsSecureString | ConvertFrom-SecureString | Out-File -FilePath c:\SecurePasswords\<username>

# using it in PS script
$credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $SMTPSecureUsername,(Get-Content -Path $SMTPSecurePasswordPath | ConvertTo-SecureString)
