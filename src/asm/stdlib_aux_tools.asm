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
;;; -----------------------------------------------------------
;;;     AUXILIARY TOOLS
;;; -----------------------------------------------------------

!zone AUX_TOOLS {
        
!ifdef caml_PRIM__caml_memcpy {
        ;; copy memory
        ;; TMP, TMP + 1 =  source start address
        ;; TMP + 2, TMP + 3 = destination start address
        ;; TMP + 4, TMP + 5 = number of bytes to move
        ;; used registers: A, X, Y; return Y = 0.
caml_memcpy
        @FROM = TMP                     ;source address
        @TO = TMP + 2                   ;destination address
        @NUM = TMP + 4                  ;num bytes
        LDA @FROM + 1
        CMP @TO + 1
        BCC @caml_memcpy_up
        BNE @caml_memcpy_dn
        LDA @FROM
        CMP @TO
        BCC @caml_memcpy_up
        BNE @caml_memcpy_dn
        RTS
        ;; copy memory from a higher address to a lower one
@caml_memcpy_dn
        LDY # 0
        LDX @NUM + 1
        BEQ +
-       LDA (@FROM),Y                   ;move a page at a time
        STA (@TO),Y
        INY
        BNE -
        INC @FROM + 1
        INC @TO + 1
        DEX
        BNE -
+       LDX @NUM
        BEQ +
-       LDA (@FROM),Y                   ;move the remaining bytes
        STA (@TO),Y
        INY
        DEX
        BNE -
+       LDY # 0
        RTS
        ;; copy memory from a lower address to a higher one
@caml_memcpy_up
        LDX @NUM + 1                    ;the last byte must be moved first
        CLC                             ;start at the final pages of from & to
        TXA
        ADC @FROM + 1
        STA @FROM + 1
        CLC
        TXA
        ADC @TO + 1
        STA @TO + 1
        INX                             ;allows use of bne after dex below
        LDY @NUM
        BEQ ++
        DEY                             ;move bytes on the last page first
        BEQ +
-       LDA (@FROM),Y
        STA (@TO),Y
        DEY
        BNE -
+       LDA (@FROM),Y                   ;handle y = 0 separately
        STA (@TO),Y
++      DEY
        DEC @FROM + 1                   ;move the next page (if any)
        DEC @TO + 1
        DEX
        BNE -
        LDY # 0
        RTS
}

!ifdef  caml_PRIM__caml_blkcpy {
        ;; caml_blkcpy
        ;; Aux. routine to copy all fields from ACCU to BLK; C:Y = 2 * size.
        ;; The block's header is not copied!
caml_blkcpy
        BCC +                           ; less than 256 bytes (<128 fields)
        BEQ ++                          ; exactly 256 bytes   (=128 fields)
        INC ACCU + 1                    ; more than 256 bytes (>128 fields)
        INC BLK + 1
--
+       DEY
-       LDA (ACCU),Y
        STA (BLK),Y
        DEY
        BNE -
        LDA (ACCU),Y                    ; handle Y = 0 apart
        STA (BLK),Y
        BCC +
        DEC ACCU + 1
        DEC BLK + 1
++      CLC
        BCC --
+       RTS
}

}       ;; !zone AUX_TOOLS
