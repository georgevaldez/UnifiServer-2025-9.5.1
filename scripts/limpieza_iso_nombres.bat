@echo off
title Limpieza simple de nombres ISO/IMG
color 0A
setlocal enabledelayedexpansion

set "ROOT=E:\IsoBoot"

echo ============================================================
echo  LIMPIANDO NUMEROS INICIALES EN TODAS LAS SUBCARPETAS
echo ============================================================

for /r "%ROOT%" %%F in (*.iso *.img) do (
  set "file=%%~nxF"
  set "path=%%~dpF"
  set "name=%%~nF"
  set "ext=%%~xF"

  set "clean="
  call :TrimLeading "!name!" clean

  if not defined clean (
    set "clean=!name!"
  )

  set "new=!clean!!ext!"

  if /I not "!file!"=="!new!" (
    echo ✓ !file! → !new!
    pushd "!path!" >nul
    ren "!file!" "!new!" >nul 2>&1
    popd >nul
  )
)

echo.
echo ============================================================
echo  PROCESO TERMINADO
echo ============================================================
pause

goto :EOF

:TrimLeading
setlocal enabledelayedexpansion
set "text=%~1"

:trimLoop
if not defined text goto trimmed
set "first=!text:~0,1!"
for %%D in (0 1 2 3 4 5 6 7 8 9) do if "!first!"=="%%D" (
  set "text=!text:~1!"
  goto trimLoop
)
for %%S in (" " "-" "_" ".") do if "!first!"=="%%~S" (
  set "text=!text:~1!"
  goto trimLoop
)
goto trimmed

:trimmed
if not defined text set "text=%~1"
endlocal & set "%~2=%text%"
goto :EOF
