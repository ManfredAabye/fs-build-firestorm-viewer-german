# **Build-Anleitung für Windows**

---

     0 cleaner.bat
     1 software_installer.bat 
     new_firestorm_buildingV2.bat

Ich habe fmod rausgenommen und OpenAL Sound eingefügt es wird alles gebaut nur werden 2 DLL Dateien nicht mit kopiert alut.dll und OpenAL32.dll.

Der link.exe fehler ist auf Github installation zurückzuführen wenn man im Programm Ordner link.exe in glink.exe umbenennt dann findet der Build Prozess nicht mehr den git link.exe.

sind unabhängige Skripte, die sich nicht gegenseitig aufrufen.

Folgendes Problem gibt es: Beim bauen zeigt der Buildvorgang 4 Fehler (Media?) an und weigert sich zu Bauen.

Wenn aber der Bauvorgang per Hand im Verzeichnis build-vc170-64 das Bauen von Hand 2 mal angestossen wird der Viewer gebaut:

## Funktion Firestorm Build-Skripte für Windows

### `0cleaner.bat`
- **Funktion**:  
  Entfernt den kompletten Firestorm-Build-Ordner.  
  *Es bleiben nur Dateien im Hauptverzeichnis zurück.*

---

### `1software_installer.bat`
- **Funktionen**:
  - Installiert benötigte Build-Tools:
    - CMake
    - Git
    - Visual Studio 2022 Community  
      *(Workload: "Desktop development with C++")*
  - Lädt alle Programmkomponenten von:
    - Git-Repositories
    - Offiziellen Quellen

---

### `2firestorm_build.bat`
- **Funktionen**:
  - Richtet Python-Virtualenv ein
  - Installiert spezifische Python-Version
  - Fügt erforderliche Pakete hinzu:
    - `llbase`
    - `llsd` 
    - `autobuild`

---

### `3firestorm_compiler.bat`
- **Funktionen**:
  - Erstellt die Binärdateien
  - Packt diese in:
     - Ein installierbares Paket
     - Ein portables Verzeichnis und Komprimiert das Ergebnis mit 7zip

---

### Ablauf:
1. `0cleaner.bat` → Bereinigung durch komplettes löschen
2. `1software_installer.bat` → Software-Installation  
3. `2firestorm_build.bat` → Umgebungssetup  
4. `3firestorm_compiler.bat` → Build & Packaging

---

Diese Seite beschreibt alle notwendigen Schritte, um den Firestorm-Viewer für Windows zu kompilieren. Für Build-Anleitungen bis (und einschließlich) Version 6.5.3 siehe die archivierte Version für das Bauen mit Python 2.7.

**Warnung**  
Bitte beachten Sie, dass wir keine Unterstützung für das selbstständige Kompilieren des Viewers anbieten. Es gibt jedoch eine Self-Compilers-Gruppe in Second Life, der Sie beitreten können, um Fragen zum Kompilieren des Viewers zu stellen: [Firestorm Self Compilers](https://example.com).

**Wichtig**  
Mit dem Merge von Linden Lab Release 6.6.16 ist es NICHT mehr möglich, 32-Bit-Builds zu erstellen! Ab jetzt sind nur noch 64-Bit-Builds möglich!

---

## Erforderliche Entwicklungstools installieren

Dies wird für das Kompilieren jedes Viewers benötigt, der auf dem Linden Lab Open-Source-Code basiert, und muss nur einmal durchgeführt werden.

Alle Installationen erfolgen mit Standardeinstellungen (sofern nicht anders angegeben) – wenn Sie diese ändern, sind Sie auf sich allein gestellt!

## Windows

- Installieren Sie Windows 10/11 64-Bit mit Ihrem eigenen Produktschlüssel.

### Microsoft Visual Studio 2022

- Installieren Sie Visual Studio 2022:
  - Führen Sie das Installationsprogramm als Administrator aus (Rechtsklick, "Als Administrator ausführen").
  - Aktivieren Sie auf der Registerkarte "Workloads" die Option "Desktopentwicklung mit C++".
  - Alle anderen Workload-Optionen können deaktiviert bleiben.

**Tipp**  
Wenn Sie keine kommerzielle Version von Visual Studio 2022 (z. B. Professional) besitzen, können Sie die Community-Version installieren.

#### Tortoise Git

- Laden Sie TortoiseGit 2.9.0 oder neuer (64-Bit) herunter und installieren Sie es.
  - Hinweis: Es gibt keine Option, es als Administrator zu installieren.
  - Verwenden Sie die Standardoptionen (Pfad, Komponenten usw.) für Tortoise Git selbst.
  - Irgendwann wird es Sie auffordern, Git für Windows herunterzuladen und zu installieren:
    - Sie können die Standardoptionen verwenden, AUSSER wenn es nach der "Konfiguration der Zeilenenden-Umwandlung" fragt: Hier MÜSSEN Sie "Checkout as-is, commit as-is" auswählen!

### CMake

- Laden Sie CMake 3.16.0 oder neuer herunter und installieren Sie es:
  - Hinweis: Es gibt keine Option, es als Administrator zu installieren.
  - Wählen Sie auf dem Bildschirm "Installationsoptionen" die Option "Add CMake to the system PATH for all users".
  - Verwenden Sie für alles andere die Standardoptionen (Pfad usw.).
  - Stellen Sie sicher, dass folgendes Verzeichnis zu Ihrem Pfad hinzugefügt wurde:
    - Für die 32-Bit-Version: `C:\Program Files (x86)\CMake\bin`
    - Für die 64-Bit-Version: `C:\Program Files\CMake\bin`

### Cygwin

- Laden Sie Cygwin 64 (64-Bit) herunter und installieren Sie es:
  - Führen Sie das Installationsprogramm als Administrator aus (Rechtsklick, "Als Administrator ausführen").
  - Verwenden Sie Standardoptionen (Pfad, Komponenten usw.), bis Sie zum Bildschirm "Select Packages" gelangen.
  - Fügen Sie zusätzliche Pakete hinzu:
    - `Devel/patch`
  - Verwenden Sie für alles andere die Standardoptionen.
  - Stellen Sie sicher, dass folgendes Verzeichnis zu Ihrem Pfad hinzugefügt wurde und dass es VOR `%SystemRoot%\system32` steht: `C:\Cygwin64\bin`.

### Python

- Laden Sie die neueste Version von Python 3 herunter und installieren Sie sie:
  - Führen Sie das Installationsprogramm als Administrator aus (Rechtsklick, "Als Administrator ausführen").
  - Aktivieren Sie "Add Python 3.10 to PATH".
  - Wählen Sie die Option "Customize Installation":
    - Stellen Sie sicher, dass "pip" aktiviert ist.
    - "Documentation", "tcl/tk and IDLE", "Python test suite" und "py launcher" werden nicht zum Kompilieren des Viewers benötigt, können aber ausgewählt werden, wenn Sie möchten.
    - Auf dem nächsten Bildschirm sollten die korrekten Optionen bereits aktiviert sein.
    - Legen Sie den benutzerdefinierten Installationspfad auf `C:\Python3` fest.
  - Stellen Sie sicher, dass folgendes Verzeichnis zu Ihrem Pfad hinzugefügt wurde: `C:\Python3`.

**Tipp**  
Unter Windows 10/11 können Sie auch den App-Alias für Python deaktivieren. Öffnen Sie die Windows-Einstellungen, suchen Sie nach "Manage app execution aliases" und deaktivieren Sie den Alias für "python3.exe".

---

## Zwischenprüfung

Überprüfen Sie, ob alles korrekt installiert wurde, indem Sie ein Cygwin-Terminal öffnen und folgende Befehle eingeben:

```bash
cmake --version
git --version
python --version
pip --version
```

Wenn alle sinnvolle Werte zurückgeben und keine "Command not found"-Fehler auftreten, ist alles in Ordnung.

**Hinweis**  
Das Cygwin-Terminal wird nur für Tests benötigt. Alle Befehle zum eigentlichen Bauen des Viewers werden in der Windows-Eingabeaufforderung ausgeführt.

---

## Autobuild einrichten

1. **Installieren Sie Autobuild**:  
   Sie können Autobuild und seine Abhängigkeiten mit der `requirements.txt`-Datei aus dem Repository installieren. Dies stellt sicher, dass dieselben Versionen wie bei unseren offiziellen Builds verwendet werden.
   - Öffnen Sie die Windows-Eingabeaufforderung und geben Sie ein:

     ```bash
     pip install -r requirements.txt
     ```

   - Autobuild wird installiert. Frühere Versionen von Autobuild konnten manuell in den Pfad eingefügt werden, aber das funktioniert nicht mehr – Autobuild MUSS wie hier beschrieben installiert werden.
   - Geben Sie zusätzlich ein:

     ```bash
     pip install git+https://github.com/secondlife/autobuild.git#egg=autobuild
     ```

2. **Setzen Sie die Umgebungsvariable `AUTOBUILD_VSVER` auf `170`** (170 = Visual Studio 2022).

3. **Überprüfen Sie die Autobuild-Version**: Sie sollte "autobuild 3.8" oder höher sein:

   ```bash
   autobuild --version
   ```

---

### NSIS (optional)

- Wenn Sie den Viewer packen und eine Installationsdatei erstellen möchten, müssen Sie NSIS von der offiziellen Website installieren.
- Dies ist nur erforderlich, wenn Sie einen tatsächlichen Viewer-Installer erstellen oder die NSIS-Installer-Logik ändern möchten.

**Wichtig**  
Wenn Sie einen Viewer auf Basis eines Standes vor dem Bugsplat-Merge packen möchten, müssen Sie die Unicode-Version von NSIS von hier installieren – die Version von der NSIS-Website funktioniert NICHT!

---

### Viewer-Build-Variablen einrichten

Um das Bauen von zusammengehörigen Paketen (wie den Viewer und alle benötigten Bibliotheken) mit denselben Kompilierungsoptionen zu vereinfachen, erwartet Autobuild eine Datei mit Variablendefinitionen. Diese kann über die Umgebungsvariable `AUTOBUILD_VARIABLES_FILE` festgelegt werden.

1. Klonen Sie das Build-Variablen-Repository:

   ```bash
   git clone https://github.com/FirestormViewer/fs-build-variables.git <Pfad-zur-Variablendatei>
   ```

2. Setzen Sie die Umgebungsvariable `AUTOBUILD_VARIABLES_FILE` auf:  
   `<Pfad-zur-Variablendatei>\variables`

---

### Visual Studio 2022 konfigurieren (optional)

1. Starten Sie die IDE.
2. Navigieren Sie zu `Tools > Options > Projects and Solutions > Build and Run` und setzen Sie die maximale Anzahl paralleler Projektbuilds auf 1.

---

### Quellcode-Verzeichnis einrichten

Planen Sie Ihre Verzeichnisstruktur im Voraus. Wenn Sie Änderungen oder Patches erstellen möchten, sollten Sie für jede Änderung eine separate Kopie des unveränderten Quellcodes klonen. Wenn Sie nur gelegentlich kompilieren, reicht ein Verzeichnis. In diesem Dokument wird angenommen, dass Sie einen Ordner `c:\firestorm` erstellen.

```bash
c:
cd \firestorm
git clone https://github.com/FirestormViewer/phoenix-firestorm.git
```

---

### Drittanbieter-Bibliotheken vorbereiten

Die meisten benötigten Bibliotheken werden automatisch heruntergeladen und während der Kompilierung in das Build-Verzeichnis installiert. Einige müssen manuell vorbereitet werden und sind normalerweise nicht erforderlich, wenn eine Open-Source-Konfiguration (`ReleaseFS_open`) verwendet wird.

**Wichtig**  
Wenn Sie die Bibliotheken manuell bauen, müssen Sie die richtige Version (32-Bit für 32-Bit-Viewer, 64-Bit für 64-Bit-Viewer) erstellen!

#### FMOD Studio mit Autobuild

Wenn Sie FMOD Studio für die Soundwiedergabe im Viewer verwenden möchten, müssen Sie eine eigene Kopie herunterladen. FMOD Studio kann hier heruntergeladen werden (ein Konto ist erforderlich).

**Wichtig**  
Stellen Sie sicher, dass Sie die FMOD Studio API und nicht das FMOD Studio Tool herunterladen!

```bash
c:
cd \firestorm
git clone https://github.com/FirestormViewer/3p-fmodstudio.git
```

1. Kopieren Sie die heruntergeladene FMOD Studio-Installationsdatei in das Stammverzeichnis des Repositorys.
2. Passen Sie die Datei `build-cmd.sh` im Stammverzeichnis an und setzen Sie die korrekte Versionsnummer entsprechend der heruntergeladenen Version. Ganz oben finden Sie die FMOD Studio-Version, die Sie packen möchten (eine kurze Version ohne Trennzeichen und eine lange Version):

```bash
FMOD_VERSION="20102"
FMOD_VERSION_PRETTY="2.01.02"
```

Führen Sie dann in der Windows-Eingabeaufforderung folgende Befehle aus:

```bash
c:
cd \firestorm\3p-fmodstudio
autobuild build -A 64 --all
autobuild package -A 64 --results-file result.txt
```

Während des `autobuild build`-Befehls könnte Windows nach einer Bestätigung fragen, da das FMOD Studio-Installationsprogramm ausgeführt wird. Erlauben Sie diese Änderungen.

Am Ende der Ausgabe sehen Sie den Paketnamen:

```bash
wrote  C:\firestorm\3p-fmodstudio\fmodstudio-{version#}-windows64-{build_id}.tar.bz2''
```

Dabei ist `{version#}` die FMOD Studio-Version (z. B. `2.01.02`) und `{build_id}` eine interne Build-ID des Pakets. Zusätzlich wird eine Datei `result.txt` erstellt, die den MD5-Hash des Pakets enthält, den Sie im nächsten Schritt benötigen.

```bash
cd \firestorm\phoenix-firestorm
cp autobuild.xml my_autobuild.xml
set AUTOBUILD_CONFIG_FILE=my_autobuild.xml
```

Kopieren Sie den FMOD Studio-Pfad und den MD5-Wert aus dem Paketierungsprozess in diesen Befehl:

```bash
autobuild installables edit fmodstudio platform=windows64 hash=<MD5-Wert> url=file:///<FMOD-Pfad>
```

Beispiel:

```bash
autobuild installables edit fmodstudio platform=windows64 hash=a0d1821154e7ce5c418e3cdc2f26f3fc url=file:///C:/firestorm/3p-fmodstudio/fmodstudio-2.01.02-windows-192171947.tar.bz2
```

**Hinweis**  
Das Kopieren von `autobuild.xml` und das Anpassen der Kopie in einem geklonten Repository ist aufwändig, aber dies ist die einzige Möglichkeit, um sicherzustellen, dass Sie Änderungen an `autobuild.xml` aus dem Haupt-Repository übernehmen und keine modifizierte Version hochladen, wenn Sie ein `git push` durchführen.

---

### Viewer konfigurieren

Öffnen Sie die Windows-Eingabeaufforderung.

Wenn Sie FMOD Studio verwenden und die vorherigen Schritte durchgeführt haben UND jetzt ein neues Terminal verwenden, müssen Sie die Umgebungsvariable zurücksetzen:

```bash
set AUTOBUILD_CONFIG_FILE=my_autobuild.xml
```

Dann geben Sie ein:

```bash
c:
cd \firestorm\phoenix-firestorm
autobuild configure -A 64 -c ReleaseFS_open
```

Dies konfiguriert Firestorm mit allen Standardeinstellungen und ohne Drittanbieter-Bibliotheken.

Verfügbare vordefinierte Firestorm-spezifische Build-Targets:

- `ReleaseFS` (enthält KDU, FMOD)
- `ReleaseFS_open` (kein KDU, kein FMOD)
- `RelWithDebInfoFS_open` (kein KDU, kein FMOD)

**Tipp**  
Die erste Konfiguration des Viewers dauert eine Weile, da alle benötigten Bibliotheken heruntergeladen werden. Der Fortschritt ist standardmäßig ausgeblendet. Wenn Sie den Fortschritt sehen möchten, können Sie die Option `-v` verwenden:

```bash
autobuild configure -A 64 -v -c ReleaseFS_open
```

---

### Konfigurationsoptionen

Es gibt mehrere Schalter, um den Konfigurationsprozess anzupassen. Der Name jedes Schalters wird gefolgt von seinem Typ und dem gewünschten Wert.

- `-A <Architektur>` legt die Zielarchitektur fest (32-Bit oder 64-Bit; Standard ist 32-Bit, wenn weggelassen).
- `--fmodstudio` steuert, ob das FMOD Studio-Paket in den Viewer eingebunden wird. Sie müssen die FMOD Studio-Installationsschritte durchgeführt haben, damit dies funktioniert.
- `--package` sorgt dafür, dass alle Dateien in das Ausgabeverzeichnis des Viewers kopiert werden. Sie können den kompilierten Viewer nicht starten, wenn Sie dies nicht aktivieren oder den Viewer in VS kompilieren.
- `--chan <Kanalname>` ermöglicht es, einen benutzerdefinierten Kanalnamen für den Viewer festzulegen.
- `-LL_TESTS:BOOL=<bool>` steuert, ob Tests kompiliert und ausgeführt werden. Es gibt viele davon, daher wird empfohlen, sie auszuschließen, es sei denn, Sie benötigen sie.

**Tipp**  
`OFF` und `NO` sind dasselbe wie `FALSE`; alles andere wird als `TRUE` betrachtet.

**Beispiele:**

- Um einen 64-Bit-Viewer mit FMOD Studio und Installer-Paket zu bauen:

  ```bash
  autobuild configure -A 64 -c ReleaseFS_open -- --fmodstudio --package --chan MyViewer -DLL_TESTS:BOOL=FALSE
  ```

- Um einen 64-Bit-Viewer ohne FMOD Studio und ohne Installer-Paket zu bauen:

  ```bash
  autobuild configure -A 64 -c ReleaseFS_open -- --chan MyViewer -DLL_TESTS:BOOL=FALSE
  ```

---

### Viewer kompilieren

Es gibt zwei Möglichkeiten, den Viewer zu kompilieren: Über die Windows-Eingabeaufforderung oder innerhalb von Visual Studio.

#### Bauen über die Windows-Eingabeaufforderung

Wenn Sie FMOD Studio verwenden und die vorherigen Schritte durchgeführt haben UND jetzt ein neues Terminal verwenden, setzen Sie die Umgebungsvariable zurück:

```bash
set AUTOBUILD_CONFIG_FILE=my_autobuild.xml
```

Führen Sie dann den Autobuild-Build-Befehl aus. Verwenden Sie denselben Architekturparameter wie bei der Konfiguration:

```bash
autobuild build -A 64 -c ReleaseFS_open --no-configure
```

Die Kompilierung dauert eine Weile.

#### Bauen in Visual Studio

Im Firestorm-Quellordner finden Sie einen Ordner namens `build-vc170-<Architektur>`, wobei `<Architektur>` entweder `32` oder `64` ist, je nach Ihrer Konfiguration. Darin befindet sich die Visual Studio-Projektmappendatei `Firestorm.sln`.

1. Doppelklicken Sie auf `Firestorm.sln`, um die Projektmappe in Visual Studio zu öffnen.
2. Wählen Sie im Menü `Build -> Build Solution`.
3. Warten Sie, bis der Build abgeschlossen ist.

---

### Fehlerbehebung

#### `SystemRootsystem32: unbound variable`

Wenn Sie den Autobuild-Build-Befehl ausführen, könnte ein Fehler wie dieser auftreten:

```bash
../build.cmd.sh line 200: SystemRootsystem32: unbound variable
```

Dieser Fehler wird durch die Reihenfolge der Einträge in der Windows-`PATH`-Umgebungsvariable verursacht. Autobuild exportiert alle Pfade aus `PATH` in Cygwin-Pfade und Variablen. Da diese Windows-Pfade auch Variablen wie `%SystemRoot%` enthalten können, ist es wichtig, die Abhängigkeitsreihenfolge beizubehalten. Beispiel:

```batch
%SystemRoot%
%SystemRoot%\system32
%SystemRoot%\System32\Wbem
```

Stellen Sie sicher, dass diese Einträge die ersten in der `PATH`-Umgebungsvariable sind.

---

## Windows 11 Batch-Skript

Hier ist ein Windows 11 Batch-Skript, das den Firestorm Viewer in einer isolierten Virtual Environment-Umgebung kompiliert. Das Skript automatisiert die Installation der benötigten Tools, richtet Python-Umgebungen ein und führt den Build-Prozess durch.

## Anleitung zur Verwendung

1. Kopieren Sie das Skript `firestorm_build.bat`
2. Führen Sie es als Administrator aus (Rechtsklick → "Als Administrator ausführen")
3. Sie sollten die Batch ausgabe in der Datei fs-compiling.log speichern und diese nach warning und error durchsuchen um diese schritt für schritt zu beheben
4. Folgen Sie den Anweisungen (besonders für FMOD Studio)

### Konfigurationsoptionen Windows 11 Batch

- `BUILD_DIR`: Arbeitsverzeichnis für den Build ist der Pfad des Skriptes
- `PYTHON_VERSION`: Python-Version (3.10 empfohlen)
- `ARCH`: Zielarchitektur (64 oder 32)
- `CONFIG`: Build-Konfiguration (`ReleaseFS_open`, `ReleaseFS`, etc.)
- `FMOD_ENABLED`: FMOD Studio-Unterstützung (`true`/`false`)

### Features Windows 11 Batch

- Automatische Installation aller Abhängigkeiten (via Chocolatey)
- Isolierte Python-Umgebung (virtualenv)
- Unterstützung für FMOD Studio (manueller Download erforderlich)
- Automatische Build-Konfiguration
- Paketierung des fertigen Viewers

### Hinweise Windows 11 Batch

- Für FMOD Studio müssen Sie die API manuell von fmod.com herunterladen
- Der Build-Vorgang kann mehrere Stunden dauern
- Stellen Sie sicher, dass mindestens 20GB freier Speicherplatz vorhanden sind

---

# TODO

## 🧭 Struktur des Firestorm Build- und Paketierungs-Skripts

| Abschnitt | Funktion / Zweck | Beschreibung |
|----------:|------------------|--------------|
| **0** | 🧾 **Meta & Hinweise** | Versionsinfo, Autor, manuelle Hinweise zu DLL-Problemen & link.exe |
| **1** | 🎨 **Terminalfarben definieren** | ANSI-Farben für saubere visuelle Ausgabe |
| **2** | ⚙️ **Umgebungsvariablen & Verzeichnisse setzen** | Pfade wie `%SCRIPT_DIR%`, `%BUILD_DIR%`, `%VENV_DIR%`, `%CONFIG%`, `%AUTO_BUILD_CONFIG%` usw. |
| **3** | 📁 **Arbeitsverzeichnis vorbereiten** | Erstellen von `%BUILD_DIR%` |
| **4** | 🐍 **Python Virtualenv einrichten und aktivieren** | Umgebung anlegen, Pakete installieren (`llbase`, `llsd`, `autobuild`) |
| **5** | 📦 **Repos klonen** | Holt `phoenix-firestorm` & `fs-build-variables` aus Git |
| **6** | 🧩 **Build-Variablen & Dependencies** | Setzt `AUTOBUILD_VSVER`, installiert `requirements.txt` |
| **7** | 🔁 **autobuild.xml vorbereiten** | Tauscht `autobuild.xml` gegen `openal_autobuild.xml` aus |
| **8** | 🛠 **Visual Studio Umgebung aktivieren** | Findet und lädt `vcvarsall.bat` von VS2022 |
| **9** | 🐍 **Python-Umgebung absichern** | Re-Aktivierung der `venv`, falls nötig |
| **10** | 🧪 **autobuild.xml prüfen** | Sicherheitsprüfung: Datei vorhanden? Sonst Abbruch |
| **11** | 📂 **Wechsel ins Quellverzeichnis** | `cd` nach `phoenix-firestorm` |
| **12** | 🔧 **Konfiguration des Builds** | Führt `autobuild configure` mit den gewünschten Flags aus |
| **13** | 🧱 **Build-Vorgang starten** | Kompilierung via `autobuild build` |
| **14** | 📍 **Release-Verzeichnis erkennen** | Dynamische Suche nach `build-vc*-64\newview\Release` |
| **15** | 🧬 **DLLs kopieren** | `alut.dll` und `OpenAL32.dll` ins Release-Verzeichnis übertragen |
| **16** | 📦 **Portable ZIP erzeugen** | Erstellt `Firestorm-OpenSim-Portable.zip` mit allen Build-Dateien |
| **17** | 🛠 **NSIS-Installer erstellen** | Führt `makensis.exe` mit `.nsi`-Skript aus |
| **18** | 🧾 **Abschluss & Ausgabeübersicht** | Zeigt erfolgreich erstellte Dateien im Zielverzeichnis an |
