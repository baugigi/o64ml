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

(** Large arrays.

    A large array is similar to an array but it can contain more elements: its
    maximum length is [max_int] i.e. 16383. All usual operations on arrays are
    available for large arrays too.
 *)

type 'a largearray (* = 'a array array *)
(** The type for large arrays. *)

val empty : 'a largearray
(** [empty] returns The large array with no elements. *)

val length : 'a largearray -> int
(** [length a] returns the length (number of elements) of large array [a]. *)

val get : 'a largearray -> int -> 'a
(** [get a n] returns the element number [n] of large array [a].
    The first element has number 0.
    The last element has number [length a - 1].
    You can also write [a.$(n)] instead of [get a n].

    @raise Invalid_argument
      if [n] is outside the range 0 to [(length a - 1)]. *)

val set : 'a largearray -> int -> 'a -> unit
(** [set a n x] modifies large array [a] in place, replacing
    element number [n] with [x].
    You can also write [a.$(n) <- x] instead of [set a n x].

    @raise Invalid_argument
      if [n] is outside the range 0 to [length a - 1]. *)

val ( .$()   ) : 'a largearray -> int -> 'a
(** [a.$(n)] equivals to [get a n]. *)

val ( .$()<- ) : 'a largearray -> int -> 'a -> unit
(** [a.$(n) <- x] equivals to [set a n x]. *)

val make : int -> 'a -> 'a largearray
(** [make n x] returns a fresh large array of length [n], initialized with [x].
    All the elements of this new large array are initially
    physically equal to [x] (in the sense of the [==] predicate).
    Consequently, if [x] is mutable, it is shared among all elements
    of the large array, and modifying [x] through one of the large array entries
    will modify all other entries at the same time.
    
    @raise Invalid_argument if [n < 0].
 *)

val init : int -> (int -> 'a) -> 'a largearray
(** [init n f] returns a fresh large array of length [n], with element number
    [i] initialized to the result of [f i].
    In other terms, [init n f] tabulates the results of [f] applied to the
    integers [0] to [n-1].

    @raise Invalid_argument if [n < 0].
 *)

val make_matrix : int -> int -> 'a -> 'a largearray largearray
(** [make_matrix dimx dimy e] returns a two-dimensional large array
    (a large array of latge arrays) with first dimension [dimx] and
    second dimension [dimy]. All the elements of this new matrix
    are initially physically equal to [e].
    The element ([x,y]) of a matrix [m] is accessed
    with the notation [m.$(x).$(y)].

   @raise Invalid_argument if [dimx] or [dimy] is negative or
   their product is greater than [max_int]. *)

val append : 'a largearray -> 'a largearray -> 'a largearray
(** [append v1 v2] returns a fresh large array containing the concatenation of
    the large arrays [v1] and [v2].
    @raise Invalid_argument
      if [length v1 + length v2] overflows [max_int]. *)

val concat : 'a largearray list -> 'a largearray
(** Same as {!append}, but concatenates a list of large arrays. *)

val sub : 'a largearray -> int -> int -> 'a largearray
(** [sub a pos len] returns a fresh large array of length [len], containing the
    elements number [pos] to [pos + len - 1] of large array [a].

    @raise Invalid_argument
      if [pos] and [len] do not designate a valid subarray of [a]; that is,
      if [pos < 0], or [len < 0], or [pos + len > length a]. *)

val copy : 'a largearray -> 'a largearray
(** [copy a] returns a copy of [a], that is, a fresh large array containing the
    same elements as [a], in the same order. *)

val fill : 'a largearray -> int -> int -> 'a -> unit
(** [fill a pos len x] modifies the large array [a] in place, storing [x] in
    elements number [pos] to [pos + len - 1].

    @raise Invalid_argument
      if [pos] and [len] do not designate a valid subarray of [a]. *)

val blit : 'a largearray -> int -> 'a largearray -> int -> int -> unit
(** [blit src src_pos dst dst_pos len] copies [len] elements from large array
    [src], starting at element number [src_pos], to large array [dst], starting
    at element number [dst_pos]. It works correctly even if [src] and [dst] are
    the same large array, and the source and destination chunks overlap.

    @raise Invalid_argument
      if [src_pos] and [len] do not designate a valid subarray of [src], or
      if [dst_pos] and [len] do not designate a valid subarray of [dst]. *)

val to_list : 'a largearray -> 'a list
(** [to_list a] returns the list of all the elements of [a]. *)

val of_list : 'a list -> 'a largearray
(** [of_list l] returns a fresh large array containing the elements of [l].

    @raise Invalid_argument
      if the length of [l] is greater than [max_int]. *)

(** {1 Iterators} *)

val iter : ('a -> unit) -> 'a largearray -> unit
(** [iter f a] applies function [f] in turn to all the elements of [a].
    It is equivalent to
    [f a.(0); f a.(1); ...; f a.(length a - 1); ()]. *)

val iteri : (int -> 'a -> unit) -> 'a largearray -> unit
(** Same as {!iter}, but the function is applied to the index of the element
    as first argument, and the element itself as second argument. *)

val map : ('a -> 'b) -> 'a largearray -> 'b largearray
(** [map f a] applies function [f] to all the elements of [a], and builds a
    large array with the results returned by [f], as in
    [init (length a) (fun i -> f (get a i))]. *)

val mapi : (int -> 'a -> 'b) -> 'a largearray -> 'b largearray
(** Same as {!map}, but the function is applied to the index of the element
    as first argument, and the element itself as second argument. *)

val fold_left : ('a -> 'b -> 'a) -> 'a -> 'b largearray -> 'a
(** [fold_left f init a] computes
    [f (... (f (f init a.(0)) a.(1)) ...) a.(n-1)],
    where [n] is the length of the large array [a]. *)

val fold_left_map : ('a -> 'b -> 'a * 'c) -> 'a -> 'b largearray -> 'a * 'c largearray
(** [fold_left_map] is a combination of {!fold_left} and {!map} that threads an
    accumulator through calls to [f]. *)

val fold_right : ('b -> 'a -> 'a) -> 'b largearray -> 'a -> 'a
(** [fold_right f a init] computes
    [f a.(0) (f a.(1) ( ... (f a.(n-1) init) ...))],
    where [n] is the length of the large array [a]. *)

(** {1 Iterators on two large arrays} *)

val iter2 : ('a -> 'b -> unit) -> 'a largearray -> 'b largearray -> unit
(** [iter2 f a b] applies function [f] to all the elements of [a] and [b].

    @raise Invalid_argument
      if the large arrays are not the same size. *)

val map2 : ('a -> 'b -> 'c) -> 'a largearray -> 'b largearray -> 'c largearray
(** [map2 f a b] applies function [f] to all the elements of [a] and [b], and
    builds a large array with the results returned by [f], as in
    [init (length a) (fun i -> f (get a i) (get b i))].

    @raise Invalid_argument
      if the large arrays are not the same size. *)

(** {1 Large array scanning} *)

val for_all : ('a -> bool) -> 'a largearray -> bool
(** [for_all f [|a1; ...; an|]] checks if all elements
    of the large array satisfy the predicate [f]. That is, it returns
    [(f a1) && (f a2) && ... && (f an)]. *)

val exists : ('a -> bool) -> 'a largearray -> bool
(** [exists f [|a1; ...; an|]] checks if at least one element of the large
    array satisfies the predicate [f]. That is, it returns
    [(f a1) || (f a2) || ... || (f an)]. *)

val for_all2 : ('a -> 'a -> bool) -> 'a largearray -> 'a largearray -> bool
(** Same as {!for_all}, but for a two-argument predicate.

    @raise Invalid_argument
      if the two large arrays have different lengths. *)

val exists2 : ('a -> 'b -> bool) -> 'a largearray -> 'b largearray -> bool
(** Same as {!exists}, but for a two-argument predicate.

    @raise Invalid_argument
      if the two large arrays have different lengths. *)

val mem : 'a -> 'a largearray -> bool
(** [mem a set] is true if and only if [a] is structurally equal
    to an element of [l] (i.e. there is an [x] in [l] such that
    [compare a x = 0]). *)

val memq : 'a -> 'a largearray -> bool
(** Same as {!mem}, but uses physical equality instead of structural equality
    to compare list elements. *)

val find_opt : ('a -> bool) -> 'a largearray -> 'a option
(** [find_opt p a] returns [Some x] where [x] is the first element of the large
    array [a] that satisfies the predicate [p], or [None] if there is no value
    that satisfies [p] in the large array [a]. *)

val findi_opt : ('a -> bool) -> 'a largearray -> ('a * int) option
(** [findi_opt p a] returns [Some (x, i)] where [x] is the first element of the
    large array [a] that satisfies the predicate [p] and [i] is its position,
    or [None] if there is no value that satisfies [p] in the large array [a]. *)

val find_map : ('a -> 'b option) -> 'a largearray -> 'b option
(** [find_map f a] applies [f] to the elements of [a] in order, and returns the
    first result of the form [Some v], or [None] if none exist. *)

val findi_map : ('a -> 'b option) -> 'a largearray -> ('b * int) option
(** [findi_map f a] applies [f] to the elements of [a] in order, and returns
    [Some (v, i)] where [Some v] is the first not-[None] result and [i] is the
    element position, or [None] if none exist. *)

(** {1 Large arrays of pairs} *)

val split : ('a * 'b) largearray -> 'a largearray * 'b largearray
(** [split ab] is
    [(init (length ab) (fun i -> fst (get a i)),
    init (length ab) (fun i -> snd (get a i)))]. *)

val combine : 'a largearray -> 'b largearray -> ('a * 'b) largearray
(** [combine a b] is [init (length a) (fun i -> ((get a i), (get b i))].

    @raise Invalid_argument
      if the two large arrays have different lengths. *)

(** {1 Sorting} *)

val sort : ('a -> 'a -> int) -> 'a largearray -> unit
(** Sort a large array in increasing order according to a comparison function.
    The comparison function must return 0 if its arguments compare as equal, a
    positive integer if the first is greater, and a negative integer if the
    first is smaller (see below for a complete specification).  For example,
    {!Stdlib.compare} is a suitable comparison function. After calling [sort],
    the large array is sorted in place in increasing order.

    [sort] is guaranteed to run in constant heap space and (at most) logarithmic
    stack space.
    
    The current implementation uses Heap Sort. It runs in constant stack space.
    
    Specification of the comparison function:
    Let [a] be the large array and [cmp] the comparison function. The following
    must be true for all [x], [y], [z] in [a]:
    - [cmp x y] > 0 if and only if [cmp y x] < 0
    - if [cmp x y] >= 0 and [cmp y z] >= 0 then [cmp x z] >= 0
    
    When [sort] returns, [a] contains the same elements as before, reordered in
    such a way that for all i and j valid indices of [a]:
    -   [cmp a.(i) a.(j)] >= 0 if and only if i >= j
*)

val stable_sort : ('a -> 'a -> int) -> 'a largearray -> unit
(** Same as {!sort}, but the sorting algorithm is stable (i.e. elements that
    compare equal are kept in their original order) and not guaranteed to run
    in constant heap space.
    
    The current implementation uses Merge Sort. It uses a temporary large array
    of length [n/2], where [n] is the length of the large array. It is usually
    faster than the current implementation of {!sort}.
 *)

val fast_sort : ('a -> 'a -> int) -> 'a largearray -> unit
(** Same as {!sort} or {!stable_sort}, whichever is faster on typical input. *)


(** {1 Large arrays and Sequences} *)

val to_seq : 'a largearray -> 'a Seq.t
(** Iterate on the large array, in increasing order. Modifications of the large
    array during iteration will be reflected in the sequence. *)

val to_seqi : 'a largearray -> (int * 'a) Seq.t
(** Iterate on the large array, in increasing order, yielding indices along
    elements. Modifications of the large array during iteration will be
    reflected in the sequence. *)

val of_seq : 'a Seq.t -> 'a largearray
(** Create a large array from the generator *)
