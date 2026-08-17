;; Created by BreadCaml - The OCaml Compiler for the Commodore 64

!to "divmod.prg", cbm
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
caml_0008 +i63:+i5d 3:+i64:+i6c -1:+i77:+i0a:+i7f 1:+i39 14:+i2b 0,caml_0004
          +i39 15:+i2b 0,caml_0001:+i39 21:+i54 caml_001d
caml_0015 +i00:+i56 caml_001a:+i35 12:+i5d 2:+i28 1
caml_001a +i35 13:+i5d 2:+i28 1
caml_001d +i2b 0,caml_0015:+i68:+i3f 0:+i68:+i3f 0:+i6c 7:+i6c 11:+i6c 13:+i70
          +i70:+i6b:+i6c 17:+i6c 47:+i70:+i70:+i36 14:+i0d:+i49:+i54 caml_007e
caml_0030 +i5c:+i35 14:+i0e:+i49:+i54 caml_0070
caml_0035 +i5c:+i02:+i43:+i36 15:+i21:+i35 16:+i5d 2:+i03:+i43:+i36 15:+i21
          +i59 caml_0065:+i07:+i43:+i11:+i43:+i72:+i12 8:+i43:+i12 8:+i43:+i71
          +i36 17:+i5d 2:+i00:+i36 15:+i21:+i35 18:+i5d 2:+i01:+i36 15:+i21
          +i35 19:+i5d 2:+i08 8:+i43:+i0c:+i12 11:+i43:+i0d:+i70:+i6e:+i79
          +i12 11:+i21:+i13 2:+i5a:+i54 caml_0067
caml_0065 +i35 20:+i5d 2
caml_0067 +i63:+i36 21:+i21:+i01:+i0e:+i43:+i6e:+i0e:+i49
caml_0070 +i01:+i0e:+i43:+i6e:+i0e:+i43:+i7b:+i55 caml_0035:+i00:+i0d:+i43:+i6e
          +i0d:+i49
caml_007e +i00:+i0d:+i43:+i6e:+i0d:+i43:+i7b:+i55 caml_0030:+i13 5:+i8f
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
+p $0002:+p $000a:!h 01 00 01 00:+p $0012:+p $0016:+p $001a:+p $001e
+p $0022:!h 01 00
caml_glob_data
!h fc 03 54 52 55 45 00 01 fc 03 46 41 4c 53 45 00 fc 01 20 00 fc 01 20 00
!h fc 01 20 00 fc 01 20 00 fc 02 45 58 4e 00
caml_glob_end
!if caml_stack_start < caml_glob_end {
	!serious "ERROR: Not enough memory for stack."
}
!source "/home/piero/.opam/LTS/lib/bcamlc/showmem.asm"
