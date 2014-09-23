/*

 Assets System - Bluegum Software
 Module Enquire - General Enquiries

*/
 
#include "assets.ch"

Procedure EnqAsset

local mscr := Box_Save()

if NetUse( "location" )
 if NetUse( "owner" )
  if NetUse( "assets" )
   assets->( ordsetfocus( 'code' ) )
   set relation to assets->ownerId into owner,;
                to assets->code into location
   Heading( 'Enquire on Asset' )
   while AssetFind()
    AssetForm( TRUE )

   enddo 

   endif
 endif
endif

close databases
Box_Restore( mscr )

return 



Function AssetFind
local cf := Box_Save()
local got_it := FALSE
local t_flag:=FALSE
local sIdent
local getlist := {}
local oEnquire
local mkey
local sAssetCode := ""
local lByDesc 
local lBySerial 
local lByModel 

Heading('Asset Find')
while TRUE
 sIdent := space( ASSET_CODE_LEN )
 Box_Save( 4, 11, 6, 64, C_GREY )
 @ 5, 13 say 'Asset No,/Description,.Serial No,;Model' get sIdent pict '@!'
 Syscolor( C_NORMAL )
 read

 if !updated()
  exit

 else
  lByDesc := ( left( sIdent, 1 ) = '/' )
  lByModel := ( left( sIdent, 1 ) = '.' )
  lBySerial := ( left( sIdent, 1 ) = ';' )
  do case
  case lByDesc .or. lByModel .or. lBySerial // .or. ( asc( left( sIdent, 1 ) ) > 64 .and. asc( left( sIdent, 1 ) ) < 123 )
   t_flag := TRUE
   assets->( ordsetfocus( if( lByDesc, 'desc', if( lByModel, 'model', 'serial' ) ) ) )
   sIdent := upper( trim( substr( sIdent, 2, len( sIdent ) - 1 ) ) )

   if !assets->( dbseek( sIdent ) )
    Error( 'No ' + if( lByDesc, 'Description', if( lByModel, 'Model', 'Serial' ) ) + ' match on file' , 12 )
    assets->( ordsetfocus( 'code' ) )
   
   else
    assets->( dbskip( 1 ) )
    if left( if( lByDesc, upper( assets->desc ), if( lByModel, upper( assets->model ), upper( assets->serial ) ) ), len( sIdent ) ) != sIdent
     assets->( dbskip( -1 ) )
     sAssetCode := assets->code
     assets->( ordsetfocus( 'code' ) )

    else
     assets->( dbskip( -1 ) )
     Box_Save( 2, 01, 22, 78 )
     Heading('Asset no find')
     oEnquire:=tbrowse():new( 03, 02, 21, 77 )
     oEnquire:colorspec := if( iscolor(), TB_COLOR, setcolor() )
  
     oEnquire:HeadSep := HEADSEP
     oEnquire:ColSep := COLSEP
     oEnquire:goTopBlock := { || jumptotop( sIdent ) }
     oEnquire:goBottomBlock := { || jumptobott( sIdent, 'asset' ) }
     
	 oEnquire:skipBlock := { | SkipCnt | AwSkipIt( SkipCnt, ;
	                         { || upper( left( if( lByDesc, assets->desc, ;
	                         if( lByModel, assets->model, assets->serial ) ), ;
							 len( sIdent ) ) ) }, sIdent ) }
     
	 oEnquire:addColumn( tbcolumnnew( 'Asset', { || assets->code } ) )
     oEnquire:addcolumn( tbcolumnNew( 'Description', { || substr( assets->desc, 1, 15 ) } ) )
     oEnquire:addcolumn( tbcolumnNew( 'Model', { || substr( assets->model, 1, 12 ) } ) )
     oEnquire:addcolumn( tbcolumnNew( 'Serial', { || substr( assets->serial, 1, 10 ) } ) )
     oEnquire:addcolumn( tbcolumnNew( 'Location', { || substr( lookitup( 'location', assets->location ), 1, 10 ) } ) )
     oEnquire:addcolumn( tbcolumnNew( 'Status', { || assets->status } ) )
     oEnquire:freeze := 3
     mkey := 0
     while mkey != K_ESC
      oEnquire:forcestable()
      mkey := inkey(0)

      if !Navigate( oEnquire, mkey )
       if mkey = K_ENTER .or. mkey == K_LDBLCLK
        sAssetCode := assets->code
        assets->( ordsetfocus( 'code' ) )
        exit

       endif
      endif
     enddo
    endif
   endif
  otherwise
   sAssetCode := sIdent

  endcase

 endif

 select assets
 if lastkey() != K_ESC
  assets->( ordsetfocus( 'code' ) )
  if !assets->( dbseek( sAssetCode ) )
   Error( 'Asset #' + trim( sAssetCode ) + ' not found', 12 )

  else
   got_it := TRUE
   exit

  endif
 endif
enddo

Box_Restore( cf )

return got_it

*
