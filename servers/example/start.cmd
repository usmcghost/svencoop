@ECHO OFF

SET game=svencoop
SET config=example
SET port=27015
SET players=12
SET map=_server_start

SET dirGame=C:\Games\SvenDS
set dirConfig=%dirGame%\%game%\servers\%config%

cd "%dirGame%"
ECHO Launching SvenDS with the "%config%" configuration set...
ECHO.
SvenDS.exe -console -autoupdate -game %game% -port %port% -noipx +maxplayers %players% +servercfgfile "servers/%config%/server.cfg" +logsdir "servers/%config%/logs" +log on +map %map% %1 %2 %3 %4 %5 %6 %7 %8 %9
ECHO.
ECHO SvenDS has closed.
ECHO.
cd "%dirConfig%"
