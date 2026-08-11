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
!ifdef caml_SHOWMEM {
  !macro str_of_dec ~@s, @n {
    @dgt=["0","1","2","3","4","5","6","7","8","9"]
    !set @s = ""
    !for @i, 4, 0 { !set @s = @s + @dgt[(@n DIV 10 ^ @i) % 10] }
  }
  !macro str_of_hex ~@s, @n {
    @dgt=["0","1","2","3","4","5","6","7","8","9","A","B","C","D","E","F"]
    !set @s = ""
    !for @i, 3, 0 { !set @s = @s + @dgt[(@n DIV $10 ^ @i) % $10] }
  }
  !macro str_of_num ~@s, @n {
    +str_of_dec ~@d, @n
    +str_of_hex ~@h, @n
    !set @s = "$" + @h + " (" + @d + ")"
  }
  !macro caml_mem ~@x, @txt, @start, @end {
    !if @end > @start {
      +str_of_num ~@sadr, @start
      +str_of_num ~@eadr, @end - 1
      +str_of_num ~@size, @end - @start
      !set @x = @x + "\n" + @txt + "\t" + @sadr + "\t" + @eadr + "\t" + @size
    } else {
      !set @x = @x + "\n" + @txt + "\t" + "<N/A>        \t<N/A>        \t<N/A>"
    }
  }
  !ifndef caml_mem_shown { ;show once only
caml_mem_shown
    !ifdef caml_INTERP {
      @program = "Bytecode    "
      @runtime = "Interpreter "
    } else {
      @program = "Object code "
      @runtime = "Runtime libs"
    }
    !set @x = "\n\nSECTION     \tSTART ADDRESS\tEND ADDRESS\tSIZE"
    +caml_mem ~@x, "BASIC loader", caml_loader, caml_loader_end
    +caml_mem ~@x, @program,       caml_program, caml_program_end
    +caml_mem ~@x, "Custom libs ", caml_program_end, caml_runtime
    +caml_mem ~@x, @runtime,       caml_runtime, caml_runtime_end
    +caml_mem ~@x, "Memory GC   ", caml_memory, caml_memory_end
    +caml_mem ~@x, "Standard lib", caml_stdlib, caml_stdlib_end
    +caml_mem ~@x, "Prim.jumptbl", caml_stdlib_end, caml_glob_table
    +caml_mem ~@x, "Global table", caml_glob_table, caml_glob_data
    +caml_mem ~@x, "Global data ", caml_glob_data, caml_glob_end
    +caml_mem ~@x, "      TOTAL:", caml_loader, caml_glob_end
    !set @x = @x + "\n"
    +caml_mem ~@x, "       HEAP:", caml_glob_end, caml_stack_start
    +caml_mem ~@x, "      STACK:", caml_stack_start, caml_stack_end
    !set @x = @x + "\n"
    !info @x
  }
}
