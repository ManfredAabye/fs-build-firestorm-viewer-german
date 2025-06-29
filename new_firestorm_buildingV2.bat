@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: Dies ist die Datei 2firestorm_build.bat
:: Diese Datei ist Teil des Firestorm Viewer Build-Prozesses.
:: Verion 1.2.5
:: by Manfred Aabye
:: Stand: 28.06.2025
:: Wichtige Hinweise: Wenn Github installiert ist kann es sein das dessen link.exe verwendet wird die kann man ändern indem man diese Datei in glink.exe umbenennt damit die autobuild.xml die richtige link.exe findet.
:: todo: Aus dem Paket 3p-openal-soft werden 2 DLL Dateien nicht mit kopiert alut.dll und OpenAL32.dll ein nachträgliche einfügen läst den Firestorm starten. Diese befinden sich im Paket openal-1.23.1-windows64-11115781501.tar.zst

:: === ANSI-Farben ===

for /f %%a in ('echo prompt $E ^| cmd') do set "ESC=%%a"
set "GREEN=%ESC%[32m"
set "RED=%ESC%[31m"
set "YELLOW=%ESC%[33m"
set "BLUE=%ESC%[34m"
set "RESET=%ESC%[0m"

echo %GREEN%=== Firestorm Build-Vorbereitung ===%RESET%

:: === Konfiguration ===
:: Kein link.exe von Github nutzen
set "PATH=%PATH:C:\Program Files\Git\usr\bin;=%"
set "PYTHON_VERSION=3.10.11"
set "SCRIPT_DIR=%~dp0"
set "BUILD_DIR=%SCRIPT_DIR%Firestorm_Build"
set "VENV_DIR=%BUILD_DIR%\venv"
set "ProgramFiles=C:\Program Files"
set "ARCH=64"
set "CONFIG=ReleaseFS_open"
set "OUTPUT_DIR=%BUILD_DIR%\output"
set "AUTO_BUILD_CONFIG=%BUILD_DIR%\phoenix-firestorm\autobuild.xml"
set "AUTOBUILD_VARIABLES_FILE=%BUILD_DIR%\fs-build-variables\variables"

set "7ZIP_PATH=%ProgramFiles%\7-Zip\7z.exe"

echo %GREEN%Erstelle Build-Verzeichnis%RESET%
mkdir "%BUILD_DIR%" 2>nul

:: Tools installieren
@REM echo %GREEN%3. Installiere Build-Tools%RESET%
@REM choco install -y --no-progress --stop-on-first-failure ^
@REM     python

echo %GREEN%Python-Virtualenv einrichten%RESET%
if not exist "%VENV_DIR%" (
    python -m venv "%VENV_DIR%"
    call "%VENV_DIR%\Scripts\activate.bat"
    python -m pip install --upgrade pip
    python -m pip install --force-reinstall --no-cache-dir llbase llsd autobuild

    echo %GREEN%[ERFOLG] Virtualenv wurde erstellt.%RESET%
) else (
    call "%VENV_DIR%\Scripts\activate.bat"
    echo %GREEN%[INFO] Virtualenv existiert bereits.%RESET%
)

:: Quellcode holen für Phoenix-Firestorm und Build-Variablen

echo %GREEN%Quellcode holen%RESET%
if not exist "%BUILD_DIR%\phoenix-firestorm" (
    git clone "https://github.com/FirestormViewer/phoenix-firestorm.git" "%BUILD_DIR%\phoenix-firestorm"
)
if not exist "%BUILD_DIR%\fs-build-variables" (
    git clone "https://github.com/FirestormViewer/fs-build-variables.git" "%BUILD_DIR%\fs-build-variables"
)

:: Build-Variablen setzen

echo %GREEN%Build-Variablen setzen%RESET%
set "AUTOBUILD_VSVER=170"
set "AUTOBUILD_VARIABLES_FILE=%BUILD_DIR%\fs-build-variables\variables"

echo %GREEN%5. Python-Abhängigkeiten installieren%RESET%
python -m pip install -r "%BUILD_DIR%\phoenix-firestorm\requirements.txt"

:: OpenAL in autobuild.xml ändern
echo %GREEN%5. Ändere OpenAL in autobuild.xml%RESET%

echo %GREEN%Ersetze autobuild.xml mit OpenAL Version%RESET%
if exist "%BUILD_DIR%\phoenix-firestorm\autobuild.xml" (
    ren "%BUILD_DIR%\phoenix-firestorm\autobuild.xml" "old_autobuild.xml"
    echo %GREEN%[INFO] Vorhandene autobuild.xml wurde in old_autobuild.xml umbenannt.%RESET%
)

if exist "%BUILD_DIR%\..\openal_autobuild.xml" (
    copy "%BUILD_DIR%\..\openal_autobuild.xml" "%BUILD_DIR%\phoenix-firestorm\autobuild.xml"
    echo %GREEN%[ERFOLG] openal_autobuild.xml wurde als autobuild.xml kopiert.%RESET%
) else (
    echo %RED%[FEHLER] openal_autobuild.xml nicht gefunden in %BUILD_DIR%\..\%RESET%
)

:: autobuild.xml ENDE

echo %BLUE%=== Firestorm Viewer Build gestartet ===%RESET%

:: === VS Umgebung aktivieren ===

echo %YELLOW%[VS] Lade Visual Studio Umgebung...%RESET%
set "VS2022BAT="
for %%D in ("C:\Program Files\Microsoft Visual Studio\2022\Community") do (
    if exist "%%~D\VC\Auxiliary\Build\vcvarsall.bat" (
        set "VS2022BAT=%%~D\VC\Auxiliary\Build\vcvarsall.bat"
    )
)

if not defined VS2022BAT (
    echo %RED%[FEHLER] Visual Studio 2022 Build Tools nicht gefunden!%RESET%
    pause & exit /b 1
)

call "%VS2022BAT%" x64
if errorlevel 1 (
    echo %RED%[FEHLER] vcvarsall.bat konnte nicht ausgeführt werden.%RESET%
    pause & exit /b 1
)
echo %GREEN%  • Erfolg: VS Umgebung geladen%RESET%

:: === Python-Virtualenv aktivieren ===

echo %YELLOW%[PYTHON] Aktiviere virtuelle Umgebung...%RESET%
if exist "%VENV_DIR%\Scripts\activate.bat" (
    call "%VENV_DIR%\Scripts\activate.bat"
    echo %GREEN%  • Python-Umgebung aktiviert%RESET%
) else (
    echo %RED%[FEHLER] Python-Virtualenv fehlt: %VENV_DIR%%RESET%
    pause & exit /b 1
)

:: === Build-Konfiguration prüfen ===

echo %YELLOW%[CHECK] Überprüfe autobuild.xml...%RESET%
if not exist "%AUTO_BUILD_CONFIG%" (
    echo %RED%[FEHLER] autobuild.xml fehlt!%RESET%
    pause & exit /b 1
)
echo %GREEN%  • autobuild.xml gefunden%RESET%

:: === In Quellverzeichnis wechseln ===
cd /d "%BUILD_DIR%\phoenix-firestorm" || (
    echo %RED%[FEHLER] Quellverzeichnis nicht gefunden!%RESET%
    pause & exit /b 1
)

:: ###########################
:: # BUILD-PROZESS
:: ###########################

:: === Konfiguration ===

echo %BLUE%=== Konfiguriere Firestorm Viewer ===%RESET%
::autobuild configure --config-file "%AUTO_BUILD_CONFIG%" -A %ARCH% -c %CONFIG%  -- --package --chan CustomBuild -DLL_TESTS:BOOL=FALSE -DFMOD:BOOL=OFF -DUSE_OPENAL:BOOL=TRUE
autobuild configure --config-file "%AUTO_BUILD_CONFIG%" -A %ARCH% -c %CONFIG%  -- --package --chan CustomBuild -DLL_TESTS:BOOL=FALSE -DFMOD:BOOL=OFF -DUSE_OPENAL:BOOL=TRUE

if errorlevel 1 (
    echo %RED%[FEHLER] autobuild configure fehlgeschlagen!%RESET%
    pause & exit /b 1
)
echo %GREEN%  • Erfolg: Konfiguration abgeschlossen%RESET%

:: === Build durchführen ===

echo %GREEN%Build durchführen%RESET%
:: autobuild build --config-file "%AUTO_BUILD_CONFIG%" -A %ARCH% -c %CONFIG% --no-configure
autobuild build --config-file "%AUTO_BUILD_CONFIG%" -A %ARCH% -c %CONFIG% --no-configure --verbose
:: autobuild build --config-file "%AUTO_BUILD_CONFIG%" -A %ARCH% -c %CONFIG% --no-configure  --quiet
:: autobuild build --config-file "%AUTO_BUILD_CONFIG%" -A %ARCH% -c %CONFIG% --no-configure  --quiet 2>&1 | findstr /I "error fatal undefined"

if errorlevel 1 (
    echo %RED%[FEHLER] Build fehlgeschlagen!%RESET%
    pause & exit /b 1
)
echo %GREEN%  • Erfolg: Build abgeschlossen%RESET%

:: === Paketierung ===
echo %BLUE%=== Portable Version erzeugen ===%RESET%
if exist "%7ZIP_PATH%" (
    mkdir "%OUTPUT_DIR%" 2>nul
    "%7ZIP_PATH%" a -tzip "%OUTPUT_DIR%\Firestorm-Portable.zip" "%OUTPUT_DIR%\Firestorm*"
    echo %GREEN%  • Erfolg: ZIP erstellt%RESET%
) else (
    echo %YELLOW%  • Warnung: 7-Zip nicht gefunden%RESET%
)

:: === Abschluss ===
echo %BLUE%=== Build abgeschlossen ===%RESET%
echo %GREEN%Ergebnis liegt in: %OUTPUT_DIR%%RESET%
dir /b "%OUTPUT_DIR%"
pause
