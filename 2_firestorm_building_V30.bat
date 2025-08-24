@echo off
:: Schaltet die Anzeige der Befehle im Konsolenfenster aus, damit die Ausgabe übersichtlich bleibt.

chcp 65001 >nul
:: Setzt die Codepage auf UTF-8, damit Sonderzeichen korrekt dargestellt werden.

setlocal enabledelayedexpansion
:: Aktiviert verzögerte Variablienerweiterung, nützlich für komplexere Batch-Operationen.

:: ##### 1. **Einleitung und Hinweise** #####
:: Diese Batchdatei automatisiert den Build-Prozess für den Firestorm Viewer.
:: Sie legt alle benötigten Variablen, Umgebungen und Verzeichnisse an und führt die einzelnen Build-Schritte aus.
:: Version 2025.08.21, Stand: 21.08.2025, by Manfred Aabye

:: ##### 2. **Farbdefinition für Konsolenausgabe**
:: Setzt ANSI-Farbcodes für farbige Statusmeldungen im Terminal (funktioniert nur in unterstützten Konsolen)
for /f %%a in ('echo prompt $E ^| cmd') do set ESC=%%a
set GREEN=%ESC%[32m
set RED=%ESC%[31m
set YELLOW=%ESC%[33m
set BLUE=%ESC%[34m
set CYAN=%ESC%[36m
set BRIGHT_CYAN=%ESC%[96m
set RESET=%ESC%[0m

:: Überschrift für die Build-Vorbereitung
echo %GREEN%Firestorm Build-Vorbereitung%RESET%

echo %CYAN%──────────────────────────────────────────────────────────────────────────────────%RESET%
:: ##### 3. **Grundkonfiguration und Variablen**
:: Definition von Skriptpfad, Zielordnern, Konfigurationsparametern
echo %GREEN%Konfiguration...%RESET%

:: Kein link.exe von Github nutzen (Git überschreibt manchmal Windows-Tools)
set "SCRIPT_DIR=%~dp0"  :: Pfad zu diesem Skript
set "PATH=%PATH:C:\Program Files\Git\usr\bin;=%"  :: Entfernt Git's Unix-Tools aus dem PATH
set "PYTHON_VERSION=3.10.11"  :: Gewünschte Python-Version
set "BUILD_DIR=%SCRIPT_DIR%Firestorm_Build"  :: Zielverzeichnis für den Build
set "VENV_DIR=%BUILD_DIR%\venv"  :: Virtuelle Python-Umgebung
set "ProgramFiles=C:\Program Files"  :: Standard-Programmpfad
set "AUTOBUILD_INSTALL_DIR=%BUILD_DIR%\packages"  :: Installationsverzeichnis für Autobuild-Pakete

set "ARCH=64"  :: Architektur
set "CONFIG=ReleaseFS_open"  :: Build-Konfiguration
set "OUTPUT_DIR=%BUILD_DIR%\phoenix-firestorm\build-vc170-64\newview\Release"  :: Release-Ausgabeverzeichnis
set "AUTO_BUILD_CONFIG=%BUILD_DIR%\phoenix-firestorm\autobuild.xml"  :: Pfad zur Build-Konfigurationsdatei
set "AUTOBUILD_VARIABLES_FILE=%BUILD_DIR%\fs-build-variables\variables"  :: Build-Variablen

:: ##### TEMP-UMLEITUNG #####
echo %GREEN%TEMP-UMLEITUNG...%RESET%
set "AUTOBUILD_TEMP=%SCRIPT_DIR%temp"  :: Temporäres Arbeitsverzeichnis
if not exist "%AUTOBUILD_TEMP%" mkdir "%AUTOBUILD_TEMP%"
:: Erstellt das TEMP-Verzeichnis, falls nicht vorhanden
set "TMP=%AUTOBUILD_TEMP%"
set "TEMP=%AUTOBUILD_TEMP%"

:: 1. fs_include ins Build-Verzeichnis kopieren
set "FS_INCLUDE_SOURCE=%SCRIPT_DIR%\fs_include"
set "FS_INCLUDE_DEST=%BUILD_DIR%\fs_include"

echo %CYAN%──────────────────────────────────────────────────────────────────────────────────%RESET%
:: ##### 4. **Erstellung des Arbeitsverzeichnisses**
:: #####    - Legt den Build-Ordner an (sofern nicht vorhanden)
echo %GREEN%Erstelle Build-Verzeichnis%RESET%

mkdir "%BUILD_DIR%" 2>nul

echo %CYAN%──────────────────────────────────────────────────────────────────────────────────%RESET%
:: ##### 5. **Einrichtung der Python-Virtualenv**
:: #####    - Erstellt virtuelle Umgebung und installiert benötigte Python-Module (`autobuild`, `llbase`, `llsd`)
echo %GREEN%[INFO] Erstelle virtuelle Umgebung...%RESET%

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

:: 1. fs_include ins Build-Verzeichnis kopieren
set "FS_INCLUDE_SOURCE=%SCRIPT_DIR%\fs_include"
set "FS_INCLUDE_DEST=%BUILD_DIR%\fs_include"

if exist "%FS_INCLUDE_SOURCE%" (
    echo %GREEN%Kopiere fs_include in das Build-Verzeichnis...%RESET%
    xcopy /E /I /Y "%FS_INCLUDE_SOURCE%" "%FS_INCLUDE_DEST%\" >nul
) else (
    echo %RED%[FEHLER] fs_include nicht gefunden in: %FS_INCLUDE_SOURCE%%RESET%
    exit /b 1
)

:: 2. Pfade für CMake setzen
set "ASSIMP_ROOT=%FS_INCLUDE_DEST%\assimp-windows64-5.2.5-r3"
set "OPENAL_ROOT=%FS_INCLUDE_DEST%\openal-1.24.2-r1-windows64-13245988487"


echo %CYAN%──────────────────────────────────────────────────────────────────────────────────%RESET%
:: ##### 6. **Klonen der Quellverzeichnisse**
:: #####    - Holt `phoenix-firestorm` und `fs-build-variables` über `git clone`
echo %GREEN%Klonen der Repositories direkt nach %BUILD_DIR%...%RESET%

:: 1. Phoenix-Firestorm direkt ins BUILD_DIR
if not exist "%BUILD_DIR%\phoenix-firestorm\.git" (
    git clone "https://github.com/FirestormViewer/phoenix-firestorm.git" "%BUILD_DIR%\phoenix-firestorm"
) else (
    echo %YELLOW%phoenix-firestorm existiert bereits. aktualisiere...%RESET%
    git -C "%BUILD_DIR%\phoenix-firestorm" pull
    echo %GREEN%[INFO] Phoenix-Firestorm wurde aktualisiert.%RESET%
)
:: 2. Build-Variablen direkt ins BUILD_DIR
if not exist "%BUILD_DIR%\fs-build-variables\.git" (
    git clone "https://github.com/FirestormViewer/fs-build-variables.git" "%BUILD_DIR%\fs-build-variables"
) else (
    echo %YELLOW%fs-build-variables existiert bereits. aktualisiere...%RESET%
    git -C "%BUILD_DIR%\fs-build-variables" pull
    echo %GREEN%[INFO] fs-build-variables wurde aktualisiert.%RESET%
)


echo %CYAN%──────────────────────────────────────────────────────────────────────────────────%RESET%
:: Weitere Source schritte...
echo %GREEN%Kopiere fs-build-variables...%RESET%

if not exist "%BUILD_DIR%\fs-build-variables" (
    xcopy /E /I /Y "%SCRIPT_DIR%\fs-build-variables" "%BUILD_DIR%\fs-build-variables" >nul 2>&1
)

echo %CYAN%──────────────────────────────────────────────────────────────────────────────────%RESET%
:: Logos überschreiben aus dem fs_include Verzeichnis
echo %GREEN%Logos ueberschreiben %BUILD_DIR%...%RESET%

xcopy /y fs_include\vivox_logo.png Firestorm_Build\phoenix-firestorm\indra\newview\skins\default\textures\3p_icons\

echo %CYAN%──────────────────────────────────────────────────────────────────────────────────%RESET%
:: Skin änderungen Kopieren
echo %GREEN%Skin Kopieren %BUILD_DIR%...%RESET%

xcopy /E /I /Y "Skin\skins.xml" "Firestorm_Build\phoenix-firestorm\indra\newview\skins"
xcopy /E /I /Y "Skin\singularity" "Firestorm_Build\phoenix-firestorm\indra\newview\skins\singularity"

echo %CYAN%──────────────────────────────────────────────────────────────────────────────────%RESET%
:: cmake änderungen Kopieren
echo %GREEN%CMAKE Kopieren %BUILD_DIR%...%RESET%

xcopy /E /I /Y "fs_include\OPENAL.cmake" "Firestorm_Build\phoenix-firestorm\indra\cmake"
xcopy /E /I /Y "fs_include\Assimp.cmake" "Firestorm_Build\phoenix-firestorm\indra\cmake"

echo %CYAN%──────────────────────────────────────────────────────────────────────────────────%RESET%
:: Include Dateien in den Sourcecode einfügen.
echo %GREEN%Führe Dateikopierungen aus...%RESET%

:: 1. ZUERST das fs_include-Verzeichnis kopieren (falls noch nicht vorhanden)
if not exist "%FS_INCLUDE_DEST%\" (
    xcopy /E /I /Y "%FS_INCLUDE_SOURCE%" "%FS_INCLUDE_DEST%\" >nul
)

echo %CYAN%──────────────────────────────────────────────────────────────────────────────────%RESET%
:: 2. OpenAL DLLs kopieren (NACH Erstellung der Verzeichnisse)
echo %GREEN%Kopiere OpenAL DLLs...%RESET%

if exist "%BUILD_DIR%\phoenix-firestorm\build-vc170-64\newview\Release\" (
    :: OpenAL
    copy /Y "%SCRIPT_DIR%\fs_include\OpenAL32.dll" "%BUILD_DIR%\phoenix-firestorm\build-vc170-64\newview\Release\" >nul
    :: alut
    copy /Y "%SCRIPT_DIR%\fs_include\alut.dll" "%BUILD_DIR%\phoenix-firestorm\build-vc170-64\newview\Release\" >nul
    :: featuretable.txt
    copy /Y "%SCRIPT_DIR%\fs_include\featuretable.txt" "%BUILD_DIR%\phoenix-firestorm\build-vc170-64\newview\Release\" >nul
)


echo %CYAN%──────────────────────────────────────────────────────────────────────────────────%RESET%
:: ##### 7. **Build-Variablen und Anforderungen installieren**
:: #####    - Setzt Version, Architektur, lädt `requirements.txt`
echo %GREEN%Anforderungen installieren...%RESET%

set "AUTOBUILD_VSVER=170"
python -m pip install -r "%BUILD_DIR%\phoenix-firestorm\requirements.txt"


echo %CYAN%──────────────────────────────────────────────────────────────────────────────────%RESET%
:: ##### 8. **Anpassung von autobuild.xml**
:: #####    - Ersetzt Originaldatei durch `openal_autobuild.xml` zur Sound-Anpassung
echo %GREEN%Anpassung von autobuild.xml durch kopieren...%RESET%

::xcopy /E /I /Y "%SCRIPT_DIR%\autobuild.xml" "%BUILD_DIR%\phoenix-firestorm"
copy /Y "%SCRIPT_DIR%\fs_include\autobuild.xml" "%BUILD_DIR%\phoenix-firestorm\autobuild.xml"


echo %CYAN%──────────────────────────────────────────────────────────────────────────────────%RESET%
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


echo %CYAN%──────────────────────────────────────────────────────────────────────────────────%RESET%
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


echo %CYAN%──────────────────────────────────────────────────────────────────────────────────%RESET%
:: ##### 11. **Prüfung der Build-Konfigurationsdatei**
:: #####     - Validiert, ob `autobuild.xml` vorhanden ist
echo %GREEN%Prüfung der Build-Konfigurationsdatei...%RESET%

if not exist "%AUTO_BUILD_CONFIG%" (
    echo %RED%[FEHLER] autobuild.xml fehlt!%RESET%
    pause
    exit /b 1
)


echo %CYAN%──────────────────────────────────────────────────────────────────────────────────%RESET%
:: ##### 12. **Wechsel ins Quellverzeichnis**
:: #####     - Setzt aktuelles Arbeitsverzeichnis auf `phoenix-firestorm`
echo %GREEN%Wechsel ins Quellverzeichnis...%RESET%

cd /d "%BUILD_DIR%\phoenix-firestorm" || (
    echo %RED%[FEHLER] Quellverzeichnis nicht gefunden!%RESET%
    pause
    exit /b 1
)


echo %CYAN%──────────────────────────────────────────────────────────────────────────────────%RESET%
:: ##### 13. OpenAL DLLs bereitstellen vor dem Build
@REM echo %GREEN%Kopiere OpenAL DLLs in sharedlibs...%RESET%

@REM copy /Y "%SCRIPT_DIR%\OpenAL32.dll" "%BUILD_DIR%\phoenix-firestorm\build-vc170-64\sharedlibs\Release" >nul
@REM copy /Y "%SCRIPT_DIR%\alut.dll"     "%BUILD_DIR%\phoenix-firestorm\build-vc170-64\sharedlibs\Release" >nul

@REM copy /Y "%SCRIPT_DIR%\OpenAL32.dll" "%BUILD_DIR%\phoenix-firestorm\build-vc170-64\newview\Release" >nul
@REM copy /Y "%SCRIPT_DIR%\alut.dll"     "%BUILD_DIR%\phoenix-firestorm\build-vc170-64\newview\Release" >nul


echo %CYAN%──────────────────────────────────────────────────────────────────────────────────%RESET%
:: ##### 14. **Einbau der 3p Bibliotheken**
echo %GREEN%Installation einer neueren 3p-openal Bibliothek...%RESET%

autobuild installables edit openal platform=windows64 url=https://github.com/secondlife/3p-openal-soft/releases/download/v1.24.2-r1/openal-1.24.2-r1-windows64-13245988487.tar.zst hash_algorithm=sha1 hash=8ad24fba1191c9cb0d2ab36e64b04b4648a99f43

echo %CYAN%──────────────────────────────────────────────────────────────────────────────────%RESET%
:: ##### Assimp hinzufügen
echo %GREEN%Installation der 3p-assimp Bibliothek...%RESET%

autobuild installables remove assimp
autobuild installables add assimp platform=windows64 url=https://github.com/secondlife/3p-assimp/releases/download/v5.2.5-r3/assimp-windows64-5.2.5-r3.tar.bz2 hash=8b878487089380b43a8b2109dfc6ab8bbebd4009 hash_algorithm=sha1

echo %CYAN%──────────────────────────────────────────────────────────────────────────────────%RESET%
:: WebRTC austausch gegen eine neuere Version
echo %GREEN%Installation einer neueren 3p-webrtc Bibliothek...%RESET%

autobuild installables remove webrtc
autobuild installables add webrtc platform=windows64 url=https://github.com/secondlife/3p-webrtc-build/releases/download/m114.5735.08.73-alpha/webrtc-m114.5735.08.73-alpha.11958809572-windows64-11958809572.tar.zst hash_algorithm=sha1 hash=c7b329d6409576af6eb5b80655b007f52639c43b


echo %CYAN%──────────────────────────────────────────────────────────────────────────────────%RESET%
:: ##### 15. **Konfiguration des Builds**
:: #####     - Führt `autobuild configure` mit Flags für Channel, Paketierung, Audiooptionen aus

:: Konfiguration mit AVX2
echo %GREEN%Konfiguration mit AVX2 openal WebRTC...%RESET%
@REM echo  %YELLOW%Die  Warnung - Warning: no --id argument - ist überflüssig und verwirrend da das UTC Datum und Zeit eh gesetzt wird.%RESET%
@REM autobuild configure --config-file "%AUTO_BUILD_CONFIG%" -A 64 -c ReleaseFS_open -- --avx2 --openal --package --chan WebRTC -DLL_TESTS:BOOL=FALSE -DFMOD:BOOL=OFF -DUSE_OPENAL=ON
:: Ausgabe: PASSTHRU:  -DLL_TESTS:BOOL=FALSE -DFMOD:BOOL=OFF -DUSE_OPENAL=ON
autobuild configure --config-file "%AUTO_BUILD_CONFIG%" -A 64 -c ReleaseFS_open -- --avx2 --openal --package --chan WebRTC

if errorlevel 1 (
    echo %RED%[FEHLER] Konfiguration fehlgeschlagen!%RESET%
    pause
    exit /b 1
)


echo %CYAN%──────────────────────────────────────────────────────────────────────────────────%RESET%
:: ##### 16. Build
echo %GREEN%Build mit den gesetzten AVX2 openal WebRTC...%RESET%
:: Hier wird anscheinend OpenAL und weitere nicht implementiert obwohl sie in autobuild configure bereits implementiert wurden.
autobuild build --config-file "%AUTO_BUILD_CONFIG%" -A 64 -c ReleaseFS_open --no-configure --verbose

if errorlevel 1 (
    echo %RED%[FEHLER] Build fehlgeschlagen!%RESET%
    pause
    exit /b 1
)


echo %CYAN%──────────────────────────────────────────────────────────────────────────────────%RESET%
:: ##### 17. NSIS-Installer
:: #####     - Führt `makensis.exe` mit der `.nsi`-Installerskriptdatei aus
echo %GREEN%Erstelle mit NSIS-Installer...%RESET%
echo DLLs werden in die Package kopiert.

if not exist "%SCRIPT_DIR%Firestorm_Build\phoenix-firestorm\build-vc170-64\newview\Release" (
    echo %GREEN%Kopiere DLLs in das Release-Verzeichnis...%RESET%
    xcopy /Y alut.dll %SCRIPT_DIR%Firestorm_Build\phoenix-firestorm\build-vc170-64\newview\Release
    xcopy /Y OpenAL32.dll %SCRIPT_DIR%Firestorm_Build\phoenix-firestorm\build-vc170-64\newview\Release
    autobuild package -A 64 --config-file autobuild.xml
) 


@REM echo %CYAN%──────────────────────────────────────────────────────────────────────────────────%RESET%
@REM :: ##### 18 **Ausgabe der Konfigurationsdatei**
@REM :: ##### Für Debugging, um die Konfigurationsdatei auszugeben.
@REM echo %GREEN%Ausgabe der Konfigurationsdatei...%RESET%

@REM autobuild print --json my-config-file.json


echo %CYAN%──────────────────────────────────────────────────────────────────────────────────%RESET%
:: ##### 19. **Zusammenfassung und Ergebnisanzeige**
:: #####     - Zeigt den Inhalt des Release-Verzeichnisses im Terminal und beendet das Skript

echo %GREEN%✔ Paketierung abgeschlossen%RESET%
echo %BLUE%   Inhalt des Release-Verzeichnisses:%RESET%
dir /b "%SCRIPT_DIR%Firestorm_Build\phoenix-firestorm\build-vc170-64\newview\Release"

@REM :: Kopiere die Release Setup Phoenix-FirestormOS-WebRTC_AVX2-7-2-0-78913_Setup.exe ins Hauptverzeichnis/release
@REM echo %GREEN%Kopiere die Release ins Hauptverzeichnis/release...%RESET%
@REM if not exist "release" mkdir "release"
@REM xcopy /Y "Firestorm_Build\phoenix-firestorm\build-vc170-64\newview\Release\*Setup.exe" "release"
@REM if errorlevel 1 (
@REM     echo %RED%[FEHLER] Kopieren der Release fehlgeschlagen!%RESET%
@REM     pause
@REM     exit /b 1
@REM )
@REM echo %GREEN%✔ Release Setup wurde kopiert nach: %SCRIPT_DIR%release%RESET%

echo %CYAN%──────────────────────────────────────────────────────────────────────────────────%RESET%
pause
exit /b 1
