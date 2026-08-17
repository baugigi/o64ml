;; Created by BreadCaml - The OCaml Compiler for the Commodore 64

!to "test.prg", cbm
caml_stack_start = $9c00
caml_stack_end = $a000

!source "/home/piero/.opam/LTS/lib/breadcaml/c64defs.asm"
caml_PRIM__caml_nonstd_print_string = 1
caml_PRIM__caml_nonstd_print_char = 1
caml_PRIM__caml_nonstd_string_of_float = 1
caml_PRIM__caml_ml_string_length = 1
caml_PRIM__caml_create_bytes = 1
caml_PRIM__caml_blit_string = 1
caml_PRIM__caml_string_of_bytes = 1
caml_PRIM__caml_fresh_oo_id = 1
caml_PRIM__caml_nonstd_mem_peek = 1
caml_PRIM__caml_array_unsafe_get = 1
caml_PRIM__caml_make_vect = 1
caml_PRIM__caml_array_unsafe_set = 1
caml_PRIM__caml_sqrt_float = 1
caml_PRIM__caml_float_of_int = 1
!source "/home/piero/.opam/LTS/lib/breadcaml/loader.asm"
!source "/home/piero/.opam/LTS/lib/breadcaml/codegen.asm"

caml_program

caml_0000 +i54 caml_002a
caml_0001 +i00:+i5d 0:+i63:+i36 12:+i25 2
caml_0006 +i67 13:+i5d 1:+i28 1
caml_0009 +i00:+i5d 2:+i5d 0:+i28 1:+i29
caml_000e +i2a 1:+i00:+i5d 3:+i0c:+i5d 3:+i0a:+i0c:+i6e:+i5d 4:+i0c:+i68:+i0c
          +i68:+i11:+i61 5:+i01:+i0d:+i0c:+i68:+i12 8:+i61 5:+i00:+i5d 6:+i28 5
caml_0026 +i00:+i36 3:+i40 0:+i5b
caml_002a +i2b 0,caml_0026:+i39 14:+i63:+i5d 7:+i35 3:+i39 24:+i2b 0,caml_000e
          +i39 27:+i2b 0,caml_0009:+i39 29:+i2b 0,caml_0006:+i39 12
          +i2b 0,caml_0001:+i39 32:+i67 255:+i6c 128:+i5e 8:+i67 255:+i39 23
          +i67 85:+i39 25:+i63:+i5d 7:+i63:+i5d 7:+i54 caml_00d5:+i29
caml_0045 +i2a 1:+i01:+i4f:+i0a:+i84 0,caml_004c:+i3a:+i28 3
caml_004c +i63:+i0d:+i5e 9:+i0c:+i21:+i0b:+i5e 10:+i69:+i0c:+i7f -1:+i09:+i0c
          +i7d:+i55 caml_006a
caml_005a +i5c:+i01:+i10:+i5e 9:+i0f:+i21:+i0c:+i0e:+i5f 11:+i01:+i09:+i7f 1
          +i14 2:+i01:+i7a:+i55 caml_005a
caml_006a +i63:+i13 2:+i00:+i28 4:+i29
caml_006f +i2a 2:+i02:+i4f:+i0c:+i4f:+i7a:+i56 caml_0079:+i35 13:+i36 14:+i25 4
caml_0079 +i63:+i0c:+i4f:+i7f -1:+i09:+i0c:+i7d:+i55 caml_0091
caml_0081 +i5c:+i01:+i0f:+i5e 9:+i0c:+i0f:+i5e 9:+i0e:+i22:+i01:+i09:+i7f 1
          +i14 2:+i01:+i7a:+i55 caml_0081
caml_0091 +i63:+i28 5:+i29
caml_0094 +i2a 1:+i63:+i0c:+i4f:+i7f -1:+i09:+i0c:+i7d:+i55 caml_00aa
caml_009d +i5c:+i01:+i0e:+i5e 9:+i0d:+i21:+i01:+i09:+i7f 1:+i14 2:+i01:+i7a
          +i55 caml_009d
caml_00aa +i63:+i28 4:+i29
caml_00ad +i2a 1:+i00:+i84 0,caml_00b2:+i3a:+i28 2
caml_00b2 +i00:+i86 0,caml_00b7:+i35 15:+i36 14:+i25 3
caml_00b7 +i63:+i0c:+i21:+i0b:+i5e 10:+i69:+i0c:+i7f -1:+i09:+i0c:+i7d
          +i55 caml_00d1
caml_00c3 +i5c:+i01:+i0f:+i21:+i0c:+i0e:+i5f 11:+i01:+i09:+i7f 1:+i14 2:+i01
          +i7a:+i55 caml_00c3
caml_00d1 +i63:+i13 2:+i00:+i28 3
caml_00d5 +i2b 0,caml_00ad:+i39 19:+i2b 0,caml_0094:+i39 18:+i2b 0,caml_006f
          +i39 17:+i2b 0,caml_0045:+i39 16:+i63:+i5d 7:+i54 caml_0149
caml_00e0 +i00:+i36 16:+i21:+i36 16:+i25 2
caml_00e5 +i00:+i36 17:+i21:+i36 17:+i25 2
caml_00ea +i00:+i36 18:+i21:+i36 18:+i25 2
caml_00ef +i00:+i1b:+i1c:+i70:+i6e:+i1a:+i25 2
caml_00f6 +i00:+i1b:+i1a:+i2b 3,caml_00ef:+i1c:+i0c:+i7b:+i56 caml_0100:+i16
          +i54 caml_0101
caml_0100 +i18
caml_0101 +i36 19:+i26 3
caml_0103 +i00:+i1b:+i1a:+i22:+i0a:+i44:+i0b:+i43:+i0b:+i84 0,caml_010f:+i00
          +i54 caml_0111
caml_010f +i00:+i7f 1
caml_0111 +i0c:+i0c:+i10:+i1c:+i2b 4,caml_00f6:+i0b:+i36 19:+i26 7:+i29
caml_011a +i2a 1:+i00:+i86 0,caml_0120:+i35 20:+i36 21:+i25 3
caml_0120 +i00:+i84 0,caml_0124:+i3a:+i28 2
caml_0124 +i01:+i0b:+i36 22:+i2b 3,caml_0103:+i09:+i59 caml_012f:+i35 23:+i0f
          +i21:+i5a:+i28 3
caml_012f +i36 24:+i0b:+i43:+i79:+i56 caml_0137:+i35 25:+i0c:+i25 5
caml_0137 +i00:+i92:+i29
caml_013a +i2a 1:+i01:+i0b:+i72:+i0c:+i0c:+i71:+i40 0:+i28 2
caml_0143 +i00:+i36 26:+i36 27:+i22:+i36 14:+i25 2
caml_0149 +i35 28:+i39 26:+i2b 0,caml_0143:+i39 21:+i2b 0,caml_013a:+i39 22
          +i2b 0,caml_011a:+i39 30:+i2b 0,caml_00ea:+i39 33:+i2b 0,caml_00e5
          +i39 37:+i2b 0,caml_00e0:+i39 35:+i63:+i5d 7:+i54 caml_016b:+i29
caml_015b +i2a 1:+i00:+i36 29:+i21:+i01:+i36 29:+i21:+i63:+i36 12:+i25 3
caml_0165 +i00:+i5d 12:+i28 1
caml_0168 +i00:+i5d 13:+i28 1
caml_016b +i2b 0,caml_0168:+i6c 500:+i36 30:+i22:+i36 31:+i36 32:+i21:+i00
          +i36 29:+i36 33:+i22:+i35 34:+i36 32:+i21:+i00:+i09:+i2b 0,caml_0165
          +i36 35:+i22:+i36 36:+i36 32:+i21:+i00:+i0c:+i09:+i2b 0,caml_015b
          +i36 37:+i23:+i13 1:+i13 1:+i8f
caml_program_end

!source "largeArray.asm"
!source "/home/piero/.opam/LTS/lib/breadcaml/runtime.asm"
!source "/home/piero/.opam/LTS/lib/breadcaml/memory.asm"
!source "/home/piero/.opam/LTS/lib/breadcaml/stdlib.asm"
!align $01, $00
caml_externals_lo
	!byte <(caml_nonstd_print_string)
	!byte <(caml_nonstd_print_char)
	!byte <(caml_nonstd_string_of_float)
	!byte <(caml_ml_string_length)
	!byte <(caml_create_bytes)
	!byte <(caml_blit_string)
	!byte <(caml_string_of_bytes)
	!byte <(caml_fresh_oo_id)
	!byte <(caml_nonstd_mem_peek)
	!byte <(caml_array_unsafe_get)
	!byte <(caml_make_vect)
	!byte <(caml_array_unsafe_set)
	!byte <(caml_sqrt_float)
	!byte <(caml_float_of_int)
caml_externals_hi
	!byte >(caml_nonstd_print_string)
	!byte >(caml_nonstd_print_char)
	!byte >(caml_nonstd_string_of_float)
	!byte >(caml_ml_string_length)
	!byte >(caml_create_bytes)
	!byte >(caml_blit_string)
	!byte >(caml_string_of_bytes)
	!byte >(caml_fresh_oo_id)
	!byte >(caml_nonstd_mem_peek)
	!byte >(caml_array_unsafe_get)
	!byte >(caml_make_vect)
	!byte >(caml_array_unsafe_set)
	!byte >(caml_sqrt_float)
	!byte >(caml_float_of_int)
!macro p .ptr { !wo caml_glob_data + .ptr }
!align $01, $00
caml_glob_table
!h 01 00:+p $0002:!h 01 00:+p $0032:!h 01 00 01 00 01 00 01 00:+p $0040
!h 01 00 01 00 01 00 01 00 01 00 01 00 01 00:+p $0048:!h 01 00 01 00
+p $0056:!h 01 00 01 00:+p $005e:!h 01 00:+p $0064:!h 01 00
caml_glob_data
!h fc 17 41 72 72 61 79 2e 69 74 65 72 32 3a 20 61 72 72 61 79 73 20 6d 75
!h 73 74 20 68 61 76 65 20 74 68 65 20 73 61 6d 65 20 6c 65 6e 67 74 68 00
!h fc 06 41 72 72 61 79 2e 69 6e 69 74 00 01 fc 03 69 6e 69 74 00 01 fc 06
!h 4c 61 72 67 65 41 72 72 61 79 2e 00 fc 03 69 74 65 72 00 01 fc 02 6d 61
!h 70 00 fc 03 69 74 65 72 32 00
caml_glob_end
!if caml_stack_start < caml_glob_end {
	!serious "ERROR: Not enough memory for stack."
}
!source "/home/piero/.opam/LTS/lib/breadcaml/showmem.asm"
