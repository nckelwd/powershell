
#You experience issues in Outlook when you try to configure free/busy information or when you try to delegate information

#Run the following cmdlet to export the current Calendar folder permissions, which may be needed to recreate any delegate permission settings
Get-MailboxFolderPermission -Identity joseph.dicamillo@aprenergy.com:\Calendar

#Run the following PowerShell cmdlet against the target mailbox
Remove-MailboxFolderPermission -Identity joseph.dicamillo@aprenergy.com:\Calendar -ResetDelegateUserCollection

#Run the following cmdlet one or more times, as needed, to add or recreate any necessary delegate permissions
Add-MailboxFolderPermission -Identity joseph.dicamillo@aprenergy.com:\Calendar -User stacie.mirabella@aprenergy.com -SharingPermissionFlag Delegate

Add-MailboxFolderPermission -Identity joseph.dicamillo@aprenergy.com:\Calendar -User Kim.Quarterman@aprenergy.com -SharingPermissionFlag Delegate