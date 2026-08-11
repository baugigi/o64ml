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

let mod_name_dot = "LargeArray."
let invalid_arg s = invalid_arg (mod_name_dot ^ s)

(***************
external fastdiv255 : int -> int = "caml_largearray_div_255"
external fastmul255 : int -> int = "caml_largearray_mul_255"
external fastdiv85 : int -> int = "caml_largearray_div_85"
external fastmul85 : int -> int = "caml_largearray_mul_85"

let div_mod n = function
  | 255 -> let d = fastdiv255 n in (d, n - fastmul255 d)
  | 85 -> let d = fastdiv85 n in (d, n - fastmul85 d)
  | dim -> (n / dim, n mod dim)
 ****************)

let div_mod n dim = (n / dim, n mod dim)


type 'a largearray = 'a array array


(* unsafe get, not in interface *)
let ( .!() ) a n =
  let dm = div_mod n (Array.length a.(0)) in
  a.(fst dm).(snd dm)

(* unsafe set, not in interface *)
let ( .!()<- ) a n elt =
  let dm = div_mod n (Array.length a.(0)) in
  a.(fst dm).(snd dm) <- elt


let empty = [||]

let length a = match Array.length a with
  | 0 -> 0
  | 1 -> Array.length a.(0)
  | l -> let l' = pred l in l' * Array.length a.(0) + Array.length a.(l')

let get a n =
  if n < 0 || n >= length a then invalid_arg "get"
  else a.!(n)

let set a n elt =
  if n < 0 || n >= length a then invalid_arg "set"
  else a.!(n)<-elt

let ( .$()   ) = get
let ( .$()<- ) = set

let make n elt = 
  if n < 0 then invalid_arg "make"
  else if n = 0 then [||]
  else
    let do_make dim =
      let (d, m) = div_mod n dim in
      let num_arr = if m = 0 then d else succ d in
      let len_arr d' = if d' < d then dim else m in
      Array.init num_arr (fun d' ->
          Array.make (len_arr d') elt) in
    try
      (* (elt : float)  <==>  Invalid_argument *)
      do_make Sys.max_array_length
    with
    | Invalid_argument _ -> do_make Sys.max_floatarray_length
    | x -> raise x

let init n f =
  if n < 0 then invalid_arg "init"
  else if n = 0 then [||]
  else
    let do_init dim =
      let (d, m) = div_mod n dim in
      let num_arr = if m = 0 then d else succ d in
      let len_arr d' = if d' < d then dim else m in
      Array.init num_arr (fun d' ->
          Array.init (len_arr d') (fun m' -> f (d' * dim + m'))) in
    try
      (* (f : int -> float)  <==>  Invalid_argument *)
      do_init Sys.max_array_length
    with
    | Invalid_argument _ -> do_init Sys.max_floatarray_length
    | x -> raise x

let copy a =          Array.(map copy a)
let exists p = 	      Array.(exists (exists p))
let exists2 p =       Array.(exists2 (exists2 p))
let fold_left f =     Array.(fold_left (fold_left f))
let fold_left_map f = Array.(fold_left_map (fold_left_map f))
let fold_right f =    Array.(fold_right (fold_right f))
let for_all p =       Array.(for_all (for_all p))
let for_all2 p =      Array.(for_all2 (for_all2 p))
let iter f =          Array.(iter (iter f))
let iter2 f =         Array.(iter2 (iter2 f))
let map f =           Array.(map (map f))
let map2 f =          Array.(map2 (map2 f))
let mem x =           Array.(exists (mem x))
let memq x =          Array.(exists (memq x))

let iteri f a = for i = 0 to pred (length a) do f i a.!(i) done
let mapi f a = init (length a) (fun i -> f i a.!(i))

let make_matrix sx sy init =
  let res = make sx [||] in
  for x = 0 to pred sx do res.!(x) <- make sy init done;
  res

let append a1 a2 = match length a1, length a2 with
  | 0, 0 -> [||]
  | 0, _ -> copy a2
  | _, 0 -> copy a1
  | l1, l2 ->
     let s = l1 + l2 in
     if s < 0 then invalid_arg "append" (* int overflow *)
     else init s (fun i -> if i < l1 then a1.!(i) else a2.!(i - l1))

let concat lst =
  let sum_length accu a =
    let s = accu + length a in
    if s < 0 then invalid_arg "concat" (* int overflow *)
    else s in
  let size = List.fold_left sum_length 0 lst in
  if size = 0 then [||]
  else
    let rec get_elt copied i = function
      | hd :: tl ->
        let l = length hd in
        let j = i - copied in
        if j < l then hd.!(j) else get_elt (copied + l) i tl
      | [] -> assert false in
    init size (fun i -> get_elt 0 i lst) 

let sub a ofs len =
  if ofs < 0 || len < 0 || ofs > length a - len then invalid_arg "sub"
  else init len (fun i -> a.!(ofs + i))

let fill a ofs len v =
  if ofs < 0 || len < 0 || ofs > length a - len then invalid_arg "fill"
  else for i = ofs to ofs + pred len do a.!(i) <- v done

let blit a1 ofs1 a2 ofs2 len =
  if len < 0 || ofs1 < 0 || ofs2 < 0 || ofs1 > length a1 - len
     || ofs2 > length a2 - len then invalid_arg "blit" else
    let d = ofs2 - ofs1 in
    if a1 != a2 || ofs1 > ofs2 then
      for i = ofs1 to pred (ofs1 + len) do a2.!(i + d) <- a1.!(i) done
    else if (* a1 == a2 && *) ofs1 < ofs2 then
      for i = pred (ofs1 + len) downto ofs1 do a2.!(i + d) <- a1.!(i) done
    else () (* a1 == a2 && ofs1 = ofs2: nothing to do *)

let to_list a =
  let rec tolist i res =
    if i < 0 then res else tolist (pred i) (a.!(i) :: res) in
  tolist (pred (length a)) []

let of_list = function
  | [] -> [||]
  | hd :: tl as l ->
     let a = make (List.length l) hd in
     let rec fill i = function
       | [] -> a
       | hd :: tl -> a.!(i) <- hd; fill (succ i) tl in
     fill 1 tl

let find_opt p a =
  let n = length a in
  let rec loop i =
    if i = n then None
    else let x = a.!(i) in
         if p x then Some x
         else loop (succ i) in
  loop 0

let find_map f a =
  let n = length a in
  let rec loop i =
    if i = n then None
    else match f a.!(i) with
         | None -> loop (succ i)
         | Some _ as r -> r in
  loop 0

let findi_opt p a =
  let n = length a in
  let rec loop i =
    if i = n then None
    else let x = a.!(i) in
         if p x then Some (x, i)
         else loop (succ i) in
  loop 0

let findi_map f a =
  let n = length a in
  let rec loop i =
    if i = n then None
    else match f a.!(i) with
         | None -> loop (succ i)
         | Some x -> Some (x, i) in
  loop 0

let split x =
  if x = [||] then ([||],[||])
  else
    let a0, b0 = x.!(0) in
    let n = length x in
    let a = make n a0 in
    let b = make n b0 in
    for i = 1 to pred n do
      let ai, bi = x.!(i) in
      a.!(i) <- ai;
      b.!(i) <- bi
    done;
    a, b

let combine a b =
  let n = length a in
  if n <> length b then invalid_arg "combine" else
  if n = 0 then [||] else
    let res = make n (a.!(0), b.!(0)) in
    for i = 1 to pred n do res.!(i) <- (a.!(i), b.!(i)) done;
    res

exception Bottom of int
let sort cmp a =
  (* Heap Sort.
     Not a stable sorting algorythm, but it runs in constant heap space and
     (at most) logarithmic stack space. *)
  let ( << ) a b = cmp a b < 0 in
  let maxson l i =
    let i31 = succ (i * 3) in
    let i32 = succ i31 in
    let i33 = succ i32 in
    let x = ref i31 in
    if i33 < l then
      (if a.!(i31) << a.!(i32) then  x := i32;
       if a.!(!x)  << a.!(i33) then  x := i33;
       !x)
    else if i32 < l && a.!(i31) << a.!(i32) then i32
    else if i31 < l then i31
    else raise (Bottom i)
  in
  let rec trickledown l i e =
    let j = maxson l i in
    if e << a.!(j) then
      (a.!(i) <- a.!(j);
       trickledown l j e)
    else a.!(i) <- e
  in
  let rec trickleup i e =
    let father = pred i / 3 in
    assert (i <> father);
    if a.!(father) << e then
      (a.!(i) <- a.!(father);
       if father > 0 then trickleup father e else a.!(0) <- e)
    else a.!(i) <- e
  in
  let trickle l i e =
    try trickledown l i e with
    | Bottom i -> a.!(i) <- e
  in
  let rec bubbledown l i =
    let j = maxson l i in
    a.!(i) <- a.!(j);
    bubbledown l j
  in
  let bubble l i =
    try bubbledown l i with
    | Bottom i -> i
  in
  let l = length a in
  for i = pred (succ l / 3) downto 0 do
    trickle l i a.!(i)
  done;
  for i = pred l downto 2 do
    let e = a.!(i) in
    a.!(i) <- a.!(0);
    trickleup (bubble i 0) e
  done;
  if l > 1 then
    let e = a.!(1) in
    a.!(1) <- a.!(0);
    a.!(0) <- e

let cutoff = 5
let stable_sort cmp a =
  (* Merge Sort.
     It uses a temporary large array of length [n/2], where [n] is [length a].
     Usually faster than Heap Sort, but it doesn't run in constant heap space.
     It's a stable sorting algorithm (i.e. elements that compare equal are kept
     in their original order. *)
  let merge src1ofs src1len src2 src2ofs src2len dst dstofs =
    let src1r = src1ofs + src1len
    and src2r = src2ofs + src2len in
    let rec loop i1 s1 i2 s2 d =
      if cmp s1 s2 <= 0 then
        (dst.!(d) <- s1;
         let i1 = succ i1 in
         if i1 < src1r then loop i1 a.!(i1) i2 s2 (succ d)
         else blit src2 i2 dst (succ d) (src2r - i2))
      else
        (dst.!(d) <- s2;
         let i2 = succ i2 in
         if i2 < src2r then loop i1 s1 i2 src2.!(i2) (succ d)
         else blit a i1 dst (succ d) (src1r - i1))
    in
    loop src1ofs a.!(src1ofs) src2ofs src2.!(src2ofs) dstofs
  in
  let isortto srcofs dst dstofs len =
    for i = 0 to pred len do
      let e = a.!(srcofs + i) in
      let j = ref (pred (dstofs + i)) in
      while (!j >= dstofs && cmp dst.!(!j) e > 0) do
        dst.!(succ !j) <- dst.!(!j);
        decr j
      done;
      dst.!(succ !j) <- e
    done
  in
  let rec sortto srcofs dst dstofs len =
    if len <= cutoff then isortto srcofs dst dstofs len
    else
      let l1 = len / 2 in
      let l2 = len - l1 in
      sortto (srcofs + l1) dst (dstofs + l1) l2;
      sortto srcofs a (srcofs + l2) l1;
      merge (srcofs + l2) l1 dst (dstofs + l1) l2 dst dstofs
  in
  let l = length a in
  if l <= cutoff then isortto 0 a 0 l
  else
    let l1 = l / 2 in
    let l2 = l - l1 in
    let t = make l2 a.!(0) in
    sortto l1 t 0 l2;
    sortto 0 a l2 l1;
    merge l2 l1 t 0 l2 a 0

let fast_sort = stable_sort

let to_seq a =
  let rec aux i () =
    if i < length a then
      let x = a.!(i) in
      Seq.Cons (x, aux (succ i))
    else Seq.Nil in
  aux 0

let to_seqi a =
  let rec aux i () =
    if i < length a then
      let x = a.!(i) in
      Seq.Cons ((i,x), aux (i+1))
    else Seq.Nil in
  aux 0

let of_rev_list = function
  | [] -> [||]
  | hd :: tl as l ->
     let len = List.length l in
     let a = make len hd in
     let rec fill i = function
       | [] -> a
       | hd::tl -> a.!(i) <- hd; fill (i-1) tl
     in
     fill (len-2) tl

let of_seq i =
  let l = Seq.fold_left (fun acc x -> x::acc) [] i in
  of_rev_list l
