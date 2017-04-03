@echo off
set CC=C:\borland\bcc55
set HB=C:\develop\harbour\hb30

set oldpath=%path%
path=%path%;%cc%\bin;%hb%\bin
set include=%cc%\include
set lib=%cc%\lib;%HB%\lib\win\bcc

set HB_ARCHITECTURE=w32
set HB_COMPILER=bcc
set HB_GT_LIB=gtwvg

hbmk2 -oassets *.prg gtwvg.hbc hbtip.hbc xhb.hbc hbct.hbc

set path=%oldpath%
set include=
set lib=
