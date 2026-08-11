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

;; ACME command-line arguments:
;;   -Dcaml_SHOWMEM=1                Show program memory usage
;;   -Dcaml_INTERP=1                 Bytecode interpretation
;;   -Dcaml_INTERP=1 -Dcaml_DEBUG=1  Bytecode interpretation w/ debugger

!cpu 6502
!convtab pet
!zone caml_LOADER {

        .dummy = $1234                          ;dummy arg. for self-modifying
                                                ;code (SMC in comments)

;; -----------------------------------------------------------------------------
;;      LOADER (C64 BASIC V2 PROGRAM)
;; -----------------------------------------------------------------------------

        * = C64_BASRAM + 1
caml_loader
	;; 10 SYS caml_init:NEW:REM...
        !word +, 10
        !byte C64_BAS_SYS
        !for @i, 4, 0 {!text '0' + (caml_init DIV 10^@i) % 10}
        !byte ':', C64_BAS_NEW, ':', C64_BAS_REM
        !text 34, 141, 147, 14                  ;<"><SH+CR><CLR><LO_CASE>
        !text 141, "         The BreadCaml Project"             ;<SH+CR> txt...
        !text 141, "        (C) 2026  Piero Furiesi"            ;<SH+CR> txt...
        !text 141, "  https://github.com/baugigi/breadcaml"     ;<SH+CR> txt...
        !text 141                                               ;<SH+CR>
.zeroes !byte 0                                 ;End of line
+       !byte 0, 0                              ;End of program

;; ----------------------------------------------------------------------------
;;      MEMORY ADDRESSES
;; ----------------------------------------------------------------------------

!addr   caml_zp_start   = $2B                   ;Start of reserved ZP area
!addr   XARGS           = $2B                   ; 1 by. Val_Int(Extra_args)
!addr   ACCU            = $2C                   ; 2 by. Accumulator
!addr   SP              = $2E                   ; 2 by. Stack pointer
!addr   HEAP            = $30                   ; 2 by. Heap pointer
!addr   TRAPSP          = $32                   ; 2 by. Trap pointer
!addr   ENV             = $34                   ; 2 by. Environment
!ifdef  caml_INTERP {
  !addr caml_interp_fetch = $36                 ;15 by. Fetch-exec ($36-$44)
  !addr PC                = $37                 ;       (2 by. Program counter)
}
	;; CAUTION: $47, $56-$60 are used by BASIC floating point routines
!addr   TMP             = $45                   ;18 by. Temp. area ($45-$56)
!addr   BLK             = $57                   ; 2 by. New alloc'ed block ptr
!addr   GC              = $59                   ; 8 by. Reserved for GC
                                                ;-----
!addr   caml_zp_end     = $61                   ;54 by. Total ($61 = end + 1)

        ;; Computed by breadcaml
;; !addr  caml_glob_data                        ;global data store (out of heap)
;; !addr  caml_glob_table                       ;table of global values
;; !addr  caml_glob_end                         ;end of table + 1
;; !addr  caml_program                          ;start of program object code
;; !addr  caml_externals_lo                     ;extern. jumptable, lo bytes
;; !addr  caml_externals_hi                     ;extern. jumptable, hi bytes
;; !addr  caml_stack_start                      ;stack memory, start address
;; !addr  caml_stack_end                        ;stack memory, end address + 1

!ifndef caml_basic_rom_overlap {
!if caml_stack_end > C64_BASROM {
  caml_basic_rom_overlap = 1
  !set .x=   "WARNING: used memory overlaps BASIC ROM address space;"
  !set .x=.x+"         calls to BASIC routines will be wrapped."
  !warn .x 
}}

;; -----------------------------------------------------------------------------
;;      MEMORY REPRESENTATION OF OCaml VALUES: INTEGERS OR BLOCKS.
;; -----------------------------------------------------------------------------

;; INTEGERS:   .___1_word__.   15-bit signed integers, lsb=1
;;             |_lo_1¦±_hi_|

!macro  Val_Int ~.val, .int {                   ; Set .val to repr(.int)
  !set  .val = (2 * .int) + 1
}
        +Val_Int ~Val_zero,     0               ;0 : int
        +Val_Int ~Val_one,      1               ;1 : int
        +Val_Int ~Val_false,    0               ;false : bool
        +Val_Int ~Val_true,     1               ;true : bool
        +Val_Int ~Val_unit,     0               ;() : unit

;; BLOCKS:     .__Pointer__.   16-bit word-aligned pointers, lsb=0
;;             |_lo_0¦__hi_|
;;            /
;; .__Header_*___Fld(0)__.___Fld(1)__._ _._Fld(Sz-1)_.
;; |Tag_¦_Sz_|___Value___|___Value___|···|___Value___|

        ;; BIT caml_is_block will set Z=1 <=> A is a block
!addr   caml_is_block   = .isblk + 1

        Custom_tag      = 255                   ;custom block
        Double_array_tag= 254                   ;array of unboxed floats
        Double_tag      = 253                   ;float
        String_tag      = 252                   ;string
        Abstract_tag    = 251                   ;abstract
        No_scan_tag     = 251                   ;tag>=No_scan_tag => no GC scan
        Forward_tag     = 250                   ;lazy value, fwd ptr
        Infix_tag       = 249                   ;rec.clos.; odd => is INT for GC
        Object_tag      = 248                   ;object/exception
        Closure_tag     = 247                   ;closure
        Lazy_tag        = 246                   ;lazy value

;; ATOM(0):    .Tag_Sz_*                        ;Atom(t),t>0 not allowed as no
;;             |_0_¦_0_|                        ;value is represented as such

        ;; Statically allocated, word-aligned
!addr   caml_atom0 = .zeroes + 2 + .zeroes % 2

;; FLOAT blocks: C64 MFLP representation, not IEEE!
;; .Tag_Sz_*_________._________._________.
;; |253¦_3_|Expo¦±M_a|_n_t¦_i_s|_s_a¦_??_|      ?? = unused byte

        Double_wosize   = 3

!macro  caml_move_float .FROM, .TO {            ;Copy float block fields
        LDY # 2 * Double_wosize - 2             ;and set Y=0 at exit
-       LDA (.FROM),Y
        STA (.TO),Y
        DEY
        BPL -
        INY
}

;; STRING blocks: length = 2 * Sz - 1 - last byte;
;; .Tag_Sz_*___________.___________.___________.
;; |252¦_3_|_'O'_¦_'C'_|_'a'_¦_'m'_|_'l'_¦__0__| "OCaml" length=2*3-1-0=5
;; .Tag_Sz_*___________.___________.___________.
;; |252¦_3_|_'C'_¦_'='_|_'6'_¦_'4'_|__0__¦__1__| "C=64"  length=2*3-1-1=4

!macro  caml_string .str {                      ;Assemble the string .str
        !text .str, 0                           ;with proper trailing byte(s)
        !if len(.str) % 2 = 0 { !byte 1 }
}

;; EXCEPTIONS:
;; .Tag_Sz_*____________._____.                 standard exceptions:
;; |248¦_2_|_string_blk_|_oid_|                 oid = -1 ... -12  = -exn_no-1
;;          /
;; .Tag_Sz_*_.______···_______.
;; |252¦Sz_|_"Exception_name"_|

        Out_of_memory   =  0 :  End_of_file     =  4 :  Stack_overflow  =  8
        Sys_error       =  1 :  Division_by_zero=  5 :  Sys_blocked_io  =  9
        Failure         =  2 :  Not_found       =  6 :  Assert_failure  = 10
        Invalid_argument=  3 :  Match_failure   =  7 :  Undef_rec_module= 11
        caml_exn_no     = 12

!macro  caml_raise .exn {                       ;Raise a standard exception
        LDA # <caml_std_exn[.exn]
        STA ACCU
        LDA # >caml_std_exn[.exn]
        STA ACCU + 1
        JMP RAISE
}
!macro  caml_raise .exn, .str {                 ;As above, with a string arg.
        LDA # <.blk
        STA ACCU
        LDA # >.blk
        STA ACCU + 1
        JMP RAISE
        !align $01, $00
        !byte String_tag, (.h - .s) div 2
.s      +caml_string .str
.h      !byte 0, 2
.blk    !word caml_std_exn[.exn], .s
}
        ;; Statically allocate std exns and init caml_std_exn[] ptr array
!macro  caml_alloc_exn .s, .i {
        +Val_Int ~.id, -.i - 1
        !byte String_tag, (.hdr - .str) div 2   ;string block's header
.str    +caml_string .s                         ;string block's fields
.hdr    !byte Object_tag, 2                     ;exception block's header
.fld    !word .str, .id                         ;exception block's fields
        !set caml_std_exn = caml_std_exn + [.fld]
}
!set .x=["Out\xa4of\xa4memory","Sys\xa4error","Failure","Invalid\xa4argument"]
!set .x=.x+["End\xa4of\xa4file","Division\xa4by\xa4zero","Not\xa4found"]
!set .x=.x+["Match\xa4failure","Stack\xa4overflow","Sys\xa4blocked\xa4io"]
!set .x=.x+["Assert\xa4failure","Undef\xa4rec\xa4module"]
!set    caml_std_exn    = []                    ;array of pointers
!align  $01, $00
!for .i, 0, caml_exn_no - 1 { +caml_alloc_exn .x[.i], .i }

;; CLOSURES/RECURSIVE CLOSURES: Sz = 2 * nfun - 1 + nvar
;; .Tag_Sz_*0______.Tag_Sz_*1______.Tag_Sz_*2______._ _.______.______._
;; |247¦Sz_|_code0_|249¦_2_|_code1_|249¦_4_|_code2_|···|_Var0_|_Var1_|_···
;;                  /    \___________/___\___ # of words from *0 to *i = 2i
;; Infix_tag_______/________________/

;; -----------------------------------------------------------------------------
;;      INITIALIZATION
;; -----------------------------------------------------------------------------

caml_init

!ifdef  caml_basic_rom_overlap {
        JSR caml_BASROM_off                     ;deactivate BASIC ROM
}
        TSX                                     ;Save the CPU stack pointer,
        STX caml_hw_stack_ptr                   ; addr. defined in runtime.asm
        LDX # caml_zp_end - caml_zp_start       ;Save zeropage values so that
-       LDA caml_zp_start - 1,X                 ; they can be restored at end.
!ifdef  caml_INTERP {
                LDY caml_zp_buf - 1,X           ;Copy the fetch-exec routine
                STY caml_zp_start - 1,X         ; to zeropage
}
        STA caml_zp_buf - 1,X
        DEX
        BNE -
        LDA # <caml_syserr                      ;Redirect C64_IERROR vector.
        STA C64_IERROR
        LDA # >caml_syserr
        STA C64_IERROR + 1
        LDA # 14                                ;Select upper+lowercase charset.
        JSR C64_CHROUT
        JSR caml_heap_init                      ;Init heap (see memory.asm).
        LDA # <caml_stack_end                   ;Init stack pointer.
        STA SP
        LDA # >caml_stack_end
        STA SP + 1
        ;; Y is set to 0 here and, if not stated elsewhere, each routine/macro
        ;; assumes Y = 0 when invoked and ensures Y = 0 stands again upon exit.
        LDY # 0
.isblk  LDA # <Val_zero
        STA ACCU                                ;Init ACCU
        STY ACCU + 1
        STA TRAPSP                              ;Init TRAPSP
        STY TRAPSP + 1
        STA XARGS                               ;Init XARGS
        LDA # <caml_atom0                       ;Init ENV
        STA ENV
        LDA # >caml_atom0
        STA ENV + 1
!ifdef  caml_INTERP {
                LDX # <caml_program             ;X,A will be used to init PC
                LDA # >caml_program
                JMP caml_interp_start           ;Start bytecode interpretation
} else {
        JMP caml_program                        ;Start compiled program
}

;; -----------------------------------------------------------------------------
;;      TERMINATION
;; -----------------------------------------------------------------------------

caml_end
        LDX # caml_zp_end - caml_zp_start
-       LDA caml_zp_buf - 1,X                   ;restore zeropage values
        STA caml_zp_start - 1,X
        DEX
        BNE -
        LDA # <C64_ERROR                        ;restore IERROR vector
        STA C64_IERROR
        LDA # >C64_ERROR
        STA C64_IERROR + 1
!ifdef  caml_basic_rom_overlap {                ;re-activate BASIC ROM
        JSR caml_BASROM_on
}
        RTS                                     ;return to BASIC prompt.

;; -----------------------------------------------------------------------------
;;      ROM/RAM OVERLAP - BASIC ROUTINES CALLS
;; -----------------------------------------------------------------------------

        ;; Macro: call a BASIC ROM routine
!macro caml_JSR_BASROM .routine {
  !ifndef caml_basic_rom_overlap {              ;Best case: code never overlaps
        JSR .routine                            ;BASIC ROM
  } else {
    !if @x < C64_BASROM {                       ;BASROM is disabled but this
        JSR caml_BASROM_on                      ;part of code doesn't overlap it
        JSR .routine
        JSR caml_BASROM_off
@x  } else {                                    ;Worst case: this part of code
        PHP                                     ;overlaps BASIC ROM. Pass the
        PHA                                     ;routine address to a wrapper
        LDA # <.routine                         ;in a safe zone and call it
        STA caml_BASROM_addr
        LDA # >.routine
        STA caml_BASROM_addr + 1
        JSR caml_BASROM_wrapper
    }
  }
}

!ifdef caml_basic_rom_overlap {
caml_BASROM_wrapper                             ;Wrapper for 'Worst case' above
        LDA C64_D6510
        ORA # %00000011
        STA C64_D6510
        PLA
        PLP
caml_BASROM_addr = * + 1
        JSR .dummy                              ;SMC: JSR .routine
        ;; fallthrough caml_BASROM_off
caml_BASROM_off                                 ;Deactivate BASIC ROM
        PHP
        PHA
        LDA C64_D6510
        AND # %11111110
        STA C64_D6510
        PLA
        PLP
        RTS
caml_BASROM_on                                  ;Activate BASIC ROM
        PHP
        PHA
        LDA C64_D6510
        ORA # %00000011
        STA C64_D6510
        PLA
        PLP
        RTS
}

;; -----------------------------------------------------------------------------
;;      BASIC/KERNAL ERROR HANDLER
;; -----------------------------------------------------------------------------

caml_syserr
!ifdef  caml_basic_rom_overlap {
        LDA C64_D6510                           ;BASIC ROM might had been turned
        AND # %11111110                         ; on to call the routine which
        STA C64_D6510                           ; failed, so deactivate it
}
        CPX # C64_ERR_DIVISION_BY_ZERO          ;If the system error matches an
        BNE +                                   ; OCaml standard exception,
        +caml_raise Division_by_zero            ; raise it
+       CPX # C64_ERR_ILLEGAL_QUANTITY
        BNE +
        +caml_raise Invalid_argument, "Illegal quantity"
+       CPX # C64_ERR_OVERFLOW
        BNE +
        +caml_raise Failure, "Overflow"
+       LDY # 0                                 ;else raise Sys_Error(error no.)
        STY @arg
        STX @arg + 1                            ; save error no. using
        SEC                                     ; the OCaml int representation
        ROL @arg
        ROL @arg + 1
        LDA # <@blk
        STA ACCU
        LDA # >@blk
        STA ACCU + 1                            ; ACCU := exn address
        JMP RAISE                               ; raise Sys_error(error no.)
        !align $01, $00                         ;Exception block:
        !byte 0, 2                              ; Tag, Size
@blk    !word caml_std_exn[Sys_error]           ; Field0 = Sys_error exn
@arg    !word .dummy                            ; Field1 = Val_Int(error no.)

;; -----------------------------------------------------------------------------
;;      ZEROPAGE BUFFER - ZP values are saved here at initializazion and
;;      restored at end. If caml_INTERP=1, the buffer also contains the
;;      fetch-exec routine to be copied into ZP by caml_init.
;; -----------------------------------------------------------------------------

caml_zp_buf
        !fill 11                                ;11 by. for ZAM2 registers
!ifdef  caml_INTERP {
  !pseudopc caml_interp_fetch {
                @PC  = @fetch + 1               ;Bytecode interpreter
                @idx = @exec + 1                ;fetch-exec routine:
@fetch          LDA .dummy                      ; 3 by. SMC: fetch next opc
                INC+1 @PC                       ; 2 by. incr. LDA operand (PCl)
                BNE +                           ; 2 by.
                INC+1 @PC + 1                   ; 2 by. incr. LDA operand (PCh)
+
    !ifdef caml_DEBUG {
                JSR caml_debug
    } else {
                ASL                             ; 1 by. C:A = 2 * opc
                STA+1 @idx                      ; 2 by. modify JMP() operand
    }
@exec           JMP (caml_interp_jmptbl)        ; 3 by. SMC: JMP(>jmptbl + A)
  }                                             ;--
} else {!fill 15}                               ;15 by. total
        !fill 28                                ;28 by. for BLK, GC, TMP

;; -----------------------------------------------------------------------------
;;      INTERPRETER TRACING DEBUGGER
;;      | PC | Opcode | ACCU | SP[0] ... SP[5] | ENV | XARGS |
;; -----------------------------------------------------------------------------

!ifdef  caml_INTERP {
!ifdef caml_DEBUG {
caml_debug
        @RevOn  = $12
        @RevOff = $92
        @Cyan   = $9F
        @LBlue  = $9A
        @CR     = $0D
        PHP                                     ;       [S
        PHA                                     ;       [opc; S
        ;; print a header every 22 lines
        DEC @count
        BPL +
        LDA # @CR
        JSR C64_CHROUT
        LDX # @hdr - @end                       ;negative number
-       LDA @end - $100,X
        JSR C64_CHROUT
        INX
        BNE -
        LDA #21
        STA @count
+       ;; print PC
        LDA PC
        SEC
        SBC # 1
        PHA                                     ;       [PC; opc; S
        LDA PC + 1
        SBC # 0
        JSR @pr_hex
        PLA                                     ;A=PC   [opc; S
        JSR @pr_hex
        ;; print opcode
        LDA # @RevOn
        JSR C64_CHROUT
        PLA                                     ;A=opc  [S
        PHA                                     ;       [opc; S
        JSR @pr_hex
        ;; print ACCU
        LDA # @Cyan
        JSR C64_CHROUT
        LDA ACCU + 1
        JSR @pr_hex
        LDA ACCU
        JSR @pr_hex
        LDA # @RevOff
        JSR C64_CHROUT
        ;; print top 6 stack elements
        LDY # 0
-       TYA
        PHA                                     ;       [Y/4; opc; S
        LSR
        LSR
        LDA # @LBlue
        BCS +                                   ;switch Cyan/LBlue
        LDA # @Cyan
+       JSR C64_CHROUT
        PLA                                     ;A=Y/4  [opc; S
        TAY
        LDA (SP),Y
        TAX
        INY
        LDA (SP),Y
        JSR @pr_hex                             ;print STACK[i]
        TXA
        JSR @pr_hex
        INY
        CPY # 12
        BNE -
        ;; print ENV
        LDA # @RevOn
        JSR C64_CHROUT
        LDA ENV + 1
        JSR @pr_hex
        LDA ENV
        JSR @pr_hex
        ;; print XARGS
        LDA # @RevOff
        JSR C64_CHROUT
        LDA XARGS
        LSR
        JSR @pr_hex
        ;; continue fetch-exec
        PLA                                     ;A=opc  [S
        PLP                                     ;S      [
        ASL
        LDY # 0
        RTS
@count  !byte 0
@pr_hex PHA                                     ;       [A
        LSR
        LSR
        LSR
        LSR
        LDX # 2
        BNE +
-       PLA                                     ;A      [
        AND # $0F
+       CLC
        ADC # '0'
        CMP # '9' + 1
        BCC +
        ADC # 7 -1                              ;-1 as C=1
+       JSR C64_CHROUT
        DEX
        BNE -
        RTS
@hdr    !text @RevOn, "addr", @RevOff, "oc",   @Cyan,  "accu", @RevOn, "stk0"
        !text @LBlue, "   1", @Cyan,   "   2", @LBlue, "   3", @Cyan,  "   4"
        !text @LBlue, "   5", @RevOff, " env", @RevOn, "xa",   @RevOff
@end
}} ;ifdef caml_INTERP & caml_DEBUG

caml_loader_end
} ;zone caml_LOADER

