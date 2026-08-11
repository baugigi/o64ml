;; ——————————————————————————————————————————————————————————————————————
;; Progetto BreadCaml / The BreadCaml Project
;; Copyright (C) 21-Apr-2026 Piero Furiesi
;; 
;; Questo  programma  è software  libero;  può  essere ridistribuito  e/o
;; modificato nei termini della licenza GNU GPL ver. 2,  come specificato
;; nel file LICENZA-it nella cartella principale del progetto.
;; 
;; This program is  free software; you can redistribute  it and/or modify
;; it under the terms of the GNU  General Public License (GPL) ver. 2, as
;; specified in the LICENSE-en file in the project root folder.
;; ——————————————————————————————————————————————————————————————————————
;;; ----------------------------------------------------------------------------
;;;   ZP ADDRESSES, BASIC V2 & KERNAL REL.3 ROUTINES, VECTORS, POINTERS, ETC.
;;; ----------------------------------------------------------------------------

!address {
        ;; Default address space
C64_VICSCN      = $0400 ;Start address of 1024 Byte Screen Memory Area
C64_BASRAM      = $0800 ;Start address of BASIC RAM - should be $00
C64_BASROM      = $A000 ;Start address of BASIC ROM (Vector: BASIC cold start)
C64_HIRAM       = $C000 ;Start address of free high RAM area
C64_IOROM       = $D000 ;Start address of I/O ROM
C64_KERROM      = $E000 ;Start address of Kernal ROM
                
        ;; Zeropage
	;; Free locations: C64_UNUSZP (1 by.), C64_FREKZP (4 by.)
C64_D6510       = $00   ;Data Direction register
C64_R6510       = $01   ;Data buffer
C64_UNUSZP      = $02   ;UNUSED
C64_ADRAY1      = $03   ;-$04 Jump Vector: Convert Integer--Floating
C64_ADRAY2      = $05   ;-$06 Jump Vector: Convert Integer--Floating
C64_CHARAC      = $07   ;Search Character
C64_ENDCHR      = $08   ;Flag: Scan for Quote at End of String
C64_TRMPOS      = $09   ;Screen Column From Last TAB
C64_VERCK       = $0A   ;Flag: 0 = Load, 1 = Verify
C64_COUNT       = $0B   ;Input Buffer Pointer / No. of Subscripts
C64_DIMFLG      = $0C   ;Flag: Default Array DiMension
C64_VAUYP       = $0D   ;Data Type: $FF = String, $00 = Numeric
C64_INTFLG      = $0E   ;Data Type: $80 = Integer, $00 = Floating
C64_GARBFL      = $0F   ;Flag: DATA scan/LlST quote/Garbage Coll
C64_SUBFLG      = $10   ;Flag: Subscript Ref / User Function Call
C64_INPFLG      = $11   ;Flag: $00 = INPUT, $40 = GET, $98 = READ
C64_TANSGN      = $12   ;Flag TAN sign / Comparison Result
C64_CHANNL      = $13   ;Current I/O Channel (CMD Logical File) Number
C64_LINNUM      = $14   ;-$15 Temp: Integer Value
C64_TEMPPT      = $16   ;Pointer Temporary String
C64_LASTPT      = $17   ;-$18 Last Temp String Address
C64_TEMPST      = $19   ;-$21 Stack for Temporary Strings
C64_INDEX       = $22   ;Utility Pointer Area
C64_INDEX1      = $22   ;-$23 First Utility Pointer.
C64_INDEX2      = $24   ;-$25 Second Utility Pointer.
C64_RESHO       = $26   ;-$2A Floating-Point Product of Multiply
C64_TXTTAB      = $2B   ;-$2C Pointer: Start of BASIC Text
C64_VARTAB      = $2D   ;-$2E Pointer: Start of BASIC Variables
C64_ARYTAB      = $2F   ;-$30 Pointer: Start of BASIC Arrays
C64_STREND      = $31   ;-$32 Pointer: End of BASIC Arrays (+1)
C64_FRETOP      = $33   ;-$34 Pointer: Bottom of String Storage
C64_FRESPC      = $35   ;-$36 Utility String Pointer
C64_BASSIZ      = $37   ;-$38 Pointer: Highest Address Used by BASIC
C64_CURLIN      = $39   ;-$3A Current BASIC Line Number
C64_OLDLIN      = $3B   ;-$3C Previous BASIC Line Number
C64_OLDTXT      = $3D   ;-$3E Pointer: BASIC Statement for CONT
C64_DATLIN      = $3F   ;-$40 Current DATA Line Number
C64_DATPTR      = $41   ;-$42 Pointer: Current DATA Item Address
C64_INPPTR      = $43   ;-$44 Vector: INPUT Routine 
C64_VARNAM      = $45   ;-$46 Current BASIC Variable Name
C64_VARPNT      = $47   ;-$48 Pointer: Current BASIC Variable Data(FOUT uses it)
C64_FORPNT      = $49   ;-$4A Pointer: Index Variable for FOR/NEXT
C64_VARTXT      = $4B   ;-$4C Temp storage for TXTPTR during READ, INPUT, GET.
C64_OPMASK      = $4D   ;Mask used during FRMEVL.
C64_TEMPF3      = $4E   ;-$52 Temporary storage for FLPT value.
C64_FOUR6       = $53   ;Length of String Variable during Garbege collection.
C64_JMPER       = $54   ;-$56 JMP used in fun Eval - followed by fun address
C64_TEMPF0      = $56   ;used by FLPT addition, subtraction and exp routines.
C64_TEMPF1      = $57   ;-$5B Temporary storage for FLPT value.
C64_TEMPF2      = $5C   ;-$60 Temporary storage for FLPT value.
C64_FAC         = $61   ;FP Accumulator (6 bytes: 1 exp, 4 mantissa, 1 sign)
C64_FACEXP      = $61   ;Floating-Point Accumulator #1: Exponent
C64_FACHO       = $62   ;-$65 Floating Accum. #1: Mantissa
C64_FACSGN      = $66   ;Floating Accum. #1: Sign
C64_SGNFLG      = $67   ;Pointer: Series Evaluation Constant
C64_BITS        = $68   ;Floating Accum. #1: Overflow Digit
C64_ARG         = $69   ;FP Argument (6 bytes: 1 exp, 4 mantissa, 1 sign)
C64_ARGEXP      = $69   ;Floating-Point Accumulator #2: Exponent
C64_ARGHO       = $6A   ;-$6D Floating Accum. #2: Mantissa
C64_ARGSGN      = $6E   ;Floating Accum. #2: Sign
C64_ARISGN      = $6F   ;Sign Comparison Result: Accum. #1 vs #2
C64_FACRND      = $70   ;Floating Accum. #1. Low-Order (Rounding)
C64_FBUFPT      = $71   ;-$72 Pointer: Cassette Buffer
C64_CHRGET      = $73   ;-$8A Subroutine: Get Next Byte of BASIC Text
C64_CHRGOT      = $79   ;Entry to Get Same Byte of Text Again
C64_CHRPTR      = $7A   ;Ptr to current byte in BASIC prg or direct command.
C64_RNDX        = $8B   ;-$8F Floating RND Function Seed Value
C64_STATUS      = $90   ;Kernal I/O Status Word: ST
C64_STKEY       = $91   ;Flag: STOP key / RVS key
C64_SVXT        = $92   ;Timing Constant for Tape
C64_VERCK2      = $93   ;Flag: 0 = Load, 1 = Verify
C64_C3PO        = $94   ;Flag: Serial Bus-Output Char. Buffered
C64_BSOUR       = $95   ;Buffered Character for Serial Bus
C64_SYNO        = $96   ;Cassette Sync No.
C64_XSAV        = $97   ;Temp Data Area
C64_LDTND       = $98   ;No. of Open Files / Index to File Table
C64_DFLTN       = $99   ;Default Input Device (0)
C64_DFLTO       = $9A   ;Default Output (CMD) Device (3)
C64_PRTY        = $9B   ;Tape Character Parity
C64_PSW         = $9C   ;Flag: Tape Byte-Received
C64_MSGFLG      = $9D   ;Flag: $80 = Direct Mode, $00 = Program
C64_PTR1        = $9E   ;Tape Pass 1 Error Log
C64_PTR2        = $9F   ;Tape Pass 2 Error Log
C64_TIME        = $A0   ;-$A2 Real-Time Jiffy Clock (approx) 1/60 Sec
C64_R2D2_PCNTR  = $A3   ;Serial Bus EOI/Bit Counter Tape Read or Write
C64_BSOUR1_FIRT = $A4   ;Serial Bus shift Counter/Pulse Counter Tape Read
C64_CNTDN       = $A5   ;Cassette Sync Countdown
C64_BUFPNT      = $A6   ;Pointer: Tape I/O Buffer
C64_INBIT       = $A7   ;RS-232 Input Bits / Cassette Temp
C64_BITCI       = $A8   ;RS-232 Input Bit Count / Cassette Temp
C64_RINONE      = $A9   ;RS-232 Flag: Check for Start Bit
C64_RIDATA      = $AA   ;RS-232 Input Byte Buffer/Cassette Temp
C64_RIPRTY      = $AB   ;RS-232 Input Parity / Cassette Short Cnt
C64_SAL         = $AC   ;-$AD Pointer: Tape Buffer/ Screen Scrolling
C64_EAL         = $AE   ;-$AF Tape End Addresses/End of Program
C64_CMP0        = $B0   ;-$B1 Tape Timing Constants
C64_TAPE1       = $B2   ;-$B3 Pointer: Start of Tape Buffer
C64_BITTS       = $B4   ;RS-232 Out Bit Count / Cassette Temp
C64_NXTBIT      = $B5   ;RS-232 Next Bit to Send/ Tape EOT Flag
C64_RODATA      = $B6   ;RS-232 Out Byte Buffer
C64_FNLEN       = $B7   ;Length of Current File Name
C64_LA          = $B8   ;-$B9 Current Logical File Number
C64_FA          = $BA   ;Current Device Number
C64_FNADR       = $BB   ;-$BC Pointer: Current File Name
C64_ROPRTY      = $BD   ;RS-232 Out Parity / Cassette Temp
C64_FSBLK       = $BE   ;Cassette Read / Write Block Count
C64_MYCH        = $BF   ;Serial Word Buffer
C64_CAS1        = $C0   ;Tape Motor Interlock
C64_STAL        = $C1   ;-$C2 I/O Start Address
C64_MEMUSS      = $C3   ;-$C4 Tape Load Temps
C64_LSTX        = $C5   ;Current Key Pressed: CHR$(n)  No Key
C64_NDX         = $C6   ;No. of Chars. in Keyboard Buffer (Queue)
C64_RVS         = $C7   ;Flag: Print Reverse Chars. -1=Yes, 0=No Used
C64_INDX        = $C8   ;Pointer: End of Logical Line for INPUT
C64_LXSP        = $C9   ;-$CA Cursor X-Y Pos. at Start of INPUT
C64_SFDX        = $CB   ;Flag: Print Shifted Chars.
C64_BLNSW       = $CC   ;Cursor Blink enable: 0 = Flash Cursor
C64_BLNCT       = $CD   ;Timer: Countdown to Toggle Cursor
C64_GDBLN       = $CE   ;Character Under Cursor
C64_BLNON       = $CF   ;Flag: Last Cursor Blink On/Off
C64_CRSW        = $D0   ;Flag: INPUT or GET from Keyboard
C64_PNT         = $D1   ;-$D2 Pointer: Current Screen Line Address
C64_PNTR        = $D3   ;Cursor Column on Current Line
C64_QTSW        = $D4   ;Flag: Editor in Quote Mode, $00 = NO
C64_LNMX        = $D5   ;Physical Screen Line Length
C64_TBLX        = $D6   ;-$D7 Current Cursor Physical Line Number
C64_INSRT       = $D8   ;Flag: Insert Mode, >0 = # INSTs
C64_LDTB1       = $D9   ;-$F2 Screen Line Link Table / Editor Temps
C64_USER        = $F3   ;-$F4 Pointer: Current Screen Color RAM loc.
C64_KEYTAB      = $F5   ;-$F6 Vector Keyboard Decode Table
C64_RIBUF       = $F7   ;-$F8 RS-232 Input Buffer Pointer
C64_ROBUF       = $F9   ;-$FA RS-232 Output Buffer Pointer
C64_FREKZP      = $FB   ;-$FE Free ZP Space for User Programs
C64_BASZPT      = $FF   ;BASIC Temp Data Area

        ;; Other BASIC/Kernal variables
C64_BAD         = $0100 ;Tape Input Error Log
C64_BUF         = $0200 ;System INPUT Buffer
C64_LAT         = $0259 ;Kernal Table: Active Logical File No's.
C64_FAT         = $0263 ;Kernal Table: Device No. for Each File
C64_SAT         = $026D ;Kernal Table: Second Address Each File
C64_KEYD        = $0277 ;Keyboard Buffer Queue (FIFO)
C64_MEMSTR      = $0281 ;Pointer: Bottom of Memory for O.S.
C64_MEMSIZ      = $0283 ;Pointer: Top of Memory for O.S.
C64_TIMOUT      = $0285 ;Flag: Kernal Variable for IEEE Timeout
C64_COLOR       = $0286 ;Current Character Color Code
C64_GDCOL       = $0287 ;Background Color Under Cursor
C64_HIBASE      = $0288 ;Top of Screen Memory (Page)
C64_XMAX        = $0289 ;Size of Keyboard Buffer
C64_RPTFLG      = $028A ;Flag: REPEAT Key Used, $80 = Repeat
C64_KOUNT       = $028B ;Repeat Speed Counter
C64_DELAY       = $028C ;Repeat Delay Counter
C64_SHFLAG      = $028D ;Flag: Keyb'rd SHIFT Key/CTRL Key/C= Key
C64_LSTSHF      = $028E ;Last Keyboard Shift Pattern
C64_KEYLOG      = $028F ;Vector: Keyboard Table Setup
C64_MODE        = $0291 ;Flag: $00=Disable SHIFT Keys, $80 = Enable SHIFT Keys
C64_AUTODN      = $0292 ;Flag: Auto Scroll Down, 0 = ON
C64_M51CTR      = $0293 ;RS-232: 6551 Control Register Image
C64_MS1CDR      = $0294 ;RS-232: 6551 Command Register Image
C64_M51AJB      = $0295 ;RS-232 Non-Standard BPS (Time/2-100) USA
C64_RSSTAT      = $0297 ;RS-232: 6551 Status Register Image
C64_BITNUM      = $0298 ;RS-232 Number of Bits Left to Send
C64_BAUDOF      = $0299 ;RS-232 Baud Rate: Full Bit Time (us)
C64_RIDBE       = $029B ;RS-232 Index to End of Input Buffer
C64_RIDBS       = $029C ;RS-232 Start of Input Buffer (Page)
C64_RODBS       = $029D ;RS-232 Start of Output Buffer (Page)
C64_RODBE       = $029E ;RS-232 Index to End of Output Buffer
C64_IRQTMP      = $029F ;Holds IRQ Vector During Tape I/O
C64_ENABL       = $02A1 ;RS-232 Enables
C64_CASTON      = $02A2 ;TOD Sense During Cassette I/O
C64_KIKA26      = $02A3 ;Temp Storage For Cassette Read
C64_STUPID      = $02A4 ;Temp D1 IRQ Indicator For Cassette Read
C64_LINTMP      = $02A5 ;Temp For Line Index
C64_PALNTS      = $02A6 ;PAL/NTSC Flag, O=NTSC, 1=PAL

        ;; Vectors for some BASIC and Kernal routines
C64_IERROR      = $0300 ;Vector: BASIC Print Error Mesg Routine (default $E38B)
C64_IMAIN       = $0302 ;Vector: BASIC Program loop (default $A483)
C64_ICRNCH      = $0304 ;Vector: BASIC CRUNCH Routine (default $A57C)
C64_IQPLOP      = $0306 ;Vector: BASIC QPLOP Routine (default $A71A)
C64_IGONE       = $0308 ;Vector: BASIC GONE Routine (default $A7E4)
C64_IEVAL       = $030A ;Vector: BASIC EVAL Routine (default $AE86)
C64_SAREG       = $030C ;Storage Area for SYS -- Accumulator
C64_SXREG       = $030D ;Storage Area for SYS -- X Register
C64_SYREG       = $030E ;Storage Area for SYS -- Y Register
C64_SPREG       = $030F ;Storage Area for SYS -- Processor Status
C64_USRPOK      = $0310 ;JMP Instruction for USR command ($4C)
C64_USRADD      = $0311 ;Address of USR routine (default: $B248, FCERR)
C64_UNUSED      = $0313 ;UNUSED
C64_CINV        = $0314 ;Vector: Kernal IRQ Routine (default $EA31)  
C64_CBINV       = $0316 ;Vector: Kernal BRK Routine (default $FE66)  
C64_NMINV       = $0318 ;Vector: Kernal NMI Routine (default $FE47)  
C64_IOPEN       = $031A ;Vector: Kernal OPEN Routine (default $F34A)  
C64_ICLOSE      = $031C ;Vector: Kernal CLOSE Routine (default $F291)  
C64_ICHKIN      = $031E ;Vector: Kernal CHKIN Routine (default $F20E)  
C64_ICHKOUT     = $0320 ;Vector: Kernal CHKOUT Routine (default $F250)
C64_ICLRCHN     = $0322 ;Vector: Kernal CLRCHN Routine (default $F333)  
C64_ICHRIN      = $0324 ;Vector: Kernal CHRIN Routine (default $F157)  
C64_ICHROUT     = $0326 ;Vector: Kernal CHROUT Routine (default $F1CA)  
C64_ISTOP       = $0328 ;Vector: Kernal STOP Routine (default $F6ED)
C64_IGETIN      = $032A ;Vector: Kernal GETIN Routine (default $F13E)  
C64_ICLALL      = $032C ;Vector: Kernal CLALL Routine (default $F32F)  
C64_USRCMD      = $032E ;Vector: BASIC User-Defined Command (default $FE66)
C64_ILOAD       = $0330 ;Vector: Kernal LOAD Routine (default $F49E)  
C64_ISAVE       = $0332 ;Vector: Kernal SAVE Routine (default $F5DD)
C64_TBUFFR      = $033C ;Tape I/O Buffer 

        ;; BASIC Floating point routines
	;; BEWARE: MULTIPLY BUG! See https://www.c64-wiki.com/wiki/Multiply_bug

        ;; Movement
C64_MOVFM       = $BBA2 ;Load FAC from MEM (A/Y). Returns Y=0,A=exp,fl=exp.
C64_CONUPK      = $BA8C ;Load ARG from MEM (A/Y), set ARISIGN and A:=FAC exp.
C64_MOVAF       = $BC0C ;Copy (rounded) FAC to ARG.
C64_MOVMF       = $BBD4 ;Copy (rounded) FAC to MEM (X/Y). Returns A=FAC exp.
C64_MOVEF       = $BC0F ;Copy FAC to ARG without rounding. 
C64_MOVFA       = $BBFC ;Copy ARG to FAC
        ;; Basic Arithmetic
C64_FADD        = $B867 ;FAC := MEM (A/Y) + FAC 
C64_FADDT       = $B86A ;FAC := ARG + FAC
C64_FSUB        = $B850 ;FAC := MEM (A/Y) - FAC 
C64_FSUBT       = $B853 ;FAC := ARG - FAC
C64_FMUL        = $BA28 ;FAC := MEM (A/Y) * FAC 
C64_FMULT       = $BA2B ;FAC := ARG * FAC
C64_MUL10       = $BAE2 ;Quickly multiply the float held in FAC by 10.
C64_FDIV        = $BB0F ;FAC := MEM (A/Y) / FAC, ARG := remainder.
C64_FDIVT       = $BB12 ;FAC := ARG / FAC, ARG := remainder
C64_DIV10       = $BAFE ;FAC := ABS(FAC / 10).
C64_NEGOP       = $BFB4 ;Switch sign on the float in FAC, if non-zero
        ;; Trigonometry
C64_SIN         = $E26B ;Perform the SIN function on the float in FAC
C64_COS         = $E264 ;Perform the COS function on the float in FAC
C64_TAN         = $E2B4 ;Perform the TAN function on the float in FAC
C64_ATN         = $E30E ;Perform the ATN function on the float in FAC
        ;; Logarithms
C64_LOG         = $B9EA ;FAC := ln FAC
C64_EXP         = $BFED ;FAC := e ^ FAC
C64_FPWR        = $BF78 ;FAC := MEM (A/Y) ^ FAC.
C64_FPWRT       = $BF7B ;FAC := ARG ^ FAC.
C64_SQR         = $BF71 ;FAC := FAC ^ 0.5
C64_SQRARG      = $BF74 ;FAC := ARG ^ 0.5
        ;; Other functions
C64_FADDH       = $B849 ;Add .5 to FAC
C64_SIGN        = $BC2B ;Sets flags N,Z depending on whether FAC is 0, + or -.
C64_ABS         = $BC58 ;Perform the ABS function on the float in FAC
C64_INT         = $BCCC ;Perform the INT function on the float in FAC
C64_FCOMP       = $BC5B ;Compare FAC and MEM (A/Y). A = 0 (=), 1 (>), -1 (<).
        ;; Type Conversion
C64_FOUT        = $BDDD ;Convert float in FAC to a string at $100 (also in A/Y)
C64_STRVAL      = $B7B5 ;Convert a string ($22/$23, A=length) to float in FAC.  
C64_FIN         = $BCF3 ;Convert a 0-terminated string $7A/$7B to float in FAC
                        ;(CHRGOT needed before, or LDA# 1st chr and CLC.)
C64_FLOATS      = $BC44 ;Conv. 16bit signed int $62 BIG-ENDIAN to float in FAC.
C64_GIVAYF      = $B391 ;Convert 16bit signed int (Y=lo/A=hi) to float in FAC.
C64_FLOAT       = $BC3C ;Convert 8bit unsigned int in A to float in FAC.
C64_SNGFLT      = $B3A2 ;Convert 8bit unsigned int in Y to float in FAC.
C64_FACINX      = $B1AA ;Convert float in FAC to 16bit signed int (Y=lo/A=hi).
C64_QINT        = $BC9B ;Conv. float in FAC to 32bit signed int $62 BIG-ENDIAN.
C64_FADFLT      = $B8D2 ;Normalize value in FAC;(SEC(+)/CLC(-) needed before.)
        ;; Polynomials
C64_POLY1       = $E043 ;Evaluate a polynomial with odd powers only, for FAC
C64_POLY2       = $E059 ;Evaluate a polynomial with odd & even powers, for FAC
        ;; Constants
C64_PI          = $AEA8 ;constant  3.14159265   = pi
C64_MININT      = $B1A5 ;constant -32768
C64_ONE         = $B9BC ;constant  1
C64_LOGPLY1     = $B9C2 ;constant  .434255942
C64_LOGPLY2     = $B9C7 ;constant  .576584541
C64_LOGPLY3     = $B9CC ;constant  .961800759
C64_LOGPLY4     = $B9D1 ;constant  2.88539007
C64_SQRHALF     = $B9D6 ;constant  .707106781   = sqrt 0.5
C64_SQR2        = $B9DB ;constant  1.41421356   = sqrt 2
C64_MHALF       = $B9E0 ;constant -.5           = -1/2
C64_LOG2        = $B9E5 ;constant  .693147181   = ln 2
C64_TEN         = $BAF9 ;constant  10
C64_HMLNM01     = $BDB3 ;constant  99999999.9   (one hundred million -0.1)
C64_1BLNM1      = $BDB8 ;constant  999999999    (one billion -1)
C64_1BLN        = $BDBD ;constant  1000000000   (one billion)
C64_HALF        = $BF11 ;constant  .5           = 1/2
C64_M100MLN     = $BF16 ;constant -100000000    (minus one hundred million)
C64_10MLN       = $BF1A ;constant  10000000     (ten millions)
C64_M1MLN       = $BF1E ;constant -1000000      (minus one million)
C64_100000      = $BF22 ;constant  100000
C64_M10000      = $BF26 ;constant -10000
C64_1000        = $BF2A ;constant  1000
C64_M100        = $BF2E ;constant -100
C64_10          = $BF32 ;constant  10
C64_M1          = $BF36 ;constant -1
C64_M10HOUR     = $BF3A ;constant -2160000      -10 hours (in 1/60 sec)
C64_1HOUR       = $BF3E ;constant  216000       1 hour (in 1/60 sec)
C64_M10MIN      = $BF42 ;constant -36000        -10 min (in 1/60 sec)
C64_1MIN        = $BF46 ;constant  3600         1 min (in 1/60 sec)
C64_M10SEC      = $BF4A ;constant -600          -10 sec (in 1/60 sec)
C64_1SEC        = $BF4E ;constant  60           1 sec (in 1/60 sec)
C64_LOG2M1      = $BFBF ;constant  1.44269504   = (ln 2)^(-1)
C64_EXPPLY1     = $BFC5 ;constant  2.14987637E-05
C64_EXPPLY2     = $BFCA ;constant  1.43523140E-04
C64_EXPPLY3     = $BFCF ;constant  1.34226348E-03
C64_EXPPLY4     = $BFD4 ;constant  9.61401701E-03
C64_EXPPLY5     = $BFD9 ;constant  .0555051269
C64_EXPPLY6     = $BFDE ;constant  .240226385
C64_EXPPLY7     = $BFE3 ;constant  .693147186   = (ln 2)/2
C64_EXPPLY8     = $BFE8 ;constant  1
C64_RANDOM1     = $E08D ;constant  11879546
C64_RANDOM2     = $E092 ;constant  3.92767774E-08
C64_PIHALF      = $E2E0 ;constant  1.57079633   = pi/2
C64_TWOPI       = $E2E5 ;constant  6.28318531   = 2*pi
C64_QUARTER     = $E2EA ;constant  .25          = 1/4
C64_SINPLY1     = $E2F0 ;constant -14.3813907
C64_SINPLY2     = $E2F5 ;constant  42.0077971
C64_SINPLY3     = $E2FA ;constant -76.7041703
C64_SINPLY4     = $E2FF ;constant  81.6052237
C64_SINPLY5     = $E304 ;constant -41.3147021
C64_SINPLY6     = $E309 ;constant  6.28318531   = 2*pi
C64_ATNPLY1     = $E33F ;constant -6.84793912E-04
C64_ATNPLY2     = $E344 ;constant  4.85094216E-03
C64_ATNPLY3     = $E349 ;constant -.0161117018
C64_ATNPLY4     = $E34E ;constant  .034209638
C64_ATNPLY5     = $E353 ;constant -.0542791328
C64_ATNPLY6     = $E358 ;constant  .0724571965
C64_ATNPLY7     = $E35D ;constant -.0898023954
C64_ATNPLY8     = $E362 ;constant  .110932413
C64_ATNPLY9     = $E367 ;constant -.142839808
C64_ATNPLYA     = $E36C ;constant  .19999912
C64_ATNPLYB     = $E371 ;constant -.333333316
C64_ATNPLYC     = $E376 ;constant 1

        ;; Other useful BASIC/Kernal routines
C64_DSPP        = $EA13 ;Put char(A) and color(X) onto screen, blink delay <- 2.
C64_ERROR       = $E38B ;Print an error string (error code in A).
C64_RESET       = $FCE2 ;Reset routine, see C64_HW_RESET
        ;; Input
;C64_CHRGET     = $0073 ;in Zeropage - Get next byte of BASIC text
C64_INITAT      = $E3A2 ;CHRGET routine in ROM
C64_GETBYTC     = $B79B ;CHRGET uint8 to X (range checking)
C64_LINGET      = $A96B ;CHRGET uint16 (0-63999) to $14-$15
C64_CHKOPN      = $AEFA ;Check for and skip open paren (syntax error otherwise)
C64_CHKCLS      = $AEF7 ;Check for and skip close paren (syntax error otherwise)
C64_CHKCOM      = $AEFD ;Check for and skip comma (syntax error otherwise)
C64_SYNCHR      = $AEFF ;Check for and skip char in A (syntax error otherwise)
C64_COMINT      = $E200 ;Skip comma and get int8 in X
        ;; Output
C64_STROUT      = $AB1E ;Print zero-terminated string @ <A >Y
C64_LINPRT      = $BDCD ;Print uint16 <X >A
C64_QPLOP       = $A717 ;Print BASIC token from A

        ;; Kernal jump table
C64_KACPTR      = $FFA5 ;JMP C64_ACPTR
C64_KCHKIN      = $FFC6 ;JMP(C64_ICHKIN)
C64_KCHKOUT     = $FFC9 ;JMP(C64_ICHKOUT)
C64_KCHRIN      = $FFCF ;JMP(C64_ICHRIN)
C64_KCHROUT     = $FFD2 ;JMP(C64_ICHROUT)
C64_KCINT       = $FF81 ;JMP C64_CINT
C64_KCIOUT      = $FFA8 ;JMP C64_CIOUT
C64_KCLALL      = $FFE7 ;JMP(C64_ICLALL)
C64_KCLOSE      = $FFC3 ;JMP(C64_ICLOSE)
C64_KCLRCHN     = $FFCC ;JMP(C64_ICLRCHN)
C64_KGETIN      = $FFE4 ;JMP(C64_IGETIN)
C64_KIOBASE     = $FFF3 ;JMP C64_IOBASE
C64_KIOINIT     = $FF84 ;JMP C64_IOINIT
C64_KLISTEN     = $FFB1 ;JMP C64_LISTEN
C64_KLOAD       = $FFD5 ;JMP(C64_ILOAD)
C64_KMEMBOT     = $FF9C ;JMP C64_MEMBOT
C64_KMEMTOP     = $FF99 ;JMP C64_MEMTOP
C64_KOPEN       = $FFC0 ;JMP(C64_IOPEN)
C64_KPLOT       = $FFF0 ;JMP C64_PLOT
C64_KRAMTAS     = $FF87 ;JMP C64_RAMTAS
C64_KRDTIM      = $FFDE ;JMP C64_RDTIM
C64_KREADST     = $FFB7 ;JMP C64_READST
C64_KRESTOR     = $FF8A ;JMP C64_RESTOR
C64_KSAVE       = $FFD8 ;JMP(C64_ISAVE)
C64_KSCNKEY     = $FF9F ;JMP C64_SCNKEY
C64_KSCREEN     = $FFED ;JMP C64_SCREEN
C64_KSECOND     = $FF93 ;JMP C64_SECOND
C64_KSETLFS     = $FFBA ;JMP C64_SETLFS
C64_KSETMSG     = $FF90 ;JMP C64_SETMSG
C64_KSETNAM     = $FFBD ;JMP C64_SETNAM
C64_KSETTIM     = $FFDB ;JMP C64_SETTIM
C64_KSETTMO     = $FFA2 ;JMP C64_SETTMO
C64_KSTOP       = $FFE1 ;JMP(C64_ISTOP)
C64_KTALK       = $FFB4 ;JMP C64_TALK
C64_KTKSA       = $FF96 ;JMP C64_TKSA
C64_KUDTIM      = $FFEA ;JMP C64_UDTIM
C64_KUNLSN      = $FFAE ;JMP C64_UNLSN
C64_KUNTLK      = $FFAB ;JMP C64_UNTLK
C64_KVECTOR     = $FF8D ;JMP C64_VECTOR

        ;; Actual entry points for Kernal routines
C64_ACPTR       = $EE13
C64_CHKIN       = $F20E
C64_CHKOUT      = $F250
C64_CHRIN       = $F157
C64_CHROUT      = $F1CA
C64_CINT        = $FF5B
C64_CIOUT       = $EDDD
C64_CLALL       = $F32F
C64_CLOSE       = $F291
C64_CLRCHN      = $F333
C64_GETIN       = $F13E
C64_IOBASE      = $E500
C64_IOINIT      = $FDA3
C64_LISTEN      = $ED0C
C64_LOAD        = $F49E
C64_MEMBOT      = $FE34
C64_MEMTOP      = $FE25
C64_OPEN        = $F34A
C64_PLOT        = $E50A
C64_RAMTAS      = $FD50
C64_RDTIM       = $F6DD
C64_READST      = $FE07
C64_RESTOR      = $FD15
C64_SAVE        = $F5DD
C64_SCNKEY      = $EA87
C64_SCREEN      = $E505
C64_SECOND      = $EDB9
C64_SETLFS      = $FE00
C64_SETMSG      = $FE18
C64_SETNAM      = $FDF9
C64_SETTIM      = $F6E4
C64_SETTMO      = $FE21
C64_STOP        = $F6ED
C64_TALK        = $ED09
C64_TKSA        = $EDC7
C64_UDTIM       = $F69B
C64_UNLSN       = $EDFE
C64_UNTLK       = $EDEF
C64_VECTOR      = $FD1A

        ;; System hardware vectors
C64_HW_NMI      = $FFFA ;normally $FF43
C64_HW_RESET    = $FFFC ;normally $FCE2 = C64_RESET
C64_HW_IRQ      = $FFFE ;normally $FF48

        ;; VIC-II registers (? = unused bits, read back 1)
C64_VIC_M0X     = $D000 ;(R/W)  Sprite 0 X-pos
C64_VIC_M0Y     = $D001 ;(R/W)  Sprite 0 Y-pos
C64_VIC_M1X     = $D002 ;(R/W)  Sprite 1 X-pos
C64_VIC_M1Y     = $D003 ;(R/W)  Sprite 1 Y-pos
C64_VIC_M2X     = $D004 ;(R/W)  Sprite 2 X-pos
C64_VIC_M2Y     = $D005 ;(R/W)  Sprite 2 Y-pos
C64_VIC_M3X     = $D006 ;(R/W)  Sprite 3 X-pos
C64_VIC_M3Y     = $D007 ;(R/W)  Sprite 3 Y-pos
C64_VIC_M4X     = $D008 ;(R/W)  Sprite 4 X-pos
C64_VIC_M4Y     = $D009 ;(R/W)  Sprite 4 Y-pos
C64_VIC_M5X     = $D00A ;(R/W)  Sprite 5 X-pos
C64_VIC_M5Y     = $D00B ;(R/W)  Sprite 5 Y-pos
C64_VIC_M6X     = $D00C ;(R/W)  Sprite 6 X-pos
C64_VIC_M6Y     = $D00D ;(R/W)  Sprite 6 Y-pos
C64_VIC_M7X     = $D00E ;(R/W)  Sprite 7 X-pos
C64_VIC_M7Y     = $D00F ;(R/W)  Sprite 7 Y-pos
C64_VIC_MX8     = $D010 ;(R/W)  Sprite X-pos, msb
C64_VIC_CR1     = $D011 ;(R/W)  Control #1: |RST8|ECM|BMM|DEN|RSEL|YSCL2-0|
C64_VIC_RASTER  = $D012 ;(R)    Raster counter (R)/comparator (W)
C64_VIC_LPX     = $D013 ;(R)    Light pen X-pos
C64_VIC_LPY     = $D014 ;(R)    Light pen Y-pos
C64_VIC_ME      = $D015 ;(R/W)  Sprite Enable Register
C64_VIC_CR2     = $D016 ;(R/W)  Control #2: |?|?|RES|MCM|CSEL|XSCL2-0|
C64_VIC_MYE     = $D017 ;(R/W)  Sprite Vertical Expansion       
C64_VIC_VMCB    = $D018 ;(R/W)  Memory Control: |VM13-10|CB13-11|?|
C64_VIC_IRQST   = $D019 ;(R/W)  IRQ Status: |IRQ|?|?|?|ILP|IMMC|IMBC|IRST|
C64_VIC_IRQEN   = $D01A ;(R/W)  IRQ Enable: | ? |?|?|?|ELP|EMMC|EMBC|ERST|
C64_VIC_MDP     = $D01B ;(R/W)  Sprite/Data Priority
C64_VIC_MMC     = $D01C ;(R/W)  Sprite Multicolor mode
C64_VIC_MXE     = $D01D ;(R/W)  Sprite Horizontal Expansion
C64_VIC_MM      = $D01E ;(R/W)  Sprite to Sprite Collision Detect
C64_VIC_MD      = $D01F ;(R/W)  Sprite to Data Collision Detect
C64_VIC_EC      = $D020 ;(R/W)  Border Color
C64_VIC_B0C     = $D021 ;(R/W)  Background Color 0
C64_VIC_B1C     = $D022 ;(R/W)  Background Color 1
C64_VIC_B2C     = $D023 ;(R/W)  Background Color 2
C64_VIC_B3C     = $D024 ;(R/W)  Background Color 3
C64_VIC_MM0     = $D025 ;(R/W)  Sprite Multicolor 0
C64_VIC_MM1     = $D026 ;(R/W)  Sprite Multicolor 1
C64_VIC_M0C     = $D027 ;(R/W)  Sprite 0 Color
C64_VIC_M1C     = $D028 ;(R/W)  Sprite 1 Color
C64_VIC_M2C     = $D029 ;(R/W)  Sprite 2 Color
C64_VIC_M3C     = $D02A ;(R/W)  Sprite 3 Color
C64_VIC_M4C     = $D02B ;(R/W)  Sprite 4 Color
C64_VIC_M5C     = $D02C ;(R/W)  Sprite 5 Color
C64_VIC_M6C     = $D02D ;(R/W)  Sprite 6 Color
C64_VIC_M7C     = $D02E ;(R/W)  Sprite 7 Color
}

        ;; BASIC V2.0 error codes
C64_ERR_TOO_MANY_FILES          = $01
C64_ERR_FILE_OPEN               = $02
C64_ERR_FILE_NOT_OPEN           = $03
C64_ERR_FILE_NOT_FOUND          = $04
C64_ERR_DEVICE_NOT_PRESENT      = $05
C64_ERR_NOT_INPUT_FILE          = $06
C64_ERR_NOT_OUTPUT_FILE         = $07
C64_ERR_MISSING_FILE_NAME       = $08
C64_ERR_ILLEGAL_DEVICE_NUMBER   = $09
C64_ERR_NEXT_WITHOUT_FOR        = $0A
C64_ERR_SYNTAX                  = $0B
C64_ERR_RETURN_WITHOUT_GOSUB    = $0C
C64_ERR_OUT_OF_DATA             = $0D
C64_ERR_ILLEGAL_QUANTITY        = $0E
C64_ERR_OVERFLOW                = $0F
C64_ERR_OUT_OF_MEMORY           = $10
C64_ERR_UNDEFD_STATMENT         = $11
C64_ERR_BAD_SUBSCRIPT           = $12
C64_ERR_REDIMD_ARRAY            = $13
C64_ERR_DIVISION_BY_ZERO        = $14
C64_ERR_ILLEGAL_DIRECT          = $15
C64_ERR_TYPE_MISMATCH           = $16
C64_ERR_STRING_TOO_LONG         = $17
C64_ERR_FILE_DATA               = $18
C64_ERR_FORMULA_TOO_COMPLEX     = $19
C64_ERR_CANT_CONTINUE           = $1A
C64_ERR_UNDEFD_FUNCTION         = $1B
C64_ERR_VERIFY                  = $1C
C64_ERR_LOAD                    = $1D
C64_ERR_BREAK                   = $1E

        ;; BASIC V2.0 tokens
C64_BAS_ABS                     = $B6   ; ABS
C64_BAS_AND                     = $AF   ; AND
C64_BAS_ASC                     = $C6   ; ASC
C64_BAS_ATN                     = $C1   ; ATN
C64_BAS_CHR_D                   = $C7   ; CHR$    -- trailing '$' included
C64_BAS_CLOSE                   = $A0   ; CLOSE
C64_BAS_CLR                     = $9C   ; CLR
C64_BAS_CMD                     = $9D   ; CMD
C64_BAS_CONT                    = $9A   ; CONT
C64_BAS_COS                     = $BE   ; COS
C64_BAS_DATA                    = $83   ; DATA
C64_BAS_DEF                     = $96   ; DEF
C64_BAS_DIM                     = $86   ; DIM
C64_BAS_END                     = $80   ; END
C64_BAS_EXP                     = $BD   ; EXP
C64_BAS_FN                      = $A5   ; FN
C64_BAS_FOR                     = $81   ; FOR
C64_BAS_FRE                     = $B8   ; FRE
C64_BAS_GET                     = $A1   ; GET
C64_BAS_GO                      = $CB   ; GO
C64_BAS_GOSUB                   = $8D   ; GOSUB
C64_BAS_GOTO                    = $89   ; GOTO
C64_BAS_IF                      = $8B   ; IF
C64_BAS_INPUT                   = $85   ; INPUT
C64_BAS_INPUT_N                 = $84   ; INPUT#  -- trailing '#' included
C64_BAS_INT                     = $B5   ; INT
C64_BAS_LEFT_D                  = $C8   ; LEFT$   -- trailing '$' included
C64_BAS_LEN                     = $C3   ; LEN
C64_BAS_LET                     = $88   ; LET
C64_BAS_LIST                    = $9B   ; LIST
C64_BAS_LOAD                    = $93   ; LOAD
C64_BAS_LOG                     = $BC   ; LOG
C64_BAS_MID_D                   = $CA   ; MID$    -- trailing '$' included
C64_BAS_NEW                     = $A2   ; NEW
C64_BAS_NEXT                    = $82   ; NEXT
C64_BAS_NOT                     = $A8   ; NOT
C64_BAS_ON                      = $91   ; ON
C64_BAS_OPEN                    = $9F   ; OPEN
C64_BAS_OR                      = $B0   ; OR
C64_BAS_PEEK                    = $C2   ; PEEK
C64_BAS_POKE                    = $97   ; POKE
C64_BAS_POS                     = $B9   ; POS
C64_BAS_PRINT                   = $99   ; PRINT
C64_BAS_PRINT_N                 = $98   ; PRINT#  -- trailing '#' included
C64_BAS_PI                      = $FF   ; Pi constant
C64_BAS_READ                    = $87   ; READ
C64_BAS_REM                     = $8F   ; REM
C64_BAS_RESTORE                 = $8C   ; RESTORE
C64_BAS_RETURN                  = $8E   ; RETURN
C64_BAS_RIGHT                   = $C9   ; RIGHT$  -- trailing '$' included
C64_BAS_RND                     = $BB   ; RND
C64_BAS_RUN                     = $8A   ; RUN
C64_BAS_SAVE                    = $94   ; SAVE
C64_BAS_SGN                     = $B4   ; SGN
C64_BAS_SIN                     = $BF   ; SIN
C64_BAS_SPC_P                   = $A6   ; SPC(    -- trailing '(' included
C64_BAS_SQR                     = $BA   ; SQR
C64_BAS_STEP                    = $A9   ; STEP
C64_BAS_STOP                    = $90   ; STOP
C64_BAS_STR_D                   = $C4   ; STR$    -- trailing '$' included
C64_BAS_SYS                     = $9E   ; SYS
C64_BAS_TAB_P                   = $A3   ; TAB(    -- trailing '(' included
C64_BAS_TAN                     = $C0   ; TAN
C64_BAS_THEN                    = $A7   ; THEN
C64_BAS_TO                      = $A4   ; TO
C64_BAS_USR                     = $B7   ; USR
C64_BAS_VAL                     = $C5   ; VAL
C64_BAS_VERIFY                  = $95   ; VERIFY
C64_BAS_WAIT                    = $92   ; WAIT
C64_BAS_ADD                     = $AA   ; '+', addition/string concatenation
C64_BAS_SUB                     = $AB   ; '-', subtraction
C64_BAS_MUL                     = $AC   ; '*', multiplication
C64_BAS_DIV                     = $AD   ; '/', division
C64_BAS_POW                     = $AE   ; '^' (up-arrow), Power
C64_BAS_GT                      = $B1   ; '>', greater-than operator
C64_BAS_EQ                      = $B2   ; '=', equals operator
C64_BAS_LT                      = $B3   ; '<', less-than operator
