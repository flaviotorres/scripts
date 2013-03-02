-------------------------------------------------------------------------------------
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
for /f "tokens=2-4 delims=/ " %%a in ('date /t') do (set ddate=%%c%%a%%b)

:: Yesterday
for /F "tokens=1-4 delims=/- " %%a in ('date/T') do set DATE=%%c%%b 
for /F "tokens=1-4 delims=/- " %%a in ('date/T') do set /a DAY=%%b
for /F "tokens=1-4 delims=/- " %%a in ('date/T') do set /a YEAR=%%d

set YEARYY = YEAR - 2000

set /a DATA = %YEARYY%%DATE%

set /a YESTERDAY = DATA - 1
echo %DAY%
if  "%DAY%" == "1" ( 
      set YESTERDAY=%DATA%
)else (
      set YESTERDAY = DATA - 1
)
echo %YESTERDAY%

:: Variaveis internas
set logpath="C:\WINDOWS\system32\LogFiles"
set zippath="C:\Program Files\7-Zip\7z.exe"
set arcpath="C:\Backup\IIS"


:: ========================================================
:: Vai para o diretorio de log
:: ========================================================
cd /D %logpath%

:: ========================================================
:: Compacta o ultimo dia de log e envia para o diretorio de backup
:: ========================================================
%zippath% a -tzip ex%YESTERDAY%-logs.zip %logpath%\ex%YESTERDAY%*.log
copy "%logpath%\*.zip" "%arcpath%"
:: del %logpath%\ex%YESTERDAY%*.log
