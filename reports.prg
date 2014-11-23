/*

 Asset system - Bluegum Software
 Module Reports - Asset reports
 17/12/86 T. Glynn


      Last change:  TG   14 Mar 2011    2:16 pm
*/

#include "assets.ch"

static page_no
static mrow

Procedure AssetPrint

local nMenuChoice, oldscr := Box_Save()
local aArray
local aflds
local lOK
local sGroupBy
local sGroupHead
local sHeadType

if NetUse( "stkhist" )
 if NetUse( "location" )
  if NetUse( "owner" )
   if NetUse( "assets" )
    assets->( ordsetfocus( 'code' ) )
    set relation to assets->ownerId into owner,;
                 to assets->code into location,;
                 to assets->prod_code into stkhist
    lOk := TRUE
   endif
  endif
 endif
endif

while lOK

 Box_Restore( oldscr )

 Heading('Assets Print Menu')

 aArray := {}
 aadd( aArray, { 'Exit', 'Return to Reports menu' } )
 aadd( aArray, { 'Assets by ID', 'List of all assets by ID' } )
 aadd( aArray, { 'Assets by description', 'List of all assets sorted by Description' } )
 aadd( aArray, { 'Assets by Location', 'List of all assets sorted by location' } )
 aadd( aArray, { 'Owners', 'List of owners' } )
 aadd( aArray, { 'Location', 'Listing of locations' } )
 nMenuChoice := MenuGen( aArray, 01, 24, 'Reports' )

 do case
 case nMenuChoice < 2
  exit
 
 case nMenuChoice >= 1 .and. nMenuChoice < 5
  sGroupBy = ""
  sGroupHead = ""
  sHeadType = "by Code"

  do case
  case nMenuChoice = 2
   assets->( ordSetFocus( 'code' ) )
  case nMenuChoice = 3
   assets->( ordSetFocus( 'desc' ) )
   sHeadtype = "by Description"
  case nMenuChoice = 4
   assets->( ordSetFocus( 'location' ) )
   sGroupBy = "location"
   sGroupHead = "Location"
   sHeadType = "by Location "

  endcase

  select assets
  assets->( dbgotop() )
  
  aFlds := {}
  aadd( aflds, { 'assets->code', 'Asset ID', 9, 0, FALSE } )
  aadd( aflds, RPT_SPACE )
  aadd( aflds, { 'assets->desc', 'Description', 20, 0, FALSE } )
  aadd( aflds, { 'assets->serial', 'Serial No', 20, 0, FALSE } )
  aadd( aflds, { 'assets->model', 'Model', 30, 0, FALSE } )
  aadd( aflds, { 'assets->location', 'Location', 9, 0, FALSE } )
  aadd( aflds, { 'assets->cost', 'Cost', 8, 2, FALSE } )
  
  Reporter( aFlds, ;                                 // Array
			'Asset Listing ' + sHeadType ,;               // Report Name
            sGroupBy 	,;                            // Group By
            sGroupHead	,;                            // Group Heading
            '' ,;                                     // Sub Group By
            '',;                                      // Sub Group head
            FALSE,;                                   // Summary
            '' ,;                                     // For Condition
			'' ,;									  // While Condition
            132 ;
          )


 case nMenuChoice = 5
  select owner
  owner->( dbgotop() )
  
  aFlds := {}
  aadd( aflds, { 'owner->code', 'Owner;Code', 9, 0, FALSE } )
  aadd( aflds, RPT_SPACE )
  aadd( aflds, { 'owner->name', 'Name', 25, 0, FALSE } )
  aadd( aflds, { 'owner->add1', 'Address 1', 20, 0, FALSE } )
  aadd( aflds, { 'owner->add2', 'Address 2', 30, 0, FALSE } )
  aadd( aflds, { 'owner->phone', 'Phone', 10, 0, FALSE } )
  aadd( aflds, { 'owner->contact', 'Contact', 20, 0, FALSE } )
  
  Reporter( aFlds, ;                         // Array
			'Assets Listing of Owners' ,;    // Report Name
            '' ,;                            // Group By
            '' ,;                            // Group Heading
            '' ,;                            // Sub Group By
            '' ,;                            // Sub Group head
            FALSE,;                          // Summary
            '' ,;                            // For Condition
			'' ,;							 // While Condition
            132 ;
          )

 case nMenuChoice = 6
  select location
  location->( dbgotop() )
  
  aFlds := {}
  aadd( aflds, { 'location->code', 'Code', 9, 0, FALSE } )
  aadd( aflds, RPT_SPACE )
  aadd( aflds, { 'location->name', 'Name', 40, 0, FALSE } )
  
  Reporter( aFlds, ;                         // Array
			'Assets Listing of Locations' ,;    // Report Name
            '' ,;                            // Group By
            '' ,;                            // Group Heading
            '' ,;                            // Sub Group By
            '' ,;                            // Sub Group head
            FALSE,;                          // Summary
            '' ,;                            // For Condition
			'' ,;							 // While Condition
            132 ;
          )


 endcase

enddo

dbcloseall()

return

