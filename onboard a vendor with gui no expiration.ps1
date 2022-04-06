

###################
##Load Variables###
###################

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName PresentationCore,PresentationFramework
[System.Windows.Forms.Application]::EnableVisualStyles()

$server = "aprjaxdc02.aprenergy.local"

$comp_Array = @(
    "GSI"
    )

########################
#Start of building Form#
########################
$Form                            = New-Object system.Windows.Forms.Form
$Form.ClientSize                 = '500,650'
$Form.text                       = "Create a Vendor account"
$Form.TopMost                    = $false
$Form.AutoScroll                 = $True
$Form.BackColor                  = "white"
$Form.StartPosition              = "CenterScreen"

##################################################################################################################
#Form Controls
##################################################################################################################

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
$TextBox_UserName                = New-Object system.Windows.Forms.Textbox
$TextBox_UserName.text           = ""
$TextBox_UserName.multiline      = $false
$TextBox_UserName.width          = 200
$TextBox_UserName.height         = 20
$TextBox_UserName.location       = New-Object System.Drawing.Point(190,270) #190,114
$TextBox_UserName.Font           = 'Microsoft Sans Serif,10'



#Company
$ComboBox_Company                 = New-Object system.Windows.Forms.ComboBox
$ComboBox_Company.text            = ""
$ComboBox_Company.width           = 200
$ComboBox_Company.height          = 20
$ComboBox_Company.location        = New-Object System.Drawing.Point(190,152)
$ComboBox_Company.Font            = 'Microsoft Sans Serif,10'
foreach ($comp in $comp_Array) {
    $ComboBox_Company.Items.add($comp)
}

#Description
$TextBox_Desc                 = New-Object system.Windows.Forms.TextBox
$TextBox_Desc.multiline       = $false
$TextBox_Desc.width           = 200
$TextBox_Desc.height          = 20
$TextBox_Desc.location        = New-Object System.Drawing.Point(190,192)
$TextBox_Desc.Font            = 'Microsoft Sans Serif,10'


#Manager
$TextBox_Manager                 = New-Object system.Windows.Forms.TextBox
$TextBox_Manager.multiline       = $false
$TextBox_Manager.width           = 200
$TextBox_Manager.height          = 20
$TextBox_Manager.location        = New-Object System.Drawing.Point(190,231)
$TextBox_Manager.Font            = 'Microsoft Sans Serif,10'

#Email Address
$TextBox_VEmail                 = New-Object system.Windows.Forms.TextBox
$TextBox_VEmail.multiline       = $false
$TextBox_VEmail.width           = 200
$TextBox_VEmail.height          = 20
$TextBox_VEmail.location        = New-Object System.Drawing.Point(190,114) #190,270
$TextBox_VEmail.Font            = 'Microsoft Sans Serif,10'

$TextBox_VEmail.Add_Validating({
    $TextBox_UserName.text = $TextBox_VEmail.text.Substring(0, $TextBox_VEmail.text.IndexOf('@'))
})

#Vendor
$TextBox_Type_Vendor             = New-Object system.Windows.Forms.label
$TextBox_Type_Vendor.text        = "Vendor"
$TextBox_Type_Vendor.AutoSize    = $true
$TextBox_Type_Vendor.width       = 200
$TextBox_Type_Vendor.height      = 20
$TextBox_Type_Vendor.location    = New-Object System.Drawing.Point(190,348)
$TextBox_Type_Vendor.Font        = 'Microsoft Sans Serif,10'

#Ticket Number
$TextBox_TicketNum               = New-Object system.Windows.Forms.TextBox
$TextBox_TicketNum.multiline     = $false
$TextBox_TicketNum.width         = 200
$TextBox_TicketNum.height        = 20
$TextBox_TicketNum.location      = New-Object System.Drawing.Point(190,426)
$TextBox_TicketNum.Font          = 'Microsoft Sans Serif,10'

##################################################################################################################
#Labels
##################################################################################################################

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
$Label2.location                 = New-Object System.Drawing.Point(95,77)
$Label2.Font                     = 'Microsoft Sans Serif,10'

$Label3                          = New-Object system.Windows.Forms.Label
$Label3.text                     = "User Name"
$Label3.AutoSize                 = $true
$Label3.width                    = 117
$Label3.height                   = 20
$Label3.Anchor                   = 'top,right,left'
$Label3.location                 = New-Object System.Drawing.Point(94,272) #94,116
$Label3.Font                     = 'Microsoft Sans Serif,10'

$LabelComp                          = New-Object system.Windows.Forms.Label
$LabelComp.text                     = "Company"
$LabelComp.AutoSize                 = $true
$LabelComp.width                    = 120
$LabelComp.height                   = 20
$LabelComp.location                 = New-Object System.Drawing.Point(100,155)
$LabelComp.Font                     = 'Microsoft Sans Serif,10'

$LabelDesc                          = New-Object system.Windows.Forms.Label
$LabelDesc.text                     = "Description"
$LabelDesc.AutoSize                 = $true
$LabelDesc.width                    = 120
$LabelDesc.height                   = 20
$LabelDesc.location                 = New-Object System.Drawing.Point(92,194)
$LabelDesc.Font                     = 'Microsoft Sans Serif,10'

$Label5                          = New-Object system.Windows.Forms.Label
$Label5.text                     = "APR Sponsor Username"
$Label5.AutoSize                 = $true
$Label5.width                    = 120
$Label5.height                   = 20
$Label5.location                 = New-Object System.Drawing.Point(18,233)
$Label5.Font                     = 'Microsoft Sans Serif,10'

$Label6                          = New-Object system.Windows.Forms.Label
$Label6.text                     = "Vendor Email Address"
$Label6.AutoSize                 = $true
$Label6.width                    = 120
$Label6.height                   = 20
$Label6.location                 = New-Object System.Drawing.Point(30,116) #30,272
$Label6.Font                     = 'Microsoft Sans Serif,10'

$Label10                         = New-Object system.Windows.Forms.Label
$Label10.text                    = "Employee Type"
$Label10.AutoSize                = $true
$Label10.width                   = 120
$Label10.height                  = 20
$Label10.location                = New-Object System.Drawing.Point(74,350)
$Label10.Font                    = 'Microsoft Sans Serif,10'

$Label11                         = New-Object system.Windows.Forms.Label
$Label11.text                    = "Ticket Number"
$Label11.AutoSize                = $true
$Label11.width                   = 120
$Label11.height                  = 20
$Label11.location                = New-Object System.Drawing.Point(81,428)
$Label11.Font                    = 'Microsoft Sans Serif,10'

##################################################################################################################
#Buttons
##################################################################################################################

#Create User Button
$Button_GO                       = New-Object system.Windows.Forms.Button
$Button_GO.text                  = "Create User"
$Button_GO.width                 = 100
$Button_GO.height                = 40
$Button_GO.location              = New-Object System.Drawing.Point(100,470)
$Button_GO.Font                  = 'Microsoft Sans Serif,10'

#Cancel Button
$Button_Cancel                       = New-Object system.Windows.Forms.Button
$Button_Cancel.text                  = "Cancel"
$Button_Cancel.width                 = 100
$Button_Cancel.height                = 40
$Button_Cancel.location              = New-Object System.Drawing.Point(300,470)
$Button_Cancel.Font                  = 'Microsoft Sans Serif,10'

$Label_Status                    = New-Object system.Windows.Forms.Label
$Label_Status.text               = "Status"
$Label_Status.AutoSize           = $true
$Label_Status.MaximumSize        = New-Object System.Drawing.Size(375,0)
$Label_Status.location           = New-Object System.Drawing.Point(50,530)
$Label_Status.Font               = 'Microsoft Sans Serif,10'



##################################################################################################################
#Build Form
##################################################################################################################

$Form.controls.AddRange(@($TextBox_FirstName,$TextBox_LastName,$TextBox_VEmail,$ComboBox_Company,$TextBox_Desc,$TextBox_Manager,$TextBox_UserName,$TextBox_EmpID,$TextBox_Type_Vendor,$TextBox_TicketNum,$Label1,$Label2,$Label3,$LabelComp,$LabelDesc,$Label5,$Label6,$Label9,$Label10,$Label11,$Button_GO,$Label_Status,$Button_Cancel))

########################################
#####Logic for New User Creation.#######
########################################

#Button Click
$Button_GO.Add_Click({createUserButtonClick})
$Button_Cancel.Add_Click({$Form.Close()})

function createUserButtonClick 
{    

    #Set Status Label
    $Label_Status.text = "Validation Steps"     
    

    ###############
    ####Tests######
    ###############
    #Check to see if username already in use
    try 
    {
        Get-ADUser -Identity $TextBox_UserName.text -Server $server
        $UserExistsCheck = $true
    }
    catch [Microsoft.ActiveDirectory.Management.ADIdentityResolutionException] 
    {    
        $UserExistsCheck = $false
    }

    #Check to see if Manager Exists
    try 
    {
        Get-ADUser -Identity $TextBox_Manager.text -Server $server
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
    Elseif($TextBox_UserName.text.Length -gt 20)
    {
        $Label_Status.text = "Username must be 20 char or less. Change username and try again."
    }
    Else{ theMagic }    
}

function theMagic {
    $Label_Status.text = "Creating User"

    ##########################
    #Load Variables from Form#
    ##########################
    $FirstName = $textbox_FirstName.text
    $LastName = $TextBox_LastName.text
    $FullName = $firstname + " " +$LastName
    $Username = $TextBox_UserName.text
    $UserDescription = $TextBox_Desc.text
    $VEmailAddress = $TextBox_VEmail.text
    $userPrinName = $TextBox_UserName.text + "@aprenergy.local"
    $Manager = $TextBox_Manager.text
    $Company = $ComboBox_Company.selecteditem   
    $EmpType = "Vendor"
    $TicketNumber = $TextBox_TicketNum.text
    $UserCreator = $env:USERNAME
    $date = get-date
    $Path    
    $TempPW = ConvertTo-SecureString "Welcome1!" -AsPlainText -Force
    $result = New-Object System.Collections.Generic.List[System.Object]
    
    ###################################################################################################
    #This Section updates user infomration based on Office location. It adds groups and sets the Path.#
    ###################################################################################################

    

    ######################################################################################
    #This Section assigns attributes based on domain.  Adds groups.#
    ######################################################################################
    Switch ($Company)
    #GSI
    {
    "GSI"
        {
            $Path = 'OU=GSI,OU=Synced,OU=Users,OU=GLobal,OU=APR,DC=aprenergy,DC=local'
        }
    default
        {
            $Path = 'OU=GSI,OU=Synced,OU=Users,OU=GLobal,OU=APR,DC=aprenergy,DC=local'
        }
    }
    #############
    #Create User#
    #############
    New-aduser -name $FullName -GivenName $FirstName -surname $LastName -DisplayName $FullName -Description $UserDescription -EmailAddress $VEmailAddress -Manager $Manager -path $path -samaccountname $username -UserPrincipalname $userPrinName -accountPassword $TempPW -enabled $True -title $UserDescription -Company $Company -Department $Department -OtherAttributes @{employeeType=$EmpType;"msDS-CloudExtensionAttribute2"="HideFromGAL"} -Server $server

    Start-Sleep -Seconds 10

    #Documents User Creation in info attribute
    Set-ADUser $Username -Replace @{Info= 'Date: ' + $date +' Account Created by: ' + $UserCreator +' Ticket Number: ' + $TicketNumber} -Server $server
   

    ###################################
    #Verify Accounts Exist#############
    ###################################
    $FinalUserExistsCheck = [bool] (get-aduser -Filter{ Samaccountname -eq $username} -server $server)

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
    $out | Add-Member -MemberType NoteProperty -Name "Manager" -Value $Manager
    $out | Add-Member -MemberType NoteProperty -Name "Company" -Value $Company
    $out | Add-Member -MemberType NoteProperty -Name "EmpType" -Value $EmpType
    $result.Add($out)

    $result | Export-Csv -Path "C:\Scripts\Logs\Onboarding\VendorOnboardingLog.csv" -NoTypeInformation -Append

}


[void]$Form.ShowDialog()