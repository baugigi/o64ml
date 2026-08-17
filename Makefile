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
	find . -path '*/.git' -prune -o -type f -name '*~' -exec rm {} '+'
	rm -f etc/Makefile.conf
