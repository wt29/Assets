/*

 Assets - basic asset stocktake
 Module Main - Startup and Menu File

      Last change:  TG   14 Feb 2012   10:07 pm
*/

#include "assets.ch"
#include "set.ch"

Procedure Main()

local nMenuChoice
local mlen,getlist:={}
local nMMchoice
local aMenu
local aMenuScr
local okaf1
local nSelRow
local getdefprt := GetDefaultPrinter()
local aBox
local sNoColor
local sFile

#ifndef NOAUDIT
local oPrinter
#endif

local lMainCoord := WVW_SetMainCoord( .t. )
WVW_SetCodePage(,255)
WVW_SetFont( , "Lucida Console", 28, -12 )
        
parameter sCmdParams

set scoreboard off
set deleted on
set confirm on 
set date british
set epoch to 1990
set wrap on
set exclusive off

#ifdef SQL
REQUEST SQLRDD             // SQLRDD should be linked in
REQUEST SR_ODBC            // Needed if you plan to connect with ODBC
rddsetdefault( "SQLRDD" )
cConnString := "dsn=rentals;uid=sa;pwd=saadmin"
nCnn := SR_AddConnection( CONNECT_ODBC, cConnString )

#else
request DBFCDX
rddsetdefault( "DBFCDX" )

#endif
set( _SET_EVENTMASK, INKEY_ALL )
set( _SET_DEBUG, .t. )
set( _SET_AUTOPEN, TRUE )
set( _SET_AUTORDER, TRUE )

if type( "sCmdParams" ) != 'U'
 if right( trim( m->sCmdParams ), 1 ) != '\'
   m->sCmdParams += '\'

 endif

else
m->sCmdParams = ''

endif

Oddvars( SYSPATH, m->sCmdParams )

set path to ( Oddvars( SYSPATH ) )

Setupdirs()

if len( directory( Oddvars( SYSPATH ) + '*.dbf' ) ) = 0
 SetupDbfs()         // a completely new program and exit after creation

endif 

// Oddvars are temporary local variables
Oddvars( ENQ_STATUS, TRUE )
Oddvars( IS_SPOOLING, FALSE )
Oddvars( TRAN_AUDIT, FALSE )
Oddvars( TEMPFILE, '_' + padl( SysInc( 'fileno', 'I', 1 ), 7 ,'0' ) )  // Unique file name
Oddvars( OPERNAME, 'XX' )

LVarGet()
BVarGet( TRUE )

globalVarSave()

sFile := Oddvars( SYSPATH ) + 'assets' + ordbagext()
if !file( sFile )
 Utilpack( TRUE )

endif

cls
mlen := max( 15, ( 20 + len( trim( globalVars( B_COMPANY ) ) ) ) / 2 )

Heading('*** Welcome to ' + SYSNAME + ' ***')
aBox := Box_Save( 06, 38-mlen, 12, 41+mlen, C_CYAN )
Center( 07, 'Copyright Bluegum Software' )
Center( 08, SUPPORT_PHONE )
Center( 09, 'Licensed to -=< ' + trim( globalVars( B_COMPANY ) ) + ' >=-' )
Center( 10, 'Build Version V' + BUILD_NO )
// Center( 11, 'Current System Date is ' + dtoc( Oddvars( SYSDATE ) ) )


#ifdef SECURITY
Login( FALSE )    // Not allowed to add an operator here

#else
Oddvars( OPERCODE, '' )
Error( "", 21 )

#endif

#ifdef EVALUATION
if globalVars( B_SYSDATE ) >= ctod( EVALEXP )
 Error( 'Evaluation Period Expired', 12, , 'Contact Bluegum Software ' + BLUEGUM_PHONE )
 cls
 quit
endif

#endif

// altd(1)

setkey( K_SH_F1, { || Print_swap() } )
// setkey( K_F2, { || StuffLastItem() } )
// setkey( K_F3, { || StuffLastCont() } )
setkey( K_F5, { || Free_enq() } )
// setkey( K_F6, { || Calendar() } )
setkey( K_CTRL_F5, { || ShowCallStack() } )
setkey( K_CTRL_P, { || Print_screen() } )
setkey( K_F12, { || Print_screen() } )   // This key works better in Windows than PrintScreen

#ifdef SECURITY
setkey( K_ALT_L, { || Login( TRUE ) } )   // Allow an Operator Add

#endif

Oddvars( LASTITEM, '0' )  // Init this item otherwise it crashes - it expects a char
Oddvars( LASTCONT, '0' )

box_restore( aBox )

sNoColor := SysColor( C_NORMAL )

// Print_find( 'report' )   // Set up the default printer

while TRUE

 Syscolor( sNoColor )
 // @ 0, 0, 24, 79 box replicate( chr( 176 ), 9 )

 @ 0,0 clear to maxrow(), maxcol()
 Syscolor( C_NORMAL )

 Bvarget( TRUE ) // Refresh the globalVars Array in case another terminal has update EOD etc

 Oddvars( ENQ_STATUS, TRUE )
 // Oddvars( SYSDATE, globalVars( B_SYSDATE ) )

 Heading( 'Main Menu' )
 set message to 24 center

 Box_Save( 02, 00, 4, 79 )

 nMMChoice := 1
 @ 03, 01 prompt ' Enquiry ' message line_clear( 24 ) + 'Enquiries on Assets'
 @ 03, 12 prompt '  File   ' message line_clear( 24 ) + 'Maintain your Asset File'
 @ 03, 36 prompt 'Stocktake' message line_clear( 24 ) + 'Do an Asset Stocktake'
 @ 03, 60 prompt 'Utilities' message line_clear( 24 ) + 'Housekeeping'
 @ 03, 71 prompt '  Quit  ' message line_clear( 24 ) + 'Exit from ' + SYSNAME
 menu to nMMChoice
 line_clear( 24 )
 aMenuScr := Box_Save()

 while TRUE

  Box_Restore( aMenuScr )

  do case
  case nMMChoice = 1 .and. Secure( X_ENQUIRE )
   Heading( 'Enquiry menu' )
   aMenu := {}
   aadd( aMenu, { 'Exit', 'Return to main menu' } )
   aadd( aMenu, { 'Asset #', 'EnquireContract enquiries', { || EnqCont() } } )
   aadd( aMenu, { 'Location', 'Hire stock enquiry', { || EnqItems() } } )
   aadd( aMenu, { 'Owner', 'Owner file enquiry', { || EnqOwner() } } )
   nMenuChoice := MenuGen( aMenu, 01, 01, 'Enquire' )

   if nMenuChoice < 2
    exit

   else
    Eval( aMenu[ nMenuChoice, 3 ] )

   endif

  case nMMChoice = 2 .and. Secure( X_FILE )
   Heading('File Maintenance')
   aMenu := {}
   aadd( aMenu, { 'Main', 'Return to top line options' } )
   aadd( aMenu, { 'Assets', 'Contract file maintenance', { || MainAsset() } } )
   aadd( aMenu, { 'Owner', 'Modify owner details', { || MainOwne() } } )
   nMenuChoice := MenuGen( aMenu, 1, 12, 'File', , , ,@nSelRow )

   if nMenuChoice < 2
    exit

   else
    Eval( aMenu[ nMenuChoice, 3 ] )

   endif
  case nMMChoice = 3 .and. Secure( X_STOCKTAKE )
   UtilStock()
  case nMMChoice = 4 .and. Secure( X_UTILITY )
   Heading('Utility Menu')
   aMenu := {}
   aadd( aMenu, { 'Main', 'Return to top line options' } )
   aadd( aMenu, { 'Details', 'Change user details', { || Utilsppa() } } )
   aadd( aMenu, { 'Pack', 'File tidy up procedure', { || Utilpack() } } )
   aadd( aMenu, { 'Index', 'Rebuild Indexes', { || Utilpack( ,TRUE ) } } )
   aadd( aMenu, { 'Barcodes', 'Print Barcodes', { || CodePrint() } } )

   okaf1 := setkey( K_ALT_F1, { || MaintLaunch() } )

   nMenuChoice := Menugen( aMenu, 1, 58, 'Utilities' )

   setkey( K_ALT_F1, okaf1 )

   if nMenuChoice < 2
    exit

   else
    Eval( aMenu[ nMenuChoice, 3 ] )

   endif

  case nMMChoice = 5 .or. nMMChoice = 0
   Appquit( )
   exit

  otherwise

   exit

  endcase

 enddo

enddo

return

*

function MaintLaunch
local aMenu:={}, nMenuChoice, mscr := Box_Save()
aadd( aMenu, { ' Audit Browse', 'Browse the Audit trail', { || BrowSystem() } } )
aadd( aMenu, { 'Check local file structures', 'Ensure field lengths etc are OK', { || Check_new_dbf() } } )
// aadd( aMenu, { 'Check Email Functionality', 'Send a test email', { || SMTP_Send( TRUE ) } } )
aadd( aMenu, { 'Update file schema', 'Update all files to latest schema', { || FixSchema( ) } } )

nMenuChoice := MenuGen( aMenu, 10, 30, 'Maint Functs' )

if nMenuChoice # 0
 eval( aMenu[ nMenuChoice, 3 ] )

endif

Box_Restore( mscr )

return nil

*

function ResetSkey
if NetUse( 'hirer' )
 if NetUse( 'master' )
  set relation to master->con_no into hirer
  if Isready( )
   Box_Save( 3, 10, 6, 50 )
   Highlight( 4, 12, '  Records to Process', Ns( master->( lastrec() ) ) )
   while !master->( eof() )
    Rec_lock( 'master' )
    master->skey := upper( hirer->surname )
    master->( dbrunlock() )
    master->( dbskip() )
    Highlight( 5, 12, 'Record processed', Ns( master->( recno() ) ) )

   enddo
   Error( 'Procedure Finished', 12 )

  endif

 endif

endif
dbcloseall()
return nil

*

function AppQuit
Heading( 'System Exit' )
if Isready( 'Ok to quit ' + SYSNAME )
 commit
 dbcloseall()
 aeval( directory( '_*.*' ), { | del_element | ferase( del_element[ 1 ] ) } )
 aeval( directory( '*.bak' ), { | del_element | ferase( del_element[ 1 ] ) } )
 aeval( directory( '*' + TEMP_EXT ), { | del_element | ferase( del_element[ 1 ] ) } )

 quit

endif

return nil

