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
;; ----------------------------------------------------------------------
;; ARRAYS (ocaml-4.14.4/runtime/array.c)
;; ----------------------------------------------------------------------
!zone caml_ARRAYS {

!ifndef caml_arrays_warn {
caml_arrays_warn
  !warn "TODO: caml_array_fill"
  !warn "TODO: caml_floatarray_blit"
  !warn "TODO: check for GC-invalidated pointers"
}
	
!ifdef caml_PRIM__caml_make_vect {
caml_make_vect
        ;; allocate and initialize an array
        ;; ACCU = length
        ;; SP[0] = init
@NFLO2  = TMP
@INIT   = TMP + 2
        ;; load init
        INY
        LDA (SP),Y
        STA @INIT + 1
        DEY
        LDA (SP),Y
        STA @INIT
        ;; is init a block?
        BIT caml_is_block                       ; test @INIT
        BNE @no_float_array
        ;; tag(init) = Double_tag?
        LDY # -2
        DEC @INIT + 1
        LDA (@INIT),Y
        INC @INIT + 1
        LDY # 0
        CMP # Double_tag
        BNE @no_float_array
;;      ;; is init in heap?
;;      SEC
;;      LDA @INIT
;;      SBC # < caml_heap_start
;;      STA TMP
;;      LDA @INIT + 1
;;      SBC # > caml_heap_start
;;      STA TMP + 1
;;      LDA TMP
;;      CMP # < caml_heap_sz
;;      LDA TMP + 1
;;      SBC # > caml_heap_sz
;;      BCS @no_float_array
        ;; allocate float array 
        JSR caml_floatarray_create
        ;; init floats
        LDA @NFLO2                      ; see caml_floatarray_create
        LSR
        TAX                             ; X = no. of floats
;       CLC
-       +caml_move_float @INIT, BLK
        LDA # < (2 * Double_wosize)
        ADC BLK
        STA BLK
        LDA # > (2 * Double_wosize)
        ADC BLK + 1
        STA BLK + 1
        DEX
        BNE -
        RTS
@no_float_array
        ;; check length
        LSR ACCU + 1
        BNE @error
        LDA ACCU
        ROR
        BNE +
        ;; length = 0, empty array
        LDA # < caml_atom0
        STA ACCU
        LDA # > caml_atom0
        STA ACCU + 1
        RTS
        ;; length > 0, allocate array
+       TAX                             ; size
        TYA                             ; tag = 0
        JSR caml_alloc
        LDA BLK
        STA ACCU
        LDA BLK + 1
        STA ACCU + 1
        ;; init fields
-       LDA @INIT
        STA (BLK),Y
        INY
        LDA @INIT + 1
        STA (BLK),Y
        INY
        BNE +
        INC BLK + 1
+       DEX
        BNE -
        LDY # 0
        RTS
@error  +caml_raise Invalid_argument, "Array.make"
}

!ifdef caml_PRIM__caml_floatarray_create {
        ;; allocate an array of floats
        ;; ACCU = length
caml_floatarray_create
@NFLO2  = TMP                   ; see caml_make_vect
        LDA ACCU + 1
        BNE @error
        LDA ACCU
        ;; exn if 3 * index > 255
        AND # $FE
        BNE +
        ;; length = 0, empty array
        LDA # < caml_atom0
        STA ACCU
        LDA # > caml_atom0
        STA ACCU + 1
        RTS
        ;; length > 0, size is length * 3
+       STA @NFLO2
        LSR
;       CLC                             ;implicit
        ADC @NFLO2
        BCS @error
        ;; allocate array of floats
        TAX                             ; size
        LDA # Double_array_tag          ; tag
        JSR caml_alloc
        LDA BLK
        STA ACCU
        LDA BLK + 1
        STA ACCU + 1
        RTS
@error  +caml_raise Invalid_argument, "Float.Array.create"
}

!ifdef caml_PRIM__caml_make_array {
        ;; if init is a block of floats, unbox all elements
        ;; ACCU = init
caml_make_array
@FIELD0 = TMP
@NFLOATS= TMP + 2
        ;; exit if size(init) = 0
        LDA # >caml_atom0
        CMP ACCU + 1
        BNE +
        LDA # <caml_atom0
        CMP ACCU
        BEQ @exit
        ;; exit if Field(init,0) is not a block
+       INY
        LDA (ACCU),Y
        STA @FIELD0
        INY
        LDA (ACCU),Y
        STA @FIELD0 + 1
        BIT caml_is_block                       ; test @FIELD0
        BNE @exit
;;      ;; exit if Field(init,0) is out of heap
;;      SEC
;;      LDA @FIELD0
;;      SBC # < caml_heap_start
;;      STA TMP
;;      LDA @FIELD0 + 1
;;      SBC # > caml_heap_start
;;      STA TMP + 1
;;      LDA TMP
;;      CMP # < caml_heap_sz
;;      LDA TMP + 1
;;      SBC # > caml_heap_sz
;;      BCS @exit
        ;; exit if tag(Field(init,0)) <> Double_tag
        LDY # -2
        DEC @FIELD0 + 1
        LDA (@FIELD0),Y
        CMP # Double_tag
        BEQ +
        LDY # 0
@exit   RTS
        ;; check length
+       INY
        DEC ACCU + 1
        LDA (ACCU),Y
;       inc ACCU + 1
        INY
        CMP # 255 DIV Double_wosize + 1
        BCC +
        +caml_raise Out_of_memory
        ;; size is lenght * 3
+       STA @NFLOATS
        ASL
;       clc
        ADC @NFLOATS
        ;; allocate array of floats
        TAX
        LDA # Double_array_tag
        JSR caml_alloc
        LDA BLK
        STA ACCU
        LDA BLK + 1
        STA ACCU + 1
        ;; init fields
        INC @FIELD0 + 1                 ; previously dec'ed
-       +caml_move_float @FIELD0, BLK
        DEX
        BEQ @exit
        INC @FIELD0
        INC @FIELD0
        BNE +
        INC @FIELD0 + 1
+       INC BLK
        INC BLK
        BNE -
        INC BLK + 1
        JMP -
}

!ifdef caml_PRIM__caml_array_get {
caml_array_get
        ;; return an array element
        ;; ACCU = array
        ;; SP[0] = index

        ;; load tag
        LDY # -2
        DEC ACCU + 1
        LDA (ACCU),Y
        INY
        ;; check if float
        CMP # Double_array_tag
        BNE caml_array_get_addr__loadsize
        JMP caml_floatarray_get__loadsize
}

!ifdef caml_PRIM__caml_array_get_addr {
        ;; return an array element (no-float version)
        ;; ACCU = array
        ;; SP[0] = index
caml_array_get_addr
        DEY
        DEC ACCU + 1
caml_array_get_addr__loadsize
        LDA (ACCU),Y
        STA TMP                                 ; TMP := size
        INC ACCU + 1                            ; restore ptr to Field(0)
        LDY # 1
        LDA (SP),Y                              ; load index, hi
        LSR
        BNE @error                              ; exn if index>255 or index<0
        BCC +
        INC ACCU + 1                            ; inc ACCU if index > 127
+       DEY
        LDA (SP),Y                              ; load index, lo
        TAY                                     ; now ACCU+Y points to elt, hi
        ROR
        CMP TMP
        BCS @error                              ; exn if index >= size
        LDA (ACCU),Y                            ; get array elt, hi
        TAX
        DEY
        LDA (ACCU),Y                            ; get array elt, lo
        STA ACCU                                ; ACCU <- array[index]
        STX ACCU + 1
        LDY # 0
        RTS
@error  +caml_raise Invalid_argument, "index out of bounds"
}

!ifdef caml_PRIM__caml_floatarray_get {
        ;; return an array element (floatarray version)
        ;; ACCU = array
        ;; SP[0] = index
caml_floatarray_get
        ;; load size
        DEY
        DEC ACCU + 1
caml_floatarray_get__loadsize
@SZ     = TMP
@IDX    = TMP + 1
        LDA (ACCU),Y
        STA @SZ
        INC ACCU + 1
        ;; load index, hi
        LDY # 1
        LDA (SP),Y
        BEQ +
        ;; exn if hi > 0
        JMP @error
        ;; load index, lo
+       DEY
        LDA (SP),Y
        ;; exn if 3 * index >= size
        AND # $FE
        BEQ +
        STA @IDX
        LSR
        ;CLC
        ADC @IDX
        BCS @error
        CMP @SZ
        BCS @error
        ;; ACCU <- &array[index]
+       ASL
        BCC +
        INC ACCU + 1
        CLC
+       ADC ACCU
        STA ACCU
        BCC +
        INC ACCU + 1
        ;; allocate float
+       LDA # Double_tag
        LDX # Double_wosize
        JSR caml_alloc
        ;; copy float
        +caml_move_float ACCU, BLK
        ;; return float
        LDA BLK
        STA ACCU
        LDA BLK + 1
        STA ACCU + 1
        RTS
@error  +caml_raise Invalid_argument, "index out of bounds"
}

!ifdef caml_PRIM__caml_array_unsafe_get {
caml_array_unsafe_get
        ;; return an array element (unsafe version)
        ;; ACCU = array
        ;; SP[0] = index
        LDY # -2
        DEC ACCU + 1
        LDA (ACCU),Y                            ; load tag
        INC ACCU + 1                            ; restore ptr
        LDY # 0
        CMP # Double_array_tag                  ; check if float
        BEQ caml_floatarray_unsafe_get         ; yes: special case
        LDA (SP),Y                              ; Val_int(index), lo
        STA TMP
        INY
        LDA (SP),Y                              ; Val_int(index), hi
        BEQ +
        INC ACCU + 1
+       LDY TMP
        ;; get array element
        LDA (ACCU),Y                            ; array[index], hi
        TAX
        DEY
        LDA (ACCU),Y                            ; array[index], lo
        STA ACCU
        STX ACCU + 1
        LDY # 0
        RTS
}

!ifdef caml_PRIM__caml_floatarray_unsafe_get {
        ;; return an array element (unsafe, floatarray version)
        ;; ACCU = array
        ;; SP[0] = index
caml_floatarray_unsafe_get
        ;; load index, lo (ignore hi byte)
        LDA (SP),Y                      ; 2*i+1
        ;; calc 3 * i
        AND # $FE
        STA TMP
        LSR
        CLC
        ADC TMP
        ;; ACCU <- &array[index]
        ASL
        BCC +
        INC ACCU + 1
        CLC
+       ADC ACCU
        STA ACCU
        BCC +
        INC ACCU + 1
        ;; allocate float
+       LDA # Double_tag
        LDX # Double_wosize
        JSR caml_alloc
        ;; copy float
        +caml_move_float ACCU, BLK
        ;; return float
        LDA BLK
        STA ACCU
        LDA BLK + 1
        STA ACCU + 1
        RTS
}

!ifdef caml_PRIM__caml_array_set {
caml_array_set
        ;; set an array element to given value
        ;; ACCU = array
        ;; SP[0] = index
        ;; SP[1] = newval

        ;; load tag
        LDY # -2
        DEC ACCU + 1
        LDA (ACCU),Y
        INY
        ;; check if float
        CMP # Double_array_tag
        BNE caml_array_set_addr__loadsize
        JMP caml_floatarray_set__loadsize
}

!ifdef caml_PRIM__caml_array_set_addr {
        ;; set an array element to given value (no-float version)
        ;; ACCU = array
        ;; SP[0] = Val_int(index)
        ;; SP[1] = newval
caml_array_set_addr
        ;; load size
        DEY
        DEC ACCU + 1
caml_array_set_addr__loadsize
@SZ     = TMP
@NEW    = TMP + 1
        LDA (ACCU),Y
        STA @SZ
        INC ACCU + 1
        ;; load newval
        LDY # 3
        LDA (SP),Y
        STA @NEW + 1
        DEY
        LDA (SP),Y
        STA @NEW
        ;; load index, hi
        DEY
        LDA (SP),Y
        ;; exn if index > 255 or index < 0
        LSR
        BNE @error
        ;; load index, lo
        DEY
        LDA (SP),Y
        ROR
        ;; exn if index >= size
        CMP @SZ
        BCS @error
        ;; array[index] <- newval
        ASL
        BCC +
        INC ACCU + 1
+       TAY
        LDA @NEW
        STA (ACCU),Y
        INY
        LDA @NEW + 1
        STA (ACCU),Y
        ;; ACCU <- ()
        LDY # <Val_unit                 ;.Y := 1
        STY ACCU
        DEY
        STY ACCU + 1
        RTS
@error  +caml_raise Invalid_argument, "index out of bounds"
}

!ifdef caml_PRIM__caml_floatarray_set {
        ;; set an array element to given value (floatarray version)
        ;; ACCU = array
        ;; SP[0] = index
        ;; SP[1] = newval
caml_floatarray_set
        ;; load size
        DEY
        DEC ACCU + 1
caml_floatarray_set__loadsize
@SZ     = TMP
@IDX    = TMP + 1
@NEW    = TMP + 2
        LDA (ACCU),Y
        STA @SZ
        INC ACCU + 1
        ;; load newval
        LDY # 3
        LDA (SP),Y
        STA @NEW + 1
        DEY
        LDA (SP),Y
        STA @NEW
        ;; load index, hi
        DEY
        LDA (SP),Y
        ;; exn if hi > 0
        BNE @error
        ;; load index, lo
        DEY
        LDA (SP),Y
        ;; exn if 3 * index >= size
        AND # $FE
        STA @IDX
        LSR
        CLC
        ADC @IDX
        BCS @error
        CMP @SZ
        BCS @error
        ;; ACCU <- &array[index]
+       ASL
        BCC +
        INC ACCU + 1
        CLC
+       ADC ACCU
        STA ACCU
        BCC +
        INC ACCU + 1
        ;; copy float
+       +caml_move_float @NEW, ACCU
        ;; ACCU <- ()
        STY ACCU + 1
        INY
        STY ACCU
        DEY
        RTS
@error  +caml_raise Invalid_argument, "index out of bounds"
}

!ifdef caml_PRIM__caml_array_unsafe_set {
caml_array_unsafe_set
        ;; set an array element to given value (unsafe version)
        ;; ACCU = array
        ;; SP[0] = index
        ;; SP[1] = newval

        ;; load tag
        LDY # -2
        DEC ACCU + 1
        LDA (ACCU),Y
        INC ACCU + 1
        LDY # 0
        ;; check if float
        CMP # Double_array_tag
        BEQ caml_floatarray_unsafe_set
        ;; FALLTHROUGH caml_array_unsafe_set_addr
}

!ifdef caml_PRIM__caml_array_unsafe_set_addr {
        ;; set an array element to given value (unsafe, no-float version)
        ;; ACCU = array
        ;; SP[0] = index
        ;; SP[1] = newval
caml_array_unsafe_set_addr
        ;; load index
        LDA (SP),Y                      ; Val_int(index), lo
        STA TMP
        INY
        LDA (SP),Y                      ; Val_int(index), hi
        BEQ +
        INC ACCU + 1
        ;; load newval
+       INY
        LDA (SP),Y
        TAX
        INY
        LDA (SP),Y
        ;; array[index] <- newval
        LDY TMP
        STA (ACCU),Y
        DEY
        TXA
        STA (ACCU),Y
        ;; ACCU <- ()
        LDY # <Val_unit                 ;.Y := 1
        STY ACCU
        DEY
        STY ACCU + 1
        RTS
}

!ifdef caml_PRIM__caml_floatarray_unsafe_set {
        ;; set an array element to given value (unsafe, floatarray version)
        ;; ACCU = array
        ;; SP[0] = index
        ;; SP[1] = newval
caml_floatarray_unsafe_set
        ;; load index, lo (ignore hi byte)
        LDA (SP),Y                      ; 2*i+1
        ;; calc 3 * i
        AND # $FE
        STA TMP
        LSR
        CLC
        ADC TMP
        ;; ACCU <- &array[index]
        ASL
        BCC +
        INC ACCU + 1
        CLC
+       ADC ACCU
        STA ACCU
        BCC +
        INC ACCU + 1
        ;; load newval
+       LDY # 2
        LDA (SP),Y
        STA TMP
        INY
        LDA (SP),Y
        STA TMP + 1
        ;; copy float
        +caml_move_float TMP, ACCU
        ;; ACCU <- ()
        LDA # <Val_unit
        STA ACCU
        STY ACCU + 1                    ; Y = 0
        RTS
}

!ifdef caml_PRIM__caml_array_blit {
caml_array_blit
        ;; copy a subarray to other one (source and dest may overlap)
        ;; ACCU = arr1
        ;; SP[0] = ofs1
        ;; SP[1] = arr2
        ;; SP[2] = ofs2
        ;; SP[3] = n
@NBY    = TMP + 2
        ;; load tag
        LDY # -2
        DEC ACCU + 1
        LDA (ACCU),Y
        INC ACCU + 1
        ;; check if float
        CMP # Double_array_tag
        BNE @no_float
        ;; array of floats, compute source start address
        LDY # 0
        STY @NBY + 1
        LDA (SP),Y                      ; ofs1, ignore hi byte
        AND # $FE
        STA TMP
        LSR
        CLC
        ADC TMP
        ;; ACCU <- &arr1[ofs1]
        ASL                             ; A = 6 * ofs1
        BCC +
        INC ACCU + 1
        CLC
+       ADC ACCU
        STA ACCU
        BCC +
        INC ACCU + 1
        ;; compute destination start address
+       LDY # 4
        LDA (SP),Y                      ; ofs2, ignore hi byte
        ;; calc 3 * index
        AND # $FE
        STA TMP
        LSR
        CLC
        ADC TMP
        ;; TMP <- &arr2[ofs2]
        TAX                             ; X = 3 * ofs2
        DEY
        LDA (SP),Y
        STA TMP + 1
        TXA
        ASL                             ; A = 6 * ofs2
        BCC +
        INC TMP + 1
        CLC
+       DEY
        ADC (SP),Y
        STA TMP
        BCC +
        INC TMP + 1
        ;; @NBY = 6 * n (no. of bytes to be moved)
+       LDY # 6
        LDA (SP),Y                      ; ignore hi byte
        AND # $FE
        STA @NBY
        LSR
        CLC
        ADC @NBY
        STA @NBY
        BCC +
        INC @NBY + 1
+       JMP @copy
@no_float
        ;; ordinary array, compute source start address
        LDY # 0
        CLC
        LDA (SP),Y
        ADC ACCU
        STA ACCU
        INY
        LDA (SP),Y
        ADC ACCU + 1
        STA ACCU + 1
        LDA ACCU
        BNE +
        DEC ACCU + 1
+       DEC ACCU
        ;; compute destination start address
        INY
        LDA (SP),Y
        STA TMP
        INY
        LDA (SP),Y
        STA TMP + 1
        INY
        CLC
        LDA TMP
        ADC (SP),Y
        STA TMP
        INY
        LDA TMP + 1
        ADC (SP),Y
        STA TMP + 1
        LDA TMP
        BNE +
        DEC TMP + 1
+       DEC TMP
        ;; compute no. of bytes to be copied
        INY
        LDA @NBY
        ADC (SP),Y
        STA @NBY
        INY
        LDA @NBY + 1
        ADC (SP),Y
        STA @NBY + 1
        LDA @NBY
        BNE +
        DEC @NBY + 1
+       DEC @NBY
        ;; copy bytes from source to destination
@copy   LDA ACCU
        CMP TMP
        LDA ACCU + 1
        SBC TMP + 1
        BCS @cpydn
        ;; ACCU < TMP, copy memory up (arr1[0] last)
        LSR @NBY + 1
        LDY @NBY
        JSR caml_blkcpy
        ;; ACCU <- ()
@done   STY ACCU + 1                    ; Y = 0
        LDA # <Val_unit
        STA ACCU
        RTS
        ;; ACCU >= TMP, copy memory down (arr1[0] first)
@cpydn  LDX @NBY + 1                    ; 0 or 1
        BEQ +
        LDY # 0
-       LDA (ACCU),Y                    ; >255 bytes: copy a whole page
        STA (TMP),Y
        INY
        BNE -
        INC ACCU + 1
        INC TMP + 1
+       LDX @NBY
        BEQ +
-       LDA (ACCU),Y                    ; copy the remaining bytes
        STA (TMP),Y
        INY
        DEX
        BNE -
+       LDY # 0
        JMP @done
}

!ifdef caml_PRIM__caml_array_sub {
caml_array_sub
        ;; allocate and return a subarray
        ;; ACCU = a
        ;; SP[0] = ofs
        ;; SP[1] = n
@NBY    = TMP
        ;; load tag
        LDY # -2
        DEC ACCU + 1
        LDA (ACCU),Y
        INC ACCU + 1
        ;; check if float
        CMP # Double_array_tag
        BNE @no_floats
        ;; array of floats, compute source start address
        LDY # 0                         ; ignore hi byte
        STY @NBY + 1
        LDA (SP),Y
        AND # $FE
        STA TMP
        LSR
        CLC
        ADC TMP
        ;; ACCU <- &arr1[ofs1]
        ASL                             ; A = 6 * ofs1
        BCC +
        INC ACCU + 1
        CLC
+       ADC ACCU
        STA ACCU
        BCC +
        INC ACCU + 1
        ;; @NBY = 6 * n (no. of bytes to be moved)
+       LDY # 2
        LDA (SP),Y                      ; ignore hi byte
        AND # $FE
        STA @NBY
        LSR
        CLC
        ADC @NBY
        STA @NBY
        BCC +
        INC @NBY + 1
        ;; allocate subarray
+       LDA @NBY + 1
        LSR
        LDA @NBY
        ROR
        TAX
        LDA # Double_array_tag
        JSR caml_alloc
        JMP @copy
@no_floats
        ;; ordinary array, compute source start address
        LDY # 0
        CLC
        LDA ACCU
        ADC (SP),Y
        STA ACCU
        INY
        LDA ACCU + 1
        ADC (SP),Y
        STA ACCU + 1
        LDA ACCU
        BNE +
        DEC ACCU + 1
+       DEC ACCU
        ;; compute no. of bytes to be copied
        INY
        LDA (SP),Y
        STA @NBY
        INY
        LDA (SP),Y
        STA @NBY + 1
        LDA @NBY
        BNE +
        DEC @NBY + 1
+       DEC @NBY
        ;; allocate subarray
        LDA @NBY + 1
        LSR
        LDA @NBY
        ROR
        TAX
        LDA # 0
        JSR caml_alloc
        ;; copy bytes from source to destination
@copy   LSR @NBY + 1
        LDY @NBY
        JSR caml_blkcpy
        ;; ACCU <- subarray
@done   LDA BLK
        STA ACCU
        LDA BLK + 1
        STA ACCU + 1
        RTS
}

!ifdef caml_PRIM__caml_array_append {
caml_array_append
        ;; append two arrays
        ;; ACCU = arr1
        ;; SP[0] = arr2
@AUX    = TMP
@SIZE1  = TMP + 2
@SIZE2  = TMP + 4
        ;; load sizes
        LDA (SP),Y
        STA @AUX
        INY
        LDA (SP),Y
        STA @AUX + 1
        LDY # -1
        DEC ACCU + 1
        DEC @AUX + 1
        LDA (ACCU),Y
        STA @SIZE1
        LDA (@AUX),Y
        STA @SIZE2
        CLC
        ADC @SIZE1
        BCC +
        ;; exception if total size > 255
        INY                             ; Y = 0
        JMP @error
        ;; load tag and allocate
+       DEY
        TAX                             ; size
        LDA (ACCU),Y                    ; tag
        JSR caml_alloc
        ;; copy arr1 to dest
        INC ACCU + 1
        LDA @SIZE1
        ASL
        TAY
        JSR caml_blkcpy
        ;; ACCU <- arr2
        LDA @AUX
        STA ACCU
        LDA @AUX + 1
        STA ACCU + 1
        ;; save ptr to result
        LDA BLK
        STA @AUX
        LDA BLK + 1
        STA @AUX + 1
        ;; TMP <- &TMP[SIZE1]
+       LDA @SIZE1
        ASL
        BCC +
        INC BLK + 1
        CLC
+       ADC BLK
        STA BLK
        BCC +
        INC BLK + 1
        ;; copy arr2 to dest
+       LDA @SIZE2
        ASL
        TAY
        JSR caml_blkcpy
        ;; ACCU <- AUX
        LDA @AUX
        STA ACCU
        LDA @AUX + 1
        STA ACCU + 1
        RTS
@error  +caml_raise Invalid_argument, "Array.append"
}

!ifdef caml_PRIM__caml_array_concat {
caml_array_concat
        ;; concatenate all arrays in a list
        ;; ACCU = list
@TAG    = TMP
@SIZE   = TMP + 1
@HEAD   = TMP + 2
@TAIL   = TMP + 4
@RESULT = TMP + 2
        DEY
        STY @TAG                        ; @TAG = -1
        INY
        STY @SIZE
        ;; return caml_atom0 if list = []
        LDA ACCU
        BIT caml_is_block
        BNE @atom0
        ;; scan list and sum all arrays sizes
        LDA (ACCU),Y
        STA @HEAD
        INY
        LDA (ACCU),Y
        STA @HEAD + 1
        INY
        LDA (ACCU),Y
        STA @TAIL
        INY
        LDA (ACCU),Y
        STA @TAIL + 1
        ;; get current array size and add it to @SIZE
-       LDY # -1
        DEC @HEAD + 1
        LDA (@HEAD),Y
        BEQ +
        CLC
        ADC @SIZE
        BCS @error                      ; raise exn if > 255
        STA @SIZE
        ;; only once: set @TAG from first non-empty array
        CPY @TAG                        ; test if @TAG = -1
        BNE +
        DEY
        LDA (@HEAD),Y
        STA @TAG
        INY
        ;; set @HEAD to next list element, @TAIL to rest
+       INY
        LDA @TAIL
        BIT caml_is_block                       ; end of list?
        BEQ @alloc                      ; yes:  exit loop
        LDA (@TAIL),Y                   ; no:   continue
        STA @HEAD
        INY
        LDA (@TAIL),Y
        STA @HEAD + 1
        INY
        LDA (@TAIL),Y
        TAX
        INY
        LDA (@TAIL),Y
        STX @TAIL
        STA @TAIL + 1
        JMP -
        ;; allocate destination array
@alloc  LDX @SIZE
        BEQ @atom0
        LDA @TAG
        JSR caml_alloc
        LDA BLK
        STA @RESULT
        LDA BLK + 1
        STA @RESULT + 1                 ; save dest address
        ;; scan list again and append all arrays
        LDY # 3
        LDA (ACCU),Y
        STA @TAIL + 1
        DEY
        LDA (ACCU),Y
        STA @TAIL
        DEY
        LDA (ACCU),Y
        TAX
        DEY
        LDA (ACCU),Y
        STX ACCU + 1
        STA ACCU
        ;; get current array size
-       LDY # -1
        DEC ACCU + 1
        LDA (ACCU),Y
        BEQ ++                          ; skip if zero
        INC ACCU + 1
        TAX
        ASL
        TAY
        ;; copy array elements to destination
        JSR caml_blkcpy
        TXA
        ;; set BLK pointer to first element to be copied next
        ASL
        BCC +
        CLC
        INC BLK + 1
+       ADC BLK
        STA BLK
        BCC ++
        INC BLK + 1
        ;; set ACCU to next list element, @TAIL to rest
++      LDY # 0
        LDA @TAIL
        BIT caml_is_block               ; end of list?
        BEQ @eol                        ; yes:  exit
        LDA (@TAIL),Y                   ; no:   continue
        STA ACCU
        INY
        LDA (@TAIL),Y
        STA ACCU + 1
        INY
        LDA (@TAIL),Y
        TAX
        INY
        LDA (@TAIL),Y
        STX @TAIL
        STA @TAIL + 1
        JMP -                           ; loop
        ;; set ACCU = destination array and return
@eol    LDA @RESULT
        STA ACCU
        LDA @RESULT + 1
        STA ACCU + 1
        RTS
@atom0  LDA # < caml_atom0
        STA ACCU
        LDA # > caml_atom0
        STA ACCU + 1
        RTS
@error  +caml_raise Invalid_argument, "Array.concat"
}

}      ;; !zone caml_ARRAYS

