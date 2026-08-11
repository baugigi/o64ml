(* ——————————————————————————————————————————————————————————————————————
   Progetto BreadCaml / The BreadCaml Project
   Copyright (C) 21-Apr-2026 Piero Furiesi
   
   Questo  programma  è software  libero;  può  essere ridistribuito  e/o
   modificato nei termini della licenza GNU GPL ver. 2,  come specificato
   nel file LICENZA-it nella cartella principale del progetto.
   
   This program is  free software; you can redistribute  it and/or modify
   it under the terms of the GNU  General Public License (GPL) ver. 2, as
   specified in the LICENSE-en file in the project root folder.
   —————————————————————————————————————————————————————————————————————— *)
module Petscii = Petscii

module Int = struct
  include Int
  external div_mod : int -> int -> int * int = "caml_nonstd_div_mod"
end

module Float = struct
  include Float
  external sign : float -> int = "caml_nonstd_sign_float"
end

(******************************
module IRQ = struct
  (* il modulo va compilato con l'opzione -irqsupport che inizialmente
     redireziona il vettore di IRQ al gestore di BreadCaml e aggiunge alla
     STOP il ripristino degli IRQ e del vettore di default  (oopure no,
     ad esempio per scrivere un programma BreadCaml per un orologio fisso
     su schermo... *)
  
  external set_standard_handler : unit -> unit = "caml_irq_set_standard_handler"
  external set_custom_handler   : unit -> unit = "caml_irq_set_custom_handler"
  external set_callback_handler : (unit -> _) -> unit =
    "caml_irq_set_callback_handler"

  type 'a t =
    | Kernal
    | Callback of (unit -> 'a)
    | Custom
      
  let set_handler = function
    | Kernal -> set_standard_handler ()
    | Callback f -> set_callback_handler f
    | Custom -> set_custom_handler ()
end
*********************************)

module VIC_II = struct
  module Sprites = struct
  (*
    Servono funzioni per:
    - definire gli sprites (dati pixel e attributi di estensione X/Y)
    - modificare le definizioni
    - accenderli/spengerli
    - posizionarli
    - ottenere info su posizione e attributi
    - muoverli (possibilmente assegnando una funzione oraria fun t -> (x, y)
    a ogni sprite, eseguita ogni p frazione di secondo)
    - gestire le collisioni MOB/MOB e MOB/FGD
   *)
  end
end

module CIA = struct
  module CIA1 = struct
  end
  module CIA2 = struct
  end
end

module SID = struct
end
