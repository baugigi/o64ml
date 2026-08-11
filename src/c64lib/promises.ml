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
type 'a state =
  | Pending
  | Fulfilled of 'a
  | Rejected of exn

(* RI: the input may not be [Pending]. *)
type 'a handler = 'a state -> unit

(* RI: if [state <> Pending] then [handlers = []]. *)
type 'a promise = {
    mutable state : 'a state;
    mutable handlers : 'a handler list
  }

let enqueue handler promise = promise.handlers <- handler :: promise.handlers

type 'a resolver = 'a promise

(* [write_once p s] changes the state of [p] to be [s].
   If [p] and [s] are both pending, that has no effect. *)
let write_once promise state =
  if promise.state <> Pending then invalid_arg "write_once: cannot write twice"
  else promise.state <- state

let make () = let p = {state = Pending; handlers = []} in p, p

let return x = {state = Fulfilled x; handlers = []}

let state promise = promise.state

let resolve resolver state =
  assert (state <> Pending);
  let handlers = resolver.handlers in
  resolver.handlers <- [];
  write_once resolver state;
  List.iter (fun f -> f state) handlers

let reject resolver x = resolve resolver (Rejected x)

let fulfill resolver x = resolve resolver (Fulfilled x)

let copying_handler resolver = function
  | Pending -> failwith "copying_handler: pending handler"
  | Rejected exc -> reject resolver exc
  | Fulfilled x -> fulfill resolver x

let handler_of_callback callback resolver = function
  | Pending -> failwith "handler_of_callback: pending handler"
  | Rejected exc -> reject resolver exc
  | Fulfilled x ->
     try
       let promise = callback x in
       match promise.state with
       | Fulfilled y -> fulfill resolver y
       | Rejected exc -> reject resolver exc
       | Pending -> enqueue (copying_handler resolver) promise
     with exc -> reject resolver exc

let bind input_promise callback =
  let fail exc = {state = Rejected exc; handlers = []} in
  match input_promise.state with
  | Fulfilled x -> (try callback x with exc -> fail exc)
  | Rejected exc -> fail exc
  | Pending ->
     let output_promise, output_resolver = make () in
     enqueue (handler_of_callback callback output_resolver) input_promise;
     output_promise
