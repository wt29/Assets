/*

  Rentals - Bluegum Software

  Module Utilpack - Pack Files
  
  Last change:  TG   26 Jan 2012    7:34 pm
*/

#include "assets.ch"

Function Utilpack ( goforit, must_index )

local start_time, finish_time, getlist:={}, elapsed, packindx := 'Pack'

default goforit to FALSE
default must_index to FALSE

packindx := if( must_index, 'Index', 'Pack' )

Heading( packindx + ' Files' )

if goforit .or. Isready( )
 
 dbcloseall()

 if must_index
  aeval( directory( '*.' + ordbagext() ), { | del_element | ferase( del_element[ 1 ] ) } )
 endif

 start_time=seconds()

 cls
 Heading( 'File ' + packindx + 'ing in Progress' )
 @ 1, 0 say ''
 
 if NetUse( "assets", EXCLUSIVE, 10 )
  PackStat( packindx, 'Assets file')

  if !file( Oddvars( SYSPATH ) + 'assets' + indexext() ) .or. must_index
   indx( 'code', 'code' )
   indx( 'upper( desc )', 'desc' )
   indx( 'upper( serial )', 'serial' )
   indx( 'upper( model )', 'model' )
   indx( 'location', 'location' )

  else
   pack

  endif

 endif

 if NetUse( "owner", EXCLUSIVE, 10 )
  PackStat( packindx, 'Owner file' )

  if !file( Oddvars( SYSPATH ) + 'owner' + indexext() ) .or. must_index
   indx( 'code', 'code' )

  else
   pack

  endif
 endif

 if NetUse( "prodcode", EXCLUSIVE, 10 )
  PackStat( packindx, 'Product Code file' )

  if !file( Oddvars( SYSPATH ) + 'prodcode' + indexext() ) .or. must_index
   indx( 'code', 'code' )

  else
   pack

  endif
 endif

 if NetUse( "operator", EXCLUSIVE, 10 )
  PackStat( packindx, 'Operator file' )

  if !file( Oddvars( SYSPATH ) + 'operator' + indexext() ) .or. must_index
   indx( 'code', 'code' )

  else
   pack

  endif 

 endif
 
 if NetUse( "status", EXCLUSIVE, 10 )
  PackStat( packindx, 'Status file' )

  if !file( Oddvars( SYSPATH ) + 'status' + indexext() ) .or. must_index
   indx( 'code', 'code' )

  else
   pack

  endif 

 endif

 if NetUse( "location", EXCLUSIVE, 10 )
  PackStat( packindx, 'Location file' )

  if !file( Oddvars( SYSPATH ) + 'location' + indexext() ) .or. must_index
   indx( 'code', 'code' )

  else
   pack

  endif 

 endif

 dbcloseall()

 finish_time := seconds()  
 if finish_time < start_time
  elapsed := ( 86399-finish_time ) + start_time

 else
  elapsed := finish_time-start_time

 endif
 ?
 ? "Time for " + packindx + " = " +  if( elapsed > 60 , str( elapsed / 60, 2 ) + " minutes ", "" ) + ;
       str( elapsed % 60, 2 )  + " seconds"

 Error("")

endif

return nil

*

function indx ( mindexkey, mtag, cAlias, lIsUnique )

default lIsUnique to FALSE
default cAlias to alias()
Ordcreate( oddvars( SYSPATH ) + cAlias, mtag, mindexkey, { || &mindexkey }, lIsUnique )

return nil

*

Function PackStat ( cType, cDesc )
? cType + Padr( 'ing ' + cDesc, 25 ) + str( reccount() ) + ' records'
return nil

