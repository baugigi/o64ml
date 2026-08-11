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

SHELL := /bin/bash

TARGET := snake.prg
SOURCE := iOtools snake
EXTLIB := iOtools
COMP = bcamlopt
FLAGS = -db snake.db

$(TARGET): $(EXTLIB:=.asm) $(EXTLIB:=.c) $(SOURCE:=.cmo)
	$(COMP) $(FLAGS) -o $@ $^ -- -r snake.rep

%.cmo: %.ml $(SOURCE:=.cmi)
	$(COMP) $(FLAGS) -c $<

%.cmi: %.mli
	$(COMP) $(FLAGS) -c $<

.INTERMEDIATE: $(SOURCE:=.mli)
%.mli: %.ml
	$(COMP) $(FLAGS) -c -i $< > $@

.INTERMEDIATE: $(SOURCE:=.c)
%.c: %.asm
	sed -nE 's/^[ \t]*(IOtools_[a-zA-Z0-9_]*)/void \1 () {}/p' $< > $@

.PHONY: clean
clean:
	rm -f *.{cm?,o,prg,db,rep}

.merlin:
	echo -ne "\
	STDLIB $$($(COMP) -where)\n\
	S .\n\
	B .\n\
	" > $@
