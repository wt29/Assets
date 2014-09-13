/*

 Assets System - Bluegum Software
 Module Enquire - General Enquiries

*/
 
#include "assets.ch"

#define LEFT_ARROW chr( 27 )
#define RIGHT_ARROW chr( 26 )

Procedure EnqAsset

local mscr := Box_Save()
local mkey, enqobj, loopval:=FALSE
local getlist:={}, sCode

if NetUse( "location" )
 if NetUse( "owner" )
  if NetUse( "assets" )
   assets->( ordsetfocus( 'code' ) )
   set relation to assets->ownerId into owner,;
                to assets->code into location
   loopval := TRUE
  endif
 endif
endif


Heading( 'Enquire on Asset' )

while loopval
 sCode = space(10)
 Box_Save( 02, 08, 4, 72 )
  @ 03, 10 say 'Enter Asset No or / for Description to Enquire' get sCode pict '@!'
 read
 if !updated()
  loopval := FALSE

 else
  assets->( dbseek( sCode ) )
  if assets->( eof() )
   Error( 'No assets found', 12 )

  else 
   Heading('Asset Inquiry' )
   select assets
   enqobj:=tbrowsedb( 01, 00, 24, 79 )
   enqobj:colorspec := if( iscolor(), TB_COLOR, setcolor() )
   enqobj:HeadSep := HEADSEP
   enqobj:ColSep := COLSEP
   enqobj:goTopBlock := { || jumptotop( sCode ) }
   enqobj:goBottomBlock := { || jumptobott( sCode ) }
   enqobj:skipBlock:={ | SkipCnt | AwSkipIt( SkipCnt, { || assets->code },sCode )}
   enqobj:addcolumn( tbcolumnNew( 'Asset Code', { || assets->code } ) )
   enqobj:addcolumn( tbcolumnNew( 'Description', { || left( assets->desc, 30 ) } ) )
   enqobj:addcolumn( tbcolumnNew( 'Model', { || left( assets->model, 20 ) } ) )
   enqobj:addcolumn( tbcolumnNew( 'Serial', { || assets->serial } ) )
   enqobj:freeze := 1
   mkey := 0

   while mkey != K_ESC .and. mkey != K_RDBLCLK
    enqobj:forcestable()
    mkey := inkey(0)

    if !Navigate( enqobj, mkey )
     if mkey == K_ENTER .or. mkey == K_LDBLCLK
      assetForm( TRUE )

     endif 

    endif

   enddo

  endif

 endif

enddo 

close databases

Box_Restore( mscr )
return nil

/*


procedure ContractEnq ( mContractNum )
local mrow
local minsure
cls
Heading( 'Enquiry on contract #' + Ns( mContractNum ) )

Syscolor( C_NORMAL )
if file( OddVars( SYSPATH ) + "mcomment\" + Ns(mContractNum) + ".txt" )
 HighLight( 01, 01, "", "F4" )
endif

Highlight( 02, 01, 'Hirer Surname', hirer->surname )
Highlight( 03, 01, '   First Name', hirer->first  )
Highlight( 05, 01, ' Addr. Line 1', hirer->add1  )
Highlight( 06, 01, '       line 2', hirer->add2  )
Highlight( 07, 01, '       Suburb', hirer->suburb )
Highlight( 08, 01, '     Postcode', hirer->pcode )
Highlight( 10, 01, 'Date of Birth', hirer->dob )
Highlight( 11, 01, '   License no', hirer->license )
Highlight( 12, 01, '  Expiry date', dtoc( hirer->expiry_d ) )

#ifdef DISCOUNT
Highlight( 13, 01, 'Map Reference', hirer->car_rego )

#else
 #ifndef RENTACENTRE
  #ifndef ARGYLE
   #ifndef BYRNES
  Highlight( 13, 01, ' Car rego no.', hirer->car_rego )
   #else
  Highlight( 13, 01, '          CRN', hirer->car_rego )
   #endif
  #else
  Highlight( 13, 01, 'Contr Penalty', hirer->car_rego )
  Highlight( 14, 01, '       E-Mail', hirer->email )

  #endif
 #else
  Highlight( 13, 01, '       E-Mail', hirer->email )

 #endif

 #ifdef MEDI
  Highlight( 14, 01, 'Purchase OrdNo', master->ponum )

 #endif

#endif
Highlight( 15, 01, '   Priv Phone', hirer->tele_priv )
Highlight( 16, 01, ' Mobile Phone', hirer->tele_mob )

#ifdef RENTACENTRE
 Highlight( 17, 01, '   Empl Phone', hirer->tele_empl )
 Highlight( 18, 01, '   Occupation', hirer->occupation )
 Highlight( 19, 01, ' Estate agent', substr( hirer->agent, 1, 15 ) )
 Highlight( 20, 01, '  Agent Phone', substr( hirer->agent_no, 1, 12 ) )
#else

 Highlight( 19, 01, '   Occupation', hirer->occupation )
 Highlight( 20, 01, '   Empl Phone', hirer->tele_empl )

#endif
Highlight( 22, 01, 'Comments', master->comments1 )
Highlight( 23, 09, '', master->comments2 )

mrow := 17
minsure := 0

Box_Save( 16, 33, 20, 79, C_BLUE )
@ 16,34 say 'Item Code'
@ 16,45 say 'Description'
@ 16,63 say 'Rent'
@ 16,69 say 'Serial'

// Reposition assets file
assets->( dbseek( mContractNum ) )

while assets->con_no = mContractNum .and. !assets->( eof() )
 HighLight( mrow, 33, '', assets->item_code )
// @ mrow,34 say assets->item_code
 HighLight( mrow, 44, '', left( assets->desc, 15 ) )
 HighLight( mrow, 61, '', transform( assets->( fieldget( fieldpos( master->term_rent + '_rent' ) ) ), '999.99') )
 HighLight( mrow, 68, '', trim( assets->serial ) )
#ifdef INSURANCE
 minsure += assets->insurance
#endif
 assets->( dbskip() )
 mrow++

enddo

Box_Save( 01, 45, 15, 79, C_MAUVE )
Highlight( 02, 46, '     Paid to', dtoc( master->paid_to ) )
Highlight( 03, 46, ' Install due', dtoc( master->next_inst ) )
Highlight( 04, 46, '  Balance BF', Ns( master->bal_bf ) )
Highlight( 05, 46, '  Instalment', Ns( master->install ) )
// Highlight( 05, 65, ' GST', Ns( GSTPaid( master->install ) ) )

#ifdef RENTACENTRE
Highlight( 07, 46, '         RPP', Ns( minsure ) )
Highlight( 08, 46, '       Total', Ns( master->install ) )
Highlight( 09, 46, '   Term Rent', master->term_len )
Highlight( 10, 46, 'Deposit Book', master->dep_no )
Highlight( 11, 46, '   Commenced', dtoc( master->commenced ) )
Highlight( 12, 46, '   Bond Paid', Ns( master->bond_paid ) )
Highlight( 13, 46, 'Pick up Date', dtoc( master->pickup ) )
Highlight( 14, 46, 'Balance Owed', if( empty( master->pickup ), 'N/A', ;
         Ns(-(pickup()) ) + if( pickup() >0 , ' Credit', '' ) ) )

#else

Highlight( 07, 46, '    Location', trim( master->area ) )
Highlight( 08, 46, ' Rent Period', perdesc( master->term_rent ) )
Highlight( 09, 46, '   Term Rent', master->term_len )
Highlight( 10, 46, '   Commenced', dtoc( master->commenced ) )
Highlight( 11, 46, 'Deposit Book', master->dep_no )
 #ifndef BYRNES
Highlight( 12, 46, '  Days Grace', Ns( master->grace ) )
 #else
HighLight( 12, 46, 'Contract End', dtoc( master->EndDate ) )
 #endif

Highlight( 13, 46, '   Bond Paid', Ns( master->bond_paid ) )
Highlight( 14, 46, '   Reminders', transform( master->reminders ,'y' ) )
Highlight( 14, 61, 'Status', LookItUp( 'status', master->status ) )
#endif


Syscolor( C_NORMAL )

select hirer
return

*


*

function Enq_Trans( mContractNum )
local tscr := Box_Save()
local mscr, mkey, enqobj
local getlist := {}
if !tran->( dbseek( mContractNum ) )
 Error( 'No transactions for Selected Contract', 12 )

else
 Heading('Transaction inquiry on Contract #' + Ns(mContractNum))
 @ 1,0 clear to 24, 79
 Highlight( 2, 10, '  Account Balance', Ns( master->bal_bf ) )
 Highlight( 3, 10, '       Paid up to', dtoc( master->paid_to ) )
 Highlight( 4, 10, 'Payment Period is', perdesc( master->term_rent ) )
 enqobj:=tran->( tbrowsedb( 05, 00, 24, 79 ) )
 enqobj:colorspec := if( iscolor(), TB_COLOR, setcolor() )
 enqobj:HeadSep := HEADSEP
 enqobj:ColSep := COLSEP
 enqobj:goTopBlock := { || jumptotop( mContractNum, 'tran' ) }
 enqobj:goBottomBlock := { || jumptobott( mContractNum, 'tran' ) }
 enqobj:skipBlock:={ | SkipCnt | AwSkipIt( SkipCnt, { || tran->con_no }, mContractNum, 'tran' ) }
 enqobj:addcolumn( tbcolumnNew( 'Date', { || tran->date } ) )
 enqobj:addcolumn( tbcolumnNew( 'Credit', { || if( tran->value>0, transform(tran->value,CURRENCY_PICT), '          ' ) } ) )
 enqobj:addcolumn( tbcolumnNew( ' Debit', { || if( tran->value<0, transform(tran->value,CURRENCY_PICT), '          ' ) } ) )
 enqobj:addcolumn( tbcolumnNew( 'Description', { || padr( Tran_type( tran->type ), 16 ) } ) )
 enqobj:addcolumn( tbcolumnNew( 'Comments', { || tran->narrative } ) )
#ifdef MEDI
 enqobj:addcolumn( tbcolumnNew( 'Pay Meth', { || tran->paytype } ) )
#endif
 mkey := 0

 while mkey != K_ESC
  enqobj:forcestable()
  mkey := inkey(0)

  if !Navigate( enqobj, mkey )

   if mkey == K_ENTER .or. mkey == K_F6 .or. mkey == K_LDBLCLK
    mscr := Box_Save( 7, 10, 10, 70 )
    Rec_lock( 'tran' )
    @ 8, 12 say 'Date' get tran->date
    @ 8, 30 say 'Comment' get tran->narrative
#ifdef MEDI
    @ 9, 12 say 'Payment Method' get tran->paytype pict '!' valid( Dup_Chk( tran->paytype, 'paytype' ) )
#endif
    read

    tran->( dbrunlock() )
    Box_Restore( mscr )

   endif
  endif
 enddo
endif

Box_Restore( tscr )
return nil

*

Function Enq_arrears( mContractNum )
local mscr := Box_Save()
local mkey
local enqobj

if !arrears->( dbseek( mContractNum ) )
 Error( 'No Arrears Transactions for Contract #' + Ns( mContractNum ), 12 )

else
 select arrears
 Box_Save( 01, 00, 05, 79 )
 Heading( 'Arrears history on contract #' + Ns( mContractNum ) )

 Highlight( 02, 10, '  Account Balance', Ns( master->bal_bf ) )
 Highlight( 03, 10, '       Paid up to', dtoc( master->paid_to ) )
 Highlight( 04, 10, 'Payment Period is', Perdesc( master->term_rent ) )

 enqobj:=tbrowsedb( 06, 0, 24, 79 )
 enqobj:colorspec := if( iscolor(), TB_COLOR, setcolor() )
 enqobj:HeadSep := HEADSEP
 enqobj:ColSep := COLSEP
 enqobj:goTopBlock := { || jumptotop( mContractNum ) }
 enqobj:goBottomBlock := { || jumptobott( mContractNum ) }
 enqobj:skipBlock := { | SkipCnt | AwSkipIt( SkipCnt, { || arrears->con_no }, mContractNum ) }
 enqobj:addcolumn( tbcolumnNew( 'Date Due', { || arrears->due } ) )
 enqobj:addcolumn( tbcolumnNew( 'Amount', { || transform( arrears->amount, '999.99') } ) )
 enqobj:addcolumn( tbcolumnNew( 'Balance', { || transform( arrears->amount - arrears->amt_paid, '999.99') } ) )
 enqobj:addcolumn( tbcolumnNew( 'Date Paid', { || if( empty( arrears->date_paid ), 'Unpaid!', dtoc( arrears->date_paid ) ) } ) )
 enqobj:addcolumn( tbcolumnNew( 'Letter 1', { || arrears->stat1 } ) )
 enqobj:addcolumn( tbcolumnNew( 'Letter 2', { || arrears->stat2 } ) )
 enqobj:addcolumn( tbcolumnNew( 'Letter 3', { || arrears->stat3 } ) )
 enqobj:freeze := 1
   
 mkey := 0

 while mkey != K_ESC
  enqobj:forcestable()
  mkey := inkey(0)
  Navigate( enqobj, mkey )

 enddo

endif

Box_Restore( mscr )

return nil

*

procedure enqassets

local mgo := FALSE, mitem, mchoice, mcode, mkeypress
local oldscr := Box_Save()
local getlist := {}
local mscr, mscr1
local enqobj
local mkey
local stk_code
local aArray
local mhlparr
local dstru, astru, mlen, nintx, cScreenSave, nMenuChoice, mField, npos, rec_list[ 51 ]
local cStrPart, nrow, bit, lFlag, nSelected

if NetUse( "hirer" )
 if NetUse( "stkhist" )
  if NetUse( "owner" )
   if NetUse( "assets" )
    set relation to assets->owner_code into owner, ;
                 to assets->item_code into stkhist, ;
                 to assets->con_no into hirer
    mgo := TRUE

   endif
  endif
 endif
endif

while mgo

 Box_Restore( oldscr )

 Heading( 'Item file inquiry' )

 aArray := {}
 aadd( aArray, { 'Exit', 'Return to Enquiry menu' } )
 aadd( aArray, { 'Code', 'Find item by Code' } )
 aadd( aArray, { 'Serial', 'Find item by Serial no' } )
 aadd( aArray, { 'Model', 'Find item by Model no' } )
 aadd( aArray, { 'History','Stock History' } )
 aadd( aArray, { 'Part','Search Stock by Part of Field' } )
 mchoice := Menugen( aArray, 4, 2, 'Item' )

 select assets
 do case
 case mchoice = 2
  while TRUE
   Heading('Inquire by code') 
   mcode := space(10)
   Box_Save( 5, 10, 7, 40 )
   @ 06,11 say 'Item Code' get mcode pict '@!'
   read
   if !updated()
    exit

   else
    assets->( ordsetfocus( 'item_code' ) )
    if !assets->( dbseek( mcode ) )
     Error( 'Code not ' + trim(mcode) + ' on file',12 )

    else
     assetForm( TRUE )

    endif
   endif
  enddo

 case mchoice = 3 .or. mchoice = 4

  if mchoice = 3
   assets->( ordsetfocus( 'serial' ) )
   mkey = 'Serial'

  else
   assets->( ordsetfocus( 'model' ) )
   mkey = 'Model'

  endif

  mscr := Box_Save()
  while TRUE
   Box_Restore( mscr )
   Heading( 'Inquire by '+mkey )
   mitem := space(5)
   Box_Save( 3+mchoice, 08, 5+mchoice, 40 )
   @ 4+mchoice, 10 say 'Part of ' + mkey get mitem pict '@!'
   read

   if !updated()
    assets->( ordsetfocus( 'contract' ) )
    exit

   else
    mitem := trim( mitem )

    if !assets->( dbseek( mitem ) )
     Error('No '+ mkey + ' match on file',12 )

    else
     @ 1,0 clear to 24,79
     select assets
     enqobj:=tbrowsedb( 01, 0, 24, 79 )
     enqobj:colorspec := if( iscolor(), TB_COLOR, setcolor() )
     enqobj:HeadSep := HEADSEP
     enqobj:ColSep := COLSEP
     enqobj:goTopBlock := { || jumptotop( mitem ) }
     enqobj:goBottomBlock := { || jumptobott( mitem ) }
     enqobj:skipBlock := { |SkipCnt| AwSkipIt( SkipCnt, { || if( mchoice=3, assets->serial,assets->model ) }, mitem ) }
     enqobj:addcolumn( tbcolumnNew( 'Item Code', { || assets->item_code } ) )
     enqobj:addcolumn( tbcolumnNew( 'Model No', { || left( assets->model, 15 ) } ) )
     enqobj:addcolumn( tbcolumnNew( 'Serial No', { || left( assets->serial, 15 ) } ) )
     enqobj:addcolumn( tbcolumnNew( 'Description', { || left( assets->desc, 20 ) } ) )
     enqobj:addcolumn( tbcolumnNew( 'Stat', { || assets->status } ) )
     enqobj:addcolumn( tbcolumnNew( 'Owner', { || assets->owner_code } ) )
     enqobj:freeze := 1
     mkeypress := 0
     while mkeypress != K_ESC

      enqobj:forcestable() 
      mkeypress := inkey(0)

      if !Navigate( enqobj, mkeypress )

       if mkeypress = K_ENTER .or. mkeypress == K_LDBLCLK

        assetForm( TRUE )

        Oddvars( LASTITEM, assets->item_code )

       endif

      endif

     enddo

    endif

   endif

  enddo

 case mchoice = 5
  mscr1 := Box_Save()
  while TRUE

   Box_Restore( mscr1 )

   Heading('Stock history enquiry')
   stk_code := space( 10 )
   mscr := Box_Save( 08, 10, 10, 40 )
   @ 09,12 say 'Stock code' get stk_code pict '@!'
   read

   if !updated()
    exit

   else

    if !stkhist->( dbseek( stk_code ) )
     Error( 'No history found for ' + trim( stk_code ), 12 )

    else
     assets->( ordsetfocus( 'Item_code' ) )
     assets->( dbseek( trim( stk_code ) ) )

     @ 1,0 clear to 24,79
     Highlight( 1, 1, 'Description', left( assets->desc, 20 ) )
#ifdef ARGYLE
     Highlight( 1, 40, '   Status', LookItUp( "status", assets->status ) )
#else
     Highlight( 1, 40, '   Status', st_status( assets->status ) )
#endif
     Highlight( 2, 1, '      Model', assets->model )
     Highlight( 2, 40, 'Serial No', assets->serial )
     select stkhist
     stkhist->( dbseek( stk_code ) )
     enqobj := tbrowsedb( 04, 0, 24, 79 )
     enqobj:colorspec := if( iscolor(), TB_COLOR, setcolor() )
     enqobj:HeadSep := HEADSEP
     enqobj:ColSep := COLSEP
     enqobj:goTopBlock := { || jumptotop( stk_code ) }
     enqobj:goBottomBlock := { || jumptobott( stk_code ) }
     enqobj:skipBlock := { |SkipCnt| AwSkipIt( SkipCnt, { || stkhist->item_code }, stk_code ) }
     enqobj:addcolumn(tbcolumnNew('Date Ret', { || stkhist->returned } ) )
     enqobj:addcolumn(tbcolumnNew('Contract #', { || stkhist->con_no } ) )
     enqobj:addcolumn(tbcolumnNew('Name', { || stkhist->name } ) )
     enqobj:addcolumn(tbcolumnNew('Address', { || left( trim( stkhist->address1 ) + ' ' + ;
            trim( stkhist->address2 ) + ' ' + stkhist->suburb, 38 ) } ) )
     enqobj:addcolumn(tbcolumnNew('Disposed', { || stkhist->disposed } ) )
     enqobj:freeze := 1
     mkeypress := 0
     while mkeypress != K_ESC

      enqobj:forcestable()
      mkeypress := inkey(0)

      if !Navigate( enqobj, mkeypress )

       do case
       case mkeypress = K_F10
        select assets
        assetForm( TRUE )

        Oddvars( LASTITEM, assets->item_code )

        select stkhist

       case mkeypress = K_ENTER .or. mkeypress == K_LDBLCLK
        mscr := Box_Save( 13, 00, 20, 65 )

        Rec_lock( 'stkhist' )
        @ 14,01 say '      Date' get stkhist->returned
        @ 15,01 say '  Customer' get stkhist->name
        @ 16,01 say 'Addr Line1' get stkhist->address1
        @ 17,01 say 'Addr Line2' get stkhist->address2
        @ 18,01 say '    Suburb' get stkhist->suburb
        @ 19,01 say '   Details' get stkhist->details
        read
        stkhist->( dbrunlock() )
        Box_Restore( mscr )

       case mkeypress = K_INS
        mscr := Box_Save( 13, 00, 20, 65 )

        Add_Rec( 'stkhist' )
        stkhist->returned := Oddvars( SYSDATE )
        @ 14,01 say '      Date' get stkhist->returned
        @ 15,01 say ' Invoice #' get stkhist->name
        @ 16,01 say '     Fault' get stkhist->address1
        @ 17,01 say '      Cost' get stkhist->address2
        @ 18,01 say 'Technician' get stkhist->suburb
        @ 19,01 say '   Details' get stkhist->details
        read
        stkhist->( dbrunlock() )
        Box_Restore( mscr )

       case mkeypress == K_F1
        mhlparr := {}
        aadd( mhlparr, { 'Esc', 'Escape from this Screen' } )
        aadd( mhlparr, { 'F10', 'Display Item Details' } )
        aadd( mhlparr, { 'Enter', 'View Details' } )
        aadd( mhlparr, { 'Ins', 'Insert History' } )
        Build_help( mhlparr )

       endcase

      endif

     enddo

    endif

   endif

  enddo
  select assets

 case mchoice = 6
  mscr1 := Box_Save()

  while TRUE
   Box_Restore( mscr1 )
   Heading('Select Field to Search within')
   select assets
   dstru:= dbstruct()
   astru:={}
   mlen := len(dstru)
   for nIntX:=1 to mlen
    if dstru[ nIntx, 2 ] = 'C'
     aadd(astru, dstru[ nIntx, 1 ] )
    endif
   next
   cScreenSave:=Box_Save( 2, 2, 24, 14 )
   nMenuChoice:=achoice( 3, 3, 23, 13, astru)
   if nMenuChoice = 0
    exit

   else
    mfield:=astru[nMenuChoice]
    mfield:=upper(substr(mfield,1,1))+lower(substr(mfield,2,len(mfield)-1))
    Heading("Enter Part to search for")
    Box_Save(2,8,5,72)
    @ 3,10 say 'This option will search for part of a '+mfield+' (10 Characters)'
    @ 4,10 say '      It may take a considerable period of time'
    cStrPart:=space(10)
    Box_Save( 5, 8, 7, 45 )
    @ 06, 10 say 'Enter Part of ' + mfield get cStrPart pict '@!'
    read
    if !updated()
     exit

    else
     select assets

     ordsetfocus()  // No index in use
     cls
     Heading("Part Search in " + mfield)
     go top
     nRow := 4
     nPos := 1
     @ 2,0 say ' No  Code      Desc                       Model            St'
     @ 3,0 say '-------------------------------------------------------------'
     lFlag := TRUE
     Highlight(1,02,'Records to search',Ns(lastrec()))
     bit := fieldpos(mfield)
     cStrPart := trim(cStrPart)
     while lFlag .and. !eof() .and. Pinwheel()
      if cStrPart $ upper(trim(fieldget(bit)))

       @ nRow,00 say nPos pict '999'
       @ nRow,04 say substr( assets->item_code, 1, 10 )
       @ nRow,15 say substr( assets->desc, 1, 25 )
       @ nRow,42 say substr( assets->model, 1, 15 )
       @ nRow,59 say assets->status

       rec_list[nPos] := recno()
       nRow++
       nPos++

      endif
      Highlight(1,50,'Record Number',Ns(recno()))
      skip

      if nRow >= 24 - 1 .or. eof() .or. inkey() != 0
       while TRUE
        nSelected := 0
        @ 24,10 say 'Enter No to Examine '+if(eof(),'','or <Enter> for next page');
                get nSelected pict '99' valid(nSelected < nPos)
        read
        if lastkey() = K_ESC
         lFlag := FALSE
         exit
        endif
        if nSelected = 0
         @ 4,0 clear
         nPos := 1
         nRow := 4
         exit
        endif
        if updated()
         goto rec_list[ nSelected ]
         assetForm( TRUE )
        endif
       enddo
      endif
     enddo
    endif
   endif
   // vidmode( 25,80 )
   select assets
   ordsetfocus( 'contract' )
  enddo

 case mchoice < 2
  dbcloseall()
  return

 endcase

enddo
return

*

procedure enq_credcard
local mscr := Box_Save( 3, 10, 7, 70 )
Highlight( 4, 12, 'Card Number', trim( master->cred_card ) )
Highlight( 5, 12, 'Expiry Date', trim( dtoc( master->expirydate ) )  )
Highlight( 6, 12, 'Card ID', trim( master->card_id ) )
Error('', 12 )
Box_Restore( mscr )
return

*

Function StuffLastItem
Keyboard Oddvars( LASTITEM ) + chr( K_ENTER )
return nil

*

Function StuffLastCont
Keyboard Oddvars( LASTCONT ) + chr( K_ENTER )
return nil

*

Procedure enqowner
local mcode
local oldscr := Box_Save()
local getlist := {}
local mscr 

if !NetUse( "owner" )
 return
endif

while TRUE

 Box_Restore( oldscr )

 Heading('Owner inquiry by code')
 mscr := Box_Save( 4, 10, 6, 40 )
 mcode := space(3)
 @ 05,12 say 'Owner code' get mcode pict '@!'
 read

 if !updated()
  exit

 else
  if !owner->( dbseek( mcode ) )
   Error('Owner code ' + mcode + ' not on file',12)

  else
   Box_Save( 02, 08, 12, 72 )

   Highlight( 03, 10, 'Name', owner->name )
   Highlight( 05, 10, 'Address', owner->add1 )
   Highlight( 06, 10, '       ', owner->add2 )
   Highlight( 08, 10, 'Phone no', owner->phone )   
   Highlight( 10, 10, 'Contact', owner->contact )
   Error('')

  endif

 endif

enddo
dbcloseall()
return

*

Function Pickup_Calc
local getlist := {}
if rec_lock( 'master' )
 @ 13, 50 say 'Pick Up Date' get master->pickup
 read
 master->( dbrunlock() )

endif
return nil

*

Function Pickup
local nRet := 0
local nDay
nDay := ( master->install * 12 ) / 365
nret :=  ( ( master->paid_to - master->pickup ) * nDay )
return nRet


function ChangeEndDate( )
local getlist := {}
if rec_lock( 'master' )
 @ 12, 46 say 'Contract End' get master->EndDate
 read
 master->( dbrunlock() )

endif
return nil



function ChangeStatus( )
local getlist := {}
if rec_lock( 'master' )
 @ 14, 68 say space(11)
 @ 14, 61 say 'Status' get master->status pict '@!' valid dup_chk( master->status, 'status' )
 read
 master->( dbrunlock() )

endif

return nil

*/