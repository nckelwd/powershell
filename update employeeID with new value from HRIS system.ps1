
Add-Type -AssemblyName System.Windows.Forms
$FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ InitialDirectory = [Environment]::GetFolderPath('Desktop') }
$null = $FileBrowser.ShowDialog()
$importedUsers = Import-Csv -Path $FileBrowser.FileName
$importedUsers.Count

$properties = "SamAccountName", "Description", "EmployeeID", "mail", "sn", "GivenName", "DisplayName", "Title", "Manager", "Department", "Division", "EmployeeType", "physicalDeliveryOfficeName", "msDS-cloudExtensionAttribute1"
$filter = "(Enabled -eq 'true')"
$adUsers = Get-ADUser -Filter $filter -Properties $properties |  select $properties
$adUsers.Count

$export_All = @()
$export_Changes = @()
$export_noMatch = @()

$creds = Get-Credential -Message "Enter on premis Admin Credentials"

$count=0
foreach ($iu in $importedUsers) {
    #Match imported User with AD
    $tmpADuser = $adUsers | where {($_.mail) -eq ($iu.'EMAIL ADDRESS')}

    
    #if a match is found
    if($tmpADuser){

        $eeid_Change = 0

        #Check for Changes
        if($tmpADuser.employeeID -ne $iu.NewEmployeeID){
            $title_Change = 1
        }

        $change_count -gt 0


        #Full list of users export
        $obj = new-object PSObject 
        $obj | add-member -MemberType NoteProperty -name SamAccountName -value $tmpADuser.SamAccountName
        $obj | add-member -MemberType NoteProperty -name EmailAddress -value $tmpADuser.mail    
        $obj | add-member -MemberType NoteProperty -name Current_EmployeeID -value $tmpADuser.employeeid        
        $obj | add-member -MemberType NoteProperty -name New_EmployeeID -value $iu.NewEmployeeID        


        $export_All += $obj
        

        if($change_count -gt 0){
            $obj_Change = new-object PSObject 
            $obj_Change | add-member -MemberType NoteProperty -name SamAccountName -value $tmpADuser.SamAccountName     
            $obj_Change | add-member -MemberType NoteProperty -name EmailAddress -value $tmpADuser.mail      
            $obj_Change | add-member -MemberType NoteProperty -name EmployeeID -value $tmpADuser.employeeid        
            $obj_Change | add-member -MemberType NoteProperty -name New_EmployeeID -value $iu.NewEmployeeID    
     
            $export_Changes += $obj_Change
            #set-aduser  -identity $tmpADuser.SamAccountName  -replace @{employeeID = $iu.'NewEmployeeID'} -Credential $creds
        
        }
    }#end found users
    else {
        $obj_noMatch = new-object PSObject 
        $obj_noMatch | add-member -MemberType NoteProperty -name Name -value ($iu.'FULL FIRST NAME' + " " + $iu.'FULL LAST/SUR NAME')     
        $obj_noMatch | add-member -MemberType NoteProperty -name EmployeeID -value $iu.'jde #'      
        $obj_noMatch | add-member -MemberType NoteProperty -name EmailAddress -value $iu.mail      

        $export_noMatch += $obj_noMatch
    }

    Write-Host "Percent Complete: " (($count / $importedUsers.count)*100)
    $count++
}

$Date = (Get-Date).ToString('MM-dd-yyyy')
$path_All = "C:\Users\$env:USERNAME\OneDrive - APR Energy\Service Desk\Headcount Documents\Results\UserAttributeUpdates_All_$Date.csv"
$path_Changes = "C:\Users\$env:USERNAME\OneDrive - APR Energy\Service Desk\Headcount Documents\Results\UserAttributeUpdates_Changes_$Date.csv"
$path_noMatch = "C:\Users\$env:USERNAME\OneDrive - APR Energy\Service Desk\Headcount Documents\Results\UserAttributeUpdates_NoMatch_$Date.csv"
$export_All | Export-Csv -Path $path_All -NoTypeInformation
$export_Changes | Export-Csv -Path $path_Changes -NoTypeInformation
$export_noMatch | Export-Csv -Path $path_noMatch -NoTypeInformation

$export.Count
$export_all.Count
$export_Changes.Count
$export_noMatch.Count