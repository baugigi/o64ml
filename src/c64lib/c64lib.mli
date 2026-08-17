module Petscii = Petscii

module Int : sig
  include module type of Int
  external div_mod : int -> int -> int * int = "caml_nonstd_div_mod"
end

module Float : sig
  include module type of Float
  external sign : float -> int = "caml_nonstd_sign_float"
end
