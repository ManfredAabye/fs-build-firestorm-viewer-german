# **Autobuild**  

**Autobuild** ist ein Framework zum Erstellen von Paketen und zum Verwalten von Abhängigkeiten eines Pakets von anderen Paketen. Es bietet eine einheitliche Schnittstelle zum Konfigurieren und Bauen von Paketen, ist jedoch **kein Build-System wie `make` oder `cmake`**. Für die Konfiguration und das Bauen Ihrer Bibliothek benötigen Sie weiterhin plattformspezifische `make`-, `cmake`- oder Projektdateien. Autobuild ermöglicht es Ihnen jedoch, diese Befehle aufzurufen und das Ergebnis mit einer einheitlichen Schnittstelle zu verpacken.  

**Hinweis:**  
*Linden Labs Autobuild* ist nicht dasselbe wie und auch nicht abgeleitet von *GNU Autobuild*, aber die Ähnlichkeiten können zu Verwechslungen führen. Wir bedauern diese Namensüberschneidung.  

---

## **Autobuild installieren**  

Autobuild wird aktiv weiterentwickelt, daher wird empfohlen, die **neueste Version** zu verwenden und regelmäßig zu aktualisieren.  

### **Voraussetzungen**

- **Python 3.7+** für Autobuild 3.x  

### **Installation mit pip oder pipx**

```bash
pip install autobuild
```  

Je nach Systemberechtigungen und ob Sie eine Python-`virtualenv` verwenden, müssen Sie möglicherweise Ihre `PATH`-Variable anpassen.  

---

### **2. Build-Konfiguration ändern oder hinzufügen**  

#### **Syntax:**

```bash
autobuild [Optionen] [Sub-Befehl]  
```  

#### **Optionen:**

| Option | Beschreibung |  
|--------|-------------|  
| `--verbose` | Ausführliche Ausgabe (hilfreich zur Fehlerdiagnose). |  
| `--dry-run` | Simulation: Zeigt an, was passieren würde, ohne Änderungen vorzunehmen. |  
| `--help [Befehl]` | Hilfe zu verfügbaren Autobuild-Befehlen anzeigen. |  
| `--quiet` | Minimale Ausgabe. |  
| `-V, --version` | Autobuild-Version anzeigen. |  
| `--debug` | Debug-Informationen (sehr detailliert, nur für Entwickler relevant). |  

#### **Sub-Befehle:**

| Befehl | Beschreibung |  
|--------|-------------|  
| `build` | Plattformspezifische Ziele erstellen. |  
| `configure` | Plattformspezifische Ziele konfigurieren. |  
| `edit` | Build- und Paketkonfiguration verwalten. |  
| `install` | Paketarchive herunterladen und installieren. |  
| `installables` | Installierbare Pakete in der Konfiguration verwalten. |  
| `manifest` | Manifest-Einträge in der Konfiguration bearbeiten. |  
| `package` | Ein Archiv der Build-Ausgabe erstellen. |  
| `print` | Konfiguration anzeigen. |  
| `source_environment` | Shell-Umgebung für Autobuild-Skripte ausgeben (via `eval`). |  
| `uninstall` | Paketarchive deinstallieren. |  

---

### **Autobuild zur Erstellung eines Projekts verwenden**  

Dieser Abschnitt erklärt, wie Autobuild konfiguriert wird, um ein Quellpaket zu erstellen. Voraussetzung ist eine bestehende Quellverteilung und ein funktionierendes Build-System wie `make` oder `cmake`.  

---

## **Vorbereitung**

### **Build für Ihre Plattform(en)**

Autobuild ist **kein Build-System** wie `make` oder `cmake`. Es löst nicht die plattformspezifischen Probleme beim Kompilieren von Code, sondern bietet eine **einheitliche Schnittstelle** für Build- und Packaging-Prozesse auf Basis plattformspezifischer Tools.  

Für jede Bibliothek oder Anwendung, die mit Autobuild verwaltet werden soll, benötigen Sie:

- Einen **Build-Befehl** (ggf. auch einen Konfigurationsbefehl) für jede unterstützte Plattform.  
  - **Linux:** Typischerweise `make` mit Makefiles.  
  - **Windows:** Beispielsweise `devenv.com` mit einer Projektdatei.  

In den folgenden Abschnitten lernen Sie, wie Sie Autobuild so konfigurieren, dass es diese plattformspezifischen Befehle ausführt.  

---

## **Neue Konfiguration erstellen**

Die folgenden Schritte erstellen eine Autobuild-Konfiguration (standardmäßig `autobuild.xml`) für Ihr Projekt. Diese beschreibt:

- Die Ausgabe des Projekts,  
- Abhängigkeiten (sogenannte *Installables*),  
- Plattformspezifische Build- und Konfigurationsschritte.  

### **1. Grundlegende Paketdetails festlegen**

Wechseln Sie in das Stammverzeichnis Ihres Projekts und führen Sie aus:

```bash
autobuild edit package
```

Dies startet einen interaktiven Dialog, in dem Sie:

- Einen **Namen** angeben,  
- Den Pfad zu einer **Versionsdatei** (z. B. `VERSION.txt`) festlegen.  

Falls Ihr Projekt ein Archiv für andere Projekte erstellen soll, können Sie auch eine **Lizenz** (`license`) und eine **Lizenzdatei** (`license_file`) angeben.  

#### **Beispiel (nicht-interaktiv):**

```bash
autobuild edit package name=test license=MIT license_file=LICENSES/test.txt version_file=VERSION.txt
```  

#### **Build-Konfiguration hinzufügen**

Für ein UNIX-ähnliches Projekt mit `configure` und `make`:

```bash
autobuild edit configure platform=darwin name=Release command=../configure
autobuild edit build platform=darwin name=Release command=make options='--directory=..' default=True
```

- `default=True` markiert diese Konfiguration als Standard-Build.  
- Die Befehle `command`, `arguments` und `options` werden zur Ausführung zusammengefügt.  

#### **Build starten**

```bash
autobuild build
```  

---

## **Mehrere Plattformen unterstützen**

Wiederholen Sie die Schritte für jede Plattform. Falls mehrere Plattformen gemeinsame Befehle verwenden (z. B. `cmake`), können Sie diese im **`common`-Platform-Abschnitt** definieren:

- Nicht spezifizierte Attribute werden von `common` geerbt.  
- Plattformspezifische Einstellungen überschreiben die `common`-Werte.  

---

## **Abhängigkeiten hinzufügen**

Wenn Ihr Projekt andere Autobuild-Pakete benötigt, können Sie diese automatisch herunterladen lassen:  

### **1. Paket-URL und Hash angeben**

```bash
autobuild installables add GL \
  url=http://example.com/GL-darwin-20101004.tar.bz2 \
  hash=0b7c1d43dc2b39301fef6c05948fb826
```  

### **2. Plattformspezifische Varianten hinzufügen**

```bash
autobuild installables edit GL platform=windows \
  url=http://example.com/GL-windows-20101001a.tar.bz2 \
  hash=a94538d064cd0a235b2a95389e7e8ee8
```  

### **3. Paket installieren**

```bash
autobuild install GL
```

- Die Dateien werden im `packages`-Verzeichnis des Build-Ordners abgelegt.  
- Zum Deinstallieren:

  ```bash
  autobuild uninstall GL
  ```  

---

## **Archiv erstellen mit Autobuild**

### **1. Manifest definieren**

Fügen Sie Dateien hinzu, die ins Archiv aufgenommen werden sollen:

```bash
autobuild manifest add 'include/*.h' 'lib/*.so'
```

- Glob-Patterns sind unterstützt.  
- Lizenzdateien werden automatisch eingebunden.  

### **2. Archiv erstellen**

```bash
autobuild package
```

- Das Archiv wird nach dem Schema `<name>-<version>-<platform>-<buildid>.tar.bz2` benannt (z. B. `test-1.0-darwin-20230530.tar.bz2`).  

---

### **Empfohlene Verzeichnisstruktur**

| Dateityp      | Verzeichnis  |  
|--------------|-------------|  
| Lizenzen     | `LICENSES`  |  
| Header       | `include`   |  
| Bibliotheken | `lib`       |  
| Binärdateien | `bin`       |  
| Skripte      | `scripts`   |  

---
