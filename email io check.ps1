write-host "----------------------------"
write-host "Testing Email Servers"
write-host "----------------------------"

$cred = get-credential
$emailfrom = ###

import-module activedirectory

$email = $cred.getNetworkCredential().username
#this pulls only the username from the get-cred cmdlt

$body = "TEST"

Send-MailMessage -To $email -From $emailfrom -Subject 'TEST' -Body $body -BodyAsHtml -smtpserver smtp.office365.com -usessl -Credential $cred -Port 587

write-host "A test email has been sent."