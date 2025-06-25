@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: OK Manfred Aabye 25.06.2025 Version 3.3
REM 3firestorm_compiler.bat - Führt den Firestorm Build-Prozess durch

:: === ANSI-Farben für Ausgabe ===
for /f %%a in ('echo prompt $E ^| cmd') do set "ESC=%%a"
set "GREEN=%ESC%[32m"
set "RED=%ESC%[31m"
set "RESET=%ESC%[0m"

echo %GREEN%=== Firestorm Build ===%RESET%

:: === Konfiguration ===
set "SCRIPT_DIR=%~dp0"
set "BUILD_DIR=%SCRIPT_DIR%Firestorm_Build"
set "VENV_DIR=%BUILD_DIR%\venv"
set "ARCH=64"
set "CONFIG=ReleaseFS_open"
set "OUTPUT_DIR=%BUILD_DIR%\output"
set "7ZIP_PATH=%ProgramFiles%\7-Zip\7z.exe"

:: Pfad zur autobuild.xml setzen
set "AUTO_BUILD_CONFIG=%BUILD_DIR%\phoenix-firestorm\autobuild.xml"
if not exist "%AUTO_BUILD_CONFIG%" (
    echo %RED%[FEHLER] autobuild.xml nicht gefunden: %AUTO_BUILD_CONFIG%%RESET%
    pause
    exit /b 1
)

:: === 1. Umgebung aktivieren ===
echo %GREEN%1. Umgebung aktivieren%RESET%
call "%VENV_DIR%\Scripts\activate.bat"
@REM call "C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\VC\Auxiliary\Build\vcvarsamd64_x86.bat"
@REM call "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat"
@REM call "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvarsall.bat" x64
:: Versuche, Visual Studio 2022 Community vcvarsall.bat zu finden
set "VS2022BAT="
for %%D in ("C:\Program Files\Microsoft Visual Studio\2022\Community") do (
    if exist "%%~D\VC\Auxiliary\Build\vcvarsall.bat" (
        set "VS2022BAT=%%~D\VC\Auxiliary\Build\vcvarsall.bat"
    )
)

if not defined VS2022BAT (
    echo %RED%[FEHLER] Visual Studio 2022 Build Tools nicht gefunden!%RESET%
    pause
    exit /b 1
)

call "%VS2022BAT%" x64
:: ############################### Umgebung aktivieren ################################################


:: === 2. Build konfigurieren ===
echo %GREEN%2. Build konfigurieren%RESET%
cd "%BUILD_DIR%\phoenix-firestorm"

:: Variablen-Datei explizit setzen
set "AUTOBUILD_VARIABLES_FILE=%BUILD_DIR%\fs-build-variables\variables"

:: Korrekte Platzierung von --config-file vor dem Doppelstrich
autobuild configure --config-file "%AUTO_BUILD_CONFIG%" -A %ARCH% -c %CONFIG% -- --package --chan CustomBuild -DLL_TESTS:BOOL=FALSE

if errorlevel 1 (
    echo %RED%[FEHLER] Autobuild configure fehlgeschlagen!%RESET%
    pause
    exit /b 1
)

:: === 3. Build durchführen ===
echo %GREEN%3. Build durchführen%RESET%
:: autobuild build --config-file "%AUTO_BUILD_CONFIG%" -A %ARCH% -c %CONFIG% --no-configure
autobuild build --config-file "%AUTO_BUILD_CONFIG%" -A %ARCH% -c %CONFIG% --no-configure --verbose


if errorlevel 1 (
    echo %RED%[FEHLER] Build fehlgeschlagen!%RESET%
    pause
    exit /b 1
)

:: === 4. Paket-Erstellung vorbereiten (optional) ===
:: echo %GREEN%4. Paket erstellen%RESET%
:: mkdir "%OUTPUT_DIR%" 2>nul
:: autobuild package --config-file "%AUTO_BUILD_CONFIG%" -A %ARCH% -c %CONFIG% -- --output="%OUTPUT_DIR%"

:: === 5. Portable Version mit 7-Zip erzeugen ===
echo %GREEN%5. Portable Version erstellen (7-Zip)%RESET%
if exist "%7ZIP_PATH%" (
    mkdir "%OUTPUT_DIR%" 2>nul
    "%7ZIP_PATH%" a -tzip "%OUTPUT_DIR%\Firestorm-Portable.zip" "%OUTPUT_DIR%\Firestorm*"
    echo %GREEN%[ERFOLG] Portable Version wurde erstellt.%RESET%
) else (
    echo %RED%[WARNUNG] 7-Zip nicht gefunden, Portable Version wurde nicht erstellt.%RESET%
)

echo %GREEN%=== Build abgeschlossen ===%RESET%
echo %GREEN%Output-Verzeichnis: %OUTPUT_DIR%%RESET%
dir /b "%OUTPUT_DIR%"
pause
