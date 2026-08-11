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

let int_of_string s =
  let fail () = failwith "int_of_string" in
  let uplimit = -2 * min_int in
  let l = String.length s in
  let val_digit base ch =
    let v = match ch with
      | '0'..'9' -> int_of_char ch - 48
      | 'A'..'F' -> int_of_char ch - 55
      | 'a'..'f' -> int_of_char ch - 87
      | _ -> fail () in
    if v < base then v else fail () in
  let rec parse_digit i base accu =
    match accu with
    | Some n when i = l -> n
    | Some n ->
       (match s.[i] with
        | '_' -> parse_digit (succ i) base accu
        | ch -> let v = n * base + val_digit base ch in
                if v > uplimit then fail ()
                else parse_digit (succ i) base (Some v))
    | None -> parse_digit (succ i) base (Some (val_digit base s.[i])) in
  let (value, sign) = 
    if l = 0 then fail ()
    else if l = 1 then (val_digit 10 s.[0], 1)
    else (match s.[0] with
          | '0' -> (match s.[1] with
                    | 'x' | 'X' -> (parse_digit 2 16 None, 0)
                    | 'o' | 'O' -> (parse_digit 2 8 None, 0)
                    | 'b' | 'B' -> (parse_digit 2 2 None, 0)
                    | _ -> (parse_digit 1 10 (Some 0), 1))
          | '+' -> (parse_digit 1 10 None, 1)
          | '-' -> (parse_digit 1 10 None, -1)
          | _ -> (parse_digit 0 10 None, 1)) in
  match sign with
  | 1 when value <= max_int -> value
  | 0 -> if value <= max_int then value else value - uplimit
  | -1 when value <= -min_int -> -value
  | _ -> fail ()
;;
