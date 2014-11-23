VERSION=BCB.01
CC_DIR = C:\Program Files\Microsoft Visual Studio 9.0\VC
HB_DIR = c:\develop\xharbour\1.20
#HB_DIR = c:\hb30
 
RECURSE= NO 
COMPRESS = NO
EXTERNALLIB = NO
XFWH = NO
FILESTOADD =  5
WARNINGLEVEL =  0
USERDEFINE = 
USERINCLUDE = 
USERLIBS = 
EDITOR = edit
GTWVW = YES
GUI = NO
MT = NO
SRC09 = 
CF = CFiles

PROJECT = assets.exe $(PR)

PRGFILES = assets.prg Enquire.prg MainAsset.prg Mainowne.prg Proclib.prg Setupdbf.prg Utilpack.prg \
           Utilsppa.prg Utilstoc.prg printfunc.prg errorsys.prg reports.prg

CFILES = assets.c Enquire.c MainAsset.c Mainowne.c Proclib.c Setupdbf.c Utilpack.c Utilsppa.c \
         Utilstoc.c printfunc.c errorsys.c  reports.c

OBJFILES = assets.obj Enquire.obj MainAsset.obj Mainowne.obj Proclib.obj Setupdbf.obj Utilpack.obj \
           utilsppa.obj utilstoc.obj printfunc.obj errorsys.obj  reports.obj

RESFILES = ASSETS.RES
RESDEPEN = 

GTLIB = gtwvw.lib

HBLIBS = lang.lib vm.lib rtl.lib rdd.lib macro.lib pp.lib dbfntx.lib dbfcdx.lib dbffpt.lib \
         pcrepos.lib common.lib codepage.lib ct.lib hbsix.lib hbzip.lib tip.lib debug.lib zlib.lib $(GTLIB)

CLIBS = user32.lib winspool.lib gdi32.lib ole32.lib oleaut32.lib ws2_32.lib comctl32.lib advapi32.lib

EXTLIBFILES =
DEFFILE = 

HARBOURFLAGS = /w2 /b /n /gc
CFLAGS = /c /W3 /MT
LFLAGS= /NODEFAULTLIB:LIBC /NODEFAULTLIB:LIBCP

LINKER = link
.SUFFIXES: .c .obj .prg 

# ALLOBJ = $(OBJFILES) $(OBJCFILES)
# ALLRES = $(RESDEPEN) $(RESFILES)
ALLLIB = $(HBLIBS) $(CLIBS)

.c.obj:
	cl -I$(HB_DIR)\include $(CFLAGS) -Fo$* $**

.prg.c:
	$(HB_DIR)\bin\harbour /D__EXPORT__ /I$(HB_DIR)\include $(HARBOURFLAGS) $**

.rc.res:
	$(CC_DIR)\rc $(RFLAGS) $<
 
# Build
assets.exe: $(PRGFILES) $(CFILES) $(OBJFILES)
	link $(OBJFILES) $(HB_DIR)\obj\vc\mainwin.obj $(ALLLIB) $(RESFILES) /out:assets.exe $(LFLAGS)
