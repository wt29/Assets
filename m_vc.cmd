@echo off
set VC=C:\Program Files (x86)\Microsoft Visual Studio 9.0
set HB=C:\develop\xharbour\1.20
rem set HB=C:\hb30

set oldpath=%path%
path=%vc%\vc\bin;%vc%\Common7\ide;C:\Program Files\Microsoft SDKs\Windows\v6.0A\bin;%HB%\bin
set include=%vc%\vc\include;C:\Program Files\Microsoft SDKs\Windows\v6.0A\include
set lib=%vc%\vc\lib;C:\Program Files\Microsoft SDKs\Windows\v6.0A\lib;%HB%\lib;%HB%\lib\win\msvc

set HB_ARCHITECTURE=w32
set HB_COMPILER=msvc
set HB_GT_LIB=gtwvw

copy makefile.vc makefile /y
rem copy harbour_makefile.vc makefile /y

rc winrent.rc

nmake

path=%oldpath%
set %oldpath%=

