rem This batch file finds the Half-Life directory and returns it
rem If the directory could not be found, returns an empty value
@echo off

set "RETURNVALUE="

setlocal enabledelayedexpansion
set KEY_NAME="HKEY_CURRENT_USER\Software\Valve\Steam"
set VALUE_NAME=ModInstallPath

rem Path relative to the default game or DS install.
set "RELATIVE_PATH=..\..\Half-Life"

FOR /F "tokens=2*" %%A IN ('REG.exe query "%KEY_NAME%" /v "%VALUE_NAME%" 2^>nul ^| find "%VALUE_NAME%"') DO (set pInstallDir=%%B)

IF ["%pInstallDir%"] == [] (
	ECHO Could not find %VALUE_NAME%. Trying to find game directory using relative path.
	IF EXIST %RELATIVE_PATH% (
		set "RETURNVALUE=%RELATIVE_PATH%"
	) ELSE (
		set RETURNVALUE=
	)
) ELSE (
	set "RETURNVALUE=%pInstallDir%"
)

ENDLOCAL&SET %~1=%RETURNVALUE%