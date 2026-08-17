;;; ---------------------------------------------------------------------
;;; INTERNAL REPRESENTATION OF VALUES (ocaml-4.14.4/runtime/obj.c)
;;; ---------------------------------------------------------------------

!zone caml_OBJ {

!ifndef caml_obj_warn {
  !warn "TODO: caml_obj_warn"
  !warn "TODO: caml_obj_make_forward"
  !warn "TODO: caml_obj_raw_field"
  !warn "TODO: caml_obj_set_raw_field"
  !warn "TODO: caml_obj_with_tag"
  !warn "TODO: check for GC-invalidated pointers"
}
caml_OOID
        !word Val_zero

!ifdef caml_PRIM__caml_obj_tag {
        ;; return tag(value)
        ;; ACCU = value
caml_obj_tag
        LDA ACCU
        BIT caml_is_block
        BNE @int
        LDX ACCU + 1
        CPX # > caml_heap_start
        BCC @ooh
        BNE +
        CMP # < caml_heap_start
        BCC @ooh
+       CPX # > caml_heap_end
        BCC +
        BNE @ooh
        CMP # < caml_heap_end
        BCS @ooh
        ;; Val_int(tag(ACCU))
+       LDY # -2
        DEC ACCU + 1
        LDA (ACCU),Y
        SEC
        ROL
        STA ACCU
        LDY # 0
        STY ACCU + 1
        ROL ACCU + 1
        RTS
@ooh    +Val_Int ~@oohtag, Out_of_heap_tag
        LDA # > @ohtag
        LDX # < @oohtag
        BNE @res                                ;BNE = JMP
@int    +Val_Int ~@inttag, Int_tag
        LDA # > @inttag
        LDX # < @inttag
@res    STA ACCU + 1
        STX ACCU
        RTS
}

!ifdef caml_PRIM__caml_obj_set_tag {
        ;; ACCU = value
        ;; SP[0] = new tag
caml_obj_set_tag
        INY
        LDA (SP),Y
        LSR
        DEY
        LDA (SP),Y
        ROR
        LDY # -2
        DEC ACCU + 1
        STA (ACCU),Y
        LDY # <Val_unit
        STY ACCU
        DEY
        STY ACCU + 1
        RTS
}

!ifdef caml_PRIM__caml_obj_block {
        ;; ACCU = tag
        ;; SP[0] = size
caml_obj_block
        INY
        LDA (SP),Y
        LSR
        DEY
        LDA (SP),Y
        ROR
        BNE +
        ;; return Atom(0) if size = 0
        LDA # < caml_atom0
        STA ACCU
        LDA # > caml_atom0
        STA ACCU + 1
        RTS
        ;; allocate a new block if size > 0
+       TAX
        LSR ACCU + 1
        LDA ACCU
        ROR
        JSR caml_alloc
        LDA BLK
        STA ACCU
        LDA BLK + 1
        STA ACCU + 1
        ;; fill fields with Val_int(0)
-       LDA # < Val_zero
        STA (BLK),Y
        INY
        LDA # > Val_zero
        STA (BLK),Y
        INY
        BNE +
        INC BLK + 1
+       DEX
        BNE -
        LDY # 0
        RTS
}

!ifdef caml_PRIM__caml_obj_dup {
        ;; ACCU = arg
caml_obj_dup
        DEY
        DEC ACCU + 1
        LDA (ACCU),Y                            ; A := size
        BEQ @atom                               ; exit if size = 0
        TAX                                     ; X := size
        DEY
        LDA (ACCU),Y                            ; A := tag
        INC ACCU + 1                            ; restore pointer
        LDY # 0                                 ;   and Y register
        JSR caml_alloc                          ; allocate a new block
        TXA                                     ; A := size
        ASL
        TAY                                     ; Y,C := 2 * size
        JSR caml_blkcpy                         ; copy the blk pointed by ACCU
        LDA BLK
        STA ACCU
        LDA BLK + 1
        STA ACCU + 1
        RTS
@atom   INC ACCU + 1
        INY
        RTS
}

!ifdef caml_PRIM__caml_set_oo_id {
caml_set_oo_id
        LDY # 3
        LDA caml_OOID + 1
        STA (ACCU),Y
        DEY
        LDA caml_OOID
        STA (ACCU),Y
        LDY # 0
        CLC
        ADC # 2
        STA caml_OOID
        BCC +
        INC caml_OOID + 1
+       RTS
}

!ifdef caml_PRIM__caml_fresh_oo_id {
caml_fresh_oo_id
        LDA caml_OOID + 1
        STA ACCU + 1
        LDA caml_OOID
        STA ACCU
        CLC
        ADC # 2
        STA caml_OOID
        BCC +
        INC caml_OOID + 1
+       RTS
}

!ifdef caml_PRIM__caml_int_as_pointer {
        ;; ACCU = n
caml_int_as_pointer
        DEC ACCU
        RTS
}

!ifdef caml_PRIM__caml_obj_truncate {
        ;; truncate a block to newsize
        ;; ACCU = value
        ;; SP[0] = newsize

        ;; Obj.truncate is deprecated!

        ;; WARNING: Obj.truncate o s  when  Obj.size o = s + 1
        ;; will leave an atom on the heap, which could cause the garbage
        ;; collector to crash if it is reachable from some root!

caml_obj_truncate
        @NEWSZ = TMP
        ;; load tag and size
        DEY
        DEC ACCU + 1
        LDA (ACCU),Y
        TAX                                     ;X := size
        DEY
        LDA (ACCU),Y
        CMP # Double_array_tag
        BEQ @floatarray
        ;; calculate Int_val(newsize)
        LDY # 1
        LDA (SP),Y
        DEY
        LSR
        BNE @error                              ;error if newsize > 255 or < 0
        LDA (SP),Y
        ROR
        BEQ @error                              ;error if newsize = 0
        STA @NEWSZ
        CPX @NEWSZ
        BEQ @exit                               ;exit if newsize = size
        BCC @error                              ;error if newsize > size
        ;; 0 < NEWSZ < size, write NEWSZ into header
@trunc  DEY
        STA (ACCU),Y
        INC ACCU + 1
        ;; set (ACCU),Y to point to Field(ACCU, newsize)
        ASL
        BCC +
        INC ACCU + 1
+       TAY
        ;; header for the leftovers: tag = No_scan_tag, sz = size-1-newsize
        ;; WARNING: sz could be 0, the GC won't be happy if block is reachable!
        LDA # No_scan_tag
        STA (ACCU),Y                            ;tag = No_scan_tag
        INY
        DEX
        TXA
        SEC
        SBC @NEWSZ                              ;sz = size-1-NEWSZ
        STA (ACCU),Y
@exit   LDY # <Val_unit
        STY ACCU                                ;ACCU := ()
        DEY
        STY ACCU + 1
        RTS
        ;; calculate Int_val(newsize) * Double_wosize
@floatarray
        LDY # 1
        LDA (SP),Y
        BNE @error                              ;error if newsize > 127 or < 0
        DEY
        LDA (SP),Y
        AND # %11111110                         ;A = 2 * newsize
        BEQ @error                              ;error if newsize = 0
        STA @NEWSZ                              ;NEWSZ = 2 * newsize
        LSR
        ;CLC                                    ;C=0 because of previous AND
        ADC @NEWSZ                              ;A = Double_wosize * newsize
        BCS @error                              ;error if > 255
        STA @NEWSZ                              ;NEWSZ=Double_wosize * newsize
        CPX @NEWSZ
        BEQ @exit                               ;exit if NEWSZ = size
        BCS @trunc                              ;error if NEWSZ > size
@error  +caml_raise Invalid_argument, "Obj.truncate"
}

!ifdef caml_PRIM__caml_obj_add_offset {
        ;; ACCU = value
        ;; SP[0] = offset
caml_obj_add_offset
        LDA (SP),Y
        STA TMP
        INY
        LDA (SP),Y
        STA TMP + 1
        DEY
        LSR TMP + 1
        ROR TMP
        CLC
        LDA TMP
        ADC ACCU
        STA ACCU
        LDA TMP + 1
        ADC ACCU + 1
        STA ACCU + 1
        RTS
}

!ifdef caml_PRIM__caml_lazy_follow_forward {
        ;; ACCU = value
caml_lazy_follow_forward
        ;; is value a block?
        LDA ACCU
        BIT caml_is_block
        BNE @exit
        ;; tag(value) = Forward_tag?
        LDY # -2
        DEC ACCU + 1
        LDA (ACCU),Y
        INC ACCU + 1
        LDY # 0
        CMP # Forward_tag
        BNE @exit
        ;; is value in heap?
        SEC
        LDA # < caml_heap_start
        SBC ACCU
        STA TMP
        LDA # > caml_heap_start
        SBC ACCU + 1
        STA TMP + 1
        LDA TMP
        CMP # < caml_heap_sz
        LDA TMP + 1
        SBC # > caml_heap_sz
        BCS @exit
        ;; ACCU <- Field(value,0)
        LDA (ACCU),Y
        TAX
        INY
        LDA (ACCU),Y
        STA ACCU + 1
        STX ACCU
        DEY
@exit   RTS
}

!ifdef caml_PRIM__caml_lazy_make_forward {
        ;; ACCU = value
caml_lazy_make_forward
        LDA # Forward_tag
        LDX # 1
        JSR caml_alloc
        LDA ACCU
        STA (BLK),Y
        INY
        LDA ACCU + 1
        STA (BLK),Y
        DEY
        LDA BLK
        STA ACCU
        LDA BLK + 1
        STA ACCU + 1
        RTS
}

}      ;; !zone caml_OBJ


        
