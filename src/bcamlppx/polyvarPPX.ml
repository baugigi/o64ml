open Asttypes
open Parsetree 
open Ast_mapper
open Ast_helper

(* Global database of polymorphic variant renamings *)
type db_t =  { mutable index : int;
               renamings : (string, string) Hashtbl.t }
let db = ref { index = -1;
               renamings = Hashtbl.create 16 }

let db_load in_ch =
  db := Marshal.from_channel in_ch

let db_save out_ch =
  Marshal.to_channel out_ch !db [];
  flush out_ch

let db_dump in_ch out_ch =
  let count = ref 0 in
  Hashtbl.iter
    (fun key value ->
      incr count;
      Printf.fprintf out_ch "%5d: `%s\t->\t`%s\n" !count key value)
    (Marshal.from_channel in_ch).renamings;
  flush out_ch


(* Renaming function *)
let rename_polyvar tag =
  try Hashtbl.find !db.renamings tag
  with Not_found ->
    let i = succ !db.index in
    if i < 32768 then
      let new_tag = PolyvarArray.a.(i) in
      !db.index <- i;
      Hashtbl.add !db.renamings tag new_tag;
      new_tag
    else raise Exit

let error ~loc =
  let fmt = Scanf.format_from_string
              "the number of polymorphic variants in all compilation \
               units exceeds 32768." "" in
  extension_of_error (Location.errorf ~loc fmt)

(* PPX rewriter *)
let expr_rewriter mapper expr = match expr.pexp_desc with
  | Pexp_variant (lbl, exp_opt) ->
     (try Exp.variant ~loc:expr.pexp_loc ~attrs:expr.pexp_attributes
            (rename_polyvar lbl)
            (Option.map (mapper.expr mapper) exp_opt)
      with Exit ->
        Exp.extension ~loc:expr.pexp_loc (error ~loc:expr.pexp_loc))
  | _ ->
     default_mapper.expr mapper expr

let pat_rewriter mapper pat = match pat.ppat_desc with
  | Ppat_variant (lbl, pat_opt) ->
     (try
        Pat.variant ~loc:pat.ppat_loc ~attrs:pat.ppat_attributes
          (rename_polyvar lbl)
          (Option.map (mapper.pat mapper) pat_opt)
      with Exit ->
        Pat.extension ~loc:pat.ppat_loc (error ~loc:pat.ppat_loc))
  | _ ->
     default_mapper.pat mapper pat

let rf_rewriter mapper rf = match rf.prf_desc with
  | Rtag(lbl, bool_, ctyp_l) ->
     Rf.tag ~loc:rf.prf_loc ~attrs:rf.prf_attributes
       { lbl with txt = rename_polyvar lbl.txt }
       bool_
       (List.map (mapper.typ mapper) ctyp_l)
  | Rinherit core_typ ->
     Rf.inherit_ ~loc:rf.prf_loc
       (mapper.typ mapper core_typ)

let typ_rewriter mapper typ = match typ.ptyp_desc with
  | Ptyp_variant (rf_l, clos_fl, lbls_opt) ->
     (try
        Typ.variant ~loc:typ.ptyp_loc ~attrs:typ.ptyp_attributes
          (List.map (rf_rewriter mapper) rf_l)
          clos_fl
          (Option.map (List.map rename_polyvar) lbls_opt)
      with Exit ->
        Typ.extension ~loc:typ.ptyp_loc (error ~loc:typ.ptyp_loc))
  | _ ->
     default_mapper.typ mapper typ

let mapper =
  { default_mapper with
    expr = expr_rewriter;
    pat = pat_rewriter;
    typ = typ_rewriter }
