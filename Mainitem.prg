/*

 Assets - Bluegum Software

 Module MainAsset - Asset maintenance
 
      Last change:  TG   14 Mar 2011    2:17 pm
*/

#include "Assets.ch"

Function MainAsset

local ok := FALSE, getlist:={}, loopval, choice, sCode, sOwnerID, sOwnerID2

local sOwnerID1, newloop, mnext, aArray

local oldscr := Box_Save()
local mtemp
local cScr

if NetUse( "location" )
 if NetUse( "owner" )
  if NetUse( "Assets" )
   Assets->( ordsetfocus( 'AssetId' ) )
   set relation to Assets->ownerId into owner,;
                to Assets->AssetId into location
   ok := TRUE
  endif
 endif
endif

while ok

 Box_Restore( oldscr )
 Heading( 'Asset file maintenance' )

 aArray := {}
 aadd( aArray, { 'Exit', 'Return to main menu' } )
 aadd( aArray, { 'Add', 'Add new Asset Assets' } )
 aadd( aArray, { 'Change', 'Change Asset details' } )
 aadd( aArray, { 'Location', 'Change location of Asset' } )
 aadd( aArray, { 'Owner', 'Change owner details for Asset' } )
 aadd( aArray, { 'Delete', 'Delete Asset Assets from file' } )
 // aadd( aArray, { 'History', 'Modify Stock Histories' } )
 choice := MenuGen( aArray, 04, 13, 'Asset' )

 do case
 case choice = 2 .and. Secure( X_ADDFILES )
  loopval := TRUE

  while loopval
   sCode = space(10)

   Box_Save( 02, 08, 12, 72 )
   Heading( 'Add new Asset Asset' )
   sCode := space( 10 )
   @ 3,10 say 'Enter Asset ID to add' get sCode pict '@!'
   read
   if !updated()
    loopval := FALSE

   else
    if Assets->( dbseek( sCode ) )
     Highlight( 07, 10, 'Description', Assets->desc )
     Highlight( 09, 10, '     Serial', Assets->serial )
     Error('Asset Code already on file',12)

    else
     sOwnerID := Bvars( B_DEF_OWNER )
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
       Assets->AssetID := sCode
       Assets->owner_code := sOwnerID
       AssetGet()
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
     Assetget()
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
       while stkhist->AssetID = sCode .and. !stkhist->( eof() )
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
     Highlight( 03, 01, '   Asset code', Assets->AssetID )
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
     stkhist->AssetID := Assets->AssetID
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

procedure Assetget
local getlist:={}
local bKF4        // Old F4 Key
local okaf10 := setkey( K_ALT_F10, { || AssetContEdit() } )
local okaf7 := setkey( K_ALT_F10, { || AssetContEdit() } )
local mscr := Box_Save(), cAssetstatus := Assets->status
cls
Heading( 'Asset Editing Screen' )
Highlight( 02, 04, 'Asset code', Assets->AssetID )
@ 04,01 say '    Model no' get Assets->model pict '@!'
@ 05,01 say ' Description' get Assets->desc pict '@!'
@ 06,01 say '   Serial no' get Assets->serial pict '@!'
#ifdef VALIDATE_PRODCODE
@ 07,01 say 'Product code' get Assets->prod_code pict '@!' valid( dup_chk( Assets->prod_code, 'prodcode' ) )
#else
@ 07,01 say 'Product code' get Assets->prod_code pict '@!'
#endif
#ifdef MEDI
@ 08,01 say 'MYOB Code' get Assets->MYOBCode pict '@!' valid( dup_chk( Assets->myobcode, 'myobcode' ) )
#endif
Highlight( 09, 08, 'Owner', Lookitup( "owner" , Assets->owner_code ) )

#ifdef ARGYLE
@ 10, 07 say 'Status' get Assets->status valid( dup_chk( Assets->status, 'status' ) )
Highlight( 10, 18, '', LookItUp( 'status', Assets->Status ) )

#else
@ 10, 07 say 'Status' get Assets->status when Assets->con_no <= 0 pict '!' ;
         valid( Assets->status $ 'TSCORW' )

HighFirst( 11, 0, 'Theft Sold ClearOut Onhand Repair Writeoff' )

Highlight( 10, 18, '', st_status( Assets->status ) )

#endif
Highlight( 12, 07, 'Account No', Assets->con_no )
Highlight( 03, 53, '', 'Rental Amounts' )
@ 04,55 say '    Monthly' get Assets->m_rent pict '999.99' valid( Assets->m_rent > 0)
@ 05,55 say 'Fortnightly' get Assets->f_rent pict '999.99' valid( Assets->f_rent > 0)
@ 06,55 say '     Weekly' get Assets->w_rent pict '999.99' valid( Assets->w_rent > 0)
@ 07,55 say '      Daily' get Assets->d_rent pict '999.99' valid( Assets->d_rent > 0)
@ 08,45 say 'All rental Amount fields must have a value!'

#ifdef INSURANCE
@ 03,69 say 'Ins.'
@ 04,73 get Assets->insurance pict '999.99'
#endif

@ 13,01 say '  Rentals YTD' get Assets->rent_ytd pict '99999.99'
@ 14,01 say 'Rentals total' get Assets->rent_tot pict '99999.99'
@ 16,01 say '  Last rented' get Assets->last_rent
@ 17,01 say 'Last returned' get Assets->last_ret
@ 19,01 say 'Original cost' get Assets->cost
@ 20,01 say 'Purchase date' get Assets->received
@ 21,01 say 'Warranty exp.' get Assets->warranty_d

Highlight( 10, 53, '', 'Leasing details' )
@ 11,45 say '    Monthly payments' get Assets->month_pay pict '99999.99'
@ 12,45 say '   Lease term (mths)' get Assets->lease_term pict '99'
@ 13,45 say '       Payments made' get Assets->pay_made pict '99'
@ 14,45 say '    Lease Interest %' get Assets->interest pict '99.99'
@ 15,45 say '  Lease payments ytd' get Assets->pay_ytd pict '99999.99'
@ 16,45 say 'Lease payments total' get Assets->pay_tot pict '99999.99'

#ifdef AssetS
if Assets
 Highlight( 17, 46 , '' , 'Fixed Asset Information' )
 @ 18,40 say "   Date into Service" get Assets->serv_date
 @ 19,40 say " Depreciation Method" get Assets->depr_mthd pict "!" valid( Assets->depr_mthd $ 'SD' )
 @ 19,65 say "<S>tL,<D>ecYear"
 @ 20,40 say "    Depreciable Life" get Assets->depr_life
 @ 21,40 say "       Salvage Value" get Assets->salvage pict "9999999.99";
         valid( Assets->salvage <= Assets->cost )
 @ 22,37 SAY 'Must be less than or equal to Cost'
endif
#endif

bKF4 := setkey( K_F4, { || Abs_edit( 'Assets', nil, TRUE ) } )   // Abs with record locked!

read

setkey( K_F4, bKF4 )

#ifdef RENTACENTRE
if cAssetstatus != Assets->Status
 Audit( 0, MACHINE_MOVEMENT, 0, St_Status( Assets->status ), Assets->AssetID )
endif
if updated()
 Audit( Assets->con_no, Asset_FILE_CHANGED, 0, '', Assets->AssetID )
endif
#endif
setkey( K_ALT_F10, okaf10 )
Oddvars( LASTAsset, Assets->AssetID )
Box_Restore( mscr )
return

*

Static Function AssetContEdit
local mscr := Box_Save( 3, 10, 5, 40 )
local getlist := {}
local oldcon := Assets->con_no
@ 4, 12 say 'New Contract Number' get Assets->con_no pict '9999999'
read
Box_Restore( mscr )
SysAudit( 'AssetContNumChange' + Ns( oldcon ) + '/' + Ns( Assets->con_no ) )
return nil


*

procedure assetSay ( mfile )
local mscr := Box_Save()
local owner_not_open := ( select( 'owner' ) = 0 )

default mfile to 'Assets'
cls

Heading( 'Asset Details' )
Highlight( 02, 01, '    Asset Code', ( mfile )->AssetID )
Highlight( 04, 01, '     Model no', ( mfile )->model )
Highlight( 05, 01, '  Description', ( mfile )->desc )
Highlight( 06, 01, '    Serial no', ( mfile )->serial )
Highlight( 07, 01, ' Product code', ( mfile )->prod_code )
#ifdef MEDI
Highlight( 08, 01, '    MYOB Code', Trim( ( mfile )->MYOBCode ) + ' ' + lookitup( 'MyobCode', (mfile)->MyobCode ) )
#endif
Highlight( 09, 01, '        Owner', LookItup( "owner" , ( mfile )->owner_code ) )
#ifdef ARGYLE
Highlight( 10, 01, '       Status', LookItUp( "status", ( mfile )->status ) )
#else
Highlight( 10, 01, '       Status', st_status( ( mfile )->status ) )
#endif
Highlight( 11, 01, '  Contract no', Ns( ( mfile )->con_no ) )
Highlight( 01, 54, 'Rentals' , '' )
Highlight( 02, 54, 'ÄÄÄÄÄÄÄ' , '' )
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
Highlight( 19, 01, 'Original cost', Ns( ( mfile )->cost ) )
Highlight( 20, 01, 'Purchase date', dtoc( ( mfile )->received ) )
Highlight( 21, 01, 'Warranty exp.', dtoc( ( mfile )->warranty_d ) )
Highlight( 08, 48, 'Leasing Details', '' )
Highlight( 09, 40, '    Monthly payments', Ns( ( mfile )->month_pay ) )
Highlight( 10, 40, '   Lease term (mths)', Ns( ( mfile )->lease_term ) )
Highlight( 11, 40, '       Payments made', Ns( ( mfile )->pay_made ) )
Highlight( 12, 40, '    Lease interest %', Ns( ( mfile )->interest ) )
Highlight( 13, 40, '  Lease payments ytd', Ns( ( mfile )->pay_ytd ) )
Highlight( 14, 40, 'Lease payments total', Ns( ( mfile )->pay_tot ) )
Highlight( 15, 40, '   Rule of 78 payout', Ns( Rule_78( ( mfile )->cost, ( mfile )->lease_term, ;
          ( mfile )->pay_made, ( mfile )->month_pay ) ) )

#ifdef AssetS
 store 0 TO mcurr,mytd,maccum
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

oddvars( LASTAsset, (mfile)->AssetID )

return


