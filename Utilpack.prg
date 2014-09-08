/*

  Rentals - Bluegum Software

  Module utilpack - Pack Files

  Last change:  TG    1 May 2008   10:50 pm

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

 
 if NetUse("assets",EXCLUSIVE,10)
  PackStat( packindx, 'Assets file')

  if !file( Oddvars( SYSPATH ) + 'items' + indexext() ) .or. must_index
   indx( 'id', 'id' )
   indx( 'serial', 'serial' )
   indx( 'model', 'model' )

  else
   pack

  endif

 endif


 if NetUse( "owner", EXCLUSIVE, 10 )
  PackStat( packindx, 'Owner file' )

  if !file( Oddvars( SYSPATH ) + 'owner' + indexext() ) .or. must_index
   indx( 'id', 'id' )

  else
   pack

  endif
 endif

 if NetUse( "prodcode", EXCLUSIVE, 10 )
  PackStat( packindx, 'Product Code file' )

  if !file( Oddvars( SYSPATH ) + 'prodcode' + indexext() ) .or. must_index
   indx( 'id', 'id' )

  else
   pack

  endif
 endif

 if NetUse( "operator", EXCLUSIVE, 10 )
  PackStat( packindx, 'Operator file' )

  if !file( Oddvars( SYSPATH ) + 'operator' + indexext() ) .or. must_index
   indx( 'id', 'id' )

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
 if elapsed > 60
  ?
  ? "Time for " + packindx + " = " + str( elapsed / 60, 2 ) + " minutes " + ;
     str( elapsed % 60, 2 )+" seconds"

 else
  ?
  ? "Time for " + packindx + " = " + str( elapsed % 60 , 2 ) + " seconds"

 endif
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

