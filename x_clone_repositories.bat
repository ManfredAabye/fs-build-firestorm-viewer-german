@echo off
setlocal
:: ##### Parameter #####
set "SCRIPT_DIR=%~1"
set "BUILD_DIR=%~2"

:: ##### Klonen der Repositories #####
echo %GREEN%Klonen der Quellverzeichnisse...%RESET%

:: 1. Phoenix-Firestorm
if not exist "%SCRIPT_DIR%\phoenix-firestorm" (
    git clone "https://github.com/FirestormViewer/phoenix-firestorm.git" "%SCRIPT_DIR%\phoenix-firestorm"
    :: Alternative Quelle:
    :: git clone "https://github.com/ManfredAabye/phoenix-firestorm-os.git" "%SCRIPT_DIR%\phoenix-firestorm"
)

:: 2. Build-Variablen
if not exist "%SCRIPT_DIR%\fs-build-variables" (
    git clone "https://github.com/FirestormViewer/fs-build-variables.git" "%SCRIPT_DIR%\fs-build-variables"
)

:: ##### Kopiervorgänge #####
:: 1. Phoenix-Firestorm
if not exist "%BUILD_DIR%\phoenix-firestorm" (
    xcopy /E /I /Y "%SCRIPT_DIR%\phoenix-firestorm" "%BUILD_DIR%\phoenix-firestorm" >nul 2>&1
    if errorlevel 1 echo %RED%Fehler beim Kopieren von phoenix-firestorm%RESET% && exit /b 1
)

:: 2. Build-Variablen
if not exist "%BUILD_DIR%\fs-build-variables" (
    xcopy /E /I /Y "%SCRIPT_DIR%\fs-build-variables" "%BUILD_DIR%\fs-build-variables" >nul 2>&1
    if errorlevel 1 echo %RED%Fehler beim Kopieren von fs-build-variables%RESET% && exit /b 1
)

:: 3. Include-Verzeichnis
if not exist "%BUILD_DIR%\fs_include" (
    xcopy /E /I /Y "%SCRIPT_DIR%\fs_include" "%BUILD_DIR%\fs_include" >nul 2>&1
    if errorlevel 1 echo %RED%Fehler beim Kopieren von fs_include%RESET% && exit /b 1
)

endlocal