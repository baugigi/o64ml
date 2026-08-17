SHELL = /bin/bash
CONF = ../../etc/Makefile.conf
include $(if $(wildcard $(CONF)),$(CONF),$(error \
	Please run «./configure [options...]» from the main source directory))

stdlib.asm: depends.asm stdlib_*.asm
	echo -ne "\
	;; AUTO-GENERATED FILE - DO NOT EDIT\n\
	caml_stdlib\n\
	 $(patsubst %,!source \"$(LIBDIR)/%\"\n,$^)\
	caml_stdlib_end\n\
	" > $@

depends.asm: stdlib_*.asm
	../../tools/mkdepends $@ $^

.PHONY: clean
clean:
	rm -f stdlib.asm depends.asm
