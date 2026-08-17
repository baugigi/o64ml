SHELL = /bin/bash
CONF = ../../etc/Makefile.conf
include $(if $(wildcard $(CONF)),$(CONF),$(error \
	Please run «./configure [options...]» from the main source directory))

BIN = ../../bin
TARGET = $(BIN)/bcamlc
VPATH = ./ocamlclean
OCLEAN = step1 prim step2 step3 data cleanbra rmnop globalise cleanenvs
BCAMLC = config globals opcodes export cmdline bcamlc
SOURCE = $(OCLEAN) $(BCAMLC)
FLAGS = -I +/../obytelib/ obytelib.cmxa -I $(VPATH)

$(TARGET): $(SOURCE:=.ml)
	$(OCAMLOPT) $(FLAGS) -o $@ $^

config.ml: config.ml.tpl $(CONF)
	cp $@.tpl $@;\
	echo -e "\
	let ocamlc  = \"$(OCAMLC_UNSAFE)\"\n\
	let libdir  = \"$(LIBDIR)\"\n\
	let bindir  = \"$(BINDIR)\"\n\
	let acme    = \"$(ACME)\"\n\
	let version = \"$(VERSION)\"\n\
	" >> $@

.PHONY: clean
clean:
	rm -f $(TARGET) {.,$(VPATH)}/*.{o,cm?} config.ml
