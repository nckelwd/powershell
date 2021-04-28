$date = Get-Date
$pwd = (convertto-securestring "password" -asplaintext -force)

#This script is part one of a two part process to create a shared mailbox.  
#This script does the On Premis section. Creates Exchange / AD Object
#-------------------------------------------------------------------------

add-pssnapin Microsoft.Exchange.Management.PowerShell.E2010
. $env:ExchangeInstallPath\bin\RemoteExchange.ps1
connect-exchangeserver -auto

$MailboxName = Read-Host -Prompt 'Input the name of the new address you would like to create.  DO NOT INCLUDE THE @DOMAIN.COM'
$MailboxFullName = $MailboxName + "@Domain.com"
$MailboxFullRemoteName = $MailboxName + "@fqdn.com"

New-RemoteMailbox -Name $MailboxName -Password $pwd -UserPrincipalName $MailboxfullName -OnPremisesOrganizationalUnit "domain/ou/ou" -PrimarySmtpAddress $MailboxFullName

Start-Sleep -Seconds 10

Set-RemoteMailbox $MailboxName -EmailAddresses @{add=$MailboxFullRemoteName}

$TicketNumber = Read-Host -Prompt 'Please enter the Ticket number for this request'
$SMBOwner = Read-Host -Prompt 'Please enter the name of the Shared Mailbox Owner'

Set-ADUser $MailboxName -Replace @{Info= 'Date: ' + $date +' Shared Mailbox Created by: ' + $env:UserName +' Shared Mailbox Owner: ' + $SMBOwner + ' Ticket Number: ' + $TicketNumber}

Disable-ADAccount -Identity $MailboxName