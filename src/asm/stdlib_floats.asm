;;; ----------------------------------------------------------------------------
;;; FLOATS
;;; ----------------------------------------------------------------------------

;;; ZEROPAGE LOCATIONS
;;; used by the C64's BASIC ROM floating point routines:
;;;
;;; $12         used by tan and (in preparation for tan) by sin & cos routines
;;; $22-$23     used to move variables into the accumulators and back to memory
;;; $24-$25     used during FP comparisons and when converting PETSCII into FP
;;; $26-$2A     result of multiplication or division
;;; $47         used by FOUT
;;; $56         used in addition and subtraction, and also the exp function
;;; $5C-$60     used by the PETSCII conversion routines
;;; $61         FAC1 exponent
;;; $62-$65     FAC1 mantissa
;;; $66         FAC1 sign in bit 7
;;; $67         used by trig, exp, log functions and PETSCII to FP conversion
;;; $68         used during normalisation and FP to integer conversion
;;; $69         FAC2 exponent
;;; $6A-$6D     FAC2 mantissa
;;; $6E         FAC2 sign in bit 7
;;; $6F         sign result of arithmetic operations, set when FAC2 is loaded
;;; $70         low order rounding byte for FAC1, cleared when FAC1 is loaded
;;; $71-$72     used during series eval. and when converting PETSCII into FP
;;; $73-$8A     CHRGET routine, used when converting a PETSCII string into FP

!zone caml_FLOATS {

.dummy  = $1234                                 ;dummy operand for self-modifying
                                                ;code (SMC in comments)

!ifndef caml_float_zp_check {
caml_float_zp_check
  !for .i in [[$12,$12],[$22,$2A],[$47,$47],[$56,$56],[$5C,$8A]] {
    !if (caml_zp_start <= .i[1]) & (.i[0] < caml_zp_end) {
      !warn "ZP storage overlaps FLPT workspace", .i
    }
  }
}
!ifdef caml_PRIM__caml_nonstd_sign_float {
caml_nonstd_sign_float
        ;; Stdlib.sign_float
        LDA (ACCU),Y                            ;Read byte #0 (exponent)
        BEQ @zero                               ;Exponent=0 <=> float=0.
        INY
        LDA (ACCU),Y                            ;Read byte #1 (mantissa, msb)
        BPL @pos                                ;If the mantissa is negative,
        LDY # $FF                               ; set ACCU=Val_Int(-1)
        STY ACCU + 1
        STY ACCU
        INY
        RTS
@pos    DEY                                     ;else
        LDA # Val_one                           ; set ACCU=Val_Int(1)
        BNE @store                              ; BNE=JMP.
@zero   LDA # Val_zero                          ;Zero: set ACCU=Val_Int(0).
@store  STA ACCU
        STY ACCU + 1
        RTS                                     ;Y=0 at exit.
}

!ifdef caml_PRIM__caml_neg_float {
caml_neg_float
        LDA ACCU
        STA caml_float_loadFAC__addr
        LDA ACCU + 1
        STA caml_float_loadFAC__addr + 1
        JSR caml_float_loadFAC
        +caml_JSR_BASROM C64_NEGOP
        JMP caml_float_alloc_result
}

!ifdef caml_PRIM__caml_abs_float {
caml_abs_float
        LDA ACCU
        STA caml_float_loadFAC__addr
        LDA ACCU + 1
        STA caml_float_loadFAC__addr + 1
        JSR caml_float_loadFAC
        +caml_JSR_BASROM C64_ABS
        JMP caml_float_alloc_result
}

!ifdef caml_PRIM__caml_exp_float {
caml_exp_float
        LDA ACCU
        STA caml_float_loadFAC__addr
        LDA ACCU + 1
        STA caml_float_loadFAC__addr + 1
        JSR caml_float_loadFAC
        +caml_JSR_BASROM C64_EXP
        JMP caml_float_alloc_result
}

!ifdef caml_PRIM__caml_expm1_float {
caml_expm1_float
        LDA ACCU
        STA caml_float_loadFAC__addr
        LDA ACCU + 1
        STA caml_float_loadFAC__addr + 1
        JSR caml_float_loadFAC
        +caml_JSR_BASROM C64_EXP
        LDA # <C64_M1
        LDY # >C64_M1
        +caml_JSR_BASROM C64_FADD
        JMP caml_float_alloc_result
}

!ifdef caml_PRIM__caml_log_float {
caml_log_float
        LDA ACCU
        STA caml_float_loadFAC__addr
        LDA ACCU + 1
        STA caml_float_loadFAC__addr + 1
        JSR caml_float_loadFAC
        +caml_JSR_BASROM C64_LOG
        JMP caml_float_alloc_result
}

!ifdef caml_PRIM__caml_log1p_float {
caml_log1p_float
        LDA ACCU
        STA caml_float_loadFAC__addr
        LDA ACCU + 1
        STA caml_float_loadFAC__addr + 1
        JSR caml_float_loadFAC
        LDA # <C64_ONE
        LDY # >C64_ONE
        +caml_JSR_BASROM C64_FADD
        +caml_JSR_BASROM C64_LOG
        JMP caml_float_alloc_result
}

!ifdef caml_PRIM__caml_log10_float {
caml_log10_float
        ;; log10 x = ln x / ln 10
        LDA ACCU
        STA caml_float_loadFAC__addr
        LDA ACCU + 1
        STA caml_float_loadFAC__addr + 1
        JSR caml_float_loadFAC
        +caml_JSR_BASROM C64_LOG
        LDA # <@rln10
        LDY # >@rln10
        BNE +
@rln10  !h 7f 5e 5b d8 a9       ;1/(ln 10)
+       +caml_JSR_BASROM C64_FMUL
        JMP caml_float_alloc_result
}

!ifdef caml_PRIM__caml_sin_float {
caml_sin_float
        LDA ACCU
        STA caml_float_loadFAC__addr
        LDA ACCU + 1
        STA caml_float_loadFAC__addr + 1
        JSR caml_float_loadFAC
        +caml_JSR_BASROM C64_SIN
        JMP caml_float_alloc_result
}

!ifdef caml_PRIM__caml_cos_float {
caml_cos_float
        LDA ACCU
        STA caml_float_loadFAC__addr
        LDA ACCU + 1
        STA caml_float_loadFAC__addr + 1
        JSR caml_float_loadFAC
        +caml_JSR_BASROM C64_COS
        JMP caml_float_alloc_result
}

!ifdef caml_PRIM__caml_tan_float {
caml_tan_float
        LDA ACCU
        STA caml_float_loadFAC__addr
        LDA ACCU + 1
        STA caml_float_loadFAC__addr + 1
        JSR caml_float_loadFAC
        +caml_JSR_BASROM C64_TAN
        JMP caml_float_alloc_result
}

!ifdef caml_PRIM__caml_sqrt_float {
caml_sqrt_float
        LDA ACCU
        STA caml_float_loadFAC__addr
        LDA ACCU + 1
        STA caml_float_loadFAC__addr + 1
        JSR caml_float_loadFAC
        +caml_JSR_BASROM C64_SQR
        JMP caml_float_alloc_result
}

!ifdef caml_PRIM__caml_atan_float {
caml_atan_float
        LDA ACCU
        STA caml_float_loadFAC__addr
        LDA ACCU + 1
        STA caml_float_loadFAC__addr + 1
        JSR caml_float_loadFAC
        +caml_JSR_BASROM C64_ATN
        JMP caml_float_alloc_result
}

!ifdef caml_PRIM__caml_floor_float {
caml_floor_float
        LDA ACCU
        STA caml_float_loadFAC__addr
        LDA ACCU + 1
        STA caml_float_loadFAC__addr + 1
        JSR caml_float_loadFAC
        +caml_JSR_BASROM C64_INT
        JMP caml_float_alloc_result
}

!ifdef caml_PRIM__caml_ceil_float {
caml_ceil_float
        ;; let fl = floor x in if fl = x then fl else fl +. 1.
        LDA ACCU
        STA caml_float_loadFAC__addr
        LDA ACCU + 1
        STA caml_float_loadFAC__addr + 1
        JSR caml_float_loadFAC
        +caml_JSR_BASROM C64_INT
        LDA # ACCU
        LDY # ACCU + 1
        +caml_JSR_BASROM C64_FCOMP
        BEQ +
        LDA # <C64_ONE
        LDY # >C64_ONE
        +caml_JSR_BASROM C64_FADD
+       JMP caml_float_alloc_result
}

!ifdef caml_PRIM__caml_classify_float {
caml_classify_float
        +Val_Int ~@FP_normal, 0
        +Val_Int ~@FP_subnormal, 1
        +Val_Int ~@FP_zero, 2
        +Val_Int ~@FP_infinite, 3
        +Val_Int ~@FP_nan, 4
        LDA (ACCU),Y
        STY ACCU + 1            ;.Y = 0
        BEQ +
        LDA # @FP_normal
        STA ACCU
        RTS
+       LDA # @FP_zero
        STA ACCU
        RTS
}

!ifdef caml_PRIM__caml_int_of_float {
caml_int_of_float
        LDA ACCU
        STA caml_float_loadFAC__addr
        LDA ACCU + 1
        STA caml_float_loadFAC__addr + 1
        JSR caml_float_loadFAC
        +caml_JSR_BASROM C64_FACINX             ; result in Y(lo), A(hi)
        STY ACCU
        SEC
        ROL ACCU                        ; OCaml int repr
        ROL
        STA ACCU + 1
        LDY # 0
        RTS
}

!ifdef caml_PRIM__caml_float_of_int {
caml_float_of_int
        LDA ACCU + 1
        CMP # $80                               ;CMP + ROR = arithm. shift right
        ROR
        TAX
        ROR ACCU
        LDY ACCU
        TXA
        +caml_JSR_BASROM C64_GIVAYF
        JMP caml_float_alloc_result
}

!ifdef caml_PRIM__caml_copysign_float {
caml_copysign_float
        LDA ACCU
        STA caml_float_loadFAC__addr
        LDA ACCU + 1
        STA caml_float_loadFAC__addr + 1
        JSR caml_float_loadFAC
        LDA (SP),Y
        STA ACCU
        INY
        LDA (SP),Y
        STA ACCU + 1
        LDA (ACCU),Y                    ;.Y = 1, load 1st mantissa byte
        STA C64_FAC + 5                 ;copy it to FAC sign byte
        JMP caml_float_alloc_result
}

!ifdef caml_PRIM__caml_float_of_string {
caml_float_of_string
        LDA C64_CHRPTR
        STA TMP
        LDA C64_CHRPTR + 1
        STA TMP + 1
        LDA ACCU
        STA C64_CHRPTR
        LDA ACCU + 1
        STA C64_CHRPTR + 1
        JSR C64_CHRGOT                  ;not a BASIC ROM routine
        +caml_JSR_BASROM C64_FIN
        LDA TMP
        STA C64_CHRPTR
        LDA TMP + 1
        STA C64_CHRPTR
        JMP caml_float_alloc_result
}

!ifdef caml_PRIM__caml_ldexp_float {
        ;; compute ACCU * 2 ^ N, -255 < N < 255.
        ;; To be called with    SP[0] = Val_int(N) if N >= 0
        ;;                      SP[0] = Val_int(256-N) if N < 0
caml_ldexp_float
        LDA # Double_tag
        LDX # Double_wosize
        JSR caml_alloc
        INY
        LDA (SP),Y
        DEY
        LSR                             ;.A := Int_val(>SP[0])
        BEQ @add                        ;N >= 0 ?
        LDA (SP),Y                      ;no:
        ROR                             ;   .A := Int_val(SP[0])
        SEC
        EOR # $FF                       ;   subtract .A from exponent
        ADC (ACCU),Y                    ;   (eor/adc = inverse sbc)
        BCS @save                       ;   if underflow,
        LDA # 0                         ;   set exp = 0 (result = 0.0)
@save   STA (BLK),Y                     ;save exp byte
        BEQ +                           ;skip copy of mantissa if underflow
        LDY # 4
-       LDA (ACCU),Y                    ;copy mantissa
        STA (BLK),Y
        DEY
        BNE -
+       LDA BLK
        STA ACCU
        LDA BLK + 1
        STA ACCU + 1                    ;ACCU := BLK
        RTS
@add    LDA (SP),Y                      ;yes:
        ROR                             ;   .A := Int_val(SP[0])
        CLC
        ADC (ACCU),Y                    ;   add .A to exponent
        BCC @save                       ;   go to @save
        LDX # C64_ERR_OVERFLOW          ;   manage overflow (error)
        JMP (C64_IERROR)
}

!ifdef caml_PRIM__caml_frexp_float {
caml_frexp_float
        @NEW = BLK                      ;used by caml_alloc
        @FLO = TMP
        ;; allocate a new float with same mantissa and exp=0
        LDA # Double_tag                ;tag of new float
        LDX # Double_wosize             ;size of new float
        JSR caml_alloc                  ;alloc new float
        LDA (ACCU),Y                    ;load (biased) exponent
        PHA                             ;save it for later
        BNE @nz                         ;float is 0.0?
        STA (@NEW),Y                    ;yes: set new float exp = 0
        BEQ @pair                       ;     and go further
@nz     LDA # $80                       ;no: set new float exp = $80
        STA (@NEW),Y
        LDY # 4                         ;    then copy the mantissa
-       LDA (ACCU),Y
        STA (@NEW),Y
        DEY
        BNE -
        ;; allocate a new pair (float * int)
@pair   LDA @NEW
        STA @FLO
        LDA @NEW + 1
        STA @FLO + 1                    ;save new float ptr in @FLO
        LDA # 0                         ;tag of new pair
        LDX # 2                         ;size of new pair
        JSR caml_alloc                  ;alloc new pair
        ;; set pair elements
        LDA @FLO
        STA (@NEW),Y
        INY
        LDA @FLO + 1
        STA (@NEW),Y                    ;field0 := new float
        INY
        LDX # 0
        PLA                             ;reload biased exponent
        BNE @debias                     ;exp = 0?
        LDA # <Val_zero                 ;yes: set field1,lo := <Val_int(0)
        STA (@NEW),Y
        LDA # >Val_zero
        BEQ @fld1h                      ;     beq=jmp to set field1,hi
@debias SEC                             ;no:  compute debiased exponent
        SBC # $80
        BCS @valint                     ;     if negative,
        DEX                             ;     set hi byte = $FF
        SEC
@valint ROL                             ;compute <Val_int(exponent)
        STA (@NEW),Y                    ;field1,lo := <Val_int(exponent)
        TXA
        ROL                             ;compute >Val_int(exponent)
@fld1h  INY
        STA (@NEW),Y                    ;field1,hi := >Val_int(exponent)
        LDA @NEW
        STA ACCU
        LDA @NEW + 1
        STA ACCU + 1                    ;ACCU := new pair
        LDY # 0
        RTS
}

!ifdef caml_PRIM__caml_add_float {
caml_add_float
        LDA (SP),Y
        STA caml_float_loadFAC__addr
        INY
        LDA (SP),Y
        STA caml_float_loadFAC__addr + 1
        JSR caml_float_loadFAC
        LDA ACCU
        STA caml_float_loadARG__addr
        LDA ACCU + 1
        STA caml_float_loadARG__addr + 1
        JSR caml_float_loadARG
        +caml_JSR_BASROM C64_FADDT
        JMP caml_float_alloc_result
}

!ifdef caml_PRIM__caml_sub_float {
caml_sub_float
        LDA (SP),Y
        STA caml_float_loadFAC__addr
        INY
        LDA (SP),Y
        STA caml_float_loadFAC__addr + 1
        JSR caml_float_loadFAC
        LDA ACCU
        STA caml_float_loadARG__addr
        LDA ACCU + 1
        STA caml_float_loadARG__addr + 1
        JSR caml_float_loadARG
        +caml_JSR_BASROM C64_FSUBT
        JMP caml_float_alloc_result
}

!ifdef caml_PRIM__caml_mul_float {
caml_mul_float
        LDA (SP),Y
        STA caml_float_loadFAC__addr
        INY
        LDA (SP),Y
        STA caml_float_loadFAC__addr + 1
        JSR caml_float_loadFAC
        LDA ACCU
        STA caml_float_loadARG__addr
        LDA ACCU + 1
        STA caml_float_loadARG__addr + 1
        JSR caml_float_loadARG
        +caml_JSR_BASROM C64_FMULT
        JMP caml_float_alloc_result
}

!ifdef caml_PRIM__caml_div_float {
caml_div_float
        LDA (SP),Y
        STA caml_float_loadFAC__addr
        INY
        LDA (SP),Y
        STA caml_float_loadFAC__addr + 1
        JSR caml_float_loadFAC
        LDA ACCU
        STA caml_float_loadARG__addr
        LDA ACCU + 1
        STA caml_float_loadARG__addr + 1
        JSR caml_float_loadARG
        +caml_JSR_BASROM C64_FDIVT
        JMP caml_float_alloc_result
}

!ifdef caml_PRIM__caml_power_float {
caml_power_float
        LDA (SP),Y
        STA caml_float_loadFAC__addr
        INY
        LDA (SP),Y
        STA caml_float_loadFAC__addr + 1
        JSR caml_float_loadFAC
        LDA ACCU
        STA caml_float_loadARG__addr
        LDA ACCU + 1
        STA caml_float_loadARG__addr + 1
        JSR caml_float_loadARG
        +caml_JSR_BASROM C64_FPWRT
        JMP caml_float_alloc_result
}

!ifdef caml_PRIM__caml_float_alloc_result {
caml_float_alloc_result
        ;; store result in a new allocated float
        LDA # Double_tag
        LDX # Double_wosize
        LDY # 0
        JSR caml_alloc
        LDX BLK
        LDY BLK + 1
        +caml_JSR_BASROM C64_MOVMF
        LDA BLK
        STA ACCU
        LDA BLK + 1
        STA ACCU + 1
        LDY # 0
        RTS
}

!ifdef caml_PRIM__caml_float_loadFAC {
        ;; how to use:
        ;; 1) set  caml_float_loadFAC__addr
        ;; 2) call caml_float_loadFAC
caml_float_loadFAC
        LDX # 4
caml_float_loadFAC__addr = * + 1
-       LDA .dummy,X            ;SMC: replaced with real address
        STA C64_FAC,X
        DEX
        BPL -
        LDA C64_FAC + 1         ;copy 1st byte of mantissa
        STA C64_FAC + 5         ;to FAC sign byte
        ORA # $80
        STA C64_FAC + 1         ;set 1st bit of mantissa = 1
        INX
        STX C64_FACRND          ;FAC round byte := 0
        RTS
}

!ifdef caml_PRIM__caml_float_loadARG {
        ;; how to use:
        ;; 1) set  caml_float_loadARG__addr
        ;; 2) call caml_float_loadARG
caml_float_loadARG
        LDX # 4
caml_float_loadARG__addr = * + 1
-       LDA .dummy,X            ;SMC: replaced with real address
        STA C64_ARG,X
        DEX
        BPL -
        LDX C64_ARG + 1         ;copy 1st byte of mantissa
        STX C64_ARG + 5         ;to ARG sign byte
        TXA
        EOR C64_FAC + 5         ;compare with FAC sign byte
        STA C64_ARISGN          ;store result of comparison
        TXA
        ORA # $80
        STA C64_ARG + 1         ;set 1st bit of mantissa = 1
        LDA C64_FAC             ;.A := FAC exponent
        RTS
}

}      ;; !zone caml_FLOATS

