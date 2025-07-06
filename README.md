# **Build-Anleitung für Windows**

---

     0 cleaner.bat
     1 software_installer.bat 
     2firestorm_buildingV7.bat

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
  - Vollautomatische installation aller benötigten Programme samt konfiguration.

---

### `2firestorm_buildingV11.bat`
- **Funktionen**:
- Alles weitere zum bau eines OpenSim Viewers

---

### Ablauf:
1. `0cleaner.bat` → Bereinigung durch komplettes löschen (Es wird nicht das temp Verzeichnis gelöscht).
2. `1software_installer.bat` → Software-Installation muss nur einmal durchgeführt werden.  
3. `2firestorm_buildingV7.bat` → Baut mit hilfe einer venv den kompletten Firestorm-OpenSim 

---

### Informationen:
- Im temp Verzeichnis werden alle 3p Pakete abgelegt, hier kann man untersuchen was alles heruntergeladen wurde.

