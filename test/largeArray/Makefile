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
