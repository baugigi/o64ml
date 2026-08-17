
FILES := largeArray.asm largeArray.c largeArray.mli largeArray.ml test.ml

.PHONY: all
all:	clean
	bcamlopt $(FILES)

.PHONY: interp
interp:	clean
	bcamlc $(FILES)

.PHONY: debug
debug:	clean
	bcamlc $(FILES) -- -Dcaml_DEBUG=1

.PHONY: clean
clean:
	rm -f *.prg *.cmi *.cmo *.o *.db
