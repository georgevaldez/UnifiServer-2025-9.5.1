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
  setlocal enabledelayedexpansion

  rem eliminar cualquier prefijo numerico y guiones bajos al inicio
  set "clean=!name!"
  for /l %%A in (1,1,20) do (
    if defined clean (
      for /f "tokens=1,* delims=_" %%B in ("!clean!") do (
        echo %%B | findstr /r "^[0-9][0-9]*$" >nul
        if not errorlevel 1 (
          set "clean=%%C"
        )
      )
    )
  )

  rem quitar guion bajo inicial si quedo
  if "!clean:~0,1!"=="_" set "clean=!clean:~1!"

  set "new=!clean!!ext!"
  endlocal & set "new=%new%" & set "file=%%~nxF" & set "path=%%~dpF"

  if /I not "%file%"=="%new%" (
    echo ✓ %file% → %new%
    pushd "%path%" >nul
    ren "%file%" "%new%" >nul 2>&1
    popd >nul
  )
)

echo.
echo ============================================================
echo  PROCESO TERMINADO
echo ============================================================
pause
