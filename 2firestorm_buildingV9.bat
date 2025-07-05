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
set "FS_INCLUDE_DEST=%BUILD_DIR%\fs_include"

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

:: 1. fs_include ins Build-Verzeichnis kopieren
set "FS_INCLUDE_SOURCE=%SCRIPT_DIR%\fs_include"
set "FS_INCLUDE_DEST=%BUILD_DIR%\fs_include"

if exist "%FS_INCLUDE_SOURCE%" (
    echo %GREEN%Kopiere fs_include nach Build-Verzeichnis...%RESET%
    xcopy /E /I /Y "%FS_INCLUDE_SOURCE%" "%FS_INCLUDE_DEST%\" >nul
) else (
    echo %RED%[FEHLER] fs_include nicht gefunden in: %FS_INCLUDE_SOURCE%%RESET%
    exit /b 1
)

:: 2. Pfade für CMake setzen
set "ASSIMP_ROOT=%FS_INCLUDE_DEST%\assimp-windows64-5.2.5-r3"
set "OPENAL_ROOT=%FS_INCLUDE_DEST%\openal-1.24.2-r1-windows64-13245988487"




:: ##### 6. **Klonen der Quellverzeichnisse**
:: #####    - Holt `phoenix-firestorm` und `fs-build-variables` über `git clone`

echo %GREEN%Klonen der Quellverzeichnisse...%RESET%

if not exist "%SCRIPT_DIR%\phoenix-firestorm" (
    git clone "https://github.com/FirestormViewer/phoenix-firestorm.git" "%SCRIPT_DIR%\phoenix-firestorm"
    :: Manni
    ::git clone "https://github.com/ManfredAabye/phoenix-firestorm-os.git" "%SCRIPT_DIR%\phoenix-firestorm"
)

if not exist "%SCRIPT_DIR%\fs-build-variables" (
    git clone "https://github.com/FirestormViewer/fs-build-variables.git" "%SCRIPT_DIR%\fs-build-variables"
)

:: Leise Kopie ins BUILD_DIR ohne Ausgabe
if not exist "%BUILD_DIR%\phoenix-firestorm" (
    xcopy /E /I /Y "%SCRIPT_DIR%\phoenix-firestorm" "%BUILD_DIR%\phoenix-firestorm" >nul 2>&1
)

if not exist "%BUILD_DIR%\fs-build-variables" (
    xcopy /E /I /Y "%SCRIPT_DIR%\fs-build-variables" "%BUILD_DIR%\fs-build-variables" >nul 2>&1
)




:: ##### 7. **Build-Variablen und Anforderungen installieren**
:: #####    - Setzt Version, Architektur, lädt `requirements.txt`

echo %GREEN%Anforderungen installieren...%RESET%

set "AUTOBUILD_VSVER=170"
python -m pip install -r "%BUILD_DIR%\phoenix-firestorm\requirements.txt"





:: ##### 8. **Anpassung von autobuild.xml**
:: #####    - Ersetzt Originaldatei durch `openal_autobuild.xml` zur Sound-Anpassung

echo %GREEN%Anpassung von autobuild.xml durch kopieren...%RESET%

::xcopy /E /I /Y "%SCRIPT_DIR%\autobuild.xml" "%BUILD_DIR%\phoenix-firestorm"
copy /Y "%SCRIPT_DIR%\autobuild.xml" "%BUILD_DIR%\phoenix-firestorm\autobuild.xml"

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

:: ##### 13. uninstaller
:: ##### Führt `autobuild uninstall` mit Flags aus, um Installationen zu entfernen.

::echo %GREEN%Entferne Installationen...%RESET%

:: fmod restlos entfernen
::autobuild uninstall fmod_studio fmod_ex

:: ##### 13.5 OpenAL DLLs bereitstellen vor dem Build

echo %GREEN%Kopiere OpenAL DLLs in sharedlibs...%RESET%

copy /Y "%SCRIPT_DIR%\OpenAL32.dll" "%BUILD_DIR%\phoenix-firestorm\build-vc170-64\sharedlibs\Release" >nul
copy /Y "%SCRIPT_DIR%\alut.dll"     "%BUILD_DIR%\phoenix-firestorm\build-vc170-64\sharedlibs\Release" >nul

copy /Y "%SCRIPT_DIR%\OpenAL32.dll" "%BUILD_DIR%\phoenix-firestorm\build-vc170-64\newview\Release" >nul
copy /Y "%SCRIPT_DIR%\alut.dll"     "%BUILD_DIR%\phoenix-firestorm\build-vc170-64\newview\Release" >nul


:: ##### 14. **Konfiguration des Builds**
:: #####     - Führt `autobuild configure` mit Flags für Channel, Paketierung, Audiooptionen aus

echo %GREEN%Konfiguration...%RESET%
:: Assimp angehängt am 04.07.2025
::autobuild configure --config-file "%AUTO_BUILD_CONFIG%" -A 64 -c ReleaseFS_open -- --package --chan WebRTC -DLL_TESTS:BOOL=FALSE -DFMOD:BOOL=OFF -DUSE_OPENAL:BOOL=TRUE -DUSE_ASSIMP:BOOL=ON
:: Ohne Assimp
::autobuild configure --config-file "%AUTO_BUILD_CONFIG%" -A 64 -c ReleaseFS_open -- --package --chan WebRTC -DLL_TESTS:BOOL=FALSE -DFMOD:BOOL=OFF -DUSE_OPENAL:BOOL=TRUE

autobuild configure --config-file "%AUTO_BUILD_CONFIG%" -A 64 -c ReleaseFS_open -- --package --chan WebRTC -DLL_TESTS:BOOL=FALSE -DFMOD:BOOL=OFF -DUSE_OPENAL:BOOL=TRUE -DUSE_ASSIMP:BOOL=ON -DASSIMP_ROOT="%FS_INCLUDE%\assimp-windows64-5.2.5-r3" -DOPENAL_ROOT="%FS_INCLUDE%\openal-1.24.2-r1-windows64-13245988487" -DCMAKE_LIBRARY_PATH="%FS_INCLUDE%\assimp-windows64-5.2.5-r3\lib\release;%FS_INCLUDE%\openal-1.24.2-r1-windows64-13245988487\lib\release" -DCMAKE_INCLUDE_PATH="%FS_INCLUDE%\assimp-windows64-5.2.5-r3\include;%FS_INCLUDE%\openal-1.24.2-r1-windows64-13245988487\include"



if errorlevel 1 (
    echo %RED%[FEHLER] Konfiguration fehlgeschlagen!%RESET%
    pause
    exit /b 1
)

:: ##### 15. **Durchführung des Builds**
:: #####     - Kompiliert den Viewer mit `autobuild build`

echo %GREEN%Build...%RESET%

:: Falls AUTOBUILD_BUILD_ID leer ist, setze Standardwert
if not defined AUTOBUILD_BUILD_ID (
    set "AUTOBUILD_BUILD_ID=78713"
)

:: Führe autobuild mit der Build-ID aus
autobuild build --id %AUTOBUILD_BUILD_ID% --config-file "%AUTO_BUILD_CONFIG%" -A 64 -c ReleaseFS_open --no-configure --verbose
:: Führe autobuild ohne Build-ID aus
::autobuild build --config-file "%AUTO_BUILD_CONFIG%" -A 64 -c ReleaseFS_open --no-configure --verbose

if errorlevel 1 (
    echo %RED%[FEHLER] Build fehlgeschlagen!%RESET%
    pause
    exit /b 1
)

:: ##### 16. **Ermittlung des Release-Verzeichnisses**
:: #####     - Findet das konkrete `Release`-Verzeichnis mit dem gebauten Viewer

echo %GREEN%Suche nach Release-Verzeichnis...%RESET%

if not exist "%SCRIPT_DIR%Firestorm_Build\phoenix-firestorm\build-vc170-64\newview\Release" (
    echo %RED%[FEHLER] Release-Verzeichnis nicht gefunden: %SCRIPT_DIR%Firestorm_Build\phoenix-firestorm\build-vc170-64\newview\Release%RESET%
    ::pause
    ::exit /b 1
)
echo %GREEN%• Release-Verzeichnis gefunden: %SCRIPT_DIR%Firestorm_Build\phoenix-firestorm\build-vc170-64\newview\Release%RESET%






:: ##### 17. **Erstellung des NSIS-Installers**
:: #####     - Führt `makensis.exe` mit der `.nsi`-Installerskriptdatei aus

:: 1. fs_include ins Build-Verzeichnis kopieren
:: Setze korrekte Verzeichnispfade
set "FS_INCLUDE_SOURCE=%SCRIPT_DIR%\fs_include"
set "FS_INCLUDE_DEST=%BUILD_DIR%\fs_include"

:: Erstelle NSIS-Installer
echo %GREEN%Erstelle NSIS-Installer...%RESET%
echo DLLs werden in die Package kopiert.

:: Definiere Zielverzeichnis für DLLs
set "RELEASE_DIR=%SCRIPT_DIR%Firestorm_Build\phoenix-firestorm\build-vc170-64\newview\Release"

:: Überprüfe ob Release-Verzeichnis existiert
if not exist "%RELEASE_DIR%" (
    echo %RED%[FEHLER] Release-Verzeichnis fehlt: "%RELEASE_DIR%"%RESET%
    exit /b 1
)

echo %GREEN%Kopiere DLLs in das Release-Verzeichnis...%RESET%
xcopy /Y "%SCRIPT_DIR%\alut.dll" "%RELEASE_DIR%\" >nul
xcopy /Y "%SCRIPT_DIR%\OpenAL32.dll" "%RELEASE_DIR%\" >nul

:: Führe autobuild package aus
autobuild package -A 64 --config-file autobuild.xml






:: ##### 18 **Ausgabe der Konfigurationsdatei**
:: ##### Für Debugging, um die Konfigurationsdatei auszugeben.

echo %GREEN%Ausgabe der Konfigurationsdatei...%RESET%

:: Funktioniert nicht
::autobuild print --config-file my-config-file.xml
autobuild print --json my-config-file.json

:: ##### 19. **Zusammenfassung und Ergebnisanzeige**
:: #####     - Zeigt den Inhalt des Release-Verzeichnisses im Terminal und beendet das Skript

echo %GREEN%✔ Paketierung abgeschlossen%RESET%
echo %BLUE%   Inhalt des Release-Verzeichnisses:%RESET%
dir /b "%SCRIPT_DIR%Firestorm_Build\phoenix-firestorm\build-vc170-64\newview\Release"
pause
exit /b 1