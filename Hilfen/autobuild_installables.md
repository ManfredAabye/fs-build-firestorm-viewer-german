# 🛠️ `autobuild installables` – Installierbare Pakete verwalten

Mit diesem Befehl kannst du **Paketabhängigkeiten definieren**, bearbeiten oder entfernen, die mit `autobuild install` installiert werden sollen.

---

## 🧩 Syntax

```bash
autobuild installables [Optionen] [Befehl] [Paketname] [Argument ...]
```

- **Befehl:** `add`, `edit`, `remove` oder `print`
- **Paketname:** z. B. `openal`
- **Argumente:** Schlüssel=Wert-Paare wie `url=https://…`, `hash=abc123`, `creds=github`

---

## 📚 Befehle

| Befehl   | Bedeutung |
|----------|-----------|
| `add`    | Neues installierbares Paket hinzufügen |
| `edit`   | Vorhandenes Paket ändern |
| `remove` | Paket entfernen |
| `print`  | Details eines Pakets anzeigen |

### 🧪 Beispiel: Neues Paket hinzufügen

```bash
autobuild installables add openal \
  url=https://example.com/openal.tar.zst \
  hash=8ad24f... \
  hash_algorithm=sha1
```

---

## 🔐 Attribute im Detail

| Attribut         | Bedeutung                                            | Beispiel |
|------------------|------------------------------------------------------|----------|
| `url`            | Download-URL zum Archiv                              | `url=https://example.com/openal.tar.zst` |
| `hash`           | Prüfsumme der Datei (z. B. SHA1)                     | `hash=8ad24fba1191c9cb...` |
| `hash_algorithm` | Algorithmus für den Hash (z. B. `sha1`, `md5`)       | `hash_algorithm=sha1` |
| `creds`          | Authentifizierung bei privaten Repos (`github`, `gitlab`) | `creds=github` |

---

## 🔐 Private Pakete laden

Ab Autobuild **v3.5.0** können Pakete aus privaten GitHub/GitLab-Repos geladen werden.

Du musst dafür Umgebungsvariablen setzen:

```bash
set AUTOBUILD_GITHUB_TOKEN=DEIN_TOKEN
```

```bash
set AUTOBUILD_GITLAB_TOKEN=DEIN_TOKEN
```

Und dein Paket mit dem `creds`-Attribut markieren:

```bash
autobuild installables edit openal creds=github
```

---

## ⚙️ Standardoptionen

| Option        | Kurzform | Beschreibung                               | Beispiel |
|---------------|----------|--------------------------------------------|----------|
| `--debug`     | `-d`     | Zeige Debug-Ausgaben                       | `autobuild installables -d print openal` |
| `--dry-run`   | `-n`     | Führt Aktionen nur simuliert aus           | `autobuild installables -n add ...` |
| `--help`      | `-h`     | Zeigt Hilfetext                            | `autobuild installables -h` |
| `--quiet`     | `-q`     | Nur minimale Ausgabe                       | `autobuild installables -q list` |
| `--verbose`   | `-v`     | Zeigt zusätzliche Details                  | `autobuild installables -v print openal` |

---

## 🧰 Befehlsspezifische Optionen

| Option                  | Kurzform | Beschreibung                                            | Beispiel |
|--------------------------|----------|---------------------------------------------------------|----------|
| `--config-file pfad.xml` | –        | Verwendet angegebene Konfigurationsdatei               | `autobuild installables --config-file custom.xml print openal` |
| `--archive pfad`         | `-a`     | Liest Attribute (wie URL, Hash) aus Archivdatei         | `autobuild installables add openal -a openal.tar.zst` |

---

## 🔍 Beispiel: OpenAL manuell definieren

```bash
autobuild installables edit openal \
  platform=windows64 \
  url=https://github.com/secondlife/3p-openal-soft/releases/download/v1.24.2-r1/openal-1.24.2-r1-windows64-13245988487.tar.zst \
  hash=8ad24fba1191c9cb0d2ab36e64b04b4648a99f43 \
  hash_algorithm=sha1 \
  creds=github
```

> 🔄 Danach kannst du mit `autobuild install openal` das Paket installieren

---
