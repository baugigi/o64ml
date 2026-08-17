;; Created by BreadCaml - The OCaml Compiler for the Commodore 64

!to "exn.prg", cbm
caml_stack_start = $9c00
caml_stack_end = $a000

!source "/home/piero/.opam/LTS/lib/bcamlc/c64defs.asm"
caml_PRIM__caml_fresh_oo_id = 1
!source "/home/piero/.opam/LTS/lib/bcamlc/loader.asm"
!source "/home/piero/.opam/LTS/lib/bcamlc/codegen.asm"

caml_program

caml_0000 +i63:+i5d 0:+i36 12:+i40 248:+i36 13:+i0b:+i40 0:+i5b:+i13 0
caml_program_end

!source "/home/piero/.opam/LTS/lib/bcamlc/runtime.asm"
!source "/home/piero/.opam/LTS/lib/bcamlc/memory.asm"
!source "/home/piero/.opam/LTS/lib/bcamlc/stdlib.asm"
!align $01, $00
caml_externals_lo
	!byte <(caml_fresh_oo_id)
caml_externals_hi
	!byte >(caml_fresh_oo_id)
!macro p .ptr { !wo caml_glob_data + .ptr }
!align $01, $00
caml_glob_table
+p $0002:+p $0016
caml_glob_data
!h fc 06 45 78 6e 2e 4d 69 61 5f 45 63 63 00 fc 02 c3 c3 c3 00 00 02 e3 12
+p $0010
caml_glob_end
!if caml_stack_start < caml_glob_end {
	!serious "ERROR: Not enough memory for stack."
}
!source "/home/piero/.opam/LTS/lib/bcamlc/showmem.asm"
