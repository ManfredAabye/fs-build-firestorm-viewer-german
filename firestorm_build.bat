@echo off
setlocal enabledelayedexpansion

:: Firestorm Windows Build Script (Virtual Environment)
:: ------------------------------------------------
:: This script automates the setup and compilation of Firestorm Viewer
:: in a clean environment with Python virtualenv.

:: Configuration
set BUILD_DIR=C:\firestorm_build
set PYTHON_VERSION=3.10
set VS_VERSION=2022
set ARCH=64
set CONFIG=ReleaseFS_open
set FMOD_ENABLED=false

:: Clean previous build if exists
if exist "%BUILD_DIR%" (
    echo [INFO] Removing previous build directory...
    rmdir /s /q "%BUILD_DIR%"
)
mkdir "%BUILD_DIR%"
cd /d "%BUILD_DIR%"

:: Install Chocolatey (if not present)
if not exist "%ProgramData%\chocolatey\bin\choco.exe" (
    echo [INFO] Installing Chocolatey package manager...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))"
    set PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin
)

:: Install required tools via Chocolatey
echo [INFO] Installing build dependencies...
choco install -y --no-progress ^
    git ^
    cmake --installargs 'ADD_CMAKE_TO_PATH=System' ^
    tortoisegit ^
    python --version=%PYTHON_VERSION% ^
    nsis ^
    visualstudio2022community ^
    visualstudio2022-workload-nativedesktop

:: Install Cygwin components
echo [INFO] Setting up Cygwin...
if not exist "C:\cygwin64\bin\patch.exe" (
    choco install -y --no-progress cygwin --params "/InstallDir:C:\cygwin64 /Packages:patch"
)
set PATH=C:\cygwin64\bin;%PATH%

:: Configure Python environment
echo [INFO] Setting up Python virtual environment...
python -m venv venv
call venv\Scripts\activate.bat
python -m pip install --upgrade pip
python -m pip install -r https://raw.githubusercontent.com/FirestormViewer/phoenix-firestorm/master/requirements.txt
python -m pip install git+https://github.com/secondlife/autobuild.git#egg=autobuild

:: Set VS environment
echo [INFO] Configuring Visual Studio %VS_VERSION%...
set AUTOBUILD_VSVER=170
if "%VS_VERSION%"=="2022" set VSTUDIO_ROOT=C:\Program Files\Microsoft Visual Studio\2022\Community
call "%VSTUDIO_ROOT%\VC\Auxiliary\Build\vcvarsall.bat" x86_amd64

:: Clone repositories
echo [INFO] Cloning source repositories...
git clone https://github.com/FirestormViewer/phoenix-firestorm.git
git clone https://github.com/FirestormViewer/fs-build-variables.git
set AUTOBUILD_VARIABLES_FILE=%BUILD_DIR%\fs-build-variables\variables

:: FMOD Studio setup (optional)
if "%FMOD_ENABLED%"=="true" (
    echo [INFO] Setting up FMOD Studio...
    git clone https://github.com/FirestormViewer/3p-fmodstudio.git
    cd 3p-fmodstudio
    :: Download FMOD Studio API (requires manual download)
    echo [WARNING] Please download FMOD Studio API manually and place in 3p-fmodstudio folder
    pause
    autobuild build -A %ARCH% --all
    autobuild package -A %ARCH% --results-file result.txt
    for /f "tokens=2" %%i in ('type result.txt ^| find "md5"') do set FMOD_HASH=%%i
    set FMOD_PKG=%BUILD_DIR%\3p-fmodstudio\fmodstudio-*-windows%ARCH%-*.tar.bz2
    cd ..\phoenix-firestorm
    copy autobuild.xml my_autobuild.xml
    set AUTOBUILD_CONFIG_FILE=my_autobuild.xml
    autobuild installables edit fmodstudio platform=windows%ARCH% hash=%FMOD_HASH% url=file:///%FMOD_PKG:\=/% 
)

:: Configure and build
echo [INFO] Configuring Firestorm Viewer...
cd phoenix-firestorm
autobuild configure -A %ARCH% -c %CONFIG% -- ^
    --%FMOD_ENABLED%fmodstudio ^
    --package ^
    --chan CustomBuild ^
    -DLL_TESTS:BOOL=FALSE

echo [INFO] Building Firestorm Viewer...
autobuild build -A %ARCH% -c %CONFIG% --no-configure

:: Package the viewer
echo [INFO] Creating installer package...
autobuild package -A %ARCH% -c %CONFIG% --results-file package_results.txt

echo [SUCCESS] Build completed! Output packages:
dir /b "%BUILD_DIR%\phoenix-firestorm\*.exe"
pause