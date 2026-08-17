;; Created by BreadCaml - The OCaml Compiler for the Commodore 64

!to "loop.prg", cbm
caml_stack_start = $9c00
caml_stack_end = $a000

!source "/home/piero/.opam/LTS/lib/bcamlc/c64defs.asm"
caml_PRIM__caml_nonstd_print_char = 1
caml_PRIM__caml_nonstd_string_of_int = 1
caml_PRIM__caml_nonstd_print_string = 1
caml_PRIM__caml_fresh_oo_id = 1
!source "/home/piero/.opam/LTS/lib/bcamlc/loader.asm"
!source "/home/piero/.opam/LTS/lib/bcamlc/codegen.asm"

caml_program

caml_0000 +i54 caml_0008
caml_0001 +i67 13:+i5d 0:+i28 1
caml_0004 +i00:+i5d 1:+i5d 2:+i28 1
caml_0008 +i63:+i5d 3:+i2b 0,caml_0004:+i39 13:+i2b 0,caml_0001:+i39 16:+i63
          +i3f 0:+i68:+i3f 0:+i6c -10:+i0b:+i49:+i54 caml_003a
caml_0016 +i5c:+i35 12:+i5d 2:+i00:+i43:+i36 13:+i21:+i35 14:+i5d 2:+i67 -10
          +i0c:+i49:+i54 caml_002f
caml_0023 +i5c:+i01:+i43:+i36 13:+i21:+i35 15:+i5d 2:+i01:+i43:+i7f 1:+i0c:+i49
caml_002f +i01:+i43:+i88 10,caml_0023:+i63:+i36 16:+i21:+i00:+i43:+i7f 1:+i0b
          +i49
caml_003a +i00:+i43:+i88 10,caml_0016:+i13 2:+i8f
caml_program_end

!source "/home/piero/.opam/LTS/lib/bcamlc/runtime.asm"
!source "/home/piero/.opam/LTS/lib/bcamlc/memory.asm"
!source "/home/piero/.opam/LTS/lib/bcamlc/stdlib.asm"
!align $01, $00
caml_externals_lo
	!byte <(caml_nonstd_print_char)
	!byte <(caml_nonstd_string_of_int)
	!byte <(caml_nonstd_print_string)
	!byte <(caml_fresh_oo_id)
caml_externals_hi
	!byte >(caml_nonstd_print_char)
	!byte >(caml_nonstd_string_of_int)
	!byte >(caml_nonstd_print_string)
	!byte >(caml_fresh_oo_id)
!macro p .ptr { !wo caml_glob_data + .ptr }
!align $01, $00
caml_glob_table
+p $0002:!h 01 00:+p $0008:+p $0010:!h 01 00
caml_glob_data
!h fc 02 49 3d 00 01 fc 03 3b 20 4a 3d 00 01 fc 02 2c 20 00 01
caml_glob_end
!if caml_stack_start < caml_glob_end {
	!serious "ERROR: Not enough memory for stack."
}
!source "/home/piero/.opam/LTS/lib/bcamlc/showmem.asm"
