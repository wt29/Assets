/** @package

      assets.ch

      Last change: APG 12/04/2009 5:42:56 PM

      Last change:  TG   20 Jan 2012   10:50 am

Version History
1.00	Cut from the rentals code 


*/
#include "inkey.ch"
#include "dbinfo.ch"
#include "tbrowse.ch"
#include "set.ch"

#define BUILD_NO "1.01"
#define BUILD_DATE "September 2014"

#define SUPPORT_EMAIL 'tglynn@hotmail.com'
#define SUPPORT_PHONE '+61 2 4751-8497'
#define SUPPORT_FAX   'No Fax Number'

#define SYSNAME 'Assets'

#define DEVELOPER 'Bluegum Software'

#define EVALEXP '01/12/2010'

#define CRYPTKEY 'BOLLOCKS'

#define C_BACKGROUND 'BG'

// #define __GTWVW__

#define TEMP_EXT '.ass'

#define CRLF chr( 13 ) + chr( 10 )
#define CR chr( 13 )
#define FF chr( 12 )
#define LF chr( 10 )   
#define TAB chr( 09 )
#define ULINE chr( 205 )   // '-'
#define NULL_DATE ctod( '  /  /  ' )
#define TRUE .t.
#define FALSE .f.
#define YES .t.
#define NO .f.
#define SHARED .f.
#define EXCLUSIVE .t.
#define SOFTSEEK .t.
#define NOEOF .f.
#define NEW .t.
#define OLD .f.
#define NOALIAS nil
#define UNLOCK .t.    // placeholder for Del_rec unlock function
#define NO_EJECT .t.  // placeholder for EndPrint Function
#define NOINTERUPT .t.
#define UNIQUE .t.
#define ALLOW_WILD .t.
#define GO_TO_EDIT .t.
#define WAIT_FOREVER 0   // Used in Inkey - seems more elegant then inkey( 0 )
#define SEC_CHAR chr(254)
#define MODAL .t.
#define DEPNOLEN  6

#define TOTAL_PICT "9999999.99"
#define CURRENCY_PICT "999999.99"

#define RGB( nR,nG,nB )   ( nR + ( nG * 256 ) + ( nB * 256 * 256 ) )

// Printing Bits
#define BIGCHARS chr(27) + chr(33) + chr(48)
#define VERYBIGCHARS chr(27) + chr(33) + chr(49)
#define NOBIGCHARS chr(27) + chr(33) + chr(0)

#define PAPERCUT chr(29) + "V" + chr(66) + chr(0)                            // Used in S_CASH

#define ITALICS chr(27)+chr(37)+'G'
#define NOITALICS chr(27)+chr(37)+'H'

#define BOLD chr(27)+'E'
#define NOBOLD chr(27)+'F'

#define FW_NORMAL  400                // Font Weight
#define FW_BOLD    700

#define DRAWLINE  chr(08)                   // Irrevant for ESC/POS but useful for Win32Prn
#define PRN_GREEN 'GREEN'
#define PRN_BLACK 'BLACK'

#define P_BIGFONTSIZE           24
#define P_VERYBIGFONTSIZE       36
#define P_BIGFONTWIDTH          100    // Pixels?

#define FORM_A4         9
#define FORM_LETTER     1

#define PS_SOLID        0

#define P_BLACK          RGB( 0x0 ,0x0 ,0x0  )
#define P_BLUE           RGB( 0x0 ,0x0 ,0x85 )
#define P_GREEN          RGB( 0x0 ,0x85,0x0  )
#define P_CYAN           RGB( 0x0 ,0x85,0x85 )
#define P_RED            RGB( 0x85,0x0 ,0x0  )
#define P_MAGENTA        RGB( 0x85,0x0 ,0x85 )
#define P_BROWN          RGB( 0x85,0x85,0x0  )
#define P_WHITE          RGB( 0xC6,0xC6,0xC6 )

#define NEWLINE        .t.
#define NONEWLINE      .f.

#define RPT_SPACE   { 'space(10)', ' ', 1, 0, FALSE}

#define VBTRUE          -1
#define VBFALSE          0
#define VBUSEDEFAULT    -2

#define C_NORMAL        1
#define C_INVERSE       2
#define C_BRIGHT        3
#define C_MAUVE         4
#define C_GREY          5
#define C_YELLOW        6
#define C_GREEN         7
#define C_CYAN          8
#define C_BLUE          9
#define C_RED           10

#define BY_CONNO        1
#define BY_DEPOSIT      2
#define BY_NATURAL      0

// Global Colour defines for Tbrowse objs
#define TB_COLOR  'W/BG, N/W, W/R, +GR/R, N/BG, +W/BG, W/RB, +GR/RB,' + ;
                  'R/B, +W/B, W/G, +GR/G, R/W, B/W, W/GR, +GR/GR'

#define HEADSEP 'Í'
#define COLSEP '³'

#xcommand DEFAULT <v1> TO <x1> [, <vn> TO <xn> ]                 ;
   =>                                                            ;
   IF <v1> == NIL ; <v1> := <x1> ; END                           ;
   [; IF <vn> == NIL ; <vn> := <xn> ; END ]
  
#define SITELEN 2                 // Length of Site Code
#define ASSET_CODE_LEN 10         // Just in case someone has a ridiculous field len
#define OWNER_CODE_LEN 3          // Length of Owner Code
#define ID_FIELD_LEN 10			  // Default Character ID Field Length

#ifdef DEBUG
 #define LICENSEE "Debug"
 #define INSURANCE
 #define STOCKTAKE

#endif

#ifndef LICENSEE
 #define LICENSEE "Bluegum Software"

#endif
 
// Global but ephemeral variables
#define SYSPATH      1
#define ENQ_STATUS   2
#define IS_SPOOLING  3
#define SYSDATE      4
#define TRAN_AUDIT   5
#define BDATE        6 
#define HEAD_STR     7 
#define LINE_CNT     8 
#define PAGE_NO      9 
#define BATCH_TOT    10
#define CONTRACT     11
#define OPERCODE     12
#define OPERNAME     13
#define TEMPFILE     14   // Creates a unique tempfile name for each session
#define LASTITEM     15   // Last Item code used
#define LASTCONT     16   // Last Contract Number
#define AUDITPTR     17

// Global Variables - Should map to the globalvars.dbf file
#define B_ADDRESS1     1
#define B_ADDRESS2     2
#define B_SUBURB       3
#define B_PCODE        4
#define B_PHONE        5
#define B_DEF_OWNER    6
#define B_EOM          7
#define B_EOY          8
#define B_PRINTER1     9
#define B_PRINTER2     10
#define B_EDITOR       11   // Name of Editor to use for Print to screen
#define B_COMPANY      12   // Company Name

// Nodes Data - this makes it easy to call the right field in an array. Should map to the nodes.dbf file
#define L_NODE           1
#define L_PRINTER        2
#define L_REPORT_NAME    3
#define L_BARCODE_NAME   4
#define L_COLATTR        5
#define L_BACKGR         6
#define L_SHADOW         7
#define L_GOOD           8
#define L_BAD            9

#define BOND_REFUND      'R'
#define BOND_PAYMENT     'B'
#define RENTAL_PAYMENT   'P'
#define MISC_DEBIT       'D'
#define MISC_CREDIT      'C'
#define ARREARS_PAYMENT  'A'
#define ARREARS_DEBIT    'E'
#define MISC_PAYMENT     'N'
#define RENTAL_INSTALL   'Z'
#define LATE_PAYMENT_FEE 'L'
#define ITEM_ADDED       'I'
#define CONTRACT_DELETED 'X'
#define CONTRACT_ADDED   'Y'
#define DELIVERY_FEE     'V'
#define MACHINE_DELETED  'M'
#define MACHINE_MOVEMENT 'T'
#define ITEM_FILE_CHANGED 'Q'

#define X_SUPERVISOR   1
#define X_ENQUIRE      2
#define X_FILE         3
#define X_TRANSACTION  4
#define X_REPORT       5
#define X_EOD          6
#define X_UTILITY      7
#define X_ADDFILES     8
#define X_EDITFILES    9
#define X_DELFILES     10
#define X_STOCKTAKE    11

#define MB_OK                       0
#define MB_OKCANCEL                 1
#define MB_ABORTRETRYIGNORE         2
#define MB_YESNOCANCEL              3
#define MB_YESNO                    4
#define MB_RETRYCANCEL              5

#define MB_RET_OK                   1
#define MB_RET_YES                  6
#define MB_RET_NO                   7

