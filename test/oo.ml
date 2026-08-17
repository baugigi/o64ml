
let o = object
  val state = ref 0
  method g () = !state
  method s n = state := n
  method i () = incr state
end

