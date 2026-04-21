# https://www.logicmonitor.com/support/rest-api-developers-guide/v1/collectors/downloading-a-collector-installer#installation
cls;
write-host "Downloading installer, please wait...";
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls11 -bor [System.Net.SecurityProtocolType]::Tls12;
(New-Object System.Net.WebClient).DownloadFile("${download_url}", "$env:USERPROFILE\LM.exe");
write-host "Download completed, starting installer";
&"$env:USERPROFILE\LM.exe"