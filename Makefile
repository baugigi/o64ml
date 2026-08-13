#  ——————————————————————————————————————————————————————————————————————
#  Progetto BreadCaml / The BreadCaml Project
#  Copyright (C) 21-Apr-2026 Piero Furiesi
#  
#  Questo  programma  è software  libero;  può  essere ridistribuito  e/o
#  modificato nei termini della licenza GNU GPL ver. 2,  come specificato
#  nel file LICENZA-it nella cartella principale del progetto.
#  
#  This program is  free software; you can redistribute  it and/or modify
#  it under the terms of the GNU  General Public License (GPL) ver. 2, as
#  specified in the LICENSE-en file in the project root folder.
#  ——————————————————————————————————————————————————————————————————————
SHELL = /bin/bash
CONF  = etc/Makefile.conf
include $(if $(wildcard $(CONF)),$(CONF),$(error \
	Please run «./configure [options...]» from the main source directory))

.PHONY: all
all:
	$(MAKE) -C src/bcamlc
	$(MAKE) -C src/bcamlppx
	$(MAKE) -C src/stdlib
	$(MAKE) -C src/asm

.PHONY: install
install: all
	mkdir -p $(LIBDIR) $(BINDIR) $(MAN1DIR) $(MAN3DIR)
	cp src/asm/*.asm $(LIBDIR)
	strip bin/bcaml{c,ppx}
	cp bin/bcaml{c,ppx} $(BINDIR)
	ln -f -s -T $(BINDIR)/bcaml{c,opt}
	cp man/* $(MAN1DIR)
	cp src/stdlib/{stdlib.cma,libcamlrun.a,*.{ml,mli,cmo,cmi}} $(LIBDIR)
	cp src/stdlib/*.$(MAN3EXT) $(MAN3DIR)

.PHONY: uninstall
uninstall:
	rm -f $(BINDIR)/{acme,bcaml{c,opt,ppx}}
	rm -f $(MAN1DIR)/bcaml{c,opt,ppx}.1.gz
	rm -f $(MAN3DIR)/*.$(MAN3EXT)
	rm -fr $(LIBDIR)

.PHONY: clean
clean:
	$(MAKE) -C src/bcamlc $@
	$(MAKE) -C src/bcamlppx $@
	$(MAKE) -C src/stdlib $@
	$(MAKE) -C src/asm $@
	$(MAKE) -C test $@

.PHONY: fullinstall
fullinstall: install clean

.PHONY: gitclean
gitclean: clean
	find . -type f -name '*~' -delete
	rm -f etc/Makefile.conf
