@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: ANSI-Farben
for /f %%a in ('echo prompt $E ^| cmd') do set "ESC=%%a"
set "GREEN=%ESC%[32m"
set "RED=%ESC%[31m"
set "RESET=%ESC%[0m"

echo %GREEN%=== Firestorm Build-Vorbereitung ===%RESET%

:: Konfiguration
set "PYTHON_VERSION=3.10.11"
set "SCRIPT_DIR=%~dp0"
set "BUILD_DIR=%SCRIPT_DIR%Firestorm_Build"
set "VENV_DIR=%BUILD_DIR%\venv"

echo %GREEN%1. Erstelle Build-Verzeichnis%RESET%
mkdir "%BUILD_DIR%" 2>nul

echo %GREEN%2. Python-Virtualenv einrichten%RESET%
if not exist "%VENV_DIR%" (
    python -m venv "%VENV_DIR%"
    call "%VENV_DIR%\Scripts\activate.bat"
    python -m pip install --upgrade pip
    python -m pip install llbase llsd "git+https://github.com/secondlife/autobuild.git#egg=autobuild"
    echo %GREEN%[ERFOLG] Virtualenv wurde erstellt.%RESET%
) else (
    call "%VENV_DIR%\Scripts\activate.bat"
    echo %GREEN%[INFO] Virtualenv existiert bereits.%RESET%
)

echo %GREEN%3. Quellcode holen%RESET%
if not exist "%BUILD_DIR%\phoenix-firestorm" (
    git clone "https://github.com/FirestormViewer/phoenix-firestorm.git" "%BUILD_DIR%\phoenix-firestorm"
)
if not exist "%BUILD_DIR%\fs-build-variables" (
    git clone "https://github.com/FirestormViewer/fs-build-variables.git" "%BUILD_DIR%\fs-build-variables"
)

echo %GREEN%4. Build-Variablen setzen%RESET%
set "AUTOBUILD_VSVER=170"
set "AUTOBUILD_VARIABLES_FILE=%BUILD_DIR%\fs-build-variables\variables"

echo %GREEN%5. Python-Abhängigkeiten installieren%RESET%
python -m pip install -r "%BUILD_DIR%\phoenix-firestorm\requirements.txt"

:: todo: Prebuild fehlt
pause