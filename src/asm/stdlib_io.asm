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
;;; INPUT-OUTPUT
;;; ----------------------------------------------------------------------------

!zone caml_IO {

!ifdef caml_PRIM__caml_nonstd_print_char {
caml_nonstd_print_char
        LSR ACCU + 1
        LDA ACCU
        ROR
        STY ACCU + 1
        LDX # <Val_unit
        STX ACCU
        JMP C64_CHROUT                          ;JMP = JSR+RTS
}

!ifdef caml_PRIM__caml_nonstd_read_line {
caml_nonstd_read_line
        ;; Stdlib.read_line
@CNT    = TMP                                   ;string length
@PTR    = TMP + 2                               ;buffer pointer
        LDA # String_tag
        LDX # $FF
        JSR caml_alloc                          ;allocate buffer, addr in BLK
        LDA BLK
        STA @PTR
        LDA BLK + 1
        STA @PTR + 1                            ;init buffer pointer
        STY @CNT                                ;reset char counter
        STY @CNT + 1
        STY C64_BLNSW                           ;enable cursor blink
-       JSR C64_GETIN                           ;A:=char from keyboard; X,Y:=?
        BEQ -                                   ;no char entered
        TAX                                     ;save char in X
        CMP # $14
        BEQ @delete                             ;DELETE
        CMP # $0D
        BEQ @return                             ;RETURN
        AND # %01111111
        CMP # $20
        BCC -                                   ;NON-PRINTABLE
        LDA @CNT + 1                            ;check counter
        BEQ +                                   ;ok, cnt < 256
        LDA @CNT
        CMP # <509
        BEQ -                                   ;cnt=509, only DEL/CR admitted:
+       TXA                                     ;reload char in A
        LDY # $00                               ;(Y used by C64_GETIN)
        STA (@PTR),Y                            ;put char into the buffer
        INC @PTR                                ;increment the buffer pointer
        BNE +
        INC @PTR + 1
+       INC @CNT                                ;increment the counter
        BNE +
        INC @CNT + 1
+       JSR C64_CHROUT                          ;print char
        JMP -                                   ;process next char
@delete LDA @CNT                                ;if counter_lo = 0
        BNE +
        ORA @CNT + 1                            ;then if counter_hi = 0
        BEQ -                                   ;    then nothing to del, jmp -
        DEC @CNT + 1                            ;    else decr counter_hi;
+       DEC @CNT                                ;decr counter_lo
        LDA @PTR                                ;if pointer_lo = 0
        BNE +
        DEC @PTR + 1                            ;then decr pointer_hi
+       DEC @PTR                                ;decr pointer_lo
        TXA                                     ;reload char in A
        JSR C64_CHROUT                          ;print char
        JMP -                                   ;process next char
@return DEC C64_BLNSW                           ;disable cursor blink
        JSR C64_CHROUT                          ;print newline
        LSR @CNT + 1
        ROR @CNT                                ;counter := counter / 2
        LDY # 0
        TYA                                     ;add string padding:
        STA (@PTR),Y                            ;1st padding byte = 0
        BCS +                                   ;is counter even?
        INY
        TYA
        STA (@PTR),Y                            ;yes: 2nd padding byte = 1
        DEY                                     ;Y := 0
+       LDX @CNT
        INX                                     ;X := # words of padded string
        JSR caml_shrink_latest_alloc            ;shrink allocated block
        LDA BLK
        STA ACCU
        LDA BLK + 1
        STA ACCU + 1                            ;return string in ACCU
        RTS
}

!ifdef caml_PRIM__caml_nonstd_print_string {
caml_nonstd_print_string
        ;; Stdlib.print_string
        LDY # -1
        DEC ACCU + 1
        LDA (ACCU),Y                            ;get block size
        INC ACCU + 1
        INY
        TAX                                     ;X := size
-       DEX                                     ;X := X - 1
        BEQ +                                   ;Exit loop when X=0
        LDA (ACCU),Y                            ;Loop: print 2 chars a time
        JSR C64_CHROUT                          ; first char
        INY
        LDA (ACCU),Y
        JSR C64_CHROUT                          ; second one
        INY
        BNE -                                   ;Continue loop
        INC ACCU + 1
        BNE -                                   ;BNE=JMP, continue loop
+       INY
        LDA (ACCU),Y                            ;Load last byte
        BNE +                                   ;If last byte = 0
        DEY
        LDA (ACCU),Y                            ;then load previous one
        JSR C64_CHROUT                          ; and print it.
+       LDA # Val_unit
        STA ACCU
        LDY # 0
        STY ACCU + 1                            ;ACCU := Val_unit
        RTS
}

}       ;; !zone caml_IO
