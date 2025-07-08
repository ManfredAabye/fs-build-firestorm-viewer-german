# 🚀 `autobuild install` – Paket(e) installieren

Installiert die Artefakte von Abhängigkeitspaketen (z. B. `openal`, `zlib`) für den Build des aktuellen Projekts.

## 🔣 Allgemeine Syntax

```bash
autobuild install [Optionen] [Paketname [Paketname ...]]
```

- Du kannst **ein Paket**, **mehrere Pakete** oder **gar keins** angeben.
- Wenn du **kein Paket** angibst, werden **alle Pakete aus dem Abschnitt `installables`** deiner `autobuild.xml` installiert.

---

## 🔐 Private Pakete (z. B. GitHub/GitLab)

Falls ein Paket private Repos verwendet, musst du Umgebungsvariablen setzen:

```bash
set AUTOBUILD_GITHUB_TOKEN=DEIN_TOKEN
set AUTOBUILD_GITLAB_TOKEN=DEIN_TOKEN
```

---

## ⚙️ Standardoptionen

| Option               | Kurzform | Bedeutung                                         | Beispiel |
|----------------------|----------|--------------------------------------------------|----------|
| `--debug`            | `-d`     | Debug-Ausgabe aktivieren                         | `autobuild install -d openal` |
| `--dry-run`          | `-n`     | Simulation ohne echte Änderungen                 | `autobuild install -n` |
| `--help`             | `-h`     | Hilfe anzeigen                                   | `autobuild install -h` |
| `--quiet`            | `-q`     | Minimale Ausgabe                                 | `autobuild install -q openal` |
| `--verbose`          | `-v`     | Detaillierte Ausgabe                             | `autobuild install -v openal` |

---

## 🧰 Befehlsspezifische Optionen

| Option                        | Bedeutung                                                  | Beispiel |
|-------------------------------|-------------------------------------------------------------|----------|
| `--config-file datei.xml`     | Nutze eine andere Konfigurationsdatei statt `autobuild.xml` | `autobuild install --config-file custom.xml openal` |
| `--export-manifest`           | Installationsmanifest an stdout ausgeben                   | `autobuild install --export-manifest openal` |
| `--installed-manifest datei`  | Speichert eine Liste der installierten Dateien              | `autobuild install --installed-manifest manifest.json openal` |
| `--install-dir pfad/`         | Installiert Dateien in angegebenes Verzeichnis              | `autobuild install --install-dir temp_install/ openal` |
| `--list`                      | Zeigt alle definierten Archive aus der Config               | `autobuild install --list` |
| `--list-installed`            | Zeigt alle bereits installierten Pakete                     | `autobuild install --list-installed` |
| `--list-licenses`             | Listet bekannte Lizenzinformationen aller Pakete            | `autobuild install --list-licenses` |
| `--platform windows64`        | Nutze eine andere Zielplattform                             | `autobuild install -p windows64 openal` |
| `--list-install-urls`         | Zeigt die URLs der Archive aller installierten Pakete       | `autobuild install --list-install-urls` |
| `--list-dirty`                | Zeigt Pakete, die lokal modifiziert wurden                  | `autobuild install --list-dirty` |
| `--what-installed pfad/datei` | Zeigt, welches Paket eine bestimmte Datei installiert hat    | `autobuild install --what-installed packages/include/AL/al.h` |
| `--versions`                  | Zeigt alle Paketnamen und ihre Versionsnummern              | `autobuild install --versions` |
| `--copyrights`                | Zeigt die Copyright-Einträge aller Pakete                   | `autobuild install --copyrights` |
| `--local pfad/zum/archiv.tar.zst` | Installiert ein Archiv direkt (nicht via URL)         | `autobuild install --local openal-1.24.2.tar.zst` |

> 🛠 `--local` ist super beim Entwickeln und Testen eigener Pakete

---

## 🧪 Praxisbeispiele

1.**Alle Pakete installieren (wie `zlib`, `openal`, `ogg`, …):**

```bash
autobuild install
```

2.**Nur OpenAL-Paket installieren:**

```bash
autobuild install openal
```

3.**Nur Testweise (dry run) ohne Installation:**

```bash
autobuild install -n openal
```

4.**OpenAL lokal installieren aus vorbereitetem Archiv:**

```bash
autobuild install --local build/openal-openlab.tar.zst
```

5.**Installation in benutzerdefiniertes Verzeichnis:**

```bash
autobuild install --install-dir temp_install/ openal
```

---
