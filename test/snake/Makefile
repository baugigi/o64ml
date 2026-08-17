
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
	../../tools/mkproto -p IOtools_ $< > $@

.PHONY: clean
clean:
	rm -f *.{cm?,o,prg,db,rep}

.merlin:
	echo -ne "\
	STDLIB $$($(COMP) -where)\n\
	S .\n\
	B .\n\
	" > $@
