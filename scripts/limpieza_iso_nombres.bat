@echo off
title Limpieza simple de nombres ISO/IMG
color 0A
setlocal enabledelayedexpansion

set "ROOT=E:\IsoBoot"

set "CATEGORIES=00_Firewalls_Virtualization 10_Windows_Client 30_Windows_Server 50_Linux_General 70_Security_Forensics 80_Backup_Recovery 90_Utilities_Rescue 99_Miscellaneous"

for %%C in (%CATEGORIES%) do (
  if not exist "%ROOT%\%%C" (
    mkdir "%ROOT%\%%C" >nul 2>&1
  )
)

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

  call :DetectCategory "!clean!" category prefix

  set "targetDir=%ROOT%\!category!"
  if not exist "!targetDir!" (
    mkdir "!targetDir!" >nul 2>&1
  )

  call :StripExistingPrefix "!clean!" "!prefix!" clean

  set "candidate=!prefix! !clean!"
  set "targetCandidate=!targetDir!\!candidate!!ext!"

  if /I "%%~fF"=="!targetCandidate!" (
    rem ya está en la carpeta correcta con el nombre esperado
  ) else (
    call :EnsureUnique "!targetDir!" "!candidate!" "!ext!" newName
    set "targetFull=!targetDir!\!newName!"

    echo ✓ !file! → !category!\!newName!
    move /Y "%%~fF" "!targetFull!" >nul
    if errorlevel 1 (
      echo ✗ Error al mover "%%~fF" a "!targetFull!"
    )
  )
)

echo.
echo ============================================================
echo  PROCESO TERMINADO
echo ============================================================
pause

goto :EOF

:EnsureUnique
setlocal enabledelayedexpansion
set "dir=%~1"
set "base=%~2"
set "ext=%~3"
set "candidate=%base%%ext%"
set /a idx=1

:ensureLoop
if exist "%dir%\%candidate%" (
  set "candidate=%base%_(%idx%)%ext%"
  set /a idx+=1
  goto ensureLoop
)

endlocal & set "%~4=%candidate%"
goto :EOF

:DetectCategory
setlocal enabledelayedexpansion
set "name=%~1"
set "category=99_Miscellaneous"
set "prefix=99"

echo !name! | findstr /I /C:"pfsense" /C:"opnsense" /C:"vyos" /C:"fortigate" /C:"fortinet" /C:"sophos" /C:"sonicwall" /C:"checkpoint" /C:"vmware" /C:"esxi" /C:"proxmox" /C:"virtualization" >nul
if not errorlevel 1 (
  set "category=00_Firewalls_Virtualization"
  set "prefix=00"
  goto detected
)

echo !name! | findstr /I /C:"windows server" /C:"server 2003" /C:"server 2008" /C:"server 2012" /C:"server 2016" /C:"server 2019" /C:"server 2022" /C:"hyper-v server" /C:"essentials" >nul
if not errorlevel 1 (
  set "category=30_Windows_Server"
  set "prefix=30"
  goto detected
)

echo !name! | findstr /I /C:"windows 7" /C:"windows 8" /C:"windows 10" /C:"windows 11" /C:"win7" /C:"win8" /C:"win10" /C:"win11" /C:"windows vista" /C:"windows xp" /C:"microsoft windows" >nul
if not errorlevel 1 (
  set "category=10_Windows_Client"
  set "prefix=10"
  goto detected
)

echo !name! | findstr /I /C:"kali" /C:"parrot" /C:"blackarch" /C:"tails" /C:"security onion" /C:"backtrack" /C:"remnux" /C:"autopsy" /C:"pentest" >nul
if not errorlevel 1 (
  set "category=70_Security_Forensics"
  set "prefix=70"
  goto detected
)

echo !name! | findstr /I /C:"clonezilla" /C:"rescuezilla" /C:"acronis" /C:"macrium" /C:"veeam" /C:"redo" /C:"r-drive" /C:"backup" /C:"recovery" >nul
if not errorlevel 1 (
  set "category=80_Backup_Recovery"
  set "prefix=80"
  goto detected
)

echo !name! | findstr /I /C:"hiren" /C:"strelec" /C:"dlc boot" /C:"ultimate boot" /C:"gparted" /C:"systemrescue" /C:"boot repair" /C:"rescue" /C:"toolkit" >nul
if not errorlevel 1 (
  set "category=90_Utilities_Rescue"
  set "prefix=90"
  goto detected
)

echo !name! | findstr /I /C:"ubuntu" /C:"debian" /C:"fedora" /C:"centos" /C:"rocky" /C:"alma" /C:"red hat" /C:"opensuse" /C:"suse" /C:"arch" /C:"manjaro" /C:"linuxmint" /C:"mint" /C:"zorin" /C:"elementary" /C:"popos" /C:"linux" >nul
if not errorlevel 1 (
  set "category=50_Linux_General"
  set "prefix=50"
  goto detected
)

:detected
endlocal & set "%~2=%category%" & set "%~3=%prefix%"
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

:StripExistingPrefix
setlocal enabledelayedexpansion
set "candidate=%~1"
set "prefix=%~2"
set /a prefixLen=0
set "tmp=%prefix%"

:stripPrefixLen
if defined tmp (
  set "tmp=%tmp:~1%"
  set /a prefixLen+=1
  goto stripPrefixLen
)

if %prefixLen% GTR 0 (
  set "maybe=!candidate:~0,%prefixLen%!"
  if /I "!maybe!"=="%prefix%" (
    set "candidate=!candidate:~%prefixLen%!"
  )
)

if defined candidate goto stripSepCheck
goto stripPrefixDone

:stripSepCheck
set "first=!candidate:~0,1!"
for %%S in (" " "-" "_" ".") do if "!first!"=="%%~S" (
  set "candidate=!candidate:~1!"
  goto stripSepCheck
)

:stripPrefixDone
call :TrimLeading "!candidate!" cleaned
if not defined cleaned set "cleaned=%~1"
endlocal & set "%~3=%cleaned%"
goto :EOF
