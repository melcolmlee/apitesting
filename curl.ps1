#Set headers and TLS version 
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Content-Type", "application/json")
$headers.Add("Accept", "application/json")

#Set test duration in minutes
$duration = 5
$timeStart = Get-Date
$timeEnd = $timeStart.AddMinutes($duration)

#Format date and time 
$timeInfo = New-Object System.Globalization.DateTimeFormatInfo;
$timeStamp = Get-Date -Format $timeInfo.SortableDateTimePattern;
$timeStamp = $timeStamp.Replace(":","-")

#Import CSV of API
$apiList = Import-Csv .\endpoints.csv

do{

    ForEach ($api in $apiList){
        $timer = [System.Diagnostics.Stopwatch]::StartNew()
        $body = $api.query
        $response = Invoke-RestMethod $api.endpoint -Method 'POST' -Headers $headers -Body $body
        $timer.Stop()
        $response | ConvertTo-Json
        $responseTime = $timer.Elapsed.TotalMilliseconds.ToString()
        Write-Host $responseTime "ms"
}

    Start-Sleep -Seconds 10 
    $timeNow = Get-Date
} until ($timeNow -ge $timeEnd)