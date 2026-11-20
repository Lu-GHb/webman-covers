```bat
@echo off
setlocal DisableDelayedExpansion
cd /d "%~dp0"

:: ==================================================
:: CONFIGURATION
:: ==================================================

set "MAX_SIZE=22528"
set "MAGICK_EXE="

:: ==================================================
:: DETECTION AUTOMATIQUE D'IMAGEMAGICK
:: ==================================================

:: 1. Recherche dans le PATH
for /f "delims=" %%A in ('where magick.exe 2^>nul') do (
    if not defined MAGICK_EXE set "MAGICK_EXE=%%A"
)

:: 2. Program Files
if not defined MAGICK_EXE (
    for /d %%D in ("C:\Program Files\ImageMagick*") do (
        if exist "%%~fD\magick.exe" (
            set "MAGICK_EXE=%%~fD\magick.exe"
        )
    )
)

:: 3. Program Files x86
if not defined MAGICK_EXE (
    for /d %%D in ("C:\Program Files (x86)\ImageMagick*") do (
        if exist "%%~fD\magick.exe" (
            set "MAGICK_EXE=%%~fD\magick.exe"
        )
    )
)

:: 4. Registre Windows
if not defined MAGICK_EXE (
    for /f "tokens=2,*" %%A in ('reg query "HKLM\SOFTWARE\ImageMagick" /s /v BinPath 2^>nul ^| findstr /i "BinPath"') do (
        if exist "%%B\magick.exe" set "MAGICK_EXE=%%B\magick.exe"
    )
)

:: Verification
if not defined MAGICK_EXE (
    echo.
    echo ERREUR : ImageMagick introuvable !
    pause
    exit /b 1
)

:: Ajout temporaire au PATH
for %%A in ("%MAGICK_EXE%") do set "MAGICK_PATH=%%~dpA"
set "PATH=%MAGICK_PATH%;%PATH%"

echo.
echo ImageMagick detecte :
echo %MAGICK_EXE%
echo.

:: ==================================================
:: CREATION DE LA LISTE DES IMAGES ORIGINALES
:: ==================================================

set "FILE_LIST=%TEMP%\magick_list_%RANDOM%_%RANDOM%.txt"

dir /s /b /a-d *.jpg *.jpeg *.png *.webp *.bmp *.gif *.tif *.tiff *.avif > "%FILE_LIST%" 2>nul

:: ==================================================
:: TRAITEMENT
:: ==================================================

for /f "usebackq delims= eol=|" %%F in ("%FILE_LIST%") do (
    call :PROCESS "%%F"
)

del "%FILE_LIST%" 2>nul

echo.
echo ==========================================
echo TRAITEMENT TERMINE !
echo ==========================================
pause
exit /b


:: ==================================================
:: SOUS-ROUTINE DE CONVERSION
:: ==================================================

:PROCESS

set "SOURCE=%~1"
set "FINAL=%~dpn1.png"
set "TEMP_PNG=%~dpn1_magick_temp.png"

echo.
echo Traitement : %~nx1

:: Plusieurs essais : dimensions et couleurs decroissantes

for %%D in (120 112 104 96 88 80 72 64 56 48 40 32 24 16 8 1) do (
    for %%C in (256 128 64 32 16 8 4 2) do (

        del "%TEMP_PNG%" 2>nul

        magick "%SOURCE%[0]" -auto-orient ^
        -thumbnail "%%Dx%%D" ^
        -background none -gravity center ^
        -extent "%%Dx%%D" ^
        -strip ^
        -colors %%C ^
        -dither None ^
        -define png:compression-level=9 ^
        -define png:compression-filter=5 ^
        -define png:compression-strategy=1 ^
        "PNG8:%TEMP_PNG%" 2>nul

        :: Verification de la taille
        if exist "%TEMP_PNG%" (
            for %%Z in ("%TEMP_PNG%") do (
                if %%~zZ LEQ %MAX_SIZE% goto SUCCESS
            )
        )
    )
)

:: Aucun resultat conforme : conservation de l'original
echo ECHEC : impossible d'atteindre 22 Ko.
echo Original conserve : %~nx1
del "%TEMP_PNG%" 2>nul
exit /b


:: ==================================================
:: RESULTAT VALIDE
:: ==================================================

:SUCCESS

:: Remplacement du PNG final
move /y "%TEMP_PNG%" "%FINAL%" >nul

if not exist "%FINAL%" (
    echo ERREUR : sauvegarde impossible.
    echo Original conserve.
    exit /b
)

:: Suppression de l'original si extension differente
if /i not "%SOURCE%"=="%FINAL%" (
    del /q "%SOURCE%"
)

for %%Z in ("%FINAL%") do echo OK : %%~nxZ - %%~zZ octets

exit /b
```