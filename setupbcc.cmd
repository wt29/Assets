@echo off
set CC=C:\borland\bcc55
set HB=C:\develop\harbour-core

set oldpath=%path%
path=%path%;%cc%\bin;%hb%\bin\win\bcc
set include=%cc%\include
set lib=%cc%\lib;%HB%\lib\win\bcc

set HB_ARCHITECTURE=w32
set HB_COMPILER=bcc
set HB_GT_LIB=gtwvw

hbmk2 -oassets *.prg gtwvw.hbc hbtip.hbc xhb.hbc hbct.hbc

set path=%oldpath%
set include=
set lib=



