@ECHO off
REM // --------------------------------------------------------------------------
REM // File name   : phpCBCLI.bat
REM // Description : phpCodeBeautifier�����а汾
REM // Requirement : phpCodeBeautifier
REM //
REM // Copyright(C), HonestQiao, 2005, All Rights Reserved.
REM //
REM // Author: HonestQiao (honestqiao@hotmail.com) 
REM //
REM // --------------------------------------------------------------------------
SETLOCAL
:_START_

REM ����phpCB·��
set phpCB=C:/Program Files/SciTE/tools/phpCB/phpCB.exe
if NOT EXIST "%phpCB%" echo ������phpCB.exe��·����"%phpCB%"�������� & goto :_END_

REM ������ʼ��
REM ����ǰ��������
set CODECOUNT_BEFOR=0
REM �������������
set CODECOUNT_AFTER=0
REM ����ǰ����������仯����
set CODECOUNT_CB=0
REM ����ǰ���������������־
set CODECOUNT_CB_FLAG=

REM ����ǰ�����ֽ���
set BYTECOUNT_BEFOR=0
REM ����������ֽ���
set BYTECOUNT_AFTER=0
REM ����ǰ������ֽ����仯��
set BYTECOUNT_CB=0
REM ����ǰ������ֽ���������־
set BYTECOUNT_CB_FLAG=

REM ��дԴ�ļ���ʹ��������Ĵ��븲��Դ�ļ�������
REM ��2��������REWRITE=YES����ʾ����
set REWRITE_FLAG=0
set REWRITE_TYPE=��ʾ������Ĵ���
if "%2=%3" == "REWRITE=YES" set REWRITE_FLAG=1
if "%REWRITE_FLAG%" == "1" set REWRITE_TYPE=��дԴ�ļ�

REM Դ�ļ�����·��
set SOURCEFILENAME=%1
REM ������ʱ�ļ�·��
set TEMPFILENAME="%TEMP%\phpcbTemp_%RANDOM%.php"


REM ����Դ�ļ���������
for /F "tokens=1 delims=:" %%a IN ('findstr /NR /C:"." %SOURCEFILENAME%') DO set /A CODECOUNT_BEFOR=%%a
REM ����Դ�ļ��ֽ���
for /F "tokens=3 delims= " %%a IN ('dir /-C %SOURCEFILENAME% ^| find " 1 "') DO set /A BYTECOUNT_BEFOR=%%a

REM ��������
"%phpCB%" %SOURCEFILENAME% > %TEMPFILENAME%

REM ���������ļ���������
for /F "tokens=1 delims=:" %%a IN ('findstr /NR /C:"." %TEMPFILENAME%') DO set /A CODECOUNT_AFTER=%%a
REM ���������ļ��ֽ���
for /F "tokens=3 delims= " %%a IN ('dir /-C %TEMPFILENAME% ^| find " 1 "') DO set /A BYTECOUNT_AFTER=%%a

REM ����Դ�ļ�
if "%REWRITE_FLAG%" == "1" move /Y %TEMPFILENAME% %SOURCEFILENAME%
if "%REWRITE_FLAG%" == "0" type %TEMPFILENAME% & echo.

REM ͳ������ǰ����������仯
if %CODECOUNT_BEFOR% GEQ %CODECOUNT_AFTER% (set /A CODECOUNT_CB=%CODECOUNT_BEFOR%-%CODECOUNT_AFTER%) ELSE (set /A CODECOUNT_CB=%CODECOUNT_AFTER%-%CODECOUNT_BEFOR%)
if %CODECOUNT_BEFOR% GTR %CODECOUNT_AFTER% (set CODECOUNT_CB_FLAG=-)
if %CODECOUNT_BEFOR% LSS %CODECOUNT_AFTER% (set CODECOUNT_CB_FLAG=+)

REM ͳ������ǰ������ֽ����仯
if %BYTECOUNT_BEFOR% GEQ %BYTECOUNT_AFTER% (set /A BYTECOUNT_CB=%BYTECOUNT_BEFOR%-%BYTECOUNT_AFTER%) ELSE (set /A BYTECOUNT_CB=%BYTECOUNT_AFTER%-%BYTECOUNT_BEFOR%)
if %BYTECOUNT_BEFOR% GTR %BYTECOUNT_AFTER% (set BYTECOUNT_CB_FLAG=-)
if %BYTECOUNT_BEFOR% LSS %BYTECOUNT_AFTER% (set BYTECOUNT_CB_FLAG=+)

echo ����������ɣ�ͳ���������£�
echo �ļ�·����%SOURCEFILENAME%
echo ������ʽ��%REWRITE_TYPE%
echo ����ǰ������������%CODECOUNT_BEFOR%    �ֽ�����%BYTECOUNT_BEFOR% 
echo �����������������%CODECOUNT_AFTER%    �ֽ�����%BYTECOUNT_AFTER%
echo ����ǰ��仯������%CODECOUNT_CB_FLAG%%CODECOUNT_CB%    �ֽ�����%BYTECOUNT_CB_FLAG%%BYTECOUNT_CB%

:_END_
echo ---------- PHP�������� ----------
ENDLOCAL
