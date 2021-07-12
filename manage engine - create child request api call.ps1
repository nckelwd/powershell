#get Requests
$sdphost = "https://helpdesk.aprenergy.net/"
$techKey = "951E0751-8C6D-4701-B365-E5E8379C2339"
$technician_key = @{ 'technician_key' = '951E0751-8C6D-4701-B365-E5E8379C2339'}
$APIEndpoint = "api/v3/requests/135407"
$APIURI = $sdphost + $APIEndpoint

$response = Invoke-RestMethod -uri $APIURI -Method get -Headers $technician_key
$response | ConvertTo-Json
if ($response.request.udf_fields.udf_pick_1801 -eq "yes") {
    write-host "its a yes from me dawg"    
}


#create Request
$sdphost = "https://helpdesk.aprenergy.net/"
$technician_key = @{ 'technician_key' = '951E0751-8C6D-4701-B365-E5E8379C2339'}
$APIEndpoint = "api/v3/requests"
$APIURI = $sdphost + $APIEndpoint

$input_data = @'
{
    "request": {
        "subject": "Test request - Subject",
        "description": "Test request - Description",
        "requester": {
            "email_id":  "Taylor.Bogle@aprenergy.com",
            "name":  "Bogle, Taylor",
            "is_vipuser":  false,
            "id":  "14156"            
        },        
        "resolution": {
            "content": "Test Request - resolution"
        },
        "status": {
            "name": "new"
        },
        "request_type": {
            "name": "Service Request"
        },
        "template": {
            "name": "Purchase"
        }
    }
}
'@

$data = @{ 'input_data' = $input_data}

$response = Invoke-RestMethod -uri $APIURI -Method post -Body $data -Headers $technician_key -ContentType "application/x-www-form-urlencoded"
$response ConvertTo-Json

#get Request Templates

$sdphost = "https://helpdesk.aprenergy.net/"
$technician_key = @{ 'technician_key' = '951E0751-8C6D-4701-B365-E5E8379C2339'}
$APIEndpoint = "/api/v3/request_templates"
$APIURI = $sdphost + $APIEndpoint

$response = Invoke-RestMethod -uri $APIURI -Method get -Headers $technician_key
$response | ConvertTo-Json