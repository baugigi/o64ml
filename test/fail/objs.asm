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

!source "/home/piero/.opam/4.14.2/lib/oc64ml/header.asm"
caml_stack_start = $9c00
caml_stack_end = $a000
caml_PRIM__caml_nonstd_string_of_int = 1
caml_PRIM__caml_nonstd_print_string = 1
caml_PRIM__caml_fresh_oo_id = 1
!source "/home/piero/.opam/4.14.2/lib/oc64ml/loader.asm"

caml_objcode

caml_0000 +i54 caml_0009
caml_0001 +i00:+i5d 0:+i5d 1:+i28 1
caml_0005 +i00:+i36 2:+i40 0:+i5b
caml_0009 +i2b 0,caml_0005:+i39 13:+i63:+i5d 2:+i2b 0,caml_0001:+i39 16
          +i54 caml_0013
caml_0010 +i35 12:+i36 13:+i25 2
caml_0013 +i2b 0,caml_0010:+i0a:+i3f 0:+i13 1:+i68:+i0b:+i43:+i21:+i63:+i0b:+i43
          +i21:+i63:+i0b:+i43:+i21:+i63:+i0b:+i43:+i21:+i63:+i0b:+i43:+i21:+i63
          +i0b:+i43:+i21:+i63:+i0b:+i43:+i21:+i39 20:+i63:+i0b:+i43:+i21:+i63
          +i0b:+i43:+i21:+i63:+i0b:+i43:+i21:+i39 21:+i63:+i0b:+i43:+i21:+i63
          +i0b:+i43:+i21:+i63:+i0b:+i43:+i21:+i63:+i0b:+i43:+i21:+i63:+i0b:+i43
          +i21:+i63:+i0b:+i43:+i21:+i39 18:+i63:+i0b:+i43:+i21:+i39 22:+i63:+i0b
          +i43:+i21:+i63:+i0b:+i43:+i21:+i63:+i0b:+i43:+i21:+i63:+i0b:+i43:+i21
          +i63:+i0b:+i43:+i21:+i63:+i0b:+i43:+i21:+i63:+i0b:+i43:+i21:+i39 15
          +i63:+i0b:+i43:+i21:+i63:+i0b:+i43:+i21:+i63:+i0b:+i43:+i21:+i63:+i0b
          +i43:+i21:+i63:+i0b:+i43:+i21:+i63:+i0b:+i43:+i21:+i63:+i0b:+i43:+i21
          +i63:+i0b:+i43:+i21:+i63:+i0b:+i43:+i21:+i63:+i0b:+i43:+i21
          +i54 caml_00ab
caml_00a5 +i35 14:+i68:+i36 15:+i26 3
caml_00a9 +i35 16:+i28 1
caml_00ab +i35 17:+i36 18:+i21:+i09:+i39 14:+i00:+i13 1:+i36 19:+i0b:+i36 20
          +i22:+i09:+i2b 0,caml_00a9:+i0b:+i0d:+i36 21:+i23:+i2b 0,caml_00a5
          +i13 1:+i0b:+i36 22:+i21:+i63:+i0b:+i21:+i13 2:+i6c 5:+i0b:+i8d 118
          +i22:+i13 1:+i8f
caml_objcode_end

!source "/home/piero/.opam/4.14.2/lib/oc64ml/runtime.asm"
!source "/home/piero/.opam/4.14.2/lib/oc64ml/memory.asm"
!source "/home/piero/.opam/4.14.2/lib/oc64ml/stdlib.asm"
!align $01, $00
caml_externals_lo
	!byte <(caml_nonstd_string_of_int)
	!byte <(caml_nonstd_print_string)
	!byte <(caml_fresh_oo_id)
caml_externals_hi
	!byte >(caml_nonstd_string_of_int)
	!byte >(caml_nonstd_print_string)
	!byte >(caml_fresh_oo_id)
!macro p .ptr { !wo caml_glob_data + .ptr }
caml_glob_table
+p $0002:!h 01 00 01 00 01 00 01 00:+p $0016:!h 01 00:+p $001a:!h 01 00 01
!h 00 01 00
caml_glob_data
!h fc 07 75 6e 69 6d 70 6c 65 6d 65 6e 74 65 64 00 fc 01 76 00 00 01
+p $0012:!h fc 01 76 00
caml_glob_end
!if caml_stack_start < caml_glob_end {
  !serious "ERROR: Not enough memory for stack."
}
!ifdef caml_SHOWMEM {
  !macro caml_mem @txt, @start, @end {
    !info @txt + "\t", @start, "\t", @end - 1, "\t", @end - @start
  }
  !ifndef caml_acme_allpasses { ;wait for ACME to complete all passes
caml_acme_allpasses
    !info "---SECTION---\tSTART ADDRESS\tEND ADDRESS\tSIZE"
    +caml_mem "Basic loader", caml_loader, caml_loader_end
    +caml_mem "Object code ", caml_objcode, caml_objcode_end
    +caml_mem "Runtime lib ", caml_runtime, caml_runtime_end
    +caml_mem "Garb.Collect", caml_memory, caml_memory_end
    +caml_mem "Standard lib", caml_stdlib, caml_stdlib_end
    +caml_mem "External lib", caml_stdlib_end, caml_glob_data
    +caml_mem "Global data ", caml_glob_data, caml_glob_end
    +caml_mem "Heap memory ", caml_glob_end, caml_stack_start
    +caml_mem "Stack memory", caml_stack_start, caml_stack_end
  }
}
