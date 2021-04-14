###Variables for Form
$terminateScript = $false

###test folder paths on PC, create if none exist
$savePath = "C:\Users\$env:username\desktop\MoversSuiteBranches"
If(!(test-path $savePath))
{md "$savePath"}

$orig_File = "C:\Users\$env:username\desktop\MoversSuite - Add a Managed SCAC Branch to MoversSuite.sql"
$source_file = "$savePath\Add-MIL-Branch.sql"

###Function - Add MIL Branch to MoversSuite
Function AddBranch-MIL {
Copy-Item $orig_file -Destination "$savePath\Add-MIL-Branch.sql"

$source_file

$SQLVarAgentNum = '9979'
$SQLVarAgentName = 'FULL AGENT NAME'
$SQLVarSCAC = 'XYZX'
$SQLVarBrGL = '8878'


(Get-Content $source_file) | ForEach-Object { $_ -replace $SQLVarAgentNum,$AgentNum} | Set-Content $source_file
(Get-Content $source_file) | ForEach-Object { $_ -replace $SQLVarAgentName,$AgentName} | Set-Content $source_file
(Get-Content $source_file) | ForEach-Object { $_ -replace $SQLVarSCAC,$SCAC} | Set-Content $source_file
(Get-Content $source_file) | ForEach-Object { $_ -replace $SQLVarBrGL,$BranchGL} | Set-Content $source_file
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
Function FileRename {

$date=(get-date -Format d) -replace("/")
$time=(get-date -Format t) -replace(":")

$source_file

$new_file = $SCAC+"_"+"MIL"+"_"+$AgentNum+"_"+"$date"+"_"+"$time"+"-[$env:Computername].sql"

Rename-Item $source_file -NewName $new_file
}

<#
###Form - Check to see if Branch/Agent exists
#>


###Form - Add Branch
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

$Form                            = New-Object system.Windows.Forms.Form
$Form.ClientSize                 = '400,400'
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

$AgencyNumberBox                 = New-Object system.Windows.Forms.TextBox
$AgencyNumberBox.multiline       = $false
$AgencyNumberBox.width           = 175
$AgencyNumberBox.height          = 20
$AgencyNumberBox.location        = New-Object System.Drawing.Point(159,86)
$AgencyNumberBox.Font            = 'Microsoft Sans Serif,10'

$AgentNameBox                    = New-Object system.Windows.Forms.TextBox
$AgentNameBox.multiline          = $false
$AgentNameBox.width              = 175
$AgentNameBox.height             = 20
$AgentNameBox.location           = New-Object System.Drawing.Point(159,147)
$AgentNameBox.Font               = 'Microsoft Sans Serif,10'

$SCACCodeBox                     = New-Object system.Windows.Forms.TextBox
$SCACCodeBox.multiline           = $false
$SCACCodeBox.width               = 175
$SCACCodeBox.height              = 20
$SCACCodeBox.location            = New-Object System.Drawing.Point(159,207)
$SCACCodeBox.Font                = 'Microsoft Sans Serif,10'

$BranchGLCodeBox                 = New-Object system.Windows.Forms.TextBox
$BranchGLCodeBox.multiline       = $false
$BranchGLCodeBox.width           = 175
$BranchGLCodeBox.height          = 20
$BranchGLCodeBox.location        = New-Object System.Drawing.Point(159,261)
$BranchGLCodeBox.Font            = 'Microsoft Sans Serif,10'

$ButtonOK                        = New-Object system.Windows.Forms.Button
$ButtonOK.text                   = "Add"
$ButtonOK.width                  = 60
$ButtonOK.height                 = 30
$ButtonOK.location               = New-Object System.Drawing.Point(79,315)
$ButtonOK.Font                   = 'Microsoft Sans Serif,10'
$ButtonOK.DialogResult           = [System.Windows.Forms.DialogResult]::Ok
$form.AcceptButton               = $ButtonOK


$ButtonCANCEL                    = New-Object system.Windows.Forms.Button
$ButtonCANCEL.text               = "Cancel"
$ButtonCANCEL.width              = 60
$ButtonCANCEL.height             = 30
$ButtonCANCEL.location           = New-Object System.Drawing.Point(247,315)
$ButtonCANCEL.Font               = 'Microsoft Sans Serif,10'
$ButtonCANCEL.DialogResult       = [System.Windows.Forms.DialogResult]::Cancel
$form.CancelButton               = $ButtonCANCEL

$Form.controls.AddRange(@($AgencyNumberBox,$AgencyNumber,$AgencyName,$SCACCode,$BranchGLCode,$AgentNameBox,$SCACCodeBox,$BranchGLCodeBox,$ButtonOK,$ButtonCANCEL))

$ButtonOK.Add_Click({$AgentNum = $AgencyNumberBox.Text
                    $AgentName = $AgentNameBox.Text
                    $SCAC = $SCACCodeBox.Text
                    $BranchGL = $BranchGLCodeBox.Text
                    AddBranch-MIL
                    FileRename
                    })
$ButtonCANCEL.Add_Click({$terminateScript = $true 
                    $Form.Close()
                    return $terminateScript
                    })

$Form.ShowDialog()