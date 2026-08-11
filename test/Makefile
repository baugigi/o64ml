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

SUB_MAKEDIRS := $(dir $(shell find . -mindepth 2 -name "Makefile"))

.PHONY: test
test:
	@for dir in $(SUB_MAKEDIRS); do \
		echo "--- Makefile in: $$dir"; \
		$(MAKE) -C $$dir; \
	done
	@for file in $(shell find . -mindepth 2 -name "*.ml"); do \
		dir_of_file="$$(dirname "$$file")/"; \
		if ! echo "$(SUB_MAKEDIRS)" | grep -q "$$dir_of_file"; then \
			echo "--- Compiling: $$file"; \
			breadcaml "$$file"; \
		fi; \
	done

.PHONY: clean
clean:
	rm -f *.{cm?,prg}
	rm -f */*.{cm?,prg}
