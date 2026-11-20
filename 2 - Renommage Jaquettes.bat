
@echo off
setlocal DisableDelayedExpansion

for /d %%D in (*) do (
    if exist "%%D\" (
        for %%I in ("%%D\*.iso") do (
            if exist "%%I" (
                for %%F in ("%%D\*.jpg" "%%D\*.jpeg" "%%D\*.png" "%%D\*.webp" "%%D\*.bmp" "%%D\*.gif" "%%D\*.tif" "%%D\*.tiff" "%%D\*.avif") do (
                    if exist "%%F" (
                        ren "%%F" "%%~nI%%~xF"
                    )
                )
            )
        )
    )
)

echo.
echo Renommage des images termine !
pause
