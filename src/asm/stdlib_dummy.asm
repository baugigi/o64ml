;;; -----------------------------------------------------------
:;; ALLOC DUMMY (ocaml-4.04.1/byterun/alloc.c)
;;; -----------------------------------------------------------

!zone caml_DUMMY {

!ifdef caml_PRIM__caml_alloc_dummy_function {
caml_alloc_dummy_function = caml_alloc_dummy
}
!ifdef caml_PRIM__caml_alloc_dummy {
        ;; allocate a dummy block for a recursive value (or function)
        ;; ACCU = size, (SP[0] = function arity, ignored)
caml_alloc_dummy
        LSR ACCU + 1
        LDA ACCU
        ROR
        BEQ +                           ; size = 0
        ;; allocate block
        TAX
        TYA
        JSR caml_alloc
        LDA BLK
        STA ACCU
        LDA BLK + 1
        STA ACCU + 1
        RTS
        ;; Atom(0)
+       LDA # < caml_atom0
        STA ACCU
        LDA # > caml_atom0
        STA ACCU + 1
        RTS
}

!ifdef caml_PRIM__caml_alloc_dummy_float {
        ;; allocate a dummy block for a recursive array/record of floats
        ;; ACCU = no. of floats
caml_alloc_dummy_float
        ;; ignore ACCU + 1, as 0 <= no. of floats <= 85
        LDA ACCU
        LSR
        BEQ +                           ; Atom(0)
        ;; X <- no. of floats * Double_wosize
        CLC
        ADC ACCU
        TAX
        DEX
        ;; allocate block
        TYA                             ; A = Y = 0
        JSR caml_alloc
        LDA BLK
        STA ACCU
        LDA BLK + 1
        STA ACCU + 1
        RTS
        ;; Atom(0)
+       LDA # < caml_atom0
        STA ACCU
        LDA # > caml_atom0
        STA ACCU + 1
        RTS
}

!ifdef caml_PRIM__caml_update_dummy {
        ;; update a dummy block with given value
        ;; ACCU = dummy, SP[0] = newval
caml_update_dummy
        ;; load newval size
        LDA (SP),Y
        STA TMP
        INY
        LDA (SP),Y
        STA TMP + 1
        LDY # -1
        DEC TMP + 1
        LDA (TMP),y
        BNE +
        ;; size = 0, update nothing
        INY                             ; Y = 0
        BEQ ++
        ;; tag(dummy) <- tag(newval)
+       TAX                             ; save size
        DEY
        DEC ACCU + 1
        LDA (TMP),y
        STA (ACCU),y
        INC ACCU + 1
        INC TMP + 1
        ;; copy newval fields into dummy ones
        TXA                             ; reload size
        ASL
        TAY                             ; Y = 2 * size, Carry = MSB
        JSR caml_blkcpy
        ;; ACCU <- ()
++      STY ACCU + 1                    ; Y = 0
        LDA # <Val_unit
        STA ACCU
        RTS
}

}       ;; !zone caml_DUMMY
