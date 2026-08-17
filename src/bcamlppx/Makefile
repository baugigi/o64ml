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
