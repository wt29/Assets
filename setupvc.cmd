@echo off
set CC=C:\borland\bcc55
set HB=C:\develop\xharbour\1.20
rem set HB=C:\hb30

set oldpath=%path%
path=%path%;%cc%\bin;c:\minigui\harbour\bin
set include=%cc%\include
set lib=%cc%\lib;%HB%\lib

set HB_ARCHITECTURE=w32
set HB_COMPILER=bcc
set HB_GT_LIB=gtwvw


