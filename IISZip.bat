@echo on

:: Name - IISZip.bat
:: Compacta o ultimo dia de log e envia para um diretorio de backup
:: Flavio Torres, v1, Fev/2013

:: ========================================================
:: Variaveis e parametros
:: ========================================================
:: Variaveis Ano e Dia

set month=%DATE:~3,2%
set year=%DATE:~8,2%

::yyyymmdd
for /f "tokens=2-4 delims=/ " %%a in ('date /t') do (set YYYYMMDD=%%c%%a%%b)

:: Yesterday
for /F "tokens=1-4 delims=/- " %%a in ('date/T') do set MMDD=%%b%%c
for /F "tokens=1-4 delims=/- " %%a in ('date/T') do set MM=%%b
for /F "tokens=1-4 delims=/- " %%a in ('date/T') do set /a DD=%%b
for /F "tokens=1-4 delims=/- " %%a in ('date/T') do set /a YYYY=%%d

set /a YY = %YYYY% - 2000

set /a YYMMDD = %YY%%MMDD%

set /a DAY_YESTERDAY = %DD% - 1

echo %DAY_YESTERDAY%

if  "%DAY_YESTERDAY%" == "1" ( 
      set /a YESTERDAY=%YYMMDD%
)else (
      set /a YESTERDAY = %YYMMDD% - 1
)
echo %YESTERDAY%

:: Variaveis internas
set logpath1="C:\inetpub\logs\LogFiles\W3SVC1"
set logpath2="C:\inetpub\logs\LogFiles\W3SVC2"
set logpath3="C:\inetpub\logs\LogFiles\W3SVC3"
set zippath="C:\Program Files (x86)\7-Zip\7z.exe"
set arcpath1="C:\Backup\IIS\W3SVC1"
set arcpath2="C:\Backup\IIS\W3SVC2"
set arcpath3="C:\Backup\IIS\W3SVC3"


:: ========================================================
:: Compacta o ultimo dia de log e envia para o diretorio de backup
:: ========================================================
cd /D %logpath1%
%zippath% a -tzip u_ex%YYMMDD%-logs.zip %logpath1%\u_ex%YYMMDD%*.log
copy "%logpath1%\*.zip" "%arcpath1%"
:: del %logpath1%\u_ex%YYMMDD%*.log

cd /D %logpath2%
%zippath% a -tzip u_ex%YYMMDD%-logs.zip %logpath2%\u_ex%YYMMDD%*.log
copy "%logpath2%\*.zip" "%arcpath2%"
:: del %logpath2%\u_ex%YYMMDD%*.log

cd /D %logpath3%
%zippath% a -tzip u_ex%YYMMDD%-logs.zip %logpath3%\u_ex%YYMMDD%*.log
copy "%logpath3%\*.zip" "%arcpath3%"
:: del %logpath3%\u_ex%YYMMDD%*.log
