/*

 Assets - Bluegum Software

 Module MainAsset - Asset maintenance
 
      Last change:  TG   14 Mar 2011    2:17 pm
*/

#include "Assets.ch"

Function MainAsset

local ok := FALSE, getlist:={}, loopval, choice, sCode, sOwnerID, sOwnerID2

local sOwnerID1, newloop, aArray

local oldscr := Box_Save()
local mtemp
local cScr

if NetUse( "location" )
 if NetUse( "owner" )
  if NetUse( "assets" )
   assets->( ordsetfocus( 'code' ) )
   set relation to assets->ownerId into owner,;
                to assets->code into location
   ok := TRUE
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
 aadd( aArray, { 'Location', 'Change location of Asset' } )
 aadd( aArray, { 'Owner', 'Change owner details for Asset' } )
 aadd( aArray, { 'Delete', 'Delete Assets from file' } )
 // aadd( aArray, { 'History', 'Modify Stock Histories' } )
 choice := MenuGen( aArray, 03, 13, 'Assets' )

 do case
 case choice = 2 .and. Secure( X_ADDFILES )
  loopval := TRUE

  while loopval
   sCode = space(10)

   Box_Save( 02, 08, 12, 72 )
   Heading( 'Add new Asset' )
   sCode := space( 10 )
   @ 3,10 say 'Enter Asset ID to add' get sCode pict '@!'
   read
   if !updated()
    loopval := FALSE

   else
    if assets->( dbseek( sCode ) )
     Highlight( 07, 10, 'Description', Assets->desc )
     Highlight( 09, 10, '     Serial', Assets->serial )
     Error('Asset Code already on file',12)

    else
     sOwnerID := globalVars( B_DEF_OWNER )
     while TRUE
      @ 7,10 say 'Enter owner code' get sOwnerID pict '@!'
      read
      if lastkey() = K_ESC
       exit
      endif

      if !owner->( dbseek( sOwnerID ) )
       Error('Owner code not on file ',12)

      else
       Add_rec( 'Assets' )
       Assets->code := sCode
       Assets->ownerId := sOwnerID
       AssetForm( FALSE )
       if !updated()
        Assets->( dbdelete() )
       endif
       Assets->( dbrunlock() )
       exit
      endif
     enddo
    endif
   endif
  enddo

 case choice = 3 .and. Secure( X_EDITFILES )
  loopval := TRUE
  while loopval
   sCode = space(10)

   Heading( 'Change Asset Details' )
   @ 7,21 say 'ÍÍ¯Asset no to edit' get sCode pict '@!'
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

 case choice = 4 .and. Secure( X_EDITFILES )
  loopval := TRUE

  while loopval
   sCode = space(10)

   Heading('Change owner code on Asset')
   sOwnerID1 = space(3)
   @ 08,21 say 'ÍÍÍ¯ Owner code to change from' get sOwnerID1 pict '@!'
   read
   if !updated()
    loopval := FALSE

   else
    if !owner->( dbseek( sOwnerID1 ) )
     Error( 'Owner code not found', 12 )

    else
     sOwnerID2 = space(3)
     Box_Save( 2, 08, 15, 72 )
     Highlight( 3, 10, 'Old owner ', owner->name )

     @ 5,10 say 'Owner code to change to' get sOwnerID2 pict '@!'
     read

     if updated()
      if !owner->( dbseek( sOwnerID2 ) )
       Error('New owner code is not on file',12)

      else
       Box_Save( 05, 09, 14, 71 )
       Highlight( 5, 10, 'New owner', owner->name )
       newloop := TRUE
       while newloop
        @ 7,09 clear to 14,71
        Heading('Change owner code on Asset')
        sCode = space(10)
        @ 7,10 say 'Asset code to change' get sCode pict '@!'
        read
        if !updated()
         newloop := FALSE

        else
         if !Assets->( dbseek( sCode ) )
          Error( 'Asset Code not on found', 12 )
         else

          if Assets->owner_code != sOwnerID1
           Error( 'Asset owner does not match old owner', 12 )
          else

           Highlight( 09, 10, 'Model       ', Assets->model )
           Highlight( 11, 10, 'Serial      ', Assets->serial )
           Highlight( 13, 10,' Description ', Assets->desc )

           if Isready( 'Ok to change this Asset' )

            Rec_lock( 'Assets' )
            Assets->owner_code := sOwnerID2
            Assets->( dbrunlock() )

           endif
          endif
         endif
        endif
       enddo
      endif
     endif
    endif
   endif
  enddo
 case choice = 5 .and. Secure( X_DELFILES )
  loopval := TRUE

  while loopval
   sCode = space(10)

   Heading( 'Delete Asset' )
   @ 9,21 say 'ÍÍÍ¯Asset code to delete' get sCode pict '@!'
   read
   if !updated()
    loopval := FALSE
   else
    if !Assets->( dbseek( sCode ) )
     Error( 'Asset code not on file', 12 )

    else
     Box_Save( 04, 08, 15, 72 )
     if Assets->status != 'O'
      Highlight( 05, 10, '      Model', Assets->model )
      Highlight( 07, 10, 'Description', Assets->desc )
      Highlight( 09, 10, '  Serial no', Assets->serial )
      Highlight( 11, 10, 'This Asset rented on contract no. ', Ns(Assets->con_no) )
      @ 13,10 say '    it cannot be deleted'
      Error('Asset not on-hand',15)

     else
      Highlight( 05, 10, 'Model       ', Assets->model )
      Highlight( 07, 10, 'Description ', Assets->desc )
      Highlight( 09, 10, 'Serial no.  ', Assets->serial )
      if Isready()
       Rec_lock( 'Assets' )
       Assets->( dbdelete() )
       Assets->( dbrunlock() )

#ifdef RENTACENTRE
       Audit( 0, 'M', 0, '', sCode )
#endif

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
   endif
  enddo
 case choice = 6 .and. Secure( X_EDITFILES )
  loopval := TRUE
  cScr := Box_Save()
  while loopval
   Box_Restore( cScr )
   sCode = space(10)

   Heading('Update Asset History')
   @ 10,22 SAY 'ÍÍ¯Enter Asset No to Edit ' get sCode pict '@!'
   read
   if !updated()
    loopval := FALSE
   else
    if !Assets->( dbseek( sCode ) )
     Error( 'Assets Code not on file', 12 )

    else
     cls
     Heading( 'Asset File Inquiry' )
     Highlight( 03, 01, '   Asset code', Assets->id )
     Highlight( 05, 01, '    Model No', Assets->model )
     Highlight( 06, 01, ' Description', Assets->desc )
     Highlight( 07, 01, '   Serial No', Assets->serial )
     Highlight( 08, 01, 'Product Code', Assets->prod_code )
     Highlight( 09, 01, '       Owner', Assets->owner_code )
     Highlight( 11, 01, '      Status', st_status( Assets->status ) )
     Highlight( 12, 01, 'Contract No.', Assets->con_no )
     @ 03,54 say 'Rentals'
     @ 04,54 say '-------'
     Highlight( 05, 50, '    Monthly', Ns( Assets->m_rent ) )
     Highlight( 06, 50, 'Fortnightly', Ns( Assets->f_rent ) )
     Highlight( 07, 50, '     Weekly', Ns( Assets->w_rent ) )
     Highlight( 08, 50, '      Daily', Ns( Assets->d_rent ) )

     Add_rec( 'stkhist' )
     stkhist->id := Assets->id
     @ 14,01 say '      Date' get stkhist->returned
     @ 15,01 say ' Invoice #' get stkhist->name
     @ 16,01 say '     Fault' get stkhist->address1
     @ 17,01 say '      Cost' get stkhist->address2
     @ 18,01 say 'Technician' get stkhist->suburb
     @ 19,01 say '   Details' get stkhist->details
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
local getlist:={}, sLabel
local bKF4        // Old F4 Key

local mscr := Box_Save(), cAssetstatus := Assets->status

cls

Heading( 'Asset Editing Screen' )

Highlight( 02, 04, 'Asset code', Assets->code )
if lReadOnly
 Highlight( 04, 01, '     Model no', assets->model )
else
 @ 04,01 say '    Model no' get assets->model pict '@!'
endif
if lReadOnly
 Highlight( 05, 01, '  Description', assets->desc )
else
 @ 05,01 say ' Description' get Assets->desc 
endif
if lReadOnly
 Highlight( 06, 01, '    Serial no', assets->serial )
else
 @ 06,01 say '   Serial no' get Assets->serial pict '@!'
endif

if lReadOnly
 Highlight( 07, 01, ' Product code', assets->prod_code )
else
 @ 07,01 say 'Product code' get Assets->prod_code pict '@!' valid( dup_chk( Assets->prod_code, 'prodcode' ) )
endif

if lReadOnly
 Highlight( 08, 01, '        Owner', LookItup( "owner" , assets->ownerID ) )
else
 Highlight( 08, 08, 'Owner', Lookitup( "owner" , Assets->ownerID ) )
endif

if lReadOnly
 Highlight( 09, 01, '       Status', LookItUp( 'status', Assets->Status ) )
else
 @ 09, 07 say 'Status' get Assets->status valid( dup_chk( Assets->status, 'status' ) )
endif


if lReadOnly
 Highlight( 11, 01, 'Original cost', Ns( assets->cost ) )
else
 @ 11,01 say 'Original cost' get Assets->cost
endif

if lReadOnly
 Highlight( 12, 01, 'Purchase date', dtoc( assets->received ) )
else
 @ 12,01 say 'Purchase date' get Assets->received
endif

if lReadOnly
 Highlight( 13, 01, 'Warranty exp.', dtoc( assets->warranty_d ) )
else
 @ 13,01 say 'Warranty exp.' get Assets->warranty_d
endif

Highlight( 15, 05, '', 'Leasing Details' )

if lReadOnly
 Highlight( 16, 01, '    Monthly payments', Ns( assets->month_pay ) )
else
 @ 16, 01 say '    Monthly payments' get Assets->month_pay pict '999999.99'
endif 

if lReadOnly
 Highlight( 17, 01, '   Lease term (mths)', Ns( assets->lease_term ) )
else
 @ 17, 01 say '   Lease term (mths)' get Assets->lease_term pict '99'
endif

if lReadOnly
 Highlight( 18, 01, '       Payments made', Ns( assets->pay_made ) )
else
 @ 18, 01 say '       Payments made' get Assets->pay_made pict '99'
endif
if lReadOnly
 Highlight( 19, 01, '    Lease interest %', Ns( assets->interest ) )
else
 @ 19, 01 say '    Lease Interest %' get Assets->interest pict '99.99'
endif

if lReadOnly
 Highlight( 20, 01, '  Lease payments ytd', Ns( assets->pay_ytd ) )

else
 @ 20, 01 say '  Lease payments ytd' get Assets->pay_ytd pict '99999.99'

endif

if lReadOnly
 Highlight( 21, 01, 'Lease payments total', Ns( assets->pay_tot ) )

else
 @ 21, 01 say 'Lease payments total' get Assets->pay_tot pict '99999.99'

endif

if lReadOnly
 Highlight( 22, 01, '   Rule of 78 payout', Ns( Rule_78( assets->cost, assets->lease_term, ;
          assets->pay_made, assets->month_pay ) ) )

endif

Highlight( 15, 46 , '' , 'Fixed Asset Information' )
sLabel := "   Date into Service"
if lReadOnly
 Highlight( 16, 30, sLabel, assets->serv_date )
else 
 @ 16, 30 say sLabel get Assets->serv_date
endif
sLabel := " Depreciation Method"
if lReadOnly
 Highlight( 17, 30, sLabel, assets->depr_mthd )
else 
 @ 17, 30 say sLabel get Assets->depr_mthd pict "!" valid( Assets->depr_mthd $ 'SD' )
endif
Highlight( 17, 55, "", "<S>tL,<D>ecYear" )
sLabel := "    Depreciable Life"
if lReadOnly
 Highlight( 18, 30, sLabel, assets->depr_life )
else
 @ 18, 30 say sLabel get Assets->depr_life
endif
Highlight( 18, 63, "", "Months" )
sLabel := "       Salvage Value"
if lReadOnly
 Highlight( 19, 30, sLabel, assets->salvage )
else
 @ 19, 30 say "       Salvage Value" get Assets->salvage pict "9999999.99" valid( Assets->salvage <= Assets->cost )
endif
Highlight( 20, 40, '', 'Must be less than or equal to Cost' )

if !lReadOnly
 bKF4 := setkey( K_F4, { || Abs_edit( 'Assets', nil, TRUE ) } )   // Abs with record locked!
 read
 setkey( K_F4, bKF4 )

else
 Error( "" )

 endif


Box_Restore( mscr )
return

*



/*

procedure assetSay assets
local mscr := Box_Save()
local owner_not_open := ( select( 'owner' ) = 0 )
local nCurr := 0, nYTD := 0, nAccum := 0

default mfile to 'Assets'
cls

Heading( 'Asset Details' )
if lReadOnly
Highlight( 02, 01, '   Asset Code', ( mfile )->id )
else
if lReadOnly
Highlight( 04, 01, '     Model no', ( mfile )->model )
else
if lReadOnly
Highlight( 05, 01, '  Description', ( mfile )->desc )
else
if lReadOnly
Highlight( 06, 01, '    Serial no', ( mfile )->serial )
else
if lReadOnly
Highlight( 07, 01, ' Product code', ( mfile )->prod_code )
else
if lReadOnly
Highlight( 09, 01, '        Owner', LookItup( "owner" , ( mfile )->owner_code ) )
else
if lReadOnly
Highlight( 10, 01, '       Status', st_status( ( mfile )->status ) )
else
if lReadOnly
Highlight( 11, 01, '  Contract no', Ns( ( mfile )->con_no ) )
else
if lReadOnly
Highlight( 01, 54, 'Rentals' , '' )
else
if lReadOnly
Highlight( 02, 54, 'ÄÄÄÄÄÄÄ' , '' )
else
if lReadOnly
Highlight( 03, 50, '    Monthly', Ns( ( mfile )->m_rent ) )
Highlight( 04, 50, 'Fortnightly', Ns( ( mfile )->f_rent ) )
Highlight( 05, 50, '     Weekly', Ns( ( mfile )->w_rent ) )
Highlight( 06, 50, '      Daily', Ns( ( mfile )->d_rent ) )
#ifdef INSURANCE
Highlight( 04, 69,'Ins.',Ns( ( mfile )->insurance ) )
#endif
Highlight( 13, 01, '  Rentals YTD', Ns( ( mfile )->rent_ytd ) )
Highlight( 14, 01, 'Rentals Total', Ns( ( mfile )->rent_tot ) )
Highlight( 16, 01, '  Last rented', dtoc( ( mfile )->last_rent ) )
Highlight( 17, 01, 'Last returned', dtoc( ( mfile )->last_ret ) )
if lReadOnly
Highlight( 19, 01, 'Original cost', Ns( ( mfile )->cost ) )
else
if lReadOnly
Highlight( 20, 01, 'Purchase date', dtoc( ( mfile )->received ) )
if lReadOnly
Highlight( 21, 01, 'Warranty exp.', dtoc( ( mfile )->warranty_d ) )
else
if lReadOnly
Highlight( 08, 48, 'Leasing Details', '' )
if lReadOnly
Highlight( 09, 40, '    Monthly payments', Ns( ( mfile )->month_pay ) )
else
if lReadOnly
Highlight( 10, 40, '   Lease term (mths)', Ns( ( mfile )->lease_term ) )
else
if lReadOnly
Highlight( 11, 40, '       Payments made', Ns( ( mfile )->pay_made ) )
else
if lReadOnly
Highlight( 12, 40, '    Lease interest %', Ns( ( mfile )->interest ) )
else
if lReadOnly
Highlight( 13, 40, '  Lease payments ytd', Ns( ( mfile )->pay_ytd ) )
else
if lReadOnly
Highlight( 14, 40, 'Lease payments total', Ns( ( mfile )->pay_tot ) )
else
if lReadOnly
Highlight( 15, 40, '   Rule of 78 payout', Ns( Rule_78( ( mfile )->cost, ( mfile )->lease_term, ;
          ( mfile )->pay_made, ( mfile )->month_pay ) ) )


#ifdef TODO
mdate := bdate
 Fadepr( mdate, mcurr, mytd, maccum )

//-----* Calculate month and year that depreciation ends
 end_mnth  :=  if( month( serv_date ) = 1, 12, month( serv_date )-1 )
 end_year  :=  year( serv_date ) + depr_life + if( month( serv_date ) = 1, -1, 0 )
 end_date  :=  str( end_mnth, 2 ) + "/" + str( end_year, 4 )

//-----* Calculate remaining undepreciated balance for Asset
 mremain  :=  cost - maccum - salvage

//-----* Display dep. info for Asset
 Highlight( 17, 34, "             Current Month", cmonth(mdate)+" "+str( year( mdate ) ) )
 Highlight( 18, 34, "   End of Depreciable Life", end_date )
 Highlight( 19, 34, "Current Month Depreciation", Ns( mcurr, 10, 2 ) )
 Highlight( 20, 34, "              Year to Date", Ns( mytd, 10, 2 ) )
 Highlight( 21, 34, "  Accumulated Depreciation", Ns( maccum, 10, 2 ) )
 Highlight( 22, 34, "     Undepreciated Balance", Ns( mremain, 10, 2 ) )
#endif
Error('')

if lastkey() = K_F12
 Print_screen()

endif

if lastkey() = K_F4
 abs_edit( 'Assets' )

endif

Box_Restore( mscr )

if owner_not_open .and. ( select( 'owner' ) != 0 )

 owner->( dbclosearea() )

endif

oddvars( LASTAsset, (mfile)->id )

return
*/