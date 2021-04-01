$gameDir = "C:\bedrock"

cd $gameDir

[Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"

(Invoke-WebRequest -Uri https://minecraft.net/en-us/download/server/bedrock/).Content -match "<a href=""(.*.zip).*?"">"
$url = $Matches[1]
$filename = $url.Replace("https://minecraft.azureedge.net/bin-win/","")
$filename

$url = "$url"
$output = "$gameDir\$filename"
$output

if(!(get-item $output)){
    Stop-Process -name "bedrock_server"

    # DO AN BACKUP OF CONFIG
    New-Item -ItemType Directory -Name backup
    Copy-Item -Path "server.properties" -Destination backup
    Copy-Item -Path "whitelist.json" -Destination backup
    Copy-Item -Path "permissions.json" -Destination backup

    $start_time = Get-Date

    Invoke-WebRequest -Uri $url -OutFile $output
    Write-Output "Time taken: $((Get-Date).Subtract($start_time).Seconds) second(s)"
    Expand-Archive -LiteralPath $output -DestinationPath $gameDir -Force

    # RECOVER BACKUP OF CONFIG
    Copy-Item -Path ".\backup\server.properties" -Destination .\
    Copy-Item -Path ".\backup\whitelist.json" -Destination .\
    Copy-Item -Path ".\backup\permissions.json" -Destination .\

}

if(!(get-process -name bedrock_server)){
    Start-Process "bedrock_server.exe"
}

exit
