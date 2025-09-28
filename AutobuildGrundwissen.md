# Autobuild

Minimalistisches Grundwissen in deutsch.

## 📝 Autobuild edit – Second Life Wiki

Der Befehl `autobuild edit` dient dazu, die Definition des aktuellen Pakets zu bearbeiten. Der Unterbefehl (Subcommand) gibt an, was bearbeitet werden soll, und kann einer der folgenden sein:

- `build`: Konfiguriert `autobuild build`
- `configure`: Konfiguriert `autobuild configure`
- `package`: Konfiguriert Informationen über das Paket
- `platform`: Konfiguriert plattformspezifische Einstellungen

---

### ⚙️ Standardoptionen

| Option        | Kürzel | Wert   | Beschreibung                                 |
|---------------|--------|--------|----------------------------------------------|
| `--debug`     | `-d`   | Keine  | Zeigt Debug-Ausgaben                         |
| `--dry-run`   | `-n`   | Keine  | Führt das Tool im „Trockenlauf“-Modus aus, falls verfügbar |
| `--help`      | `-h`   | Keine  | Zeigt die Hilfeinformationen                 |
| `--quiet`     | `-q`   | Keine  | Zeigt minimale Ausgaben                      |
| `--verbose`   | `-v`   | Keine  | Zeigt ausführliche Ausgaben                  |

---

### 🔧 Befehls-spezifische Optionen

| Option           | Kürzel | Wert           | Beschreibung                                 |
|------------------|--------|----------------|----------------------------------------------|
| `--delete`       | –      | ?              | Löscht einen Eintrag (Details nicht spezifiziert) |
| `--config-file`  | –      | `config_file`  | Verwendet die angegebene Konfigurationsdatei |

---

### 📦 Argumente für Unterbefehle

#### Für `build`

- `name`: Name der Konfiguration
- `platform`: Zielplattform der Konfiguration
- `command`: Auszuführender Befehl
- `options`: Optionen für den Befehl
- `arguments`: Argumente für den Befehl

#### Für `package`

- `name`: Name des Pakets
- `description`: Beschreibung des Pakets
- `copyright`: Copyright-Angabe (falls zutreffend)
- `license`: Lizenztyp (falls zutreffend)
- `license_file`: Pfad zur Lizenzdatei relativ zum Paketverzeichnis
- `version_file`: Pfad zu einer Datei, die die Versionsnummer nach dem Build enthält

#### Für `platform`

- `name`: Name der Plattform
- `build_directory`: Build-Verzeichnis

---

## 🔧 Autobuild konfigurieren – Second Life Wiki

Der Befehl `autobuild configure` wird verwendet, um Plattform-Ziele zu konfigurieren.

### 🛠️ Standardoptionen

| Option        | Kürzel | Wert   | Beschreibung                                 |
|---------------|--------|--------|----------------------------------------------|
| `--debug`     | `-d`   | Keine  | Zeigt Debug-Ausgaben                         |
| `--dry-run`   | `-n`   | Keine  | Führt das Tool im „Trockenlauf“-Modus aus, falls verfügbar |
| `--help`      | `-h`   | Keine  | Zeigt die Hilfeinformationen                 |
| `--quiet`     | `-q`   | Keine  | Zeigt minimale Ausgaben                      |
| `--verbose`   | `-v`   | Keine  | Zeigt ausführliche Ausgaben                  |

---

### ⚙️ Befehls-spezifische Optionen

| Option               | Kürzel | Wert             | Beschreibung                                                                 |
|----------------------|--------|------------------|------------------------------------------------------------------------------|
| `--all`              | `-a`   | Keine            | Baut alle Konfigurationen                                                   |
| `--config-file`      | –      | `config_file`    | Verwendet die angegebene Konfigurationsdatei. Standard ist `$AUTOBUILD_CONFIG_FILE` oder `autobuild.xml`. |
| `--configuration`    | `-c`   | `config`         | Baut eine bestimmte Konfiguration (kann auch als kommagetrennte Liste angegeben werden über `$AUTOBUILD_CONFIGURATION`) |
| `--`                 | –      | `Option`         | Übergibt eine Option direkt an den Konfigurationsbefehl. Beispiel: `-- -DFMOD:BOOL=ON` |
| `--address-size`     | –      | `bits` (32/64)   | Gibt die Adressgröße an. Standard ist die Umgebungsvariable `AUTOBUILD_ADDRSIZE`, falls vorhanden, sonst 32. |

---

## 📦 Autobuild installables – Second Life Wiki

Mit dem Befehl `autobuild installables` kannst du Abhängigkeiten („Installables“) für das aktuelle Paket definieren, die beim Ausführen von `autobuild install` verwendet werden.

---

### 🛠️ Befehlsstruktur

```bash
autobuild installables [Optionen] ... [Befehl] [Name] [Argument(e)]
```

- **Befehl**: `add`, `remove`, `edit` oder `print`
- **Name**: Name des Installable-Pakets
- **Argument**: Schlüssel=Wert-Paar zur Angabe eines Attributs

---

### 🔑 Unterstützte Attribute

| Attribut         | Beschreibung                                                                 |
|------------------|------------------------------------------------------------------------------|
| `creds`          | Optionales Authentifizierungsverfahren für private Pakete (`github`, `gitlab`) |
| `url`            | Download-URL                                                                 |
| `hash`           | Datei-Hash                                                                   |
| `hash_algorithm` | Algorithmus zur Berechnung des Hash-Werts (`md5`, `blake2b`)                 |

---

### 🔐 Private Pakete

Ab Version **v3.5.0** unterstützt Autobuild das Herunterladen von Paketen aus privaten GitHub- und GitLab-Repositories.

- Das Paket muss mit dem Attribut `creds` versehen sein, z. B. `creds=github`
- Die Authentifizierung erfolgt über folgende Umgebungsvariablen:

```bash
AUTOBUILD_GITHUB_TOKEN
AUTOBUILD_GITLAB_TOKEN
```

---

### ⚙️ Standardoptionen installables

| Option        | Kürzel | Wert   | Beschreibung                                 |
|---------------|--------|--------|----------------------------------------------|
| `--debug`     | `-d`   | Keine  | Zeigt Debug-Ausgaben                         |
| `--dry-run`   | `-n`   | Keine  | Führt das Tool im „Trockenlauf“-Modus aus    |
| `--help`      | `-h`   | Keine  | Zeigt die Hilfeinformationen                 |
| `--quiet`     | `-q`   | Keine  | Minimale Ausgabe                             |
| `--verbose`   | `-v`   | Keine  | Ausführliche Ausgabe                         |

---

### 🔧 Befehls-spezifische Optionen installables

| Option            | Kürzel | Wert         | Beschreibung                                                                 |
|-------------------|--------|--------------|------------------------------------------------------------------------------|
| `--config-file`   | –      | `config_file`| Pfad zur Konfigurationsdatei (Standard: `$AUTOBUILD_CONFIG_FILE` oder `autobuild.xml`) |
| `--archive`       | `-a`   | `archive`    | Archivname – leitet Installable-Attribute aus dem Archiv ab                 |

---

### 📋 Beispiel

```bash
autobuild installables edit otherpkg url=<URL>
```

Dieser Befehl bearbeitet das Installable `otherpkg` und setzt dessen Download-URL.

---

## 📦 Autobuild install – Second Life Wiki

Der Befehl `autobuild install` installiert Artefakte von Abhängigkeits-Paketen, die während des Builds des aktuellen Pakets benötigt werden.

---

### 📥 Argument: `package`

- **package**: Name des Pakets, das installiert werden soll.
- Du kannst ein oder mehrere Paketnamen angeben, getrennt durch Leerzeichen – oder gar keine.
- Wenn keine Pakete angegeben werden, versucht `autobuild`, alle Pakete zu installieren, die im Abschnitt `installables` der Konfigurationsdatei aufgeführt sind.

---

### 🔐 Private Pakete install

Falls ein Paket GitHub- oder GitLab-Zugangsdaten benötigt, müssen folgende Umgebungsvariablen mit gültigen persönlichen Zugriffstokens gesetzt werden:

- `AUTOBUILD_GITHUB_TOKEN`
- `AUTOBUILD_GITLAB_TOKEN`

---

### ⚙️ Standardoptionen install

| Option        | Kürzel | Wert   | Beschreibung                                 |
|---------------|--------|--------|----------------------------------------------|
| `--debug`     | `-d`   | Keine  | Zeigt Debug-Ausgaben                         |
| `--dry-run`   | `-n`   | Keine  | Führt das Tool im „Trockenlauf“-Modus aus    |
| `--help`      | `-h`   | Keine  | Zeigt die Hilfeinformationen                 |
| `--quiet`     | `-q`   | Keine  | Minimale Ausgabe                             |
| `--verbose`   | `-v`   | Keine  | Ausführliche Ausgabe                         |

---

### 🔧 Befehls-spezifische Optionen install

| Option                  | Kürzel | Wert             | Beschreibung                                                                 |
|-------------------------|--------|------------------|------------------------------------------------------------------------------|
| `--config-file`         | –      | `filename`       | Verwendet die angegebene Konfigurationsdatei (Standard: `$AUTOBUILD_CONFIG_FILE` oder `autobuild.xml`) |
| `--export-manifest`     | –      | Keine            | Gibt das Installationsmanifest auf `stdout` aus und beendet das Programm    |
| `--installed-manifest`  | –      | `filename`       | Speichert, was installiert wurde, in der angegebenen Datei                   |
| `--install-dir`         | –      | `dir`            | Entpackt installierte Dateien in das angegebene Verzeichnis                 |
| `--list`                | –      | Keine            | Listet die Archive, die in der Paketdatei angegeben sind                    |
| `--list-installed`      | –      | Keine            | Listet die Namen der installierten Pakete und beendet das Programm          |
| `--list-licenses`       | –      | Keine            | Listet bekannte Lizenzen und beendet das Programm                           |
| `--platform`            | `-p`   | `platform`       | Überschreibt die automatisch ermittelte Plattform                           |
| `--list-install-urls`   | –      | Keine            | Listet die Archiv-URLs aller installierten Pakete                           |
| `--list-dirty`          | –      | Keine            | Listet die Namen der „dirty“ installierten Pakete                           |
| `--what-installed`      | –      | `file-path`      | Zeigt, welches Archiv eine bestimmte Datei installiert hat – nützlich bei Konflikten |
| `--versions`            | –      | Keine            | Gibt Paketnamen und Versionsnummern aus                                     |
| `--copyrights`          | –      | Keine            | Gibt Paketnamen und Copyright-Angaben aus                                   |
| `--local`               | –      | `archive`        | Installiert eine angegebene Archivdatei anstelle der Version aus der Konfiguration. Markiert den Build als „dirty“, ist aber nützlich für die Entwicklung. |

---

## 🧹 Autobuild uninstall – Second Life Wiki

Der Befehl `autobuild uninstall` entfernt Artefakte, die zuvor mit dem Befehl `autobuild install` installiert wurden.

---

### 🛠️ Befehlsstruktur uninstall

```bash
autobuild uninstall [Option [Wert]] ... [Paket [Paket ...]]
```

---

### 📋 Argumente uninstall

| Argument | Beschreibung                                 |
|----------|----------------------------------------------|
| `package` | Liste der zu deinstallierenden Pakete        |

---

### ⚙️ Standardoptionen uninstall

| Option        | Kürzel | Wert   | Beschreibung                                 |
|---------------|--------|--------|----------------------------------------------|
| `--debug`     | `-d`   | Keine  | Zeigt Debug-Ausgaben                         |
| `--dry-run`   | `-n`   | Keine  | Führt das Tool im „Trockenlauf“-Modus aus    |
| `--help`      | `-h`   | Keine  | Zeigt die Hilfeinformationen                 |
| `--quiet`     | `-q`   | Keine  | Minimale Ausgabe                             |
| `--verbose`   | `-v`   | Keine  | Ausführliche Ausgabe                         |

---

### 🔧 Befehls-spezifische Optionen uninstall

| Option                | Kürzel | Wert         | Beschreibung                                                                 |
|-----------------------|--------|--------------|------------------------------------------------------------------------------|
| `--config-file`       | –      | `Dateiname`  | Konfigurationsdatei, die beschreibt, was installiert wurde (Standard: `$AUTOBUILD_CONFIG_FILE` oder `autobuild.xml`) |
| `--installed-manifest`| –      | `Dateiname`  | Datei, in der festgehalten wird, was installiert wurde                       |
| `--install-dir`       | –      | `Verzeichnis`| Speicherort der Standarddatei `--installed-manifest`                         |

---

## 🛠️ Autobuild build – Second Life Wiki

Der Befehl `autobuild build` wird verwendet, um das aktuelle Paket zu bauen und die erzeugten Artefakte in das Build-Verzeichnis zu kopieren, damit sie vom Befehl `autobuild package` verwendet werden können.

---

### ⚙️ Standardoptionen build

| Option        | Kürzel | Wert   | Beschreibung                                 |
|---------------|--------|--------|----------------------------------------------|
| `--debug`     | `-d`   | Keine  | Zeigt Debug-Ausgaben                         |
| `--dry-run`   | `-n`   | Keine  | Führt das Tool im „Trockenlauf“-Modus aus, falls verfügbar |
| `--help`      | `-h`   | Keine  | Zeigt die Hilfeinformationen                 |
| `--quiet`     | `-q`   | Keine  | Zeigt minimale Ausgaben                      |
| `--verbose`   | `-v`   | Keine  | Zeigt ausführliche Ausgaben                  |

---

### 🔧 Befehls-spezifische Optionen build

| Option               | Kürzel | Wert             | Beschreibung                                                                 |
|----------------------|--------|------------------|------------------------------------------------------------------------------|
| `--all`              | `-a`   | Keine            | Baut alle Konfigurationen                                                   |
| `--config-file`      | –      | `config-file`    | Verwendet die angegebene Konfigurationsdatei                                |
| `--configuration`    | `-c`   | `config`         | Baut eine bestimmte Konfiguration                                           |
| `--no-configure`     | –      | Keine            | Verhindert die automatische Ausführung von `configure` vor dem Build        |
| `--`                 | –      | `Option`         | Übergibt eine Option direkt an den Build-Befehl. Beispiel: `-- -j1`         |
| `--id`               | –      | `build-id`       | Eindeutige ID für diesen Build. Standard ist die Umgebungsvariable `AUTOBUILD_BUILD_ID`, falls vorhanden, sonst ein Zeitstempel (mit Warnung) |
| `--address-size`     | –      | `bits` (32/64)   | Gibt die Adressgröße an. Standard ist die Umgebungsvariable `AUTOBUILD_ADDRSIZE`, falls vorhanden, sonst 32 |

---

## 📦 Autobuild manifest – Second Life Wiki

Der Befehl `autobuild manifest` legt fest, welche Artefakte durch den Befehl `autobuild package` verpackt werden sollen.

---

### 🛠️ Befehlsstruktur manifest

```bash
autobuild manifest [Option [Wert]] ... [Befehl] [Muster [Muster ...]]
```

- **Befehl**: `add`, `remove`, `clear` oder `print`
- **Muster**: Dateimuster (z. B. `*.dll`, `bin/*`) zur Auswahl von Dateien

---

### 🔧 Argumente manifest

| Argument | Beschreibung                                      |
|----------|---------------------------------------------------|
| `command` | Der Manifest-Befehl (`add`, `remove`, `clear`, `print`) |
| `pattern` | Dateimuster zur Auswahl von Artefakten            |

---

### ⚙️ Standardoptionen manifest

| Option        | Kürzel | Wert   | Beschreibung                                 |
|---------------|--------|--------|----------------------------------------------|
| `--debug`     | `-d`   | Keine  | Zeigt Debug-Ausgaben                         |
| `--dry-run`   | `-n`   | Keine  | Führt das Tool im „Trockenlauf“-Modus aus    |
| `--help`      | `-h`   | Keine  | Zeigt die Hilfeinformationen                 |
| `--quiet`     | `-q`   | Keine  | Minimale Ausgabe                             |
| `--verbose`   | `-v`   | Keine  | Ausführliche Ausgabe                         |

---

### 🔧 Befehls-spezifische Optionen manifest

| Option            | Kürzel | Wert         | Beschreibung                                                                 |
|-------------------|--------|--------------|------------------------------------------------------------------------------|
| `--config-file`   | –      | `config_file`| Pfad zur Konfigurationsdatei (Standard: `$AUTOBUILD_CONFIG_FILE` oder `autobuild.xml`) |
| `--platform`      | `-p`   | `platform`   | Plattformname – Manifest für bestimmte Plattform bearbeiten                 |

---

## 📦 Autobuild package – Second Life Wiki

Der Befehl `autobuild package` erstellt ein Paketarchiv zur Verteilung, das die Artefakte enthält, die durch den Befehl `autobuild build` erzeugt wurden.

---

### 🛠️ Befehlsstruktur package

```bash
autobuild package [Option [Wert]] ...
```

---

### ⚙️ Standardoptionen package

| Option        | Kürzel | Wert   | Beschreibung                                 |
|---------------|--------|--------|----------------------------------------------|
| `--debug`     | `-d`   | Keine  | Zeigt Debug-Ausgaben                         |
| `--dry-run`   | `-n`   | Keine  | Führt das Tool im „Trockenlauf“-Modus aus    |
| `--help`      | `-h`   | Keine  | Zeigt die Hilfeinformationen                 |
| `--quiet`     | `-q`   | Keine  | Minimale Ausgabe                             |
| `--verbose`   | `-v`   | Keine  | Ausführliche Ausgabe                         |

---

### 🔧 Befehls-spezifische Optionen package

| Option              | Kürzel | Wert        | Beschreibung                                                                 |
|---------------------|--------|-------------|------------------------------------------------------------------------------|
| `--config-file`     | –      | `Dateiname` | Konfigurationsdatei, die beschreibt, wie das Paket gebaut wird (Standard: `$AUTOBUILD_CONFIG_FILE` oder `autobuild.xml`) |
| `--archive-name`    | –      | `Dateiname` | Name des zu erstellenden Paketarchivs                                       |
| `--platform`        | `-p`   | `Plattform` | Plattformname – überschreibt die aktuelle Arbeitsplattform                   |

---

---

---

---

## 🖨️ Autobuild print – Second Life Wiki

Der Befehl `autobuild print` zeigt eine menschenlesbare Ansicht der Paketdefinition im aktuellen Paket an.

---

### 🛠️ Befehlsstruktur print

```bash
autobuild print [Option [Wert]] ...
```

---

### 📋 Beschreibung

Dieser Befehl dient dazu, die Inhalte und Konfigurationen eines Autobuild-Pakets übersichtlich darzustellen. Er kann auch verwendet werden, um die Ausgabe im JSON-Format zu erhalten.

---

### ⚙️ Standardoptionen print

| Option        | Kürzel | Wert   | Beschreibung                                 |
|---------------|--------|--------|----------------------------------------------|
| `--debug`     | `-d`   | Keine  | Zeigt Debug-Ausgaben                         |
| `--dry-run`   | `-n`   | Keine  | Führt das Tool im „Trockenlauf“-Modus aus    |
| `--help`      | `-h`   | Keine  | Zeigt die Hilfeinformationen                 |
| `--quiet`     | `-q`   | Keine  | Minimale Ausgabe                             |
| `--verbose`   | `-v`   | Keine  | Ausführliche Ausgabe                         |

---

### 🔧 Befehls-spezifische Optionen print

| Option            | Kürzel | Wert         | Beschreibung                                                                 |
|-------------------|--------|--------------|------------------------------------------------------------------------------|
| `--config-file`   | –      | `Dateiname`  | Gibt die zu verwendende Konfigurationsdatei an                              |
| `--json`          | –      | Keine        | Gibt die Ausgabe im JSON-Format aus                                         |

---

## 🧪 Autobuild source environment – Second Life Wiki

Der Befehl `autobuild source_environment` zeigt die Shell-Umgebungsvariablen an, die von Autobuild-basierten Build-Skripten verwendet werden sollen.

Du kannst die Ausgabe entweder mit `eval` ausführen:

```bash
eval "$(autobuild source_environment)"
```

… oder sie direkt in die laufende Shell „sourcen“.

---

### ⚙️ Standardoptionen source environment

| Option        | Kürzel | Wert   | Beschreibung                                 |
|---------------|--------|--------|----------------------------------------------|
| `--debug`     | `-d`   | Keine  | Zeigt Debug-Ausgaben                         |
| `--dry-run`   | `-n`   | Keine  | Führt das Tool im „Trockenlauf“-Modus aus    |
| `--help`      | `-h`   | Keine  | Zeigt die Hilfeinformationen                 |
| `--quiet`     | `-q`   | Keine  | Minimale Ausgabe                             |
| `--verbose`   | `-v`   | Keine  | Ausführliche Ausgabe                         |

---

### 🔧 Befehls-spezifische Optionen source environment

| Option        | Kürzel | Wert     | Beschreibung                                                                 |
|---------------|--------|----------|------------------------------------------------------------------------------|
| `--version`   | `-V`   | Keine    | Zeigt Versionsinformationen für das Tool `source_environment`               |

---

### 📁 Zusätzliche Argumente ab Version 1.1

Ab Autobuild-Version **1.1** kann ein optionales Argument übergeben werden:

```bash
autobuild source_environment [varsfile]
```

| Argument   | Beschreibung                                                                 |
|------------|--------------------------------------------------------------------------------|
| `varsfile` | Datei mit Variablenzuweisungen, die je nach Build-Typ angepasst werden können. Standard: `$AUTOBUILD_VARIABLES_FILE` |

Dies erlaubt die Verwendung einer separaten Datei für verwandte Projekte (z. B. Viewer und zugehörige Bibliotheken), sodass alle Builds dieselben Compiler- und Optionsschalter verwenden.

Die von Linden Lab verwendete Variablendatei zur Erstellung des Viewers und seiner Bibliotheken befindet sich im Repository **viewer-build-variables**.

---

## Noch weiter erforschen

Wie ist die optimale Reihenfolge der autobuild Kommandos?:
build
configure
edit
install
installables
manifest
package
print
source_environment
uninstall

Wenn du ein neues Projekt mit **Autobuild** von Grund auf aufsetzen möchtest, ist es wichtig,
die Kommandos in einer sinnvollen Reihenfolge zu verwenden,
damit dein Projekt sauber konfiguriert, gebaut und paketiert wird.
Dies ist noch keine korrekte reihenfolge!

---

## 🚀 Optimale Reihenfolge für ein neues Autobuild-Projekt

Hier ist eine schrittweise Anleitung mit den passenden Kommandos:

### 1️⃣ `edit` – Projektdefinition erstellen  

Erstelle oder bearbeite die Datei `autobuild.xml`, in der Name, Version, Plattformen und andere Metadaten deines Projekts definiert sind.

```bash
autobuild edit myproject version=1.0.0
```

---

### 2️⃣ `installables` – Abhängigkeiten definieren  

Füge externe Bibliotheken oder Tools hinzu, die dein Projekt benötigt.

```bash
autobuild installables add zlib url=https://... hash=... hash_algorithm=md5
```

---

### 3️⃣ `install` – Abhängigkeiten installieren  

Installiere die zuvor definierten Pakete in dein Projektverzeichnis.

```bash
autobuild install zlib
```

---

### 4️⃣ `source_environment` – Umgebungsvariablen setzen  

Setze die Build-Umgebung, z. B. Compilerpfade oder Flags.

```bash
eval "$(autobuild source_environment)"
```

---

### 5️⃣ `configure` – Projekt konfigurieren  

Bereite dein Projekt für den Build vor (z. B. durch Konfiguration von Makefiles oder CMake).

```bash
autobuild configure
```

---

### 6️⃣ `build` – Projekt bauen  

Führe den eigentlichen Build-Prozess aus.

```bash
autobuild build
```

---

### 7️⃣ `manifest` – Artefakte definieren  

Gib an, welche Dateien ins Paket aufgenommen werden sollen.

```bash
autobuild manifest add bin/*.dll lib/*.so
```

---

### 8️⃣ `package` – Paket erstellen  

Erzeuge ein Archiv mit den gebauten Artefakten.

```bash
autobuild package --archive-name=myproject-1.0.0.tar.gz
```

---

### 9️⃣ `print` – Paketdefinition anzeigen  

Überprüfe die aktuelle Paketkonfiguration.

```bash
autobuild print
```

---

### 🔁 Optional: `uninstall` – Aufräumen  

Entferne installierte Abhängigkeiten, wenn du das Projekt bereinigen willst.

```bash
autobuild uninstall zlib
```

---

## 🧩 Zusammenfassung als Reihenfolge

```text
edit → installables → install → source_environment → configure → build → manifest → package → print → (uninstall)
```

---

## 🧩 Drittanbieter-Bibliotheken

Diese Seite listet alle Drittanbieter-Bibliotheken (3p) auf, die beim Bau des Second Life Viewers verwendet werden. Viele davon sind Open Source und über das Autobuild-System als vorgefertigte Pakete verfügbar.

### 📦 Struktur eines typischen Drittanbieter-Pakets
Ein modernes 3p-Paket (2024-Stil) sollte wie folgt aufgebaut sein:
- `vendor/` – Git-Submodul mit dem Original-Quellcode
- `.github/` – CI/CD-Konfiguration
- `autobuild.xml` – Manifest für Autobuild
- `build-cmd.sh` – Build-Skript
- `LICENSE` – Lizenzinformationen
- `README.md` – Projektbeschreibung

### 👨‍💻 Anleitung für Mitwirkende
1. Repository forken und lokal testen
2. Pull Request (PR) erstellen – mit Etikette und Verhaltenskodex
3. PR wird überprüft und gemerged
4. Maintainer veröffentlicht neue Version

### 🛠️ Anleitung für Maintainer
- PRs zügig prüfen und mergen
- Neue Version über GitHub Releases veröffentlichen
- Versionsschema: `vUPSTREAM-rRELEASE` (z. B. `v1.0.0-r2`)

### 🧵 Patches
Patches liegen im Verzeichnis `patches/` und werden beim Build angewendet. Ein Hilfsbefehl im Build-Skript hilft beim Einspielen.

### 🔄 Unterschiede zum alten Stil
Früher wurden separate Branches für Vendor und Default verwendet. Der neue Ein-Branch-Stil ist einfacher, schneller und besser mit GitHub integriert.

---

## 📚 Liste der Drittanbieter-Bibliotheken

| Bibliothek       | Lizenz         | Beschreibung |
|------------------|----------------|--------------|
| APR Suite        | Apache         | Portables C-Interface für OS-Funktionen (Threads, Sockets) |
| Boost            | Boost License  | Umfangreiche C++-Bibliothek, z. B. für Tokenisierung |
| Curl             | BSD-Stil       | Netzwerkprotokolle (GET/POST/PUT/DELETE) |
| Expat            | MIT            | XML-Parser |
| Freetype         | Freetype & andere | Font-Engine |
| GLH Linear       | nVidia SDK     | OpenGL-Hilfsbibliothek |
| GStreamer        | Open           | Multimedia-Framework |
| JPEGlib          | Open           | JPEG-Dekodierung |
| Kakadu (KDU)     | Kommerziell    | JPEG-2000-Dekodierung |
| libpng           | Open           | PNG-Bildbibliothek |
| libxml2          | MIT            | XML-Verarbeitung |
| ndofdev          | BSD-Stil       | Joystick-Treiber für SpaceNavigator |
| Ogg Vorbis       | BSD-Stil       | Audio-Codecs |
| OpenAL           | GPL            | 3D-Audio |
| OpenJPEG         | BSD-Stil       | Alternative zu Kakadu |
| OpenSSL          | Apache         | Verschlüsselung (z. B. Login) |
| SDL2             | zlib Lizenz    | Eingabe und Fenster-Setup unter Linux |
| SLVoice          | Kommerziell    | Sprachfunktion (Vivox) |
| TUT              | BSD-Stil       | Unit-Test-Framework |
| XMLRPC-EPI       | Epinions       | XML-RPC-Protokoll |
| zlib-ng          | zlib Lizenz    | Kompression für Netzwerk und Dateien |

---

## 🚫 Einschränkungen bei der Weiterverbreitung

Einige Dateien dürfen nicht frei weitergegeben werden, z. B.:
- **Meta-Fonts**: Nur für Second Life erlaubt, nicht für andere Zwecke
- **Kakadu JPEG2000**: Nicht redistributierbar – OpenJPEG als Alternative
- **Vivox-Komponenten**: SLVoice.exe, vivoxsdk.dll etc. sind nicht redistributierbar

---
