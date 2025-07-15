@echo off
setlocal enabledelayedexpansion

:: Prompt for target app and script folder
set /p targetApp="Enter the target app package name (e.g., com.example.app): "
set /p scriptFolder="Enter the path to the folder containing Frida scripts: "
set /p typeofScriptsUsed="Testing for SSL Pinning or Root/JB Detection? (S/s or D/d): "

:: Ask if the user wants to specify a device ID (overrides other connection options)
set /p specifyDevice="Do you want to specify a specific Frida device ID? (yes/y or no/n): "
if /I "%specifyDevice%" EQU "yes" (
    set /p deviceID="Enter the device ID (e.g., emulator-5556): "
    set "fridaOption=-D %deviceID%"
) else (
    :: Ask if the device is remote
    set /p connectionType="Is this a remote device? (yes/y or no/n): "
    if /I "%connectionType%" EQU "yes" (
        set /p ipAddr="Enter the IP address of the remote device: "
        set "fridaOption=-H %ipAddr%"
    ) else if /I "%connectionType%" EQU "y" (
        set /p ipAddr="Enter the IP address of the remote device: "
        set "fridaOption=-H %ipAddr%"
    ) else (
        :: Default to USB
        set "fridaOption=-U"
    )
)

:: Verify script folder exists
if not exist "%scriptFolder%" (
    echo The specified folder path does not exist. Exiting.
    exit /b
)

:: Determine script subfolder based on type
if /I "%typeofScriptsUsed%" EQU "s" (
    set "scriptFolder=%scriptFolder%\SSL"
) else if /I "%typeofScriptsUsed%" EQU "d" (
    set "scriptFolder=%scriptFolder%\Detection"
) else (
    echo Invalid script type entered. Exiting.
    exit /b
)

:: Collect all .js files in the folder
set scriptCount=0
for %%f in ("%scriptFolder%\*.js") do (
    set "scriptFiles[!scriptCount!]=%%f"
    set /a scriptCount+=1
)

:: Ensure at least one script was found
if %scriptCount% EQU 0 (
    echo No .js scripts found in %scriptFolder%. Exiting.
    exit /b
)

:: Execute each Frida script using the selected connection option
set /A end=%scriptCount%-1
for /L %%i in (0,1,!end!) do (
    set "scriptPath=%%~f"
    set /A scriptCurr=%%i+1
    echo Running script !scriptCurr! of %scriptCount%: !scriptFiles[%%i]!
    frida %fridaOption% -f "%targetApp%" -l "!scriptFiles[%%i]!"
    pause
)

echo All scripts executed.
pause
