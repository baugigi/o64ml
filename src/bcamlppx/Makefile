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
TARGET = $(BIN)/bcamlppx
SOURCE = petscii petsciiPPX polyvarArray polyvarPPX bcamlppx
FLAGS =  -I +compiler-libs ocamlcommon.cmxa str.cmxa unix.cmxa

$(TARGET): $(SOURCE:=.ml)
	$(OCAMLOPT) $(FLAGS) -o $@ $^

.PHONY: clean
clean:
	rm -f $(TARGET) *.{o,cm?}
