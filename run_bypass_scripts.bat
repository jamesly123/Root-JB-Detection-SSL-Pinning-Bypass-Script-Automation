@echo off
setlocal enabledelayedexpansion

:: Prompt the user for the target app package name and the folder containing Frida scripts
set /p targetApp="Enter the target app package name (e.g., com.example.app): "
set /p scriptFolder="Which platform is it (path to script folder): "
set /p connectionType="Is this a remote device? (yes/y or no/n): "
set /p typeofScriptsUsed="Testing for SSL Pinning or Root/JB Detection? (S/s or D/d): "

:: Normalize the input to lowercase for consistency
for %%A in (A B C D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
    set "connectionType=!connectionType:%%A=%%A!"
)

:: Set initial Frida connection option based on remote or USB
if /I "%connectionType%" EQU "yes" (
    set /p ipAddr="Enter the IP address of the target: "
    set "fridaOption=-H %ipAddr%"
) else if /I "%connectionType%" EQU "y" (
    set /p ipAddr="Enter the IP address of the target: "
    set "fridaOption=-H %ipAddr%"
) else (
    set "fridaOption=-U"
)

:: Ask if the user wants to specify a specific device ID (overrides -U)
set /p specifyDevice="Do you want to specify a specific device ID? (yes/y or no/n): "
if /I "%specifyDevice%" EQU "yes" (
    set /p deviceID="Enter the device ID (e.g., emulator-5556): "
    set "fridaOption=-D %deviceID%"
)

:: Check if the specified script folder exists
if not exist "%scriptFolder%" (
    echo The specified folder path does not exist. Exiting.
    exit /b
)

:: Determine script subfolders to search
if /I "%typeofScriptsUsed%" EQU "s" (
    set "scriptFolder=%scriptFolder%\SSL"
) else if /I "%typeofScriptsUsed%" EQU "S" (
    set "scriptFolder=%scriptFolder%\SSL"
) else if /I "%typeofScriptsUsed%" EQU "d" (
    set "scriptFolder=%scriptFolder%\Detection"
) else if /I "%typeofScriptsUsed%" EQU "D" (
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

:: Ensure there is at least one Frida script
if %scriptCount% EQU 0 (
    echo No .js scripts found in the specified folder. Exiting.
    exit /b
)

:: Run each Frida script on the target app
set /A end=%scriptCount%-1
for /L %%i in (0,1,!end!) do (
    set "scriptPath=.\!scriptFiles[%%i]!"
    set /A scriptCurr=%%i+1
    echo Running !scriptCurr!/%scriptCount%
    echo Running Frida script: !scriptPath! on app: %targetApp%
    frida %fridaOption% -f "%targetApp%" -l "!scriptPath!"
    pause
)

echo All scripts have been executed.
pause
