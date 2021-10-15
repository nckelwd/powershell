#######################################################################################################################################################
###create a service account
#######################################################################################################################################################


#######################################################################################################################################################
#some variables
#######################################################################################################################################################
$server = "aprjaxdc02.aprenergy.local"
$Path = 'CN=Managed Service Accounts,DC=aprenergy,DC=local'
$accountType = @()
$userCreator = $env:USERNAME
$date = get-date
$description =  @()
$employeeType = 'Service Account'

#######################################################################################################################################################
#sets the account type
#######################################################################################################################################################
function setAccountType {
    $accountTypePrompt = Read-Host -Prompt "What type of account will this be? Enter 1 for SERVICE ACCOUNT (SVC), or enter 2 for APPLICATION ACCOUNT (APP)"
    
    if ($accountTypePrompt -eq '1') {
        $accountType = 'SVC-'
        Write-Host "You have chose the account type:" $accountType -ForegroundColor Green
        setAccountName
    }
    elseif ($accountTypePrompt -eq '2') {
        $accountType = 'APP-'
        Write-Host "You have chose the account type:" $accountType -ForegroundColor Green
        setAccountName
    }
    else
    {
        Write-Warning "Your entry is invalid. Press Enter to exit the script and re-run to try again"
        exit
    }
}

#######################################################################################################################################################
#sets the account name
#######################################################################################################################################################
function setAccountName {
    $accountName = Read-Host -Prompt "What should the name of the application or service account be?"
    $accountName = $accountName -replace '\s',''

    Write-Host "The application or service account name entered is: " $accountName -ForegroundColor Green
    $accountNamePrompt = Read-Host -Prompt "Is this correct? Enter Y to continue or any other key to exit"

    if ($accountNamePrompt -eq 'Y') {
        $svcLogonName = $accountType + $accountName
        $description = "Service account for " + $accountName
        setManager
    }
    else {
        Write-Warning "The script will now exit. If you still need to create a service account, restart the script and try again."
        exit
    }
}

#######################################################################################################################################################
#sets the manager
#######################################################################################################################################################
function setManager {
    $managerSAM = Read-Host -Prompt "Who is the designated manager of the account? Enter their on-premise/login name"
    Write-Host "The Manager you entered is: " $managerSAM -ForegroundColor Green
    $managerPrompt = Read-Host -Prompt "Is this correct? Enter Y to continue or any other key to exit"

    if ($managerPrompt -eq 'Y') {
        try {
            Get-ADUser -Identity $managerSAM -Server $server
            $ManagerExistsCheck = $true
        }
        catch [Microsoft.ActiveDirectory.Management.ADIdentityResolutionException] {    
            $ManagerExistsCheck = $false
        }
    }

    if ($ManagerExistsCheck -eq $true) {
        setTicket
    }
    else {
        Write-Warning = "Manager account doesn't exist and is required. The script will now exit. Please try again."
        Exit
    }
}

#######################################################################################################################################################
#sets the ticket number
#######################################################################################################################################################
function setTicket {
        $ticketNumber = Read-Host -Prompt "Enter the ticket number associated to this account"
    
        Write-Host "The ticket number entered is: " $ticketNumber -ForegroundColor Green
        $ticketNumberPrompt = Read-Host -Prompt "Is this correct? Enter Y to continue or any other key to exit"
    
        if ($ticketNumberPrompt -eq 'Y') {
            giveSummary
        }
        else {
            Write-Warning "The script will now exit. If you still need to create a service account, restart the script and try again."
            exit
        }
}

#######################################################################################################################################################
#gives a summary
#######################################################################################################################################################
function giveSummary {
    Write-Host "A summary of your entry will be provided below. Please review before you continue." -ForegroundColor Green
    Write-Host "Date: " $date  -ForegroundColor Green
    Write-Host "Your username: " $userCreator -ForegroundColor Green
    Write-Host "Account: " $svcLogonName -ForegroundColor Green
    Write-Host "Description: " $description -ForegroundColor Green
    Write-Host "OU Path: " $Path -ForegroundColor Green
    Write-Host "Manager account: " $managerSAM -ForegroundColor Green
    Write-Host "Ticket Number: " $ticketNumber -ForegroundColor Green
    $summaryPrompt = Read-Host "Is this information correct? Enter Y to continue or any other key to exit and start over"
    if ($summaryPrompt -eq 'Y') {
        createAccount
    }
    else {
        Write-Warning "The script will now exit. If you still need to create a service account, restart the script and try again."
        exit
    }
}

#######################################################################################################################################################
#creates a randomized password
#######################################################################################################################################################
function Get-RandomCharacters($length, $characters) {
    $random = 1..$length | ForEach-Object { Get-Random -Maximum $characters.length }
    $private:ofs=""
    return [String]$characters[$random]
}
 
function Scramble-String([string]$inputString){     
    $characterArray = $inputString.ToCharArray()   
    $scrambledStringArray = $characterArray | Get-Random -Count $characterArray.Length     
    $outputString = -join $scrambledStringArray
    return $outputString 
}
 
$password = Get-RandomCharacters -length 6 -characters 'abcdefghiklmnoprstuvwxyz'
$password += Get-RandomCharacters -length 4 -characters 'ABCDEFGHKLMNOPRSTUVWXYZ'
$password += Get-RandomCharacters -length 3 -characters '1234567890'
$password += Get-RandomCharacters -length 3 -characters '!"§$%&/()=?}][{@#*+'
 
$password = Scramble-String $password
$passwordRead = $password
$password = ConvertTo-SecureString $password -AsPlainText -Force

#######################################################################################################################################################
#creates the account
#######################################################################################################################################################
function createAccount {

    #Set Any additional variables
    $userPrinName = $svcLogonName + "@aprenergy.local"
    $firstName = "SVC"
    $result = New-Object System.Collections.Generic.List[System.Object]

    New-aduser -name $svcLogonName -GivenName $firstName -Surname $accountName -DisplayName $svcLogonName -accountPassword $password  -Description $description -samaccountname $svcLogonName -UserPrincipalName $userPrinName -path $Path -Manager $managerSAM -enabled $True -OtherAttributes @{employeeType=$employeeType} -Server $server
    
    Start-Sleep -Seconds 10

    Set-ADUser $svcLogonName -Replace @{Info= 'Date: ' + $date +' Account Created by: ' + $UserCreator +' Ticket Number: ' + $TicketNumber} -Server $server

    $FinalUserExistsCheck = [bool] (get-aduser -Filter{ Samaccountname -eq $svcLogonName} -server $server)
        if(!$FinalUserExistsCheck)
        {
            Write-Host "Failed to create account in AD. Try again" -ForegroundColor Green
            Exit
        }
        Else
        {
            Write-Host "Account created successfully." -ForegroundColor Green
            Write-Host "The password used in this creation was: " $passwordRead -ForegroundColor Green
            Write-Host "Document or change the password as needed. This will not be logged." -ForegroundColor Green
            logToFile
        }
}

#######################################################################################################################################################
#Write to Log
#######################################################################################################################################################
function logToFile {
        $out = New-Object psobject
        $out | Add-Member -MemberType NoteProperty -Name "CreatedBy" -Value $UserCreator
        $out | Add-Member -MemberType NoteProperty -Name "AccountType" -Value $accountType
        $out | Add-Member -MemberType NoteProperty -Name "AccountName" -Value $accountName
        $out | Add-Member -MemberType NoteProperty -Name "Login" -Value $svcLogonName
        $out | Add-Member -MemberType NoteProperty -Name "Date" -Value $date
        $out | Add-Member -MemberType NoteProperty -Name "TicketNumber" -Value $TicketNumber    
        $out | Add-Member -MemberType NoteProperty -Name "Manager" -Value $ManagerSAM
        $out | Add-Member -MemberType NoteProperty -Name "EmpType" -Value $EmployeeType
        $result.Add($out)
    
        #$result | Export-Csv -Path "C:\Scripts\Logs\ServiceAccounts\ServiceAccountLog.csv" -NoTypeInformation -Append
        $result | Export-Csv -Path "C:\Scripts\ServiceAccountLog.csv" -NoTypeInformation -Append
    
        Exit
}
#######################################################################################################################################################
#start your engines!
#######################################################################################################################################################
setAccountType
