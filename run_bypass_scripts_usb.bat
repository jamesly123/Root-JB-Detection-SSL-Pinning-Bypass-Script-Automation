@echo off
setlocal enabledelayedexpansion

:: Prompt the user for the target app package name and the folder containing Frida scripts
set /p targetApp="Enter the target app package name (e.g., com.example.app): "
set /p scriptFolder="Which Platform it is: "

:: Check if the folder exists
if not exist "%scriptFolder%" (
    echo The specified folder path does not exist. Exiting.
    exit /b
)

:: Find all .js files in the specified folder
set scriptCount=0
for %%f in ("%scriptFolder%\*.js") do (
    set "scriptFiles[!scriptCount!]=%%f"
    set /a scriptCount+=1
)

:: Check if any .js scripts were found
if %scriptCount% EQU 0 (
    echo No .js scripts found in the specified folder. Exiting.
    exit /b
)

:: Run each Frida script on the target app
for /L %%i in (0,1,%scriptCount%-2) do (
    set "scriptPath=.\!scriptFiles[%%i]!"
    echo Running %%i/%scriptCount%
    echo Running Frida script: !scriptPath! on app: %targetApp%
    frida -U -f %targetApp% -l "!scriptPath!"
    pause
)

echo All scripts have been executed.
