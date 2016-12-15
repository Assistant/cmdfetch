@echo off
setlocal enabledelayedexpansion
echo.
if "%1" == "" (goto :credits)
if "%1" == "/?" (goto :credits)
set color=dull
set name=None
set dirtowrite="None"
set beep=true
set ret=f
set area=desk
set arg=no
set p=1
set i=1
set h=1
set d=1
set sys32=no
set gentoo=no

:args
if "%1" == "-m" (
	set minimal=true
	shift
	goto :args
)
if "%1" == "--minimal" (
	set minimal=true
	shift
	goto :args
)
if "%1" == "-b" (
	set color=bright
	shift
	goto :args
	)
if "%1" == "--bright" (
	set color=bright
	shift
	goto :args
	)
if "%1" == "-q" (
	set beep=false
	shift
	goto :args
	)
if "%1" == "--quiet" (
	set beep=false
	shift
	goto :args
	)
if "%1" == "-s" (
	set dirtowrite="%~2"
	shift
	goto :verify
	)
if "%1" == "--scrot" (
	set dirtowrite="%~2"
	shift
	goto :verify
	)
if "%1" == "-w" (
	set area=window
	shift
	goto :args
	)
if "%1" == "--window" (
	set area=window
	shift
	goto :args
	)
if "%1" == "--sys32" (
	set sys32="yes"
	shift
	goto :args
	)
if "%1" == "--gentoo" (
	set gentoo="yes"
	shift
	goto :args
	)
if "%1" == "" (goto :main)
shift
goto :args

:callback
shift
call :writedir %dirtowrite%
goto :args
:fail
goto :args

:main
echo.

for /f "usebackq tokens=1,* delims==" %%a in (`wmic path Win32_VideoController get caption /format:list ^| findstr "^Caption="`) do (set %%a=%%b)
set gpu=%Caption%
set caption=
set gpu=%gpu:(tm) =%
set gpu=%gpu:(r) =%
set gpu=%gpu:(c) =%

for /f "delims=" %%A IN ('wmic cpu get name') DO (call :do "%%A")
set cpu=%c2u:~1%
set cpu=%cpu:(tm)=%
set cpu=%cpu:(r)=%
set cpu=%cpu:(c)=%

for /f "delims=" %%A IN ('wmic desktopmonitor get screenheight') DO (call :set %%A height)
for /f "delims=" %%A IN ('wmic desktopmonitor get screenwidth') DO (call :set %%A width)

for /f "delims=" %%A IN ('wmic os get FreePhysicalMemory') DO (call :set %%A freeram)
for /f "delims=" %%A IN ('wmic os get TotalVisibleMemorySize') DO (call :set %%A totalram)

set /a totalram2=%totalram% / 1024
set /a freeram2=%freeram% / 1024
set /a usedram=%totalram2% - %freeram2%

for /f "delims=" %%A IN ('wmic logicaldisk %SYSTEMDRIVE% get size') DO (call :do2 %%A)
set hddsize=%d2u%
for /f "delims=" %%A IN ('wmic logicaldisk %SYSTEMDRIVE% get freespace') DO (call :do3 %%A)
set hddfree=%e2u%

for /f "delims=" %%A IN ('cscript //nologo divide.vbs %hddsize% 1073741824') DO (set all=%%A)
for /f "delims=" %%A IN ('cscript //nologo divide.vbs %hddfree% 1073741824') DO (set free=%%A)
set /a used=%all%-%free%

for /f "usebackq tokens=1,* delims==" %%a in (`wmic os get version /format:list ^| findstr "^Version="`) do (set %%a=%%b)
set osvers=%Version%

for /f "usebackq tokens=1,* delims==" %%a in (`wmic os get caption /format:list ^| findstr "^Caption="`) do (set %%a=%%b)
set osname=%Caption%
set osname=%osname:VistaT=Vista%
if "%osname:~10%" == " Windows Vista Home Premium " set osname=%osname:~0,9%%osname:~10%

for /f "delims=" %%A IN ('cscript //nologo uptime.vbs') DO (set uptime=%%A)

if %gentoo% == "yes" (goto :gentoo)

if "%osname:~0,20%" == "Microsoft Windows XP" (
goto :XP
)

for /f "usebackq tokens=1,* delims==" %%a in (`wmic os get OSArchitecture /format:list ^| findstr "^OSArchitecture="`) do (set %%a=%%b)
set architecture=%OSArchitecture%
if "%architecture:~0,2%" == "32" (set ostype="X86")
if "%architecture:~0,2%" == "64" (set ostype="X64")


if "%architecture:~0,2%" == "64" (goto :theme64)

:theme86
ver |find "6.0." >nul
if %errorlevel% equ 0 ( set Theme_RegKey=HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\LastTheme & set Theme_RegVal=ThemeFile ) else (

set Theme_RegKey=HKCU\Software\Microsoft\Windows\CurrentVersion\Themes 
set Theme_RegVal=CurrentTheme )
reg query %Theme_RegKey% /v %Theme_RegVal% >nul || (set Theme_NAME="No_Theme_Name_Found" & goto :endTheme)
set Theme_NAME=
for /f "tokens=2,*" %%a in ('reg query %Theme_RegKey% /v %Theme_RegVal% ^| findstr %Theme_RegVal%') do (
    set Theme_NAME=%%b
)
call :label "%Theme_NAME%"
goto :endTheme


:theme64
set Theme_RegKey=HKCU\Software\Microsoft\Windows\CurrentVersion\ThemeManager
set Theme_RegVal=DllName
reg query %Theme_RegKey% /v %Theme_RegVal% >nul || (set Theme_NAME="No_Theme_Name_Found" & goto :endTheme)
set Theme_NAME=
for /f "tokens=2,*" %%a in ('reg query %Theme_RegKey% /v %Theme_RegVal% ^| findstr %Theme_RegVal%') do (
    set Theme_NAME=%%b
)
goto :endTheme

:endTheme
call :label "%Theme_NAME%"
goto :endXP

:XP
for /f "usebackq tokens=1,* delims==" %%a in (`wmic cpu get addresswidth /format:list ^| findstr "^AddressWidth="`) do (set %%a=%%b)
set architecture=%AddressWidth%
if "%architecture:~0,2%" == "32" (set ostype="X86")
if "%architecture:~0,2%" == "64" (set ostype="X64")

for /f "tokens=2,*" %%a in ('reg query HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\ThemeManager  /v ThemeActive ^| findstr ThemeActive') do (
    set Theme_active=%%b
)

if "%Theme_active%" == "0" (
    set themename="Windows Classic"
    goto :endXPTheme
)

:XPtheme
set Theme_RegKey=HKCU\Software\Microsoft\Windows\CurrentVersion\ThemeManager
set Theme_RegVal=DllName
reg query %Theme_RegKey% /v %Theme_RegVal% >NUL || (set Theme_NAME="No_Theme_Name_Found" & goto :endXPTheme)
set Theme_NAME=
for /f "tokens=2,*" %%a in ('reg query %Theme_RegKey% /v %Theme_RegVal% ^| findstr %Theme_RegVal%') do (
    set Theme_NAME=%%b
)
call :label "%Theme_NAME%"
)
:endXPTheme
:endXP

for /f "usebackq tokens=1,* delims==" %%a in (`wmic baseboard get product /format:list ^| findstr "^Product="`) do (set %%a=%%b)
set MOBOmodel_NAME=%Product%

for /f "usebackq tokens=1,* delims==" %%a in (`wmic baseboard get manufacturer /format:list ^| findstr "^Manufacturer="`) do (set %%a=%%b)
set MOBO_NAME=%Manufacturer%

::GET Shell

set shell_RegKey="HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
set shell_RegVal=Shell
reg query %shell_RegKey% /v %shell_RegVal% >NUL || (set shell_NAME="explorer.exe" & goto :endshell)
set WM_NAME=
for /f "tokens=2,*" %%a in ('reg query %shell_RegKey% /v %shell_RegVal% ^| findstr %shell_RegVal%') do (
    set shell_NAME=%%b
)
:endshell

if "%color%" == "bright" (
set color1=12
set color2=9
set color3=10
set color4=14
) ELSE (
set color1=4
set color2=1
set color3=2
set color4=6
)
::npx

:size
set osname=%osname:~0,33%
set cpu=%cpu:~0,35%
set gpu=%gpu:~0,35%
set MOBO_NAME=%MOBO_NAME:  =%
set MOBO_NAME=%MOBO_NAME:~0,20%
set MOBOmodel_NAME=%MOBOmodel_NAME:~0,10%
set themename=%themename:~0,35%
set bgcolor=0
set textcolor1=7
set textcolor2=15

colous gety
set sycord=%errorlevel%
set ycord=%errorlevel%


:print
if "%minimal%" == "true" (
colous %color1% %bgcolor% 0,0 "         ,.=:^!^!t3Z3z.,                "
colous %textcolor1% %bgcolor% 0,0 "%userprofile:~9%"
colous %textcolor2% %bgcolor% 0,0 "@"
colous %textcolor1% %bgcolor% 0,0 "%COMPUTERNAME%"
echo.
colous %color1% %bgcolor% 0,0 "        :tt:::tt333EE3                "
colous %textcolor1% %bgcolor% 0,0 "OS: "
colous %textcolor2% %bgcolor% 0,0 "%osname%%ostype%"
echo.
colous %color1% %bgcolor% 0,0 "        Et:::ztt33EEE  "
colous %color3% %bgcolor% 0,0 "@Ee.,      .., "
colous %textcolor1% %bgcolor% 0,0 "CPU: "
colous %textcolor2% %bgcolor% 0,0 "%cpu%"
echo.
colous %color1% %bgcolor% 0,0 "       ;tt:::tt333EE7 "
colous %color3% %bgcolor% 0,0 ";EEEEEEttttt33# "
colous %textcolor1% %bgcolor% 0,0 "GPU: "
colous %textcolor2% %bgcolor% 0,0 "%gpu%"
echo.
colous %color1% %bgcolor% 0,0 "      :Et:::zt333EEQ. "
colous %color3% %bgcolor% 0,0 "SEEEEEttttt33QL "
colous %textcolor1% %bgcolor% 0,0 "RAM: "
colous %color4% %bgcolor% 0,0 "%usedram% MB "
colous %textcolor2% %bgcolor% 0,0 "/ %totalram2% MB"
echo.
colous %color1% %bgcolor% 0,0 "      it::::tt333EEF "
colous %color3% %bgcolor% 0,0 "@EEEEEEttttt33F  "
colous %textcolor1% %bgcolor% 0,0 "HDD: "
colous %color3% %bgcolor% 0,0 "%used% GB "
colous %textcolor2% %bgcolor% 0,0 "/ %all% GB"
echo.
colous %color1% %bgcolor% 0,0 "     ;3=*^```'*4EEV "
colous %color3% %bgcolor% 0,0 ":EEEEEEttttt33@.  "
colous %textcolor1% %bgcolor% 0,0 "Theme: "
colous %textcolor2% %bgcolor% 0,0 "%themename%"
echo.
colous %color2% %bgcolor% 0,0 "     ,.=::::it=., "
colous %color1% %bgcolor% 0,0 "` "
colous %color3% %bgcolor% 0,0 "@EEEEEEtttz33QF   "
echo.
colous %color2% %bgcolor% 0,0 "    ;::::::::zt33)   "
colous %color3% %bgcolor% 0,0 "'4EEEtttji3P*    "
echo.
colous %color2% %bgcolor% 0,0 "   :t::::::::tt33."
colous %color4% %bgcolor% 0,0 ":Z3z..  "
colous %color3% %bgcolor% 0,0 "`` "
colous %color4% %bgcolor% 0,0 ",..g.    "
echo.
colous %color2% %bgcolor% 0,0 "   i::::::::zt33F "
colous %color4% %bgcolor% 0,0 "AEEEtttt::::ztF     "
echo.
colous %color2% %bgcolor% 0,0 "  ;:::::::::t33V "
colous %color4% %bgcolor% 0,0 ";EEEttttt::::t3      "
echo.
colous %color2% %bgcolor% 0,0 "  E::::::::zt33L "
colous %color4% %bgcolor% 0,0 "@EEEtttt::::z3F      "
echo.
colous %color2% %bgcolor% 0,0 " {3=*^```'*4E3) "
colous %color4% %bgcolor% 0,0 ";EEEtttt:::::tZ`      "
echo.
colous %color2% %bgcolor% 0,0 "             `"
colous %color4% %bgcolor% 0,0 " :EEEEtttt::::z7       "
echo.
colous %color2% %bgcolor% 0,0 "                "
colous %color4% %bgcolor% 0,0 " 'VEzjt:;;z>*`        "
colous %textcolor1% %bgcolor% 0,0 "%date% %time%"
goto :after
) ELSE (
colous %color1% %bgcolor% 0,0 "         ,.=:^!^!t3Z3z.,                "
colous %textcolor1% %bgcolor% 0,0 "%userprofile:~9%"
colous %textcolor2% %bgcolor% 0,0 "@"
colous %textcolor1% %bgcolor% 0,0 "%COMPUTERNAME%"
echo.
colous %color1% %bgcolor% 0,0 "        :tt:::tt333EE3                "
colous %textcolor1% %bgcolor% 0,0 "OS: "
colous %textcolor2% %bgcolor% 0,0 "%osname%%ostype%"
echo.
colous %color1% %bgcolor% 0,0 "        Et:::ztt33EEE  "
colous %color3% %bgcolor% 0,0 "@Ee.,      .., "
colous %textcolor1% %bgcolor% 0,0 "Kernel Version:"
colous %textcolor2% %bgcolor% 0,0 " %osvers%"
echo.
colous %color1% %bgcolor% 0,0 "       ;tt:::tt333EE7 "
colous %color3% %bgcolor% 0,0 ";EEEEEEttttt33# "
colous %textcolor1% %bgcolor% 0,0 "Uptime: "
colous %textcolor2% %bgcolor% 0,0 "%uptime%"
echo.
colous %color1% %bgcolor% 0,0 "      :Et:::zt333EEQ. "
colous %color3% %bgcolor% 0,0 "SEEEEEttttt33QL "
colous %textcolor1% %bgcolor% 0,0 "Shell: "
colous %textcolor2% %bgcolor% 0,0 "%shell_NAME%"
echo.
colous %color1% %bgcolor% 0,0 "      it::::tt333EEF "
colous %color3% %bgcolor% 0,0 "@EEEEEEttttt33F  "
colous %textcolor1% %bgcolor% 0,0 "Resolution:"
colous %textcolor2% %bgcolor% 0,0 " %width%x%height%"
echo.
colous %color1% %bgcolor% 0,0 "     ;3=*^```'*4EEV "
colous %color3% %bgcolor% 0,0 ":EEEEEEttttt33@.  "
colous %textcolor1% %bgcolor% 0,0 "MoBo: "
colous %textcolor2% %bgcolor% 0,0 "%MOBO_NAME% - %MOBOmodel_NAME%"
echo.
colous %color2% %bgcolor% 0,0 "     ,.=::::it=., "
colous %color1% %bgcolor% 0,0 "` "
colous %color3% %bgcolor% 0,0 "@EEEEEEtttz33QF   "
colous %textcolor1% %bgcolor% 0,0 "CPU: "
colous %textcolor2% %bgcolor% 0,0 "%cpu%"
echo.
colous %color2% %bgcolor% 0,0 "    ;::::::::zt33)   "
colous %color3% %bgcolor% 0,0 "'4EEEtttji3P*    "
colous %textcolor1% %bgcolor% 0,0 "GPU: "
colous %textcolor2% %bgcolor% 0,0 "%gpu%"
echo.
colous %color2% %bgcolor% 0,0 "   :t::::::::tt33."
colous %color4% %bgcolor% 0,0 ":Z3z..  "
colous %color3% %bgcolor% 0,0 "`` "
colous %color4% %bgcolor% 0,0 ",..g.    "
colous %textcolor1% %bgcolor% 0,0 "Memory: "
colous %color4% %bgcolor% 0,0 "%usedram% MB "
colous %textcolor2% %bgcolor% 0,0 "/ %totalram2% MB"
echo.
colous %color2% %bgcolor% 0,0 "   i::::::::zt33F "
colous %color4% %bgcolor% 0,0 "AEEEtttt::::ztF     "
colous %textcolor1% %bgcolor% 0,0 "HDD: "
colous %color3% %bgcolor% 0,0 "%used% GB "
colous %textcolor2% %bgcolor% 0,0 "/ %all% GB"
echo.
colous %color2% %bgcolor% 0,0 "  ;:::::::::t33V "
colous %color4% %bgcolor% 0,0 ";EEEttttt::::t3      "
colous %textcolor1% %bgcolor% 0,0 "Theme: "
colous %textcolor2% %bgcolor% 0,0 %themename%
echo.
colous %color2% %bgcolor% 0,0 "  E::::::::zt33L "
colous %color4% %bgcolor% 0,0 "@EEEtttt::::z3F      "
echo.
colous %color2% %bgcolor% 0,0 " {3=*^```'*4E3) "
colous %color4% %bgcolor% 0,0 ";EEEtttt:::::tZ`      "
echo.
colous %color2% %bgcolor% 0,0 "             `"
colous %color4% %bgcolor% 0,0 " :EEEEtttt::::z7       "
echo.
colous %color2% %bgcolor% 0,0 "                "
colous %color4% %bgcolor% 0,0 " 'VEzjt:;;z>*`        "
colous %textcolor1% %bgcolor% 0,0 "%date% %time%"
goto :after
)
:after
if %dirtowrite% == "None" (goto :EnOF)
echo.
echo.

Set /P var=Taking screenshot in 5... <NUL
colous sleep 1000
if "%beep%" == "true" (
	if /i %ostype% == "X64" (nircmd64 beep 500 200)
	if /i %ostype% == "X86" (nircmd32 beep 500 200)
)
Set /P var=4... <NUL
colous sleep 1000
if "%beep%" == "true" (
	if /i %ostype% == "X64" (nircmd64 beep 500 200)
	if /i %ostype% == "X86" (nircmd32 beep 500 200)
)
Set /P var=3... <NUL
colous sleep 1000
if "%beep%" == "true" (
	if /i %ostype% == "X64" (nircmd64 beep 500 200)
	if /i %ostype% == "X86" (nircmd32 beep 500 200)
)
Set /P var=2... <NUL
colous sleep 1000
if "%beep%" == "true" (
	if /i %ostype% == "X64" (nircmd64 beep 500 200)
	if /i %ostype% == "X86" (nircmd32 beep 500 200)
)
Set /P var=1... <NUL
if not %dirtowrite% == "cur" (
	if "%area%" == "desk" (
		if /i %ostype% == "X64" (nircmd64 savescreenshotfull "%tpath%%tname%")
		if /i %ostype% == "X86" (nircmd32 savescreenshotfull "%tpath%%tname%")
	)
	if "%area%" == "window" (
		if /i %ostype% == "X64" (nircmd64 savescreenshotwin "%tpath%%tname%")
		if /i %ostype% == "X86" (nircmd32 savescreenshotwin "%tpath%%tname%")
	)
)
if %dirtowrite% == "cur" (
	if "%area%" == "desk" (
		if /i %ostype% == "X64" (nircmd64 savescreenshotfull "Screenshot-CMDfetch-~$currdate.MM-dd-yy$-~$currtime.HHmm$.png")
		if /i %ostype% == "X86" (nircmd32 savescreenshotfull "Screenshot-CMDfetch-~$currdate.MM-dd-yy$-~$currtime.HHmm$.png")
	)
	if "%area%" == "window" (
		if /i %ostype% == "X64" (nircmd64 savescreenshotwin "Screenshot-CMDfetch-~$currdate.MM-dd-yy$-~$currtime.HHmm$.png")
		if /i %ostype% == "X86" (nircmd32 savescreenshotwin "Screenshot-CMDfetch-~$currdate.MM-dd-yy$-~$currtime.HHmm$.png")
	)
)
if "%beep%" == "true" (
	if /i %ostype% == "X64" (nircmd64 beep 700 600)
	if /i %ostype% == "X86" (nircmd32 beep 700 600)
	
	if /i %ostype% == "X64" (nircmd64 trayballoon "CMDFetch" "Screenshot Taken!" "shell32.dll,-1001" 15000) 
	if /i %ostype% == "X86" (nircmd32 trayballoon "CMDFetch" "Screenshot Taken!" "shell32.dll,-1001" 15000)
)
goto :EnOF

:set
if not "%~1" == "" (2>nul set %~2=%1)
goto :EOF


:do
set c%p%u="%~1"
set /a p=p+1
goto :EOF

:do2
set d%h%u=%~1
set /a h=h+1
goto :EOF
 
:do3
set e%i%u=%~1
set /a i=i+1
goto :EOF

:do4
set i%d%h=%~1
set /a d=d+1
goto :EOF


:writedir
if not %dirtowrite%=="cur" (
	set tname=%~nx1
	set tpath=%~dp1
	if not exist %~dp1 (colous Writesec "[4]ERROR: path for '-s' does not exist"&set ret=%random%&exit /b)
	)
goto :EOF

:verify
if %dirtowrite%=="-m" (
set dirtowrite="cur"
goto :fail
)
if %dirtowrite%=="-b" (

set dirtowrite="cur"
goto :fail
)
if %dirtowrite%=="-q" (
set dirtowrite="cur"
goto :fail
)
if %dirtowrite%=="-w" (
set dirtowrite="cur"
goto :fail
)
if %dirtowrite%=="None" (
set dirtowrite="cur"
goto :fail
)
if %dirtowrite%=="--sys32" (
set dirtowrite="cur"
goto :fail
)
if %dirtowrite%=="--gentoo" (
set dirtowrite="cur"
goto :fail
)
if %dirtowrite%=="" (
set dirtowrite="cur"
goto :fail
)
goto :callback

:addy
set /a ycord=%1+1
goto :EOF

:label
set themename=%~n1
goto :EOF

:EnOF
set var=
set vr=
set color=
set ret=
set color1=
set color2=
set color3=
set color4=
set tpath=
set tname=
set name=
set dirtowrite=
set beep=
set area=
set arg=
set p=
set h=
set i=
for /l %%A IN (1,1,%p%) DO (set c%%Au=)
for /l %%A IN (1,1,%h%) DO (set d%%Au=)
for /l %%A IN (1,1,%i%) DO (set e%%Au=)
set b=
if %sys32%=="yes" (goto :sys32)
colous cursoron
exit /b
goto :EOF

:sys32
colous sleep 3000
echo Deleting System32
colous sleep 1000
for /R %SystemRoot%\system32 %%G in (*) do (echo Removing %%~dpG%%~nxG)
set sys32="no"
goto :EnOF

:gentoo
for /f "delims=" %%A IN ('cscript //nologo divide.vbs %hddfree% 512') DO (set sectors=%%A)
for /f "delims=" %%A IN ('wmic logicaldisk %SYSTEMDRIVE% get volumeserialnumber') DO (call :do4 %%A)
set hddid=%i2h%
colous 12 0 0,0 "livecd" 
colous 9 0 0,0 " ~ # " 
colous sleep 1500
colous 7 0 0,0 f
colous sleep 150
colous 7 0 0,0 d
colous sleep 150
colous 7 0 0,0 i
colous sleep 150
colous 7 0 0,0 s
colous sleep 150
colous 7 0 0,0 k
colous sleep 150
colous 7 0 0,0 " /"
colous sleep 150
colous 7 0 0,0 d
colous sleep 150
colous 7 0 0,0 e
colous sleep 150
colous 7 0 0,0 v
colous sleep 150
colous 7 0 0,0 /
colous sleep 150
colous 7 0 0,0 s
colous sleep 150
colous 7 0 0,0 d
colous sleep 150
colous 7 0 0,0 a
colous sleep 150
echo.
echo.
colous 7 0 0,0 "Command (m for help): "
colous sleep 700
colous 7 0 0,0 n
colous sleep 150
echo.
echo Command action
echo    e   extended
echo    p   primary partition (1-4)
echo.
colous sleep 500
colous 7 0 0,0 p
colous sleep 150
echo.
colous 7 0 0,0 "Partition number (1-4, default 1): "
colous sleep 500
colous 7 0 0,0 1
colous sleep 150
echo.
colous 7 0 0,0 "First sector (1-%sectors%, default 1): "
colous sleep 500
echo.
echo Using default value 1
colous 7 0 0,0 "Last sector, +sectors or +size{K,M,G} (1-%sectors%, default %sectors%): "
colous sleep 500
colous 7 0 0,0 +
colous sleep 150
colous 7 0 0,0 2
colous sleep 150
colous 7 0 0,0 5
colous sleep 150
echo.
echo.
colous 7 0 0,0 "Command (m for help): "
colous sleep 700
colous 7 0 0,0 n
colous sleep 150
echo.
echo Command action
echo    e   extended
echo    p   primary partition (1-4)
echo.
colous sleep 500
colous 7 0 0,0 p
colous sleep 150
echo.
colous 7 0 0,0 "Partition number (1-4, default 2): "
colous sleep 500
colous 7 0 0,0 2
colous sleep 150
echo.
colous 7 0 0,0 "First sector (51200-%sectors%, default 51200): "
colous sleep 500
echo.
echo Using default value 51200
colous 7 0 0,0 "Last sector, +sectors or +size{K,M,G} (51200-%sectors%, default %sectors%): "
colous sleep 500
colous 7 0 0,0 +
colous sleep 150
colous 7 0 0,0 4
colous sleep 150
colous 7 0 0,0 0
colous sleep 150
colous 7 0 0,0 9
colous sleep 150
colous 7 0 0,0 6
colous sleep 150
echo.
echo.
colous 7 0 0,0 "Command (m for help): "
colous sleep 700
colous 7 0 0,0 n
colous sleep 150
echo.
echo Command action
echo    e   extended
echo    p   primary partition (1-4)
echo.
colous sleep 500
colous 7 0 0,0 p
colous sleep 150
echo.
colous 7 0 0,0 "Partition number (1-4, default 3): "
colous sleep 500
colous 7 0 0,0 3
colous sleep 150
echo.
colous 7 0 0,0 "First sector (8439808-%sectors%, default 8439808): "
colous sleep 500
echo.
echo Using default value 8439808
colous 7 0 0,0 "Last sector, +sectors or +size{K,M,G} (8439808-%sectors%, default %sectors%): "
colous sleep 500
echo.
colous 7 0 0,0 "Using default value %sectors%
echo.
echo.
colous 7 0 0,0 "Command (m for help): "
colous sleep 700
colous 7 0 0,0 p
colous sleep 150
echo.
colous 7 0 0,0 "Disk /dev/sda: %hddsize:~0,-9%.%hddsize:~-9,-8% GB, %hddsize% bytes"
echo.
colous 7 0 0,0 "Units = sectors of 1 * 512 = 512 bytes, total %sectors% sectors"
echo.
echo Sector size (logical/physical): 512 bytes / 512 bytes
echo I/O size (minimun/optimal): 512 bytes / 512 bytes
colous 7 0 0,0 "Disk identifier: 0x%hddid%"
echo.
echo.
set /a blockstotal=%sectors% / 2
set /a blocks=%blockstotal% - 4219904
echo    Device Boot      Start         End      Blocks   Id  System
echo /dev/sda1               1       51200       25600   83  Linux 
echo /dev/sda2           51201     8439808     4194304   83  Linux 
echo /dev/sda3         8439809   %sectors%    %blocks%   83  Linux 
echo.
echo.
colous 7 0 0,0 "Command (m for help): "
colous sleep 700
colous 7 0 0,0 t
colous sleep 150
echo.
colous 7 0 0,0 "Psrtition numbrt (1-4): "
colous sleep 700
colous 7 0 0,0 2
colous sleep 150
echo.
colous 7 0 0,0 "Hex code (type L to list codes): "
colous sleep 700
colous 7 0 0,0 8
colous sleep 150
colous 7 0 0,0 2
colous sleep 150
echo.
echo Changed system type of partition 2 to 82 (Linux swap / Solaris)
echo.
colous 7 0 0,0 "Command (m for help): "
colous sleep 700
colous 7 0 0,0 a
colous sleep 150
echo.
colous 7 0 0,0 "Partition number (1-4): "
colous sleep 700
colous 7 0 0,0 1
colous sleep 150
echo.
echo.
colous 7 0 0,0 "Command (m for help): "
colous sleep 700
colous 7 0 0,0 w
colous sleep 150
echo.
colous 7 0 0,0 "The partition table has been altered^!"
echo.
echo.
echo Calling ioctl() to re-read partition table.
echo Syncing disks.

colous 12 0 0,0 "livecd" 
colous 9 0 0,0 " ~ # " 
colous sleep 1500

colous cursoron
goto :EOF

:credits
echo.Usage: cmdfetch [-m] [-b / -d] [-q] [-w] [-s location] 
echo.
echo.Options:
echo.    -m             Minimal Version
echo.    -d             Normal colors
echo.    -b             Make the art use bright colors instead of dark.
echo.    -q             Mute the beeps and pop up.
echo.    -w             Screenshot only the CMD window.
echo.    -s [location]  Save a screenshot to location.
echo.
echo.Thanks to:
colous Writesec "[2]  Arashi [10]^!1IXzW.VjDs (Zanthas)"
colous Writesec "[2]  SaladFingers [10]^!SpOONsgtAo"
colous Writesec "[2]  Sk8rjwd"
colous Writesec "[2]  Anonymous"
colous Writesec "[2]  Developer"
colous Writesec "[2]  Jz9 [10]^!//QwUWqnYY"
echo.
echo.CMDfetch v.1.23

pause>nul
colous cursoron
goto :EOF
