# Autobuild Anleitung

< Autobuild  
Autobuild

* Viewer erstellen
* Schnellstart
* Anleitung
* Glossar
* Beispiele
* Paketstruktur
* Klassenmodell
* Build-Skript Aufbau
* Shell-Funktionen

Autobuild ist ein Framework zur Verwaltung und Erstellung von Projekten sowie zur Handhabung ihrer Abhängigkeiten. Diese Seite bietet eine Tutorial-Einführung in die grundlegende Nutzung von Autobuild. Für einen Überblick siehe [Autobuild](Autobuild).

## Inhaltsverzeichnis

1. [Autobuild zur Projekterstellung nutzen](#using-autobuild-to-build-a-project)  
   1.1 [Vorbereitung](#before-you-start)  
   &nbsp;&nbsp;&nbsp;&nbsp;1.1.1 [Plattformspezifisches Build](#build-for-your-platforms)  
   1.2 [Neue Konfiguration erstellen](#creating-a-new-configuration)  
   1.3 [Plattform-Builds konfigurieren](#configuring-platform-builds)  
   1.4 [Mehrere Plattformen unterstützen](#building-on-multiple-platforms)  
   1.5 [Abhängigkeiten hinzufügen](#adding-dependencies)  
2. [Archive mit Autobuild erstellen](#using-autobuild-to-construct-an-archive)  
   2.1 [Manifest und Packaging](#constructing-the-manifest-and-packaging)  
   2.2 [Struktur der Build-Produkte](#laying-out-build-product)  

---

<a name="using-autobuild-to-build-a-project"></a>

## Autobuild zur Projekterstellung nutzen

Dieser Abschnitt erklärt, wie Autobuild konfiguriert wird, um ein Quellpaket zu erstellen. Vorausgesetzt wird eine Quellcode-Distribution und ein funktionierendes Build-System wie `make` oder `cmake`.

<a name="before-you-start"></a>

### Vorbereitung

<a name="build-for-your-platforms"></a>

#### Plattformspezifisches Build

Autobuild ist **kein** Build-System wie `make` oder `cmake`. Es löst nicht die detaillierten Probleme der Code-Erstellung auf bestimmten Plattformen, sondern bietet eine einheitliche Schnittstelle für Builds und Packaging auf Basis plattformspezifischer Tools.  

Für jede Bibliothek/Anwendung benötigen Sie:

* Einen Build-Befehl (ggf. mit Konfiguration) für jede unterstützte Plattform  
  *Beispiele:*  
  * Linux: `make` mit Makefiles  
  * Windows: `devenv.com` mit Projektdatei  

In den folgenden Abschnitten lernen Sie, wie Autobuild diese Befehle ausführt.

<a name="creating-a-new-configuration"></a>

### Neue Konfiguration erstellen

Schritte zur Erstellung einer `autobuild.xml`-Konfiguration:

1. Projektausgabe definieren
2. Abhängigkeiten ("Installables") festlegen
3. Plattformspezifische Build-Schritte konfigurieren

**Beispielbefehl (im Paket-Stammverzeichnis):**

```bash
autobuild edit package
```

*Interaktiver Modus:*  

* Pflichtangaben: Name + Pfad zur Versiondatei (relativ zum Build-Verzeichnis)  
* Optional: Lizenz + Lizenzdatei für Archivpakete  

**Nicht-interaktiv (Beispiel):**

```bash
autobuild edit package name=test license=MIT license_file=LICENSES/test.txt version_file=VERSION.txt
```

<a name="configuring-platform-builds"></a>

### Plattform-Builds konfigurieren

**Grundlegende Plattform-Einstellung (Beispiel für MacOS X):**

```bash
autobuild edit platform name=darwin build_directory=build
```

*(Relative Pfade beziehen sich auf die `autobuild.xml`-Datei.)*

**Build-Konfiguration hinzufügen (UNIX-Beispiel):**

```bash
autobuild edit configure platform=darwin name=Release command=../configure
autobuild edit build platform=darwin name=Release command=make options='--directory=..' default=True
```

*Attribute:*  

* `command`, `arguments`, `options` → Werden zum Shell-Befehl kombiniert  
* `default=True` → Standard-Build-Konfiguration  

**Build starten:**

```bash
autobuild build
```

<a name="building-on-multiple-platforms"></a>

### Mehrere Plattformen unterstützen

* Wiederholen Sie die Konfigurationsschritte für jede Plattform  
* Für gemeinsame Befehle: Nutzen Sie die `common`-Plattform  
  *Vererbungslogik:*  
  * Arbeitsplattformen überschreiben `command`/`arguments` von `common`  
  * `options` werden verkettet (`common`-Optionen zuerst)

<a name="adding-dependencies"></a>

### Abhängigkeiten hinzufügen

**Installierbares Archiv hinzufügen (Beispiel):**

```bash
autobuild installables add GL \
  url=http://s3.amazonaws.com/.../GL-darwin-20101004.tar.bz2 \
  hash=0b7c1d43dc2b39301fef6c05948fb826
```

**Für weitere Plattformen bearbeiten:**

```bash
autobuild installables edit GL platform=windows \
  url=http://s3.amazonaws.com/.../GL-windows-20101001a.tar.bz2 \
  hash=a94538d064cd0a235b2a95389e7e8ee8
```

**Installation/Deinstallation:**

```bash
autobuild install GL      # Herunterladen + Entpacken nach packages/
autobuild uninstall GL    # Entfernen
```

*(Autobuild verwaltet Versionen automatisch!)*

---

<a name="using-autobuild-to-construct-an-archive"></a>

## Archive mit Autobuild erstellen

<a name="constructing-the-manifest-and-packaging"></a>

### Manifest und Packaging

**Dateien zum Archiv hinzufügen (Beispiel):**

```bash
autobuild manifest add 'include/*.h'  # Alle .h-Header im include-Verzeichnis
```

*Hinweise:*  

* Nur relative Pfade (bezogen auf Build-Verzeichnis)  
* Lizenzdateien werden automatisch eingebunden  
* Plattformübergreifende Dateien: `common`-Plattform nutzen  

**Archiv erstellen:**

```bash
autobuild package
```

*Dateinamenkonvention:*  
`<name>-<version>-<platform>-<buildid>.tar.bz2` (z.B. `test-1.0-darwin-201010201423.tar.bz2`)

<a name="laying-out-build-product"></a>

### Struktur der Build-Produkte

Empfohlene Verzeichnisstruktur:

| Dateityp          | Verzeichnis |
|-------------------|-------------|
| Lizenzen          | LICENSES    |
| Headerdateien     | include     |
| Bibliotheken      | lib         |
| Ausführbare Dateien | bin       |
| Skripte           | scripts     |

*Details:* [Paketstruktur](Autobuild/Package_Layout)  
Für andere Dateitypen: Allgemein übliche Strukturen verwenden.

[[Kategorie:Autobuild]] [[Kategorie:Open Source Portal]]
