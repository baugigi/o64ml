;; Created by BreadCaml - The OCaml Compiler for the Commodore 64

!to "hello.prg", cbm
caml_stack_start = $9c00
caml_stack_end = $a000

!source "/home/piero/.opam/LTS/lib/bcamlc/c64defs.asm"
caml_PRIM__caml_nonstd_print_string = 1
caml_PRIM__caml_nonstd_print_char = 1
caml_PRIM__caml_fresh_oo_id = 1
!source "/home/piero/.opam/LTS/lib/bcamlc/loader.asm"
!source "/home/piero/.opam/LTS/lib/bcamlc/codegen.asm"

caml_program

caml_0000 +i54 caml_0009
caml_0001 +i00:+i5d 0:+i63:+i36 12:+i25 2
caml_0006 +i67 13:+i5d 1:+i28 1
caml_0009 +i63:+i5d 2:+i2b 0,caml_0006:+i39 12:+i2b 0,caml_0001:+i39 14:+i35 13
          +i36 14:+i21:+i8f
caml_program_end

!source "/home/piero/.opam/LTS/lib/bcamlc/runtime.asm"
!source "/home/piero/.opam/LTS/lib/bcamlc/memory.asm"
!source "/home/piero/.opam/LTS/lib/bcamlc/stdlib.asm"
!align $01, $00
caml_externals_lo
	!byte <(caml_nonstd_print_string)
	!byte <(caml_nonstd_print_char)
	!byte <(caml_fresh_oo_id)
caml_externals_hi
	!byte >(caml_nonstd_print_string)
	!byte >(caml_nonstd_print_char)
	!byte >(caml_fresh_oo_id)
!macro p .ptr { !wo caml_glob_data + .ptr }
!align $01, $00
caml_glob_table
!h 01 00:+p $0002:!h 01 00
caml_glob_data
!h fc 04 48 45 4c 4c 4f 21 00 01
caml_glob_end
!if caml_stack_start < caml_glob_end {
	!serious "ERROR: Not enough memory for stack."
}
!source "/home/piero/.opam/LTS/lib/bcamlc/showmem.asm"
