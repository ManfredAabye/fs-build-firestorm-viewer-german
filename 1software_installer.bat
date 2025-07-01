@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: OK Manfred Aabye 25.06.2025 Version 3.3
REM 1software_installer.bat - Installiert die benötigten Software-Tools für den Firestorm Build-Prozess

:: ANSI-Farben
for /f %%a in ('echo prompt $E ^| cmd') do set "ESC=%%a"
set "GREEN=%ESC%[32m"
set "RED=%ESC%[31m"
set "RESET=%ESC%[0m"

echo %GREEN%=== Installation der Build-Tools ===%RESET%

echo %GREEN%=== Installation der Build-Tools ===%RESET%

:: 1. Visual Studio 2022 Community mit BEIDEN Toolsets
echo %GREEN%1. Installiere Visual Studio 2022 Community%RESET%
echo %GREEN%   - Workload: "Desktop development with C++"%RESET%
echo %GREEN%   - Zusätzliche Komponenten:%RESET%
echo %GREEN%     * MSVC v141 - VS 2017 C++ x64/x86-Buildtools%RESET%
echo %GREEN%     * MSVC v143 - VS 2022 C++ x64/x86-Buildtools%RESET%

choco install -y --no-progress visualstudio2022community ^
    --package-parameters="--add Microsoft.VisualStudio.Workload.NativeDesktop ^
    --add Microsoft.VisualStudio.Component.VC.14.16.x86.x64 ^
    --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64"

:: Chocolatey
echo %GREEN%2. Chocolatey-Installation%RESET%
if not exist "%ProgramData%\Chocolatey\bin\choco.exe" (
    echo %GREEN%[INFO] Installiere Chocolatey...%RESET%
    powershell -NoProfile -ExecutionPolicy Bypass -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; iex (New-Object Net.WebClient).DownloadString('https://chocolatey.org/install.ps1')"
    timeout /t 30
    call "%ProgramData%\Chocolatey\bin\refreshEnv.cmd"
)

:: Tools installieren
echo %GREEN%3. Installiere Build-Tools%RESET%
choco install -y --no-progress --stop-on-first-failure ^
    cmake ^
    git ^
    python ^
    nsis ^
    cygwin ^
    7zip ^
    doxygen

:: Cygwin Pakete
echo %GREEN%4. Installiere Cygwin-Pakete%RESET%
:: cygwinsetup.exe
if exist "C:\cygwin64\cygwinsetup.exe" (
    C:\cygwin64\cygwinsetup.exe -q -P patch
) else (
    echo %RED%[ERROR] Cygwin setup executable not found at 'C:\cygwin64\setup-x86_64.exe'. Check the path.%RESET%
)

echo %GREEN%=== Tool-Installation abgeschlossen ===%RESET%
echo %GREEN%Führen Sie nun '2firestorm_build.bat' aus.%RESET%
pause
