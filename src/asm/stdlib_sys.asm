;;; -----------------
;;;       SYS
;;; -----------------

!ifdef caml_PRIM__caml_nonstd_mem_peek {
caml_nonstd_mem_peek
        ;; Sys.mem_peek lo hi returns the content of memory location at address
        ;; 256*hi+lo as an integer; lo, hi are taken modulo 256.
        LSR ACCU + 1
        ROR ACCU
        INY
        LDA (SP),Y
        LSR
        DEY
        LDA (SP),Y
        ROR
        STA ACCU + 1
        LDA (ACCU),Y
        SEC
        ROL
        STA ACCU
        STY ACCU + 1
        ROL ACCU + 1
        RTS
}
