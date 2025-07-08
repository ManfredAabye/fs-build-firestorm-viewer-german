#!/bin/bash

# ##### 1. **Einleitung und Hinweise** #####
# ##### Dies ist die Datei 2firestorm_buildV5.sh
# ##### Teil des Firestorm Viewer Build-Prozesses
# ##### Version 25.100
# ##### by Manfred Aabye
# ##### Stand: 07.07.2025

# Wichtige Änderungen und Anpassungen:
#
#     Verzeichnisstruktur: Das Skript arbeitet jetzt im Verzeichnis /opt/Firestorm_Build statt in einem Windows-Pfad.
#     Bash-Syntax:
#         @echo off entfernt
#         set durch export ersetzt
#         %VAR% durch $VAR ersetzt
#         if exist durch if [ -f ] oder if [ -d ] ersetzt
#         mkdir mit -p Option für Elternverzeichnisse
#         xcopy durch cp -r ersetzt
#     Windows-spezifische Elemente entfernt:
#         Visual Studio-Aktivierung (vcvarsall.bat) wurde entfernt
#         NSIS-Installer (Linux verwendet typischerweise andere Paketierungssysteme)
#     Farbausgabe: Verwendet echo -e für ANSI-Farbcodes
#     Fehlerbehandlung: Verwendet $? für Exit-Code-Prüfung statt errorlevel
#     Python Virtualenv: Aktivierung mit source venv/bin/activate statt .bat-Datei
#     Git-Operationen: Bleiben gleich, da Git auf beiden Plattformen verfügbar ist


# ##### 2. **Farbdefinition für Konsolenausgabe**
# ##### - Setzt ANSI-Farbcodes für farbige Statusmeldungen im Terminal

ESC="\033"
GREEN="${ESC}[32m"
RED="${ESC}[31m"
YELLOW="${ESC}[33m"
BLUE="${ESC}[34m"
RESET="${ESC}[0m"

echo -e "${GREEN}Firestorm Build-Vorbereitung${RESET}"

# ##### 3. **Grundkonfiguration und Variablen**
# #####    - Definition von Skriptpfad, Zielordnern, Konfigurationsparametern

echo -e "${GREEN}Konfiguration...${RESET}"

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PYTHON_VERSION="3.10.11"
BUILD_DIR="/opt/Firestorm_Build"
VENV_DIR="$BUILD_DIR/venv"
AUTOBUILD_INSTALL_DIR="$BUILD_DIR/packages"

ARCH="64"
CONFIG="ReleaseFS_open"
OUTPUT_DIR="$BUILD_DIR/phoenix-firestorm/build-vc170-64/newview/Release"
AUTO_BUILD_CONFIG="$BUILD_DIR/phoenix-firestorm/autobuild.xml"
AUTOBUILD_VARIABLES_FILE="$BUILD_DIR/fs-build-variables/variables"

# ##### TEMP-UMLEITUNG #####
echo -e "${GREEN}TEMP-UMLEITUNG...${RESET}"
AUTOBUILD_TEMP="$SCRIPT_DIR/temp"
mkdir -p "$AUTOBUILD_TEMP"
export TMP="$AUTOBUILD_TEMP"
export TEMP="$AUTOBUILD_TEMP"

# 1. fs_include ins Build-Verzeichnis kopieren
FS_INCLUDE_SOURCE="$SCRIPT_DIR/fs_include"
FS_INCLUDE_DEST="$BUILD_DIR/fs_include"

# ##### 4. **Erstellung des Arbeitsverzeichnisses**
# #####    - Legt den Build-Ordner an (sofern nicht vorhanden)

echo -e "${GREEN}Erstelle Build-Verzeichnis${RESET}"
mkdir -p "$BUILD_DIR"

# ##### 5. **Einrichtung der Python-Virtualenv**
# #####    - Erstellt virtuelle Umgebung und installiert benötigte Python-Module

if [ ! -d "$VENV_DIR" ]; then
    python -m venv "$VENV_DIR"
    source "$VENV_DIR/bin/activate"
    python -m pip install --upgrade pip
    python -m pip install --force-reinstall --no-cache-dir llbase llsd autobuild
    echo -e "${GREEN}[INFO] Virtualenv wurde erstellt.${RESET}"
else
    source "$VENV_DIR/bin/activate"
    echo -e "${GREEN}[INFO] Virtualenv existiert bereits.${RESET}"
fi

# 1. fs_include ins Build-Verzeichnis kopieren
if [ -d "$FS_INCLUDE_SOURCE" ]; then
    echo -e "${GREEN}Kopiere fs_include nach Build-Verzeichnis...${RESET}"
    cp -r "$FS_INCLUDE_SOURCE" "$FS_INCLUDE_DEST"
else
    echo -e "${RED}[FEHLER] fs_include nicht gefunden in: $FS_INCLUDE_SOURCE${RESET}"
    exit 1
fi

# 2. Pfade für CMake setzen
export ASSIMP_ROOT="$FS_INCLUDE_DEST/assimp-windows64-5.2.5-r3"
export OPENAL_ROOT="$FS_INCLUDE_DEST/openal-1.24.2-r1-windows64-13245988487"

# ##### 6. **Klonen der Quellverzeichnisse**
# #####    - Holt `phoenix-firestorm` und `fs-build-variables` über `git clone`

echo -e "${GREEN}Klonen der Quellverzeichnisse...${RESET}"

# 1. Phoenix-Firestorm direkt ins BUILD_DIR
if [ ! -d "$BUILD_DIR/phoenix-firestorm/.git" ]; then
    git clone "https://github.com/FirestormViewer/phoenix-firestorm.git" "$BUILD_DIR/phoenix-firestorm"
else
    echo -e "${YELLOW}phoenix-firestorm existiert bereits. Überspringe...${RESET}"
fi

# 2. Build-Variablen direkt ins BUILD_DIR
if [ ! -d "$BUILD_DIR/fs-build-variables/.git" ]; then
    git clone "https://github.com/FirestormViewer/fs-build-variables.git" "$BUILD_DIR/fs-build-variables"
else
    echo -e "${YELLOW}fs-build-variables existiert bereits. Überspringe...${RESET}"
fi

# Dateien in den Sourcecode einfügen.
echo -e "${GREEN}Führe Dateikopierungen aus...${RESET}"

# 1. ZUERST das fs_include-Verzeichnis kopieren (falls noch nicht vorhanden)
if [ ! -d "$FS_INCLUDE_DEST" ]; then
    cp -r "$FS_INCLUDE_SOURCE" "$FS_INCLUDE_DEST"
fi

# 2. OpenAL DLLs kopieren (NACH Erstellung der Verzeichnisse)
if [ -d "$BUILD_DIR/phoenix-firestorm/build-vc170-64/newview/Release" ]; then
    cp "$SCRIPT_DIR/OpenAL32.dll" "$BUILD_DIR/phoenix-firestorm/build-vc170-64/newview/Release/"
    cp "$SCRIPT_DIR/alut.dll" "$BUILD_DIR/phoenix-firestorm/build-vc170-64/newview/Release/"
    cp "$SCRIPT_DIR/featuretable.txt" "$BUILD_DIR/phoenix-firestorm/build-vc170-64/newview/Release/"
fi

# ##### 7. **Build-Variablen und Anforderungen installieren**
# #####    - Setzt Version, Architektur, lädt `requirements.txt`

echo -e "${GREEN}Anforderungen installieren...${RESET}"

export AUTOBUILD_VSVER="170"
python -m pip install -r "$BUILD_DIR/phoenix-firestorm/requirements.txt"

# ##### 8. **Anpassung von autobuild.xml**
# #####    - Ersetzt Originaldatei durch `openal_autobuild.xml` zur Sound-Anpassung

echo -e "${GREEN}Anpassung von autobuild.xml durch kopieren...${RESET}"

cp "$SCRIPT_DIR/autobuild.xml" "$BUILD_DIR/phoenix-firestorm/autobuild.xml"

# ##### 10. **Aktivierung der Python-Umgebung**
# #####     - (Erneut) Aktiviert Virtualenv für Folgeaktionen

echo -e "${GREEN}Aktivierung der Python-Umgebung...${RESET}"

if [ -f "$VENV_DIR/bin/activate" ]; then
    source "$VENV_DIR/bin/activate"
else
    echo -e "${RED}[FEHLER] Python-Virtualenv fehlt: $VENV_DIR${RESET}"
    exit 1
fi

# ##### 11. **Prüfung der Build-Konfigurationsdatei**
# #####     - Validiert, ob `autobuild.xml` vorhanden ist

echo -e "${GREEN}Prüfung der Build-Konfigurationsdatei...${RESET}"

if [ ! -f "$AUTO_BUILD_CONFIG" ]; then
    echo -e "${RED}[FEHLER] autobuild.xml fehlt!${RESET}"
    exit 1
fi

# ##### 13.5 OpenAL DLLs bereitstellen vor dem Build

echo -e "${GREEN}Kopiere OpenAL DLLs in sharedlibs...${RESET}"

mkdir -p "$BUILD_DIR/phoenix-firestorm/build-vc170-64/sharedlibs/Release"
cp "$SCRIPT_DIR/OpenAL32.dll" "$BUILD_DIR/phoenix-firestorm/build-vc170-64/sharedlibs/Release/"
cp "$SCRIPT_DIR/alut.dll" "$BUILD_DIR/phoenix-firestorm/build-vc170-64/sharedlibs/Release/"

mkdir -p "$BUILD_DIR/phoenix-firestorm/build-vc170-64/newview/Release"
cp "$SCRIPT_DIR/OpenAL32.dll" "$BUILD_DIR/phoenix-firestorm/build-vc170-64/newview/Release/"
cp "$SCRIPT_DIR/alut.dll" "$BUILD_DIR/phoenix-firestorm/build-vc170-64/newview/Release/"

# ##### 110. **Einbau der 3p Bibliotheken**
echo -e "${GREEN}Installation einer neueren 3p-openal Bibliothek...${RESET}"
echo "."

autobuild installables edit openal platform=windows64 url=https://github.com/secondlife/3p-openal-soft/releases/download/v1.24.2-r1/openal-1.24.2-r1-windows64-13245988487.tar.zst hash_algorithm=sha1 hash=8ad24fba1191c9cb0d2ab36e64b04b4648a99f43

# WebRTC austausch gegen eine neuere Version
echo -e "${GREEN}Installation einer neueren 3p-webrtc Bibliothek...${RESET}"
echo "."

autobuild installables remove webrtc
autobuild installables add webrtc platform=windows64 url=https://github.com/secondlife/3p-webrtc-build/releases/download/m114.5735.08.73-alpha/webrtc-m114.5735.08.73-alpha.11958809572-windows64-11958809572.tar.zst hash_algorithm=sha1 hash=c7b329d6409576af6eb5b80655b007f52639c43b

# ##### 14. **Konfiguration des Builds**
# #####     - Führt `autobuild configure` mit Flags für Channel, Paketierung, Audiooptionen aus

echo -e "${GREEN}Konfiguration...${RESET}"

autobuild configure --config-file "$AUTO_BUILD_CONFIG" -A 64 -c ReleaseFS_open -- --package --chan WebRTC -DLL_TESTS:BOOL=FALSE -DFMOD:BOOL=OFF --openal

if [ $? -ne 0 ]; then
    echo -e "${RED}[FEHLER] Konfiguration fehlgeschlagen!${RESET}"
    exit 1
fi

# ##### 15. **Durchführung des Builds**
# #####     - Kompiliert den Viewer mit `autobuild build`

echo -e "${GREEN}Build...${RESET}"

autobuild build --config-file "$AUTO_BUILD_CONFIG" -A 64 -c ReleaseFS_open --no-configure --verbose

if [ $? -ne 0 ]; then
    echo -e "${RED}[FEHLER] Build fehlgeschlagen!${RESET}"
    exit 1
fi

# ##### 16. **Ermittlung des Release-Verzeichnisses**
# #####     - Findet das konkrete `Release`-Verzeichnis mit dem gebauten Viewer

echo -e "${GREEN}Suche nach Release-Verzeichnis...${RESET}"

if [ ! -d "$BUILD_DIR/phoenix-firestorm/build-vc170-64/newview/Release" ]; then
    echo -e "${RED}[FEHLER] Release-Verzeichnis nicht gefunden: $BUILD_DIR/phoenix-firestorm/build-vc170-64/newview/Release${RESET}"
    exit 1
fi
echo -e "${GREEN}• Release-Verzeichnis gefunden: $BUILD_DIR/phoenix-firestorm/build-vc170-64/newview/Release${RESET}"

# ##### 17. **Erstellung des NSIS-Installers**
# #####     - Führt `makensis.exe` mit der `.nsi`-Installerskriptdatei aus

echo -e "${GREEN}Erstelle NSIS-Installer...${RESET}"
echo "DLLs werden in die Package kopiert."

if [ ! -d "$BUILD_DIR/phoenix-firestorm/build-vc170-64/newview/Release" ]; then
    echo -e "${GREEN}Kopiere DLLs in das Release-Verzeichnis...${RESET}"
    cp "$SCRIPT_DIR/alut.dll" "$BUILD_DIR/phoenix-firestorm/build-vc170-64/newview/Release/"
    cp "$SCRIPT_DIR/OpenAL32.dll" "$BUILD_DIR/phoenix-firestorm/build-vc170-64/newview/Release/"
    autobuild package -A 64 --config-file autobuild.xml
else
    echo -e "${RED}[FEHLER] Release-Verzeichnis fehlt.${RESET}"
fi

# ##### 18 **Ausgabe der Konfigurationsdatei**
# ##### Für Debugging, um die Konfigurationsdatei auszugeben.

echo -e "${GREEN}Ausgabe der Konfigurationsdatei...${RESET}"

autobuild print --json my-config-file.json

# ##### 19. **Zusammenfassung und Ergebnisanzeige**
# #####     - Zeigt den Inhalt des Release-Verzeichnisses im Terminal und beendet das Skript

echo -e "${GREEN}✔ Paketierung abgeschlossen${RESET}"
echo -e "${BLUE}   Inhalt des Release-Verzeichnisses:${RESET}"
ls -la "$BUILD_DIR/phoenix-firestorm/build-vc170-64/newview/Release"
exit 1