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
set "ARCH=64"
set "CONFIG=ReleaseFS_open"
set "OUTPUT_DIR=%BUILD_DIR%\phoenix-firestorm\build-vc170-64\newview\Release"
set "AUTO_BUILD_CONFIG=%BUILD_DIR%\phoenix-firestorm\autobuild.xml"
set "AUTOBUILD_VARIABLES_FILE=%BUILD_DIR%\fs-build-variables\variables"

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

autobuild configure --config-file "%AUTO_BUILD_CONFIG%" -A 64 -c ReleaseFS_open -- --package --chan WebRTC -DLL_TESTS:BOOL=FALSE -DFMOD:BOOL=OFF -DUSE_OPENAL:BOOL=TRUE

if errorlevel 1 (
    echo %RED%[FEHLER] Konfiguration fehlgeschlagen!%RESET%
    pause
    exit /b 1
)

:: ##### 15. **Durchführung des Builds**
:: #####     - Kompiliert den Viewer mit `autobuild build`

echo %GREEN%Build...%RESET%

autobuild build --config-file "%AUTO_BUILD_CONFIG%" -A 64 -c ReleaseFS_open --no-configure --verbose
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

echo %GREEN%Erstelle NSIS-Installer...%RESET%
echo DLLs werden in die Package kopiert.

if not exist "%SCRIPT_DIR%Firestorm_Build\phoenix-firestorm\build-vc170-64\newview\Release" (
    echo %GREEN%Kopiere DLLs in das Release-Verzeichnis...%RESET%
    ::copy /Y "%SCRIPT_DIR%alut.dll" "%SCRIPT_DIR%Firestorm_Build\phoenix-firestorm\build-vc170-64\newview\Release" >nul
    xcopy /Y alut.dll %SCRIPT_DIR%Firestorm_Build\phoenix-firestorm\build-vc170-64\newview\Release
    ::copy /Y "%SCRIPT_DIR%OpenAL32.dll" "%SCRIPT_DIR%Firestorm_Build\phoenix-firestorm\build-vc170-64\newview\Release" >nul
    xcopy /Y OpenAL32.dll %SCRIPT_DIR%Firestorm_Build\phoenix-firestorm\build-vc170-64\newview\Release
    autobuild package -A 64 --config-file autobuild.xml
) else (
    echo %RED%[FEHLER] Release-Verzeichnis fehlt.%RESET%
)

:: ##### 18 **Ausgabe der Konfigurationsdatei**
:: ##### Für Debugging, um die Konfigurationsdatei auszugeben.

echo %GREEN%Ausgabe der Konfigurationsdatei...%RESET%

:: Funktioniert nicht
autobuild print --config-file my-config-file.xml
autobuild print --json my-config-file.json

:: ##### 19. **Zusammenfassung und Ergebnisanzeige**
:: #####     - Zeigt den Inhalt des Release-Verzeichnisses im Terminal und beendet das Skript

echo %GREEN%✔ Paketierung abgeschlossen%RESET%
echo %BLUE%   Inhalt des Release-Verzeichnisses:%RESET%
dir /b "%SCRIPT_DIR%Firestorm_Build\phoenix-firestorm\build-vc170-64\newview\Release"
pause
exit /b 1