REM ::注意：====>所有参数必须在同一行。否则会报错。

@echo off
::运行游戏模拟器调试游戏
start run\debug\win32\GloryProject.exe -workdir %~dp0\client -resolution 960x640 -write-debug-log e:\log

REM -entry src\main.lua -search-path src;res 

REM 横屏
REM -landscape -resolution 640x360

REM 表示 放缩因子 1
:: -scale 1

::表示log输出目录
REM ::-write-debug-log 

REM 表示 是否显示控制台 enable 表示显示，其他表示不显示。
::-console 

REM 表示窗口显示的位置:x, y
::-position

REM 表示调试模式：codeide=代码编辑工具调试，studio=cocostudio调试
::-debugger 

REM 表示显示菜单，不写表示不显示
::-app-menu 

REM 表示重新改变大小
::-resize-window 

REM 显示模式
::-retina-display 

REM 绑定监听地址 参数值位地址
::-listen 

