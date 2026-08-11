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
;;; COMPARISONS
;;; -----------------------------------------------------------

!zone caml_COMPARISONS {

!ifndef caml_compare_warn {
caml_compare_warn
  !warn "TODO: caml_compare_val_custom_tag"
  !warn "TODO: caml_compare_val_double_array_tag"
  !warn "TODO: caml_compare_val_object_tag"
}

.dummy = $1234                                  ;dummy address for SMC
        
!macro  beq .adr { BNE + : JMP .adr :+ }        ;Long branch if equal
!macro  bne .adr { BEQ + : JMP .adr :+ }        ;Long branch if not equal

.V1     = ACCU                                  ;word, 1st argument
.V2     = TMP                                   ;word, 2nd argument
.SAVESP = TMP + 2                               ;word, SP backup
.CMP    = TMP + 4                               ;byte, result/temp
.COMPARE= TMP + 5                               ;byte, total ordering flag
.FLTMP  = TMP + 6                               ;5 bytes, float temp area
        ;; TMP + 11 ...                         ;free

        ;;
        ;; int
        ;;

!ifdef caml_PRIM__caml_int_compare {
caml_int_compare
        LDA ACCU + 1                            ;Compare hi bytes by subtraction
        INY
        SEC
        SBC (SP),Y
        BEQ ++                                  ;if A = arg0h-arg1h <> 0 then
        BVC +                                   ;  A_7 <- N xor V
        EOR #$80                                ;  (A_7=1 <==> arg0 < arg1)
+       STA ACCU + 1                            ;  store it in ACCUh
        DEY
        RTS                                     ;  exit (ACCUl unchanged);      
++      DEY                                     ;else
        LDA (SP),Y                              ;  compare lo bytes
        CMP ACCU                                ;  (C=1 <==> arg0 <= arg1)
        BEQ caml_return_zero                    ;  if equal, return Val_zero;
        ROR ACCU + 1                            ;  else rotate C -> ACCUh_7
        RTS                                     ;  and exit (ACCUl unchanged);
}

        ;;
        ;; floats
        ;;

!ifdef caml_PRIM__caml_eq_float {
caml_eq_float
        JSR caml_compare_identity_setV2
        BEQ caml_return_true
        JSR caml_compare_val_double_tag
        BEQ caml_return_true
        BNE caml_return_false
}

!ifdef caml_PRIM__caml_neq_float {
caml_neq_float
        JSR caml_compare_identity_setV2
        BEQ caml_return_false
        JSR caml_compare_val_double_tag
        BEQ caml_return_false
        BNE caml_return_true
}

!ifdef caml_PRIM__caml_le_float {
caml_le_float
        JSR caml_compare_identity_setV2
        BEQ caml_return_true
        JSR caml_compare_val_double_tag
        BMI caml_return_true
        BPL caml_return_false
}

!ifdef caml_PRIM__caml_lt_float {
caml_lt_float
        JSR caml_compare_identity_setV2
        BEQ caml_return_false
        JSR caml_compare_val_double_tag
        BMI caml_return_true
        BPL caml_return_false
}

!ifdef caml_PRIM__caml_ge_float {
caml_ge_float
        JSR caml_compare_identity_setV2
        BEQ caml_return_true
        JSR caml_compare_val_double_tag
        BMI caml_return_false
        BPL caml_return_true
}

!ifdef caml_PRIM__caml_gt_float {
caml_gt_float
        JSR caml_compare_identity_setV2
        BEQ caml_return_false
        JSR caml_compare_val_double_tag
        BMI caml_return_false
        BPL caml_return_true
}

!ifdef caml_PRIM__caml_float_compare {
caml_float_compare
        JSR caml_compare_identity_setV2
        BEQ caml_return_zero
        JSR caml_compare_val_double_tag
        JMP caml_compare_set_result
}

        ;;
        ;; bytes/string
        ;;

!ifdef caml_PRIM__caml_bytes_equal {
caml_bytes_equal = caml_string_equal
}
!ifdef caml_PRIM__caml_string_equal {
caml_string_equal
        JSR caml_compare_identity_setV2
        BEQ caml_return_true
        JSR caml_string_eq_neq
        BEQ caml_return_true
        BNE caml_return_false
}

!ifdef caml_PRIM__caml_bytes_notequal {
caml_bytes_notequal = caml_string_notequal
}
!ifdef caml_PRIM__caml_string_notequal {
caml_string_notequal
        JSR caml_compare_identity_setV2
        BEQ caml_return_false
        JSR caml_string_eq_neq
        BEQ caml_return_false
        BNE caml_return_true
}

;;; --------------------------------------      ;Auxiliary routines for saving
!ifdef  caml_PRIM__caml_return_true {           ;the comparison result in ACCU.
caml_return_true                                ;Placed here due to the branch
        STY ACCU + 1                            ;offset limitations.
        LDA # <Val_true
        STA ACCU
        RTS
}

!ifdef  caml_PRIM__caml_return_false {
caml_return_false
        STY ACCU + 1
        LDA # <Val_false
        STA ACCU
        RTS
}

!ifdef  caml_PRIM__caml_return_zero {
caml_return_zero=caml_return_false
}
;;; --------------------------------------

!ifdef caml_PRIM__caml_bytes_lessthan {
caml_bytes_lessthan = caml_string_lessthan
}
!ifdef caml_PRIM__caml_string_lessthan {
caml_string_lessthan
        JSR caml_compare_identity_setV2
        BEQ caml_return_false
        JSR caml_compare_val_string_tag
        BMI caml_return_true
        BPL caml_return_false
}

!ifdef caml_PRIM__caml_bytes_greaterequal {
caml_bytes_greaterequal = caml_string_greaterequal
}
!ifdef caml_PRIM__caml_string_greaterequal {
caml_string_greaterequal
        JSR caml_compare_identity_setV2
        BEQ caml_return_true
        JSR caml_compare_val_string_tag
        BMI caml_return_false
        BPL caml_return_true
}

!ifdef caml_PRIM__caml_bytes_lessequal {
caml_bytes_lessequal = caml_string_lessequal
}
!ifdef caml_PRIM__caml_string_lessequal {
caml_string_lessequal
        JSR caml_compare_identity_setV2
        BEQ caml_return_true
        JSR caml_compare_val_string_tag
        BMI caml_return_true
        BPL caml_return_false
}

!ifdef caml_PRIM__caml_bytes_greaterthan {
caml_bytes_greaterthan = caml_string_greaterthan
}
!ifdef caml_PRIM__caml_string_greaterthan {
caml_string_greaterthan
        JSR caml_compare_identity_setV2
        BEQ caml_return_false
        JSR caml_compare_val_string_tag
        BMI caml_return_false
        BPL caml_return_true
}

!ifdef caml_PRIM__caml_bytes_compare {
caml_bytes_compare = caml_string_compare
}
!ifdef caml_PRIM__caml_string_compare {
caml_string_compare
        JSR caml_compare_identity_setV2
        BEQ caml_return_zero
        JSR caml_compare_val_string_tag
        JMP caml_compare_set_result
}

        ;;
        ;; polymorphic comparisons
        ;;

!ifdef caml_PRIM__caml_equal {
caml_equal
        JSR caml_compare_val
        BNE caml_return_false
        BEQ caml_return_true
}

!ifdef caml_PRIM__caml_notequal {
caml_notequal
        JSR caml_compare_val
        BNE caml_return_true
        BEQ caml_return_false
}

!ifdef caml_PRIM__caml_lessthan {
caml_lessthan
        JSR caml_compare_val
        BPL caml_return_false
        BMI caml_return_true
}

!ifdef caml_PRIM__caml_greaterequal {
caml_greaterequal
        JSR caml_compare_val
        BPL caml_return_true
        BMI caml_return_false
}

!ifdef caml_PRIM__caml_lessequal {
caml_lessequal
        JSR caml_compare_val
        BMI caml_return_true
        BNE caml_return_false
        BEQ caml_return_true
}

!ifdef caml_PRIM__caml_greaterthan {
caml_greaterthan
        JSR caml_compare_val
        BMI caml_return_false
        BNE caml_return_true
        BEQ caml_return_false
}

!ifdef caml_PRIM__caml_compare {
caml_compare
        INY                                     ;set .COMPARE=1
        JSR caml_compare_val
        ;; FALLTHROUGH caml_compare_set_result
}

!ifdef caml_PRIM__caml_compare_set_result {
caml_compare_set_result
        BPL +
        LDA # -1
        STA ACCU
        STA ACCU + 1
        RTS
+       SEC
        ROL
        STA ACCU
        STY ACCU + 1
        RTS
}

!ifdef caml_PRIM__caml_compare_identity_setV2 {
caml_compare_identity_setV2
        ;; check if ACCU == SP[0] (physical identity)
        ;; yes: return Z = 1
        ;; no:  return Z = 0, .V2 = SP[0]
        LDA (SP),Y
        TAX
        INY
        LDA (SP),Y
        DEY
        CPX .V1
        BNE +
        CMP .V1 + 1
        BNE +
        RTS
+       STX .V2
        STA .V2 + 1
        RTS
}

!ifdef caml_PRIM__caml_compare_val {
caml_compare_val
        ;; Compare values in ACCU and SP[0].
        ;; PREREQUISITE: Y <> 0 if called by caml_compare, Y = 0 otherwise.
        ;; Result: A </=/> 0 according to the OCaml semantics of compare.
        ;; Status byte is set according to A.
        STY .COMPARE                            ;Y <> 0 iif called by caml_compare
        LDY # 0
        LDA SP
        STA .SAVESP
        LDA SP + 1
        STA .SAVESP + 1
        LDA (SP),Y
        STA .V2
        INY
        LDA (SP),Y
        STA .V2 + 1
.loop   LDY # 0
        STY .CMP
        LDA .V1 + 1
        LDX .V1
        CPX .V2
        BEQ .eq_tst
        SBC .V2 + 1
.neq    BVC +                                   ;(signed) v1<v2 iif V xor N = 1
        ORA # $80
+       BMI +
        INC .CMP                                ;v1 > v2 => CMP := 1
        BNE .int_or_block                       ;bne=jmp
+       DEC .CMP                                ;v1 < v2 => CMP := -1
        BNE .int_or_block                       ;bne=jmp
.eq_tst SBC .V2 + 1
        BNE .neq
        CMP .COMPARE                            ;v1==v2; called by caml_compare?
        BEQ .int_or_block                       ;no: go deep, maybe raise exn :(
        JMP .next_item                          ;yes: speed up, go to next_item
.int_or_block
        TXA
        BIT caml_is_block
        BEQ .v1_block
        LDA .V2
        BIT caml_is_block
        BEQ .v1_int_v2_block
        LDA .CMP
        JMP .return_or_next
.v1_int_v2_block
        LDY # -2
        DEC .V2 + 1
        LDA (.V2),Y                             ;A := Tag(v2)
        INC .V2 + 1
        CMP # Forward_tag                       ;check for special cases
        BEQ .v2_forward
        CMP # Custom_tag
        BEQ .v2_custom
        LDA # -1
        JMP .return                             ;int < block => RETURN LESS
.v2_forward
        LDY # 1
        LDA (.V2),Y                             ;v2 := Field(v2,0)
        TAX
        DEY
        LDA (.V2),Y
        STX .V2 + 1
        STA .V2
        JMP .loop                               ;continue
.v2_custom
        LDY # 1
        LDA (.V2),Y                             ;load jmptbl address
        STA .v2jsr + 2
        DEY
        LDA (.V2),Y
        STA .v2jsr + 1
.v2jsr  JSR .dummy                              ;call custom_compare, res. in A
        JMP .return_or_next
.v1_block
        LDA .V2
        BIT caml_is_block
        BEQ .v1_block_v2_block
        LDY # -2                                ;v1:block, v2:int
        DEC .V1 + 1
        LDA (.V1),Y                             ;A := Tag(v1)
        INC .V1 + 1
        CMP # Forward_tag                       ;check for special cases
        BEQ .v1_forward
        CMP # Custom_tag
        BEQ .v1_cust_tst
        LDA # 1
        JMP .return                             ;block > int => RETURN GREATER
.v1_forward
        LDY # 1
        LDA (.V1),Y                             ;v1 := Field(v1,0)
        TAX
        DEY
        LDA (.V1),Y
        STX .V1 + 1
        STA .V1
        JMP .loop                               ;continue
.v1_cust_tst
        LDY # 1
        LDA (.V1),Y                             ;load jmptbl address
        STA .v1jsr + 2
        DEY
        LDA (.V1),Y
        STA .v1jsr + 1
.v1jsr  JSR .dummy                              ;call custom_compare, res. in A
        JMP .return_or_next
.v1_block_v2_block
        LDY # -2
        DEC .V1 + 1
        DEC .V2 + 1
        LDA (.V2),Y
        TAX                                     ;X := Tag_v2
        LDA (.V1),Y                             ;A := Tag_v1
        INC .V1 + 1
        INC .V2 + 1
        CMP # Forward_tag
        BEQ .v1_forward                         ;jump if Tag_v1=Forward_tag
        CPX # Forward_tag
        +beq .v2_forward                        ;jump if Tag_v2=Forward_tag
        STX .CMP
        SEC
        SBC .CMP
        BEQ .switch_on_tag                      ;Tag_v1=Tag_v2 =>choose routine
        JMP .return                             ;Tag_v1!=Tag_v2=>RETURN
.switch_on_tag
        CPX # String_tag                        ;dichotomic switch
        BCC .t249
        BNE .t254
        JSR caml_compare_val_string_tag
        JMP .return_or_next
.t249   CPX # Infix_tag
        BCC .t247
        BNE +
-       +caml_raise Invalid_argument, "compare: functional value"
+       +caml_raise Invalid_argument, "compare: abstract value"
.t247   CPX # Closure_tag
        BCC .default
        BEQ -
        JSR caml_compare_val_object_tag
        JMP .return_or_next
.t254   CPX # Double_array_tag
        BCC .t253
        BNE .t255
        JSR caml_compare_val_double_array_tag
        JMP .return_or_next
.t253   JSR caml_compare_val_double_tag
        JMP .return_or_next
.t255   JSR caml_compare_val_custom_tag
        JMP .return_or_next
.default
        ;; compare sizes first
        LDY # -1
        DEC .V1 + 1
        DEC .V2 + 1
        LDA (.V1),Y                             ;A := size(v1)
        TAX                                     ;save it
        SEC
        SBC (.V2),Y                             ;A := size(v1) - size(v2)
        BNE .return                             ;A <> 0 ==> return(A)
        TXA                                     ;reload size(v1)
        BEQ .next_item                          ;v1, v2 atoms ==> next_item
        INC .V1 + 1
        INC .V2 + 1
        DEX                                     ;only one field?
        BEQ .field0                             ;yes:compare Fld(v1,0) Fld(v2,0)
        +caml_grow_stack 3                      ;no: save data on stack:
        LDY # 0
        CLC
        LDA .V1
        ADC # 2
        STA (SP),Y
        INY
        LDA .V1 + 1
        ADC # 0
        STA (SP),Y                              ;address of Field(v1,1) in SP[0]
        INY
        CLC
        LDA .V2
        ADC # 2
        STA (SP),Y
        INY
        LDA .V2 + 1
        ADC # 0
        STA (SP),Y                              ;address of Field(v2,1) in SP[1]
        INY
        DEX                                     ;# of following fields in SP[2]
        TXA
        STA (SP),Y
.field0 LDY # 0
        LDA (.V1),Y                             ;get <Field(v1,0)
        TAX                                     ;save it
        LDA (.V2),Y                             ;get <Field(v2,0)
        STA .CMP                                ;save it
        INY
        LDA (.V1),Y                             ;get >Field(v1,0)
        STA .V1 + 1                             ;.V1 + 1 :=  >Field(v1,0)
        LDA (.V2),Y                             ;get >Field(v2,0)
        STA .V2 + 1                             ;.V2 + 1  := >Field(v2,0)
        STX .V1                                 ;.V1 := Field(v1,0)
        LDA .CMP
        STA .V2                                 ;.V2 := Field(v2,0)
        JMP .loop                               ;continue comparison on v1, v2
.return_or_next
        ORA # 0                                 ;set status byte according to A
        BEQ .next_item                          ;if A=0 then compare nexts
.return LDX .SAVESP                             ;else
        STX SP                                  ; restore SP
        LDX .SAVESP + 1
        STX SP + 1
        LDY # 0
        ORA # 0                                 ; set status byte according to A
        RTS                                     ; exit
.next_item
        LDA SP                                  ;if SP = .SAVESP
        CMP .SAVESP
        BNE +
        LDA SP + 1
        CMP .SAVESP + 1
        BNE +
        LDA # 0                                 ;then RETURN EQUAL
        BEQ .return                             ;BEQ=JMP
+       LDY # 0                                 ;else get next item from stack:
        LDA (SP),Y                              ;V1 := SP[0] (lo byte)
        STA .V1
        CLC
        ADC # 2
        STA (SP),Y                              ;SP[0] := &next field (lo byte)
        INY
        LDA (SP),Y                              ;as above, hi byte
        STA .V1 + 1
        ADC # 0
        STA (SP),Y
        INY
        LDA (SP),Y                              ;V2 := SP[1] (lo byte)
        STA .V2
        CLC
        ADC # 2
        STA (SP),Y                              ;SP[1] := &next field (lo byte)
        INY
        LDA (SP),Y                              ;as above, hi byte
        STA .V2 + 1
        ADC # 0
        STA (SP),Y
        INY
        LDA (SP),Y                              ;get counter of remaining fields
        BEQ +                                   ;if counter = 0, continue loop
        SEC
        SBC # 1                                 ;else decrement the counter
        STA (SP),Y
        CLC
        LDA # 6
        ADC SP
        STA SP
        BCC +
        INC SP + 1                              ;and pop items from stack
+       LDY # 1                                 ;get curr. Fld(v1,x), Fld(v2,x)
        LDA (.V1),Y
        TAX
        LDA (.V2),Y
        STA .CMP
        DEY
        LDA (.V1),Y
        STA .V1
        STX .V1 + 1
        LDA (.V2),Y
        STA .V2
        LDA .CMP
        STA .V2 + 1
        JMP .loop                               ;continue loop
}

!ifdef caml_PRIM__caml_compare_val_double_tag {
caml_compare_val_double_tag
        ;; Compare floats in ACCU and SP[0].
        ;; Result: A </=/> 0 according to the OCaml semantics of compare.
        ;; Status byte is set according to A.
        LDA .V1
        STA caml_float_loadFAC__addr
        LDA .V1 + 1
        STA caml_float_loadFAC__addr + 1
        JSR caml_float_loadFAC
        LDY .V2 + 1
        LDA .V2
        +caml_JSR_BASROM C64_FCOMP
        LDY # 0
        ORA # 0                                 ;set status byte according to A
        RTS
}

!ifdef caml_PRIM__caml_compare_val_string_tag {
caml_compare_val_string_tag
        ;; Compare strings in ACCU and SP[0].
        ;; Result: A </=/> 0 according to the OCaml semantics of compare.
        ;; Status byte is set according to A.
        LDY # -1
        DEC .V1 + 1
        DEC .V2 + 1
        LDA (.V1),Y
        TAX
        SEC
        SBC (.V2),Y
        STA .CMP                                ;CMP = size(v1) - size(v2)
        BCC +
        LDA (.V2),Y
        TAX                                     ;X := min(size(v1), size(v2))
+       INY                                     ;Y := 0
--      INC .V1 + 1                             ;for Y := 0 to X - 1 {
        INC .V2 + 1                             ;  compare char by char:
-       DEX
        BEQ ++
        LDA (.V1),Y                             ;  1st byte
        CMP (.V2),Y
        BCC @lt
        BNE @gt
        INY
        LDA (.V1),Y                             ;  2nd byte
        CMP (.V2),Y
        BCC @lt
        BNE @gt
        INY
        BNE -
        BEQ --                                  ;}
++      LDA (.V1),Y                             ;last word, 1st char
        CMP (.V2),Y
        BCC @lt
        BNE @gt
                                                ;(sub)strings are =, return CMP
        LDA .CMP                                ;CMP is size(v1)-size(v2),
        BNE +                                   ;if CMP = 0, adjust result
        INY                                     ;according to string paddings:
        CLC                                     ;len_v1-len_v2=-pad_v1+pad_v2
        ADC (.V2),Y
        SEC
        SBC (.V1),Y
+       LDY # 0
        ORA # 0                                 ;set status byte according to A
        RTS
@lt     LDY # 0
        LDA # -1
        RTS
@gt     LDY # 0
        LDA # 1
        RTS
}

!ifdef caml_PRIM__caml_compare_val_custom_tag {
caml_compare_val_custom_tag
        ;; Compare custom values in ACCU and SP[0].
        ;; Result: A </=/> 0 according to the OCaml semantics of compare.
        ;; Status byte is set according to A.
        +caml_raise Not_found
}

!ifdef caml_PRIM__caml_compare_val_double_array_tag {
caml_compare_val_double_array_tag
        ;; Compare floatarrays in ACCU and SP[0].
        ;; Result: A </=/> 0 according to the OCaml semantics of compare.
        ;; Status byte is set according to A.
        +caml_raise Not_found
}

!ifdef caml_PRIM__caml_compare_val_object_tag {
caml_compare_val_object_tag
        ;; Compare objects in ACCU and SP[0].
        ;; Result: A </=/> 0 according to the OCaml semantics of compare.
        ;; Status byte is set according to A.
        +caml_raise Not_found
}

!ifdef caml_PRIM__caml_string_eq_neq {           ;caml_compare_val_string_tag is
caml_string_eq_neq                              ; slower for equality tests
        LDY # -1
        DEC .V1 + 1
        DEC .V2 + 1
        LDA (.V1),Y
        CMP (.V2),Y
        BNE @neq
        TAX
        INY                                     ;Y := 0
--      INC .V1 + 1                             ;loop:
        INC .V2 + 1                             ; compare strings chr by chr
-       DEX
        BEQ +
        LDA (.V1),Y                             ;1st byte
        CMP (.V2),Y
        BNE @neq
        INY
        LDA (.V1),Y                             ;2nd byte
        CMP (.V2),Y
        BNE @neq
        INY
        BEQ --
        BNE -
+       LDA (.V1),Y                             ;last word, 1st char
        CMP (.V2),Y
        BNE @neq
        LDY # 0
        TYA
        RTS
@neq    LDY # 0
        LDA # -1
        RTS
}

}       ;; !zone caml_COMPARISONS
