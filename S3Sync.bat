@echo off
REM S3Sync.nat
REM
REM Este script enviara o contetudo do diretorio para o S3
REM Programas necessarios: S3Sync
REM
REM Flavio Torres, v1 - Feb2013
REM 

"C:\Program Files\SprightlySoft\S3 Sync\S3Sync.exe" -AWSAccessKeyId SUA_ACCESS_KEY_ID -AWSSecretAccessKey SUA_SECRET_ACCESS_KEY -BucketName NOME_DO_BUCKET -SyncDirection Upload -LocalFolderPath "C:\Backup" -DeleteS3ItemsWhereNotInLocalList false -OutputLevel 2 -CompareFilesBy ETag -LogFilePath "C:\Documents and Settings\Administrator\Local Settings\Temp\S3SyncLog.txt"

