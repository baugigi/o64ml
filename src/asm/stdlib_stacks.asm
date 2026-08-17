;;; -----------------------------------------------------------
;;; STACK (ocaml-4.04.1/byterun/stacks.c)
;;; -----------------------------------------------------------

!zone caml_STACK {

!ifndef caml_stack_warn {
caml_stack_warn
  !warn "TODO: caml_ensure_stack_capacity"
}

!ifdef caml_PRIM__caml_ensure_stack_capacity {
;; TODO: raise  Stack_overflow if stack space is not enough."
        ;; ACCU = required space (ignored)
caml_ensure_stack_capacity
        ;; do nothing and return Val_unit
        LDA # < Val_unit
        STA ACCU
        ;LDY # 0
        STY ACCU + 1
        RTS
}

}       ;; !zone caml_STACK

