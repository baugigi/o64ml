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
;;; ---------------------------------------------------------------------------
;;; STRINGS (ocaml-4.14.4/runtime/str.c)
;;; ---------------------------------------------------------------------------

!zone caml_STRINGS {

!ifdef caml_PRIM__caml_string_of_bytes {
caml_string_of_bytes = caml_bytes_of_string
}
!ifdef caml_PRIM__caml_bytes_of_string {
caml_bytes_of_string
        RTS
}

!ifdef caml_PRIM__caml_create_bytes {
caml_create_bytes = caml_create_string
}
!ifdef caml_PRIM__caml_create_string {
caml_create_string
        ;; ACCU = length
        ;; alloc a new block for a string of given length (max 509)

        LDA ACCU + 1                            ;load >length
        LSR                                     ;
        ROR ACCU                                ;ACCUl,A := Int_val(lenght)
        LSR
        BNE +++                                 ;A>0 => len > max, raise exn.
        ROR ACCU                                ;ACCUl :=  Int_val(lenght) / 2
        PHP                                     ;save carry (remainder)
        LDX ACCU                                ;X := block size, in words
        INX                                     ;take into account Ocaml padding
        BEQ ++                                  ;Exception if size > 255
        LDA # String_tag                        ;load tag
        JSR caml_alloc                          ;allocate block
        LDA BLK
        STA ACCU
        LDA BLK + 1
        STA ACCU + 1                            ;ACCU := address of new block
        DEX                                     ;Compute the padding bytes:
        TXA                                     ;A := size - 1
        ASL                                     ;A := 2 * size - 2
        BCC +
        INC BLK + 1
+       TAY                                     ;BLK+.Y = address of last word
        LDA # 0
        PLP                                     ;reload .C flag
        BCS +                                   ;string length is odd?
        STA (BLK),Y                             ;no: padding = "\000\001"
        LDA # 1
+       INY                                     ;yes: padding = "\000"
        STA (BLK),Y
        LDY # 0
        RTS
++      PLP
+++     +caml_raise Invalid_argument, "String.create"
}

!ifdef caml_PRIM__caml_ml_bytes_length {
caml_ml_bytes_length = caml_ml_string_length
}
!ifdef caml_PRIM__caml_ml_string_length {
caml_ml_string_length
        ;; ACCU = string
        ;; return the string length (0 to 509)

        JSR caml_string_length_yx               ;TMP, TMP + 1 := len
        TYA
        SEC
        ROL
        STA ACCU
        TXA
        ROL
        STA ACCU + 1                            ;ACCU := Val_int(len)
        LDY # 0
        RTS
}

!ifdef caml_PRIM__caml_bytes_get {
caml_bytes_get = caml_string_get
}
!ifdef caml_PRIM__caml_string_get {
caml_string_get
        ;; ACCU=string, SP[0]=index
        ;; return string[index]

        JSR caml_string_index_y
        LDA (ACCU),Y                            ;get char
        SEC
        ROL
        STA ACCU
        LDA # 0
        TAY                                     ;.Y := 0
        ROL
        STA ACCU + 1                            ;ACCU := Val_char(char)
        RTS
}

!ifdef caml_PRIM__caml_bytes_set {
caml_bytes_set = caml_string_set
}
!ifdef caml_PRIM__caml_string_set {
caml_string_set
        ;; ACCU=string, SP[0]=index, SP[1]=newval
        ;; string.[index]<-newval; return: ()
;       TMP                                     ; used by caml_string_index_y
;       TMP + 1                                 ; used by caml_string_index_y
@CHAR   = TMP + 2
        LDY # 3
        LDA (SP),Y                              ; get newval, hi
        DEY
        LSR
        LDA (SP),Y                              ; get newval, lo
        ROR
        STA @CHAR                               ; save char_val(newval)
        JSR caml_string_index_y                 ; Y := index
        LDA @CHAR
        STA (ACCU),Y                            ; modify string in place
        LDY # <Val_unit
        STY ACCU
        DEY
        STY ACCU + 1                            ; return ()
        RTS
}

!ifdef caml_PRIM__caml_fill_bytes {
caml_fill_bytes = caml_fill_string
}
!ifdef caml_PRIM__caml_fill_string {
caml_fill_string
        ;; ACCU = string, SP[0]=ofs, SP[1]=num, SP[2]=char
        ;; for num times, string.[i]<-char starting from i=ofs; return: ()
        ;; (unsafe, args are checked in Bytes module)

        ;; TMP + 1 <- int_val(num)
        LDY # 3
        LDA (SP),Y
        LSR
        STA TMP + 1
        DEY
        LDA (SP),Y
        ROR
        BNE +
        CMP TMP + 1
        BEQ ++                          ;num = 0, nothing to do
+       STA TMP
        ;; ACCU <- ACCU + int_val(pos)
        DEY
        LDA (SP),Y
        LSR
        TAX
        DEY
        LDA (SP),Y
        ROR
        CLC
        ADC ACCU
        STA ACCU
        TXA
        ADC ACCU + 1
        STA ACCU + 1
        ;; A <- int_val(char)
        LDY # 5
        LDA (SP),Y
        LSR
        DEY
        LDA (SP),Y
        ROR
        ;; start substitution
        LDY # 0
        LDX TMP
--      STA (ACCU),Y                            ;modify string in place
        DEX
        BEQ +
-       INY
        BNE --
        INC ACCU + 1
        JMP --
+       CPX TMP + 1
        BEQ ++
        DEC TMP + 1
        JMP -
++      LDY # <Val_unit
        STY ACCU
        DEY
        STY ACCU + 1                            ;return ()
        RTS
}

!ifdef caml_PRIM__caml_blit_bytes {
caml_blit_bytes = caml_blit_string
}
!ifdef caml_PRIM__caml_blit_string {
caml_blit_string
        ;; ACCU=src, SP[0]=sofs SP[1]=dst, SP[2]=dofs, SP[3]=len
        ;; copies len consecutive bytes, starting from src.[sofs], to dst.[dofs]
        ;; source and destination intervals may overlap.
        ;; (unsafe, args are checked in Bytes module)
@FROM   = TMP
@TO     = TMP + 2
@SIZE   = TMP + 4
        LDY # 7
        LDA (SP),Y                              ; >len
        LSR
        STA @SIZE + 1                           ; SIZE + 1 := >int_val(len)
        DEY
        LDA (SP),Y                              ; <len
        ROR
        STA @SIZE                               ; SIZE := <int_val(len)
        DEY
        LDA (SP),Y                              ; >dofs
        LSR
        STA @TO + 1                             ; TO := >int_val(dofs)
        DEY
        LDA (SP),Y                              ; <dofs
        ROR
        STA @TO                                 ; TO := <int_val(dofs)
        DEY
        LDA (SP),Y                              ; >dst
        TAX
        DEY
        LDA (SP),Y                              ; <dst
        CLC
        ADC @TO
        STA @TO                                 ; TO := <(dst + int_val(dofs))
        TXA
        ADC @TO + 1
        STA @TO + 1                             ; TO + 1:= >(dst+int_val(dofs))
        DEY
        LDA (SP),Y                              ; >sofs
        LSR
        TAX
        DEY
        LDA (SP),Y                              ; <soft
        ROR
        CLC
        ADC ACCU
        STA @FROM                               ; FROM := <(src + int_val(sofs))
        TAY
        TXA
        ADC ACCU + 1
        STA @FROM + 1                           ; FROM+1 := >(src+int_val(sofs))
        JSR caml_memcpy                         ; ok, even if src & dest overlap
        LDY # <Val_unit
        STY ACCU
        DEY
        STY ACCU + 1
        RTS
}

!ifdef caml_PRIM__caml_nonstd_string_of_float {
caml_nonstd_string_of_float
        ;; Stdlib.string_of_float
        LDA ACCU
        LDX ACCU + 1
        STA caml_float_loadFAC__addr
        STX caml_float_loadFAC__addr + 1
        JSR caml_float_loadFAC
        LDA $47                                 ;WARNING: FOUT OVERWRITES $47
        PHA                                     ;save it
        +caml_JSR_BASROM C64_FOUT               ;0-terminated string in $0100
        PLA                                     ;restore $47 value
        STA $47
        LDX # $FF
-       INX                                     ;count string length (except 0)
        LDA $0100,X
        BNE -                                   ;(X = length when loop ends)
        LDA # 1                                 ;add a final 1 for padding; it
        STA $0101,X                             ;won't be copied if len is odd
        TXA                                     ;A := length
        LSR
        TAX                                     ;X := length / 2
        INX                                     ;X := length/2+1=blk size (wo.)
        LDA # String_tag
        LDY # 0
        JSR caml_alloc                          ;allocate the new block
        LDA BLK
        STA ACCU
        LDA BLK + 1
        STA ACCU + 1                            ;ACCU := new string
        TXA
        ASL
        TAY                                     ;Y := 2 * size
        DEY
-       LDA $0100,Y                             ;copy string and 0/01 padding
        STA (BLK),Y                             ;to the new block
        DEY
        BNE -
        LDA $0100
        STA (BLK),Y
        RTS
}

!ifdef caml_PRIM__caml_nonstd_string_of_int {
caml_nonstd_string_of_int
        ;; Stdlib.string_of_int
        ;; Convert an int to string, using the C64 format: first char for sign
        ;; (space if positive, minus if negative), followed by 5 digit max and
        ;; no non-significative zeroes.
@DGT    = TMP
@SKIPZ  = TMP + 1
        LDA # String_tag                        ;Max len is 4 words:
        LDX # 4                                 ;|'-','1'|'6','3'|'8','3'|\0,\1|
        JSR caml_alloc                          ;Allocate string, addr in BLK
        LDA # ' '                               ;Positive numbers start with ' '
        BIT ACCU + 1
        BPL +
        SEC                                     ;If value is negative,
        LDA # 2                                 ; negate it
        SBC ACCU
        STA ACCU
        TYA
        SBC ACCU + 1
        STA ACCU + 1
        LDA # '-'                               ; and put a '-' into the string
+       STA (BLK),Y
        INY
        LSR ACCU + 1                            ;Get rid of trailing 1
        ROR ACCU
        LDA # '0'                               ;Set SKIPZ flag to '0' (=ignore
        STA @SKIPZ                              ; all initial zeroes)
        LDX # 3                                 ;For X := 3 downto 0
--      STA @DGT                                ; Init DGT to '0'
        LDA ACCU                                ; Loop for calculating DGT:
        SEC
-       SBC @lo10,X                             ;  Subtract 10^(X+1) from ACCU
        PHA
        LDA ACCU + 1
        SBC @hi10,X
        BCC +                                   ; Exit loop on negative result
        STA ACCU + 1                            ;  Store result in ACCU
        PLA
        STA ACCU
        INC @DGT                                ;  Set DGT to next char digit
        BCS -                                   ; BCS=JMP, Continue loop
+       PLA
        LDA @DGT
        CMP @SKIPZ                              ; If DGT='0' & SKIPZ='0'
        BEQ +                                   ; then ignore current digit
        DEC @SKIPZ                              ; else stop skipping zeroes,
        STA (BLK),Y                             ;  put DGT into the string,
        INY
        LDA # '0'                               ;  set A='0' for next iteration.
+       DEX                                     ; Decrement counter
        BPL --                                  ;End_For
        ORA ACCU                                ;A := '0'|ACCU  (last digit)
        STA (BLK),Y
        INY
        LDA # 0                                 ;Pad string with \0
        STA (BLK),Y
        INY
        TYA
        LSR                                     ;Compute block size (in wo.)
        TAX
        BCC +
        LDA # 1                                 ;Add \1 pad if necessary
        STA (BLK),Y
        INX                                     ;size +1 for \0\1
+       LDA BLK
        STA ACCU
        LDA BLK + 1
        STA ACCU + 1
        LDY # 0
        JSR caml_shrink_latest_alloc            ;Shrink block to computed size
        RTS
@lo10   !byte <10, <100, <1000, <10000
@hi10   !byte >10, >100, >1000, >10000
}

        ;;
        ;; AUX
        ;;

!ifdef caml_PRIM__caml_string_index_y {
caml_string_index_y
        ;; given a string in ACCU, read index from SP[0], then
        ;; set Y and ACCU+1 so that ACCU+Y = &string[index];
        ;; raise Invalid_argument if not 0<=index<length(string).
        LDY # 1
        LDA (SP),Y                              ;get ARGh
        LSR                                     ;Int_val(ARGh)
        STA TMP + 1                             ;save
        DEY
        LDA (SP),Y                              ;get ARGl
        ROR                                     ;Int_val(ARGl)
        STA TMP                                 ;save
        JSR caml_string_length_yx               ;get string length in .Y.X
        CPX TMP + 1                             ;compare hi bytes
        BCC ++                                  ;.X < ARGh: error
        BNE +                                   ;.X > ARGh: ok
        CPY TMP                                 ;.X = ARGh: compare lo byte
        BCC ++                                  ;.Y < ARGl: error
        BEQ ++                                  ;.Y = ARGl: error
+       LDY TMP                                 ;reload index, lo
        LDA TMP + 1
        BEQ +
        INC ACCU + 1                            ;inc ACCUh if needed
+       RTS
++      +caml_raise Invalid_argument, "index out of bounds"
}

!ifdef caml_PRIM__caml_string_length_yx {
caml_string_length_yx
        ;; ACCU = string
        ;; return the string length in .Y,.X (int16, lo-hi)
        LDA ACCU + 1
        PHA                                     ;save ACCU + 1
        DEY                                     ;LDY # -1
        DEC ACCU + 1
        LDA (ACCU),Y                            ;.A := size
        INC ACCU + 1
        LDX # 0
        ASL
        TAY                                     ;.Y := <(2 * size)
        BCC @minus1
        BNE +
        DEY                                     ;shortcut when .Y=256
        BNE @pad                                ;bne=jmp
+       INC ACCU + 1
        INX                                     ;.X := >(2 * size)
@minus1 DEY                                     ;.Y := <(2 * size - 1)
        CPY # $FF
        BNE @pad
        DEC ACCU + 1
        DEX                                     ;.X := >(2 * size - 1)
@pad    LDA (ACCU),Y                            ;.A := padding byte
        BEQ +
        DEY                                     ;.Y := <(2 * size -1 -pad)
        CPY # $FF
        BNE +
        DEX                                     ;.X := >(2 * size -1 -pad)
+       PLA
        STA ACCU + 1                            ;restore ACCU+1
        RTS
}

}      ;; !zone caml_STRINGS

