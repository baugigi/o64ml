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

!zone caml_RUNTIME {
caml_runtime

        .dummy = $1234                          ;dummy arg. for self-modifying
                                                ;code (SMC in comments)

!macro  caml_NEXT {                             ;process next instruction
  !ifdef caml_INTERP {
                JMP caml_interp_fetch
  } else {
        RTS
}}

!macro  caml_JMP_CODEPTR @code {                ;jump to @code pointer
  !ifdef caml_INTERP {
                JMP caml_interp_fetch
  } else {
        JMP (@code)
}}

!macro  caml_grow_stack .w {                    ;Increase stack by .w words,
        LDA SP                                  ;.w < 128.
  !if .w = 1 {
        BNE +
        DEC SP + 1
        LDA SP + 1
        CMP # >caml_stack_start
        BCS +
        JMP caml_stack_overflow
+       DEC SP
        DEC SP
  } else {
        SEC
        SBC # 2 * .w
        STA SP
        BCS +
        DEC SP + 1
        LDA SP + 1
        CMP # >caml_stack_start
        BCS +
        JMP caml_stack_overflow
+ }}

caml_stack_overflow
        +caml_raise Stack_overflow
        
;; -----------------------------------------------------------------------------
;; The following routines are common to native code and bytecode interpretation.
;; They are annotated with (sort of!) Hoare Triples to highlight which
;; conditions must be met at entry and which will stand at exit (beware of Y<>0,
;; see the comment at caml_init in loader.asm).
;; Annotations refer to native code (caml_INTERP=<undef>).
;; Code to be assembled only ifdef caml_INTERP is indented a tab-stop more.
;; -----------------------------------------------------------------------------

ACCL
!ifdef caml_gen_ACCL {                  ;{Y = <2n}
        LDA (SP),Y                              ;Read SP[n], lo byte
        STA ACCU                                ;and save it in ACCU
        INY                                     ;Increment index
        LDA (SP),Y                              ;Read SP[n], hi byte
        STA ACCU + 1                            ;and save it in ACCU+1
        LDY # 0                                 ;Reset Y
        +caml_NEXT                      ;{Y = 0}
}

ACCH
!ifdef caml_gen_ACCH {
  !ifdef caml_INTERP {
                JSR caml_interp_getarg
                STA TMP
                JSR caml_interp_getarg
                LDY TMP
  }                                     ;{A = >2n, Y = <2n}
        LDX SP + 1                              ;Save SP+1
        CLC                                     ;Prepare ADC
        ADC SP + 1                              ;Add >2n to SP+1
        STA SP + 1                              ;Save result
        LDA (SP),Y                              ;Read SP[n], lo byte
        STA ACCU                                ;and save it in ACCU
        INY                                     ;Increment index
        LDA (SP),Y                              ;Read SP[n], hi byte
        STA ACCU + 1                            ;and save it in ACCU+1
        LDY # 0                                 ;Reset Y
        STX SP + 1                              ;Restore SP+1
        +caml_NEXT                      ;{Y = 0}
}

PUSH
!ifdef caml_gen_PUSH {                  ;{Y = 0}
        LDA SP                                  ;Read the stack pointer, lo
        BNE +                                   ;If zero
        DEC SP + 1                              ;then decrement the stack ptr, hi
        LDA SP + 1
        CMP # >caml_stack_start
        BCS +
        JMP caml_stack_overflow
+       DEC SP                                  ;Decrement the stack pointer, lo
        LDA ACCU + 1                            ;Copy ACCU + 1
        STA (SP),Y                              ;to SP[0], hi byte
        DEC SP                                  ;Decrement the stack pointer, lo
        LDA ACCU                                ;Copy ACCU
        STA (SP),Y                              ;to SP[0], lo byte
        ;; No +caml_NEXT here! Always called by JSR
        RTS                             ;{X = x, Y = 0}
}

PHACC
!ifdef caml_gen_PHACC {
                JSR PUSH
                JMP ACCH
}

POP1
!ifdef caml_gen_POP1 {                  ;{Y = y}
        INC SP                                  ;Increment stack pointer, lo
        INC SP                                  ;twice (n.b. word aligned)
        BNE +                                   ;If page has been crossed
        INC SP + 1                              ;then increment pointer, hi
+       +caml_NEXT                      ;{Y = y}
}

POPN
!ifdef caml_gen_POPN {
  !ifdef caml_INTERP {
                JSR caml_interp_getarg
                TAX
                JSR caml_interp_getarg
                TAY
                TXA
  }                                     ;{A = <2n, Y = >2n}
        CLC                                     ;Prepare ADC
        ADC SP                                  ;Increment the stack pointer, lo
        STA SP                                  ;by <2n
        TYA                                     ;Set A to >2n
        ADC SP + 1                              ;Increment the stackpointer, hi
        STA SP + 1                              ;by >2n
        LDY # 0                                 ;Reset Y
        +caml_NEXT                      ;{Y = 0}
}

ASSIGNH
!ifdef caml_gen_ASSIGNH {
  !ifdef caml_INTERP {
                JSR caml_interp_getarg
                STA TMP
                JSR caml_interp_getarg
                LDY TMP
  }                                     ;{A = >2n, Y = <2n, SP+1 = x}
        LDX SP + 1                              ;Save SP+1, caller'll restore it
        CLC                                     ;Prepare ADC
        ADC SP + 1                              ;Add >2n to SP+1
        STA SP + 1                              ;and save it
}       ;; fallthrough ASSIGNL

ASSIGNL
!ifdef caml_gen_ASSIGNL {               ;{A = >2n, Y = <2n, SP+1 = x}
        LDA ACCU                                ;Copy ACCU
        STA (SP),Y                              ;to SP[n], lo byte
        INY                                     ;Increment index
        LDA ACCU + 1                            ;Copy ACCU+1
        STA (SP),Y                              ;to SP[n], hi byte
        LDA # <Val_unit                         ;Set ACCU
        STA ACCU                                ;to Val_unit, lo byte
        LDY # 0                                 ;Set ACCU+1
        STY ACCU + 1                            ;to Val_unit, hi byte
  !ifdef caml_INTERP {
                STX SP + 1
  }
        +caml_NEXT                      ;{X = x, Y = 0}
}

ENVACC      
!ifdef caml_gen_ENVACC {                ;{Y = <2n}
        LDA (ENV),Y
        STA ACCU
        INY
        LDA (ENV),Y
        STA ACCU + 1
        LDY # 0
        +caml_NEXT                      ;{Y = 0}
}

;; PUSHRETADDR and APPLY n, APPLY1, APPLY2, APPLY3:
;;
;; A closure application to n arguments is usually compiled by ocamlc by
;; emitting a PUSHRETADDR (which pushes the return address onto the stack),
;; followed by instructions that compute and push the arguments, and finally an
;; APPLY n instruction that jump to the closure code; but when n < 4, ocamlc
;; skips the PUSHRETADDR: its work is left up to APPLY1 (or APPLY2, or APPLY3).

PHRET      
!ifdef caml_gen_PHRET {
  !ifdef caml_INTERP {
                JSR caml_interp_getarg
                STA TMP
                JSR caml_interp_getarg
                TAX
  } else {                              ;{A = <adr, X = >adr, Y = 0}
        STA TMP
  }
        +caml_grow_stack 3
        LDA TMP
        STA (SP),Y                              ;STACK[0] := return address
        INY
        TXA
        STA (SP),Y
        INY
        LDA ENV                                 ;STACK[1] := ENV
        STA (SP),Y
        INY
        LDA ENV + 1
        STA (SP),Y
        INY
        LDA XARGS                               ;STACK[2] := XARGS
        STA (SP),Y
        LDY # 0
        +caml_NEXT                      ;{Y = 0}
}

APPLY13
!ifdef caml_gen_APPLY13 {
  !ifdef caml_INTERP {
                SBC # $41 -1                    ;-1 as C=0; A:=2n-1=2*opc-$41
                TAY
  }                                     ;{Y = 2n-1}
        @SP = TMP
        @N2M1 = TMP + 2
        STY @N2M1
        LDA SP                                  ;Save current SP value
        STA @SP
        LDA SP + 1
        STA @SP + 1
        +caml_grow_stack 3
-       LDA (@SP),Y                             ;Slide n arguments by 3 slots
        STA (SP),Y                              ;(it's safe to copy backwards
        DEY                                     ;because n <= 3)
        BPL -
        LDY @N2M1
        INY
  !ifdef caml_INTERP {
                LDA PC
  } else {
        PLA                                     ;get ret.addr. from hw stack
        CLC
        ADC # 1
  }
        STA (SP),Y                              ;STACK[n] := return address
        INY
  !ifdef caml_INTERP {
                LDA PC + 1
  } else {
        PLA
        ADC # 0
  }
        STA (SP),Y
        INY
        LDA ENV                                 ;STACK[n+1] := ENV
        STA (SP),Y
        INY
        LDA ENV + 1
        STA (SP),Y
        INY
        LDA XARGS                               ;STACK[n+2] := XARGS
        STA (SP),Y
        LDY @N2M1                       ;{Y = 2n-1}
}       ;; fallthrough APPLY

APPLY
!ifdef caml_gen_APPLY {
  !ifdef caml_INTERP {
                @PC = PC
  } else {
        @PC = TMP
  }                                     ;{Y = 2n-1}
        STY XARGS                               ;XARGS := Val_Int(n-1)
        LDA ACCU                                ;ENV := ACCU (&closure)
        STA ENV
        LDA ACCU + 1
        STA ENV + 1
        LDY # 1                                 ;@PC := Code(ACCU)
        LDA (ACCU),Y
        STA @PC + 1
        DEY
        LDA (ACCU),Y
        STA @PC
        +caml_JMP_CODEPTR @PC
}                                       ;{Y = 0}

APPTRMN
!ifdef caml_gen_APPTRMN {
  !ifdef caml_INTERP {
                JSR caml_interp_getarg
                TAX
                JSR caml_interp_getarg
  }                                     ;{A=2(n-1), X=2(s-n)}
        TAY
        INY                                     ;Y=2n-1
        CLC
        ADC XARGS                               ;XARGS :=
        STA XARGS                               ;  Val_Int(Int_Val(XARGS)+n-1)
  !ifdef caml_INTERP {
                JMP APPTRM1
  }     ;; ifndef caml_INTERP
}       ;; fallthrough APPTRM1

APPTRM1
!ifdef caml_gen_APPTRM1 {
  !ifdef caml_INTERP {
                @PC = PC
  } else {
        @PC = TMP
  }
        LDA SP                          ;{X=2(s-n), Y=2n-1}
        STA TMP
        LDA SP + 1
        STA TMP + 1                             ;save stack pointer
        TXA                                     ;A := 2 * (.s - .n)
        CLC
        ADC SP                                  ;Pop s elements, push n
        STA SP
        BCC +
        INC SP + 1
+:-     LDA (TMP),Y                             ;move n elements from old top
        STA (SP),Y                              ;to new one
        DEY
        BNE -
        LDA (TMP),Y
        STA (SP),Y
        LDA ACCU
        STA ENV
        LDA ACCU + 1
        STA ENV + 1                             ;ENV := ACCU (closure)
        LDA (ACCU),Y
        STA @PC
        INY
        LDA (ACCU),Y
        STA @PC + 1                             ;@PC := ACCU[0] (closure code)
        DEY
        +caml_JMP_CODEPTR @PC
}

;; RESTART and GRAB:
;;
;; GRAB checks that the caller passed enough arguments onto the stack. If not,
;; it creates a closure, stores all the available arguments in it, points the
;; closure code to the instruction just before GRAB (which is assumed to be a
;; RESTART), then returns to the caller, as if executing a RETURN instruction.
;; When the new closure is called, RESTART will push the arguments onto the
;; stack again and fallthrough GRAB.

RESTART
!ifdef caml_gen_RESTART {               ;{}
        @ENV0 = TMP
        LDA ENV                                 ;@ENV0 := ENV
        STA @ENV0
        LDA ENV + 1
        STA @ENV0 + 1
        LDY # 2
        LDA (@ENV0),Y                           ;ENV := ENV[1]
        STA ENV
        INY
        LDA (@ENV0),Y
        STA ENV + 1
        LDY # -1
        DEC @ENV0 + 1
        LDA (@ENV0),Y                           ;Get size(@ENV0)
        SEC
        SBC # 2                                 ;A := size(@ENV0)-2
        BCC +
        BNE @pharg                              ;push args
+       INY                                     ;Exit if size(@ENV0)-2 <= 0
        +caml_NEXT                      ;{Y = 0}
@pharg  INC @ENV0 + 1
        ASL
        TAY                                     ;Y := 2 * (size(@ENV0)-2)
        ;CLC                                    ;(C clear as size(@ENV0)-2<128)
        ADC XARGS                               ;Incr. XARGS by size(@ENV0)-2
        STA XARGS
        LDA SP
        STY SP
        SEC
        SBC SP
        STA SP                                  ;SP := SP - 2 * (size(@ENV0)-2)
        BCS +
        DEC SP + 1
        LDA SP + 1
        CMP # >caml_stack_start
        BCS +
        JMP caml_stack_overflow
+       CLC
        LDA # 4                                 ;@ENV0 := &Field(@ENV0, 2)
        ADC @ENV0
        STA @ENV0
        BCC +
        INC @ENV0 + 1
+       DEY
-       LDA (@ENV0),Y                           ;push args onto the stack
        STA (SP),Y
        DEY
        BNE -
        LDA (@ENV0),Y
        STA (SP),Y
        +caml_NEXT                      ;{Y = 0}
}

GRAB
!ifdef caml_gen_GRAB {
        @offset = caml_restart_len + caml_grab_len
  !ifdef caml_INTERP {
                JSR caml_interp_getarg
  }                                     ;{A = v = 2n+1, Y = 0}
        EOR # $FF
        SEC
        ADC XARGS                               ;A := XARGS - v = ~A + 1 + XARGS
        BMI @mkclos                             ;If XARGS >= v then
        ORA # 1                                 ; set XARGS's lsb
        STA XARGS                               ; XARGS := XARGS - v and exit
        +caml_NEXT                      ;{Y = 0}
@mkclos LDA XARGS                               ;Compute size = Int_Val(XARGS)
        LSR                                     ; + 3wo (CODE, ENV, and Arg1)
        ADC # 3 -1                              ; (-1 as carry set by LSR)
        TAX     
        LDA # Closure_tag                       ;BLK := new closure
        JSR caml_alloc
  !ifdef caml_INTERP {
                LDA PC                          ;Compute previous RESTART addr
                SEC                             ; =PC-(RESTART len + GRAB len).
                SBC # @offset
  } else {
        PLA                                     ;Compute previous RESTART addr
        SEC                                     ; from the ret addr on hw stack
        SBC # @offset - 1                       ; (-1 because of how JSR works).
  }
        STA (BLK),Y                             ;Field(BLK,0) := CODE
  !ifdef caml_INTERP {
                LDA PC + 1
  } else {
        PLA
        SBC # 0
  }
        INY
        STA (BLK),Y
        INY
        LDA ENV                                 ;Field(BLK,1) := ENV
        STA (BLK),Y
        INY
        LDA ENV + 1
        STA (BLK),Y
        LDA BLK + 1                             ;ACCU := BLK
        STA ACCU + 1
        LDA BLK 
        STA ACCU
        CLC                                     ;BLK := &Field(BLK,2)
        ADC # 4
        STA BLK
        BCC +
        INC BLK + 1
+       LDY XARGS                               ;Y := 2 * Int_Val(XARGS) + 1
-       LDA (SP),Y                              ;Field(ACCU, i+2) := SP[i],
        STA (BLK),Y                             ;  0 <= i <= XARGS
        DEY
        BNE -
        LDA (SP),Y
        STA (BLK),Y
        LDA SP                                  ;pop XARGS + 1 elements
        SEC                                     ;  (SEC = +1)
        ADC XARGS
        STA SP
        BCC +
        INC SP + 1
+       ;; fallthrough GORETURN         ;{Y = 0}
}

GORETURN
!ifdef caml_gen_GORETURN {
  !ifdef caml_INTERP {
                @PC = PC
  } else {                              ;{}
        @PC = TMP
  }
        LDY # 4                                 ;get return frame:
        LDA (SP),Y
        STA XARGS                               ;XARGS := STACK[2]
        DEY
        LDA (SP),Y                              ;ENV := STACK[1]
        STA ENV + 1
        DEY
        LDA (SP),Y
        STA ENV
        DEY
        LDA (SP),Y                              ;@PC := STACK[0] = ret.addr.
        STA @PC + 1
        DEY
        LDA (SP),Y
        STA @PC
        LDA # 6                                 ;pop 3 elements
        CLC
        ADC SP
        STA SP
        BCC +
        INC SP + 1
+       +caml_JMP_CODEPTR @PC
}

;; RETURN:
;;
;; A function might be called with more arguments on the stack than expected. If
;; there is any extra argument, RETURN does not give control back to the caller:
;; instead, it assumes that there is a closure in the accumulator and gives it
;; immediate control.

RETURN
!ifdef caml_gen_RETURN {
  !ifdef caml_INTERP {
                @PC = PC
                JSR caml_interp_getarg
                ORA # 0                         ;set N flag according to A
                BEQ +
  } else {                              ;{A = 2n}
        @PC = TMP
        BEQ +
        CLC
  }
        ADC SP                                  ;pop n elements
        STA SP
        BCC +
        INC SP + 1
        CLC
+       LDA XARGS                               ;If XARGS - Val_one < Val_zero
        SBC # (Val_one & $FE) -1                ;(-1 as carry is clear)
        BCC GORETURN                            ;then get return frame
        STA XARGS                               ;else XARGS := XARGS - Val_one
        LDA ACCU
        STA ENV                                 ; ENV := ACCU
        LDA ACCU + 1
        STA ENV + 1
        LDA (ACCU),Y                            ; TMP := Code(ACCU)
        STA @PC
        INY
        LDA (ACCU),Y
        STA @PC + 1
        DEY                                     ; reset Y
        +caml_JMP_CODEPTR @PC           ;{Y = 0}
}

CLOSURE
!ifdef caml_gen_CLOSURE {
        @CODE   = TMP
        @NM1    = TMP + 2
  !ifdef caml_INTERP {
                JSR caml_interp_getarg
                TAX
                JSR caml_interp_getarg
                STA @CODE
                JSR caml_interp_getarg
                STA @CODE + 1
  } else {                      ;{X = n, A = <ptr, Y = >ptr}
        STA @CODE                               ;save code pointer
        STY @CODE + 1
  }
        INX                                     ;allocate a closure block
        LDA # Closure_tag                       ;with n + 1 fields
        JSR caml_alloc
        LDA @CODE                               ;Field(BLK,0) := code pointer
        STA (BLK),Y                             ;Y=0 by caml_alloc
        INY
        LDA @CODE + 1
        STA (BLK),Y
        DEX                                     ;X := n
        BEQ +                                   ;if n > 0 then
        INY
        LDA ACCU                                ; Field(BLK,1) := ACCU
        STA (BLK),Y
        INY
        LDA ACCU + 1
        STA (BLK),Y
+       LDA BLK + 1                             ;ACCU := block address, A:=BLK
        STA ACCU + 1
        LDA BLK
        STA ACCU
        CPX # 2
        BCC ++                                  ;If n <= 1 then exit
        ADC # 4 - 1                             ;(-1 as carry is set)
        STA BLK                                 ;BLK := &Field(BLK,2)
        BCC +
        INC BLK + 1
+       DEX
        STX @NM1
        LDY # 0                                 ;for i := 0 to n - 2
-       LDA (SP),Y                              ; Field(BLK,2+i) := SP[i]
        STA (BLK),Y
        INY
        LDA (SP),Y
        STA (BLK),Y
        INY
        DEX
        BNE -
        LDA @NM1                                ;Pop n - 1 elements
        ASL
        ;CLC                                    ;C clear as 2*@NM1 < 256
        ADC SP
        STA SP
        BCC ++
        INC SP + 1
++      LDY # 0
        +caml_NEXT                      ;{Y = 0}
}

CLOSREC
!ifdef caml_gen_CLOSREC {
        @NVAR   = TMP
        @NFUN   = TMP + 1
        @ADR    = TMP + 2
  !ifdef caml_INTERP {                          ;$2c .v .f .data=fun1 [funs]
                @DATA = PC
                JSR caml_interp_getarg
                STA @NVAR
                JSR caml_interp_getarg          ;Now @DATA=PC points to .data
                STA @NFUN
  } else {                              ;{A = <.data, Y = >.data}
        @DATA = TMP + 4
        STA @DATA
        DEY
        STY @DATA + 1                           ;Now @DATA points to .data - $100
        LDY # -2                                ;Now @DATA + Y points to .v
        LDA (@DATA),Y                           ;Read .v
        STA @NVAR                               ; and save it
        INY
        LDA (@DATA),Y                           ;Read .f
        STA @NFUN                               ; and save it
        INY                                     ;Set Y = 0
        INC @DATA + 1                           ;Now @DATA points to .data
  }
        ASL                                     ;Compute the size of the
        CLC                                     ; closure block as
        ADC @NVAR                               ; 2×@NFUN+@NVAR-1 words (<=255)
        TAX                                     ;(here A may be 0 if f=128,v=0)
        DEX                                     ;(last step, X=255 if f=128,v=0)
        LDA # Closure_tag                       ;Load appropriate tag
        JSR caml_alloc                          ; and allocate the closure
        LDA @NVAR                               ;If @NVAR>0 then push ACCU on the
        BEQ +                                   ; stack (it'll be popped out and
        JSR PUSH                                ; inserted into the closure)
+       LDA BLK
        STA ACCU                                ;ACCU := closure address
        STA @ADR                                ;@ADR := closure address
        LDA BLK + 1
        STA ACCU + 1
        STA @ADR + 1
        LDX @NFUN                               ;Set loop counter
        BNE @code                               ;JMP @code (loop entry)
@ifx    LDA # Infix_tag                         ; Put an infix tag in lo byte of
        STA (BLK),Y                             ;  Field(BLK,2i-1), i=@NFUN-X+1
        INY
        TYA                                     ; Compute the offset: Y is odd,
        LSR                                     ;  LSR:ADC is (Y+1)/2="distance"
        ADC # 0                                 ;  in word from main closure;
        STA (BLK),Y                             ;  write it into hi byte.
        INY                                     ; An Y overflow may occur here:
        BNE +                                   ;  if so,
        INC BLK + 1                             ;  increment hi bytes of
        INC @DATA + 1                           ;  both pointers.
+       LDA @DATA                               ; Decrement DATA by 2
        SEC                                     ;  as only 2 bytes from the .t
        SBC # 2                                 ;  tab will be copied every 4
        STA @DATA                               ;  increments of Y index.
        BCS @code
        DEC @DATA + 1
@code   LDA (@DATA),Y                           ;Loop entry: populate fun fields
        STA (BLK),Y                             ; Load code ptr, lo by; store it
        INY                                     ;  in Field(BLK,2i-2),i=@NFUN-X+1
        LDA (@DATA),Y
        STA (BLK),Y                             ; As above, hi byte
        INY
        DEX                                     ; Decrement loop counter (i++)
        BNE @ifx                                ;Loop until X = 0 (i > @NFUN)
  !ifdef caml_INTERP {
                TYA
                CLC
                ADC PC
                STA PC                          ;PC:=@DATA+Y=PC+Y=.data+2×f
                BCC +
                INC PC + 1
+ }
        TYA                                     ;Set BLK to point to next field
        CLC
        ADC BLK
        STA BLK
        BCC +
        INC BLK + 1
+       LDX @NVAR
        BEQ @grwstk                             ;If @NVAR = 0 then exit
        LDY # 0
@vars   LDA (SP),Y                              ;Loop: copy vars from stack to
        STA (BLK),Y                             ; Fld(2f-1),…,Fld(2f+v-2)
        INY
        LDA (SP),Y
        STA (BLK),Y
        INY
        BNE +
        INC SP + 1
        INC BLK + 1
+       DEX
        BNE @vars
        TYA                                     ;Pop @NVAR elts
        CLC
        ADC SP
        STA SP
        BCC @grwstk
        INC SP + 1
@grwstk LDA @NFUN
        ASL
        TAY
        BCS +                                   ;branch if @NFUN=128
        EOR # $FF
        SEC
        ADC SP
        STA SP                                  ;SP := SP-2*@NFUN
        BCS ++
+       DEC SP + 1
        LDA SP + 1
        CMP # >caml_stack_start
        BCS ++
        JMP caml_stack_overflow
++      DEY                                     ;Init counter: Y=2*@NFUN-1
@pshadr LDA @ADR + 1                            ;Loop: push onto the stack
        STA (SP),Y                              ; each function address;
        DEY                                     ; the 1st one is in @ADR,
        BEQ +                                   ; the others are 4 bytes 
        LDA @ADR                                ; far each other,
        STA (SP),Y
        DEY
        CLC
        ADC # 4                                 ; so add 4 to @ADR at each
        STA @ADR                                ; step
        BCC @pshadr
        INC @ADR + 1
        BCS @pshadr                             ;JMP @pshadr
+       LDA @ADR                                ;Last byte
        STA (SP),Y
        +caml_NEXT                      ;{Y = 0}
}

OFSCL0
!ifdef caml_gen_OFSCL0 {
        LDA ENV                         ;{Y = y}
        STA ACCU
        LDA ENV + 1
        STA ACCU + 1                            ;ACCU := ENV
        +caml_NEXT                      ;{Y = 0}
}

OFSCLN
!ifdef caml_gen_OFSCLN {
  !ifdef caml_INTERP {
                JSR caml_interp_getarg
  }                                     ;{A = <2n, X = >2n, Y = y}
        CLC                                     ;ACCU := ENV + 2 * .n (signed)
        ADC ENV
        STA ACCU
  !ifdef caml_INTERP {
                JSR caml_interp_getarg
  } else {
        TXA
  }
        ADC ENV + 1
        STA ACCU + 1
        +caml_NEXT                      ;{Y = 0}
}

SETGLB
!ifdef caml_gen_SETGLB {
  !ifdef caml_INTERP {
                JSR caml_interp_getarg
                STA TMP
                JSR caml_interp_getarg
                STA TMP + 1
  } else {                              ;{A = <&global, X = >&global, Y = 0}
        STA TMP
        STX TMP + 1
  }
        LDA ACCU
        STA (TMP),Y
        INY
        LDA ACCU + 1
        STA (TMP),Y
        LDA # <Val_unit
        STA ACCU
        DEY
        STY ACCU + 1
        +caml_NEXT                      ;{Y = 0}
}       

MKBLK
!ifdef caml_gen_MKBLK {                 ;{A = tag, X = size, Y = 0}
        JSR caml_alloc
        LDA ACCU
        STA (BLK),Y
        INY
        LDA ACCU + 1
        STA (BLK),Y                             ;Field(newblock,0) := ACCU
        DEY                                     ;Y := 0
        LDA BLK
        STA ACCU
        LDA BLK + 1
        STA ACCU + 1                            ;ACCU := newblock
        DEX
        BEQ ++
        INC BLK                                 ;BLK -> Field(newblock,1)
        INC BLK
        BNE +
        INC BLK + 1
+:-     LDA (SP),Y                              ;copy .sz-1 elts from stack
        STA (BLK),Y
        INY
        LDA (SP),Y
        STA (BLK),Y
        INY
        BNE +
        INC SP + 1
        INC BLK + 1
+       DEX                                     ;to newblock's fields
        BNE -   
        TYA                                     ;and pop them
        BEQ ++
        CLC
        ADC SP
        STA SP
        BCC +
        INC SP + 1
+       LDY # 0
++      +caml_NEXT                      ;{Y = 0}
}

MKFBLK
!ifdef caml_gen_MKFBLK {
  !ifdef caml_INTERP {
                JSR caml_interp_getarg
                TAX
  }                                     ;{X = wosize, Y = 0}
        LDA # Double_array_tag                  ;set tag and allocate new block
        JSR caml_alloc
        +caml_move_float ACCU, BLK              ;Float(BLK):=Float(ACCU)
        LDA BLK
        STA ACCU
        LDA BLK + 1
        STA ACCU + 1                            ;ACCU := newblock
        ;; Field(ACCU,1+i...3+i) := Float(SP[i]), 0 <= i < size/Double_wosize
-       TXA
        SEC
        SBC # Double_wosize
        BEQ ++                                  ;no elements to pop
        TAX
        LDA BLK                                 ;TMP := addr of next float field
        CLC
        ADC # Double_wosize
        BCC +
        INC BLK + 1
+       LDA (SP),Y
        STA TMP
        INC SP
        LDA (SP),Y
        STA TMP + 1                             ;pop from stack
        INC SP
        BNE +
        INC SP + 1
+       +caml_move_float TMP, BLK               ;Float(BLK):=Float(TMP)
        JMP -
++      +caml_NEXT                      ;{Y = 0}
}

GETFLDN
!ifdef  caml_gen_GETFLDN {
  !ifdef caml_INTERP {
                JSR caml_interp_getarg
  }                                     ;{A = n}
        ASL
        BCC +
        INC ACCU + 1
+       TAY                             ;{Y = <2n}
}       ;; fallthrough GETFLD0

GETFLD0
!ifdef caml_gen_GETFLD0 {               ;{Y = <2n}
        LDA (ACCU),Y
        TAX
        INY
        LDA (ACCU),Y
        STX ACCU
        STA ACCU + 1
        LDY # 0
        +caml_NEXT                      ;{Y = 0}
}

SETFLDN
!ifdef caml_gen_SETFLDN {
  !ifdef caml_INTERP {
                JSR caml_interp_getarg
  }                                     ;{A = n, Y = 0}
        ASL
        BCC +
        INC ACCU + 1
        CLC
+       ADC ACCU
        STA ACCU
        BCC SETFLD0
        INC ACCU + 1
}       ;; fallthrough SETFLD0

SETFLD0
!ifdef caml_gen_SETFLD0 {               ;{Y = 0}
        LDA (SP),Y
        STA (ACCU),Y
        INY
        LDA (SP),Y
        STA (ACCU),Y
        DEY
        INC SP
        INC SP
        BNE +
        INC SP + 1
+       LDA # <Val_unit
        STA ACCU
        STY ACCU + 1
        +caml_NEXT                      ;{Y = 0}
}

GETFFLDN
!ifdef caml_gen_GETFFLDN {
  !ifdef caml_INTERP {
                JSR caml_interp_getarg
                TAX                             ;set flags according to A
                BEQ GETFFLD0
                ASL
                BCC +
                INC ACCU + 1
+ }                                     ;{A = <2n, Y = y, ACCU+1 = >&Fld(ACCU,n)}
        CLC
        ADC ACCU
        STA ACCU
        BCC +
        INC ACCU + 1                    ;{Y = y, ACCU+1:ACCU = &Field(ACCU,n)}
+
}       ;; fallthrough GETFFLD0 

GETFFLD0
!ifdef caml_gen_GETFFLD0 {
        LDX # Double_wosize
        LDA # Double_tag
        JSR caml_alloc                          ;address of new block in BLK
        +caml_move_float ACCU, BLK              ;Float(BLK):=Float(ACCU)
        LDA BLK
        STA ACCU
        LDA BLK + 1
        STA ACCU + 1                            ;ACCU := BLK
        +caml_NEXT                      ;{Y = 0}
}

SETFFLDN
!ifdef caml_gen_SETFFLDN {
  !ifdef caml_INTERP {
                JSR caml_interp_getarg
                TAX                             ;set flags according to A
                BEQ SETFFLD0
                ASL
                BCC +
                INC ACCU + 1
+ }                                     ;{A = <2n, Y = y, ACCU+1 = >&Fld(ACCU,n)}
        CLC                                     ;ACCU := &Field(ACCU, n)
        ADC ACCU
        STA ACCU
        BCC SETFFLD0
        INC ACCU + 1                    ;{Y = y, ACCU+1:ACCU = &Field(ACCU,n)}
}       ;; fallthrough SETFFLD0

SETFFLD0
!ifdef caml_gen_SETFFLD0 {
        LDA (SP),Y
        STA TMP
        INC SP
        LDA (SP),Y
        STA TMP + 1                             ;TMP := SP[0]
        INC SP
        BNE +
        INC SP + 1
+       +caml_move_float TMP, ACCU              ;Float(ACCU):=Float(TMP)
        LDA # <Val_unit                         ;ACCU := ()
        STA ACCU
        STY ACCU + 1
        +caml_NEXT                      ;{Y = 0}
}

VECLEN
!ifdef caml_gen_VECLEN {                ;{}
        LDY # -2
        DEC ACCU + 1
        LDA (ACCU),Y                            ;load Tag(ACCU)
        TAX
        INY
        LDA (ACCU),Y                            ;load size(ACCU)
        INY                                     ;reset Y
        CPX # Double_array_tag                  ;float array?
        BEQ @floats
        SEC                                     ;  no: ACCU := Val_Int(size)
        ROL
        STA ACCU
        STY ACCU + 1
        ROL ACCU + 1
        +caml_NEXT                      ;{Y = 0}
@floats STA ACCU                                ;  yes: compute A := A/3
        LSR                                     ;    (start of A/3)
        ADC # 21
        LSR
        ADC ACCU
        ROR
        LSR
        ADC ACCU
        ROR
        LSR
        ADC ACCU
        ROR
        ;LSR                                    ;    (end of A/3)
        ;ASL                                    ;    ACCU := Val_Int(size/3)
        ORA # 1                                 ;    = 2 * A/3 + 1 
        STA ACCU
        STY ACCU + 1
        +caml_NEXT                      ;{Y = 0}
}

GETVEC
!ifdef caml_gen_GETVEC {                ;{Y = 0}
        LDA (SP),Y                              ;Val_Int(index), lo
        STA TMP
        INC SP
        LDA (SP),Y                              ;Val_Int(index), hi
        BNE +
        INC ACCU + 1
+       INC SP
        BNE +
        INC SP + 1
+       LDY TMP
        LDA (ACCU),Y                            ;array[index], hi
        TAX
        DEY
        LDA (ACCU),Y                            ;array[index], lo
        STA ACCU
        STX ACCU + 1
        LDY # 0
        +caml_NEXT                      ;{Y = 0}
}

SETVEC
!ifdef caml_gen_SETVEC {                ;{Y = 0}
        LDA (SP),Y                              ;Val_Int(index), lo
        STA TMP
        INC SP
        LDA (SP),Y                              ;Val_Int(index), hi
        BNE +
        INC ACCU + 1
+       INC SP
        BNE +
        INC SP + 1
+       LDA (SP),Y                              ;value, lo
        TAX
        INC SP
        LDA (SP),Y                              ;value, hi
        INC SP
        BNE +
        INC SP + 1
+       LDY TMP
        STA (ACCU),Y                            ;set array[index], hi
        DEY
        TXA
        STA (ACCU),Y                            ;set array[index], lo
        LDY # 0                                 ;reset Y
        LDA # <Val_unit                         ;ACCU := ()
        STA ACCU
        STY ACCU + 1
        +caml_NEXT                      ;{Y = 0}
}

GETCHR
!ifdef caml_gen_GETCHR {                ;{Y = 0}
        INY
        LDA (SP),Y
        LSR
        TAX
        DEY     
        LDA (SP),Y
        ROR
        TAY                                     ;Y := <Int_Val(SP[0])
        TXA
        CLC
        ADC ACCU + 1
        STA ACCU + 1                            ;ACCU + 1 += >Int_Val(SP[0])
        LDA (ACCU),Y                            ;A := Char
        SEC
        ROL
        STA ACCU
        LDY # 0
        TYA
        ROL
        STA ACCU + 1                            ;ACCU := Val_char(Char)
        INC SP                                  ;pop
        INC SP
        BNE +
        INC SP + 1
+       +caml_NEXT                      ;{Y = 0}
}

SETCHR
!ifdef caml_gen_SETCHR {                ;{Y = 0}
        LDY # 3
        LDA (SP),Y
        LSR
        DEY
        LDA (SP),Y
        ROR
        STA TMP                                 ;TMP := Char_val(SP[1])
        DEY
        LDA (SP),Y
        LSR
        TAX
        DEY
        LDA (SP),Y
        ROR
        TAY                                     ;Y := <Int_Val(SP[0])
        TXA
        CLC
        ADC ACCU + 1
        STA ACCU + 1                            ;ACCU + 1 += >Int_Val(SP[0])
        LDA TMP
        STA (ACCU),Y                            ;*ACCU := TMP
        LDA # <Val_unit
        STA ACCU
        LDY # 0
        STY ACCU + 1                            ;ACCU := ()
        LDA # 4                                 ;pop(2)
        CLC
        ADC SP
        BCC +
        INC SP + 1
+       +caml_NEXT                      ;{Y = 0}
}

SWITCHP      
!ifdef caml_gen_SWITCHP {
  !ifdef caml_INTERP {
                @adr = PC
  } else {
        @adr = @jmp + 1
  }                                     ;{A = <p, X = >p}
        STA TMP                                 ;X:A is adr + 2n
        DEC ACCU + 1
        LDY # -2
        LDA (ACCU),Y                            ;Tag(ACCU) is i
        INC ACCU + 1
        ASL                                     ;compute adr + 2n + 2i
        BCC +
        INX
        CLC
+       ADC TMP
        STA @adr                                ;and save it as JMP() arg
        BCC +
        INX
+       STX @adr + 1
        LDY # 0                                 ;reset Y
@jmp    +caml_JMP_CODEPTR .dummy                ;SMC: JMP (adr + 2n + 2i)
}                                       ;{Y = 0}

SWITCHI      
!ifdef caml_gen_SWITCHI {
  !ifdef caml_INTERP {
                @adr = PC
  } else {
        @adr = @jmp + 1
  }                                     ;{A = <p, X = >p, Y = y}
        CLC                                     ;X:A = adr-1, compute adr+2i
        ADC ACCU                                ;(ACCU is 2i+1)
        STA @adr                                ;and save it as JMP() arg
        TXA
        ADC ACCU + 1
        STA @adr + 1
@jmp    +caml_JMP_CODEPTR .dummy                ;SMC: JMP (adr+2i)
}                                       ;{Y = y}

BOOLNOT
!ifdef caml_gen_BOOLNOT {               ;{Y = y}
        LDA ACCU
        EOR # %00000010                         ;Invert bit #1
        STA ACCU
        +caml_NEXT                      ;{Y = y}
}

PHTRP      
!ifdef caml_gen_PHTRP {
  !ifdef caml_INTERP {
                JSR caml_interp_getarg
                STA TMP
                JSR caml_interp_getarg
                STA TMP + 1
  } else {                              ;{A = <ptr, X = >ptr}
        STA TMP                                 ;save address
        STX TMP + 1
  }
        +caml_grow_stack 4
        LDY # 6
        LDA XARGS                               ;push trap frame on stack:
        STA (SP),Y                              ;SP[3] := XARGS
        DEY
        LDA ENV + 1
        STA (SP),Y
        DEY
        LDA ENV
        STA (SP),Y                              ;SP[2] := ENV
        DEY
        LDA TRAPSP + 1
        STA (SP),Y
        DEY
        LDA TRAPSP
        STA (SP),Y                              ;SP[1] := TRAPSP
        DEY
        LDA TMP + 1
        STA (SP),Y
        DEY
        LDA TMP
        STA (SP),Y                              ;SP[0] := address
        LDA SP + 1
        STA TRAPSP + 1
        LDA SP
        STA TRAPSP                              ;TRAPSP := SP
        +caml_NEXT                      ;{Y = 0}
}

POPTRP      
!ifdef caml_gen_POPTRP {                ;{}
        LDY # 2
        LDA (SP),Y
        STA TRAPSP
        INY
        LDA (SP),Y
        STA TRAPSP + 1                          ;get TRAPSP from SP[1]
        LDA # 8                                 ;POP trap frame
        CLC
        ADC SP
        STA SP
        BCC +
        INC SP + 1
+       LDY # 0                                 ;reset Y
        +caml_NEXT                      ;{Y = 0}
}

RAISE      
;; !ifdef caml_gen_RAISE                        ;Always assembled
!ifdef caml_INTERP {
                @PC = PC
} else {                                ;{}
        @PC = TMP
}
caml_hw_stack_ptr = * + 1
        LDX # <.dummy                           ;SMC, see caml_init in loader.asm
        TXS                                     ;clean exit from all JSRs
        LDA TRAPSP
        BIT caml_is_block                       ;is TRAPSP a pointer?
        BEQ +
        JMP caml_uncaught_exn                   ;no: failure - exit
+       STA SP                                  ;yes: restore stack pointer
        LDA TRAPSP + 1
        STA SP + 1
        LDY # 6                                 ;ignore hi byte
        LDA (SP),Y                              ;get XARGS from stack
        STA XARGS
        DEY
        LDA (SP),Y
        STA ENV + 1
        DEY
        LDA (SP),Y
        STA ENV                                 ;get ENV from stack
        DEY
        LDA (SP),Y
        STA TRAPSP + 1
        DEY
        LDA (SP),Y
        STA TRAPSP                              ;get TRAPSP from stack
        DEY
        LDA (SP),Y
        STA @PC + 1
        DEY
        LDA (SP),Y
        STA @PC                                 ;get address from stack
        CLC
        LDA # 8                                 ;pop 4 elements
        ADC SP
        STA SP
        BCC +
        INC SP + 1
+       +caml_JMP_CODEPTR @PC           ;{Y = 0 or HALT}

CCALL
!ifdef caml_gen_CCALL {
  !ifdef caml_INTERP {
                SBC # $BA -1                    ;-1 as C=0; A:=2(n-1)=2*opc-$BA
                LSR                             ;A:=n-1
                CMP # 5
                BCC +
                JSR caml_interp_getarg          ;if CCALL n, get n - 1
+               PHA                             ;save #args_on_stack
                JSR caml_interp_getarg          ;get prim.idx
                TAX
  } else {                              ;{A = #args_on_stack, X = prim.idx, Y=0}
        PHA                                     ;save #args_on_stack
  }
        LDA caml_externals_lo,X                 ;get routine's address, lo by.
        STA @jsr + 1                            ;write following JSR operand
        LDA caml_externals_hi,X                 ;as above, hi by.
        STA @jsr + 2
@jsr    JSR .dummy                              ;SMC: JSR &routine
        LDY # 0                                 ;better safe than sorry
        PLA                                     ;reload #args
        BEQ ++
        ASL
        BCC +
        INC SP + 1
        CLC
+       ADC SP                                  ;pop args from stack
        STA SP
        BCC ++
        INC SP + 1
++      +caml_NEXT                      ;{Y = 0}
}

NEGINT
        ;; Val_Int(-n) = Val_Int(0) + 1 - Val_Int(n)
!ifdef caml_gen_NEGINT {                ;{Y = 0}
        LDA # Val_zero + 1                      ;Load <Val_Int(0)+1 in A
        SEC                                     ;Prepare SBC
        SBC ACCU                                ;Subtract ACCU from A
        STA ACCU                                ;Save result in ACCU
        TYA                                     ;Load >Val_Int(0)+1=0 in A
        SBC ACCU + 1                            ;Subtract ACCU+1 from A
        STA ACCU + 1                            ;Save result in ACCU+1
        +caml_NEXT                      ;{Y = 0}
}

!macro  ARLOGOP @OP {                   ;{Y = 0}
        LDA ACCU
  !if    @OP = '+' { AND # $FE : CLC : ADC (SP),Y
  } elif @OP = '-' { SEC : SBC (SP),Y : ORA # 1
  } elif @OP = '&' { AND (SP),Y
  } elif @OP = '|' { ORA (SP),Y
  } elif @OP = 'X' { EOR (SP),Y : ORA # 1
  } else {!serious "ARLOGOP: Invalid argument"}
        STA ACCU
        INC SP
        LDA ACCU + 1
  !if    @OP = '+' { ADC (SP),Y
  } elif @OP = '-' { SBC (SP),Y
  } elif @OP = '&' { AND (SP),Y
  } elif @OP = '|' { ORA (SP),Y
  } elif @OP = 'X' { EOR (SP),Y
  } else {!serious "ARLOGOP: Invalid argument"}
        STA ACCU + 1
        INC SP
        BNE +
        INC SP + 1
+       +caml_NEXT                      ;{Y = 0}
}

ADDINT  ;;Val_Int(m+n)=Val_Int(m)-1+Val_Int(n)
!ifdef caml_gen_ADDINT { +ARLOGOP '+' }

SUBINT  ;;Val_Int(m-n)=Val_Int(m)-Val_Int(n)+1
!ifdef caml_gen_SUBINT { +ARLOGOP '-' }

ANDINT  ;;Val_Int(m&n)=Val_Int(m)&Val_Int(n)
!ifdef caml_gen_ANDINT { +ARLOGOP '&' }

ORINT   ;;Val_Int(m|n)=Val_Int(m)|Val_Int(n)
!ifdef caml_gen_ORINT  { +ARLOGOP '|' }

XORINT  ;;Val_Int(mXn)=Val_Int(m)XVal_Int(n)|1
!ifdef caml_gen_XORINT { +ARLOGOP 'X' }

!macro  SHFOP @OP {                     ;{Y = 0}
        LDA (SP),Y                              ;load Val_Int(b)
        INC SP                                  ;pop(1)
        INC SP
        BNE +
        INC SP + 1
+       LSR                                     ;compute b from Val_Int(b)
        AND # $0F                               ;extract lo nibble
        BEQ +                                   ;=0? nothing to be shifted
        TAX                                     ;bit counter
        LDA ACCU
  !if    @OP = "<<"  { AND # $FE }              ;clear lsb
- !if    @OP = "<<"  { ASL : ROL ACCU + 1
  } elif @OP = ">>"  { LSR ACCU + 1 : ROR
  } elif @OP = "->>" { SEC : ROR ACCU + 1 : ROR
  } else {!serious "SHFOP: Invalid argument"}
        DEX
        BNE -
        ORA # 1
        STA ACCU
+       +caml_NEXT                      ;{Y = 0}
}

LSLINT
!ifdef caml_gen_LSLINT { +SHFOP "<<" }

LSRINT
!ifdef caml_gen_LSRINT { +SHFOP ">>" }

ASRINT
!ifdef caml_gen_ASRINT {
        BIT ACCU + 1                            ;test sign
        BPL LSRINT                              ;+: do LSRINT
        +SHFOP "->>"                            ;-: shift preserving sign
}

MULINT
        ;; Val_Int(m * n) = (Val_Int(m) >> 1) * (Val_Int(n) - 1) + 1
!ifdef caml_gen_MULINT {                ;{Y = 0}
        @N      = TMP                           ;Multiplicator
        @P      = TMP + 2                       ;P+1:P:ACCU+1:ACCU=Product
        STY @P
        STY @P + 1
        LSR ACCU + 1                            ;ACCU := Val_Int(m) >> 1
        ROR ACCU
        LDA (SP),Y
        AND # $FE                               ;N := Val_Int(n) - 1
        STA @N
        INC SP                                  ;pop lo byte
        LDA (SP),Y
        STA @N + 1
        INC SP                                  ;pop hi byte
        BNE +
        INC SP + 1
        ;; Compute only the two least significative bytes of the product
+       LSR ACCU + 1                            ;prepare ACCU_0 test
        ROR ACCU
        LDX # 8                                 ;repeat 8 times {
-       BCC +                                   ;       if ACCU_0 was 1
        CLC                                     ;       then    P += N
        LDA @N
        ADC @P
        STA @P
        LDA @N + 1
        ADC @P + 1
        STA @P + 1
+       LSR @P + 1                              ;       P:ACCU >>1
        ROR @P
        ROR ACCU + 1
        ROR ACCU
        DEX     
        BNE -                                   ;}
        LDX # 8                                 ;repeat 8 times {
-       BCC +                                   ;       if ACCU_0 was 1
        CLC                                     ;       then    Plo += Nlo
        LDA @P
        ADC @N
        STA @P
+       LSR @P                                  ;       Plo:ACCU >>1
        ROR ACCU + 1
        ROR ACCU
        DEX     
        BNE -                                   ;}
        INC ACCU                                ;Add 1 (set LSB)
        +caml_NEXT                      ;{Y = 0}
}

DIVMOD
!ifdef caml_gen_DIVMOD {                ;{Y = 0}
        .REM    = TMP                           ;Remainder - SHARED WITH MODINT
        @DSR    = TMP + 2                       ;Divisor. Dividend in ACCU.
        @SIGNS  = TMP + 4                       ;bit 7,6 = quot,rem signs flags
        LDA ACCU
        LSR
        ORA ACCU + 1                            ;set N,Z as dividend value
        BNE @not0                               ;Dividend = 0?
        INC SP                                  ;Yes: pop divisor out
        INC SP
        BNE +
        INC SP + 1
+       CLC                                     ;and exit returning C = 0
        RTS

@not0   STY .REM                                ;No: init Remainder
        STY .REM + 1
        BMI @negdvd                             ;Check dividend sign:
        LDX # %00......                         ;+: unset quot & rem signs flags
        BEQ @lddsr                              ;   and JMP to divisor section
@negdvd LDX # %11......                         ;-: set quot & rem signs flags
        SEC                                     ;   and negate the dividend:
        LDA # 2
        SBC ACCU
        STA ACCU
        LDA # 0
        SBC ACCU + 1
        STA ACCU + 1                            ;   Val_Int(-n) = 2 - Val_Int(n)
@lddsr  LDA (SP),Y                              ;load divisor, lo byte
        STA @DSR                                ;and save it
        INC SP                                  ;pop
        LDA (SP),Y                              ;load hi byte
        PHP                                     ;save CPU status for later
        BPL @intval                             ;check divisor sign
        EOR # $FF                               ;-: negate hi byte
@intval LSR                                     ;Compute |Int_Val(divisor)|:
        STA @DSR + 1                            ;save shifted hi byte
        ROR @DSR                                ;shift lo byte
        INC SP
        BNE +
        INC SP + 1                              ;pop
+       PLP                                     ;get saved CPU status
        BMI @negdsr                             ;and check divisor sign again:
        ORA @DSR                                ;+: divisor = 0?
        BNE @divide                             ;   no: start division
        +caml_raise Division_by_zero            ;   yes: raise exception
@negdsr TXA                                     ;-: get quot & rem signs flags
        EOR # %10......                         ;   invert quotient sign flag
        TAX                                     ;   save flags in X
        LDA @DSR                                ;   negate divisor's lo byte
        EOR # $7F                               ;   (bits 6-0 only, as bit7 was
        STA @DSR                                ;   negated and RORed before)
        INC @DSR                                ;   add 1 to get the 2's 
        BNE @divide                             ;   complement of divisor
        INC @DSR + 1                            ;   (adj. hi byte if necessary)
        ;; Division routine: 15 bits, start from dividend's MSB
@divide STX @SIGNS                              ;save flags in S.
        LDX # 15
-       ASL ACCU                                ;shortcut: skip all initial 0s
        ROL ACCU + 1                            ; of dividend
        BCS +                                   ;first 1 found: enter div loop
        DEX
        BNE -                                   ;check next bit
        BRK                                     ;NOT REACHED as ACCU <> Val_zero
-       ASL ACCU                                ;ACCU_0 := 0, shift the
        ROL ACCU + 1                            ;   highest bit of ACCU into
+       ROL .REM                                ;   R and make room in ACCU
        ROL .REM + 1                            ;   for next quotient's bit
        SEC     
        LDA .REM
        SBC @DSR                                ;  Try subtraction R - N
        TAY
        LDA .REM + 1
        SBC @DSR + 1
        BCC +   
        STA .REM + 1                            ;  If subtraction succeeds
        STY .REM                                ;   then save result in R
        INC ACCU                                ;   and record a 1 in ACCU
+       DEX
        BNE -                                   ;Continue loop
        LDY # 0                                 ;reset Y
        BIT @SIGNS                              ;return N = Q sign, V = R sign,
        SEC                                     ;C = 1 (Dividend <> 0),
        RTS                             ;{.REM=|Remainder|, ACCU=|Quotient|,
}                                       ;       CNV=flags, Y = 0}

DIVINT
!ifdef caml_gen_DIVINT {                ;{Y = 0}
        JSR DIVMOD                              ;Compute Q = |A| div |B|
        BCC ++                                  ;ACCU=Dividend=Val_zero, exit
        BMI +                                   ;Need to negate Quotient?
        ;SEC                                    ;no: ACCU := Val_Int(Q) = 2Q+1
        ROL ACCU
        ROL ACCU + 1
        +caml_NEXT                      ;{Y = 0}
+       ASL ACCU                                ;yes: ACCU := Val_Int(-Q) = 1-2Q
        ROL ACCU + 1
        SEC
        LDA # 1
        SBC ACCU
        STA ACCU
        LDA # 0
        SBC ACCU + 1
        STA ACCU + 1
++      +caml_NEXT                      ;{Y = 0}
}

MODINT
!ifdef caml_gen_MODINT {                ;{Y = 0}
        JSR DIVMOD                              ;Compute R = |A| mod |B|
        BCC ++                                  ;ACCU=Dividend=Val_zero, exit
        BVS +                                   ;Need to negate Remainder?
        LDA .REM                                ;no: ACCU := Val_Int(R) = 2R+1
        ;SEC
        ROL
        STA ACCU
        LDA .REM + 1
        ROL
        STA ACCU + 1
        +caml_NEXT                      ;{Y = 0}
+       ASL .REM                                ;yes: ACCU := Val_Int(-R) = 1-2R
        ROL .REM + 1
        SEC
        LDA # 1
        SBC .REM
        STA ACCU
        LDA # 0
        SBC .REM + 1
        STA ACCU + 1
++      +caml_NEXT                      ;{Y = 0}
}

EQ      
!ifdef caml_gen_EQ {                    ;{Y = 0}
        LDA (SP),Y
        INC SP
        CMP ACCU
        BNE CMPRES_F
        LDA (SP),Y
        CMP ACCU + 1
        BNE CMPRES_F
        BEQ CMPRES_T
}                                       ;{Y = 0}

NEQ      
!ifdef caml_gen_NEQ {                   ;{Y = 0}
        LDA (SP),Y
        INC SP
        CMP ACCU
        BNE CMPRES_T
        LDA (SP),Y
        CMP ACCU + 1
        BNE CMPRES_T
        BEQ CMPRES_F
}                                       ;{Y = 0}

!macro  LTGEINT {                       ;{Y = 0}
        LDA ACCU
        CMP (SP),Y
        INC SP
        LDA ACCU + 1
        SBC (SP),Y
        BVC +
        EOR # $80
+
}                                       ;{Y = 0}

!macro  LEGTINT {                       ;{Y = 0}
        LDA (SP),Y
        CMP ACCU
        INC SP
        LDA (SP),Y
        SBC ACCU + 1
        BVC +
        EOR # $80                       ;{Y = 0}
+
}

LTINT      
!ifdef caml_gen_LTINT { +LTGEINT : BMI CMPRES_T : BPL CMPRES_F }

GEINT      
!ifdef caml_gen_GEINT { +LTGEINT : BPL CMPRES_T : BMI CMPRES_F }

LEINT      
!ifdef caml_gen_LEINT { +LEGTINT : BPL CMPRES_T : BMI CMPRES_F }

GTINT      
!ifdef caml_gen_GTINT { +LEGTINT : BMI CMPRES_T : BPL CMPRES_F }

CMPRES
        ;; EQ, NEQ, [LG][ET]INT - shared code
!ifdef caml_gen_CMPRES {                ;{Y = 0}
CMPRES_T
        LDA # Val_true
        BNE +                                   ;JMP ++
CMPRES_F
        LDA # Val_false
+       STA ACCU
        STY ACCU + 1
        INC SP
        BNE +
        INC SP + 1
+       +caml_NEXT                      ;{Y = 0}
}

OFSINT      
!ifdef caml_gen_OFSINT {
  !ifdef caml_INTERP {
                JSR caml_interp_getarg
                TAX
                JSR caml_interp_getarg
                TAY
                TXA
  }                                     ;{A = <2n, Y = >2n}
        CLC
        ADC ACCU
        STA ACCU
        TYA
        ADC ACCU + 1
        STA ACCU + 1
        LDY # 0
        +caml_NEXT                      ;{Y = 0}
}

OFSREF      
!ifdef caml_gen_OFSREF {
  !ifdef caml_INTERP {
        JSR caml_interp_getarg
        TAX
        JSR caml_interp_getarg
        STA TMP
        TXA
  } else {                              ;{A = <2n, Y = >2n}
        STY TMP
  }
        LDY # 0
        CLC
        ADC (ACCU),Y
        STA (ACCU),Y
        INY
        LDA TMP
        ADC (ACCU),Y
        STA (ACCU),Y
        DEY
        LDA # <Val_unit
        STA ACCU
        STY ACCU + 1
        +caml_NEXT                      ;{Y = 0}
}

ISINT      
!ifdef caml_gen_ISINT {                 ;{Y = 0}
        LDA ACCU
        AND # %00000001
        SEC
        ROL
        STA ACCU
        STY ACCU + 1
        +caml_NEXT                      ;{Y = 0}
}

;; BEQ, BNEQ, BLTINT, BLEINT, BGTINT, BGEINT:
;; see "BYTECODE INTERPRETER SPECIFIC" section below.

SGNCMP
        ;; Branches on signed-integer comparison - shared code
!ifdef caml_gen_SGNCMP {                ;{A = <v, Y = >v}
        CMP ACCU                                ;Signed comparison, result is
        TYA                                     ;N=1:>= / N=0:<
        LDY # 0                                 ;Used by [B]LTINT, [B]LEINT, ...
        SBC ACCU + 1
        BVC +
        EOR # $80
+       RTS                             ;{Y = 0}
}

!macro ULTGEINT @LTGE {                 ;{Y = 0}
        INY
  !if @LTGE = "ULTINT" {
        LDA ACCU + 1
        CMP (SP),Y
  } elif @LTGE = "UGEINT" {
        LDA (SP),Y
        CMP ACCU + 1
  } else {!serious "ULTGEINT: invalid arg"}
        BCC ++
        BNE +
        DEY
        LDA ACCU
        CMP (SP),Y
  !if @LTGE = "<" {
        BCC ++
  } elif @LTGE = ">=" {
        BCS ++
  } else {!serious "ULTGEINT: invalid arg"}
+       LDA # Val_false
        BNE +                                   ;JMP +
++      LDA # Val_true
+       STA ACCU
        STY ACCU + 1
        INC SP
        INC SP
        BNE +
        INC SP + 1
+       LDY # 0
        +caml_NEXT                      ;{Y = 0}
}
        
ULTINT      
!ifdef caml_gen_ULTINT { +ULTGEINT "<" }

UGEINT      
!ifdef caml_gen_UGEINT { +ULTGEINT ">=" }       

;; BULTINT, BUGEINT:
;; see "BYTECODE INTERPRETER SPECIFIC" section below.

STOP = caml_end                                 ;See loader.asm

;; ----------------------------------------------------------------------------
;;       UNCAUGHT EXCEPTIONS
;; ----------------------------------------------------------------------------

        ;; Print an uncaught exception with its arguments, if any.
!ifndef caml_uncaught_exn_warn {
caml_uncaught_exn_warn
        !warn "TODO: caml_uncaught_exn should reset VIC, SID, (more?)"
}
caml_uncaught_exn
        @VAL = TMP                              ;current value
        @PRFLD = TMP + 2                        ;print blk fields: =0 yes/<>0 no
        @SIZE  = TMP + 3                        ;for @pr_val: block size
        @SKP0  = TMP + 4                        ;for @pr_int: skip leading 0s
        @DGT  =  TMP + 5                        ;for @pr_int: digit to print
        LDY # 0
        STY @PRFLD                              ;flag: print fields=yes
        LDX # 0                                 ;print error message
-       LDA @err,X
        BEQ +
        JSR C64_CHROUT
        INX
        BNE -
+       DEC ACCU + 1                            ;prepare access to tag(ACCU)
        LDY # -2
        LDA (ACCU),Y                            ;load tag(ACCU)
        INC ACCU + 1                            ;restore ptr
        CMP # 0                                 ;Is exn boxed with its arg(s)?
        BNE @unbxd
        TAY                                     ;Yes: ACCU={tag=0|EXN_BLK|arg}
        LDA (ACCU),Y
        STA @VAL
        INY
        LDA (ACCU),Y
        STA @VAL + 1                            ;  VAL := EXN_BLK
        LDA (@VAL),Y                            ;  load EXN_BLK[0], hi
        TAX
        DEY
        LDA (@VAL),Y                            ;  load EXN_BLK[0], lo
        STX @VAL + 1                            ;  VAL := EXN_BLK[0] (exn name)
        STA @VAL
	JSR @pr_exn                             ;  print exn name
	LDA # ' '
	JSR C64_CHROUT
        LDY # 3
        LDA (ACCU),Y
        STA @VAL + 1
        DEY
        LDA (ACCU),Y
        STA @VAL                                ;  VAL := ACCU[1] (exn arg)
        JSR @pr_val                             ;  print argument(s)
        JMP STOP                                ;  exit.
@unbxd  LDY # 1                                 ;No: ACCU={obj_tag|"name"|oid}
        LDA (ACCU),Y
        STA @VAL + 1
        DEY
        LDA (ACCU),Y
        STA @VAL                                ;  VAL := ACCU[0] (exn name)
	JSR @pr_exn                             ;  print exn name, petscii conv.
        JMP STOP                                ;  exit.
!convtab pet
@err    !text 13, "Exception: ", 0

        ;; Print VAL if int or string, or its fields if tag(VAL)=0 & PRFLD=0
@pr_val BIT caml_is_block                       ;Is VAL a block?
        BEQ +                                   ;No: print integer & return.
        JMP @pr_int                             ; JMP=JSR+RTS
+       DEC @VAL + 1                            ;Yes: prepare access to tag(VAL)
        LDY # -2
        LDA (@VAL),Y                            ; Get tag(VAL)
        BEQ @tag0                               ; branch if tag=0
        CMP # String_tag
        BNE @othblk                             ; branch if tag <> String_tag
        INC @VAL + 1                            ; Restore pointer
        LDA # '"'                               ;== STRING BLOCK ==
        JSR C64_CHROUT                          ; Print '"'
        JSR @pr_str                             ; Print the string
        LDA # '"'                               ; Print '"'
        JMP C64_CHROUT                          ; JMP=JSR+RTS
@othblk LDX # 0                                 ;== BLOCK WITH TAG<>0 ==
-       LDA @msg,X                              ; Print "<BLOCK>"
        BEQ +
        JSR C64_CHROUT
        INX
        BNE -
+       RTS                                     ; Return.
@msg    !text "<BLOCK>", 0
@tag0   BIT @PRFLD                              ;== BLOCK WITH TAG=0 ==
        BMI @othblk                             ; If @PRFLD=$FF, do as above.
        LDA # '('                               ; Print '('
        JSR C64_CHROUT
        INY
        LDA (@VAL),Y                            ; Get size(VAL)
        STA @SIZE                               ;  and save it
        INC @VAL + 1                            ; Restore pointer
        DEC @PRFLD                              ; PRFLD := $FF
-       LDA @VAL + 1                            ; Loop on size(VAL):
        PHA                                     ;  Push VAL,hi onto h/w stack
        LDA @VAL
        PHA                                     ;  Push VAL,lo onto h/w stack
        INY
        LDA (@VAL),Y                            ;  Get current Field(VAL), lo
        TAX
        INY
        LDA (@VAL),Y                            ;   and hi byte
        STX @VAL                                ;  VAL := Field(VAL)
        STA @VAL + 1
        TYA
        PHA                                     ;  Push Y onto h/w stack
        JSR @pr_val                             ;  Recall pr_val(VAL,PRFLD=$FF)
        PLA                                     ;  Pop Y register from h/w stack
        TAY
        PLA                                     ;  Pop VAL,lo from h/w stack
        STA @VAL
        PLA                                     ;  Pop VAL,hi from h/w stack 
        STA @VAL + 1
        DEC @SIZE                               ;  Decrement counter
        BEQ +                                   ; Exit if all fields are printed
        LDA # ','                               ;  Print ','
        JSR C64_CHROUT
        LDA # ' '                               ;  Print ' '
        JSR C64_CHROUT
        JMP -                                   ; Continue loop
+       LDA # ')'                               ; Print ')'
        JSR C64_CHROUT
        RTS                                     ; Return.

        ;; Convert the exn name ptd by VAL to PETSCII and print it
@pr_exn LDY # 0
-       LDA (@VAL),Y                            ;A := VAL[Y]
        BEQ +++                                 ;Exit if null
	CMP # $5F				;test for underscore
	BNE +
	LDA # $A4
	BNE ++				        ;JMP
+	CMP # $61				;test for lowercase letter
	BCC +
	SBC # $20
	BNE ++				        ;JMP
+	CMP # $41				;test for uppercase letter
	BCC ++
	EOR # $80
++      JSR C64_CHROUT                          ;Print VAL[Y]
        INY
        BNE -
        INC @VAL + 1
        BNE -
+++     RTS

        ;; Print the string pointed by VAL
@pr_str LDY # 0
-       LDA (@VAL),Y                            ;A := VAL[Y]
        BEQ +                                   ;Exit if null
        JSR C64_CHROUT                          ;Print VAL[Y]
        INY
        BNE -
        INC @VAL + 1
        BNE -
+       RTS

        ;; Print the integer in VAL
@pr_int BIT @VAL + 1
        BPL +
        SEC                                     ;If VAL < 0,
        LDA # Val_zero + 1
        SBC @VAL                                ; negate it
        STA @VAL
        LDA # 0
        SBC @VAL + 1
        STA @VAL + 1
        LDA # '-'                               ; and print '-'.
        JSR C64_CHROUT
+       LSR @VAL + 1                            ;Get rid of trailing 1
        ROR @VAL
        LDA # '0'
        STA @SKP0                               ;Ignore initial 0s
        LDX # 3                                 ;For X := 3 downto 0
--      STA @DGT                                ; DGT := '0'
-       LDA @VAL                                ; Loop
        SEC
        SBC @lo10,X                             ;  A:Y := VAL - 10^(X+1)
        TAY
        LDA @VAL + 1
        SBC @hi10,X
        BCC +                                   ; Exit_loop if A:Y < 0
        STY @VAL                                ;  VAL := A:Y
        STA @VAL + 1
        INC @DGT                                ;  DGT :=nxt(DGT) ('1','2',...)
        BNE -                                   ; End_Loop
+       LDA @DGT                                ; If not(DGT = '0' & SKP0 = '0')
        CMP @SKP0
        BEQ +
        DEC @SKP0                               ;  SKP0 := <non_digit_char>
        JSR C64_CHROUT                          ;  Print DGT
        LDA # '0'                               ;  Set A for next iteration
+       DEX                                     ;  Decrement counter
        BPL --                                  ;End_For
        ORA @VAL                                ;A := '0'|VAL  (last digit)
        ;JSR C64_CHROUT                         ;Print it
        ;RTS                                    ; and return.
        JMP C64_CHROUT                          ;JMP=JSR+RTS
@lo10   !byte <10, <100, <1000, <10000
@hi10   !byte >10, >100, >1000, >10000


!ifdef caml_INTERP {
;; ----------------------------------------------------------------------------
;;       BYTECODE INTERPRETER SPECIFIC ROUTINES
;; ----------------------------------------------------------------------------

PHENVACC
!ifdef caml_gen_PHENVACC {
                JSR PUSH
                JMP ENVACCN
}

ENVACCN
!ifdef caml_gen_ENVACCN {
                JSR caml_interp_getarg
                TAY
                JMP ENVACC
}

PHENVACC14
!ifdef caml_gen_PHENVACC14 {
                SBC # $34 -1                    ;-1 as C=0; A:=2n=2*opc-$34
                STA TMP
                JSR PUSH
                LDY TMP
                JMP ENVACC
}

ENVACC14
!ifdef caml_gen_ENVACC14 {
                SBC # $2A -1                    ;-1 as C=0; A:=2n=2*opc-$2A
                TAY
                JMP ENVACC
}

APPLYN
!ifdef caml_gen_APPLYN {
                JSR caml_interp_getarg
                TAY
                JMP APPLY
}

APPTRM13
!ifdef caml_gen_APPTRM13 {
                SBC # $4A -1                    ;-1 as C=0; A:=2(n-1)=2*opc-$4A
                BEQ +
                TAY
                CLC
                ADC XARGS                       ;XARGS :=
                STA XARGS                       ;  Val_Int(Int_Val(XARGS)+n-1)
+               JSR caml_interp_getarg
                TAX                             ;X:=2(s-n)
                INY                             ;Y:=2n-1
                JMP APPTRM1
}

PHOFSCLM2
!ifdef caml_gen_PHOFSCLM2 {
                JSR PUSH
                CLC
                JMP OFSCLM2
}

OFSCLM2
!ifdef caml_gen_OFSCLM2 {
                LDA ENV
                SBC # 4 -1                      ;-1 as C=0
                STA ACCU
                LDA ENV + 1
                SBC # 0
                STA ACCU + 1
                +caml_NEXT
}

PHOFSCL0
!ifdef caml_gen_PHOFSCL0 {
                JSR PUSH
                JMP OFSCL0
}

PHOFSCL2
!ifdef caml_gen_PHOFSCL2 {
                JSR PUSH
                CLC
                JMP OFSCL2
}

OFSCL2
!ifdef caml_gen_OFSCL2 {
                LDA ENV
                ADC # 4                         ;C=0
                STA ACCU
                LDA ENV + 1
                ADC # 0
                STA ACCU + 1
                +caml_NEXT
}

PHOFSCLN
!ifdef caml_gen_PHOFSCLN {
                JSR PUSH
                JMP OFSCLN
}

PHGETGLB
!ifdef caml_gen_PHGETGLB {
                JSR PUSH
                JMP GETGLB
}

GETGLB
!ifdef caml_gen_GETGLB {
                JSR GETGLBSUB
                +caml_NEXT
GETGLBSUB                                       ;called by [PH]GETGLB[FLD]
                JSR caml_interp_getarg
                STA ACCU
                JSR caml_interp_getarg
                STA ACCU + 1
                CMP # >caml_glob_table          ;return if ACCU is an address
                BCC +                           ; of a standard exception blk
                INY                             ;else ACCU points to the global
                LDA (ACCU),Y                    ; table: access it and get the
                TAX                             ; value
                DEY
                LDA (ACCU),Y
                STA ACCU
                STX ACCU + 1
+               RTS
}

PHGETGLBFLD
!ifdef caml_gen_PHGETGLBFLD {
                JSR PUSH
                JMP GETGLBFLD
}

GETGLBFLD
!ifdef caml_gen_GETGLBFLD {
                JSR GETGLBSUB
                JSR caml_interp_getarg
                ASL
                BCC +
                INC ACCU + 1
+               TAY
                LDA (ACCU),Y
                TAX
                INY
                LDA (ACCU),Y
                STX ACCU
                STA ACCU + 1
                LDY #0
                +caml_NEXT
}

PHATOM0
!ifdef caml_gen_PHATOM0 {
                JSR PUSH
                JMP ATOM0
}

ATOM0
!ifdef caml_gen_ATOM0 {
                LDA # <caml_atom0
                STA ACCU
                LDA # >caml_atom0
                STA ACCU + 1
                +caml_NEXT
}

MKBLKN
!ifdef caml_gen_MKBLKN {
                JSR caml_interp_getarg
                TAX                             ;X = size
                JSR caml_interp_getarg          ;A = tag
                JMP MKBLK
}

MKBLK13
!ifdef caml_gen_MKBLK13 {
                SBC # $7C -1                    ;-1 as C=0; A:=2n=2*opc-$7C
                LSR
                TAX                             ;X = size
                JSR caml_interp_getarg          ;A = tag
                JMP MKBLK
}

GETFLD13
!ifdef caml_gen_GETFLD13 {
                SBC # $86 -1                    ;-1 as C=0; A:=2n=2*opc-$86
                TAY
                JMP GETFLD0
}

SETFLD13
!ifdef caml_gen_SETFLD13 {
                SBC # $93 -1                    ;-1 as C=0; A:=2n-1=2*opc-$93
                ADC ACCU                        ;A:=2n-1+ACCU +1 as C=1
                STA ACCU                        ;ACCU:=2n+ACCU
                BCC SETFLD0
                INC ACCU + 1
                JMP SETFLD0
}

BIF
!ifdef caml_gen_BIF {
                LDA ACCU
                LSR
                ORA ACCU + 1
                BEQ +
                JMP BRANCH
+               CLC:JMP caml_interp_skip2or3by
}

BIFNOT
!ifdef caml_gen_BIFNOT {
                LDA ACCU
                LSR
                ORA ACCU + 1
                BNE +
                JMP BRANCH
+               CLC:JMP caml_interp_skip2or3by
}

SWITCH
!ifdef caml_gen_SWITCH {
                LDA (PC),Y                      ;A := n
                STA TMP
                BEQ @pptrs
                LDA ACCU
                AND # 1
                BEQ @pptrs
                LDA PC
                LDX PC + 1
                JMP SWITCHI
@pptrs          LDX PC + 1
                ASL TMP
                BCC +
                INX
+               LDA PC
                SEC                             ;+1
                ADC TMP
                BCC +
                INX
+               JMP SWITCHP
}

PHCST03
!ifdef caml_gen_PHCST03 {
                SBC # $CF -1                    ;-1 as C=0; A:=2n+1=2*opc-$CF
                TAX
                JSR PUSH
                STX ACCU                        ;ACCU:=Val_int(opcode-$CF)
                STY ACCU + 1
                +caml_NEXT
}

CST03
!ifdef caml_gen_CST03 {
                SBC # $C5 -1                    ;-1 as C=0; A:=2n+1=2*opc-$C5
                STA ACCU                        ;ACCU:=Val_int(opcode-$63)
                STY ACCU + 1
                +caml_NEXT
}

PHCSTN
!ifdef caml_gen_PHCSTN {
                TAX
                JSR PUSH
                TXA
                JMP CSTN
}

CSTN
!ifdef caml_gen_CSTN {
                JSR caml_interp_getarg
                STA ACCU
                JSR caml_interp_getarg
                STA ACCU + 1
                +caml_NEXT
}

        ;; "PAIRED OPCODES" DISAMBIGUATION.
        ;; Two opcodes are paired iff their bits are equal but the msb.
        ;; Paired opcodes share the same jumptable place (see at end);
        ;; the fetch-exec routine sets C = msb of fetched opcode.
        ;; N.b.: the routines placement guarantees that conditional
        ;; branches targets stay in range [-128, +127]

!set PUSH_ULTINT = *
!ifdef caml_gen_PUSH_ULTINT {
  !ifdef caml_gen_PUSH {
    !ifdef caml_gen_ULTINT {
                BCS +
                JSR PUSH
                +caml_NEXT
+               JMP ULTINT
    } else {    JSR PUSH
                +caml_NEXT }
  } else { !set PUSH_ULTINT = ULTINT }
}

PHACC5_STOP
!ifdef caml_gen_PHACC5_STOP {
                BCC PHACC17
                JMP STOP
}

PHACC17
!ifdef caml_gen_PHACC17 {
                SBC # $14 -1                    ;-1 as C=0; A:=2n=2*opc-$14
                STA TMP
                JSR PUSH
                LDY TMP                         ;Y:=2n
                JMP ACCL
}

!set ACC_BGEINT = *
!ifdef caml_gen_ACC_BGEINT {
  !ifdef caml_gen_ACCH {
    !ifdef caml_gen_BGTGEINT {
                BCS BGTGEINT
                JMP ACCH
    } else { !set ACC_BGEINT = ACCH }
  } else { !set ACC_BGEINT = BGTGEINT }
}

!set ACC7_BGTINT = *
!ifdef caml_gen_ACC7_BGTINT {
  !ifdef caml_gen_ACC07 {
    !ifdef caml_gen_BGTGEINT {
                BCC ACC07
                ;; fallthrough BGTGEINT
    } else { !set ACC7_BGTINT = ACC07 }
  } else { !set ACC7_BGTINT = BGTGEINT }
}
BGTGEINT
!ifdef caml_gen_BGTGEINT {
                JSR caml_interp_getarg
                TAX
                JSR caml_interp_getarg
                TAY
                TXA
                JSR SGNCMP
                BPL BRANCH                      ;OK: BPL +119
                CLC:JMP caml_interp_skip2or3by  ;no BCC, it'll be out-of-range
}

!set PHACC1_BULTINT = *
!ifdef caml_gen_PHACC1_BULTINT {
  !ifdef caml_gen_PHACC17 {
    !ifdef caml_gen_BULTINT {
                BCC PHACC17
                ;; fallthrough BULTINT
    } else { !set PHACC1_BULTINT = PHACC17 }
  } else { !set PHACC1_BULTINT = BULTINT }
}
BULTINT
!ifdef caml_gen_BULTINT {
                JSR caml_interp_getarg
                CMP ACCU
                JSR caml_interp_getarg
                SBC ACCU + 1
                BCC BRANCH
                CLC:BCC caml_interp_skip2or3by  ;OK: BCC +116
}

!set PHACC2_BUGEINT = *
!ifdef caml_gen_PHACC2_BUGEINT {
  !ifdef caml_gen_PHACC17 {
    !ifdef caml_gen_BUGEINT {
                BCC PHACC17
                ;; fallthrough BUGEINT 
    } else { !set PHACC2_BUGEINT = PHACC17 }
  } else { !set PHACC2_BUGEINT = BUGEINT }
}
BUGEINT
!ifdef caml_gen_BUGEINT {
                JSR caml_interp_getarg
                CMP ACCU
                JSR caml_interp_getarg
                SBC ACCU + 1
                BCS BRANCH
                CLC:BCC caml_interp_skip2or3by
}

!set ACC0_OFSREF = *
!ifdef caml_gen_ACC0_OFSREF {
  !ifdef caml_gen_ACC07 {
    !ifdef caml_gen_OFSREF {
                BCC ACC07
                JMP OFSREF
    } else { !set ACC0_OFSREF = ACC07 }
  } else { !set ACC0_OFSREF = OFSREF }
}

!set ACC1_ISINT = *
!ifdef caml_gen_ACC1_ISINT {
  !ifdef caml_gen_ACC07 {
    !ifdef caml_gen_ISINT {
                BCC ACC07
                JMP ISINT
    } else { !set ACC1_ISINT = ACC07 }
  } else { !set ACC1_ISINT = ISINT }
}

!set ACC3_BEQ = *
!ifdef caml_gen_ACC3_BEQ {
  !ifdef caml_gen_ACC07 {
    !ifdef caml_gen_BEQ {
                BCC ACC07
                ;; fallthrough BEQ_
    } else { !set ACC3_BEQ = ACC07 }
  } else { !set ACC3_BEQ = BEQ_ }
}
BEQ_
!ifdef caml_gen_BEQ {
                JSR caml_interp_getarg
                CMP ACCU
                BEQ +
                SEC:BCS caml_interp_skip2or3by
+               JSR caml_interp_getarg
                CMP ACCU + 1
                BEQ BRANCH
                CLC:BCC caml_interp_skip2or3by
}

!set ACC4_BNEQ = *
!ifdef caml_gen_ACC4_BNEQ {
  !ifdef caml_gen_ACC07 {
    !ifdef caml_gen_BNEQ {
                BCC ACC07
                ;; fallthrough BNEQ
    } else { !set ACC4_BNEQ = ACC07 }
  } else { !set ACC4_BNEQ = BNEQ }
}
BNEQ
!ifdef caml_gen_BNEQ {
                JSR caml_interp_getarg
                CMP ACCU
                BNE +
                SEC:BCS caml_interp_skip2or3by
+               JSR caml_interp_getarg
                CMP ACCU + 1
                BNE BRANCH
                CLC:BCC caml_interp_skip2or3by
}

!set ACC5_BLTINT = *
!ifdef caml_gen_ACC5_BLTINT {
  !ifdef caml_gen_ACC07 {
    !ifdef caml_gen_BLTLEINT {
                BCS BLTLEINT
                ;; fallthrough ACC07
    } else { !set ACC5_BLTINT = ACC07 }
  } else { !set ACC5_BLTINT = BLTLEINT }
}
ACC07
!ifdef caml_gen_ACC07 {
                TAY                             ;Y=2n
                JMP ACCL
}

!set ACC6_BLEINT = *
!ifdef caml_gen_ACC6_BLEINT {
  !ifdef caml_gen_ACC07 {
    !ifdef caml_gen_BLTLEINT {
                BCC ACC07
                ;; fallthrough BLTLEINT
    } else { !set ACC6_BLEINT = ACC07 }
  } else { !set ACC6_BLEINT = BLTLEINT }
}
BLTLEINT
!ifdef caml_gen_BLTLEINT {
                JSR caml_interp_getarg
                TAX
                JSR caml_interp_getarg
                TAY
                TXA
                JSR SGNCMP
                BMI BRANCH
                CLC:BCC caml_interp_skip2or3by
}
                ;; BRANCH, START, FETCH ARG, SKIP ARG.

BRANCH                                          ;Branch to *PC
                LDA (PC),Y
                TAX
                INC PC
                BNE +
                INC PC + 1
+               LDA (PC),Y
                ;; fallthrough caml_interp_start
caml_interp_start                               ;ENTRYPOINT: start interpreter
                STX PC
                STA PC + 1
                JMP caml_interp_fetch

caml_interp_skip2or3by                          ;Skip next 2 + Carry bytes
                LDA # 2
                ADC PC
                STA PC
                BCC +
                INC PC + 1
+               JMP caml_interp_fetch

caml_interp_getarg                              ;Fetch a 1-byte argument
                LDA (PC),Y
                INC PC
                BNE +
                INC PC + 1
+               RTS

                ;; OPCODES JUMPTABLE.
                ;; The table is page-aligned. The fetch-exec routine sets C=bit7
                ;; of fetched opcode, then accesses the table using 2*opcode as
                ;; an index.  

                !align  $FF, $00
caml_interp_jmptbl
                ;; $00...$0f/$80...$8f  (unused opcodes: $0a, $82, $8d, $8e)
                !wo ACC0_OFSREF, ACC1_ISINT, ACC07, ACC3_BEQ, ACC4_BNEQ
                !wo ACC5_BLTINT, ACC6_BLEINT, ACC7_BGTINT, ACC_BGEINT
                !wo PUSH_ULTINT, UGEINT, PHACC1_BULTINT, PHACC2_BUGEINT 
                !wo PHACC17, PHACC17, PHACC5_STOP
                ;; $10...$1f/$90...$94  (unused opcodes: $90...$94)
                !wo PHACC17, PHACC17, PHACC, POPN, ASSIGNH, ENVACC14, ENVACC14
                !wo ENVACC14, ENVACC14, ENVACCN, PHENVACC14, PHENVACC14
                !wo PHENVACC14, PHENVACC14, PHENVACC, PHRET
                ;; $20...$2f
                !wo APPLYN, APPLY13, APPLY13, APPLY13, APPTRMN, APPTRM13
                !wo APPTRM13, APPTRM13, RETURN, RESTART, GRAB, CLOSURE, CLOSREC
                !wo OFSCLM2, OFSCL0, OFSCL2
                ;; $30...$3f            (unused opcodes: $3b, $3d)
                !wo OFSCLN, PHOFSCLM2, PHOFSCL0, PHOFSCL2, PHOFSCLN, GETGLB
                !wo PHGETGLB, GETGLBFLD, PHGETGLBFLD, SETGLB, ATOM0, $ffff
                !wo PHATOM0, $ffff, MKBLKN, MKBLK13
                ;; $40...$4f
                !wo MKBLK13, MKBLK13, MKFBLK, GETFLD0, GETFLD13, GETFLD13
                !wo GETFLD13, GETFLDN, GETFFLDN, SETFLD0, SETFLD13, SETFLD13
                !wo SETFLD13, SETFLDN, SETFFLDN, VECLEN
                ;; $50...$5f            (unused opcode: $5c)
                !wo GETVEC, SETVEC, GETCHR, SETCHR, BRANCH, BIF, BIFNOT, SWITCH
                !wo BOOLNOT, PHTRP, POPTRP, RAISE, $ffff, CCALL, CCALL, CCALL
                ;; $60...$6f
                !wo CCALL, CCALL, CCALL, CST03, CST03, CST03, CST03, CSTN
                !wo PHCST03, PHCST03, PHCST03, PHCST03, PHCSTN, NEGINT, ADDINT
                !wo SUBINT
                ;; $70...$7f
                !wo MULINT, DIVINT, MODINT, ANDINT, ORINT, XORINT, LSLINT
                !wo LSRINT, ASRINT, EQ, NEQ, LTINT, LEINT, GTINT, GEINT, OFSINT

} ;ifdef caml_INTERP

caml_runtime_end
} ;zone caml_RUNTIME
