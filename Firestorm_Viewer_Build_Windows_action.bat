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


:: ##### 3. **Grundkonfiguration und Variablen**
:: Definition von Skriptpfad, Zielordnern, Konfigurationsparametern


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

set "AUTOBUILD_TEMP=%SCRIPT_DIR%temp"  :: Temporäres Arbeitsverzeichnis
if not exist "%AUTOBUILD_TEMP%" mkdir "%AUTOBUILD_TEMP%"
:: Erstellt das TEMP-Verzeichnis, falls nicht vorhanden
set "TMP=%AUTOBUILD_TEMP%"
set "TEMP=%AUTOBUILD_TEMP%"

:: 1. fs_include ins Build-Verzeichnis kopieren
:: Neuer Ort des fs_include Verzeichnisses: https://github.com/ManfredAabye/fs-build-firestorm-viewer-german/tree/main/fs_include
if not exist "%BUILD_DIR%\fs-build-firestorm-viewer-german\.git" (
    git clone "https://github.com/ManfredAabye/fs-build-firestorm-viewer-german.git" "%BUILD_DIR%\fs-build-firestorm-viewer-german"
) else (
    echo %YELLOW%fs-build-firestorm-viewer-german existiert bereits. aktualisiere...%RESET%
    git -C "%BUILD_DIR%\fs-build-firestorm-viewer-german" pull
)

set "FS_INCLUDE_SOURCE=%SCRIPT_DIR%\fs_include"
set "FS_INCLUDE_DEST=%BUILD_DIR%\fs_include"


:: ##### 4. **Erstellung des Arbeitsverzeichnisses**
:: #####    - Legt den Build-Ordner an (sofern nicht vorhanden)

mkdir "%BUILD_DIR%" 2>nul


:: ##### 5. **Einrichtung der Python-Virtualenv**
:: #####    - Erstellt virtuelle Umgebung und installiert benötigte Python-Module (`autobuild`, `llbase`, `llsd`)

if not exist "%VENV_DIR%" (
    python -m venv "%VENV_DIR%"
    call "%VENV_DIR%\Scripts\activate.bat"
    python -m pip install --upgrade pip
    python -m pip install --force-reinstall --no-cache-dir llbase llsd autobuild
) else (
    call "%VENV_DIR%\Scripts\activate.bat"
)

:: 1. fs_include ins Build-Verzeichnis kopieren
set "FS_INCLUDE_SOURCE=%SCRIPT_DIR%\fs_include"
set "FS_INCLUDE_DEST=%BUILD_DIR%\fs_include"

if exist "%FS_INCLUDE_SOURCE%" (
    xcopy /E /I /Y "%FS_INCLUDE_SOURCE%" "%FS_INCLUDE_DEST%\" >nul
) else (
    exit /b 1
)

:: 2. Pfade für CMake setzen
set "ASSIMP_ROOT=%FS_INCLUDE_DEST%\assimp-windows64-5.2.5-r3"
set "OPENAL_ROOT=%FS_INCLUDE_DEST%\openal-1.24.2-r1-windows64-13245988487"



:: ##### 6. **Klonen der Quellverzeichnisse**
:: #####    - Holt `phoenix-firestorm` und `fs-build-variables` über `git clone`

:: 1. Phoenix-Firestorm direkt ins BUILD_DIR
if not exist "%BUILD_DIR%\phoenix-firestorm\.git" (
    git clone "https://github.com/FirestormViewer/phoenix-firestorm.git" "%BUILD_DIR%\phoenix-firestorm"
) else (
    echo %YELLOW%phoenix-firestorm existiert bereits. aktualisiere...%RESET%
    git -C "%BUILD_DIR%\phoenix-firestorm" pull
)
:: 2. Build-Variablen direkt ins BUILD_DIR
if not exist "%BUILD_DIR%\fs-build-variables\.git" (
    git clone "https://github.com/FirestormViewer/fs-build-variables.git" "%BUILD_DIR%\fs-build-variables"
) else (
    echo %YELLOW%fs-build-variables existiert bereits. aktualisiere...%RESET%
    git -C "%BUILD_DIR%\fs-build-variables" pull
)


:: Weitere Source schritte...

if not exist "%BUILD_DIR%\fs-build-variables" (
    xcopy /E /I /Y "%SCRIPT_DIR%\fs-build-variables" "%BUILD_DIR%\fs-build-variables" >nul 2>&1
)


:: Logos überschreiben aus dem fs_include Verzeichnis

xcopy /y fs_include\vivox_logo.png Firestorm_Build\phoenix-firestorm\indra\newview\skins\default\textures\3p_icons\


:: Skin änderungen Kopieren

xcopy /E /I /Y "Skin\skins.xml" "Firestorm_Build\phoenix-firestorm\indra\newview\skins"
xcopy /E /I /Y "Skin\singularity" "Firestorm_Build\phoenix-firestorm\indra\newview\skins\singularity"



:: Include Dateien in den Sourcecode einfügen.

:: 1. ZUERST das fs_include-Verzeichnis kopieren (falls noch nicht vorhanden)
if not exist "%FS_INCLUDE_DEST%\" (
    xcopy /E /I /Y "%FS_INCLUDE_SOURCE%" "%FS_INCLUDE_DEST%\" >nul
)


:: 2. OpenAL DLLs kopieren (NACH Erstellung der Verzeichnisse)

if exist "%BUILD_DIR%\phoenix-firestorm\build-vc170-64\newview\Release\" (
    :: OpenAL
    copy /Y "%SCRIPT_DIR%\fs_include\OpenAL32.dll" "%BUILD_DIR%\phoenix-firestorm\build-vc170-64\newview\Release\" >nul
    :: alut
    copy /Y "%SCRIPT_DIR%\fs_include\alut.dll" "%BUILD_DIR%\phoenix-firestorm\build-vc170-64\newview\Release\" >nul
    :: featuretable.txt
    copy /Y "%SCRIPT_DIR%\fs_include\featuretable.txt" "%BUILD_DIR%\phoenix-firestorm\build-vc170-64\newview\Release\" >nul
)



:: ##### 7. **Build-Variablen und Anforderungen installieren**
:: #####    - Setzt Version, Architektur, lädt `requirements.txt`

set "AUTOBUILD_VSVER=170"
python -m pip install -r "%BUILD_DIR%\phoenix-firestorm\requirements.txt"



:: ##### 8. **Anpassung von autobuild.xml**
:: #####    - Ersetzt Originaldatei durch `openal_autobuild.xml` zur Sound-Anpassung

::xcopy /E /I /Y "%SCRIPT_DIR%\autobuild.xml" "%BUILD_DIR%\phoenix-firestorm"
copy /Y "%SCRIPT_DIR%\fs_include\autobuild.xml" "%BUILD_DIR%\phoenix-firestorm\autobuild.xml"



:: ##### 9. **Aktivierung der Visual-Studio-Umgebung**
:: #####    - Lädt `vcvarsall.bat` für das 64-Bit-Toolset von Visual Studio 2022

set "VS2022BAT="
for %%D in ("C:\Program Files\Microsoft Visual Studio\2022\Community") do (
    if exist "%%~D\VC\Auxiliary\Build\vcvarsall.bat" (
        set "VS2022BAT=%%~D\VC\Auxiliary\Build\vcvarsall.bat"
    )
)

call "%VS2022BAT%" x64


:: ##### 10. **Aktivierung der Python-Umgebung**
:: #####     - (Erneut) Aktiviert Virtualenv für Folgeaktionen

if exist "%VENV_DIR%\Scripts\activate.bat" (
    call "%VENV_DIR%\Scripts\activate.bat"
) else (
    echo %RED%[FEHLER] Python-Virtualenv fehlt: %VENV_DIR%%RESET%
    pause
    exit /b 1
)



:: ##### 11. **Prüfung der Build-Konfigurationsdatei**
:: #####     - Validiert, ob `autobuild.xml` vorhanden ist

if not exist "%AUTO_BUILD_CONFIG%" (
    echo %RED%[FEHLER] autobuild.xml fehlt!%RESET%
    pause
    exit /b 1
)


:: ##### 12. **Wechsel ins Quellverzeichnis**
:: #####     - Setzt aktuelles Arbeitsverzeichnis auf `phoenix-firestorm`

cd /d "%BUILD_DIR%\phoenix-firestorm" || (
    echo %RED%[FEHLER] Quellverzeichnis nicht gefunden!%RESET%
    pause
    exit /b 1
)

:: ##### 13. OpenAL DLLs bereitstellen vor dem Build

copy /Y "%SCRIPT_DIR%\OpenAL32.dll" "%BUILD_DIR%\phoenix-firestorm\build-vc170-64\sharedlibs\Release" >nul
copy /Y "%SCRIPT_DIR%\alut.dll"     "%BUILD_DIR%\phoenix-firestorm\build-vc170-64\sharedlibs\Release" >nul

copy /Y "%SCRIPT_DIR%\OpenAL32.dll" "%BUILD_DIR%\phoenix-firestorm\build-vc170-64\newview\Release" >nul
copy /Y "%SCRIPT_DIR%\alut.dll"     "%BUILD_DIR%\phoenix-firestorm\build-vc170-64\newview\Release" >nul


:: ##### 14. **Einbau der 3p Bibliotheken**

autobuild installables edit openal platform=windows64 url=https://github.com/secondlife/3p-openal-soft/releases/download/v1.24.2-r1/openal-1.24.2-r1-windows64-13245988487.tar.zst hash_algorithm=sha1 hash=8ad24fba1191c9cb0d2ab36e64b04b4648a99f43

:: WebRTC austausch gegen eine neuere Version
autobuild installables remove webrtc
autobuild installables add webrtc platform=windows64 url=https://github.com/secondlife/3p-webrtc-build/releases/download/m114.5735.08.73-alpha/webrtc-m114.5735.08.73-alpha.11958809572-windows64-11958809572.tar.zst hash_algorithm=sha1 hash=c7b329d6409576af6eb5b80655b007f52639c43b

:: ##### 15. **Konfiguration des Builds**
:: #####     - Führt `autobuild configure` mit Flags für Channel, Paketierung, Audiooptionen aus

:: Konfiguration mit AVX2
autobuild configure --config-file "%AUTO_BUILD_CONFIG%" -A 64 -c ReleaseFS_open -- --avx2 --openal --package --chan WebRTC -DLL_TESTS:BOOL=FALSE -DFMOD:BOOL=OFF -DUSE_OPENAL=ON

if errorlevel 1 (
    echo %RED%[FEHLER] Konfiguration fehlgeschlagen!%RESET%
    pause
    exit /b 1
)


:: ##### 16. Build

autobuild build --config-file "%AUTO_BUILD_CONFIG%" -A 64 -c ReleaseFS_open --no-configure --verbose
if errorlevel 1 (
    echo %RED%[FEHLER] Build fehlgeschlagen!%RESET%
    pause
    exit /b 1
)


:: ##### 17. **Ermittlung des Release-Verzeichnisses**
:: #####     - Findet das konkrete `Release`-Verzeichnis mit dem gebauten Viewer

if not exist "%SCRIPT_DIR%Firestorm_Build\phoenix-firestorm\build-vc170-64\newview\Release" (
    echo %RED%[FEHLER] Release-Verzeichnis nicht gefunden: %SCRIPT_DIR%Firestorm_Build\phoenix-firestorm\build-vc170-64\newview\Release%RESET%
)


:: ##### 18. NSIS-Installer
:: #####     - Führt `makensis.exe` mit der `.nsi`-Installerskriptdatei aus

if not exist "%SCRIPT_DIR%Firestorm_Build\phoenix-firestorm\build-vc170-64\newview\Release" (
    echo %GREEN%Kopiere DLLs in das Release-Verzeichnis...%RESET%
    xcopy /Y alut.dll %SCRIPT_DIR%Firestorm_Build\phoenix-firestorm\build-vc170-64\newview\Release
    xcopy /Y OpenAL32.dll %SCRIPT_DIR%Firestorm_Build\phoenix-firestorm\build-vc170-64\newview\Release
    autobuild package -A 64 --config-file autobuild.xml
) 

exit /b 1