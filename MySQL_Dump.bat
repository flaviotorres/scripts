@echo off
REM MySQL Dump / Backup Script for Windows NT Systems.
REM
REM This Script will dump all tables from your MySQL Instance to a 7zip archive;
REM it will Also take care of starting and stopping the MySQL Service on the machine.
REM
REM @author Jonny Reeves - http://www.jonnyreeves.co.uk/
REM Flavio Torres, v1.1 - Feb2013
REM - updated time and date format
 
setlocal
set mysql_username="USER"
set mysql_password="PASS"
set mysql_service="MySQL56"
set mysql_path="C:\Program Files\MySQL\MySQL Server 5.6\bin"
set zip_path="C:\Program Files\7-Zip\"
set output_path="C:\Backup\MySQL"
 
 
REM Start of Script.
IF NOT EXIST %output_path% (mkdir %output_path%)
 
REM Check to see if the MySQL Service is running
for /f "tokens=*" %%a IN ('sc query "%mysql_service%" ^| find "RUNNING"') do set servicerunning=%%a
if "X%servicerunning%%" == "X" (goto service_stopped) ELSE (goto service_running)
 
:service_stopped
    echo Starting MySQL Service: %mysql_service%
    net start %mysql_service%
    call :dump_and_zip
    echo Stopping MySQL Service: %mysql_service%
    net stop %mysql_service%
    goto end
 
:service_running
    echo MySQL Service is already running.
    call :dump_and_zip
    goto end
     
:dump_and_zip:
    REM Dump out the MySQL Database to a yyyymmdd .sql file
    for /f "tokens=2-4 delims=/ " %%a in ('date /t') do (set ddate=%%c%%a%%b)
    %mysql_path%\mysqldump.exe --user %mysql_username% --password=%mysql_password% --all-databases --opt > "%output_path%\%ddate%.sql"
 
    REM Check for Errors.
    if %ERRORLEVEL% NEQ 0 (goto error)
         
    REM Zip it up and remove the temp file.
    %zip_path%\7z.exe a -t7z %output_path%\%ddate%.7z %output_path%\%ddate%.sql
    del "%output_path%\%ddate%.sql"
    goto :EOF
     
:error
    echo An error occured.
    EXIT /B 42
     
:end
    endlocal
