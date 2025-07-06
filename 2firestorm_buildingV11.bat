@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: ##### 1. **Einleitung und Hinweise** #####

:: ##### Dies ist die Datei 2firestorm_buildV5.bat
:: ##### Teil des Firestorm Viewer Build-Prozesses
:: ##### Version 5.0
:: ##### by Manfred Aabye
:: ##### Stand: 30.06.2025



:: ##### 2. **Farbdefinition für Konsolenausgabe**
:: ##### - Setzt ANSI-Farbcodes für farbige Statusmeldungen im Terminal

for /f %%a in ('echo prompt $E ^| cmd') do set "ESC=%%a"
set "GREEN=%ESC%[32m"
set "RED=%ESC%[31m"
set "YELLOW=%ESC%[33m"
set "BLUE=%ESC%[34m"
set "RESET=%ESC%[0m"

echo %GREEN%Firestorm Build-Vorbereitung%RESET%

:: ##### 3. **Grundkonfiguration und Variablen**
:: #####    - Definition von Skriptpfad, Zielordnern, Konfigurationsparametern (z. B. `%SCRIPT_DIR%`, `%BUILD_DIR%`, `%CONFIG%`)

echo %GREEN%Konfiguration...%RESET%

:: ##### 3. Konfiguration (mit DRYBUILD-Option) #####
set "DRYBUILD=OFF"

:: Kein link.exe von Github nutzen
set "SCRIPT_DIR=%~dp0"
set "PATH=%PATH:C:\Program Files\Git\usr\bin;=%"
set "PYTHON_VERSION=3.10.11"
set "BUILD_DIR=%SCRIPT_DIR%Firestorm_Build"
set "VENV_DIR=%BUILD_DIR%\venv"
set "ProgramFiles=C:\Program Files"
:: Neu 04.07.2025 D:\01072025Firestorm\Firestorm_Build\phoenix-firestorm\build-vc170-64\packages
set "AUTOBUILD_INSTALL_DIR=%BUILD_DIR%\packages"

set "ARCH=64"
set "CONFIG=ReleaseFS_open"
set "OUTPUT_DIR=%BUILD_DIR%\phoenix-firestorm\build-vc170-64\newview\Release"
set "AUTO_BUILD_CONFIG=%BUILD_DIR%\phoenix-firestorm\autobuild.xml"
set "AUTOBUILD_VARIABLES_FILE=%BUILD_DIR%\fs-build-variables\variables"
:: ##### TEMP-UMLEITUNG #####
echo %GREEN%TEMP-UMLEITUNG...%RESET%
set "AUTOBUILD_TEMP=%SCRIPT_DIR%temp"
if not exist "%AUTOBUILD_TEMP%" mkdir "%AUTOBUILD_TEMP%"
set "TMP=%AUTOBUILD_TEMP%"
set "TEMP=%AUTOBUILD_TEMP%"

:: 1. fs_include ins Build-Verzeichnis kopieren
set "FS_INCLUDE_SOURCE=%SCRIPT_DIR%\fs_include"

:: set "AUTOBUILD_BUILD_ID=0123456789"

:: ##### 4. **Erstellung des Arbeitsverzeichnisses**
:: #####    - Legt den Build-Ordner an (sofern nicht vorhanden)

echo %GREEN%Erstelle Build-Verzeichnis%RESET%
mkdir "%BUILD_DIR%" 2>nul

:: ##### 5. **Einrichtung der Python-Virtualenv**
:: #####    - Erstellt virtuelle Umgebung und installiert benötigte Python-Module (`autobuild`, `llbase`, `llsd`)

if not exist "%VENV_DIR%" (
    python -m venv "%VENV_DIR%"
    call "%VENV_DIR%\Scripts\activate.bat"
    python -m pip install --upgrade pip
    python -m pip install --force-reinstall --no-cache-dir llbase llsd autobuild
    echo %GREEN%[INFO] Virtualenv wurde erstellt.%RESET%
) else (
    call "%VENV_DIR%\Scripts\activate.bat"
    echo %GREEN%[INFO] Virtualenv existiert bereits.%RESET%
)




:: ##### 6. **Klonen der Quellverzeichnisse**
:: ##### 6. Repository-Klonung auslagern #####
call "%SCRIPT_DIR%\x_clone_repositories.bat" "%SCRIPT_DIR%" "%BUILD_DIR%"
if errorlevel 1 (
    echo %RED%Fehler beim Klonen/Kopieren der Repositories%RESET%
    exit /b 1
)

:: ##### Git-Build-ID Abfrage
set "AUTOBUILD_BUILD_ID=78713"

cd /d "D:\01072025Firestorm\Firestorm_Build\phoenix-firestorm" 2>nul && (
    for /f "tokens=4 delims=_-" %%a in ('git describe --tags --long 2^>nul') do (
        set "AUTOBUILD_BUILD_ID=%%a"
    )
    cd /d %SCRIPT_DIR%
)

echo %GREEN%Build-ID ist: %AUTOBUILD_BUILD_ID%%RESET%

:: ##### 7. **Build-Variablen und Anforderungen installieren**
:: #####    - Setzt Version, Architektur, lädt `requirements.txt`

echo %GREEN%Anforderungen installieren...%RESET%

set "AUTOBUILD_VSVER=170"
python -m pip install -r "%BUILD_DIR%\phoenix-firestorm\requirements.txt"





:: ##### 8. **Anpassung von autobuild.xml**
:: #####    - Ersetzt Originaldatei durch `openal_autobuild.xml` zur Sound-Anpassung

echo %GREEN%Anpassung von autobuild.xml durch kopieren...%RESET%

:: TODO: Neuer Kopierpfad von fs_include
copy /Y "%FS_INCLUDE_SOURCE%\autobuild.xml" "%BUILD_DIR%\phoenix-firestorm\autobuild.xml"

:: ##### 9. **Aktivierung der Visual-Studio-Umgebung**
:: #####    - Lädt `vcvarsall.bat` für das 64-Bit-Toolset von Visual Studio 2022

echo %GREEN%Aktivierung der Visual-Studio-Umgebung...%RESET%

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

:: ##### 10. **Aktivierung der Python-Umgebung**
:: #####     - (Erneut) Aktiviert Virtualenv für Folgeaktionen

echo %GREEN%Aktivierung der Python-Umgebung...%RESET%

if exist "%VENV_DIR%\Scripts\activate.bat" (
    call "%VENV_DIR%\Scripts\activate.bat"
) else (
    echo %RED%[FEHLER] Python-Virtualenv fehlt: %VENV_DIR%%RESET%
    pause
    exit /b 1
)

:: ##### 11. **Prüfung der Build-Konfigurationsdatei**
:: #####     - Validiert, ob `autobuild.xml` vorhanden ist

echo %GREEN%Prüfung der Build-Konfigurationsdatei...%RESET%

if not exist "%AUTO_BUILD_CONFIG%" (
    echo %RED%[FEHLER] autobuild.xml fehlt!%RESET%
    pause
    exit /b 1
)
:: Assimp eingefügt am 04.07.2025
@REM echo %GREEN%[assimp 2/3] Installiere assimp...%RESET%
@REM if not exist "%AUTOBUILD_INSTALL_DIR%" mkdir "%AUTOBUILD_INSTALL_DIR%"
@REM autobuild install --install-dir="%AUTOBUILD_INSTALL_DIR%" --config-file "%AUTO_BUILD_CONFIG%" assimp -A 64 --platform windows64

@REM echo %GREEN%[assimp 2/2] Prüfe assimp-Installation...%RESET%
@REM if not exist "%AUTOBUILD_INSTALL_DIR%\include\assimp\config.h" (
@REM     echo %RED%[FEHLER] assimp-Header nicht gefunden in %AUTOBUILD_INSTALL_DIR%\include\assimp\%RESET%
@REM     exit /b 1
@REM )
@REM echo %YELLOW%Assimp wird installiert nach: %AUTOBUILD_INSTALL_DIR%%RESET%





:: ##### 12. **Wechsel ins Quellverzeichnis**
:: #####     - Setzt aktuelles Arbeitsverzeichnis auf `phoenix-firestorm`

echo %GREEN%Wechsel ins Quellverzeichnis...%RESET%

cd /d "%BUILD_DIR%\phoenix-firestorm" || (
    echo %RED%[FEHLER] Quellverzeichnis nicht gefunden!%RESET%
    pause
    exit /b 1
)


:: ##### 13. OpenAL DLLs bereitstellen vor dem Build
echo %GREEN%Kopiere OpenAL DLLs in sharedlibs...%RESET%

:: Verzeichnis prüfen
if exist "%BUILD_DIR%\phoenix-firestorm\build-vc170-64\sharedlibs\Release\" (
    echo Verzeichnis phoenix-firestorm\build-vc170-64\sharedlibs\Release existiert
) else (
    echo Verzeichnis phoenix-firestorm\build-vc170-64\sharedlibs\Release existiert NICHT
)
if exist "%BUILD_DIR%\phoenix-firestorm\build-vc170-64\newview\Release" (
    echo Verzeichnis phoenix-firestorm\build-vc170-64\newview\Release existiert
) else (
    echo Verzeichnis phoenix-firestorm\build-vc170-64\newview\Release existiert NICHT
)

:: TODO: Neuer Kopierpfad von fs_include
:: sharedlibs
copy /Y "%FS_INCLUDE_SOURCE%\OpenAL32.dll" "%BUILD_DIR%\phoenix-firestorm\build-vc170-64\sharedlibs\Release" >nul
copy /Y "%FS_INCLUDE_SOURCE%\alut.dll"     "%BUILD_DIR%\phoenix-firestorm\build-vc170-64\sharedlibs\Release" >nul
:: newview
copy /Y "%FS_INCLUDE_SOURCE%\OpenAL32.dll" "%BUILD_DIR%\phoenix-firestorm\build-vc170-64\newview\Release" >nul
copy /Y "%FS_INCLUDE_SOURCE%\alut.dll"     "%BUILD_DIR%\phoenix-firestorm\build-vc170-64\newview\Release" >nul


:: ##### 14. **Konfiguration des Builds**
:: #####     - Führt `autobuild configure` mit Flags für Channel, Paketierung, Audiooptionen aus

echo %GREEN%Konfiguration...%RESET%
:: Assimp angehängt am 04.07.2025
::autobuild configure --config-file "%AUTO_BUILD_CONFIG%" -A 64 -c ReleaseFS_open -- --package --chan WebRTC -DLL_TESTS:BOOL=FALSE -DFMOD:BOOL=OFF -DUSE_OPENAL:BOOL=TRUE -DUSE_ASSIMP:BOOL=ON
@REM autobuild configure --config-file "%AUTO_BUILD_CONFIG%" -A 64 -c ReleaseFS_open -- --package --chan WebRTC -DLL_TESTS:BOOL=FALSE -DFMOD:BOOL=OFF -DUSE_OPENAL:BOOL=TRUE
@REM if errorlevel 1 (
@REM     echo %RED%[FEHLER] Konfiguration fehlgeschlagen!%RESET%
@REM     pause
@REM     exit /b 1
@REM )

:: ##### 14. Build-Konfiguration (mit DRYBUILD-Option) #####
:: --id %AUTOBUILD_BUILD_ID%
if /i "%DRYBUILD%"=="ON" (
    echo %YELLOW%[DRYBUILD] Überspringe autobuild Configure%RESET%
) else (
    echo %GREEN%Führe autobuild Configure aus...%RESET%
    autobuild configure --config-file "%AUTO_BUILD_CONFIG%" -A 64 -c ReleaseFS_open --id %AUTOBUILD_BUILD_ID% -- --package --chan WebRTC -DLL_TESTS:BOOL=FALSE -DFMOD:BOOL=OFF -DUSE_OPENAL:BOOL=TRUE
    if errorlevel 1 (
        echo %RED%[FEHLER] Konfiguration fehlgeschlagen!%RESET%
        exit /b 1
    )
)

:: ##### 15. **Durchführung des Builds**
:: #####     - Kompiliert den Viewer mit `autobuild build`

@REM echo %GREEN%Build...%RESET%

@REM autobuild build --config-file "%AUTO_BUILD_CONFIG%" -A 64 -c ReleaseFS_open --no-configure --verbose
@REM if errorlevel 1 (
@REM     echo %RED%[FEHLER] Build fehlgeschlagen!%RESET%
@REM     pause
@REM     exit /b 1
@REM )
:: ##### 15. Build-Durchführung (mit DRYBUILD-Option) #####
echo %GREEN%Build...%RESET%

if /i "%DRYBUILD%"=="ON" (
    echo %YELLOW%[DRYBUILD] Überspringe autobuild Build%RESET%
    echo %YELLOW%[DRYBUILD] Simuliere erfolgreichen Build%RESET%
) else (
    echo %GREEN%Starte autobuild Build...%RESET%
    autobuild build --config-file "%AUTO_BUILD_CONFIG%" -A 64 -c ReleaseFS_open --no-configure --verbose
    if errorlevel 1 (
        echo %RED%[FEHLER] Build fehlgeschlagen!%RESET%
        pause
        exit /b 1
    )
    echo %GREEN%[ERFOLG] Build abgeschlossen%RESET%
)






@REM :: ##### 16. **Ermittlung des Release-Verzeichnisses**
@REM :: #####     - Findet das konkrete `Release`-Verzeichnis mit dem gebauten Viewer

@REM echo %GREEN%Suche nach Release-Verzeichnis...%RESET%

@REM if not exist "%SCRIPT_DIR%Firestorm_Build\phoenix-firestorm\build-vc170-64\newview\Release" (
@REM     echo %RED%[FEHLER] Release-Verzeichnis nicht gefunden: %SCRIPT_DIR%Firestorm_Build\phoenix-firestorm\build-vc170-64\newview\Release%RESET%
@REM     ::pause
@REM     ::exit /b 1
@REM )
@REM echo %GREEN%• Release-Verzeichnis gefunden: %SCRIPT_DIR%Firestorm_Build\phoenix-firestorm\build-vc170-64\newview\Release%RESET%






:: ##### 17. **Erstellung des NSIS-Installers**
:: #####     - Führt `makensis.exe` mit der `.nsi`-Installerskriptdatei aus

echo %GREEN%Erstelle NSIS-Installer...%RESET%
@REM echo DLLs werden in die Package kopiert.

@REM :: TODO: Neuer Kopierpfad von fs_include
@REM if not exist "%SCRIPT_DIR%Firestorm_Build\phoenix-firestorm\build-vc170-64\newview\Release" (
@REM     echo %GREEN%Kopiere DLLs in das Release-Verzeichnis...%RESET%
@REM     xcopy /Y "%FS_INCLUDE_SOURCE%\alut.dll %SCRIPT_DIR%Firestorm_Build\phoenix-firestorm\build-vc170-64\newview\Release
@REM     xcopy /Y "%FS_INCLUDE_SOURCE%\OpenAL32.dll %SCRIPT_DIR%Firestorm_Build\phoenix-firestorm\build-vc170-64\newview\Release
@REM     autobuild package -A 64 --config-file autobuild.xml
@REM ) else (
@REM     echo %RED%[FEHLER] Release-Verzeichnis fehlt.%RESET%
@REM )

:: ##### 17. NSIS-Installer #####
set "RELEASE_DIR=%SCRIPT_DIR%Firestorm_Build\phoenix-firestorm\build-vc170-64\newview\Release"

if not exist "%RELEASE_DIR%" (
    echo Kein Build-Verzeichnis gefunden, überspringe Paketerstellung.
) else (
    echo %GREEN%Erstelle Installer-Paket...%RESET%
    echo Kopiere benötigte DLLs...
    xcopy /Y "%FS_INCLUDE_SOURCE%\alut.dll" "%RELEASE_DIR%\" >nul && echo - alut.dll kopiert
    xcopy /Y "%FS_INCLUDE_SOURCE%\OpenAL32.dll" "%RELEASE_DIR%\" >nul && echo - OpenAL32.dll kopiert
    
    autobuild package -A 64 --config-file autobuild.xml
    if errorlevel 1 (
        echo %RED%Fehler bei der Paketerstellung!%RESET%
    ) else (
        echo %GREEN%Paket erfolgreich erstellt.%RESET%
    )
)





:: ##### 18. Konfigurationsdatei-Ausgabe #####
set "RELEASE_DIR=%SCRIPT_DIR%Firestorm_Build\phoenix-firestorm\build-vc170-64\newview\Release"

if not exist "%RELEASE_DIR%" (
    echo Kein Build-Verzeichnis gefunden, überspringe Konfigurationsausgabe.
) else (
    echo %GREEN%Erstelle Konfigurationsdatei...%RESET%
    
    :: JSON-Ausgabe
    autobuild print --json my-config-file.json >nul 2>&1 && (
        echo - Konfiguration als JSON gespeichert: my-config-file.json
    ) || (
        echo %YELLOW%Warnung: JSON-Konfiguration konnte nicht erstellt werden%RESET%
    )
    
    :: XML-Ausgabe (falls benötigt)
    :: autobuild print --config-file my-config-file.xml >nul 2>&1
)

:: ##### 19. **Zusammenfassung und Ergebnisanzeige**
:: #####     - Zeigt den Inhalt des Release-Verzeichnisses im Terminal und beendet das Skript

::echo %GREEN%✔ Paketierung abgeschlossen%RESET%
echo %BLUE%   Inhalt des Release-Verzeichnisses:%RESET%
@REM dir /b "%SCRIPT_DIR%Firestorm_Build\phoenix-firestorm\build-vc170-64\newview\Release"

:: Prüfe Release-Verzeichnis
set "RELEASE_DIR=%SCRIPT_DIR%Firestorm_Build\phoenix-firestorm\build-vc170-64\newview\Release"

if not exist "%RELEASE_DIR%" (
    echo Verzeichnis existiert nicht: %RELEASE_DIR%
    exit /b 1
)

echo Verzeichnisinhalt:
dir /b "%RELEASE_DIR%"


pause
exit /b 1