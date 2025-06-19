@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: firestorm_build.bat Firestorm Windows Build Script by Manfred Aabye V 1.0.9
:: -----------------------------------------------------
:: This script automates the build process for the Firestorm Viewer on Windows.
:: It installs necessary dependencies, configures the environment, and builds the viewer.
:: https://github.com/FirestormViewer/phoenix-firestorm/blob/master/doc/building_windows.md

:: Configuration
set "PYTHON_VERSION=3.10.11"
set "VS_VERSION=2022"
set "ARCH=64"
set "CONFIG=ReleaseFS_open"
set "FMOD_ENABLED=false"

:: Set build directory relative to script location
set "SCRIPT_DIR=%~dp0"
set "AUTOBUILD_CACHE_DIR=%SCRIPT_DIR%.autobuild-cache"
set "BUILD_DIR=%SCRIPT_DIR%Firestorm_Build"
cd /d "%SCRIPT_DIR%"

:: Clean previous build if exists
if exist "%BUILD_DIR%" (
    echo " ___________________________"
    echo [INFO] Removing previous build directory...
    rmdir /s /q "%BUILD_DIR%"
)
mkdir "%BUILD_DIR%"
cd /d "%BUILD_DIR%"

:: Install Chocolatey (if not present)
if not exist "%ProgramData%\Chocolatey\bin\choco.exe" (
    echo " ___________________________"
    echo [INFO] Installing Chocolatey package manager...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))"
    set "PATH=%PATH%;%ALLUSERSPROFILE%\Chocolatey\bin"
    timeout /t 30
)

:: Refresh environment after Chocolatey install
call "%ProgramData%\Chocolatey\bin\refreshEnv.cmd" >nul 2>&1

:: Install required tools via Chocolatey (without version pinning)
echo " ___________________________"
echo [INFO] Installing build dependencies...
choco install -y --no-progress git
choco install -y --no-progress cmake --installargs '"ADD_CMAKE_TO_PATH=System"'
choco install -y --no-progress tortoisegit
choco install -y --no-progress python --version=%PYTHON_VERSION%
choco install -y --no-progress nsis
choco install -y --no-progress visualstudio2022community
choco install -y --no-progress visualstudio2022-workload-nativedesktop

:: Install Cygwin components
echo " ___________________________"
echo [INFO] Setting up Cygwin...
if not exist "%BUILD_DIR%\Cygwin64\bin\patch.exe" (
    choco install -y --no-progress cygwin --params '"/InstallDir:%BUILD_DIR%\Cygwin64 /Packages:patch"'
)
set "PATH=%BUILD_DIR%\Cygwin64\bin;%PATH%"

:: Configure Python environment
echo " ___________________________"
echo [INFO] Setting up Python virtual environment...
python -m venv "%BUILD_DIR%\venv"
call "%BUILD_DIR%\venv\Scripts\activate.bat"
python -m pip install --upgrade pip
python -m pip install -r "https://raw.githubusercontent.com/FirestormViewer/phoenix-firestorm/master/requirements.txt"
python -m pip install "git+https://github.com/secondlife/autobuild.git#egg=autobuild"

:: Set VS environment
echo " ___________________________"
echo [INFO] Configuring Visual Studio %VS_VERSION%...
set "AUTOBUILD_VSVER=170"
for /f "usebackq tokens=*" %%i in (`where vcvarsall.bat`) do set "VSTUDIO_ROOT=%%~dpi..\.."
call "%VSTUDIO_ROOT%\VC\Auxiliary\Build\vcvarsall.bat" x86_amd64

:: Clone repositories
echo " ___________________________"
echo [INFO] Cloning source repositories...
git clone "https://github.com/FirestormViewer/phoenix-firestorm.git"
git clone "https://github.com/FirestormViewer/fs-build-variables.git"
set "AUTOBUILD_VARIABLES_FILE=%BUILD_DIR%\fs-build-variables\variables"

:: Configure and build
echo " ___________________________"
echo [INFO] Configuring Firestorm Viewer...
cd "phoenix-firestorm"









:: Dynamisch prüfen, ob fmod_prepared existiert
if exist "%SCRIPT_DIR%fmod_prepared" (
    echo [INFO] FMOD-Verzeichnis gefunden – baue mit FMOD Studio-Unterstützung.
    set "FMOD_ENABLED=true"
    
    :: FMOD-Dateien in Firestorm-Baum einfügen
    xcopy /E /Y /I "%SCRIPT_DIR%fmod_prepared\include\fmod" "%BUILD_DIR%\phoenix-firestorm\libraries\i686-win32\include\fmod" >nul
    xcopy /E /Y /I "%SCRIPT_DIR%fmod_prepared\lib\release" "%BUILD_DIR%\phoenix-firestorm\libraries\i686-win32\lib\release" >nul

    :: FMOD-Paket erkennen und registrieren (Version 2.03.07 bevorzugt, alternativ 2.02.05)
    set "FMOD_PACKAGE="
    if exist "%SCRIPT_DIR%fmodstudio-2.03.07-windows64.tar.bz2" (
        set "FMOD_PACKAGE=%SCRIPT_DIR%fmodstudio-2.03.07-windows64.tar.bz2"
    ) else if exist "%SCRIPT_DIR%fmodstudio-2.02.05-windows64.tar.bz2" (
        set "FMOD_PACKAGE=%SCRIPT_DIR%fmodstudio-2.02.05-windows64.tar.bz2"
    )

    if defined FMOD_PACKAGE (
        echo [INFO] FMOD-Paketdatei erkannt: %FMOD_PACKAGE%

        for /f "tokens=1" %%h in ('certutil -hashfile "!FMOD_PACKAGE!" MD5 ^| find /i /v "hash" ^| find /i /v ":"') do set FMOD_HASH=%%h

        set "FMOD_TAR_URL=file:///%FMOD_PACKAGE:\=/%"
        autobuild installables edit fmodstudio platform=windows64 hash=!FMOD_HASH! url=!FMOD_TAR_URL!
    ) else (
        echo [WARNUNG] Kein passendes .tar.bz2-FMOD-Paket gefunden – Build könnte fehlschlagen.
    )
) else (
    echo [INFO] Kein FMOD-Verzeichnis gefunden – baue ohne FMOD Studio.
    set "FMOD_ENABLED=false"
)







:: Konfigurieren mit oder ohne FMOD
if "%FMOD_ENABLED%"=="true" (
    autobuild configure -A %ARCH% -c %CONFIG% -- --fmodstudio --package --chan CustomBuild -DLL_TESTS:BOOL=FALSE
) else (
    autobuild configure -A %ARCH% -c %CONFIG% -- --no-fmodstudio --package --chan CustomBuild -DLL_TESTS:BOOL=FALSE
)


echo " ___________________________"
echo [INFO] Building Firestorm Viewer...
autobuild build -A %ARCH% -c %CONFIG% --no-configure

:: Package the viewer
if exist "build-vc170-%ARCH%" (
    echo " ___________________________"
    echo [INFO] Creating installer package...
    autobuild package -A %ARCH% -c %CONFIG% --results-file "%BUILD_DIR%\package_results.txt"
    
    echo [SUCCESS] Build completed! Output packages:
    dir /b "%BUILD_DIR%\phoenix-firestorm\*.exe"
) else (
    echo [ERROR] Build directory not found! Check for errors above.
)

pause