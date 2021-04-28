#This script imports a CSV file from Workday and looks at a row header called 'EmployeeID' --- this column header must be exact
#The filter only looks at enabled users
#The output will create a CSV file which contains all the desired properties of those users found in Active Directory
#The script takes about 2-3 minutes to run
#Script is based on this article: https://community.spiceworks.com/topic/491322-powershell-get-aduser-displayname-from-csv-with-names
#To compare the data from both this CSV file output and the HR CSV file, you will need to run "CSV_MergeEmpId.ps1" afterwards

#file location to import the CSV
$in_file = "C:\Temp\Workday_ad\KD_AD_Report 09.18.17.csv"

#file location to export the results to CSV
$out_file = "C:\Temp\Workday_ad\Reports\WorkdayToAD091817.csv"

$out_data = @()

ForEach ($row in (Import-Csv $in_file)) {
    If ($row.'EmployeeID') {
        $out_data += Get-ADUser -Filter "enabled -eq '$TRUE' -and employeeID -eq '$($row.'EmployeeID')' " -Properties * | Select-Object DisplayName,employeeID,emailaddress,enabled,samaccountname

    }
} 

$out_data | 
Select Department,DisplayName,office,departmentNumber,Manager,employeeType,employeeID,GivenName,Surname,title,emailaddress,enabled,samaccountname |
Export-Csv -Path $out_file -NoTypeInformation

