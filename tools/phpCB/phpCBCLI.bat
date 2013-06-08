@ECHO off
REM // --------------------------------------------------------------------------
REM // File name   : phpCBCLI.bat
REM // Description : phpCodeBeautifier命令行版本
REM // Requirement : phpCodeBeautifier
REM //
REM // Copyright(C), HonestQiao, 2005, All Rights Reserved.
REM //
REM // Author: HonestQiao (honestqiao@hotmail.com) 
REM //
REM // --------------------------------------------------------------------------
SETLOCAL
:_START_

REM 设置phpCB路径
set phpCB=C:/Program Files/SciTE/tools/phpCB/phpCB.exe
if NOT EXIST "%phpCB%" echo 请设置phpCB.exe的路径，"%phpCB%"并不存在 & goto :_END_

REM 变量初始化
REM 美化前代码行数
set CODECOUNT_BEFOR=0
REM 美化后代码行数
set CODECOUNT_AFTER=0
REM 美化前后代码行数变化行数
set CODECOUNT_CB=0
REM 美化前后代码行数增减标志
set CODECOUNT_CB_FLAG=

REM 美化前代码字节数
set BYTECOUNT_BEFOR=0
REM 美化后代码字节数
set BYTECOUNT_AFTER=0
REM 美化前后代码字节数变化数
set BYTECOUNT_CB=0
REM 美化前后代码字节数增减标志
set BYTECOUNT_CB_FLAG=

REM 重写源文件，使用美化后的代码覆盖源文件的内容
REM 第2个参数：REWRITE=YES，表示覆盖
set REWRITE_FLAG=0
set REWRITE_TYPE=显示美化后的代码
if "%2=%3" == "REWRITE=YES" set REWRITE_FLAG=1
if "%REWRITE_FLAG%" == "1" set REWRITE_TYPE=重写源文件

REM 源文件完整路径
set SOURCEFILENAME=%1
REM 美化临时文件路径
set TEMPFILENAME="%TEMP%\phpcbTemp_%RANDOM%.php"


REM 计算源文件代码行数
for /F "tokens=1 delims=:" %%a IN ('findstr /NR /C:"." %SOURCEFILENAME%') DO set /A CODECOUNT_BEFOR=%%a
REM 计算源文件字节数
for /F "tokens=3 delims= " %%a IN ('dir /-C %SOURCEFILENAME% ^| find " 1 "') DO set /A BYTECOUNT_BEFOR=%%a

REM 美化代码
"%phpCB%" %SOURCEFILENAME% > %TEMPFILENAME%

REM 计算美化文件代码行数
for /F "tokens=1 delims=:" %%a IN ('findstr /NR /C:"." %TEMPFILENAME%') DO set /A CODECOUNT_AFTER=%%a
REM 计算美化文件字节数
for /F "tokens=3 delims= " %%a IN ('dir /-C %TEMPFILENAME% ^| find " 1 "') DO set /A BYTECOUNT_AFTER=%%a

REM 美化源文件
if "%REWRITE_FLAG%" == "1" move /Y %TEMPFILENAME% %SOURCEFILENAME%
if "%REWRITE_FLAG%" == "0" type %TEMPFILENAME% & echo.

REM 统计美化前后代码行数变化
if %CODECOUNT_BEFOR% GEQ %CODECOUNT_AFTER% (set /A CODECOUNT_CB=%CODECOUNT_BEFOR%-%CODECOUNT_AFTER%) ELSE (set /A CODECOUNT_CB=%CODECOUNT_AFTER%-%CODECOUNT_BEFOR%)
if %CODECOUNT_BEFOR% GTR %CODECOUNT_AFTER% (set CODECOUNT_CB_FLAG=-)
if %CODECOUNT_BEFOR% LSS %CODECOUNT_AFTER% (set CODECOUNT_CB_FLAG=+)

REM 统计美化前后代码字节数变化
if %BYTECOUNT_BEFOR% GEQ %BYTECOUNT_AFTER% (set /A BYTECOUNT_CB=%BYTECOUNT_BEFOR%-%BYTECOUNT_AFTER%) ELSE (set /A BYTECOUNT_CB=%BYTECOUNT_AFTER%-%BYTECOUNT_BEFOR%)
if %BYTECOUNT_BEFOR% GTR %BYTECOUNT_AFTER% (set BYTECOUNT_CB_FLAG=-)
if %BYTECOUNT_BEFOR% LSS %BYTECOUNT_AFTER% (set BYTECOUNT_CB_FLAG=+)

echo 代码美化完成，统计数据如下：
echo 文件路径：%SOURCEFILENAME%
echo 美化方式：%REWRITE_TYPE%
echo 美化前代码总行数：%CODECOUNT_BEFOR%    字节数：%BYTECOUNT_BEFOR% 
echo 美化后代码总行数：%CODECOUNT_AFTER%    字节数：%BYTECOUNT_AFTER%
echo 美化前后变化行数：%CODECOUNT_CB_FLAG%%CODECOUNT_CB%    字节数：%BYTECOUNT_CB_FLAG%%BYTECOUNT_CB%

:_END_
echo ---------- PHP代码美化 ----------
ENDLOCAL
