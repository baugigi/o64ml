
!zone caml_CODEGEN {
;; ----------------------------------------------------------------------------
;;      CODE GENERATION
;; ----------------------------------------------------------------------------

        ;;      caml_INTERP undefined:  generate native code
        ;;      caml_INTERP = 1:        generate bytecode for interpretation

;; Check for out-of-range argument
!macro caml_range .min, .arg, .max, .txt {
  !if (.arg < .min) | (.arg > .max) {
        !error .txt + " = ", .arg, " out of range [", .min, ", ", .max, "]"
  }
}

;; These shouldn't be necessary: ocamlc should have already given up
!macro  i82     {!serious "ERROR: Objects and classes not implemented"}
!macro  i8d .t  {!serious "ERROR: Objects and classes not implemented"}
!macro  i8e     {!serious "ERROR: Objects and classes not implemented"}


!ifndef caml_INTERP {
        ;; --------------------------------------------------------------------
        ;;      NATIVE CODE GENERATION
        ;; --------------------------------------------------------------------

;; Macros in opcode order, but dependencies

;; i00-i12 depend on i08
!macro  i08 .n {                                ;ACCESS n
        +caml_range 0, .n, $7FFF, "ACC n: n" 
        .n2h = >(2 * .n)
        .n2l = <(2 * .n)
  !if .n2l > 0 {
        LDY # .n2l
  }
  !if .n2h = 0 {
        !set    caml_gen_ACCL = 1
        JSR caml_ACCL
  } elif .n2h = 1 {
        !set    caml_gen_ACCL = 1
        INC SP + 1
        JSR caml_ACCL
        DEC SP + 1
  } else {
        !set    caml_gen_ACCH = 1
        LDA # .n2h
        JSR caml_ACCH
  }
}
!macro  i00     {+i08 0}                        ;ACCi -> ACC i
!macro  i01     {+i08 1}
!macro  i02     {+i08 2}
!macro  i03     {+i08 3}
!macro  i04     {+i08 4}
!macro  i05     {+i08 5}
!macro  i06     {+i08 6}
!macro  i07     {+i08 7}

;; i0a-i12, i1a-i1e, i31-i34, i36, i38, i3c-i3d, i68-i6c depend on i09
!macro  i09 {                                   ;PUSH
        !set    caml_gen_PUSH = 1
        JSR caml_PUSH
}
!macro  i0a     {+i09}                          ;PUSHACC0 -> caml_PUSH
!macro  i0b     {+i09 : +i08 1}                 ;PUSHACCi -> PUSH; ACC i
!macro  i0c     {+i09 : +i08 2}
!macro  i0d     {+i09 : +i08 3}
!macro  i0e     {+i09 : +i08 4}
!macro  i0f     {+i09 : +i08 5}
!macro  i10     {+i09 : +i08 6}
!macro  i11     {+i09 : +i08 7}
!macro  i12 .n  {+i09 : +i08 .n}                ;PUSHACC n -> PUSH; ACC n
!macro  i13 .n {                                ;POP n
        +caml_range 0, .n, $7FFF, "POP n: n"
        .n2h = >(2 * .n)
        .n2l = <(2 * .n)
  !if .n = 0 {
        ;NOP
  } elif .n = 1 {
        !set    caml_gen_POP1 = 1
        JSR caml_POP1
  } else {
        LDA # .n2l
    !if .n2h > 0 {
        LDY # .n2h
    }
        !set    caml_gen_POPN = 1
        JSR caml_POPN
  }
}
!macro  i14 .n {                                ;ASSIGN n
        +caml_range 0, .n, $7FFF, "ASSIGN n: n"
        .n2h = >(2 * .n)
        .n2l = <(2 * .n)
        !set    caml_gen_ASSIGNL = 1
  !if .n2l > 0 {
        LDY # .n2l
  }
  !if .n2h = 0 {
        JSR caml_ASSIGNL
  } elif .n2h = 1 {
        INC SP + 1
        JSR caml_ASSIGNL
        DEC SP + 1
  } else {
        !set    caml_gen_ASSIGNH = 1
        LDA # .n2h
        JSR caml_ASSIGNH
        STX SP + 1
  }
}

;; i15-i1e depend on i19
!macro  i19 .n {                                ;ENVACC n
        +caml_range 0, .n, $FE, "ENVACC n: n"
        .n2h = >(2 * .n)
        .n2l = <(2 * .n)
        !set    caml_gen_ENVACC = 1
  !if .n2l > 0 {
        LDY # .n2l
  }
  !if .n2h > 0 {
        INC ENV + 1
        JSR caml_ENVACC
        DEC ENV + 1
  } else {
        JSR caml_ENVACC
  }
}
!macro  i15     {+i19 1}                        ;ENVACCi -> ENVACC i
!macro  i16     {+i19 2}
!macro  i17     {+i19 3}
!macro  i18     {+i19 4}
!macro  i1a     {+i09 : +i19 1}                 ;PUSHENVACCi -> PUSH; ENVACC i
!macro  i1b     {+i09 : +i19 2}
!macro  i1c     {+i09 : +i19 3}
!macro  i1d     {+i09 : +i19 4}
!macro  i1e .n  {+i09 : +i19 .n}                ;PUSHENVACC n -> PUSH; ENVACC n
!macro  i1f .adr {                              ;PUSHRETADDR adr
        !set    caml_gen_PHRET = 1
        LDA # <.adr
        LDX # >.adr
        JSR caml_PHRET
}

;; i21-i23 depend on i20
!macro  i20 .n {                                ;APPLY n
        +caml_range 1, .n, $7F, "APPLY n: n"
        !set    caml_gen_APPLY = 1
        LDY # 2 * .n - 1
  !if .n <= 3 {
        !set    caml_gen_APPLY13 = 1
        JSR caml_APPLY13                             ;JMP & push retadr-1 on hw stack
  } else {
        JMP caml_APPLY
  }
}
!macro  i21     {+i20 1}                        ;APPLYi -> APPLY i
!macro  i22     {+i20 2}
!macro  i23     {+i20 3}

;; i25-i27 depend on i24
!macro  i24 .n, .s {                            ;APPTERM n s
        +caml_range 1, .n, $7F, "APPTERM n s: n"
        +caml_range .n, .s, $7F, "APPTERM n s: s"
        !set    caml_gen_APPTRM1 = 1
        LDX # 2 * (.s - .n)
  !if .n = 1 {
        INY
        JMP caml_APPTRM1
  } else {
        !set    caml_gen_APPTRMN = 1
        LDA # 2 * (.n - 1)
        JMP caml_APPTRMN
  }
}
!macro  i25 .s  {+i24 1,.s}                     ;APPTERMi s -> APPTERM i s
!macro  i26 .s  {+i24 2,.s}
!macro  i27 .s  {+i24 3,.s}
!macro  i28 .n {                                ;RETURN n
        +caml_range 0, .n, $7F, "RETURN n: n"
        !set    caml_gen_RETURN = 1
        !set    caml_gen_GORETURN = 1
  !if .n = 0 {
        TYA
  } else {
        LDA # 2 * .n
  }
        JMP caml_RETURN
}
!macro  i29 {                                   ;RESTART
        !set    caml_gen_RESTART = 1
        !set    caml_restart_len = @end - *     ;needed by GRAB routine
        JSR caml_RESTART
@end
}
!macro  i2a .n {                                ;GRAB n
        +caml_range 0, .n, $7C, "GRAB n: n"
        +Val_Int ~.v, .n
        !set    caml_gen_GRAB = 1
        !set    caml_gen_GORETURN = 1
        !set    caml_grab_len = @end - *        ;needed by GRAB routine
        LDA # .v
        JSR caml_GRAB
@end
}
!macro  i2b .n, .ptr {                          ;CLOSURE n ptr
        +caml_range 0, .n, $7F, "CLOSURE n p: n"
        LDX # .n
        LDA # <.ptr
        LDY # >.ptr
        !set    caml_gen_CLOSURE = 1
        JSR caml_CLOSURE
}
!macro  i2c .f, .v, .o, .t {                    ;CLOSUREREC f v o t
        +caml_range 1, .f, $80, "CLOSUREREC f v o t: f"
        +caml_range 0, .v, $FE, "CLOSUREREC f v o t: v"
        +caml_range 1, 2 * .f - 1 + .v, $FF, "CLOSUREREC f v o t: 2f-1+v"
        !set    caml_gen_CLOSREC = 1
        LDA # <.data
        LDY # >.data
        JSR caml_CLOSREC
        JMP +
        !byte .v, .f
.data   !word .o, .t
+
}

;; i2d-i2f, i31-i34 depend on i30
!macro  i30 .n {                                ;OFFSETCLOSURE n
        +caml_range -$FE, .n, $FE, "OFFSETCLOSURE n: n"
        +caml_range 0, .n mod 2, 0, "OFFSETCLOSURE n: n mod 2"
        .n2h = >(2 * .n)
        .n2l = <(2 * .n)
  !if .n2h > 0 {
        LDX # .n2h
    }
  !if .n = 0 {
        !set    caml_gen_OFSCL0 = 1
        JSR caml_OFSCL0
  } else {
        !set    caml_gen_OFSCLN = 1
        LDA # .n2l
        JSR caml_OFSCLN
  }
}
!macro  i2d     {+i30 -2}                       ;OFFSETCLOSUREi -> OFFS... i
!macro  i2e     {+i30 0}
!macro  i2f     {+i30 2}
!macro  i31     {+i09 : +i30 -2}                ;PUSHOFFSETCLOSUREi -> PUSH;...
!macro  i32     {+i09 : +i30 0}
!macro  i33     {+i09 : +i30 2}
!macro  i34 .n  {+i09 : +i30 .n}                ;PUSHOFFSETCLOSURE n-> PUSH;...

;; i36-i38 depend on i35
!macro  i35 .n {                                ;GETGLOBAL n
        +caml_range 0, .n, $7FFF, "GETGLOBAL n: n"
  !if .n < caml_exn_no {
        LDA # < caml_std_exn[.n]
        STA ACCU
        LDA # > caml_std_exn[.n]
        STA ACCU + 1
  } else {
        .ofs = 2 * (.n - caml_exn_no)
        LDA caml_glob_table + .ofs
        STA ACCU
        LDA caml_glob_table + .ofs + 1
        STA ACCU + 1
  }
}
!macro  i36 .n  {+i09 : +i35 .n}                ;PUSHGETGOBAL n -> PUSH; ...

;; i37-138, i43-i46 depend on i47
!macro  i47 .n {                                ;GETFIELD n
        +caml_range 0, .n, $FE, "GETFIELD n: n"
        !set    caml_gen_GETFLD0 = 1
  !if .n = 0 {
        JSR caml_GETFLD0
  } else {
        !set    caml_gen_GETFLDN = 1
        LDA # .n
        JSR caml_GETFLDN
  }
}
!macro  i37 .n,.m {+i35 .n : +i47 .m}           ;GETGLOBALFIELD n m -> GETGL...
!macro  i38 .n,.m {+i09 : +i35 .n : +i47 .m}    ;PUSHGETGLOBALFIELD n m->PUSH...
!macro  i39 .n {                                ;SETGLOBAL n
        +caml_range caml_exn_no, .n, $7FFF, "SETGLOBAL n: n"
        .ofs = 2 * (.n - caml_exn_no)
        !set    caml_gen_SETGLB = 1
        LDA # <(caml_glob_table + .ofs)
        LDX # >(caml_glob_table + .ofs)
        JSR caml_SETGLB
}

;; i3a, i3c-i3d depend on i3b
!macro  i3b .n {                                ;ATOM n
        +caml_range 0, .n, 0, "ATOM n: n"       ;only ATOM(0) allowed
        LDA # <caml_atom0
        STA ACCU
        LDA # >caml_atom0
        STA ACCU + 1
}
!macro  i3a     {+i3b 0}                        ;ATOM0 -> ATOM 0
!macro  i3c     {+i09 : +i3b 0}                 ;PUSHATOM0 -> PUSH; ATOM 0
!macro  i3d .n  {+i09 : +i3b .n}                ;PUSHATOM n -> PUSH; ATOM n

;; i3f-i41 depend on i3e
!macro  i3e .size, .tag {                       ;MAKEBLOCK s t
        +caml_range 1, .size, $FF, "MKBLK s t: s"
        +caml_range 0, .tag, $FF, "MKBLK s t: t"
        !set    caml_gen_MKBLK = 1
        LDX # .size
        LDA # .tag
        JSR caml_MKBLK
}
!macro  i3f .t  {+i3e 1,.t}                     ;MAKEBLOCK1 t -> MAKEBLOCK 1 t
!macro  i40 .t  {+i3e 2,.t}                     ;MAKEBLOCK2 t -> MAKEBLOCK 2 t
!macro  i41 .t  {+i3e 3,.t}                     ;MAKEBLOCK3 t -> MAKEBLOCK 3 t
!macro  i42 .s {                                ;MAKEFLOATBLOCK s
        +caml_range 1, .s, $FF div Double_wosize, "MAKEFLOATBLOCK s: s"
        !set    caml_gen_MKFBLK = 1
        LDX # .s * Double_wosize
        JSR caml_MKFBLK
}
!macro  i43     {+i47 0}                        ;GETFIELDi -> GETFIELD i
!macro  i44     {+i47 1}
!macro  i45     {+i47 2}
!macro  i46     {+i47 3}
!macro  i48 .n {                                ;GETFLOATFIELD n
        +caml_range 0, .n, $FF div Double_wosize, "GETFLOATFIELD n: n"
        .n2l = <(2 * .n * Double_wosize)
        .n2h = >(2 * .n * Double_wosize)
        !set    caml_gen_GETFFLD0 = 1
  !if .n2h > 0 {
        INC ACCU + 1
  }
  !if .n2l > 0 {
        !set    caml_gen_GETFFLDN = 1
        LDA # .n2l
        JSR caml_GETFFLDN
  } else {
        JSR caml_GETFFLD0
  }
}

;; i49-i4c depend on i4d
!macro  i4d .n {                                ;SETFIELD n
        +caml_range 0, .n, $FE, "SETFLD n: n"
        !set    caml_gen_SETFLD0 = 1
  !if .n = 0 {
        JSR caml_SETFLD0
  } else {
        !set    caml_gen_SETFLDN = 1
        LDA # .n
        JSR caml_SETFLDN
  }
}
!macro  i49     {+i4d 0}                        ;SETFIELDi -> SETFIELD i
!macro  i4a     {+i4d 1}
!macro  i4b     {+i4d 2}
!macro  i4c     {+i4d 3}
!macro  i4e .n {                                ;SETFLOATFIELD n
        +caml_range 0, .n, $FF div Double_wosize, "SETFLOATFIELD n: n"
        .n2l = <(2 * .n * Double_wosize)
        .n2h = >(2 * .n * Double_wosize)
        !set    caml_gen_SETFFLD0 = 1
  !if .n2h > 0 {
        INC ACCU + 1
  }
  !if .n2l > 0 {
        !set    caml_gen_SETFFLDN = 1
        LDA # .n2l
        JSR caml_SETFFLDN
  } else {
        JSR caml_SETFFLD0
  }
}
!macro  i4f {                                   ;VECTLENGTH
        !set    caml_gen_VECLEN = 1
        JSR caml_VECLEN
}
!macro  i50 {                                   ;GETVECTITEM
        !set    caml_gen_GETVEC = 1
        JSR caml_GETVEC
}
!macro  i51 {                                   ;SETVECTITEM
        !set    caml_gen_SETVEC = 1
        JSR caml_SETVEC
}

;; i94 depends on i52
!macro  i52 {                                   ;GETBYTESCHAR
        !set    caml_gen_GETCHR = 1
        JSR caml_GETCHR
}
!macro  i53 {                                   ;SETBYTESCHAR
        !set    caml_gen_SETCHR = 1
        JSR caml_SETCHR
}
!macro  i54 .p {                                ;BRANCH p
        JMP .p
}
!macro  i55 .p {                                ;BRANCHIF p
        LDA ACCU
        LSR
        ORA ACCU + 1
        BEQ +
        JMP .p
+
}
!macro  i56 .p {                                ;BRANCHIFNOT p
        LDA ACCU
        LSR
        ORA ACCU + 1
        BNE +
        JMP .p
+
}
!macro  i57 .n, .tab {                          ;SWITCH n tab
        +caml_range 0, .n, $FF, "SWITCH n t: n"
  !if (0 < .n) & (.n < len(.tab)) {             ;both iptrs & pptrs present,
        LDA ACCU                                ;select the appropriate
        AND # 1                                 ;jumptable section
        BEQ .pptrs
  }
  !if 0 < .n {
        !set    caml_gen_SWITCHI = 1            ;iptrs: pointers are stored in
        LDA # <(.adr - 1)                       ;ACCU = offset + 1,
        LDX # >(.adr - 1)                       ;so base address = .adr - 1
        JMP caml_SWITCHI                             ;tab[0]...tab[n-1],
  }
.pptrs
  !if .n < len(.tab) {
        !set    caml_gen_SWITCHP = 1            ;pptrs: pointers are stored in
        LDA # <(.adr + 2 * .n)                  ;Tag(ACCU) = offset,
        LDX # >(.adr + 2 * .n)                  ;so base address = .adr + 2 * .n
        JMP caml_SWITCHP                             ;tab[n]...tab[len-1],
  }
        !align $01, $00                         ;avoid JMP($xxFF) bug
.adr    !word .tab                              ;jumptable
}
!macro  i58 {                                   ;BOOLNOT
        !set    caml_gen_BOOLNOT = 1
        JSR caml_BOOLNOT
}
!macro  i59 .p {                                ;PUSHTRAP p
        !set    caml_gen_PHTRP = 1
        LDA # <.p
        LDX # >.p
        JSR caml_PHTRP
}
!macro  i5a {                                   ;POPTRAP
        !set    caml_gen_POPTRP = 1
        JSR caml_POPTRP
}

;; i92-i93 depend on i5b
!macro  i5b {                                   ;RAISE
        JMP caml_RAISE
}
!macro  i5c { }                                 ;CHECKSIGNALS = NOP

;; i5d-i61 depend on i62
!macro  i62 .p, .n {                            ;CCALL p n
        +caml_range 0, .p, $FF, "CCALL p n: p"
        +caml_range 1, .n, $FF, "CCALL p n: n"
        !set    caml_gen_CCALL = 1
        LDX # .p                                ;load routine's index
        LDA # .n - 1                            ;load # of args on stack
        JSR caml_CCALL
}
!macro  i5d .p  {+i62 .p, 1}                    ;CCALLi p -> CCALL p i
!macro  i5e .p  {+i62 .p, 2}
!macro  i5f .p  {+i62 .p, 3}
!macro  i60 .p  {+i62 .p, 4}
!macro  i61 .p  {+i62 .p, 5}

;; i63-i66, i68-i6c depend on i67
!macro  i67 .n {                                ;CONSTINT n
        +caml_range -$4000, .n, $7FFF, "CONSTINT n: n"
        +Val_Int ~.v, .n
        LDA # <.v
        STA ACCU
  !if >.v = 0 {
        STY ACCU + 1
  } else {
        LDA # >.v
        STA ACCU + 1
  }
}
!macro  i63     {+i67 0}                        ;CONSTi -> CONSTINT i
!macro  i64     {+i67 1}
!macro  i65     {+i67 2}
!macro  i66     {+i67 3}
!macro  i68     {+i09 : +i67 0}                 ;PUSHCONSTi -> PUSH;...
!macro  i69     {+i09 : +i67 1}
!macro  i6a     {+i09 : +i67 2}
!macro  i6b     {+i09 : +i67 3}
!macro  i6c .n  {+i09 : +i67 .n}                ;PUSHCONSTINT n -> PUSH;...
!macro  i6d {                                   ;NEGINT
        !set    caml_gen_NEGINT = 1
        JSR caml_NEGINT
}
!macro  i6e {                                   ;ADDINT
        !set    caml_gen_ADDINT = 1
        JSR caml_ADDINT
}
!macro  i6f {                                   ;SUBINT
        !set    caml_gen_SUBINT = 1
        JSR caml_SUBINT
}
!macro  i70 {                                   ;MULINT
        !set    caml_gen_MULINT = 1
        JSR caml_MULINT
}
!macro  i71 {                                   ;DIVINT
        !set    caml_gen_DIVINT = 1
        !set    caml_gen_DIVMOD = 1
        JSR caml_DIVINT
}
!macro  i72 {                                   ;MODINT
        !set    caml_gen_MODINT = 1
        !set    caml_gen_DIVMOD = 1
        JSR caml_MODINT
}
!macro  i73 {                                   ;ANDINT
        !set    caml_gen_ANDINT = 1
        JSR caml_ANDINT
}
!macro  i74 {                                   ;ORINT
        !set    caml_gen_ORINT = 1
        JSR caml_ORINT
}
!macro  i75 {                                   ;XORINT
        !set    caml_gen_XORINT = 1
        JSR caml_XORINT
}
!macro  i76 {                                   ;LSLINT
        !set    caml_gen_LSLINT = 1
        JSR caml_LSLINT
}
!macro  i77 {                                   ;LSRINT
        !set    caml_gen_LSRINT = 1
        JSR caml_LSRINT
}
!macro  i78 {                                   ;ASRINT
        !set    caml_gen_ASRINT = 1
        !set    caml_gen_LSRINT = 1
        JSR caml_ASRINT
}
!macro  i79 {                                   ;EQ
        !set    caml_gen_EQ = 1
        !set    caml_gen_CMPRES = 1
        JSR caml_EQ
}
!macro  i7a {                                   ;NEQ
        !set    caml_gen_NEQ = 1
        !set    caml_gen_CMPRES = 1
        JSR caml_NEQ
}
!macro  i7b {                                   ;LTINT
        !set    caml_gen_LTINT = 1
        !set    caml_gen_CMPRES = 1
        JSR caml_LTINT
}
!macro  i7c {                                   ;LEINT
        !set    caml_gen_LEINT = 1
        !set    caml_gen_CMPRES = 1
        JSR caml_LEINT
}
!macro  i7d {                                   ;GTINT
        !set    caml_gen_GTINT = 1
        !set    caml_gen_CMPRES = 1
        JSR caml_GTINT
}
!macro  i7e {                                   ;GEINT
        !set    caml_gen_GEINT = 1
        !set    caml_gen_CMPRES = 1
        JSR caml_GEINT
}
!macro  i7f .n {                                ;OFFSETINT n
        +caml_range -$4000, .n, $3FFF, "OFFSETINT n: n"
        .n2h = >(2 * .n)
        .n2l = <(2 * .n)
        !set    caml_gen_OFSINT = 1
  !if .n2h > 0 {
        LDY # .n2h
  }
        LDA # .n2l
        JSR caml_OFSINT
}
!macro  i80 .n {                                ;OFFSETREF n
        +caml_range -$4000, .n, $3FFF, "OFFSETREF n: n"
        .n2h = >(2 * .n)
        .n2l = <(2 * .n)
        !set    caml_gen_OFSREF = 1
  !if .n2h > 0 {
        LDY # .n2h
  }
        LDA # .n2l
        JSR caml_OFSREF
}
!macro  i81 {                                   ;ISINT
        !set    caml_gen_ISINT = 1
        JSR caml_ISINT
}
!macro  i83 .n, .p {                            ;BEQ n p
        +caml_range -$4000, .n, $3FFF, "BEQ n p: n"
        +Val_Int ~.v, .n
        LDA ACCU
        CMP # <.v
        BNE +
        LDA ACCU + 1
  !if >.v > 0 {
        CMP # >.v
  }
        BNE +
        JMP .p
+
}
!macro  i84 .n, .p {                            ;BNEQ n p
        +caml_range -$4000, .n, $3FFF, "BNEQ n p: n"
        +Val_Int ~.v, .n
        LDA ACCU
        CMP # <.v
        BEQ +
-       JMP .p
+       LDA ACCU + 1
  !if >.v > 0 {
        CMP # >.v
  }
        BNE -
}
!macro  i85 .n, .p {                            ;BLTINT n p
        +caml_range -$4000, .n, $3FFF, "BLTINT n p: n"
        +Val_Int ~.v, .n
        !set    caml_gen_SGNCMP = 1
        LDA # <.v
  !if >.v > 0 {
        LDY # >.v
  }
        JSR caml_SGNCMP
        BPL +
        JMP .p
+
}
!macro  i86 .n, .p {                            ;BLEINT n p
        +caml_range -$4000, .n, $3FFF, "BLEINT n p: n"
        +Val_Int ~.v, .n
        !set    caml_gen_SGNCMP = 1
        LDA # $FE & <.v
  !if >.v > 0 {
        LDY # >.v
  }
        JSR caml_SGNCMP
        BPL +
        JMP .p
+
}
!macro  i87 .n, .p {                            ;BGTINT n p
        +caml_range -$4000, .n, $3FFF, "BGTINT n p: n"
        +Val_Int ~.v, .n
        !set    caml_gen_SGNCMP = 1
        LDA # $FE & <.v
  !if >.v > 0 {
        LDY # >.v
  }
        JSR caml_SGNCMP
        BMI +
        JMP .p
+
}
!macro  i88 .n, .p {                            ;BGEINT n p
        +caml_range -$4000, .n, $3FFF, "BGEINT n p: n"
        +Val_Int ~.v, .n
        !set    caml_gen_SGNCMP = 1
        LDA # <.v
  !if >.v > 0 {
        LDY # >.v
  }
        JSR caml_SGNCMP
        BMI +
        JMP .p
+
}
!macro  i89 {                                   ;ULTINT
        !set    caml_gen_ULTINT = 1
        JSR caml_ULTINT
}
!macro  i8a {                                   ;UGEINT
        !set    caml_gen_UGEINT = 1
        JSR caml_UGEINT
}
!macro  i8b .n, .p {                            ;BULTINT n p
        +caml_range -$4000, .n, $7FFF, "BULTINT n p: n"
        +Val_Int ~.v, .n
        LDA # <.v
        CMP ACCU
  !if >.v > 0 {
        LDA # >.v
  } else {
        TYA
  }
        SBC ACCU + 1
        BCS +
        JMP .p
+
}
!macro  i8c .n, .p {                            ;BUGEINT n p
        +caml_range -$4000, .n, $7FFF, "BUGEINT n p: n"
        +Val_Int ~.v, .n
        LDA # <.v
        CMP ACCU
  !if >.v > 0 {
        LDA # >.v
  } else {
        TYA
  }
        SBC ACCU + 1
        BCC +
        JMP .p
+
}
!macro  i8f {                                   ;STOP
        JMP caml_STOP
}
!macro  i90     {}                              ;EVENT = NOP
!macro  i91     {}                              ;BREAK = NOP
!macro  i92     {+i5b}                          ;RERAISE -> RAISE
!macro  i93     {+i5b}                          ;RAISENOTRACE -> RAISE
!macro  i94     {+i52}                          ;GETSTRINGCHAR -> GETBYTESCHAR

} ;ifndef caml_INTERP


!ifdef caml_INTERP {
        ;; --------------------------------------------------------------------
        ;;      BYTECODE GENERATION
        ;; --------------------------------------------------------------------

        ;;  $5c, $90, $91                       ignored
        ;;  $82, $8d, $8e                       error (operations on objects)
        ;;  $0a, $3b, $3d, $92, $93, $94        replaced by other opcodes

;; Macros in opcode order
        
!macro i00  {   !set    caml_gen_ACC0_OFSREF=1
                !set    caml_gen_ACC07=1
                !set    caml_gen_ACCL=1
                !by $00 }
!macro i01  {   !set    caml_gen_ACC1_ISINT=1
                !set    caml_gen_ACC07=1
                !set    caml_gen_ACCL=1
                !by $01 }
!macro i02  {   !set    caml_gen_ACC07=1
                !set    caml_gen_ACCL=1
                !by $02 }
!macro i03  {   !set    caml_gen_ACC3_BEQ=1
                !set    caml_gen_ACC07=1
                !set    caml_gen_ACCL=1
                !by $03 }
!macro i04 {    !set    caml_gen_ACC4_BNEQ=1
                !set    caml_gen_ACC07=1
                !set    caml_gen_ACCL=1
                !by $04 }
!macro i05 {    !set    caml_gen_ACC5_BLTINT=1
                !set    caml_gen_ACC07=1
                !set    caml_gen_ACCL=1
                !by $05 }
!macro i06 {    !set    caml_gen_ACC6_BLEINT=1
                !set    caml_gen_ACC07=1
                !set    caml_gen_ACCL=1
                !by $06 }
!macro i07 {    !set    caml_gen_ACC7_BGTINT=1
                !set    caml_gen_ACC07=1
                !set    caml_gen_ACCL=1
                !by $07 }
!macro i08 .n { +caml_range 0, .n, $7FFF, "ACC n: n"
                !set    caml_gen_ACC_BGEINT=1
                !set    caml_gen_ACCH=1
                !by $08 : !wo 2 * .n }
!macro i09 {    !set    caml_gen_PUSH_ULTINT=1
                !set    caml_gen_PUSH=1
                !by $09 }
!macro i0a {    !set    caml_gen_PUSH_ULTINT=1
                !set    caml_gen_PUSH=1
                !by $09 }                       ;*** PUSHACC0 -> caml_PUSH ***
!macro i0b {    !set    caml_gen_PHACC1_BULTINT=1
                !set    caml_gen_PHACC17=1
                !set    caml_gen_PUSH=1
                !set    caml_gen_ACCL=1
                !by $0b }
!macro i0c {    !set    caml_gen_PHACC2_BUGEINT=1
                !set    caml_gen_PHACC17=1
                !set    caml_gen_PUSH=1
                !set    caml_gen_ACCL=1
                !by $0c }
!macro i0d {    !set    caml_gen_PHACC17=1
                !set    caml_gen_PUSH=1
                !set    caml_gen_ACCL=1
                !by $0d }
!macro i0e {    !set    caml_gen_PHACC17=1
                !set    caml_gen_PUSH=1
                !set    caml_gen_ACCL=1
                !by $0e }
!macro i0f {    !set    caml_gen_PHACC5_STOP=1
                !set    caml_gen_PHACC17=1
                !set    caml_gen_PUSH=1
                !set    caml_gen_ACCL=1
                !by $0f }
!macro i10 {    !set    caml_gen_PHACC17=1
                !set    caml_gen_PUSH=1
                !set    caml_gen_ACCL=1
                !by $10 }
!macro i11 {    !set    caml_gen_PHACC17=1
                !set    caml_gen_PUSH=1
                !set    caml_gen_ACCL=1
                !by $11 }
!macro i12 .n { +caml_range 0, .n, $7FFF, "PUSHACC n: n"
                !set    caml_gen_PHACC=1
                !set    caml_gen_PUSH=1
                !set    caml_gen_ACCH=1
                !by $12 : !wo 2 * .n }
!macro i13 .n { +caml_range 0, .n, $7FFF, "POP n: n"
                !set    caml_gen_POPN=1
                !by $13 : !wo 2 * .n }
!macro i14 .n { +caml_range 0, .n, $7FFF, "ASSIGN n: n"
                !set    caml_gen_ASSIGNH=1
                !set    caml_gen_ASSIGNL=1
                !by $14 : !wo 2 * .n }  
!macro i15 {    !set    caml_gen_ENVACC14=1
                !set    caml_gen_ENVACC=1
                !by $15 }
!macro i16 {    !set    caml_gen_ENVACC14=1
                !set    caml_gen_ENVACC=1
                !by $16 }
!macro i17 {    !set    caml_gen_ENVACC14=1
                !set    caml_gen_ENVACC=1
                !by $17 }
!macro i18 {    !set    caml_gen_ENVACC14=1
                !set    caml_gen_ENVACC=1
                !by $18 }
!macro i19 .n { +caml_range 0, .n, $FE, "ENVACC n: n"
                !set    caml_gen_ENVACCN=1
                !set    caml_gen_ENVACC=1
                !by $19, .n }
!macro i1a {    !set    caml_gen_PHENVACC14=1
                !set    caml_gen_PUSH=1
                !set    caml_gen_ENVACC=1
                !by $1a }
!macro i1b {    !set    caml_gen_PHENVACC14=1
                !set    caml_gen_PUSH=1
                !set    caml_gen_ENVACC=1
                !by $1b }
!macro i1c {    !set    caml_gen_PHENVACC14=1
                !set    caml_gen_PUSH=1
                !set    caml_gen_ENVACC=1
                !by $1c }
!macro i1d {    !set    caml_gen_PHENVACC14=1
                !set    caml_gen_PUSH=1
                !set    caml_gen_ENVACC=1
                !by $1d }
!macro i1e .n { +caml_range 0, .n, $FE, "PUSHENVACC n: n"
                !set    caml_gen_PHENVACC=1
                !set    caml_gen_PUSH=1
                !set    caml_gen_ENVACCN=1
                !set    caml_gen_ENVACC=1
                !by $1e, .n }
!macro i1f .p { !set    caml_gen_PHRET=1
                !by $1f : !wo .p }
!macro i20 .n { +caml_range 1, .n, $7F, "APPLY n: n"
                !set    caml_gen_APPLYN=1
                !set    caml_gen_APPLY=1
                !by $20, 2 * .n - 1 }
!macro i21 {    !set    caml_gen_APPLY13=1
                !set    caml_gen_APPLY=1
                !by $21 }
!macro i22 {    !set    caml_gen_APPLY13=1
                !set    caml_gen_APPLY=1
                !by $22 }
!macro i23 {    !set    caml_gen_APPLY13=1
                !set    caml_gen_APPLY=1
                !by $23 }
!macro i24 .n, .s {
                +caml_range 1, .n, $7F, "APPTERM n s: n"
                +caml_range .n, .s, $7F, "APPTERM n s: s"
                !set    caml_gen_APPTRMN=1
                !set    caml_gen_APPTRM1=1
                !by $24, 2 * (.s - .n), 2 * (.n - 1) }
!macro i25 .s { +caml_range 1, .s, $7F, "APPTERM1 s: s"
                !set    caml_gen_APPTRM13=1
                !set    caml_gen_APPTRM1=1
                !by $25, 2 * (.s - 1) }
!macro i26 .s { +caml_range 2, .s, $7F, "APPTERM2 s: s"
                !set    caml_gen_APPTRM13=1
                !set    caml_gen_APPTRM1=1
                !by $26, 2 * (.s - 2) }
!macro i27 .s { +caml_range 3, .s, $7F, "APPTERM3 s: s"
                !set    caml_gen_APPTRM13=1
                !set    caml_gen_APPTRM1=1
                !by $27, 2 * (.s - 3) }
!macro i28 .n { +caml_range 0, .n, $7F, "RETURN n: n"
                !set    caml_gen_RETURN=1
                !set    caml_gen_GORETURN=1
                !by $28, 2 * .n }
!macro i29 {    !set    caml_gen_RESTART=1
                !set    caml_restart_len = 1    ;needed by caml_GRAB routine
                !by $29 }
!macro i2a .n { +caml_range 0, .n, $7C, "GRAB n: n"
                !set    caml_gen_GRAB=1
                !set    caml_gen_GORETURN=1
                !set    caml_grab_len = 2       ;needed by caml_GRAB routine
                !by $2a, 2 * .n + 1 }
!macro i2b .n, .p {
                +caml_range 0, .n, $7F, "CLOSURE n p: n"
                !set    caml_gen_CLOSURE=1
                !by $2b, .n : !wo .p }
!macro i2c .f, .v, .o, .t {
                +caml_range 1, .f, $80, "CLOSUREREC f v o t: f"
                +caml_range 0, .v, $FE, "CLOSUREREC f v o t: v"
                +caml_range 1, 2 * .f - 1 + .v, $FF, "CLOSUREREC f v o t: 2f-1+v"
                !set    caml_gen_CLOSREC=1
                !by $2c, .v, .f : !wo .o, .t }
!macro i2d {    !set    caml_gen_OFSCLM2=1
                !by $2d }
!macro i2e {    !set    caml_gen_OFSCL0=1
                !by $2e }
!macro i2f {    !set    caml_gen_OFSCL2=1
                !by $2f }
!macro i30 .n { +caml_range -$FE, .n, $FE, "OFFSETCLOSURE n: n"
                +caml_range 0, .n mod 2, 0, "OFFSETCLOSURE n: n mod 2"
                !set    caml_gen_OFSCLN=1
                !by $30 : !wo 2 * .n }
!macro i31 {    !set    caml_gen_PHOFSCLM2=1
                !set    caml_gen_PUSH=1
                !set    caml_gen_OFSCLM2=1
                !by $31 }
!macro i32 {    !set    caml_gen_PHOFSCL0=1
                !set    caml_gen_PUSH=1
                !set    caml_gen_OFSCL0=1
                !by $32 }
!macro i33 {    !set    caml_gen_PHOFSCL2=1
                !set    caml_gen_PUSH=1
                !set    caml_gen_OFSCL2=1
                !by $33 }
!macro i34 .n { +caml_range -$FE, .n, $FE, "PUSHOFFSETCLOSURE n: n"
                +caml_range 0, .n mod 2, 0, "PUSHOFFSETCLOSURE n: n mod 2"
                !set    caml_gen_PHOFSCLN=1
                !set    caml_gen_PUSH=1
                !set    caml_gen_OFSCLN=1
                !by $34 : !wo 2 * .n }
!macro i35 .n { +caml_range 0, .n, $7FFF, "GETGLOBAL n: n"
                !set    caml_gen_GETGLB=1
                !if .n < caml_exn_no {
                  !by $35 : !wo caml_std_exn[.n]
                } else {
                  .ofs = 2 * (.n - caml_exn_no)
                  !by $35 : !wo caml_glob_table + .ofs } }
!macro i36 .n { +caml_range 0, .n, $7FFF, "PUSHGETGLOBAL n: n"
                !set    caml_gen_PHGETGLB=1
                !set    caml_gen_PUSH=1
                !set    caml_gen_GETGLB=1
                !if .n < caml_exn_no {
                  !by $36 : !wo caml_std_exn[.n]
                } else {
                  .ofs = 2 * (.n - caml_exn_no)
                  !by $36 : !wo caml_glob_table + .ofs } }
!macro i37 .n, .m {
                +caml_range 0, .n, $7FFF, "GETGLOBALFIELD n m: n"
                +caml_range 0, .m, $FE, "GETGLOBALFIELD n m: m"
                !set    caml_gen_GETGLBFLD=1
                !set    caml_gen_GETGLB=1
                !if .n < caml_exn_no {
                  !by $37 : !wo caml_std_exn[.n] : !by .m
                } else {
                  .ofs = 2 * (.n - caml_exn_no)
                  !by $37 : !wo caml_glob_table + .ofs : !by .m } }
!macro i38 .n, .m {
                +caml_range 0, .n, $7FFF, "PUSHGETGLOBALFIELD n m: n"
                +caml_range 0, .m, $FE, "PUSHGETGLOBALFIELD n m: m"
                !set    caml_gen_PHGETGLBFLD=1
                !set    caml_gen_PUSH=1
                !set    caml_gen_GETGLBFLD=1
                !set    caml_gen_GETGLB=1
                !if .n < caml_exn_no {
                  !by $38 : !wo caml_std_exn[.n] : !by .m
                } else {
                  .ofs = 2 * (.n - caml_exn_no)
                  !by $38 : !wo caml_glob_table + .ofs : !by .m } }
!macro i39 .n { +caml_range caml_exn_no, .n, $7FFF, "SETGLOBAL n: n"
                .ofs = 2 * (.n - caml_exn_no)
                !set    caml_gen_SETGLB=1
                !by $39 : !wo caml_glob_table + .ofs }
!macro i3a {    !by $3a }
!macro i3b .n { +caml_range 0, .n, 0, "ATOM n: n"
                !set    caml_gen_ATOM0=1
                !by $3a }                       ;*** ATOM t -> ATOM0 ***
!macro i3c {    !by $3c }
!macro i3d .n { +caml_range 0, .n, 0, "PUSHATOM n: n"
                !set    caml_gen_PHATOM0=1
                !set    caml_gen_PUSH=1
                !set    caml_gen_ATOM0=1
                !by $3c }                       ;*** PUSHATOM t -> PUSHATOM0 ***
!macro i3e .t, .s {
                +caml_range 1, .s, $FF, "MAKEBLOCK t s: s"
                +caml_range 0, .t, $FF, "MAKEBLOCK t s: t"
                !set    caml_gen_MKBLKN=1
                !set    caml_gen_MKBLK=1
                !by $3e, .s, .t }
!macro i3f .t { +caml_range 0, .t, $FF, "MAKEBLOCK1 t: t"
                !set    caml_gen_MKBLK13=1
                !set    caml_gen_MKBLK=1
                !by $3f, .t }
!macro i40 .t { +caml_range 0, .t, $FF, "MAKEBLOCK2 t: t"
                !set    caml_gen_MKBLK13=1
                !set    caml_gen_MKBLK=1
                !by $40, .t }
!macro i41 .t { +caml_range 0, .t, $FF, "MAKEBLOCK3 t: t"
                !set    caml_gen_MKBLK13=1
                !set    caml_gen_MKBLK=1
                !by $41, .t }
!macro i42 .s { +caml_range 1, .s, $FF div Double_wosize, "MAKEFLOATBLOCK s: s"
                !set    caml_gen_MKFBLK=1
                !by $42, Double_wosize * .s }
!macro i43 {    !set    caml_gen_GETFLD0=1
                !by $43 }
!macro i44 {    !set    caml_gen_GETFLD13=1
                !set    caml_gen_GETFLD0=1
                !by $44 }
!macro i45 {    !set    caml_gen_GETFLD13=1
                !set    caml_gen_GETFLD0=1
                !by $45 }
!macro i46 {    !set    caml_gen_GETFLD13=1
                !set    caml_gen_GETFLD0=1
                !by $46 }
!macro i47 .n { +caml_range 0, .n, $FE, "GETFIELD n: n"
                !set    caml_gen_GETFLDN=1
                !set    caml_gen_GETFLD0=1
                !by $47, .n }
!macro i48 .n { +caml_range 0, .n, $FF div Double_wosize, "GETFLOATFIELD n: n"
                !set    caml_gen_GETFFLDN=1
                !set    caml_gen_GETFFLD0=1
                !by $48, Double_wosize * .n }
!macro i49 {    !set    caml_gen_SETFLD0=1
                !by $49 }
!macro i4a {    !set    caml_gen_SETFLD13=1
                !set    caml_gen_SETFLD0=1
                !by $4a }
!macro i4b {    !set    caml_gen_SETFLD13=1
                !set    caml_gen_SETFLD0=1
                !by $4b }
!macro i4c {    !set    caml_gen_SETFLD13=1
                !set    caml_gen_SETFLD0=1
                !by $4c }
!macro i4d .n { +caml_range 0, .n, $FE, "SETFIELD n: n"
                !set    caml_gen_SETFLDN=1
                !set    caml_gen_SETFLD0=1
                !by $4d, .n }
!macro i4e .n { +caml_range 0, .n, $FF div Double_wosize, "SETFLOATFIELD n: n"
                !set    caml_gen_SETFFLDN=1
                !set    caml_gen_SETFFLD0=1
                !by $4e, Double_wosize * .n }
!macro i4f {    !set    caml_gen_VECLEN=1
                !by $4f }
!macro i50 {    !set    caml_gen_GETVEC=1
                !by $50 }
!macro i51 {    !set    caml_gen_SETVEC=1
                !by $51 }
!macro i52 {    !set    caml_gen_GETCHR=1
                !by $52 }
!macro i53 {    !set    caml_gen_SETCHR=1
                !by $53 }
!macro i54 .p { !by $54 : !wo .p }
!macro i55 .p { !set    caml_gen_BIF=1
                !by $55 : !wo .p }
!macro i56 .p { !set    caml_gen_BIFNOT=1
                !by $56 : !wo .p }
!macro i57 .n, .tab {
                +caml_range 0, .n, $FF, "SWITCH n t: n"
                !set    caml_gen_SWITCH=1
                !set    caml_gen_SWITCHI=1
                !set    caml_gen_SWITCHP=1
                !by $57, .n : !wo .tab }
!macro i58 {    !set    caml_gen_BOOLNOT=1
                !by $58 }
!macro i59 .p { !set    caml_gen_PHTRP=1
                !by $59 : !wo .p }
!macro i5a {    !set    caml_gen_POPTRP=1
                !by $5a }
!macro i5b {    !by $5b }
!macro i5c { }                                  ;*** CHECKSIGNALS = NOP ***
!macro i5d .p { +caml_range 0, .p, $FF, "CCALL1 p: p"
                !set    caml_gen_CCALL=1
                !by $5d, .p }
!macro i5e .p { +caml_range 0, .p, $FF, "CCALL2 p: p"
                !set    caml_gen_CCALL=1
                !by $5e, .p }
!macro i5f .p { +caml_range 0, .p, $FF, "CCALL3 p: p"
                !set    caml_gen_CCALL=1
                !by $5f, .p }
!macro i60 .p { +caml_range 0, .p, $FF, "CCALL4 p: p"
                !set    caml_gen_CCALL=1
                !by $60, .p }
!macro i61 .p { +caml_range 0, .p, $FF, "CCALL5 p: p"
                !set    caml_gen_CCALL=1
                !by $61, .p }
!macro i62 .p, .n {
                +caml_range 0, .p, $FF, "CCALL p n: p"
                +caml_range 1, .n, $FF, "CCALL p n: n"
                !set    caml_gen_CCALL=1
                !by $62, .n - 1, .p }
!macro i63 {    !set    caml_gen_CST03=1
                !by $63 }
!macro i64 {    !set    caml_gen_CST03=1
                !by $64 }
!macro i65 {    !set    caml_gen_CST03=1
                !by $65 }
!macro i66 {    !set    caml_gen_CST03=1
                !by $66 }
!macro i67 .n { +caml_range -$4000, .n, $7FFF, "CONSTINT n: n"
                !set    caml_gen_CSTN=1
                !by $67 : !wo 2 * .n + 1 }
!macro i68 {    !set    caml_gen_PHCST03=1
                !set    caml_gen_PUSH=1
                !by $68 }
!macro i69 {    !set    caml_gen_PHCST03=1
                !set    caml_gen_PUSH=1
                !by $69 }
!macro i6a {    !set    caml_gen_PHCST03=1
                !set    caml_gen_PUSH=1
                !by $6a }
!macro i6b {    !set    caml_gen_PHCST03=1
                !set    caml_gen_PUSH=1
                !by $6b }
!macro i6c .n { +caml_range -$4000, .n, $7FFF, "PUSHCONSTINT n: n"
                !set    caml_gen_PHCSTN=1
                !set    caml_gen_PUSH=1
                !set    caml_gen_CSTN=1
                !by $6c : !wo 2 * .n + 1 }
!macro i6d {    !set    caml_gen_NEGINT=1
                !by $6d }
!macro i6e {    !set    caml_gen_ADDINT=1
                !by $6e }
!macro i6f {    !set    caml_gen_SUBINT=1
                !by $6f }
!macro i70 {    !set    caml_gen_MULINT=1
                !by $70 }
!macro i71 {    !set    caml_gen_DIVINT=1
                !set    caml_gen_DIVMOD=1
                !by $71 }
!macro i72 {    !set    caml_gen_MODINT=1
                !set    caml_gen_DIVMOD=1
                !by $72 }
!macro i73 {    !set    caml_gen_ANDINT=1
                !by $73 }
!macro i74 {    !set    caml_gen_ORINT=1
                !by $74 }
!macro i75 {    !set    caml_gen_XORINT=1
                !by $75 }
!macro i76 {    !set    caml_gen_LSLINT=1
                !by $76 }
!macro i77 {    !set    caml_gen_LSRINT=1
                !by $77 }
!macro i78 {    !set    caml_gen_ASRINT=1
                !set    caml_gen_LSRINT=1
                !by $78 }
!macro i79 {    !set    caml_gen_EQ=1
                !set    caml_gen_CMPRES=1
                !by $79 }
!macro i7a {    !set    caml_gen_NEQ=1
                !set    caml_gen_CMPRES=1
                !by $7a }
!macro i7b {    !set    caml_gen_LTINT=1
                !set    caml_gen_CMPRES=1
                !by $7b }
!macro i7c {    !set    caml_gen_LEINT=1
                !set    caml_gen_CMPRES=1
                !by $7c }
!macro i7d {    !set    caml_gen_GTINT=1
                !set    caml_gen_CMPRES=1
                !by $7d }
!macro i7e {    !set    caml_gen_GEINT=1
                !set    caml_gen_CMPRES=1
                !by $7e }
!macro i7f .n { +caml_range -$4000, .n, $3FFF, "OFFSETINT n: n"
                !set    caml_gen_OFSINT=1
                !by $7f : !wo 2 * .n }
!macro i80 .n { +caml_range -$4000, .n, $3FFF, "OFFSETREF n: n"
                !set    caml_gen_ACC0_OFSREF=1
                !set    caml_gen_OFSREF=1
                !by $80 : !wo 2 * .n }
!macro i81 {    !set    caml_gen_ACC1_ISINT=1
                !set    caml_gen_ISINT=1
                !by $81 }
!macro i83 .n, .p {
                +caml_range -$4000, .n, $3FFF, "BEQ n p: n"
                !set    caml_gen_ACC3_BEQ=1
                !set    caml_gen_BEQ=1
                !by $83 : !wo 2 * .n + 1, .p }
!macro i84 .n, .p {
                +caml_range -$4000, .n, $3FFF, "BNEQ n p: n"
                !set    caml_gen_ACC4_BNEQ=1
                !set    caml_gen_BNEQ=1
                !by $84 : !wo 2 * .n + 1, .p }
!macro i85 .n, .p {
                +caml_range -$4000, .n, $3FFF, "BLTINT n p: n"
                !set    caml_gen_ACC5_BLTINT=1
                !set    caml_gen_BLTLEINT=1
                !set    caml_gen_SGNCMP=1
                !by $85 : !wo 2 * .n + 1, .p }
!macro i86 .n, .p {
                +caml_range -$4000, .n, $3FFF, "BLEINT n p: n"
                !set    caml_gen_ACC6_BLEINT=1
                !set    caml_gen_BLTLEINT=1
                !set    caml_gen_SGNCMP=1
                !by $86 : !wo 2 * .n, .p }      ;Note: 2 * .n, not 2 * .n + 1!
!macro i87 .n, .p {
                +caml_range -$4000, .n, $3FFF, "BGTINT n p: n"
                !set    caml_gen_ACC7_BGTINT=1
                !set    caml_gen_BGTGEINT=1
                !set    caml_gen_SGNCMP=1
                !by $87 : !wo 2 * .n, .p }      ;Note: 2 * .n, not 2 * .n + 1!
!macro i88 .n, .p {
                +caml_range -$4000, .n, $3FFF, "BGEINT n p: n"
                !set    caml_gen_ACC_BGEINT=1
                !set    caml_gen_BGTGEINT=1
                !set    caml_gen_SGNCMP=1
                !by $88 : !wo 2 * .n + 1, .p }
!macro i89 {    !set    caml_gen_PUSH_ULTINT=1
                !set    caml_gen_ULTINT=1
                !by $89 }
!macro i8a {    !set    caml_gen_UGEINT=1
                !by $8a }
!macro i8b .n, .p {
                +caml_range -$4000, .n, $7FFF, "BULTINT n p: n"
                !set    caml_gen_PHACC1_BULTINT=1
                !set    caml_gen_BULTINT=1
                !by $8b : !wo 2 * .n + 1, .p }
!macro i8c .n, .p {
                +caml_range -$4000, .n, $7FFF, "BUGEINT n p: n"
                !set    caml_gen_PHACC2_BUGEINT=1
                !set    caml_gen_BUGEINT=1
                !by $8c : !wo 2 * .n + 1, .p }
!macro i8f {    !set    caml_gen_PHACC5_STOP=1
                !by $8f }
!macro i90 { }                                  ;EVENT = NOP
!macro i91 { }                                  ;BREAK = NOP
!macro i92 {    !by $5b }                       ;RERAISE -> RAISE
!macro i93 {    !by $5b }                       ;RAISENOTRACE -> RAISE
!macro i94 {    !by $52 }                       ;GETSTRINGCHAR -> GETBYTESCHAR

} ;ifdef caml_INTERP

} ;zone caml_CODEGEN
