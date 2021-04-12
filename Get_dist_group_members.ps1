$final = @()

$1 = Get-DistributionGroup #Groupname*

$1 | %{ 
write-host $_.DisplayName
$ListName = $_.Name
$ListDisplayName = $_.DisplayName
$2 = Get-distributionGroupMember $listName
 $2 | %{
 $MbxAlias = $_.Alias
 $MBxFirst = $_.FirstName
 $MBxLast = $_.LastName
 $returnobj = new-object psobject
 $returnobj |Add-Member -MemberType NoteProperty -Name "ListDisplayName" -Value $ListDisplayName
 $returnobj |Add-Member -MemberType NoteProperty -Name "FirstName" -Value $MbxFirst
 $returnobj |Add-Member -MemberType NoteProperty -Name "LastName" -Value $MbxLast
 $final += $returnObj
  }
}

$final | Export-csv C:\Scripts\MSGroups.csv