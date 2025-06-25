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

:: fmod

:: Das FMOD ist hier: C:\Program Files\FMOD SoundSystem\FMOD Studio 2.03.07

REM Setze Pfad zur FMOD Studio 2.03.07-Paketdatei
SET FMOD_PACKAGE=%~dp0fmodstudio-2.03.07-windows64.tar.bz2

REM Setze Pfad zur autobuild.xml
SET AUTOBUILD_CONFIG_FILE=%BUILD_DIR%\phoenix-firestorm\autobuild.xml
SET "AUTOBUILD_CONFIG_FILE_UNIX=%AUTOBUILD_CONFIG_FILE:\=/%"

REM Prüfe, ob FMOD-Paket existiert
IF NOT EXIST "%FMOD_PACKAGE%" (
    echo %RED%Fehler: FMOD-Paket nicht gefunden unter "%FMOD_PACKAGE%"%RESET%
    exit /b 1
)

REM Prüfe, ob die autobuild.xml vorhanden ist
IF NOT EXIST "%AUTOBUILD_CONFIG_FILE%" (
    echo %RED%Fehler: autobuild.xml nicht gefunden unter "%AUTOBUILD_CONFIG_FILE%"%RESET%
    exit /b 1
)

REM MD5-Hash berechnen
FOR /F "skip=1 tokens=1" %%H IN ('certutil -hashfile "%FMOD_PACKAGE%" MD5') DO (
    SET "FMOD_HASH=%%H"
    GOTO :hash_done
)
:hash_done

IF NOT DEFINED FMOD_HASH (
    echo %RED%Fehler beim Berechnen des Hashwerts für FMOD-Paket%RESET%
    exit /b 1
)

REM FMOD-Paket mit Hash registrieren
echo %GREEN%Registriere FMOD Studio 2.03.07 unter platform=windows64%RESET%
autobuild installables add fmodstudio platform=windows64 ^
  url="file:///%FMOD_PACKAGE:/=/%" ^
  hash=%FMOD_HASH% ^
  version=2.03.07 ^
  license=fmod ^
  license_file=LICENSES/fmodstudio.txt ^
  --config-file="%AUTOBUILD_CONFIG_FILE_UNIX%"

echo %GREEN%FMOD-Paket erfolgreich eingebunden.%RESET%

:: FMOD vorbereiten
@REM 7z a -ttar fmodstudio-2.03.07-windows64.tar fmod_prepared
@REM 7z a -tbzip2 fmodstudio-2.03.07-windows64-251121127.tar.bz2 fmodstudio-2.03.07-windows64.tar

:: Es wird im Verzeichnis c:\cygwin\opt\firestorm\ erwartet.
if not exist "c:\cygwin\opt\firestorm" (
    mkdir "c:\cygwin\opt\firestorm"
)
xcopy /Y /Q "%SCRIPT_DIR%fmodstudio-2.03.07-windows64.tar.bz2" "c:\cygwin\opt\firestorm\" >nul
:: xcopy /Y /Q "%SCRIPT_DIR%fmodstudio-2.03.07-windows64.tar.bz2" "c:\cygwin\opt\firestorm\fmodstudio-2.03.07-windows64.tar.bz2" >nul

:: fmod

echo %GREEN%4. Build-Variablen setzen%RESET%
set "AUTOBUILD_VSVER=170"
set "AUTOBUILD_VARIABLES_FILE=%BUILD_DIR%\fs-build-variables\variables"

echo %GREEN%5. Python-Abhängigkeiten installieren%RESET%
python -m pip install -r "%BUILD_DIR%\phoenix-firestorm\requirements.txt"

:: todo: Prebuild fehlt
pause