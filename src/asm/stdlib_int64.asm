;; -----------------------------------------------------------------------------
;; Int64
;; .___Tag_____Sz_*_Field_0_.______Field_1______. ... .______Field_4______.
;; |Custom_tag¦_5_|___ptr___|bits07-00|bits15-08| ... |bits55-48|bits63-56|
;;                     \
;;                     |compare_ptr|hash_ptr|
;; -----------------------------------------------------------------------------

!zone caml_INT64 {

!ifndef caml_int64_warn {
caml_int64_warn
  !warn "TODO: caml_int64_bits_of_float(value vd)"
  !warn "TODO: caml_int64_div(value v1, value v2)"
  !warn "TODO: caml_int64_mod(value v1, value v2)"
  !warn "TODO: caml_int64_bswap(value v)"
  !warn "TODO: caml_int64_of_int(value v)"
  !warn "TODO: caml_int64_to_int(value v)"
  !warn "TODO: caml_int64_of_float"
  !warn "TODO: caml_int64_of_int32(value v)"
  !warn "TODO: caml_int64_to_int32(value v)"
}

!macro caml_int64_alloc {
        LDA # Custom_tag
        LDX # 5
        JSR caml_alloc
}

!ifdef  caml_PRIM__caml_int64_custom    {
!align $01, $00
caml_int64_custom
        !word @caml_int64_compare
        !word @caml_int64_hash
@caml_int64_compare
        STY TMP + 2
        LDA (SP),Y
        STA TMP
        INY
        LDA (SP),Y
        STA TMP + 1
        SEC
        LDX # 7
-       INY
        LDA (ACCU),Y
        SBC (TMP),Y
        ORA TMP + 2
        STA TMP + 2
        DEX
        BNE -
        INY
        LDA (ACCU),Y
        SBC (TMP),Y
        BVC +
        EOR # $80
+       BMI ++                          ;jump if <
        LDY # 0
        STY ACCU + 1
        ORA TMP + 2
        BNE +                           ;jump if >
        LDA # <Val_zero
        STA ACCU
        RTS
+       LDA # <Val_one
        STA ACCU
        RTS
++      LDY # $FF
        STY ACCU
        STY ACCU + 1
        INY
        RTS
@caml_int64_hash
        LDY # 9
        LDA (ACCU),Y
  !for @i, 1, 3 {
        DEY
        EOR (ACCU),Y
  }
        TAX
        DEY
        LDA (ACCU),Y
  !for @i, 1, 3 {
        DEY
        EOR (ACCU),Y
  }
        SEC
        ROL
        STA ACCU
        TXA
        ROL
        STA ACCU + 1
        LDY # 0
        RTS
}

!ifdef  caml_PRIM__caml_int64_neg {
caml_int64_neg
        +caml_int64_alloc
        LDX # 0
        SEC
        LDA # < caml_int64_custom
        STA (BLK),Y
        INY
        LDA # > caml_int64_custom
        STA (BLK),Y
  !for @i, 1, 8 {
        INY
        TXA
        SBC (ACCU),Y
        STA (BLK),Y
  }
        LDA BLK
        STA ACCU
        LDA BLK + 1
        STA ACCU + 1
        LDY # 0
        RTS
}

!ifdef  caml_PRIM__caml_int64_add {
caml_int64_add
        +caml_int64_alloc
        LDA (SP),Y
        STA TMP
        INY
        LDA (SP),Y
        STA TMP + 1
        CLC
  !for @i, 1, 8 {
        INY
        LDA (ACCU),Y
        ADC (TMP),Y
        STA (BLK),Y
  }
        LDY # 1
        LDA # > caml_int64_custom
        STA (BLK),Y
        DEY
        LDA # < caml_int64_custom
        STA (BLK),Y
        LDA BLK
        STA ACCU
        LDA BLK + 1
        STA ACCU + 1
        RTS
}

!ifdef  caml_PRIM__caml_int64_sub {
caml_int64_sub
        +caml_int64_alloc
        LDA (SP),Y
        STA TMP
        INY
        LDA (SP),Y
        STA TMP + 1
        SEC
  !for @i, 1, 8 {
        INY
        LDA (ACCU),Y
        SBC (TMP),Y
        STA (BLK),Y
  }
        LDY # 1
        LDA # > caml_int64_custom
        STA (BLK),Y
        DEY
        LDA # < caml_int64_custom
        STA (BLK),Y
        LDA BLK
        STA ACCU
        LDA BLK + 1
        STA ACCU + 1
        RTS
}

!ifdef  caml_PRIM__caml_int64_and {
caml_int64_and
        +caml_int64_alloc
        LDA (SP),Y
        STA TMP
        INY
        LDA (SP),Y
        STA TMP + 1
  !for @i, 1, 8 {
        INY
        LDA (ACCU),Y
        AND (TMP),Y
        STA (BLK),Y
  }
        LDY # 1
        LDA # > caml_int64_custom
        STA (BLK),Y
        DEY
        LDA # < caml_int64_custom
        STA (BLK),Y
        LDA BLK
        STA ACCU
        LDA BLK + 1
        STA ACCU + 1
        RTS
}

!ifdef  caml_PRIM__caml_int64_or {
caml_int64_or
        +caml_int64_alloc
        LDA (SP),Y
        STA TMP
        INY
        LDA (SP),Y
        STA TMP + 1
  !for @i, 1, 8 {
        INY
        LDA (ACCU),Y
        ORA (TMP),Y
        STA (BLK),Y
  }
        LDY # 1
        LDA # > caml_int64_custom
        STA (BLK),Y
        DEY
        LDA # < caml_int64_custom
        STA (BLK),Y
        LDA BLK
        STA ACCU
        LDA BLK + 1
        STA ACCU + 1
        RTS
}

!ifdef  caml_PRIM__caml_int64_xor {
caml_int64_xor
        +caml_int64_alloc
        LDA (SP),Y
        STA TMP
        INY
        LDA (SP),Y
        STA TMP + 1
  !for @i, 1, 8 {
        INY
        LDA (ACCU),Y
        EOR (TMP),Y
        STA (BLK),Y
  }
        LDY # 1
        LDA # > caml_int64_custom
        STA (BLK),Y
        DEY
        LDA # < caml_int64_custom
        STA (BLK),Y
        LDA BLK
        STA ACCU
        LDA BLK + 1
        STA ACCU + 1
        RTS
}

!ifdef  caml_PRIM__caml_int64_shift_left {
caml_int64_shift_left
        +caml_int64_alloc
        LDA (SP),Y
        LSR
        AND # 63
        BNE +
        LDY # 9
  !for @i, 1, 8 {
        LDA (ACCU),Y
        STA (BLK),Y
        DEY
  }
--      LDA # > caml_int64_custom
        STA (BLK),Y
        DEY
        LDA # < caml_int64_custom
        STA (BLK),Y
        LDA BLK
        STA ACCU
        LDA BLK + 1
        STA ACCU + 1
        RTS
+       TAX
-       LDY # 2
        LDA (ACCU),Y
        ASL
        STA (BLK),Y
  !for @i, 1, 7 {
        INY
        LDA (ACCU),Y
        ROL
        STA (BLK),Y
  }
        DEX
        BNE -
        LDY # 1
        BNE --                          ;jmp
}

!ifdef  caml_PRIM__caml_int64_shift_right {
caml_int64_shift_right
        +caml_int64_alloc
        LDA (SP),Y
        LSR
        AND # 63
        BNE +
        LDY # 9
  !for @i, 1, 8 {
        LDA (ACCU),Y
        STA (BLK),Y
        DEY
  }
--      LDA # > caml_int64_custom
        STA (BLK),Y
        DEY
        LDA # < caml_int64_custom
        STA (BLK),Y
        LDA BLK
        STA ACCU
        LDA BLK + 1
        STA ACCU + 1
        RTS
+       TAX
-       LDY # 9
        LDA (ACCU),Y
        CMP # $80
        ROR
        STA (BLK),Y
  !for @i, 1, 7 {
        DEY
        LDA (ACCU),Y
        ROR
        STA (BLK),Y
  }
        DEX
        BNE -
        LDY # 1
        BNE --                          ;jmp
}

!ifdef  caml_PRIM__caml_int64_shift_right_unsigned {
caml_int64_shift_right_unsigned
        +caml_int64_alloc
        LDA (SP),Y
        LSR
        AND # 63
        BNE +
        LDY # 9
  !for @i, 1, 8 {
        LDA (ACCU),Y
        STA (BLK),Y
        DEY
  }
--      LDA # > caml_int64_custom
        STA (BLK),Y
        DEY
        LDA # < caml_int64_custom
        STA (BLK),Y
        LDA BLK
        STA ACCU
        LDA BLK + 1
        STA ACCU + 1
        RTS
+       TAX
-       LDY # 9
        LDA (ACCU),Y
        LSR
        STA (BLK),Y
  !for @i, 1, 7 {
        DEY
        LDA (ACCU),Y
        ROR
        STA (BLK),Y
  }
        DEX
        BNE -
        LDY # 1
        BNE --                          ;jmp
}

!ifdef  caml_PRIM__caml_int64_mul {
caml_int64_mul
@M      = TMP                                   ;8 bytes
@P      = TMP + 8                               ;8 bytes
@NPTR   = TMP + 16                              ;2 bytes
        +caml_int64_alloc
        SEC
        LDA (SP),Y
        SBC # $FF - 9                   :!warn "COS'E'? COMMENTARE!"
        STA @NPTR
        INY
        LDA (SP),Y
        SBC # 0
        STA @NPTR + 1
        LDX # 0
        LDY # 9
        LDA (ACCU),Y
        LSR
        STA @M + 7
        STX @P + 7
  !for @i, 6, 0 {
        DEY
        LDA (ACCU),Y
        ROR
        STA @M + @i
        STX @P + @i
  }
        LDX # 64
--      BCC +
        CLC
        LDY # $FF - 7
-       LDA (@NPTR),Y
        ADC @P - $FF + 7,Y
        STA @P - $FF + 7,Y
        INY
        BNE -
+       LSR @P + 7
  !for @i, 6, 0 {
        ROR @P + @i
  }
  !for @i, 7, 0 {
        ROR @M + @i
  }
        DEX
        BNE --
        LDY # 9
-       LDA @M - 2,Y
        STA (BLK),Y
        DEY
        CPY # 2
        BCS -
        LDA BLK
        STA ACCU
        LDA BLK + 1
        STA ACCU + 1
        LDY # 0
        RTS
}

!ifdef  caml_PRIM__caml_int64_to_float {
caml_int64_to_float
        STY C64_FAC + 5                 ;clear FAC sign
        STY C64_FACRND                  ;clear FAC round byte
        LDA # 64 + $80
        STA C64_FAC                     ;set exponent (64)
        LDY # 6
        LDX # 3
-       LDA (ACCU),Y                    ;copy int64 hi bytes into FAC mantissa
        STA C64_FAC + 1,X
        INY
        DEX
        BPL -
        EOR # $80
        CMP # $80                       ;set carry if int64 is positive
        +caml_JSR_BASROM C64_FADFLT     ;normalize
        LDX # <TMP
        LDY # >TMP
        +caml_JSR_BASROM C64_MOVMF      ;copy FAC to TMP
;       ldy #0                          ;Y = 0 by MOVMF
        STY C64_FAC + 5                 ;clear FAC sign
        STY C64_FACRND                  ;clear FAC round byte
        LDA # 32 + $80
        STA C64_FAC                     ;set exponent (32)
        LDY # 2
        LDX # 3
-       LDA (ACCU),Y                    ;copy int64 lo bytes into FAC mantissa
        STA C64_FAC + 1,X
        INY
        DEX
        BPL -
        SEC                             ;set carry (positive)
        +caml_JSR_BASROM C64_FADFLT     ;normalize
        LDA # <TMP
        LDY # >TMP
        +caml_JSR_BASROM C64_FADD       ;FAC := TMP + FAC
        JMP caml_float_alloc_result
}

;; Conversion from IEEE754 binary64 to C64FLP and vice-versa.
;; See en.wikipedia.org/wiki/Double-precision_floating-point_format
;; &   www.c64-wiki.com/wiki/Floating_point_arithmetic
;;
;; IEEE754:      |±¦e10_e04|e03_e00¦m51_m48|m47_m40|...|m07_m00|
;; little-endian |m07_m00|...|m47_m40|e03_e00¦m51_m48|±¦e10_e04| Int64.t
;; exponent representation: excess-1023
;;      exp = $001...$7FE -> ± (2^(exp-1023) * 1.mantissa)
;;      exp = $7FF -> special numbers: NaN, +infinity, -infinity
;;      exp = $000, mantissa =  0 -> +0.0, -0.0
;;      exp = $000, mantissa <> 0 ->  ± (2^(-1022) * 0.mantissa)
;; range:   ±2.22507386E-308 ... ±1.79769313E+308 (normal)
;;          ±4.94065646E-324 ... ±2.22507386E-308 (subnormal)
;; example: 1.0= |0¦0111111|1111¦0000|00000000|...|00000000|
;; little-endian |00000000|...|00000000|1111¦0000|0¦0111111| Int64.t
;;
;; C64 (in RAM): |E07_E00|±¦M30_M24|M23_M16|M15_M08|M07_M00|
;; C64 (in FAC): |E07_E00|1¦M30_M24|M23_M16|M15_M08|M07_M00|±///////|
;; exponent representation: excess-128
;;      exp = $01...$FF -> ± (2^(exp-128) * 0.1mantissa)
;;      exp = $00 -> 0.0
;; range:   ±2.93873588E-39 ... ±1.70141183E+38
;; example: 1.0= |10000001|0¦0000000|00000000|00000000|00000000|  (RAM)
;;          1.0= |10000001|1¦0000000|00000000|00000000|00000000|0|(FAC)

!ifdef  caml_PRIM__caml_int64_bits_of_float {
caml_int64_bits_of_float
@EXPHI  = TMP
        +caml_int64_alloc
        LDA ACCU
        STA caml_float_loadFAC_addr
        LDA ACCU + 1
        STA caml_float_loadFAC_addr + 1
        JSR caml_float_loadFAC
        LDA C64_FAC                     ;load exp
        CLC
        ADC # <(1023 - 128 - 1)         ;adjust bias, lo bits
        STA C64_FAC                     ;save
        LDA # 0
        ADC # >(1023 - 128 - 1)         ;idem, hi bits
        LDX # 3                         ;shift left exp 4 times
-       ASL C64_FAC
        ROL
        DEX
        BPL -
        STA @EXPHI
        LDA C64_FAC + 5                 ;load sign byte
        AND # %10000000                 ;get bit 7
        ORA @EXPHI                      ;merge with exp
        LDY # 9
        STA (BLK),Y                     ;save |±¦e10_e04|
        LDX # 4                         ;shift left mantissa 5 times
-       ASL C64_FAC + 4
  !for @i, 3, 1 {
        ROL C64_FAC + @i
  }
        ROL
        DEX
        BPL -
        AND # %00001111                 ;merge m51_m48
        ORA C64_FAC                     ;with e03_e00
        DEY
  !for @i, 1, 4 {
        STA (BLK),Y
        LDA C64_FAC + @i
        DEY
  }
        LDA # 0
        STA (BLK),Y                     ;put 0 in last 3 bytes
        DEY
        STA (BLK),Y
        DEY
        STA (BLK),Y
        TAY
        LDA BLK
        STA ACCU
        LDA BLK + 1
        STA ACCU + 1
        ;return result
        RTS
}

!ifdef  caml_PRIM__caml_int64_float_of_bits {
caml_int64_float_of_bits
        LDY # 9
        LDA (ACCU),Y                    ;.A <- sign¦e10_e04
        STA C64_FAC + 5                 ;put sign into FAC sign byte
        AND # %01111111                 ;clear sign bit
        TAX
        DEY
        LDA (ACCU),Y                    ;.A <- e03_e00¦m51_m48
        STA C64_FAC + 1
        SEC
        SBC # <((1023-128-1) << 4)      ;adjust exp bias, lo bits
        STA C64_FAC
        TXA
        SBC # >((1023-128-1) << 4)      ;idem, hi bits
        BCS +
        LDA # 0                         ;treat floats under C64 repr.
        STA C64_FAC                     ;lower limit as zero:
@zero   STA C64_FAC + 5                 ;clear minus sign, if any;
        JMP caml_float_alloc_result     ;allocate float and return
@exn    +caml_raise Invalid_argument, "Int64.float_of_bits"
@mask  !byte %11110000
+       BIT @mask
        BNE @exn                        ;if NaN, ±inf or overflow, raise exn
  !for @i, 1, 4 {
        LSR                             ;shift result into FAC exp byte
        ROR C64_FAC
  }
        BEQ @zero                       ;if zero skip mantissa loading
        DEY
        LDA (ACCU),Y                    ;load significative part of mantissa
        STA C64_FAC + 2
        DEY
        LDA (ACCU),Y
        STA C64_FAC + 3
        DEY
        LDA (ACCU),Y
        STA C64_FAC + 4
        DEY
        LDA (ACCU),Y
        STA C64_FACRND
        LDX # 2                         ;shift left 3 times
-       ASL C64_FACRND
  !for @i, 4, 1 {
        ROL C64_FAC + @i
  }
        DEX
        BPL -
        LDA C64_FAC + 1
        ORA # $80                       ;set leftmost bit of mantissa
        STA C64_FAC + 1
        JMP caml_float_alloc_result     ;allocate float and return
}

; caml_int64_bits_of_float(value vd)
; caml_int64_div(value v1, value v2)
; caml_int64_mod(value v1, value v2)
; caml_int64_bswap(value v)
; caml_int64_of_int(value v)
; caml_int64_to_int(value v)
; caml_int64_of_float
; caml_int64_of_int32(value v)
; caml_int64_to_int32(value v)

}       ;; zone caml_INT64
