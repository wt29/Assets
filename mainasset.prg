/*

 Assets - Bluegum Software

 Module MainAsset - Asset maintenance
 
      Last change:  TG   14 Mar 2011    2:17 pm
*/

#include "Assets.ch"

Function MainAsset

local ok := FALSE, getlist:={}, loopval, choice, sCode
local aArray
local oldscr := Box_Save()
local cScr

if NetUse( "stkhist" )
 if NetUse( "location" )
  if NetUse( "owner" )
   if NetUse( "assets" )
    assets->( ordsetfocus( 'code' ) )
    set relation to assets->ownerId into owner,;
                 to assets->code into location,;
                 to assets->prod_code into stkhist
    ok := TRUE
   endif
  endif
 endif
endif

while ok

 Box_Restore( oldscr )
 Heading( 'Asset file maintenance' )

 aArray := {}
 aadd( aArray, { 'Exit', 'Return to main menu' } )
 aadd( aArray, { 'Add', 'Add new Asset' } )
 aadd( aArray, { 'Change', 'Change Asset details' } )
 aadd( aArray, { 'Delete', 'Delete Assets from file' } )
 aadd( aArray, { 'History', 'Modify Stock Histories' } )
 choice := MenuGen( aArray, 03, 13, 'Assets' )

 do case
 case choice = 2 .and. Secure( X_ADDFILES )
  loopval := TRUE

  while loopval
   sCode = space(10)

   Box_Save( 02, 08, 04, 72 )
   Heading( 'Add new Asset' )
   sCode := space( ASSET_CODE_LEN )
   @ 3,10 say 'Enter Asset ID to add' get sCode pict '@!'
   read
   if !updated()
    loopval := FALSE

   else
    if assets->( dbseek( sCode ) )
     Box_Save( 06, 08, 09, 72 )
	 Highlight( 07, 10, 'Description', Assets->desc )
     Highlight( 08, 10, '     Serial', Assets->serial )
     Error('Asset Code already on file',12)

    else
     Add_rec( 'Assets' )
     Assets->code := sCode
     Assets->ownerId := globalVars( B_DEF_OWNER )
	 assets->depr_mthd := 'S'
     AssetForm( FALSE )
     if !updated()
      Assets->( dbdelete() )

     endif
     Assets->( dbrunlock() )
    endif
   endif
  enddo

 case choice = 3 .and. Secure( X_EDITFILES )
  loopval := TRUE
  while loopval
   sCode = space(10)

   Heading( 'Change Asset Details' )
   Box_Save( 02, 08, 04, 72 )
   sCode := space( ASSET_CODE_LEN )
   @ 3,10 say 'Asset ID to change' get sCode pict '@!'
   read
   if !updated()
    loopval := FALSE

   else
    if !Assets->( dbseek( sCode ) )
     Error( 'Asset code not found', 12 )

    else
     Rec_lock( 'Assets' )
     AssetForm( FALSE )
     Assets->( dbrunlock() )

    endif

   endif
  enddo

 case choice = 4 .and. Secure( X_DELFILES )
  loopval := TRUE

  while loopval
   Heading( 'Delete Asset' )
   Box_Save( 02, 08, 04, 72 )
   sCode := space( ASSET_CODE_LEN )
   @ 3, 10 say 'Asset code to delete' get sCode pict '@!'
   read
   if !updated()
    loopval := FALSE
   else
    if !Assets->( dbseek( sCode ) )
     Error( 'Asset code not on file', 12 )

    else
     Box_Save( 04, 08, 15, 72 )
     Highlight( 05, 10, 'Model       ', Assets->model )
     Highlight( 07, 10, 'Description ', Assets->desc )
     Highlight( 09, 10, 'Serial no.  ', Assets->serial )
     if Isready()
      Rec_lock( 'Assets' )
      Assets->( dbdelete() )
      Assets->( dbrunlock() )
      Audit( 0, 'M', 0, '', sCode )

      stkhist->( dbseek( sCode ) )
      while stkhist->id = sCode .and. !stkhist->( eof() )
       Rec_lock( 'stkhist' )
       stkhist->( dbdelete() )
       stkhist->( dbrunlock() )
       stkhist->( dbskip() )

      enddo
     endif
    endif
   endif
  enddo
 case choice = 5 .and. Secure( X_EDITFILES )
  loopval := TRUE
  cScr := Box_Save()
  while loopval
   Box_Restore( cScr )
   sCode = space(10)

   Heading('Update Asset History')
   Box_Save( 02, 08, 04, 72 )
   sCode := space( ASSET_CODE_LEN )
   @ 03,10 say 'Asset No to modify history ' get sCode pict '@!'
   read
   if !updated()
    loopval := FALSE
   else
    if !Assets->( dbseek( sCode ) )
     Error( 'Assets Code not on file', 12 )

    else
     cls
     Heading( 'Asset File Inquiry' )
     Highlight( 03, 01, '   Asset code', Assets->code )
     Highlight( 05, 01, '    Model No', Assets->model )
     Highlight( 06, 01, ' Description', Assets->desc )
     Highlight( 07, 01, '   Serial No', Assets->serial )
     Highlight( 08, 01, 'Product Code', lookitup( "prodcode", assets->prod_code ) )
     Highlight( 09, 01, '       Owner', lookitup( "owner", assets->ownerID ) )
     Highlight( 10, 01, '      Status', lookitup( "status", assets->status ) )

     Add_rec( 'stkhist' )
     stkhist->code := Assets->code
     @ 14,01 say '     Date' get stkhist->date
     @ 15,01 say 'Invoice #' get stkhist->invoice
     @ 17,01 say '     Cost' get stkhist->cost
     @ 18,01 say '      Who' get stkhist->who
     @ 19,01 say '  Details' get stkhist->details
     read
     if !updated()
      stkhist->( dbdelete() )
      Error( 'No Data Added - Record not added to History' ,12 )
     endif
     stkhist->( dbrunlock() )

    endif
   endif
  enddo
 case choice < 2
  ok := FALSE
 endcase
enddo

dbcloseall()
return nil

*

procedure AssetForm ( lReadOnly )
local getlist:={}
local bKF4        // Old F4 Key
local mscr := Box_Save(), cAssetstatus := Assets->status

cls
Heading( 'Asset Editing Screen' )
Highlight( 02, 04, 'Asset code', Assets->code )
Highlight( 15, 05, '', 'Leasing Details', , 'N' )
Highlight( 11, 46, '', 'Depreciation Information', ,'N' )

if lReadOnly
 Highlight( 04, 01, '     Model no', assets->model )
 Highlight( 05, 01, '  Description', assets->desc )
 Highlight( 06, 01, '    Serial no', assets->serial )
 Highlight( 07, 01, ' Product code', LookItUp( 'prodcode', assets->prod_code ) )
 Highlight( 08, 01, '        Owner', LookItup( "owner" , assets->ownerID ) )
 Highlight( 09, 01, '       Status', LookItUp( 'status', assets->Status ) )
 Highlight( 10, 01, '     Location', LookItUp( 'location', assets->location ) )
 Highlight( 11, 01, 'Original cost', Ns( assets->cost ) )
 Highlight( 12, 01, 'Purchase date', dtoc( assets->received ) )
 Highlight( 13, 01, 'Warranty exp.', dtoc( assets->warranty_d ) )
 Highlight( 16, 01, '    Monthly payments', Ns( assets->month_pay ) )
 Highlight( 17, 01, '   Lease term (mths)', Ns( assets->lease_term ) )
 Highlight( 18, 01, '       Payments made', Ns( assets->pay_made ) )
 Highlight( 19, 01, '    Lease interest %', Ns( assets->interest ) )
 Highlight( 20, 01, '  Lease payments ytd', Ns( assets->pay_ytd ) )
 Highlight( 21, 01, 'Lease payments total', Ns( assets->pay_tot ) )
 Highlight( 22, 01, '   Rule of 78 payout', Ns( Rule_78( assets->cost, assets->lease_term, ;
          assets->pay_made, assets->month_pay ) ) )
 Highlight( 12, 34, '  Date into Service', assets->serv_date )
 Highlight( 13, 34, 'Depreciation Method', assets->depr_mthd )
 Highlight( 14, 34, '   Depreciable Life', assets->depr_life )
 Highlight( 15, 34, '      Salvage Value', assets->salvage )
 Error( "" )
 
else
 Highlight( 13, 60, "", "<S>tL,<D>ecYear" )
 Highlight( 14, 60, "", "Months" )
 Highlight( 16, 40, '', 'Must be less than or equal to Cost' )

 @ 04,01 say '    Model no' get assets->model 
 @ 05,01 say ' Description' get Assets->desc 
 @ 06,01 say '   Serial no' get Assets->serial 
 @ 07,01 say 'Product code' get Assets->prod_code pict '@!' valid( dup_chk( assets->prod_code, 'prodcode' ) )
 @ 08,01 say '       Owner' get assets->ownerID pict '@!' valid( dup_chk( assets->ownerID, 'owner' ) )
 @ 09,01 say '      Status' get Assets->status pict '@!' valid( dup_chk( assets->status, 'status' ) )
 @ 10,01 say '    Location' get Assets->location pict '@!' valid( dup_chk( assets->location, 'location' ) )
 @ 11,01 say '       Original cost' get Assets->cost
 @ 12,01 say '       Purchase date' get Assets->received
 @ 13,01 say '     Warranty expiry' get Assets->warranty_d
 @ 16,01 say '    Monthly payments' get Assets->month_pay pict '999999.99'
 @ 17,01 say '   Lease term (mths)' get Assets->lease_term pict '99'
 @ 18,01 say '       Payments made' get Assets->pay_made pict '99'
 @ 19,01 say '    Lease Interest %' get Assets->interest pict '99.99'
 @ 20,01 say '  Lease payments ytd' get Assets->pay_ytd pict '99999.99'
 @ 21,01 say 'Lease payments total' get Assets->pay_tot pict '99999.99'

 @ 12,34 say '   Date into Service' get Assets->serv_date
 @ 13,34 say ' Depreciation Method' get Assets->depr_mthd pict "!" valid( Assets->depr_mthd $ 'SD' )
 @ 14,34 say '    Depreciable Life' get Assets->depr_life
 @ 15,34 say '       Salvage Value' get Assets->salvage pict "9999999.99" valid( Assets->salvage <= Assets->cost )

 bKF4 := setkey( K_F4, { || Abs_edit( 'Assets', nil, TRUE ) } )   // Abs with record locked!
 read
 setkey( K_F4, bKF4 )

endif
/* TODO - Depreciated value 
 mdate := bdate

 Fadepr( mdate, mcurr, mytd, maccum )

//-----* Calculate month and year that depreciation ends
 end_mnth  :=  if( month( serv_date ) = 1, 12, month( serv_date )-1 )
 end_year  :=  year( serv_date ) + depr_life + if( month( serv_date ) = 1, -1, 0 )
 end_date  :=  str( end_mnth, 2 ) + "/" + str( end_year, 4 )

//-----* Calculate remaining undepreciated balance for Asset
 mremain  :=  cost - maccum - salvage
*/

Box_Restore( mscr )
return






