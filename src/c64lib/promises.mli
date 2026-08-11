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
(** The type for promise states. *)
type 'a state =
  | Pending		(** the promise is not fulfilled nor rejected yet. *)
  | Fulfilled of 'a	(** the promise has been resolved with a value. *) 
  | Rejected of exn	(** the promise has been rejected with an exception. *)

(** The type for promises. *)
type 'a promise

(** The type for promise resolvers. *)
type 'a resolver


(** [make ()] returns a new pending promise with an associated resolver. *)
val make : unit -> 'a promise * 'a resolver


(** [return x] returns a new promise already fulfilled with value [x]. *)
val return : 'a -> 'a promise


(** [state p] is the state of the promise [p]. *)
val state : 'a promise -> 'a state


(** [fulfill r x] resolves the promise [p], associated with resolver [r],
    with value [x]; [state p] will become [Fulfilled x].
    Requires: [p] is pending. *)
val fulfill : 'a resolver -> 'a -> unit


(** [reject r x] rejects the promise [p], associated with resolver [r],
    with exception [x]; [state p] will become [Rejected x].
    Requires: [p] is pending. *)
val reject : 'a resolver -> exn -> unit


(** [bind p c] registers callback [c] with promise [p].
    When the promise is fulfilled, the callback will be run on the promises's
    contents. If the promise is never fulfilled, the callback will never run. *)
val bind : 'a promise -> ('a -> 'b promise) -> 'b promise
