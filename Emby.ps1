<# QBT use alt speed limits when Emby has active users
  Scriptname (Emby Address) (Emby API Key) (qbt address) (QBT username) (QBT password)
  Emby.ps1 http://localhost:8096 dcdcf76ccdb330e http://localhost:12345 username password#>

$embyaddress = $args[0]
$apikey = $args[1]
$qbtaddress = $args[2]
$username = $args[3]
$password = $args[4]
while (1 -eq 1) {


Try { $result = Invoke-RestMethod -Uri "$embyaddress/emby/Sessions?api_key=$apikey" -Method 'GET' -ContentType "application/json" |  % {$_.NowPlayingItem} }
             Catch { Write-Host "Couldnt connect to emby!"
                     Exit }

if ($result -like "*Name*") {Write-host "String contains Name, slow rates enabled"
# SET ALT SPEEDS
$result = Invoke-Webrequest -Uri "$qbtaddress/api/v2/auth/login" -Method 'POST' -Body "username=$username&password=$password" -Headers @{'Referrer' = "$qbtaddress/"} |
        Select-Object -Expand RawContent 
$logincookie = $result.tostring() -split "[`r`n]" | select-string "Set-Cookie" | % {$_ -replace '.*Set-Cookie: SID=|\;.*'}
$session = [Microsoft.PowerShell.Commands.WebRequestSession]::new()
$cookie = [System.Net.Cookie]::new('SID', "$logincookie")
$session.Cookies.Add("$qbtaddress/", $cookie)
# 1 is alt speeds
$dlstatus = Invoke-Webrequest -Uri "$qbtaddress/api/v2/transfer/speedLimitsMode" -Method 'GET' -WebSession $session | Select-Object -Expand Content
if ($dlstatus -eq 1) {Write-Host "alt"}
        Else { IWR -Uri "$qbtaddress/api/v2/transfer/toggleSpeedLimitsMode" -Method 'POST' -WebSession $session }
}


     Else {Write-Host "String does not contain name, fast rates enabled"
# SET STD SPEEDS
$result = Invoke-Webrequest -Uri "$qbtaddress/api/v2/auth/login" -Method 'POST' -Body "username=SERVER&password=Fuckoffm8" -Headers @{'Referrer' = "$qbtaddress/"} |
        Select-Object -Expand RawContent 
$logincookie = $result.tostring() -split "[`r`n]" | select-string "Set-Cookie" | % {$_ -replace '.*Set-Cookie: SID=|\;.*'}
$session = [Microsoft.PowerShell.Commands.WebRequestSession]::new()
$cookie = [System.Net.Cookie]::new('SID', "$logincookie")
$session.Cookies.Add("$qbtaddress/", $cookie)
# 0 is STD speeds
$dlstatus = Invoke-Webrequest -Uri "$qbtaddress/api/v2/transfer/speedLimitsMode" -Method 'GET' -WebSession $session | Select-Object -Expand Content
if ($dlstatus -eq 0) {Write-Host "STD"}
        Else { IWR -Uri "$qbtaddress/api/v2/transfer/toggleSpeedLimitsMode" -Method 'POST' -WebSession $session }}
Start-Sleep 10
}
