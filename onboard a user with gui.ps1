<#  Created  9/6/2018 by Taylor Bogle
    This script is used to create new users.
#>

<# Updated 7/12/2021 by Nick Elwood
    Modified with company information for APR.
#>

###################
##Load Variables###
###################

#Department Variables
$Dept_Admin              = "Administration"
$Dept_Commercial         = "Commercial"
$Dept_EPC                = "EPC"
$Dept_Finance            = "Finance"
$Dept_HR                 = "Human Resources"
$Dept_IT                 = "IT"
$Dept_Legal              = "Legal"
$Dept_Operations         = "Operations"

#Office Variables
$off_Jacksonville        = "Jacksonville"
$off_Virtual             = "Virtual"


Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

########################
#Start of building Form#
########################
$Form                            = New-Object system.Windows.Forms.Form
$Form.ClientSize                 = '450,750'
$Form.text                       = "Create a New User"
$Form.TopMost                    = $false
$Form.AutoScroll                 = $True
$Form.BackColor                  = "white"
$Form.StartPosition              = "CenterScreen"
#
# Form Controls
#

#First Name
$TextBox_FirstName               = New-Object system.Windows.Forms.TextBox
$TextBox_FirstName.multiline     = $false
$TextBox_FirstName.width         = 200
$TextBox_FirstName.height        = 20
$TextBox_FirstName.location      = New-Object System.Drawing.Point(190,36)
$TextBox_FirstName.Font          = 'Microsoft Sans Serif,10'

#LastName
$TextBox_LastName                = New-Object system.Windows.Forms.TextBox
$TextBox_LastName.multiline      = $false
$TextBox_LastName.width          = 200
$TextBox_LastName.height         = 20
$TextBox_LastName.location       = New-Object System.Drawing.Point(190,75)
$TextBox_LastName.Font           = 'Microsoft Sans Serif,10'

#Username
$TextBox_UserName                = New-Object system.Windows.Forms.Label
$TextBox_UserName.text           = ""
#$TextBox_UserName.multiline      = $false
$TextBox_UserName.width          = 200
$TextBox_UserName.height         = 20
$TextBox_UserName.location       = New-Object System.Drawing.Point(190,117)
$TextBox_UserName.Font           = 'Microsoft Sans Serif,10'

#Set username
$TextBox_FirstName.Add_Validating({
    $TextBox_UserName.Text = $TextBox_FirstName.Text.Substring(0,1) + $TextBox_LastName.Text
})
$TextBox_LastName.Add_Validating({
    $TextBox_UserName.Text = $TextBox_FirstName.Text.Substring(0,1) + $TextBox_LastName.Text
})

<# For FirstName.LastName
$TextBox_FirstName.Add_Validating({
    $TextBox_UserName.Text = $TextBox_FirstName.Text + "." + $TextBox_LastName.Text
})
$TextBox_LastName.Add_Validating({
    $TextBox_UserName.Text = $TextBox_FirstName.Text + "." + $TextBox_LastName.Text
})
#>

#Domain No-edit
$TextBox_Domain                  = New-Object system.Windows.Forms.Label
$TextBox_Domain.text             = "@aprenergy.com"
#$TextBox_Domain.Multiline        = $false
$TextBox_Domain.width            = 200
$TextBox_Domain.height           = 20
$TextBox_Domain.location         = New-Object System.Drawing.Point(190,150)
$TextBox_Domain.Font             = 'Microsoft Sans Serif,10'

#Description
$TextBox_Desc                 = New-Object system.Windows.Forms.TextBox
$TextBox_Desc.multiline       = $false
$TextBox_Desc.width           = 200
$TextBox_Desc.height          = 20
$TextBox_Desc.location        = New-Object System.Drawing.Point(190,180)
$TextBox_Desc.Font            = 'Microsoft Sans Serif,10'

#Job Title
$TextBox_JobTitle                 = New-Object system.Windows.Forms.TextBox
$TextBox_JobTitle.multiline       = $false
$TextBox_JobTitle.width           = 200
$TextBox_JobTitle.height          = 20
$TextBox_JobTitle.location        = New-Object System.Drawing.Point(190,222)
$TextBox_JobTitle.Font            = 'Microsoft Sans Serif,10'

#Manager
$TextBox_Manager                 = New-Object system.Windows.Forms.TextBox
$TextBox_Manager.multiline       = $false
$TextBox_Manager.width           = 200
$TextBox_Manager.height          = 20
$TextBox_Manager.location        = New-Object System.Drawing.Point(190,261)
$TextBox_Manager.Font            = 'Microsoft Sans Serif,10'

#Office Combo Box
$ComboBox_Office                 = New-Object system.Windows.Forms.ComboBox
$ComboBox_Office.text            = "Office"
$ComboBox_Office.width           = 250
$ComboBox_Office.height          = 20
$ComboBox_Office.location        = New-Object System.Drawing.Point(190,307)
$ComboBox_Office.Font            = 'Microsoft Sans Serif,10'
$ComboBox_Office.Items.add($off_Jacksonville)
$ComboBox_Office.Items.add($off_Virtual)

#Business Unit Combo Box
$ComboBox_Dept                     = New-Object system.Windows.Forms.ComboBox
$ComboBox_Dept.text                = "Department"
$ComboBox_Dept.width               = 250
$ComboBox_Dept.height              = 20
$ComboBox_Dept.location            = New-Object System.Drawing.Point(190,357)
$ComboBox_Dept.Font                = 'Microsoft Sans Serif,10'
$ComboBox_Dept.Items.add($Dept_Admin)
$ComboBox_Dept.Items.add($Dept_Commercial)
$ComboBox_Dept.Items.add($Dept_EPC)
$ComboBox_Dept.Items.add($Dept_Finance)
$ComboBox_Dept.Items.add($Dept_HR)
$ComboBox_Dept.Items.add($Dept_IT)
$ComboBox_Dept.Items.add($Dept_Legal)
$ComboBox_Dept.Items.add($Dept_Operations)

#Employee ID
$TextBox_EmpID                   = New-Object system.Windows.Forms.TextBox
$TextBox_EmpID.multiline         = $false
$TextBox_EmpID.width             = 200
$TextBox_EmpID.height            = 20
$TextBox_EmpID.location          = New-Object System.Drawing.Point(190,401)
$TextBox_EmpID.Font              = 'Microsoft Sans Serif,10'

#Employee vs Contingent Radio Button Box
$groupBox_EmpVsCont = New-Object System.Windows.Forms.GroupBox #create the group box
$groupBox_EmpVsCont.Location = New-Object System.Drawing.Size(190,425) #location of the group box (px) in relation to the primary window's edges (length, height)
$groupBox_EmpVsCont.size = New-Object System.Drawing.Size(200,85) #the size in px of the group box (length, height)

#Employee Radio
$RadioButton_Type_Employee       = New-Object system.Windows.Forms.RadioButton
$RadioButton_Type_Employee.text  = "APR Employee"
$RadioButton_Type_Employee.AutoSize  = $true
$RadioButton_Type_Employee.width  = 104
$RadioButton_Type_Employee.height  = 20
$RadioButton_Type_Employee.location  = New-Object System.Drawing.Point(1,15)
$RadioButton_Type_Employee.Font  = 'Microsoft Sans Serif,10'

#Independent Contratacto Radio
$RadioButton_Type_IC     = New-Object system.Windows.Forms.RadioButton
$RadioButton_Type_IC.text  = "Independent Contractor"
$RadioButton_Type_IC.AutoSize  = $true
$RadioButton_Type_IC.width  = 104
$RadioButton_Type_IC.height  = 20
$RadioButton_Type_IC.location  = New-Object System.Drawing.Point(1,35)
$RadioButton_Type_IC.Font  = 'Microsoft Sans Serif,10'

#3rd Party Contractor Radio
$RadioButton_Type_3PC     = New-Object system.Windows.Forms.RadioButton
$RadioButton_Type_3PC.text  = "3rd Party Contractor"
$RadioButton_Type_3PC.AutoSize  = $true
$RadioButton_Type_3PC.width  = 104
$RadioButton_Type_3PC.height  = 20
$RadioButton_Type_3PC.location  = New-Object System.Drawing.Point(1,55)
$RadioButton_Type_3PC.Font  = 'Microsoft Sans Serif,10'

#Adding buttons to Employee vs Contingent Group
$groupBox_EmpVsCont.Controls.Add($RadioButton_Type_Employee)
$groupBox_EmpVsCont.Controls.Add($RadioButton_Type_IC)
$groupBox_EmpVsCont.Controls.Add($RadioButton_Type_3PC)

#Ticket Number
$TextBox_TicketNum               = New-Object system.Windows.Forms.TextBox
$TextBox_TicketNum.multiline     = $false
$TextBox_TicketNum.width         = 200
$TextBox_TicketNum.height        = 20
$TextBox_TicketNum.location      = New-Object System.Drawing.Point(190,531)
$TextBox_TicketNum.Font          = 'Microsoft Sans Serif,10'

#
#Labels
#
$Label1                          = New-Object system.Windows.Forms.Label
$Label1.text                     = "First Name"
$Label1.AutoSize                 = $true
$Label1.width                    = 120
$Label1.height                   = 20
$Label1.Anchor                   = 'top,right,left'
$Label1.location                 = New-Object System.Drawing.Point(94,38)
$Label1.Font                     = 'Microsoft Sans Serif,10'

$Label2                          = New-Object system.Windows.Forms.Label
$Label2.text                     = "Last Name"
$Label2.AutoSize                 = $true
$Label2.width                    = 117
$Label2.height                   = 20
$Label2.Anchor                   = 'top,right,left'
$Label2.location                 = New-Object System.Drawing.Point(95,79)
$Label2.Font                     = 'Microsoft Sans Serif,10'

$Label3                          = New-Object system.Windows.Forms.Label
$Label3.text                     = "User Name"
$Label3.AutoSize                 = $true
$Label3.width                    = 117
$Label3.height                   = 20
$Label3.Anchor                   = 'top,right,left'
$Label3.location                 = New-Object System.Drawing.Point(94,117)
$Label3.Font                     = 'Microsoft Sans Serif,10'

$Label4                          = New-Object system.Windows.Forms.Label
$Label4.text                     = "Domain"
$Label4.AutoSize                 = $true
$Label4.width                    = 120
$Label4.height                   = 20
$Label4.location                 = New-Object System.Drawing.Point(113,150)
$Label4.Font                     = 'Microsoft Sans Serif,10'

$LabelDesc                          = New-Object system.Windows.Forms.Label
$LabelDesc.text                     = "Description"
$LabelDesc.AutoSize                 = $true
$LabelDesc.width                    = 120
$LabelDesc.height                   = 20
$LabelDesc.location                 = New-Object System.Drawing.Point(92,181)
$LabelDesc.Font                     = 'Microsoft Sans Serif,10'

$Label5                          = New-Object system.Windows.Forms.Label
$Label5.text                     = "Manager User Name"
$Label5.AutoSize                 = $true
$Label5.width                    = 120
$Label5.height                   = 20
$Label5.location                 = New-Object System.Drawing.Point(43,261)
$Label5.Font                     = 'Microsoft Sans Serif,10'

$Label8                          = New-Object system.Windows.Forms.Label
$Label8.text                     = "Job Title"
$Label8.AutoSize                 = $true
$Label8.width                    = 120
$Label8.height                   = 20
$Label8.location                 = New-Object System.Drawing.Point(110,222)
$Label8.Font                     = 'Microsoft Sans Serif,10'


$Label6                          = New-Object system.Windows.Forms.Label
$Label6.text                     = "Office"
$Label6.AutoSize                 = $true
$Label6.width                    = 120
$Label6.height                   = 20
$Label6.location                 = New-Object System.Drawing.Point(124,308)
$Label6.Font                     = 'Microsoft Sans Serif,10'

$Label7                          = New-Object system.Windows.Forms.Label
$Label7.text                     = "Department"
$Label7.AutoSize                 = $true
$Label7.width                    = 120
$Label7.height                   = 20
$Label7.location                 = New-Object System.Drawing.Point(93,357)
$Label7.Font                     = 'Microsoft Sans Serif,10'

$Label9                          = New-Object system.Windows.Forms.Label
$Label9.text                     = "Employee ID"
$Label9.AutoSize                 = $true
$Label9.width                    = 120
$Label9.height                   = 20
$Label9.location                 = New-Object System.Drawing.Point(88,401)
$Label9.Font                     = 'Microsoft Sans Serif,10'

$Label10                         = New-Object system.Windows.Forms.Label
$Label10.text                    = "Employee Type"
$Label10.AutoSize                = $true
$Label10.width                   = 120
$Label10.height                  = 20
$Label10.location                = New-Object System.Drawing.Point(74,446)
$Label10.Font                    = 'Microsoft Sans Serif,10'

$Label11                         = New-Object system.Windows.Forms.Label
$Label11.text                    = "Ticket Number"
$Label11.AutoSize                = $true
$Label11.width                   = 120
$Label11.height                  = 20
$Label11.location                = New-Object System.Drawing.Point(81,534)
$Label11.Font                    = 'Microsoft Sans Serif,10'

#Create User Button
$Button_GO                       = New-Object system.Windows.Forms.Button
$Button_GO.text                  = "Create User"
$Button_GO.width                 = 100
$Button_GO.height                = 40
$Button_GO.location              = New-Object System.Drawing.Point(100,587)
$Button_GO.Font                  = 'Microsoft Sans Serif,10'

#Retry Email Button
$Button_Cancel                       = New-Object system.Windows.Forms.Button
$Button_Cancel.text                  = "Cancel"
$Button_Cancel.width                 = 100
$Button_Cancel.height                = 40
$Button_Cancel.location              = New-Object System.Drawing.Point(260,587)
$Button_Cancel.Font                  = 'Microsoft Sans Serif,10'

$Label_Status                    = New-Object system.Windows.Forms.Label
$Label_Status.text               = "Status"
$Label_Status.AutoSize           = $true
$Label_Status.MaximumSize        = New-Object System.Drawing.Size(375,0)
$Label_Status.location           = New-Object System.Drawing.Point(50,665)
$Label_Status.Font               = 'Microsoft Sans Serif,10'

<#Used only if we are setting the Expiration Dates for non-employee types
#Set Expiration Date Button
$Button_SetExpDateto90           = New-Object system.Windows.Forms.Button
$Button_SetExpDateto90.text      = "Set Exp Date"
$Button_SetExpDateto90.width     = 80
$Button_SetExpDateto90.height    = 40
$Button_SetExpDateto90.location  = New-Object System.Drawing.Point(300,587)
$Button_SetExpDateto90.Font      = 'Microsoft Sans Serif,10'

$Label_ExpirationDate            = New-Object system.Windows.Forms.Label
$Label_ExpirationDate.text       = "Contingent Worker Exp Date"
$Label_ExpirationDate.AutoSize   = $true
$Label_ExpirationDate.width      = 25
$Label_ExpirationDate.height     = 10
$Label_ExpirationDate.location   = New-Object System.Drawing.Point(4,497)
$Label_ExpirationDate.Font       = 'Microsoft Sans Serif,10'

#Expiration Date Time Picker
$Cal_DateTimePicker              = New-Object System.Windows.Forms.DateTimePicker
$Cal_DateTimePicker.width        = 220
$Cal_DateTimePicker.location     = New-Object System.Drawing.Point(190,495)
$Cal_DateTimePicker.Font         = 'Microsoft Sans Serif,10'
$Cal_DateTimePicker.Value        = '1988-07-27'
#>


#
#Build Form
#
$Form.controls.AddRange(@($TextBox_Domain, $TextBox_FirstName,$TextBox_LastName,$TextBox_UserName,$TextBox_Desc,$TextBox_JobTitle,$TextBox_Manager,$ComboBox_Office,$ComboBox_Dept,$TextBox_EmpID,$groupBox_EmpVsCont,$TextBox_TicketNum,$Label1,$Label2,$Label3,$Label4,$LabelDesc,$Label5,$Label6,$Label7,$Label8,$Label9,$Label10,$Label11,$Button_GO,$Label_Status, $Button_Cancel))

########################################
#####Logic for New User Creation.#######
########################################

#Button Click
$Button_GO.Add_Click({createUserButtonClick})
$Button_Cancel.Add_Click({$Form.Close()})
#$Button_SetExpDateto90.Add_Click({90daybuttonclick})

function createUserButtonClick 
{        
    #Set Status Label
    $Label_Status.text = "Creating User" 

    ##########################
    #Load Variables from Form#
    ##########################
    $FirstName = $textbox_FirstName.text
    $LastName = $TextBox_LastName.text
    $FullName = $LastName + ", " + $firstname
    $Username = $TextBox_UserName.text
    $domain = "@aprenergy.com"
    $title = $TextBox_JobTitle.text
    $UserDescription = $TextBox_Desc.text
    $smtpAddress = $FirstName + "." + $LastName + $Domain
    $Manager = $TextBox_Manager.text
    $Department = $ComboBox_Dept.selecteditem
    $Office = $ComboBox_Office.selecteditem
    $Company = "APR Energy"
    $EmployeeID = $TextBox_EmpID.text    
    #Radio Button Employee VS Contingent    
    if($RadioButton_Type_Employee.checked -eq $True)
    {
        $EmpVSContingent = "APR Employee"
    }
    Elseif($RadioButton_Type_IC.checked -eq $true)
    {
        $EmpVSContingent = "Independent Contractor"
    }
    Elseif($RadioButton_Type_3PC.checked -eq $true)
    {
        $EmpVSContingent = "3rd Party Contractor"
    }

    $TicketNumber = $TextBox_TicketNum.text
    $UserCreator = $env:USERNAME
    #$date = get-date
    #$90FromToday = (Get-Date).adddays(90)
    $Path
    $LogonScript
    $Groups = New-Object System.Collections.Generic.List[System.Object]
    $TempPW = ConvertTo-SecureString "Mist3mp!2345678" -AsPlainText -Force
    $result = New-Object System.Collections.Generic.List[System.Object]
    $server = "aprjaxdc02.aprenergy.local"

    ###############
    ####Tests######
    ###############
    #Check to see if username already in use
    try 
    {
        Get-ADUser -Identity $Username
        $UserExistsCheck = $true
    }
    catch [Microsoft.ActiveDirectory.Management.ADIdentityResolutionException] 
    {    
        $UserExistsCheck = $false
    }

    #Check to see if Manager Exists
    try 
    {
        Get-ADUser -Identity $Manager
        $ManagerExistsCheck = $true
    }
    catch [Microsoft.ActiveDirectory.Management.ADIdentityResolutionException] 
    {    
        $ManagerExistsCheck = $false
    }

    #####################
    ##Data Verification##
    #####################
    if ($UserExistsCheck)
    {
        $Label_Status.text = "Username is already in use. Please change and try again."
    }
    Elseif(!$ManagerExistsCheck)
    {
        $Label_Status.text = "Manager account doesn't exist and is required. Please check manager field and try again."
    }
    #Elseif(($date -gt $Cal_DateTimePicker.Value) -and ($EmpVSContingent -eq 'Contingent'))
    #{
    #    $Label_Status.text = "The Expiration date on this contingent user cannot be in the past. Please update the date."
    #}
    #Elseif(($Cal_DateTimePicker.Value -gt $90FromToday) -and ($EmpVSContingent -eq 'Contingent'))
    #{
    #    $Label_Status.text = "The expiration date on this contingent user cannot exceed 90 days. Please update the expiration date."
    #}
    #################################
    ########The Magic################
    #################################
    Else
    {   
        ###################################################################################################
        #This Section updates user infomration based on Office location. It adds groups and sets the Path.#
        ###################################################################################################

        Switch ($Office)
        {
        $off_Jacksonville
            {
                $Path = 'OU=Jax Employees,OU=APR,DC=aprenergy,DC=local'
            }
        $off_Virtual
            {
                $Path = 'OU=Misc Users and Groups,OU=APR,DC=aprenergy,DC=local'
            }
        }

        ######################################################################################
        #This Section assigns attributes based on domain.  Adds groups.#
        ######################################################################################
        Switch ($domain)
        {
            "@aprenergy.com"
                {                    
                    $Groups.Add('APR Energy VPN')
                }
        }

        #############
        #Create User#
        #############
        New-aduser -name $FullName -GivenName $FirstName -surname $LastName -DisplayName $FullName -Description $UserDescription -EmailAddress $smtpAddress -Manager $Manager -path $path -samaccountname $username -UserPrincipalname $smtpAddress -accountPassword $TempPW -enabled $True -title $Title -Office $Office -Company $Company -Department $Department -scriptPath $LogonScript -EmployeeID $EmployeeID -OtherAttributes @{employeeType=$EmpVSContingent;proxyAddresses="SMTP:" + $smtpAddress} -Server $server
    
        Start-Sleep -Seconds 10

        #if($EmpVSContingent -eq "Contingent")
        #{
        #    Set-ADAccountExpiration $username -DateTime $Cal_DateTimePicker.Value.Date -Server $server
        #}
    
        #Documents User Creation in info attribute
        Set-ADUser $Username -Replace @{Info= 'Date: ' + $date +' Account Created by: ' + $UserCreator +' Ticket Number: ' + $TicketNumber} -Server $server
        
        #
        #Adds Groups
        #
        Foreach($group in $groups)
        {
            Add-ADGroupMember -Identity $group $Username -Server $server
        }
    
        ###################################
        #Verify Accounts Exist#############
        ###################################
        $FinalUserExistsCheck = [bool] (get-aduser -Filter{ Samaccountname -eq $username})

        if(!$FinalUserExistsCheck)
        {
            $Label_Status.text = "Failed to create account in AD.  Try again"
        }
        Else
        {
            $Label_Status.text = "Account created successfully."
        }

        #Write to Log
        $out = New-Object psobject
        $out | Add-Member -MemberType NoteProperty -Name "CreatedBy" -Value $UserCreator
        $out | Add-Member -MemberType NoteProperty -Name "Username" -Value $Username
        $out | Add-Member -MemberType NoteProperty -Name "Date" -Value $date
        $out | Add-Member -MemberType NoteProperty -Name "TicketNumber" -Value $TicketNumber    
        $out | Add-Member -MemberType NoteProperty -Name "Domain" -Value $Domain
        $out | Add-Member -MemberType NoteProperty -Name "Manager" -Value $Manager
        $out | Add-Member -MemberType NoteProperty -Name "Company" -Value $Company
        $out | Add-Member -MemberType NoteProperty -Name "Office" -Value $Office
        $out | Add-Member -MemberType NoteProperty -Name "EmpVSContingent" -Value $EmpVSContingent
        $out | Add-Member -MemberType NoteProperty -Name "EmployeeID" -Value $EmployeeID
        $result.Add($out)

        $result | Export-Csv -Path "C:\AUTOMATION_SCRIPTS\UserOnboarding\OnboardingLog.csv" -NoTypeInformation -Append
    }

    
}

#Set date 90 days out
#function 90daybuttonclick 
#{        
#    $90FromToday = (Get-Date).adddays(90)
#    $Cal_DateTimePicker.Value = $90FromToday
#}


[void]$Form.ShowDialog()