
@echo off
setlocal DisableDelayedExpansion

for %%F in (*.iso) do (
    if exist "%%F" (
        if not exist "%%~nF\" mkdir "%%~nF"
        move "%%F" "%%~nF\"
    )
)

echo.
echo Tous les fichiers ISO ont ete ranges !
pause
