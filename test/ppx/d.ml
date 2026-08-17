type t = [ `IIIa | `IIIb | `IIIz ]
let _ =
  let a = `IIIa in
  let b = `IIIb in
  let c = `IIIc in
  match (a, b, c) with
  | (`IIIa, `IIIb, `IIIc) -> 0
  | _ -> 1
