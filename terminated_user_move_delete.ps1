$TerminatedUsers_PendingMovetoNonSyncedOU = Get-ADUser -filter * -SearchBase 'OU=Disabled - Email Active,OU=APR,DC=aprenergy,DC=local' -Properties msDS-CloudExtensionAttribute3, mail
$TerminatedUsers_PendingDelete = Get-ADUser -filter * -SearchBase 'OU=Terminated User Staging,OU=NonSynced,OU=Users,OU=Global,OU=APR,DC=aprenergy,DC=local' -Properties msDS-CloudExtensionAttribute3, mail

$14daysago = (get-date).adddays(-14)
$21daysago = (get-date).adddays(-21)

#move users to non-synced ou
foreach ($User in $TerminatedUsers_PendingMovetoNonSyncedOU) {
   if($user.'msDS-CloudExtensionAttribute3'){
       $termdate = [System.DateTime]::ParseExact($user.'msDS-CloudExtensionAttribute3',"g",$null)
       if($termdate -lt $14daysago){
           Write-Host "move user to unsynced OU"
           Move-ADObject  $user.guid -TargetPath "OU=Terminated User Staging,OU=NonSynced,OU=Users,OU=Global,OU=APR,DC=aprenergy,DC=local"
           ###########################
           #Move User to non synced OU
           ###########################
           $user_Export = [PSCustomObject]@{
               Action = "MoveUser"                
               ActionDate = get-date
               GUID = $User.guid
               SamAccountName = $User.samaccountname
               TerminationDate = $user.'msDS-CloudExtensionAttribute3'                
               mail = $user.mail
           }
           $user_Export | Export-Csv -Path "C:\Scripts\Logs\UserDelete\ChangeActions.csv" -NoTypeInformation -Append
       }
   }
}


#Delete Users
foreach ($User in $TerminatedUsers_PendingDelete) {
   if($user.'msDS-CloudExtensionAttribute3'){
       $termdate = [System.DateTime]::ParseExact($user.'msDS-CloudExtensionAttribute3',"g",$null)
       if($termdate -lt $21daysago){
           Write-Host "Delete user"
           #Remove-ADUser -identity $user.guid -confirm $false
           #####################
           #Export deleted users
           #####################
           $user_Export = [PSCustomObject]@{
               Action = "Delete"                
               ActionDate = get-date
               GUID = $User.guid
               SamAccountName = $User.samaccountname
               TerminationDate = $user.'msDS-CloudExtensionAttribute3'                
               mail = $user.mail
           }
           $user_Export | Export-Csv -Path "C:\Scripts\Logs\UserDelete\ChangeActions.csv" -NoTypeInformation -Append            
       }
   }
}
