# Firestorm Viewer Build Instructions for Windows

0cleaner.bat, 1software_installer.bat, 2firestorm_build.bat und 3firestorm_compiler.bat sind unabhängige Skripte, die sich nicht gegenseitig aufrufen.

0cleaner.bat -* Entfernt den kompletten Firestorm aus dem Verzeichnis es bleiben nur die Dateien im Hauptverzeichnis zurück.

1software_installer.bat -* Installiert CMake, Git, Visual Studio 2022 Community - Select "Desktop development with C++" workload und lädt alle Programmteile vom Git oder anderen Quellen herunter.

2firestorm_build.bat -* Installiert Python-Virtualenv inklusive der benötigten Python Version mit llbase llsd autobuild.

3firestorm_compiler.bat -* Erstellt die Binären Dateien und Packt es in ein Installierbares Paket oder in ein Portables Verzeichnis und zipt es mit 7zip.
