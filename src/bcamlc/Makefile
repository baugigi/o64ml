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
