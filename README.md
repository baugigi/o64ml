**[English]** / [Italiano](LEGGIMI.md)

# The BreadCaml Project [PRE-RELEASE]
*Piero Furiesi <p.furiesi@tiscali.it>*

## OCaml for the Commodore 64

**BreadCaml allows you to compile OCaml programs on Linux systems and generate
native code for Commodore 64.**

## Overview

The BreadCaml Project's provides the `bcamlopt` and `bcamlc` cross-compilers for
GNU/Linux systems.  `bcamlopt` compiles OCaml source files into standalone
native code executables for the Commodore 64, while `bcamlc` generates
standalone bytecode files with the associated interpreter, thus giving the
developer the freedom to choose to optimize the executable for speed or file
size. In both cases, the generated .PRG files contain a BASIC loader at the
beginning, so that they can be simply loaded and run with the usual `LOAD
"MYPROG.PRG",8` and `RUN` commands. In addition to the compilers, the BreadCaml
Project includes a specially modified distribution of the OCaml Standard
Library, the `bcamlppx` preprocessor, and (coming soon) libraries dedicated to
graphics and sound.

## Installation

See [INSTALL.md](INSTALL.md).

## Documentation

The installation procedure generates manual pages for the `bcamlopt` and
`bcamlc` compilers, the StdLib modules (`man 3bc module-name`), and for the
`bcamlppx` preprocessor. Please read also
[CAVEATS-LIMITATIONS-NOTES.md](CAVEATS-LIMITATIONS-NOTES.md) and [BUGS](BUGS).

## License

See [LICENSE-en](LICENSE-en).
