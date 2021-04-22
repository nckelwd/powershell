﻿###Variables for Form
$terminateScript = $false

###test folder paths on PC, create if none exist
$savePath = "C:\Users\$env:username\desktop\MoversSuiteBranches"
If(!(test-path $savePath))
{md "$savePath"}

$orig_File = "C:\Users\$env:username\desktop\MoversSuite - Add a Managed SCAC Branch to MoversSuite.sql"
$source_file = "$savePath\Add-MIL-Branch.sql"

$insertSecProf = "C:\Users\$env:username\desktop\MoversSuite - Insert Branch into SecProfileDetail with copied access.sql"
$sourceInsertSecProf = "$savePath\Add-SecProf.sql"

$insertBranchList = "C:\Users\$env:username\desktop\MoversSuite - Add Branch to Personnel Records with specified default Branch.sql"
$sourceInsertBranchList = "$savePath\Add-BranchList.sql"


###Function - Add MIL Branch to MoversSuite
Function AddBranch-MIL {
Copy-Item $orig_file -Destination $source_file

$source_file

$SQLVarAgentNum = '9979'
$SQLVarAgentName = 'FULL AGENT NAME'
$SQLVarSCAC = 'XYZX'
$SQLVarBrGL = '8878'
$SQLVarCmGL = '2117'


(Get-Content $source_file) | ForEach-Object { $_ -replace $SQLVarAgentNum,$AgentNum} | Set-Content $source_file
(Get-Content $source_file) | ForEach-Object { $_ -replace $SQLVarAgentName,$AgentName} | Set-Content $source_file
(Get-Content $source_file) | ForEach-Object { $_ -replace $SQLVarSCAC,$SCAC} | Set-Content $source_file
(Get-Content $source_file) | ForEach-Object { $_ -replace $SQLVarBrGL,$BranchGL} | Set-Content $source_file
(Get-Content $source_file) | ForEach-Object { $_ -replace $SQLVarCmGL,$CompanyGL} | Set-Content $source_file
}


###Function - Run the SQL Script
<#
$date=(get-date -Format d) -replace("/")
$time=(get-date -Format t) -replace(":")
$source_file
$new_file = "$date"+"_"+"$time"+"_"+"MILBranch-[$env:Computername].txt"

Invoke-Sqlcmd -InputFile $source_file -ServerInstance "" -AbortOnError | Out-File -FilePath $new_file"

RUN IT!!!!!!!!!!!!!!!!!
#>


###Function - Rename file
Function FileRenameBranch {

$date=(get-date -Format d) -replace("/")
$time=(get-date -Format t) -replace(":")

$source_file

$final_branch_file = $SCAC+"_"+"MIL"+"_"+$AgentNum+"_"+"$date"+"_"+"$time"+"-[$env:Computername].sql"

Rename-Item $source_file -NewName $final_branch_file
}


###Function - Add MIL Branch to Security Profiles
Function AddSecProf-MIL {
Copy-Item $insertSecProf -Destination $sourceInsertSecProf

$sourceInsertSecProf

$SQLVarAgentNum = '9979'

(Get-Content $sourceInsertSecProf) | ForEach-Object { $_ -replace $SQLVarAgentNum,$AgentNum} | Set-Content $sourceInsertSecProf
}

###Function - Rename file
Function FileRenameSecProf {

$sourceInsertSecProf

$final_secprof_file = $SCAC+"_"+"MIL"+"_"+$AgentNum+"_"+"SecurityProfile"+"-[$env:Computername].sql"

Rename-Item $sourceInsertSecProf -NewName $final_secprof_file
}

###Function - Add MIL Branch to Branch list
Function AddBranchList-MIL {
Copy-Item $insertBranchList -Destination $sourceInsertBranchList

$sourceInsertBranchList

$SQLVarAgentNum = '9979'

(Get-Content $sourceInsertBranchList) | ForEach-Object { $_ -replace $SQLVarAgentNum,$AgentNum} | Set-Content $sourceInsertBranchList
}

###Function - Rename file
Function FileRenameBranchList {

$sourceInsertBranchList

$final_branchlist_file = $SCAC+"_"+"MIL"+"_"+$AgentNum+"_"+"AddToBranchList"+"-[$env:Computername].sql"

Rename-Item $sourceInsertBranchList -NewName $final_branchlist_file
}

<#
###Form - Check to see if Branch/Agent exists
#>


###Form - Add Branch
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

$Form                            = New-Object system.Windows.Forms.Form
$Form.ClientSize                 = '450,500'
$Form.text                       = "MoversSuite - Add MIL Branch"
$Form.TopMost                    = $false
$form.StartPosition              = [System.Windows.Forms.FormStartPosition]::CenterScreen;

$AgencyNumber                    = New-Object system.Windows.Forms.Label
$AgencyNumber.text               = "Agency #"
$AgencyNumber.AutoSize           = $true
$AgencyNumber.width              = 175
$AgencyNumber.height             = 20
$AgencyNumber.location           = New-Object System.Drawing.Point(82,91)
$AgencyNumber.Font               = 'Microsoft Sans Serif,10'

$AgencyName                      = New-Object system.Windows.Forms.Label
$AgencyName.text                 = "Name"
$AgencyName.AutoSize             = $true
$AgencyName.width                = 175
$AgencyName.height               = 20
$AgencyName.location             = New-Object System.Drawing.Point(82,152)
$AgencyName.Font                 = 'Microsoft Sans Serif,10'

$SCACCode                        = New-Object system.Windows.Forms.Label
$SCACCode.text                   = "SCAC"
$SCACCode.AutoSize               = $true
$SCACCode.width                  = 175
$SCACCode.height                 = 20
$SCACCode.location               = New-Object System.Drawing.Point(82,212)
$SCACCode.Font                   = 'Microsoft Sans Serif,10'

$BranchGLCode                    = New-Object system.Windows.Forms.Label
$BranchGLCode.text               = "Branch GL"
$BranchGLCode.AutoSize           = $true
$BranchGLCode.width              = 175
$BranchGLCode.height             = 20
$BranchGLCode.location           = New-Object System.Drawing.Point(82,266)
$BranchGLCode.Font               = 'Microsoft Sans Serif,10'

$CompanyGLCode                   = New-Object system.Windows.Forms.Label
$CompanyGLCode.text              = "Company GL"
$CompanyGLCode.AutoSize          = $true
$CompanyGLCode.width             = 175
$CompanyGLCode.height            = 20
$CompanyGLCode.location          = New-Object System.Drawing.Point(82,320)
$CompanyGLCode.Font              = 'Microsoft Sans Serif,10'

$AgencyNumberBox                 = New-Object system.Windows.Forms.TextBox
$AgencyNumberBox.multiline       = $false
$AgencyNumberBox.width           = 175
$AgencyNumberBox.height          = 20
$AgencyNumberBox.location        = New-Object System.Drawing.Point(170,86)
$AgencyNumberBox.Font            = 'Microsoft Sans Serif,10'

$AgentNameBox                    = New-Object system.Windows.Forms.TextBox
$AgentNameBox.multiline          = $false
$AgentNameBox.width              = 175
$AgentNameBox.height             = 20
$AgentNameBox.location           = New-Object System.Drawing.Point(170,147)
$AgentNameBox.Font               = 'Microsoft Sans Serif,10'

$SCACCodeBox                     = New-Object system.Windows.Forms.TextBox
$SCACCodeBox.multiline           = $false
$SCACCodeBox.width               = 175
$SCACCodeBox.height              = 20
$SCACCodeBox.location            = New-Object System.Drawing.Point(170,207)
$SCACCodeBox.Font                = 'Microsoft Sans Serif,10'

$BranchGLCodeBox                 = New-Object system.Windows.Forms.TextBox
$BranchGLCodeBox.multiline       = $false
$BranchGLCodeBox.width           = 175
$BranchGLCodeBox.height          = 20
$BranchGLCodeBox.location        = New-Object System.Drawing.Point(170,261)
$BranchGLCodeBox.Font            = 'Microsoft Sans Serif,10'

$CompanyGLCodeBox                = New-Object system.Windows.Forms.TextBox
$CompanyGLCodeBox.multiline      = $false
$CompanyGLCodeBox.width          = 175
$CompanyGLCodeBox.height         = 20
$CompanyGLCodeBox.location       = New-Object System.Drawing.Point(170,315)
$CompanyGLCodeBox.Font           = 'Microsoft Sans Serif,10'

$ButtonOK                        = New-Object system.Windows.Forms.Button
$ButtonOK.text                   = "Add"
$ButtonOK.width                  = 60
$ButtonOK.height                 = 30
$ButtonOK.location               = New-Object System.Drawing.Point(79,390)
$ButtonOK.Font                   = 'Microsoft Sans Serif,10'
$ButtonOK.DialogResult           = [System.Windows.Forms.DialogResult]::Ok
$form.AcceptButton               = $ButtonOK


$ButtonCANCEL                    = New-Object system.Windows.Forms.Button
$ButtonCANCEL.text               = "Cancel"
$ButtonCANCEL.width              = 60
$ButtonCANCEL.height             = 30
$ButtonCANCEL.location           = New-Object System.Drawing.Point(307,390)
$ButtonCANCEL.Font               = 'Microsoft Sans Serif,10'
$ButtonCANCEL.DialogResult       = [System.Windows.Forms.DialogResult]::Cancel
$form.CancelButton               = $ButtonCANCEL

$Form.controls.AddRange(@($AgencyNumberBox,$AgencyNumber,$AgencyName,$SCACCode,$BranchGLCode,$CompanyGLCode,$AgentNameBox,$SCACCodeBox,$BranchGLCodeBox,$CompanyGLCodeBox,$ButtonOK,$ButtonCANCEL))

$ButtonOK.Add_Click({$AgentNum = $AgencyNumberBox.Text
                    $AgentName = $AgentNameBox.Text
                    $SCAC = $SCACCodeBox.Text
                    $BranchGL = $BranchGLCodeBox.Text
                    $CompanyGL = $CompanyGLCodeBox.Text
                    AddBranch-MIL
                    FileRenameBranch
                    AddSecProf-MIL
                    FileRenameSecProf
                    AddBranchList-MIL
                    FileRenameBranchList
                    })
$ButtonCANCEL.Add_Click({$terminateScript = $true 
                    $Form.Close()
                    return $terminateScript
                    })

$Form.ShowDialog()