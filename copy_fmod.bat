@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: kopiere_fmod.bat Firestorm Windows FMOD Script by Manfred Aabye V 1.0.2
:: -----------------------------------------------------
:: This script automates the build process for the Firestorm Viewer on Windows.
:: It installs necessary dependencies, configures the environment, and builds the viewer.
:: https://github.com/FirestormViewer/phoenix-firestorm/blob/master/doc/building_windows.md

echo [INFO] Versuche, den FMOD-API-Pfad automatisch zu finden...

:: Kandidaten für mögliche Installationspfade
set "CHECK1=C:\Program Files\FMODStudioAPI\api"
set "CHECK2=%USERPROFILE%\FMOD\api"
set "CHECK3=%~d0FMOD\api"
set "CHECK4=D:\FMOD\extracted\api"  :: Optional: dein bekannter Installationspfad

:: Prüfung in Reihenfolge
set "FMOD_SRC="

for %%P in ("%CHECK1%" "%CHECK2%" "%CHECK3%" "%CHECK4%") do (
    if exist "%%~P\core\lib\x64\fmod.dll" (
        set "FMOD_SRC=%%~P"
        echo [GEFUNDEN] Automatischer FMOD-Pfad: !FMOD_SRC!
        goto :FoundFMOD
    )
)

:: Wenn nichts gefunden wurde, nachfragen
echo [WARNUNG] Kein FMOD-API-Verzeichnis automatisch gefunden.
set /p FMOD_SRC=Bitte geben Sie den Pfad zum "api"-Ordner an (z. B. D:\FMOD\extracted\api): 

:FoundFMOD
:: Prüfung, ob Pfad gültig ist
if not exist "!FMOD_SRC!\core\lib\x64\fmod.dll" (
    echo [FEHLER] Ungültiger Pfad oder fehlende Dateien: !FMOD_SRC!
    pause
    exit /b 1
)

:: Zielverzeichnis definieren
set "SCRIPT_DIR=%~dp0"
set "DEST_DIR=%SCRIPT_DIR%fmod_prepared"

:: Zielstruktur anlegen
mkdir "%DEST_DIR%\include\fmod" >nul 2>&1
mkdir "%DEST_DIR%\lib\release" >nul 2>&1

:: Dateien kopieren
echo [INFO] Kopiere Header-Dateien...
copy "!FMOD_SRC!\core\inc\*.h" "%DEST_DIR%\include\fmod\" >nul
copy "!FMOD_SRC!\studio\inc\*.h" "%DEST_DIR%\include\fmod\" >nul

echo [INFO] Kopiere DLLs...
copy "!FMOD_SRC!\core\lib\x64\fmod.dll" "%DEST_DIR%\lib\release\" >nul
copy "!FMOD_SRC!\studio\lib\x64\fmodstudio.dll" "%DEST_DIR%\lib\release\" >nul

echo [INFO] Kopiere .lib-Dateien...
copy "!FMOD_SRC!\core\lib\x64\fmod_vc.lib" "%DEST_DIR%\lib\release\" >nul
copy "!FMOD_SRC!\studio\lib\x64\fmodstudio_vc.lib" "%DEST_DIR%\lib\release\" >nul

:: FMOD lokal registrieren, falls Paket vorhanden
if exist "%SCRIPT_DIR%fmodstudio-2.02.05-windows64.tar.bz2" (
    echo [INFO] FMOD-Paketdatei gefunden – wird bei Autobuild registriert...

    :: MD5-Hash auslesen
    for /f "tokens=1" %%h in ('certutil -hashfile "%SCRIPT_DIR%fmodstudio-2.02.05-windows64.tar.bz2" MD5 ^| find /i /v "hash" ^| find /i /v ":"') do set FMOD_HASH=%%h

    :: FMOD bei Autobuild registrieren
    autobuild installables edit fmodstudio platform=windows64 hash=!FMOD_HASH! url=file:///%SCRIPT_DIR:f:\=F:/%fmodstudio-2.02.05-windows64.tar.bz2
)

echo.
echo [SUCCESS] FMOD-Dateien wurden erfolgreich vorbereitet in:
echo           %DEST_DIR%
pause
