#Set headers and TLS version 
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Content-Type", "application/json")
$headers.Add("Accept", "application/json")

#Set test duration in minutes
$duration = 5
$timeStart = Get-Date
$timeEnd = $timeStart.AddMinutes($duration)

#Import CSV of API
$apiList = Import-Csv .\endpoints.csv

do{

    ForEach ($api in $apiList){
        #Format date and time
        $timeInfo = New-Object System.Globalization.DateTimeFormatInfo;
        $timeStamp = Get-Date -Format $timeInfo.SortableDateTimePattern;
        $timeStamp = $timeStamp.Replace(":","-")
        
        #Set body of request
        $body = $api.query
        
        try {
            $url = $api.endpoint
            $timer = [System.Diagnostics.Stopwatch]::StartNew()
            $response = Invoke-RestMethod $url -Method 'POST' -Headers $headers -Body $body
            $timer.Stop()
            $response | ConvertTo-Json
            $responseTime = $timer.Elapsed.TotalMilliseconds.ToString()
            #Write-Host $responseTime "ms"
            Add-Content .\apiTestLog.csv "$timeStamp,$url,PASS,$responseTime,$response" 
        }
        catch {
            Add-Content .\apiTestLog.csv "$timeStamp,$url,FAIL,$responseTime,$response" 
        }       
}

    Start-Sleep -Seconds 10 
    $timeNow = Get-Date
} until ($timeNow -ge $timeEnd)