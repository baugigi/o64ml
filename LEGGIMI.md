**[Italiano]** / [English](README.md)

# Progetto BreadCaml [PRE-RILASCIO]
*Piero Furiesi <p.furiesi@tiscali.it>*

## OCaml per il Commodore 64

**BreadCaml consente di compilare programmi OCaml su sistemi Linux e generare
codice nativo per Commodore 64.**

## In breve

Il Progetto BreadCaml fornisce i cross-compilatori `bcamlopt` e `bcamlc`
specifici per sistemi GNU/Linux.  `bcamlopt` compila file sorgenti OCaml in
codice nativo per il Commodore 64, mentre `bcamlc` genera file di bytecode con
l'interprete associato, rendendo così lo sviluppatore libero di scegliere tra un
file eseguibile più veloce o uno di dimensione inferiore.  In entrambi i casi, i
file .PRG generati contengono un caricatore in BASIC all'inizio e quindi sono
semplicemente caricabili ed avviabili con i consueti `LOAD "MIOPROG.PRG",8` e
`RUN`.  Oltre ai compilatori, il Progetto BreadCaml comprende una distribuzione
della Standard Library di OCaml appositamente modificata, il preprocessore
`bcamlppx` e (prossimamente) delle librerie dedicate alla grafica e al suono.

## Installazione

Vedere [INSTALL.md](INSTALL.md) (in inglese).

## Documentazione

La procedura di installazione genera le pagine di manuale per i compilatori
`bcamlopt` e `bcamlc`, i moduli della StdLib (`man 3bc nome-modulo`) e il
preprocessore `bcamlppx`.  Si consiglia di leggere anche
[CAVEATS-LIMITATIONS-NOTES.md](CAVEATS-LIMITATIONS-NOTES.md) e [BUGS](BUGS).

## Licenza

Vedere [LICENZA-it](LICENZA-it).
