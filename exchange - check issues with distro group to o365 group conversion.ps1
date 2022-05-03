<#
    MIT License

    Copyright (c) Microsoft Corporation.

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE
#>

# Version 22.01.16.1612

#Create working folder on the logged user desktop
$ts = Get-Date -Format yyyyMMdd_HHmmss
$ExportPath = "$env:USERPROFILE\Desktop\PowershellDGUpgrade\DlToO365GroupUpgradeChecks_$ts"
mkdir $ExportPath -Force | Out-Null
Add-Content -Path $ExportPath\DlToO365GroupUpgradeCheckslogging.csv  -Value '"Function","Description","Status"'
$Script:Conditionsfailed = 0
Function log {
    param(
        [Parameter(Mandatory = $true)]
        [string]$CurrentStatus,

        [Parameter(Mandatory = $true)]
        [string]$Function,

        [Parameter(Mandatory = $true)]
        [string]$CurrentDescription

    )

    $PSobject = New-Object PSObject
    $PSobject | Add-Member -NotePropertyName "Function" -NotePropertyValue $Function
    $PSobject | Add-Member -NotePropertyName "Description" -NotePropertyValue $CurrentDescription
    $PSobject | Add-Member -NotePropertyName "Status" -NotePropertyValue $CurrentStatus
    $PSobject | Export-Csv $ExportPath\DlToO365GroupUpgradeCheckslogging.csv -NoTypeInformation -Append
}
Function Connect2EXO {
    try {
        #Validate EXO V2 is installed
        if ((Get-Module | Where-Object { $_.Name -like "ExchangeOnlineManagement" }).count -eq 1) {
            Import-Module ExchangeOnlineManagement -ErrorAction stop -Force
            $CurrentDescription = "Importing EXO V2 Module"
            $CurrentStatus = "Success"
            log -CurrentStatus $CurrentStatus -Function "Importing EXO V2 Module" -CurrentDescription $CurrentDescription
            Write-Warning "Connecting to EXO V2, please enter Global administrator credentials when prompted!"
            Connect-ExchangeOnline -ErrorAction Stop
            $CurrentDescription = "Connecting to EXO V2"
            $CurrentStatus = "Success"
            log -CurrentStatus $CurrentStatus -Function "Connecting to EXO V2" -CurrentDescription $CurrentDescription
            Write-Host "Connected to EXO V2 successfully" -ForegroundColor Cyan
        } else {
            #log failure and try to install EXO V2 module then Connect to EXO
            Write-Host "ExchangeOnlineManagement Powershell Module is missing `n Trying to install the module" -ForegroundColor Red
            Install-Module -Name ExchangeOnlineManagement -Force -ErrorAction Stop -Scope CurrentUser
            Import-Module ExchangeOnlineManagement -ErrorAction stop -Force
            $CurrentDescription = "Installing & Importing EXO V2 powershell module"
            $CurrentStatus = "Success"
            log -CurrentStatus $CurrentStatus -Function "Installing & Importing EXO V2 powershell module" -CurrentDescription $CurrentDescription
            Write-Warning "Connecting to EXO V2, please enter Global administrator credentials when prompted!"
            Connect-ExchangeOnline -ErrorAction Stop
            $CurrentDescription = "Connecting to EXO V2"
            $CurrentStatus = "Success"
            log -CurrentStatus $CurrentStatus -Function "Connecting to EXO V2" -CurrentDescription $CurrentDescription
            Write-Host "Connected to EXO V2 successfully" -ForegroundColor Cyan
        }
    } catch {
        $CurrentDescription = "Connecting to EXO V2 please check if ExchangeOnlineManagement Powershell Module is installed & imported"
        $CurrentStatus = "Failure"
        log -CurrentStatus $CurrentStatus -Function "Connecting to EXO V2" -CurrentDescription $CurrentDescription
        break
    }
}
#Check if Distribution Group can't be upgraded because Member*Restriction is set to "Closed"
Function Debugmemberrestriction {
    param(
        [Parameter(Mandatory = $true)]
        [PScustomobject]$Distgroup

    )
    $MemberJoinRestriction = $Distgroup.MemberJoinRestriction.ToLower().ToString()
    $MemberDepartRestriction = $Distgroup.MemberDepartRestriction.ToLower().ToString()
    if ($MemberDepartRestriction -eq "closed" -or $MemberJoinRestriction -eq "closed") {
        $script:Conditionsfailed++
        Write-Host "Distribution Group can't be upgraded cause either MemberJoinRestriction or MemberDepartRestriction or both values are set to Closed!" -ForegroundColor Red
        "Distribution Group can't be upgraded cause either MemberJoinRestriction or MemberDepartRestriction or both values are set to Closed!" | Out-File $ExportPath\DlToO365GroupUpgradeChecksREPORT.txt -Append
        Write-Host "FIX --> Please follow the following article https://aka.ms/Setdistributiongroup to proceed with fixing DL Member*Restriction & set DL MemberJoin/DepartRestriction to Open!`n" -ForegroundColor Green
        "FIX --> Please follow the following article https://aka.ms/Setdistributiongroup to proceed with fixing DL Member*Restriction & set DL MemberJoin/DepartRestriction to Open!`n" | Out-File $ExportPath\DlToO365GroupUpgradeChecksREPORT.txt -Append
    }
}
#Check if Distribution Group can't be upgraded because it is DirSynced
Function Debugdirsync {
    param(
        [Parameter(Mandatory = $true)]
        [PScustomobject]$Distgroup
    )
    $IsDirSynced = $Distgroup.IsDirSynced
    if ($IsDirSynced -eq $true) {
        $script:Conditionsfailed++
        Write-Host "Distribution Group can't be upgraded because it's synchronized from on-premises!`n" -ForegroundColor Red
        "Distribution Group can't be upgraded because it's synchronized from on-premises!`n" | Out-File $ExportPath\DlToO365GroupUpgradeChecksREPORT.txt -Append
    }
}
#Check if Distribution Group can't be upgraded because EmailAddressPolicyViolated
Function Debugmatchingeap {
    param(
        [Parameter(Mandatory = $true)]
        [PScustomobject]$Distgroup
    )
    $eap = Get-EmailAddressPolicy -ErrorAction stop
    # Bypass that step if there's no EAP
    if ($null -ne $eap) {
        $matchingEap = @( $eap | Where-Object { $_.RecipientFilter -eq "RecipientTypeDetails -eq 'GroupMailbox'" -and $_.EnabledPrimarySMTPAddressTemplate.ToString().Split("@")[1] -cne $Distgroup.PrimarySmtpAddress.ToString().Split("@")[1] })
        if ($matchingEap.Count -ge 1) {
            $script:Conditionsfailed++
            Write-Host "Distribution Group can't be upgraded because Admin has applied Group Email Address Policy for the groups on the organization e.g. DL PrimarySmtpAddress @Contoso.com while the EAP EnabledPrimarySMTPAddressTemplate is @contoso.com OR DL PrimarySmtpAddress @contoso.com however there's an EAP with EnabledPrimarySMTPAddressTemplate set to @fabrikam.com" -ForegroundColor Red
            Write-Host "Group Email Address Policy found:" -BackgroundColor Yellow -ForegroundColor Black
            $matchingEap | Format-Table name, recipientfilter, Guid, enabledemailaddresstemplates
            "Distribution Group can't be upgraded because Admin has applied Group Email Address Policy for the groups on the organization e.g. DL PrimarySmtpAddress @Contoso.com while the EAP EnabledPrimarySMTPAddressTemplate is @contoso.com OR DL PrimarySmtpAddress @contoso.com however there's an EAP with EnabledPrimarySMTPAddressTemplate set to @fabrikam.com" | Out-File $ExportPath\DlToO365GroupUpgradeChecksREPORT.txt -Append
            "Group Email Address Policy found:" | Out-File $ExportPath\DlToO365GroupUpgradeChecksREPORT.txt -Append
            $matchingEap | Format-Table name, recipientfilter, Guid, enabledemailaddresstemplates | Out-File $ExportPath\DlToO365GroupUpgradeChecksREPORT.txt -Append
            Write-Host "FIX --> Please follow the following article https://aka.ms/removeeap to proceed with removing non-matching EmailAddressPolicy!`n" -ForegroundColor Green
            "FIX --> Please follow the following article https://aka.ms/removeeap to proceed with removing non-matching EmailAddressPolicy!`n" | Out-File $ExportPath\DlToO365GroupUpgradeChecksREPORT.txt -Append
        }
    }
}
#Check if Distribution Group can't be upgraded because DlHasParentGroups
Function Debuggroupnesting {
    param(
        [Parameter(Mandatory = $true)]
        [PScustomobject]$Distgroup
    )
    $ParentDGroups = @()
    try {
        Write-Warning "Retrieving all distribution groups in Exchange online to validate Dl for nested Dl condition, please wait...."
        $alldgs = Get-DistributionGroup -ResultSize unlimited -ErrorAction Stop
        $CurrentDescription = "Retrieving All DGs in the EXO directory"
        $CurrentStatus = "Success"
        log -Function "Retrieve All DGs" -CurrentDescription $CurrentDescription -CurrentStatus $CurrentStatus
    } catch {
        $CurrentDescription = "Retrieving All DGs in the EXO directory"
        $CurrentStatus = "Failure"
        log -Function "Retrieve All DGs" -CurrentDescription $CurrentDescription -CurrentStatus $CurrentStatus
    }
    $DGcounter=0
    foreach ($parentdg in $alldgs) {
        try {
            $Pmembers = Get-DistributionGroupMember $($parentdg.Guid.ToString()) -ErrorAction Stop
            if ($alldgs.count -ge 2) {
                $DGcounter++
                $percent=[Int32]($DGcounter/$alldgs.count*100)
                Write-Progress -Activity "Querying Distribution Groups"  -PercentComplete $percent -Status "Processing $DGcounter/$($alldgs.count)group"
            }
        } catch {
            $CurrentDescription = "Retrieving: $parentdg members"
            $CurrentStatus = "Failure"
            log -Function "Retrieve Distribution Group membership" -CurrentDescription $CurrentDescription -CurrentStatus $CurrentStatus
        }
        $DGmembercounter=0
        foreach ($member in $Pmembers) {
            if ($member.Guid.Guid.ToString() -like $Distgroup.Guid.Guid.ToString()) {
                $ParentDGroups += $parentdg
            }
            if ($Pmembers.count -ge 2) {
                $DGmembercounter++
                $childpercent=[Int32]($DGmembercounter/$Pmembers.count*100)
                Write-Progress -Activity "Querying Group Members" -Id 1 -PercentComplete $childpercent -Status "Processing $DGmembercounter/$($Pmembers.count) member"
            }
        }
    }
    Write-Progress -Activity "Querying Group Members" -Completed -Id 1
    Write-Progress -Activity "Querying Distribution Groups" -Completed
    if ($ParentDGroups.Count -ge 1) {
        $script:Conditionsfailed++
        Write-Host "Distribution Group can't be upgraded because it is a child group of another parent group" -ForegroundColor Red
        Write-Host "Parent Groups found:" -BackgroundColor Yellow -ForegroundColor Black
        $ParentDGroups | Format-Table -AutoSize DisplayName, Alias, GUID, RecipientTypeDetails, PrimarySmtpAddress
        "Distribution Group can't be upgraded because it is a child group of another parent group"  | Out-File $ExportPath\DlToO365GroupUpgradeChecksREPORT.txt -Append
        "Parent Groups found:" | Out-File $ExportPath\DlToO365GroupUpgradeChecksREPORT.txt -Append
        $ParentDGroups | Format-Table -AutoSize DisplayName, Alias, GUID, RecipientTypeDetails, PrimarySmtpAddress | Out-File $ExportPath\DlToO365GroupUpgradeChecksREPORT.txt -Append
        Write-Host "FIX --> Please follow the following article https://aka.ms/RemoveDGmember to proceed with removing DL membership from Parent DL(s)!`n" -ForegroundColor Green
        "FIX --> Please follow the following article https://aka.ms/RemoveDGmember to proceed with removing DL membership from Parent DL(s)!`n" | Out-File $ExportPath\DlToO365GroupUpgradeChecksREPORT.txt -Append
    }
}
#Check if Distribution Group can't be upgraded because DlHasNonSupportedMemberTypes with RecipientTypeDetails other than UserMailbox, SharedMailbox, TeamMailbox, MailUser
Function Debugmembersrecipienttypes {
    param(
        [Parameter(Mandatory = $true)]
        [PScustomobject]$Distgroup
    )

    try {
        Write-Warning "Retrieving $($Distgroup.PrimarySmtpAddress) group members to validate DlHasNonSupportedMemberTypes condition, please wait...."
        $members = Get-DistributionGroupMember $($Distgroup.Guid.ToString()) -ErrorAction stop
        $CurrentDescription = "Retrieving: $($Distgroup.PrimarySmtpAddress) members"
        $CurrentStatus = "Success"
        log -Function "Retrieve Distribution Group membership" -CurrentStatus $CurrentStatus -CurrentDescription $CurrentDescription
    } catch {
        $CurrentDescription = "Retrieving: $($Distgroup.PrimarySmtpAddress) members"
        $CurrentStatus = "Failure"
        log -Function "Retrieve Distribution Group membership" -CurrentStatus $CurrentStatus -CurrentDescription $CurrentDescription
    }
    $matchingMbr = @( $members | Where-Object { $_.RecipientTypeDetails -ne "UserMailbox" -and `
                $_.RecipientTypeDetails -ne "SharedMailbox" -and `
                $_.RecipientTypeDetails -ne "TeamMailbox" -and `
                $_.RecipientTypeDetails -ne "MailUser" -and `
                $_.RecipientTypeDetails -ne "GuestMailUser" -and `
                $_.RecipientTypeDetails -ne "RoomMailbox" -and `
                $_.RecipientTypeDetails -ne "EquipmentMailbox" -and `
                $_.RecipientTypeDetails -ne "User" -and `
                $_.RecipientTypeDetails -ne "DisabledUser" `
        })

    if ($matchingMbr.Count -ge 1) {
        $script:Conditionsfailed++
        Write-Host "Distribution Group can't be upgraded because DL contains member RecipientTypeDetails other than UserMailbox, SharedMailbox, TeamMailbox, MailUser" -ForegroundColor Red
        Write-Host "Non-supported members found:" -BackgroundColor Yellow -ForegroundColor Black
        $matchingMbr | Format-Table -AutoSize DisplayName, Alias, GUID, RecipientTypeDetails, PrimarySmtpAddress
        "Distribution Group can't be upgraded because DL contains member RecipientTypeDetails other than UserMailbox, SharedMailbox, TeamMailbox, MailUser" | Out-File $ExportPath\DlToO365GroupUpgradeChecksREPORT.txt -Append
        "Non-supported members found:" | Out-File $ExportPath\DlToO365GroupUpgradeChecksREPORT.txt -Append
        $matchingMbr | Format-Table -AutoSize DisplayName, Alias, GUID, RecipientTypeDetails, PrimarySmtpAddress | Out-File $ExportPath\DlToO365GroupUpgradeChecksREPORT.txt -Append
        Write-Host "FIX --> Please follow the following article https://aka.ms/RemoveDGmember to proceed with removing NonSupportedMemberTypes membership from the DL!`n" -ForegroundColor Green
        "FIX --> Please follow the following article https://aka.ms/RemoveDGmember to proceed with removing NonSupportedMemberTypes membership from the DL!`n" | Out-File $ExportPath\DlToO365GroupUpgradeChecksREPORT.txt -Append
    }
}
#Check if Distribution Group can't be upgraded because it has more than 100 owners or it has no owner
Function Debugownerscount {
    param(
        [Parameter(Mandatory = $true)]
        [PScustomobject]$Distgroup
    )
    $owners = $Distgroup.ManagedBy
    if ($owners.Count -gt 100 -or $owners.Count -eq 0) {
        $script:Conditionsfailed++
        Write-Host "Distribution Group can't be upgraded because it has more than 100 owners or it has no owners" -ForegroundColor Red
        "Distribution Group can't be upgraded because it has more than 100 owners or it has no owners" | Out-File $ExportPath\DlToO365GroupUpgradeChecksREPORT.txt -Append
        Write-Host "FIX --> Please follow the following article https://aka.ms/Setdistributiongroup to adjust owners(ManagedBy) count!`n" -ForegroundColor Green
        "FIX --> Please follow the following article https://aka.ms/Setdistributiongroup to adjust owners(ManagedBy) count!`n" | Out-File $ExportPath\DlToO365GroupUpgradeChecksREPORT.txt -Append
    }
}
#Check if Distribution Group can't be upgraded because the distribution list owner(s) is non-supported with RecipientTypeDetails other than UserMailbox, MailUser
Function Debugownersstatus {
    param(
        [Parameter(Mandatory = $true)]
        [PScustomobject]$Distgroup
    )
    $owners = $Distgroup.ManagedBy
    if ($owners.Count -le 100 -and $owners.Count -ge 1) {
        $ConditionDGownerswithoutMBX = @()
        foreach ($owner in $owners) {
            try {
                $owner = Get-Recipient $owner -ErrorAction stop
                $CurrentDescription = "Validating: $owner RecipientTypeDetails"
                $CurrentStatus = "Success"
                log -Function "Validate owner RecipientTypeDetails" -CurrentStatus $CurrentStatus -CurrentDescription $CurrentDescription
                if (!($owner.RecipientTypeDetails -eq "UserMailbox" -or $owner.RecipientTypeDetails -eq "MailUser")) {
                    $ConditionDGownerswithoutMBX = $ConditionDGownerswithoutMBX + $owner
                }
            } catch {
                $CurrentDescription = "Validating: $owner RecipientTypeDetails"
                $CurrentStatus = "Failure"
                log -Function "Validate owner RecipientTypeDetails" -CurrentStatus $CurrentStatus -CurrentDescription $CurrentDescription
                #Check if the owner RecipientTypeDetails is User
                $owner = Get-User $owner -ErrorAction stop
                $ConditionDGownerswithoutMBX = $ConditionDGownerswithoutMBX + $owner
            }
        }
        if ($ConditionDGownerswithoutMBX.Count -ge 1) {
            Write-Host "Distribution Group can't be upgraded because DL owner(s) is non-supported with RecipientTypeDetails other than UserMailbox, MailUser" -ForegroundColor Red
            Write-Host "Non-supported Owner(s) found:" -BackgroundColor Yellow -ForegroundColor Black
            $ConditionDGownerswithoutMBX | Format-Table -AutoSize -Wrap Name, GUID, RecipientTypeDetails
            "Distribution Group can't be upgraded because DL owner(s) is non-supported with RecipientTypeDetails other than UserMailbox, MailUser" | Out-File $ExportPath\DlToO365GroupUpgradeChecksREPORT.txt -Append
            "Non-supported Owner(s) found:" | Out-File $ExportPath\DlToO365GroupUpgradeChecksREPORT.txt -Append
            $ConditionDGownerswithoutMBX | Format-Table -AutoSize -Wrap Name, GUID, RecipientTypeDetails | Out-File $ExportPath\DlToO365GroupUpgradeChecksREPORT.txt -Append
            $script:Conditionsfailed++
            #fix will occur if we still have supported owners to avoid zero owner condition
            if ($owners.Count -gt $ConditionDGownerswithoutMBX.Count) {
                Write-Host "FIX --> Please follow the following article https://aka.ms/Setdistributiongroup to proceed with removing non-supported RecipientTypeDetails owner(ManagedBy)!`n" -ForegroundColor Green
                "FIX --> Please follow the following article https://aka.ms/Setdistributiongroup to proceed with removing non-supported RecipientTypeDetails owner(ManagedBy)!`n" | Out-File $ExportPath\DlToO365GroupUpgradeChecksREPORT.txt -Append
            }
        }
    }
}
#Check if Distribution Group can't be upgraded because the distribution list is part of Sender Restriction in another DL
Function Debugsenderrestriction {
    param(
        [Parameter(Mandatory = $true)]
        [PScustomobject]$Distgroup
    )
    $ConditionDGSender = @()
    $DGcounterloop=0
    [int]$SenderRestrictionCount = 0
    foreach ($alldg in $alldgs) {
        if ($alldgs.count -ge 2) {
            $DGcounterloop++
            $perc=[Int32]($DGcounterloop/$alldgs.count*100)
            Write-Progress -Activity "Validating Distribution Groups Sender Restriction"  -PercentComplete $perc -Status "Processing $DGcounterloop/$($alldgs.count)group"
        }
        if ($alldg.AcceptMessagesOnlyFromSendersOrMembers -match $Distgroup.Name -or $alldg.AcceptMessagesOnlyFromDLMembers -match $Distgroup.Name ) {

            $ConditionDGSender = $ConditionDGSender + $alldg
            $SenderRestrictionCount++
        }
    }
    Write-Progress -Activity "Validating Distribution Groups Sender Restriction" -Completed
    if ($SenderRestrictionCount -ge 1) {
        $script:Conditionsfailed++
        Write-Host "Distribution Group can't be upgraded because the distribution list is part of Sender Restriction in another DL" -ForegroundColor Red
        Write-Host "Distribution group(s) with sender restriction:" -BackgroundColor Yellow -ForegroundColor Black
        $ConditionDGSender | Format-Table -AutoSize DisplayName, Alias, GUID, RecipientTypeDetails, PrimarySmtpAddress
        "Distribution Group can't be upgraded because the distribution list is part of Sender Restriction in another DL" | Out-File $ExportPath\DlToO365GroupUpgradeChecksREPORT.txt -Append
        "Distribution group(s) with sender restriction:" | Out-File $ExportPath\DlToO365GroupUpgradeChecksREPORT.txt -Append
        $ConditionDGSender | Format-Table -AutoSize DisplayName, Alias, GUID, RecipientTypeDetails, PrimarySmtpAddress | Out-File $ExportPath\DlToO365GroupUpgradeChecksREPORT.txt -Append
        Write-Host "FIX --> Please follow the following article https://aka.ms/Setdistributiongroup to proceed with removing DL from AcceptMessagesOnlyFromSendersOrMembers/AcceptMessagesOnlyFromDLMembers restriction in another DL(s)!`n" -ForegroundColor Green
        "FIX --> Please follow the following article https://aka.ms/Setdistributiongroup to proceed with removing DL from AcceptMessagesOnlyFromSendersOrMembers/AcceptMessagesOnlyFromDLMembers restriction in another DL(s)!`n" | Out-File $ExportPath\DlToO365GroupUpgradeChecksREPORT.txt -Append
    }
}
#Check if Distribution Group can't be upgraded because Distribution lists which were converted to RoomLists or isn't a security group nor Dynamic DG
Function Debuggrouprecipienttype {
    param(
        [Parameter(Mandatory = $true)]
        [PScustomobject]$Distgroup
    )
    if ($Distgroup.RecipientTypeDetails -like "MailUniversalSecurityGroup" -or $Distgroup.RecipientTypeDetails -like "DynamicDistributionGroup" -or $Distgroup.RecipientTypeDetails -like "roomlist" ) {
        $script:Conditionsfailed++
        Write-Host "Distribution Group can't be upgraded because it was converted to RoomList or is found to be a security group or Dynamic distribution group" -ForegroundColor Red
        Write-Host "Distribution Group RecipientTypeDetails is: " $Distgroup.RecipientTypeDetails
        "Distribution Group can't be upgraded because it was converted to RoomList or is found to be a security group or Dynamic distribution group" | Out-File $ExportPath\DlToO365GroupUpgradeChecksREPORT.txt -Append
        "Distribution Group RecipientTypeDetails is: " + $Distgroup.RecipientTypeDetails | Out-File $ExportPath\DlToO365GroupUpgradeChecksREPORT.txt -Append
    }
}
#Check if Distribution Group can't be upgraded because the distribution list is configured to be a forwarding address for Shared Mailbox
Function Debugforwardingforsharedmbxs {
    param(
        [Parameter(Mandatory = $true)]
        [PScustomobject]$Distgroup
    )
    $Conditionfwdmbx = @()
    try {
        Write-Warning "Retrieving all shared mailboxes in Exchange online to validate if Dl is configured as a forwarding address for a Shared Mailbox, please wait...."
        $sharedMBXs = Get-Mailbox -ResultSize unlimited -RecipientTypeDetails sharedmailbox -ErrorAction stop
        $CurrentDescription = "Retrieving All Shared MBXs in the EXO directory"
        $CurrentStatus = "Success"
        log -Function "Retrieve Shared Mailboxes" -CurrentDescription $CurrentDescription -CurrentStatus $CurrentStatus
    } catch {
        $CurrentDescription = "Retrieving All Shared MBXs in the EXO directory"
        $CurrentStatus = "Failure"
        write-log -Function "Retrieve Shared Mailboxes" -CurrentDescription $CurrentDescription -CurrentStatus $CurrentStatus
    }
    $counter = 0
    $Sharedcounter=0
    foreach ($sharedMBX in $sharedMBXs) {
        if ($sharedMBX.ForwardingAddress -match $Distgroup.name -or $sharedMBX.ForwardingSmtpAddress -match $Distgroup.PrimarySmtpAddress) {
            $Conditionfwdmbx = $Conditionfwdmbx + $sharedMBX
            $counter++
            $percent=[Int32]($Sharedcounter/$sharedMBXs.count*100)
            Write-Progress -Activity "Querying Shared Mailboxes"  -PercentComplete $percent -Status "Processing $Sharedcounter/$($sharedMBXs.count) Mailboxes"
        }
    }
    Write-Progress -Activity "Querying Shared Mailboxes" -Completed
    if ($counter -ge 1) {
        $script:Conditionsfailed++
        Write-Host "Distribution Group can't be upgraded because the distribution list is configured to be a forwarding address for Shared Mailbox" -ForegroundColor Red
        Write-Host "Shared Mailbox(es):" -BackgroundColor Yellow -ForegroundColor Black
        $Conditionfwdmbx | Format-Table -AutoSize DisplayName, Alias, GUID, RecipientTypeDetails, PrimarySmtpAddress
        "Distribution Group can't be upgraded because the distribution list is configured to be a forwarding address for Shared Mailbox" | Out-File $ExportPath\DlToO365GroupUpgradeChecksREPORT.txt -Append
        "Shared Mailbox(es):" | Out-File $ExportPath\DlToO365GroupUpgradeChecksREPORT.txt -Append
        $Conditionfwdmbx | Format-Table -AutoSize DisplayName, Alias, GUID, RecipientTypeDetails, PrimarySmtpAddress | Out-File $ExportPath\DlToO365GroupUpgradeChecksREPORT.txt -Append
        Write-Host "FIX --> Please follow the following article https://aka.ms/Setmailbox to proceed with removing DL from ForwardingAddress/ForwardingSmtpAddress in shared mailbox(es)!`n" -ForegroundColor Green
        "FIX --> Please follow the following article https://aka.ms/Setmailbox to proceed with removing DL from ForwardingAddress/ForwardingSmtpAddress in shared mailbox(es)!`n" | Out-File $ExportPath\DlToO365GroupUpgradeChecksREPORT.txt -Append
    }
}
#Check for duplicate Alias,PrimarySmtpAddress,Name,DisplayName on EXO objects
Function Debugduplicateobjects {
    param(
        [Parameter(Mandatory = $true)]
        [PScustomobject]$Distgroup
    )
    try {
        Write-Warning "Querying across Exchange online recipients for duplicate objects with $($Distgroup.PrimarySmtpAddress) group, please wait..."
        $dupAlias = Get-Recipient -IncludeSoftDeletedRecipients -Identity $Distgroup.alias -ResultSize unlimited -ErrorAction stop
        $dupAddress = Get-Recipient -IncludeSoftDeletedRecipients -ResultSize unlimited -Identity $Distgroup.PrimarySmtpAddress -ErrorAction stop
        $dupDisplayName = Get-Recipient -IncludeSoftDeletedRecipients -ResultSize unlimited -Identity $Distgroup.DisplayName -ErrorAction stop
        $dupName = Get-Recipient -IncludeSoftDeletedRecipients -ResultSize unlimited -Identity $Distgroup.Name -ErrorAction stop
        $CurrentDescription = "Retrieving duplicate recipients having same Alias,PrimarySmtpAddress,Name,DisplayName in the EXO directory"
        $CurrentStatus = "Success"
        log -Function "Retrieve Duplicate Recipient Objects" -CurrentStatus $CurrentStatus -CurrentDescription $CurrentDescription
    } catch {
        $CurrentDescription = "Retrieving duplicate recipients having same Alias,PrimarySmtpAddress,Name,DisplayName in the EXO directory"
        $CurrentStatus = "Failure"
        log -Function "Retrieve Duplicate Recipient Objects" -CurrentStatus $CurrentStatus -CurrentDescription $CurrentDescription
    }

    if ($dupAlias.Count -ge 2) {
        $script:Conditionsfailed++
        Write-Host "Distribution Group can't be upgraded because duplicate objects having same Alias found" -ForegroundColor Red
        Write-Host "Duplicate account(s):" -BackgroundColor Yellow -ForegroundColor Black
        $dupalias | Where-Object { $_.guid -notlike $Distgroup.guid } | Format-Table -AutoSize DisplayName, Alias, GUID, RecipientTypeDetails, PrimarySmtpAddress
        "Distribution Group can't be upgraded because duplicate objects having same Alias found" | Out-File $ExportPath\DlToO365GroupUpgradeChecksREPORT.txt -Append
        "Duplicate account(s):" | Out-File $ExportPath\DlToO365GroupUpgradeChecksREPORT.txt -Append
        $dupalias | Where-Object { $_.guid -notlike $Distgroup.guid } | Format-Table -AutoSize DisplayName, Alias, GUID, RecipientTypeDetails, PrimarySmtpAddress | Out-File $ExportPath\DlToO365GroupUpgradeChecksREPORT.txt -Append
    } elseif ($dupAddress.Count -ge 2) {
        $script:Conditionsfailed++
        Write-Host "Distribution Group can't be upgraded because duplicate objects having same PrimarySmtpAddress found" -ForegroundColor Red
        Write-Host "Duplicate account(s):" -BackgroundColor Yellow -ForegroundColor Black
        $dupAddress | Where-Object { $_.guid -notlike $Distgroup.guid } | Format-Table -AutoSize DisplayName, Alias, GUID, RecipientTypeDetails, PrimarySmtpAddress
        "Distribution Group can't be upgraded because duplicate objects having same PrimarySmtpAddress found" | Out-File $ExportPath\DlToO365GroupUpgradeChecksREPORT.txt -Append
        "Duplicate account(s):" | Out-File $ExportPath\DlToO365GroupUpgradeChecksREPORT.txt -Append
        $dupAddress | Where-Object { $_.guid -notlike $Distgroup.guid } | Format-Table -AutoSize DisplayName, Alias, GUID, RecipientTypeDetails, PrimarySmtpAddress   | Out-File $ExportPath\DlToO365GroupUpgradeChecksREPORT.txt -Append
    } elseif ($dupDisplayName.Count -ge 2) {
        $script:Conditionsfailed++
        Write-Host "Distribution Group can't be upgraded because duplicate objects having same DisplayName found" -ForegroundColor Red
        Write-Host "Duplicate account(s):" -BackgroundColor Yellow -ForegroundColor Black
        $dupDisplayName | Where-Object { $_.guid -notlike $Distgroup.guid } | Format-Table -AutoSize DisplayName, Alias, GUID, RecipientTypeDetails, PrimarySmtpAddress
        "Distribution Group can't be upgraded because duplicate objects having same DisplayName found" | Out-File $ExportPath\DlToO365GroupUpgradeChecksREPORT.txt -Append
        "Duplicate account(s):" | Out-File $ExportPath\DlToO365GroupUpgradeChecksREPORT.txt -Append
        $dupDisplayName | Where-Object { $_.guid -notlike $Distgroup.guid } | Format-Table -AutoSize DisplayName, Alias, GUID, RecipientTypeDetails, PrimarySmtpAddress | Out-File $ExportPath\DlToO365GroupUpgradeChecksREPORT.txt -Append
    } elseif ($dupName.Count -ge 2) {
        $script:Conditionsfailed++
        Write-Host "Distribution Group can't be upgraded because duplicate objects having same Name found" -ForegroundColor Red
        Write-Host "Duplicate account(s):" -BackgroundColor Yellow -ForegroundColor Black
        $dupName | Where-Object { $_.guid -notlike $Distgroup.guid } | Format-Table -AutoSize DisplayName, Alias, GUID, RecipientTypeDetails, PrimarySmtpAddress
        "Distribution Group can't be upgraded because duplicate objects having same Name found" | Out-File $ExportPath\DlToO365GroupUpgradeChecksREPORT.txt -Append
        "Duplicate account(s):" | Out-File $ExportPath\DlToO365GroupUpgradeChecksREPORT.txt -Append
        $dupName | Where-Object { $_.guid -notlike $Distgroup.guid } | Format-Table -AutoSize DisplayName, Alias, GUID, RecipientTypeDetails, PrimarySmtpAddress | Out-File $ExportPath\DlToO365GroupUpgradeChecksREPORT.txt -Append
    }
}

#Connect to EXO PS
$Sessioncheck = Get-PSSession | Where-Object { $_.Name -like "*Exchangeonline*" -and $_.State -match "opened" }
if ($null -eq $Sessioncheck) {
    Connect2EXO
}

#Getting the DG SMTP
$dgsmtp = Read-Host "Please enter email address of the Distribution Group"
$dgsmtp = $dgsmtp.ToLower().ToString()
try {
    $dg = get-DistributionGroup -Identity $dgsmtp -ErrorAction stop
    $CurrentDescription = "Retrieving Distribution Group from EXO Directory"
    $CurrentStatus = "Success"
    log -CurrentStatus $CurrentStatus -Function "Retrieving Distribution Group from EXO Directory" -CurrentDescription $CurrentDescription
} catch {
    $CurrentDescription = "Retrieving Distribution Group from EXO Directory"
    $CurrentStatus = "Failure"
    log -CurrentStatus $CurrentStatus -Function "Retrieving Distribution Group from EXO Directory" -CurrentDescription $CurrentDescription
    Write-Host "You entered an incorrect smtp, the script is quitting!`n" -ForegroundColor Red
    Break
}

#Intro with group name
[String]$article = "https://aka.ms/DlToM365GroupUpgrade"
[string]$Description = "This script illustrates Distribution to O365 Group migration eligibility checks taken place over group SMTP: " + $dgsmtp + ", migration BLOCKERS will be reported down!`n,please ensure to mitigate them"
$Description = $Description + ",for more informtion please check: $article`n"
Write-Host $Description -ForegroundColor Cyan
$Description | Out-File $ExportPath\DlToO365GroupUpgradeChecksREPORT.txt -Append

#Main Function
DebugMemberRestriction($dg)
DebugDirSync($dg)
Debugmatchingeap($dg)
Debuggroupnesting($dg)
DebugmembersrecipientTypes($dg)
Debugownerscount($dg)
Debugownersstatus($dg)
Debugsenderrestriction($dg)
Debuggrouprecipienttype($dg)
Debugforwardingforsharedmbxs($dg)
Debugduplicateobjects($dg)

if ($Conditionsfailed -eq 0) {
    Write-Host "All checks passed please proceed to upgrade the distribution group" -ForegroundColor Green
    "All checks passed please proceed to upgrade the distribution group" | Out-File $ExportPath\DlToO365GroupUpgradeChecksREPORT.txt -Append
}
#Ask for feedback
Write-Host "Please rate the script experience & tell us what you liked or what we can do better over https://aka.ms/DTGFeedback!" -ForegroundColor Cyan
"Please rate the script experience & tell us what you liked or what we can do better over https://aka.ms/DTGFeedback!" | Out-File $ExportPath\DlToO365GroupUpgradeChecksREPORT.txt -Append

# End of the Diag
Write-Host "`nlog file was exported in the following location: $ExportPath" -ForegroundColor Yellow
Start-Sleep -Seconds 3

# SIG # Begin signature block
# MIInzwYJKoZIhvcNAQcCoIInwDCCJ7wCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCD4KkTQ/CV5rg/M
# 2AGf9IyWy3aE7OIqS6BasEKbfhqjSKCCDYEwggX/MIID56ADAgECAhMzAAACUosz
# qviV8znbAAAAAAJSMA0GCSqGSIb3DQEBCwUAMH4xCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01pY3Jvc29mdCBDb2RlIFNpZ25p
# bmcgUENBIDIwMTEwHhcNMjEwOTAyMTgzMjU5WhcNMjIwOTAxMTgzMjU5WjB0MQsw
# CQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9u
# ZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMR4wHAYDVQQDExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIB
# AQDQ5M+Ps/X7BNuv5B/0I6uoDwj0NJOo1KrVQqO7ggRXccklyTrWL4xMShjIou2I
# sbYnF67wXzVAq5Om4oe+LfzSDOzjcb6ms00gBo0OQaqwQ1BijyJ7NvDf80I1fW9O
# L76Kt0Wpc2zrGhzcHdb7upPrvxvSNNUvxK3sgw7YTt31410vpEp8yfBEl/hd8ZzA
# v47DCgJ5j1zm295s1RVZHNp6MoiQFVOECm4AwK2l28i+YER1JO4IplTH44uvzX9o
# RnJHaMvWzZEpozPy4jNO2DDqbcNs4zh7AWMhE1PWFVA+CHI/En5nASvCvLmuR/t8
# q4bc8XR8QIZJQSp+2U6m2ldNAgMBAAGjggF+MIIBejAfBgNVHSUEGDAWBgorBgEE
# AYI3TAgBBggrBgEFBQcDAzAdBgNVHQ4EFgQUNZJaEUGL2Guwt7ZOAu4efEYXedEw
# UAYDVR0RBEkwR6RFMEMxKTAnBgNVBAsTIE1pY3Jvc29mdCBPcGVyYXRpb25zIFB1
# ZXJ0byBSaWNvMRYwFAYDVQQFEw0yMzAwMTIrNDY3NTk3MB8GA1UdIwQYMBaAFEhu
# ZOVQBdOCqhc3NyK1bajKdQKVMFQGA1UdHwRNMEswSaBHoEWGQ2h0dHA6Ly93d3cu
# bWljcm9zb2Z0LmNvbS9wa2lvcHMvY3JsL01pY0NvZFNpZ1BDQTIwMTFfMjAxMS0w
# Ny0wOC5jcmwwYQYIKwYBBQUHAQEEVTBTMFEGCCsGAQUFBzAChkVodHRwOi8vd3d3
# Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2NlcnRzL01pY0NvZFNpZ1BDQTIwMTFfMjAx
# MS0wNy0wOC5jcnQwDAYDVR0TAQH/BAIwADANBgkqhkiG9w0BAQsFAAOCAgEAFkk3
# uSxkTEBh1NtAl7BivIEsAWdgX1qZ+EdZMYbQKasY6IhSLXRMxF1B3OKdR9K/kccp
# kvNcGl8D7YyYS4mhCUMBR+VLrg3f8PUj38A9V5aiY2/Jok7WZFOAmjPRNNGnyeg7
# l0lTiThFqE+2aOs6+heegqAdelGgNJKRHLWRuhGKuLIw5lkgx9Ky+QvZrn/Ddi8u
# TIgWKp+MGG8xY6PBvvjgt9jQShlnPrZ3UY8Bvwy6rynhXBaV0V0TTL0gEx7eh/K1
# o8Miaru6s/7FyqOLeUS4vTHh9TgBL5DtxCYurXbSBVtL1Fj44+Od/6cmC9mmvrti
# yG709Y3Rd3YdJj2f3GJq7Y7KdWq0QYhatKhBeg4fxjhg0yut2g6aM1mxjNPrE48z
# 6HWCNGu9gMK5ZudldRw4a45Z06Aoktof0CqOyTErvq0YjoE4Xpa0+87T/PVUXNqf
# 7Y+qSU7+9LtLQuMYR4w3cSPjuNusvLf9gBnch5RqM7kaDtYWDgLyB42EfsxeMqwK
# WwA+TVi0HrWRqfSx2olbE56hJcEkMjOSKz3sRuupFCX3UroyYf52L+2iVTrda8XW
# esPG62Mnn3T8AuLfzeJFuAbfOSERx7IFZO92UPoXE1uEjL5skl1yTZB3MubgOA4F
# 8KoRNhviFAEST+nG8c8uIsbZeb08SeYQMqjVEmkwggd6MIIFYqADAgECAgphDpDS
# AAAAAAADMA0GCSqGSIb3DQEBCwUAMIGIMQswCQYDVQQGEwJVUzETMBEGA1UECBMK
# V2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0
# IENvcnBvcmF0aW9uMTIwMAYDVQQDEylNaWNyb3NvZnQgUm9vdCBDZXJ0aWZpY2F0
# ZSBBdXRob3JpdHkgMjAxMTAeFw0xMTA3MDgyMDU5MDlaFw0yNjA3MDgyMTA5MDla
# MH4xCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdS
# ZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMT
# H01pY3Jvc29mdCBDb2RlIFNpZ25pbmcgUENBIDIwMTEwggIiMA0GCSqGSIb3DQEB
# AQUAA4ICDwAwggIKAoICAQCr8PpyEBwurdhuqoIQTTS68rZYIZ9CGypr6VpQqrgG
# OBoESbp/wwwe3TdrxhLYC/A4wpkGsMg51QEUMULTiQ15ZId+lGAkbK+eSZzpaF7S
# 35tTsgosw6/ZqSuuegmv15ZZymAaBelmdugyUiYSL+erCFDPs0S3XdjELgN1q2jz
# y23zOlyhFvRGuuA4ZKxuZDV4pqBjDy3TQJP4494HDdVceaVJKecNvqATd76UPe/7
# 4ytaEB9NViiienLgEjq3SV7Y7e1DkYPZe7J7hhvZPrGMXeiJT4Qa8qEvWeSQOy2u
# M1jFtz7+MtOzAz2xsq+SOH7SnYAs9U5WkSE1JcM5bmR/U7qcD60ZI4TL9LoDho33
# X/DQUr+MlIe8wCF0JV8YKLbMJyg4JZg5SjbPfLGSrhwjp6lm7GEfauEoSZ1fiOIl
# XdMhSz5SxLVXPyQD8NF6Wy/VI+NwXQ9RRnez+ADhvKwCgl/bwBWzvRvUVUvnOaEP
# 6SNJvBi4RHxF5MHDcnrgcuck379GmcXvwhxX24ON7E1JMKerjt/sW5+v/N2wZuLB
# l4F77dbtS+dJKacTKKanfWeA5opieF+yL4TXV5xcv3coKPHtbcMojyyPQDdPweGF
# RInECUzF1KVDL3SV9274eCBYLBNdYJWaPk8zhNqwiBfenk70lrC8RqBsmNLg1oiM
# CwIDAQABo4IB7TCCAekwEAYJKwYBBAGCNxUBBAMCAQAwHQYDVR0OBBYEFEhuZOVQ
# BdOCqhc3NyK1bajKdQKVMBkGCSsGAQQBgjcUAgQMHgoAUwB1AGIAQwBBMAsGA1Ud
# DwQEAwIBhjAPBgNVHRMBAf8EBTADAQH/MB8GA1UdIwQYMBaAFHItOgIxkEO5FAVO
# 4eqnxzHRI4k0MFoGA1UdHwRTMFEwT6BNoEuGSWh0dHA6Ly9jcmwubWljcm9zb2Z0
# LmNvbS9wa2kvY3JsL3Byb2R1Y3RzL01pY1Jvb0NlckF1dDIwMTFfMjAxMV8wM18y
# Mi5jcmwwXgYIKwYBBQUHAQEEUjBQME4GCCsGAQUFBzAChkJodHRwOi8vd3d3Lm1p
# Y3Jvc29mdC5jb20vcGtpL2NlcnRzL01pY1Jvb0NlckF1dDIwMTFfMjAxMV8wM18y
# Mi5jcnQwgZ8GA1UdIASBlzCBlDCBkQYJKwYBBAGCNy4DMIGDMD8GCCsGAQUFBwIB
# FjNodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2RvY3MvcHJpbWFyeWNw
# cy5odG0wQAYIKwYBBQUHAgIwNB4yIB0ATABlAGcAYQBsAF8AcABvAGwAaQBjAHkA
# XwBzAHQAYQB0AGUAbQBlAG4AdAAuIB0wDQYJKoZIhvcNAQELBQADggIBAGfyhqWY
# 4FR5Gi7T2HRnIpsLlhHhY5KZQpZ90nkMkMFlXy4sPvjDctFtg/6+P+gKyju/R6mj
# 82nbY78iNaWXXWWEkH2LRlBV2AySfNIaSxzzPEKLUtCw/WvjPgcuKZvmPRul1LUd
# d5Q54ulkyUQ9eHoj8xN9ppB0g430yyYCRirCihC7pKkFDJvtaPpoLpWgKj8qa1hJ
# Yx8JaW5amJbkg/TAj/NGK978O9C9Ne9uJa7lryft0N3zDq+ZKJeYTQ49C/IIidYf
# wzIY4vDFLc5bnrRJOQrGCsLGra7lstnbFYhRRVg4MnEnGn+x9Cf43iw6IGmYslmJ
# aG5vp7d0w0AFBqYBKig+gj8TTWYLwLNN9eGPfxxvFX1Fp3blQCplo8NdUmKGwx1j
# NpeG39rz+PIWoZon4c2ll9DuXWNB41sHnIc+BncG0QaxdR8UvmFhtfDcxhsEvt9B
# xw4o7t5lL+yX9qFcltgA1qFGvVnzl6UJS0gQmYAf0AApxbGbpT9Fdx41xtKiop96
# eiL6SJUfq/tHI4D1nvi/a7dLl+LrdXga7Oo3mXkYS//WsyNodeav+vyL6wuA6mk7
# r/ww7QRMjt/fdW1jkT3RnVZOT7+AVyKheBEyIXrvQQqxP/uozKRdwaGIm1dxVk5I
# RcBCyZt2WwqASGv9eZ/BvW1taslScxMNelDNMYIZpDCCGaACAQEwgZUwfjELMAkG
# A1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQx
# HjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEoMCYGA1UEAxMfTWljcm9z
# b2Z0IENvZGUgU2lnbmluZyBQQ0EgMjAxMQITMwAAAlKLM6r4lfM52wAAAAACUjAN
# BglghkgBZQMEAgEFAKCBxjAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgor
# BgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAvBgkqhkiG9w0BCQQxIgQgx+N5k4F9
# +nyqJvo6frLcJ9FWNT2XSYDSph/NAXqMiRQwWgYKKwYBBAGCNwIBDDFMMEqgGoAY
# AEMAUwBTACAARQB4AGMAaABhAG4AZwBloSyAKmh0dHBzOi8vZ2l0aHViLmNvbS9t
# aWNyb3NvZnQvQ1NTLUV4Y2hhbmdlIDANBgkqhkiG9w0BAQEFAASCAQBx5dCgmyOB
# Mpwy4+EZp6S80L8kDWbAUW6+FGOh6OhUlSmuSiA4rl0ijWYlyBecqpjb5T3w/b5K
# JhxFo5haqnJqpsk8RJIWAWoi/pRl1W/HuisMpCDj7fwvfFtiI/esljAhedDvVMV5
# ssxH8exr4o6HQC+6VzWEGYjP3PprbaJF4q2M+reGPP7P19CA7asDdS5+CDqtawRe
# FOTBi1dOG0AMGVSV+bFKSnWHRw3dq8ocZ6ysJQeOMQHFcX39V9SpMIulK1hkbBT7
# GwCdUMHGhI0R/b0POf3T/uyQLX05A8a/J6Gj33gjxiMxa+FSuNmhmLEUsVRIOHWy
# TlIM/2XncJApoYIXFjCCFxIGCisGAQQBgjcDAwExghcCMIIW/gYJKoZIhvcNAQcC
# oIIW7zCCFusCAQMxDzANBglghkgBZQMEAgEFADCCAVkGCyqGSIb3DQEJEAEEoIIB
# SASCAUQwggFAAgEBBgorBgEEAYRZCgMBMDEwDQYJYIZIAWUDBAIBBQAEIFOsx/vK
# IL+zosz3m6gscyJnCunSXUmV2fElOd/fwHWOAgZiZuQie8cYEzIwMjIwNDI3MjAy
# MzIzLjEwMVowBIACAfSggdikgdUwgdIxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpX
# YXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQg
# Q29ycG9yYXRpb24xLTArBgNVBAsTJE1pY3Jvc29mdCBJcmVsYW5kIE9wZXJhdGlv
# bnMgTGltaXRlZDEmMCQGA1UECxMdVGhhbGVzIFRTUyBFU046MkFENC00QjkyLUZB
# MDExJTAjBgNVBAMTHE1pY3Jvc29mdCBUaW1lLVN0YW1wIFNlcnZpY2WgghFlMIIH
# FDCCBPygAwIBAgITMwAAAYZ45RmJ+CRLzAABAAABhjANBgkqhkiG9w0BAQsFADB8
# MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVk
# bW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYDVQQDEx1N
# aWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMDAeFw0yMTEwMjgxOTI3MzlaFw0y
# MzAxMjYxOTI3MzlaMIHSMQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3Rv
# bjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0
# aW9uMS0wKwYDVQQLEyRNaWNyb3NvZnQgSXJlbGFuZCBPcGVyYXRpb25zIExpbWl0
# ZWQxJjAkBgNVBAsTHVRoYWxlcyBUU1MgRVNOOjJBRDQtNEI5Mi1GQTAxMSUwIwYD
# VQQDExxNaWNyb3NvZnQgVGltZS1TdGFtcCBTZXJ2aWNlMIICIjANBgkqhkiG9w0B
# AQEFAAOCAg8AMIICCgKCAgEAwI3G2Wpv6B4IjAfrgfJpndPOPYO1Yd8+vlfoIxMW
# 3gdCDT+zIbafg14pOu0t0ekUQx60p7PadH4OjnqNIE1q6ldH9ntj1gIdl4Hq4rdE
# HTZ6JFdE24DSbVoqqR+R4Iw4w3GPbfc2Q3kfyyFyj+DOhmCWw/FZiTVTlT4bdejy
# AW6r/Jn4fr3xLjbvhITatr36VyyzgQ0Y4Wr73H3gUcLjYu0qiHutDDb6+p+yDBGm
# KFznOW8wVt7D+u2VEJoE6JlK0EpVLZusdSzhecuUwJXxb2uygAZXlsa/fHlwW9Yn
# lBqMHJ+im9HuK5X4x8/5B5dkuIoX5lWGjFMbD2A6Lu/PmUB4hK0CF5G1YaUtBrME
# 73DAKkypk7SEm3BlJXwY/GrVoXWYUGEHyfrkLkws0RoEMpoIEgebZNKqjRynRJgR
# 4fPCKrEhwEiTTAc4DXGci4HHOm64EQ1g/SDHMFqIKVSxoUbkGbdKNKHhmahuIrAy
# 4we9s7rZJskveZYZiDmtAtBt/gQojxbZ1vO9C11SthkrmkkTMLQf9cDzlVEBeu6K
# mHX2Sze6ggne3I4cy/5IULnHZ3rM4ZpJc0s2KpGLHaVrEQy4x/mAn4yaYfgeH3ME
# AWkVjy/qTDh6cDCF/gyz3TaQDtvFnAK70LqtbEvBPdBpeCG/hk9l0laYzwiyyGY/
# HqMCAwEAAaOCATYwggEyMB0GA1UdDgQWBBQZtqNFA+9mdEu/h33UhHMN6whcLjAf
# BgNVHSMEGDAWgBSfpxVdAF5iXYP05dJlpxtTNRnpcjBfBgNVHR8EWDBWMFSgUqBQ
# hk5odHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2NybC9NaWNyb3NvZnQl
# MjBUaW1lLVN0YW1wJTIwUENBJTIwMjAxMCgxKS5jcmwwbAYIKwYBBQUHAQEEYDBe
# MFwGCCsGAQUFBzAChlBodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2Nl
# cnRzL01pY3Jvc29mdCUyMFRpbWUtU3RhbXAlMjBQQ0ElMjAyMDEwKDEpLmNydDAM
# BgNVHRMBAf8EAjAAMBMGA1UdJQQMMAoGCCsGAQUFBwMIMA0GCSqGSIb3DQEBCwUA
# A4ICAQDD7mehJY3fTHKC4hj+wBWB8544uaJiMMIHnhK9ONTM7VraTYzx0U/TcLJ6
# gxw1tRzM5uu8kswJNlHNp7RedsAiwviVQZV9AL8IbZRLJTwNehCwk+BVcY2gh3ZG
# Zmx8uatPZrRueyhhTTD2PvFVLrfwh2liDG/dEPNIHTKj79DlEcPIWoOCUp7p0ORM
# wQ95kVaibpX89pvjhPl2Fm0CBO3pXXJg0bydpQ5dDDTv/qb0+WYF/vNVEU/MoMEQ
# qlUWWuXECTqx6TayJuLJ6uU7K5QyTkQ/l24IhGjDzf5AEZOrINYzkWVyNfUOpIxn
# KsWTBN2ijpZ/Tun5qrmo9vNIDT0lobgnulae17NaEO9oiEJJH1tQ353dhuRi+A00
# PR781iYlzF5JU1DrEfEyNx8CWgERi90LKsYghZBCDjQ3DiJjfUZLqONeHrJfcmhz
# 5/bfm8+aAaUPpZFeP0g0Iond6XNk4YiYbWPFoofc0LwcqSALtuIAyz6f3d+UaZZs
# p41U4hCIoGj6hoDIuU839bo/mZ/AgESwGxIXs0gZU6A+2qIUe60QdA969wWSzucK
# Oisng9HCSZLF1dqc3QUawr0C0U41784Ko9vckAG3akwYuVGcs6hM/SqEhoe9jHwe
# 4Xp81CrTB1l9+EIdukCbP0kyzx0WZzteeiDN5rdiiQR9mBJuljCCB3EwggVZoAMC
# AQICEzMAAAAVxedrngKbSZkAAAAAABUwDQYJKoZIhvcNAQELBQAwgYgxCzAJBgNV
# BAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4w
# HAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xMjAwBgNVBAMTKU1pY3Jvc29m
# dCBSb290IENlcnRpZmljYXRlIEF1dGhvcml0eSAyMDEwMB4XDTIxMDkzMDE4MjIy
# NVoXDTMwMDkzMDE4MzIyNVowfDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hp
# bmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jw
# b3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAgUENBIDIwMTAw
# ggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQDk4aZM57RyIQt5osvXJHm9
# DtWC0/3unAcH0qlsTnXIyjVX9gF/bErg4r25PhdgM/9cT8dm95VTcVrifkpa/rg2
# Z4VGIwy1jRPPdzLAEBjoYH1qUoNEt6aORmsHFPPFdvWGUNzBRMhxXFExN6AKOG6N
# 7dcP2CZTfDlhAnrEqv1yaa8dq6z2Nr41JmTamDu6GnszrYBbfowQHJ1S/rboYiXc
# ag/PXfT+jlPP1uyFVk3v3byNpOORj7I5LFGc6XBpDco2LXCOMcg1KL3jtIckw+DJ
# j361VI/c+gVVmG1oO5pGve2krnopN6zL64NF50ZuyjLVwIYwXE8s4mKyzbnijYjk
# lqwBSru+cakXW2dg3viSkR4dPf0gz3N9QZpGdc3EXzTdEonW/aUgfX782Z5F37Zy
# L9t9X4C626p+Nuw2TPYrbqgSUei/BQOj0XOmTTd0lBw0gg/wEPK3Rxjtp+iZfD9M
# 269ewvPV2HM9Q07BMzlMjgK8QmguEOqEUUbi0b1qGFphAXPKZ6Je1yh2AuIzGHLX
# pyDwwvoSCtdjbwzJNmSLW6CmgyFdXzB0kZSU2LlQ+QuJYfM2BjUYhEfb3BvR/bLU
# HMVr9lxSUV0S2yW6r1AFemzFER1y7435UsSFF5PAPBXbGjfHCBUYP3irRbb1Hode
# 2o+eFnJpxq57t7c+auIurQIDAQABo4IB3TCCAdkwEgYJKwYBBAGCNxUBBAUCAwEA
# ATAjBgkrBgEEAYI3FQIEFgQUKqdS/mTEmr6CkTxGNSnPEP8vBO4wHQYDVR0OBBYE
# FJ+nFV0AXmJdg/Tl0mWnG1M1GelyMFwGA1UdIARVMFMwUQYMKwYBBAGCN0yDfQEB
# MEEwPwYIKwYBBQUHAgEWM2h0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMv
# RG9jcy9SZXBvc2l0b3J5Lmh0bTATBgNVHSUEDDAKBggrBgEFBQcDCDAZBgkrBgEE
# AYI3FAIEDB4KAFMAdQBiAEMAQTALBgNVHQ8EBAMCAYYwDwYDVR0TAQH/BAUwAwEB
# /zAfBgNVHSMEGDAWgBTV9lbLj+iiXGJo0T2UkFvXzpoYxDBWBgNVHR8ETzBNMEug
# SaBHhkVodHRwOi8vY3JsLm1pY3Jvc29mdC5jb20vcGtpL2NybC9wcm9kdWN0cy9N
# aWNSb29DZXJBdXRfMjAxMC0wNi0yMy5jcmwwWgYIKwYBBQUHAQEETjBMMEoGCCsG
# AQUFBzAChj5odHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpL2NlcnRzL01pY1Jv
# b0NlckF1dF8yMDEwLTA2LTIzLmNydDANBgkqhkiG9w0BAQsFAAOCAgEAnVV9/Cqt
# 4SwfZwExJFvhnnJL/Klv6lwUtj5OR2R4sQaTlz0xM7U518JxNj/aZGx80HU5bbsP
# MeTCj/ts0aGUGCLu6WZnOlNN3Zi6th542DYunKmCVgADsAW+iehp4LoJ7nvfam++
# Kctu2D9IdQHZGN5tggz1bSNU5HhTdSRXud2f8449xvNo32X2pFaq95W2KFUn0CS9
# QKC/GbYSEhFdPSfgQJY4rPf5KYnDvBewVIVCs/wMnosZiefwC2qBwoEZQhlSdYo2
# wh3DYXMuLGt7bj8sCXgU6ZGyqVvfSaN0DLzskYDSPeZKPmY7T7uG+jIa2Zb0j/aR
# AfbOxnT99kxybxCrdTDFNLB62FD+CljdQDzHVG2dY3RILLFORy3BFARxv2T5JL5z
# bcqOCb2zAVdJVGTZc9d/HltEAY5aGZFrDZ+kKNxnGSgkujhLmm77IVRrakURR6nx
# t67I6IleT53S0Ex2tVdUCbFpAUR+fKFhbHP+CrvsQWY9af3LwUFJfn6Tvsv4O+S3
# Fb+0zj6lMVGEvL8CwYKiexcdFYmNcP7ntdAoGokLjzbaukz5m/8K6TT4JDVnK+AN
# uOaMmdbhIurwJ0I9JZTmdHRbatGePu1+oDEzfbzL6Xu/OHBE0ZDxyKs6ijoIYn/Z
# cGNTTY3ugm2lBRDBcQZqELQdVTNYs6FwZvKhggLUMIICPQIBATCCAQChgdikgdUw
# gdIxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdS
# ZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xLTArBgNVBAsT
# JE1pY3Jvc29mdCBJcmVsYW5kIE9wZXJhdGlvbnMgTGltaXRlZDEmMCQGA1UECxMd
# VGhhbGVzIFRTUyBFU046MkFENC00QjkyLUZBMDExJTAjBgNVBAMTHE1pY3Jvc29m
# dCBUaW1lLVN0YW1wIFNlcnZpY2WiIwoBATAHBgUrDgMCGgMVAAGu2DRzWkKljmXy
# SX1korHL4fMnoIGDMIGApH4wfDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hp
# bmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jw
# b3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAgUENBIDIwMTAw
# DQYJKoZIhvcNAQEFBQACBQDmFAWQMCIYDzIwMjIwNDI4MDIxMDI0WhgPMjAyMjA0
# MjkwMjEwMjRaMHQwOgYKKwYBBAGEWQoEATEsMCowCgIFAOYUBZACAQAwBwIBAAIC
# Ap0wBwIBAAICEVkwCgIFAOYVVxACAQAwNgYKKwYBBAGEWQoEAjEoMCYwDAYKKwYB
# BAGEWQoDAqAKMAgCAQACAwehIKEKMAgCAQACAwGGoDANBgkqhkiG9w0BAQUFAAOB
# gQA+hVyNh0KjhckluTGXhI6HlfFM7Ru5O3gII4NS5akb/5DtEA37g1CxS5WlpF8C
# 7KqvE1L2CDE+FKwtp0ZB45EiqqRSZHFJARy/4kqb7lJZAShBHupe5jOWougTaWRJ
# UANCxH7eGv/mv7xaiX29p6DhMxq8R2w6TUgEl31zEutp+zGCBA0wggQJAgEBMIGT
# MHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdS
# ZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xJjAkBgNVBAMT
# HU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAyMDEwAhMzAAABhnjlGYn4JEvMAAEA
# AAGGMA0GCWCGSAFlAwQCAQUAoIIBSjAaBgkqhkiG9w0BCQMxDQYLKoZIhvcNAQkQ
# AQQwLwYJKoZIhvcNAQkEMSIEIPGKxbK5Pqqpg2uPimTwSsifHLkFzyDMj4svfj4B
# O3MAMIH6BgsqhkiG9w0BCRACLzGB6jCB5zCB5DCBvQQgGpmI4LIsCFTGiYyfRAR7
# m7Fa2guxVNIw17mcAiq8Qn4wgZgwgYCkfjB8MQswCQYDVQQGEwJVUzETMBEGA1UE
# CBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9z
# b2Z0IENvcnBvcmF0aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQ
# Q0EgMjAxMAITMwAAAYZ45RmJ+CRLzAABAAABhjAiBCCKY0y75t6R7A1b2K+AtIsU
# ItqGdZSarWqI/3KqrAqKPjANBgkqhkiG9w0BAQsFAASCAgBpzbP9qsXvxGdqNOgl
# A/Yuo50W3mEXp523czXnJcGMo8u3pCthHi1vjOkcM3/9krylCx/T8lNINRxNi/qc
# D9FEvWL8egBmOeuZt845cA4uEHuqMV8ikZmHbtcQj+s6wSljaj4FaL+RepkNX5FT
# BgIxM2FpUrUJx+5JqcVOi4WZ1t5uQUFwA7DjbMVhrxaE/wCQmAdccqUm9VE72Rsf
# Bb5fNjXba2WM0G3q41gIKMOfJmZnsSkggrwXU8ua26JgtCVuoRZ+z6iwUe1Uaoej
# 1aIDLFkxvlyT2RQE8L8DEiKOUM4vj8BxKVFJkpu7ypT8eB8P3wS+ZIm5Z0l8gYLK
# 5UVoGMuaEplufmjDzcJU34YT7in6V73ssH4RmRmABRFIh4ZrMsr61Xr43mct+ZYr
# UCTlV8nAajfWVZqSgTXwO2y45wOYZ0bt3u2FfBzskQGK27+gHlXjfqibnIZLhSBI
# YU2YjZhEnYwBxSybU52oKtc/Bfw0rOy21sW3xM2YNaBQ/BgKi+CwGbYhshPkmpR+
# CduGh1y4N2gxb7FjPi+XKvmNERvgGIipbfDSYhAYJrMKV7tYKbXlkhM34AQ6pVfg
# oyW1HhRuZ9uLu6b4Th16d59FTTS0U4YfQKmuC+1gi7rhvCQTkgPUmGcpeS7jRVis
# 95MfZnVqHgXMxzNhGctytTIumw==
# SIG # End signature block
