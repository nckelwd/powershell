$csv = Import-CSV "C:\Scripts\empid.csv"

foreach ($empid in $csv) {
    $e = $empid.empID 
    get-aduser -filter {(employeeID -like $e)} -Properties employeeid, enabled | select name, employeeID, enabled | export-csv "C:\Scripts\employeeAudit.csv" -NoTypeInformation -append
    
} 
 

      