@echo off
setlocal EnableDelayedExpansion
Title PC Diagnostics Tool
mode con: cols=100 lines=35

:: ===== DEFAULT TEXT COLOR (Foreground Only, Pink-Red) =====
color 0C

:menu
cls
echo =====================================================
echo               PC DIAGNOSTICS TOOL
echo =====================================================
echo.
echo   1 - Check CPU Temps
echo   2 - Check RAM
echo   3 - Check GPU Events
echo   4 - Check Storage
echo   5 - Check Windows System Files
echo   6 - Run ALL
echo   7 - Change Text Color
echo   8 - Exit

echo.
choice /c 12345678 /n /m "Select: "
set "action=%errorlevel%"

if %action%==1 goto temps
if %action%==2 goto ram
if %action%==3 goto gpu
if %action%==4 goto storage
if %action%==5 goto windows
if %action%==6 goto all
if %action%==7 goto colorMenu
if %action%==8 exit
goto menu

:colorMenu
cls
echo ===================== TEXT COLOR SELECT =====================
echo.
echo 0 - Black
echo 1 - Blue
echo 2 - Green
echo 3 - Aqua
echo 4 - Red
echo 5 - Purple
echo 6 - Yellow
echo 7 - White
echo 8 - Gray

echo.
choice /c 012345678 /n /m "Select a text color: "
set /a fg=%errorlevel%-1
:: Keep background black (0) and only change foreground
color 0%fg%
pause
goto menu

:temps
cls
echo =============== CPU TEMPERATURE CHECK ===============
echo.
tasklist | findstr /i "OpenHardwareMonitor.exe" >nul
if not %errorlevel%==0 (
    echo OpenHardwareMonitor is NOT detected.
    echo Install it here: https://openhardwaremonitor.org
    pause
    goto menu
)
for /f "tokens=*" %%a in ('powershell -command "(Get-WmiObject MSAcpi_ThermalZoneTemperature).CurrentTemperature / 10 - 273.15"') do set ctemp=%%a
echo CPU Temperature: !ctemp! °C
echo GPU temps appear inside OpenHardwareMonitor.
choice /c YN /n /m "Run CPU stress test (Y/N)? "
if %errorlevel%==2 goto menu
pause
exit /b

:ram
cls
echo ===================== RAM DIAGNOSTIC =====================
echo.
echo Installed RAM Modules (Bank - Capacity - Speed):

powershell -Command "Get-CimInstance Win32_PhysicalMemory | ForEach-Object { ($_.BankLabel + ' - ' + ([math]::Round($_.Capacity/1GB,2)) + ' GB - ' + $_.Speed + ' MHz') }"
echo.
choice /c YN /n /m "Run detailed RAM test (Y/N)? "
if %errorlevel%==2 goto menu
pause
exit /b

:gpu
cls
echo ===================== GPU DRIVER CHECK =====================
echo.
echo Showing recent GPU driver events (simplified):

powershell -Command "Get-WinEvent -LogName System | Where-Object { $_.Message -like '*nvlddmkm*' -or $_.Message -like '*NVIDIA Display*' } | Select-Object -First 10 | ForEach-Object { ($_.TimeCreated.ToString('MM/dd/yyyy HH:mm') + ' - ' + ($_.Message.Split([char]10)[0])) }"
echo.
choice /c YN /n /m "Run GPU detailed test (Y/N)? "
if %errorlevel%==2 goto menu
pause
exit /b

:storage
cls
echo ===================== STORAGE HEALTH =====================
echo.
echo Disk Drives:

powershell -Command "Get-PhysicalDisk | ForEach-Object { ($_.FriendlyName + ' - ' + $_.HealthStatus + ' - ' + ([math]::Round($_.Size/1GB,2)) + ' GB') }"
echo.
choice /c YN /n /m "Run CHKDSK (Y/N)? "
if %errorlevel%==2 goto menu
if %errorlevel%==1 chkdsk /f /r
pause
exit /b

:windows
cls
echo ===================== WINDOWS SYSTEM FILE CHECK =====================
echo.
echo Checking Windows system files (simplified output)...
echo.
echo SFC will scan and repair system files.
echo DISM will check and restore system health.
choice /c YN /n /m "Run system file check (Y/N)? "
if %errorlevel%==2 goto menu
sfc /scannow
DISM /online /cleanup-image /restorehealth
pause
exit /b

:all
cls
echo =============== RUNNING ALL TESTS ===============
echo.
choice /c YN /n /m "Run all diagnostics (Y/N)? "
if %errorlevel%==2 goto menu
call :temps
call :ram
call :gpu
call :storage
call :windows
pause
goto menu