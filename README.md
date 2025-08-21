# **Build-Anleitung für Windows**

---

     0_cleaner.bat - Löscht das Build Verzeichnis.
     0_cleaner_inc_temp.bat - Löscht das Build Verzeichnis und das temp Verzeichnis.
     1_build_software_installer.bat - Installiert alle Programme und abhängigkeiten die zum bau des Firestorm benötigt werden.
     2_firestorm_building_V27.bat - Erstellt einen Tagesaktuellen Firestorm OpenSim WebRTC OpenAL AVX2 Viewer.
     3_refresh_check.bat - schaut nach ob es eine neue Firestorm Version gibt und aktualisiert sie gleichzeitig.

Ich habe fmod Sound rausgenommen und einen aktualisierten OpenAL Sound eingefügt.

Ich habe WebRTC aktualisiert.

Der link.exe fehler ist auf Github installation zurückzuführen, wenn man im Programm Ordner von git die Datei link.exe in glink.exe umbenennt, dann findet der Build Prozess diesen nicht mehr.

### Informationen:
- Im temp Verzeichnis werden alle 3p Pakete abgelegt, hier kann man untersuchen was alles heruntergeladen wurde.
