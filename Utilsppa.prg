/*

 Rentals - Bluegum Software

 Module Utilsppa - System Parameters

 Last change:  APG  15 Jun 2004    3:46 pm

      Last change:  TG   14 Mar 2011    2:49 pm
*/

#include "assets.ch"

procedure UtilSPPA

local getlist := {}
local aGlobalVars := bvarget()    // this will return an array of all globalVars
// local mcon_no := Sysinc( 'con_no' )
local aLocalVars := lvarget()  
local oKF2, oKF9

cls
Heading( 'Setup System data' )

@ 02,05 say '  Company Name' get aGlobalVars[ B_COMPANY ]
@ 04,05 say 'Address line 1' get aGlobalVars[ B_ADDRESS1 ] 
@ 05,05 say 'Address line 2' get aGlobalVars[ B_ADDRESS2 ] 
@ 06,05 say '   City/suburb' get aGlobalVars[ B_SUBURB ]
@ 07,05 say '      Postcode' get aGlobalVars[ B_PCODE ] pict '9999'
@ 08,05 say '      Phone no' get aGlobalVars[ B_PHONE ] pict '(999)9999-9999'

@ 11,05 say '  Month for end of year' get aGlobalVars[ B_EOY ] pict '99' ;
       valid( mglobalVars[ B_EOY ] $ '01|02|03|04|05|06|07|08|09|10|11|12')
@ 11,35 say "'06' for June,'03' for March etc"
// @ 12,05 say 'Assets Fiscal Year End' get aGlobalVars[ B_FAFISCALY ]
@ 13,05 say 'Default owner' get aGlobalVars[ B_DEF_OWNER ] pict '!!!'
@ 14,04 say 'Report Printer' get aLocalVars[ L_REPORT_NAME ] pict 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
@ 15,03 say 'Barcode Printer' get aLocalVars[ L_BARCODE_NAME ] pict 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
@ 16,10 say 'Use the Windows Printer Name! - UNC is OK too. !Case Sensitive'
@ 22,01 say 'Editor Program' get aGlobalVars[ B_EDITOR ]

okF2 := setkey( K_F2, { || SysData() } )
// okF9 := setkey( K_F9, { || SMTP() } )

read

setkey( K_F2, okF2 )

// setkey( K_F9, okF9 )

globalVarsave()
Lvarsave()

Print_find( 'report' )

// Sysinc( 'CON_NO', 'R', mcon_no )

return

*

proc sd_set
local getlist:={}
local mdate := globalVars( B_SYSDATE )
local nGSTRate := globalVars( B_GSTRATE )
local mscr := Box_Save( 2, 25, 5, 56 )
@ 3,27 say 'System Date' get mdate
@ 4,27 say '   GST Rate' get nGSTRate pict '99.99'
read
globalVars( B_SYSDATE, mdate )
globalVars( B_GSTRATE, nGSTRate )
globalVarsave()
Oddvars( SYSDATE, globalVars( B_SYSDATE ) )
Box_Restore( mscr )
return

*

Procedure Sysdata
local oWindow

// nCurWindow := WVW_nOpenWindow(cWinName, nTop, nLeft, nBottom, nRight)
   

 oWindow := WvW_nOpenWindow( "System Information",0, 0, 06, 60 )
 WvW_SBCreate( oWindow )
 WvW_SBSetText( oWindow, 0 , "System Info" )
 // wvw_SetFont("Arial",17,10)
//      :SetTitle( "Editar Datos del Equipo" )
//      :SetStatusBar( "WvwGetsys Demo!" )
//      :SetFont( "Courier New" )
//      :Create()
   
//local cScr := Box_Save( 2, 05, 10, 76 )
Highlight( 00, 00, 'OS', os() )
Highlight( 01, 00, 'RDD', rddsetdefault() )
Highlight( 02, 00, 'Index Ext', ordbagext() )
Highlight( 03, 00, 'Compiler', version() )
Highlight( 04, 00, 'Free Pool', Ns( memory(0) ) )
Highlight( 05, 00, SYSNAME + ' Build Ver', BUILD_NO )
Highlight( 06, 00, 'Node', LVars( L_NODE ) )

//   :Activate( .T., .T. ) // Instead of READ CYCLE
//      :Close()
   
inkey(0)

//
   WVW_lCloseWindow()
//Box_Restore( cScr )
return

*

PROCEDURE SMTP
      LOCAL oSmtp, oEMail
      LOCAL cSmtpUrl
      LOCAL cSubject, cFrom, cTo, cBody, cFile
 /*
Set objEmail = CreateObject("CDO.Message")
objEmail.From = "admin1@fabrikam.com"
objEmail.To = "tony@bluegumsoftware.com"
objEmail.Subject = "Server down" 
objEmail.Textbody = "Server1 is no longer accessible over the network."
objEmail.Configuration.Fields.Item("http://schemas.microsoft.com/cdo/configuration/sendusing") = 2
objEmail.Configuration.Fields.Item("http://schemas.microsoft.com/cdo/configuration/smtpserver") = _
        "mail.tpg.com.au" 
objEmail.Configuration.Fields.Item("http://schemas.microsoft.com/cdo/configuration/smtpserverport") = 25
objEmail.Configuration.Fields.Update
objEmail.Send
 */
      // preparing data for eMail
      cSmtpUrl := "smtp://@mail.tpg.com.au"
      cSubject := "Testing eMail"
      cFrom    := "WinRent Testing"
      cTo      := "tony@bluegumsoftware.com"
      cFile    := "File_Attachment.zip"
      cBody    := "This is a test mail sent at: " + DtoC(date()) + " " + Time()

      // preparing eMail object
      oEMail   := TIpMail():new()
      oEMail:setHeader( cSubject, cFrom, cTo )
      oEMail:setBody( cBody )
     // oEMail:attachFile( cFile )

      // preparing SMTP object
      oSmtp := TIpClientSmtp():new( cSmtpUrl, TRUE )

      // sending data via internet connection
      IF oSmtp:open()
//         oSmtp:sendMail( oEMail )
         oSmtp:close()
         error( "Mail sent" )
     ELSE
         @ 10,0 clear to maxrow(), maxcol()
         ? "Error ",  oSmtp:lastErrorMessage()
      ENDIF
   RETURN


