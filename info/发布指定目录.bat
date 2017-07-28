@echo off

echo.
echo 将指定目录拖进批处理窗口,如: 大厅定位到client/client目录, 游戏定位到game/qipai/land目录
echo.

set /p SRC=目录:
if not exist "%SRC%" (
	echo 请输入合法的目录!
	pause.
	exit
)
rem 获取当前目录名
set curdir=""
for %%i in ("%SRC%") do (
	set curdir=%%~ni
)
set h=%time:~0,2%
set h=%h: =0%
set folder=..\client_publish\%date:~0,4%-%date:~5,2%-%date:~8,2%-%h%%time:~3,2%\%curdir%
if not exist "%folder%" (
	mkdir %folder%
)
rem 编译lua代码
echo 编译lua代码
call  cocos luacompile -s %SRC% -d %folder% -e -k RY_QP_MBCLIENT_!2016 -b RY_QP_2016 --disable-compile
if  errorlevel 1 goto CipherSrcError
if  errorlevel 0 goto MakeMD5
pause
exit

:CipherSrcError
echo 编译lua错误!
pause
exit

:MakeMD5
echo 生成MD5更新文件
md ..\client\ciphercode\game
xcopy /y /e /exclude:uncopy.txt %SRC% %folder%
MakeMD5List -dst %temp% -src %folder%
copy %temp%\filemd5List.json %folder%\res\filemd5List.json
del %temp%\filemd5List.json

echo 更新文件已复制到%folder%目录
pause