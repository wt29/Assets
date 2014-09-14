* Asset_scan - Bluegum Software
* Module UtilStock - Stocktake Module
* 28/10/86 T. Glynn 11:03:03  9/23/1987
**************************************

#include "assets.ch"

Procedure UtilStock

local level1 := Box_Save()
local choice
local printchoice
local getlist := {}
local aFlds
local sLoc, sID

if !NetUse( 'assets' )
 return
endif

while TRUE
 Box_Restore( level1 )
 Heading('Assets Stocktake System')
 Choice = 1
 Box_Save(01,33,06,45)
 @ 02,34 prompt 'Exit      ' message Line_clear(24)+'Return to Main Menu'
 @ 03,34 prompt ' Prepare  ' message Line_clear(24)+'Prepare the asset file for Stocktaking'
 @ 04,34 prompt ' Stocktake' message Line_clear(24)+'Do the stocktake'
 @ 05,34 prompt ' Reports  ' message Line_clear(24)+'Shrinkage etc reports'
 @ 01,34 say 'Stocktake'
 menu to choice
 do case
 case choice = 2
  Box_Save(03,03,09,75)
  Center(04,'This module will prepare the asset file for the stocktake.')
  Center(05,'It clears the stocktake found flag and last stocktake location.')
  Center(07,'It is a mandatory step in the stocktaking process.')
  Heading('Stocktake Preparation')
  if Isready()
   Box_Save(09,19,11,58)
   @ 10,20 say 'Processing in progress - Please wait'
   assets->( dbgotop() )
   while !assets->( eof() )
    Rec_lock()
    assets->prevLoc := assets->Location
    assets->stoctake := FALSE
    assets->( dbrunlock() )
    assets->( dbskip() )
   enddo
  endif

 case choice = 3
  Heading('Stocktake Entry')
  if Isready( 10, 12, "Have you prepared the stocktake first" )
   Box_Save( 2, 08, 6, 72 )
   @ 5,10 say 'Asset Description                 Location'
   sloc := ""
   while TRUE
 	sID := space(10)
    @ 03,10 say 'Scan/Enter asset ID or location' get sID pict '@!'
    read
    if !updated() 
     exit

    else
	 if location->( dbseek( sID ) )
	  sLoc = sID
	  warning( "Location set to " + trim( location->desc ) )
	  loop
      
	 endif	   
	  
	 if sLoc = ""
	  Warning( "Scan/Enter a valid location before commencing asset scans" )
	
	 else 
	  if !asset->( dbseek( sID ) )
	   Error( 'Asset ID not found', 12, .5 )
	   tone( lvars( L_BAD ), 5 )

	  else
	   tone( lvars( L_GOOD ), 5 )
       Rec_lock( 'assets' )
       assets->location = sLoc
       assets->stocktake = TRUE

      endif
     endif

     scroll( 6, 9, 15, 70, -1 )
     line_clear( 6 )
     @ 6,09 say left( asset->desc, 30 )
     @ 6,45 say left( location->desc, 20 )

	endif
   enddo
  endif

 case choice = 4
  Heading('Stocktake Report Menu')
  Printchoice = 1
  Box_Save( 05, 34, 10, 46 )
  @ 06,35 prompt 'Exit      ' message Line_clear(24)+'Return to Stocktake Menu'
  @ 07,35 prompt ' All assets' message Line_clear(24)+'All assets in Stocktake'
  @ 08,35 prompt '  Not found' message Line_clear(24)+'assets Not found in Location'
  @ 09,35 prompt '  Incorrect' message Line_clear(24)+'assets in Incorrect Location'
  @ 05,35 say 'Reports'
  menu to printchoice

  assets->( dbgotop() )

  do case
  case printchoice = 2
   Heading("Print all Assets found during Stocktake by Location")
   if Isready()
    Box_Save( 12, 20, 14, 60 )
    assets->( ordsetFocus( 'location' ) )
    @ 13,21 say '-=< Processing - Please Wait >=-'

    aFlds := {}
    aadd( aflds, { 'assets->code', 'Item;Code', ASSET_CODE_LEN, 0, FALSE } )
    aadd( aflds, { 'assets->serial', 'Serial No', 10, 0, FALSE } )
    aadd( aflds, { 'assets->desc', 'Description', 20, 0, FALSE } )

    Reporter( aFlds, ;
            'Complete List Stocktake assets',;
            'location',;
            '',;
            '',;
            '',;
            FALSE,;
            '',;
            'assets->stocktake',;
              132 ;
            )


   endif

  case printchoice = 3
   Heading("Print assets not found Report")
   if Isready()
    Box_Save( 12, 20, 14, 60 )
    @ 13,21 say '-=< Processing - Please Wait >=-'

	aFlds := {}
    aadd( aflds, { 'assets->code', 'Asset;Code', 10, 0, FALSE } )
    aadd( aflds, { 'assets->serial', 'Serial No', 10, 0, FALSE } )
    aadd( aflds, { 'assets->desc', 'Description', 20, 0, FALSE } )

    Reporter( aFlds, ;
              'List of assets not found in Stocktake',;
              'location',;
              '',;
              '',;
              '',;
              FALSE,;
              '',;
              '!assets->stocktake',;
              132 ;
            )


   endif

  case Printchoice = 4
   Heading('Print Incorrect assets found Report')
   if Isready(12)
    Box_Save( 12, 20, 14, 60 )
    @ 13,21 say '-=< Processing - Please Wait >=-'
    
    aFlds := {}
    aadd( aflds, { 'assets->code', 'Asset;Code', 10, 0, FALSE } )
    aadd( aflds, { 'assets->serial', 'Serial No', 10, 0, FALSE } )
    aadd( aflds, { 'assets->desc', 'Description', 20, 0, FALSE } )

    Reporter( aFlds, ;
            'List of assets found Incorrectly in Stocktake',;
            'location',;
            '',;
            '',;
            '',;
            FALSE,;
            '',;
            'assets->stocktake .and. assets->prevLoc <> assets->location',;
              132 ;
            )

 
   endif
  endcase

 case choice < 2
  exit

 endcase
enddo

dbcloseall()

return
