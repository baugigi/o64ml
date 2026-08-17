;; Created by BreadCaml - The OCaml Compiler for the Commodore 64

!to "prova.prg", cbm
caml_stack_start = $9c00
caml_stack_end = $a000

!source "/home/piero/.opam/LTS/lib/bcamlc/c64defs.asm"
caml_PRIM__caml_fresh_oo_id = 1
caml_PRIM__caml_array_get_addr = 1
!source "/home/piero/.opam/LTS/lib/bcamlc/loader.asm"
!source "/home/piero/.opam/LTS/lib/bcamlc/codegen.asm"

caml_program

caml_0000 +i63:+i5d 0:+i35 0:+i39 15:+i35 5:+i39 14:+i54 caml_000b
caml_0007 +i00:+i36 12:+i5e 1:+i5b
caml_000b +i63:+i5d 0:+i36 13:+i40 248:+i0a:+i36 14:+i36 15:+i41 0:+i39 12
          +i2b 0,caml_0007:+i6a:+i0b:+i21:+i13 2:+i8f
caml_program_end

!source "/home/piero/.opam/LTS/lib/bcamlc/runtime.asm"
!source "/home/piero/.opam/LTS/lib/bcamlc/memory.asm"
!source "/home/piero/.opam/LTS/lib/bcamlc/stdlib.asm"
!align $01, $00
caml_externals_lo
	!byte <(caml_fresh_oo_id)
	!byte <(caml_array_get_addr)
caml_externals_hi
	!byte >(caml_fresh_oo_id)
	!byte >(caml_array_get_addr)
!macro p .ptr { !wo caml_glob_data + .ptr }
!align $01, $00
caml_glob_table
!h 01 00:+p $0002:!h 01 00 01 00
caml_glob_data
!h fc 05 50 72 6f 76 61 2e 4d 69 61 00
caml_glob_end
!if caml_stack_start < caml_glob_end {
	!serious "ERROR: Not enough memory for stack."
}
!source "/home/piero/.opam/LTS/lib/bcamlc/showmem.asm"
