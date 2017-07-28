@echo off

echo.
echo AppDf.lua �ļ��е� appdf.BASE_C_VERSION ֵ��Ҫ���������µĴ����汾��һ��
echo.
pause

if not exist "..\client_publish" (
	mkdir ..\client_publish
)
rem del /s /q ..\client_publish\LuaMBClient_LY.apk

call GloryProjectR.bat

set h=%time:~0,2%
set h=%h: =0%
set folder=%date:~0,4%-%date:~5,2%-%date:~8,2%-%h%%time:~3,2%
if not exist "..\client_publish\%folder%" (
	mkdir ..\client_publish\%folder%
)

if not exist "..\client_publish\%folder%\base" (
	mkdir ..\client_publish\%folder%\base
)

if not exist "..\client_publish\%folder%\command" (
	mkdir ..\client_publish\%folder%\command
)

if not exist "..\client_publish\%folder%\client" (
	mkdir ..\client_publish\%folder%\client
)

if not exist "..\client_publish\%folder%\game" (
	mkdir ..\client_publish\%folder%\game
)

xcopy /y /e ..\client\ciphercode\base ..\client_publish\%folder%\base
xcopy /y /e ..\client\ciphercode\command ..\client_publish\%folder%\command
xcopy /y /e ..\client\ciphercode\client ..\client_publish\%folder%\client
xcopy /y /e ..\client\ciphercode\game ..\client_publish\%folder%\game
copy ..\run\release\android\GloryProject-release-signed.apk ..\client_publish\%folder%\LuaMBClient_LY.apk

pause