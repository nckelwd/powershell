# Variables that we will use later                            
$ou = "OU=NON-MAIL-ENABLED-Accts,DC=aprenergy,DC=local"            


# Now we will output the accounts expiring within the specified time frame.
"`Expiring within 1 day"
$1day = (get-date).AddDays(1) ; Search-ADAccount -SearchBase $ou -AccountExpiring -TimeSpan (New-TimeSpan -Days 1) | Select-Object SamAccountName,AccountExpirationDate | Sort-Object AccountExpirationDate | Format-Table SamAccountName, AccountExpirationDate -AutoSize

"`Expiring within 3 days"
$3days = (get-date).AddDays(3) ; Search-ADAccount -AccountExpiring -TimeSpan (New-TimeSpan -Days 3) | Select-Object SamAccountName,AccountExpirationDate | Sort-Object AccountExpirationDate | Format-Table SamAccountName, AccountExpirationDate -AutoSize

"`Expiring within 7 days"
$7days = (get-date).AddDays(7) ; Search-ADAccount -AccountExpiring -TimeSpan (New-TimeSpan -Days 7) | Sort-Object Name | Format-Table Name, AccountExpirationDate -AutoSize

"`Expiring within 14 days"
$14days = (get-date).AddDays(14) ; $users = Search-ADAccount -SearchBase $ou -AccountExpiring -TimeSpan (New-TimeSpan -Days 14) | Select-Object SamAccountName,AccountExpirationDate | Sort-Object AccountExpirationDate | Format-Table SamAccountName, AccountExpirationDate -AutoSize

foreach ($u in $users){
    $uname = Select-Object SamAccountName | Format-Table SamAccountName
}
$uname

# And so this concludes the portion of the script that queries AD, we will now compose the email that will be sent.