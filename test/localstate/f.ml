
(*

#require "inspect"
;;
let dump v =
  let file = "dump.dot" in
  Inspect.Dot.dump_to_file file v;
  Sys.command ("xdot " ^ file)
;;

*)

let f =
  let x = ref 1000 in
  fun () -> incr x; !x
;;

f ()
;;

