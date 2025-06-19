@echo off
setlocal enabledelayedexpansion

:: Firestorm Windows Build Script by Manfred Aabye V 1.0.5
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
set "BUILD_DIR=%SCRIPT_DIR%Firestorm_Build"
cd /d "%SCRIPT_DIR%"

:: Clean previous build if exists
if exist "%BUILD_DIR%" (
    echo [INFO] Removing previous build directory...
    rmdir /s /q "%BUILD_DIR%"
)
mkdir "%BUILD_DIR%"
cd /d "%BUILD_DIR%"

:: Install Chocolatey (if not present)
if not exist "%ProgramData%\Chocolatey\bin\choco.exe" (
    echo [INFO] Installing Chocolatey package manager...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))"
    set "PATH=%PATH%;%ALLUSERSPROFILE%\Chocolatey\bin"
    timeout /t 30
)

:: Refresh environment after Chocolatey install
call "%ProgramData%\Chocolatey\bin\refreshEnv.cmd" >nul 2>&1

:: Install required tools via Chocolatey (without version pinning)
echo [INFO] Installing build dependencies...
@REM choco install -y --no-progress ^
@REM     git ^
@REM     cmake --installargs '"ADD_CMAKE_TO_PATH=System"' ^
@REM     tortoisegit ^
@REM     python --version=%PYTHON_VERSION% ^
@REM     nsis ^
@REM     visualstudio2022community ^
@REM     visualstudio2022-workload-nativedesktop

choco install -y --no-progress git
choco install -y --no-progress cmake --installargs '"ADD_CMAKE_TO_PATH=System"'
choco install -y --no-progress tortoisegit
choco install -y --no-progress python --version=%PYTHON_VERSION%
choco install -y --no-progress nsis
choco install -y --no-progress visualstudio2022community
choco install -y --no-progress visualstudio2022-workload-nativedesktop

:: Install Cygwin components
echo [INFO] Setting up Cygwin...
if not exist "%BUILD_DIR%\Cygwin64\bin\patch.exe" (
    choco install -y --no-progress cygwin --params '"/InstallDir:%BUILD_DIR%\Cygwin64 /Packages:patch"'
)
set "PATH=%BUILD_DIR%\Cygwin64\bin;%PATH%"

:: Configure Python environment
echo [INFO] Setting up Python virtual environment...
python -m venv "%BUILD_DIR%\venv"
call "%BUILD_DIR%\venv\Scripts\activate.bat"
python -m pip install --upgrade pip
python -m pip install -r "https://raw.githubusercontent.com/FirestormViewer/phoenix-firestorm/master/requirements.txt"
python -m pip install "git+https://github.com/secondlife/autobuild.git#egg=autobuild"

:: Set VS environment
echo [INFO] Configuring Visual Studio %VS_VERSION%...
set "AUTOBUILD_VSVER=170"
for /f "usebackq tokens=*" %%i in (`where vcvarsall.bat`) do set "VSTUDIO_ROOT=%%~dpi..\.."
call "%VSTUDIO_ROOT%\VC\Auxiliary\Build\vcvarsall.bat" x86_amd64

:: Clone repositories
echo [INFO] Cloning source repositories...
git clone "https://github.com/FirestormViewer/phoenix-firestorm.git"
git clone "https://github.com/FirestormViewer/fs-build-variables.git"
set "AUTOBUILD_VARIABLES_FILE=%BUILD_DIR%\fs-build-variables\variables"

:: Configure and build
echo [INFO] Configuring Firestorm Viewer...
cd "phoenix-firestorm"

:: Correct FMOD parameter handling
if "%FMOD_ENABLED%"=="true" (
    autobuild configure -A %ARCH% -c %CONFIG% -- --fmodstudio --package --chan CustomBuild -DLL_TESTS:BOOL=FALSE
) else (
    autobuild configure -A %ARCH% -c %CONFIG% -- --no-fmodstudio --package --chan CustomBuild -DLL_TESTS:BOOL=FALSE
)

echo [INFO] Building Firestorm Viewer...
autobuild build -A %ARCH% -c %CONFIG% --no-configure

:: Package the viewer
if exist "build-vc170-%ARCH%" (
    echo [INFO] Creating installer package...
    autobuild package -A %ARCH% -c %CONFIG% --results-file "%BUILD_DIR%\package_results.txt"
    
    echo [SUCCESS] Build completed! Output packages:
    dir /b "%BUILD_DIR%\phoenix-firestorm\*.exe"
) else (
    echo [ERROR] Build directory not found! Check for errors above.
)

pause