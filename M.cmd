@echo off

rem for Multi thread support, un-remark next line
set HB_MT=MT

rem nmake
call m_bcc.cmd
if not exist assets.exe goto noexe
goto end
:noexe 
echo No executable generated
:end


