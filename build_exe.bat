@echo off
echo ====================================================
echo Autobuild Package Manager - EXE Builder
echo ====================================================
echo.

REM Prüfe ob Python verfügbar ist
python --version >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo FEHLER: Python ist nicht installiert oder nicht im PATH!
    echo Bitte installieren Sie Python und versuchen Sie es erneut.
    pause
    exit /b 1
)

echo Python gefunden: 
python --version

REM Prüfe ob pip verfügbar ist
pip --version >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo FEHLER: pip ist nicht verfügbar!
    pause
    exit /b 1
)

echo.
echo Installiere benötigte Pakete...
echo ====================================================

REM Installiere PyInstaller falls nicht vorhanden
echo Installiere PyInstaller...
pip install pyinstaller

REM Installiere PIL/Pillow für Icon-Unterstützung (optional)
echo Installiere Pillow für bessere Icon-Unterstützung...
pip install Pillow

echo.
echo Erstelle EXE-Datei...
echo ====================================================

REM Erstelle die EXE mit PyInstaller
REM --onefile: Alles in eine einzige EXE-Datei
REM --windowed: Keine Konsole anzeigen (GUI-App)
REM --name: Name der EXE-Datei
REM --icon: Icon für die EXE (falls vorhanden)
REM --add-data: Zusätzliche Dateien einbinden

if exist "icon.png" (
    echo Icon gefunden - wird in EXE eingebettet...
    pyinstaller --onefile --windowed --name "AutobuildPackageManager" --icon=icon.png --add-data "icon.png;." autobuild_package_manager.py
) else (
    echo Kein Icon gefunden - erstelle EXE ohne Icon...
    pyinstaller --onefile --windowed --name "AutobuildPackageManager" autobuild_package_manager.py
)

REM Prüfe ob Build erfolgreich war
if %ERRORLEVEL% neq 0 (
    echo.
    echo FEHLER: Build fehlgeschlagen!
    echo Überprüfen Sie die Fehlermeldungen oben.
    pause
    exit /b 1
)

echo.
echo ====================================================
echo BUILD ERFOLGREICH!
echo ====================================================
echo.

REM Zeige Ergebnis
if exist "dist\AutobuildPackageManager.exe" (
    echo EXE-Datei erstellt: dist\AutobuildPackageManager.exe
    echo Dateigröße:
    dir "dist\AutobuildPackageManager.exe" | find "AutobuildPackageManager.exe"
    echo.
    echo Die EXE-Datei befindet sich im 'dist' Ordner.
    echo Sie können diese Datei auf andere Computer kopieren und ausführen.
    echo.
    
    REM Frage ob EXE gestartet werden soll
    set /p choice="Möchten Sie die EXE-Datei jetzt testen? (j/n): "
    if /i "%choice%"=="j" (
        echo Starte AutobuildPackageManager.exe...
        start "AutobuildPackageManager" "dist\AutobuildPackageManager.exe"
    )
) else (
    echo WARNUNG: EXE-Datei nicht gefunden in dist\ Ordner!
)

echo.
echo ====================================================
echo Zusätzliche Informationen:
echo ====================================================
echo - Die EXE-Datei enthält alle Python-Abhängigkeiten
echo - Sie benötigt keine Python-Installation auf dem Zielcomputer
echo - Die EXE ist ca. 20-50 MB groß (je nach Abhängigkeiten)
echo - Zum Verteilen kopieren Sie nur die EXE-Datei
echo.
echo Build-Artefakte:
echo - dist\AutobuildPackageManager.exe (die fertige EXE)
echo - build\ (temporäre Build-Dateien - kann gelöscht werden)
echo - AutobuildPackageManager.spec (PyInstaller-Konfiguration)
echo.

pause