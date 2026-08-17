;; Created by BreadCaml - The OCaml Compiler for the Commodore 64

!to "fibonacci.prg", cbm
caml_stack_start = $9c00
caml_stack_end = $a000

!source "/home/piero/.opam/LTS/lib/bcamlc/c64defs.asm"
caml_PRIM__caml_nonstd_print_char = 1
caml_PRIM__caml_nonstd_string_of_int = 1
caml_PRIM__caml_nonstd_print_string = 1
caml_PRIM__caml_ml_string_length = 1
caml_PRIM__caml_create_bytes = 1
caml_PRIM__caml_blit_string = 1
caml_PRIM__caml_string_of_bytes = 1
caml_PRIM__caml_fresh_oo_id = 1
!source "/home/piero/.opam/LTS/lib/bcamlc/loader.asm"
!source "/home/piero/.opam/LTS/lib/bcamlc/codegen.asm"

caml_program

caml_0000 +i54 caml_0021
caml_0001 +i67 13:+i5d 0:+i28 1
caml_0004 +i00:+i5d 1:+i5d 2:+i28 1:+i29
caml_0009 +i2a 1:+i00:+i5d 3:+i0c:+i5d 3:+i0a:+i0c:+i6e:+i5d 4:+i0c:+i68:+i0c
          +i68:+i11:+i61 5:+i01:+i0d:+i0c:+i68:+i12 8:+i61 5:+i00:+i5d 6:+i28 5
caml_0021 +i63:+i5d 7:+i2b 0,caml_0009:+i39 13:+i2b 0,caml_0004:+i39 15
          +i2b 0,caml_0001:+i39 16:+i54 caml_004c
caml_002a +i00:+i85 1,caml_002e:+i00:+i28 1
caml_002e +i00:+i7f -2:+i32:+i21:+i0b:+i7f -1:+i32:+i21:+i6e:+i28 1:+i29
caml_0039 +i2a 2:+i00:+i85 0,caml_003e:+i02:+i28 3
caml_003e +i01:+i0c:+i0e:+i6e:+i0c:+i7f -1:+i32:+i27 6
caml_0046 +i2c 1,0,caml_0039,[]:+i63:+i69:+i0d:+i0d:+i27 5
caml_004c +i2c 1,0,caml_002a,[]:+i2b 0,caml_0046:+i6c 20:+i36 12:+i0b:+i5d 1
          +i36 13:+i22:+i36 14:+i36 13:+i22:+i5d 2:+i00:+i0c:+i21:+i36 15:+i21
          +i63:+i36 16:+i21:+i35 17:+i0b:+i5d 1:+i36 13:+i22:+i36 18:+i36 13
          +i22:+i5d 2:+i00:+i0d:+i21:+i36 15:+i21:+i63:+i36 16:+i21:+i13 3:+i8f
caml_program_end

!source "/home/piero/.opam/LTS/lib/bcamlc/runtime.asm"
!source "/home/piero/.opam/LTS/lib/bcamlc/memory.asm"
!source "/home/piero/.opam/LTS/lib/bcamlc/stdlib.asm"
!align $01, $00
caml_externals_lo
	!byte <(caml_nonstd_print_char)
	!byte <(caml_nonstd_string_of_int)
	!byte <(caml_nonstd_print_string)
	!byte <(caml_ml_string_length)
	!byte <(caml_create_bytes)
	!byte <(caml_blit_string)
	!byte <(caml_string_of_bytes)
	!byte <(caml_fresh_oo_id)
caml_externals_hi
	!byte >(caml_nonstd_print_char)
	!byte >(caml_nonstd_string_of_int)
	!byte >(caml_nonstd_print_string)
	!byte >(caml_ml_string_length)
	!byte >(caml_create_bytes)
	!byte >(caml_blit_string)
	!byte >(caml_string_of_bytes)
	!byte >(caml_fresh_oo_id)
!macro p .ptr { !wo caml_glob_data + .ptr }
!align $01, $00
caml_glob_table
+p $0002:!h 01 00:+p $0006:!h 01 00 01 00:+p $0014:+p $0018
caml_glob_data
!h fc 01 3d 00 fc 06 46 49 42 4f a4 54 41 49 4c 20 00 01 fc 01 3d 00 fc 06
!h 46 49 42 4f a4 52 45 43 20 20 00 01
caml_glob_end
!if caml_stack_start < caml_glob_end {
	!serious "ERROR: Not enough memory for stack."
}
!source "/home/piero/.opam/LTS/lib/bcamlc/showmem.asm"
