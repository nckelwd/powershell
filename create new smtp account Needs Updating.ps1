#Mail User Creation
#This script is used to create mail user objects for use in systems that require sending mail.
#---------------------------------------------------------------------------------------------

#Import Password Generator Function
. "C:\AUTOMATION_SCRIPTS\Functions\PasswordGenerator.ps1"

function CreateMailUser
{   
    ##############################################################################################
    #This function creates the AD user object, sets attributes, then enables the mail user object.
    ##############################################################################################

    #Create AD User object, Set primary membership, remove domain user
    $Credential = Get-Credential -Message "Enter on Prem Admin Credentials"

    New-aduser -CannotChangePassword $false -PasswordNeverExpires $true -Name $Name -SamAccountName $SamAccountName -DisplayName $DisplayName -Description $Description -Manager $Manager -path $path  -UserPrincipalname $userprincipalname -accountPassword $Password_SecureString -enabled $True -Company $Company -Title $Title -OtherAttributes @{'employeeType'=$employeeType;'NetworkAddress'=$IPAddress;'Info'= 'Date: ' + $date + "`r`nAccount Created by: " + $UserCreator + "`r`nIPAddress: "+$IPAddress} -Server $server -Credential $Credential

    Add-ADGroupMember -Identity "Sudco_ServiceAccount" -Members $SamAccountName -Credential $Credential -Server $server
    
    Set-ADUser -Identity $SamAccountName -Replace @{primaryGroupID=$PrimaryGroup.primaryGroupToken} -Credential $Credential -Server $server
    
    Remove-ADGroupMember -Identity "Domain Users" -Members $SamAccountName -Credential $Credential -Confirm:$false -Server $server

    #Connect to On Premises Exchange
    $OnPremisesSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://PVJAXEXCH01CL.sudco.com/PowerShell/ -Authentication Kerberos -Credential $Credential
    
    Import-PSSession $OnPremisesSession

    #Enable MailUser on AD User object, Set Primary SMTP settings, Hide from Gal, Set recipients to self.
    Enable-MailUser -Identity $Name -PrimarySmtpAddress $PrimarySMTP -ExternalEmailAddress $PrimarySMTP
    
    Set-MailUser -Identity $Name -HiddenFromAddressListsEnabled $true -AcceptMessagesOnlyFromSendersOrMembers $UserPrincipalName

    #output log
    $out = New-Object psobject
    $out | Add-Member -MemberType NoteProperty -Name "CreatedBy" -Value $UserCreator
    $out | Add-Member -MemberType NoteProperty -Name "EmployeeType" -Value $EmployeeType
    $out | Add-Member -MemberType NoteProperty -Name "SamAccountName" -Value $SamAccountName
    $out | Add-Member -MemberType NoteProperty -Name "PrimarySMTP" -Value $PrimarySMTP
    $out | Add-Member -MemberType NoteProperty -Name "DisplayName" -Value $Displayname
    $out | Add-Member -MemberType NoteProperty -Name "Date" -Value $Date
    $out | Add-Member -MemberType NoteProperty -Name "Company" -Value $Company
    $out | Add-Member -MemberType NoteProperty -Name "Description" -Value $UserEnteredDescription
    $out | Add-Member -MemberType NoteProperty -Name "IPAddress" -Value $IPAddress
    $out | Add-Member -MemberType NoteProperty -Name "Manager" -Value $Manager
    $out | Add-Member -MemberType NoteProperty -Name "Name" -Value $Name
    $out | Add-Member -MemberType NoteProperty -Name "UserPrincipalName" -Value $UserPrincipalName
    $out | Add-Member -MemberType NoteProperty -Name "Email Address" -Value $UserPrincipalName
    $out | Export-Csv -Path "C:\AUTOMATION_SCRIPTS\ServiceAccountCreation\SMTPAccountCreationLog.csv" -NoTypeInformation -Append
}

Function VerifyMailUser
{
    #This function verifies that the ad user object was created. And then checks to verify that the mail attribute was set. 
    param($ADUSERTest)
    try
    {
        $VerifyADUser = Get-ADUser -Identity $ADUSERTest -Properties mail -ErrorAction Stop -Server $server
        $ADUserTest_Created= $true
    }
    catch [Microsoft.ActiveDirectory.Management.ADIdentityResolutionException]
    {        
        Write-Host "Account Creation Failed. Please manually check account."
        $ADUserTest_Created= $false        
    }
    if($ADUserTest_Created -eq $true)
    {
        if($VerifyADUser.mail -like "*")
        {
            Write-Host "Account created successfully"
        }
        else
        {
            Write-Host "Ad account created successfully. Mail Account did not. Please investigate"
        }
    }    
}

Function VerifySamAccountAvailable
{
    param($SamAccountTest)
    $global:AvailabilityPassFail = $false
    try
    {
        Get-ADUser -Identity $SamAccountTest -ErrorAction Stop -Server $server
        
    }
    catch [Microsoft.ActiveDirectory.Management.ADIdentityResolutionException]
    {        
        $global:AvailabilityPassFail = $true        
    }    
}

function GetUseType 
{
    $global:AccountUseType_read = Read-Host -Prompt "What system type will be using this account? Please enter the number next to the corresponding type.`n`r1: MFP `n`r2: Application`n`r3: Server`n`r"

    switch($AccountUseType_read)
    {
        1
            {
                $global:AccountUseType = "MFP"
                $global:Path = "OU=Scanners,OU=SMTP Accounts,OU=SUDCO_ MIS Non User,DC=sudco,DC=com"
                Break
            }
        2
            {
                $global:AccountUseType = "APP"
                $global:Path = "OU=Applications,OU=SMTP Accounts,OU=SUDCO_ MIS Non User,DC=sudco,DC=com"
                Break
            }
        3
            {
                $global:AccountUseType = "SRV"
                $global:Path = "OU=Servers,OU=SMTP Accounts,OU=SUDCO_ MIS Non User,DC=sudco,DC=com"
                Break
            }
        default
        { 
            Write-Host "Incorrect Entry. Type 1,2, or 3"
            getusetype
        }
    }
}

Function LoadVariables 
{
    ################
    #Load Variables#
    ################
    #userEntry
    #-------------------------------------
    $global:UserEntry_Name = Read-Host -Prompt "Please enter Account name. This will become the SamAccountName, UPN PRefix, Name, and Email Prefix"
    #$global:UserEntry_DisplayName = Read-Host -Prompt "Please enter the display name."    
    $global:UserEnteredDescription = Read-Host -Prompt "Please enter a description application or MFP this account will be used for"
    $global:IPAddress = Read-Host -Prompt "Enter the IP address of the device this account will be used on"
    $global:Manager = Read-Host -Prompt "Enter SamAccountName of Manager/responsible party for this account"
    #$global:PrimarySMTP = Read-Host -Prompt "Enter from address.(PrimarySMTP)"        
    
    #Load use Type
    getusetype
    $global:Title = "SMTP: " + $AccountUseType

    $global:Company = "Centralized Services"
    $global:SamAccountName = $AccountUseType +"-"+ $UserEntry_Name
    $global:Name = $SamAccountName
    $global:DisplayName = "SMTP - " + $UserEntry_Name
    $global:Description = "SMTP - " + $UserEnteredDescription + " - (" + $IPAddress + ")"
    #$global:UserPrincipalName = $SamAccountName + "@suddath.com"
    $global:UserPrincipalName = $UserEntry_Name + "@suddath.com"
    $global:PrimarySMTP = $UserPrincipalName        
    $global:server = Get-addomain | select -expand pdcemulator
    $global:Date = Get-Date
    $global:UserCreator = $env:USERNAME
    $employeeType= "ServiceAccount"
    $global:PrimaryGroup = Get-ADGroup "Sudco_ServiceAccount" -properties @("primaryGroupToken")

    
    
    #Random Password Generator
    $global:Password_PlainText = PasswordGenerator -length 15
    $global:Password_SecureString = (convertto-securestring $Password_PlainText -asplaintext -force)
    
    #write to screen
    Write-host "Company:" $Company `n"Name:" $UserEntry_Name `n"DisplayName:" $global:DisplayName `n"Description:" $Description `n"IPAddress:" $IPAddress `n"Manager:" $Manager `n"SamAccountName:" $samaccountname`n"Userprincipalname:" $UserPrincipalName `n"Path:" $Path `n"Server:" $server `n"Password:" $Password_PlainText   

    if($UserEntry_Name.Length -gt 20)
    {
        Write-Host "Username must be 20 characters or less. Please try again."
        LoadVariables
    }
    elseif($UserEnteredDescription.Length -gt 256)
    {
        Write-Host "Description must be less that 256 characters. Please try again."
        LoadVariables
    }
    Else
    {
        #Verify that the samAccountName is not already in use on this forrest. If its not already in use, create the user. If it is already in use, reload variables.
        VerifySamAccountAvailable $SamAccountName
        if($AvailabilityPassFail -eq $true)
        {
            CreateMailUser
            VerifyMailUser $SamAccountName
        }
        else
        {
            Write-Host "SamAccountName is already in use. Starting over"
            LoadVariables    
        }
    }
}

##########
#Execution
##########

#Load Variables
LoadVariables
