module CtlChar = struct
  (* cursor movements *)
  let up	= '\145'
  let dn	= '\017'
  let lf	= '\157'
  let rt	= '\029'
  (* colours: (l)ight/(m)edium/(d)ark *)
  let blk	= '\144'
  let wht	= '\005'
  let red	= '\028'
  let cyn	= '\159'
  let pur	= '\156'
  let grn	= '\030'
  let lgrn	= '\153'
  let blu	= '\031'
  let lblu	= '\154'
  let yel	= '\158'
  let org	= '\129'
  let brn	= '\149'
  let lred, pnk	= '\150', '\150'
  let dgry	= '\151'
  let mgry	= '\152'
  let lgry	= '\155'
  (* charset selection *)
  let rvson	= '\018'	(* reverse mode on *)
  let rvsoff	= '\146'	(* reverse mode off *)
  let swon	= '\009'	(* enable charset switching *)
  let swoff	= '\008'	(* disable charset switching *)
  let lcase	= '\014'	(* select lower/upper charset *)
  let ucase	= '\142'	(* select upper/graph charset *)
  (* function keys *)
  let f1	= '\133'
  let f2	= '\137'
  let f3	= '\134'
  let f4	= '\138'
  let f5	= '\135'
  let f6	= '\139'
  let f7	= '\136'
  let f8	= '\140'
  (* other keys *)
  let stop	= '\003'
  let run	= '\131'	(* shift + run/stop *)
  let cr	= '\013'
  let home	= '\019'
  let clr	= '\147'	(* shift + clr/home *)
  let del	= '\020'
  let inst	= '\148'	(* shift + inst/del *)
  let shf_spc	= '\160'	(* shift + space bar *)
  let shf_ret	= '\141'	(* shift + return *)
  let ctl_larr	= '\006'	(* control + left arrow *)
  let ctl_uarr	= '\030'	(* control + up arrow *)
  let ctl_pound = '\028'	(* control + pound *)
  let nul	= '\000'
end

module CommonGlyph = struct
  (* 1px-wide lines: underscore/upperscore *)
  let under	= '\164'
  let upper	= '\163'
  (* 2px-wide lines: (b)ottom/(c)entre/(t)op, (h)orizontal *)
  let bhl	= '\175'
  let chl	= '\192'
  let thl	= '\183'
  (* 2px-wide lines: (l)eft/(c)enter/(r)ight, (v)ertical *)
  let lvl	= '\165'
  let lvl_	= '\180' (* same glyph, different code *)
  let cvl	= '\221'
  let rvl	= '\167'
  let rvl_	= '\170' (* same glyph, different code *)
  (* blocks: (b)ottom/(t)op/(l)eft/(r)ight, no. = width in px *)
  let tb1	= upper
  let tb2	= thl
  let tb3	= '\184'
  let bb1	= under
  let bb2	= bhl
  let bb3	= '\185'
  let bb4	= '\162'
  let lb2	= lvl
  let lb3	= '\181'
  let lb4	= '\161'
  let rb2	= rvl
  let rb3	= '\182'
  (* corners: (t)op/(b)ottom, (l)eft/(r)ight *)
  let tlc	= '\176'
  let trc 	= '\174'
  let blc	= '\173'
  let brc	= '\189'
  (* T-junctions: (u)p/(d)own/(l)eft/(r)ight pointing *)
  let utj	= '\177'
  let dtj	= '\178'
  let ltj	= '\179'
  let rtj	= '\171'
  (* four-way junction, the big + *)
  let fwj	= '\219'
  (* quadrants: (t)op/(b)ottom, (l)eft/(r)ight *)
  let tlq	= '\190'
  let trq	= '\188'
  let blq	= '\187'
  let brq	= '\172'
  let tlbrq	= '\191'
  (* shades: full, (b)ottom-half, (l)eft-half *)
  let shd	= '\166'
  let bshd	= '\168'
  let lshd	= '\220'
  (* misc *)
  let pound	= '\092'	(* British Pound sign *)
  let uarr	= '\094'	(* upwards arrow *)
  let larr	= '\095'	(* leftwards arrow *)
end

module UcaseGlyph = struct
  include CommonGlyph
  (* card suits *)
  let spd	= '\193'
  let hea	= '\211'
  let clb	= '\216'
  let dmd	= '\218'
  (* 2px-wide lines: (h)orizontal, no. = dist. from bottom, in px *)
  let hl0	= bhl
  let hl1	= '\210'
  let hl2	= '\198'
  let hl3	= chl
  let hl4	= '\196'
  let hl5	= '\197'
  let hl6	= thl
  (* 2px-wide lines: (v)ertical, no. = dist. from left, in px *)
  let vl0	= lvl
  let vl1	= '\212'
  let vl2	= '\199'
  let vl3	= cvl
  let vl4	= '\200'
  let vl5	= '\217'
  let vl6	= rvl
  (* edge corners *)
  let tlec	= '\207'
  let trec	= '\208'
  let blec	= '\204'
  let brec	= '\250'
  (* rounded corners *)
  let tlrc	= '\213'
  let trrc	= '\201'
  let blrc	= '\202'
  let brrc	= '\203'
  (* triangles *)
  let tlt	= '\169'
  let trt	= '\223'
  (* diagonals: \=from (t)op(l)eft corner, /=from (b)ottom(l)eft corner *)
  let tld	= '\206'
  let bld	= '\205'
  let cross	= '\214'
  (* circular glyphs *)
  let circ	= '\209'
  let ring	= '\215'
  (* misc *)
  let pi	= '\222'
end

module LcaseGlyph = struct
  include CommonGlyph
  (* shades: (r)everse, or diagonal: from (t)op/(b)ottom left corner *)
  let rshd	= '\222'
  let tlshd	= '\169'
  let blshd	= '\223'
  (* misc *)
  let check	= '\186'
end

module UcaseChar = struct
  include CtlChar
  include CommonGlyph
  include UcaseGlyph
end

module LcaseChar = struct
  include CtlChar
  include CommonGlyph
  include LcaseGlyph
end

include CtlChar
include CommonGlyph
include UcaseGlyph
include LcaseGlyph

let cbm ch =
  let shifted = [| tlc; tlbrq; trq; brq; utj; blq; lvl; lvl_; bb4; lb3; lb4;
                   rb3; rvl; rvl_; bb3; bhl; rtj; dtj; trc; tb1; tb3; tlq; ltj;
                   brc; thl; blc |] in
  match ch with
  (* cbm+key *)
  | 'A' .. 'Z' -> let idx = Char.(code ch - code 'A') in shifted.(idx)
  | 'a' .. 'z' -> let idx = Char.(code ch - code 'a') in shifted.(idx)
  | '1' -> org
  | '2' .. '8' -> Char.(chr (149 + code ch - code '2'))
  | '*' -> trt (* = blshd *)
  | '+' -> shd
  | '-' -> lshd
  | '@' -> under
  | '\163' (* Pound *) -> bshd
  | _ -> failwith "Petscii.cbm"

let ctl ch = match ch with
  (* control+key *)
  | 'A' .. 'Z' -> Char.(chr (1 + code ch - code 'A'))
  | 'a' .. 'z' -> Char.(chr (1 + code ch - code 'a'))
  | '0' .. '9' -> let i = Char.(code ch - code '0') in
                  [|rvsoff; blk; wht; red; cyn; pur; grn; blu; yel; rvson|].(i)
  | ':' -> '\027'
  | '\163' (* Pound *) -> red
  | ';' -> rt
  | '=' -> blu
  | '@' -> nul
  | '^' -> grn		(* ctl + up arrow   = ctl + 6 *)
  | '_' -> '\006'	(* ctl + left arrow = ctl + F *)
  | _ -> failwith "Petscii.ctl"

let of_char ch = match ch with
  | 'A' .. 'Z' -> Char.(chr (code ch + 0x80))	(* 65..90 -> 193..218 *)
  | 'a' .. 'z' -> Char.(chr (code ch - 0x20))	(* 97..122 -> 65..90 *)
  | '_' -> under				(* 95 -> 164 *)
  | '|' -> cvl		  			(* 124 -> 221 *)
  | '\163' (* Pound *) -> pound  		(* 163 -> 92 *)
  | _ -> ch

let token_ht =
  Hashtbl.of_seq
    (List.to_seq
       [ (* --- Petscii.CommonGlyph --- *)
         (* 1px-wide lines *)
         ("{UNDER}", under); ("{UPPER}", upper);
         (* 2px-wide lines *)
         ("{BHL}", bhl); ("{CHL}", chl); ("{THL}", thl); ("{LVL}", lvl);
         ("{CVL}", cvl); ("{RVL}", rvl);
         (* blocks *)
         ("{TB1}", tb1); ("{TB2}", tb2); ("{TB3}", tb3); ("{BB1}", bb1);
         ("{BB2}", bb2); ("{BB3}", bb3); ("{BB4}", bb4); ("{LB2}", lb2);
         ("{LB3}", lb3); ("{LB4}", lb4); ("{RB2}", rb2); ("{RB3}", rb3);
         (* corners *)
         ("{TLC}", tlc); ("{TRC}", trc); ("{BLC}", blc); ("{BRC}", brc);
         (* T-junctions & four-way junction*)
         ("{UTJ}", utj); ("{DTJ}", dtj); ("{LTJ}", ltj); ("{RTJ}", rtj);
         ("{FWJ}", fwj);
         (* quadrants *)
         ("{TLQ}", tlq); ("{TRQ}", trq); ("{BLQ}", blq); ("{BRQ}", brq);
         ("{TLBRQ}", tlbrq);
         (* shades *)
         ("{SHD}", shd); ("{BSHD}", bshd); ("{LSHD}", lshd);
         (* misc *)
         ("{POUND}", pound); ("{UARR}", uarr); ("{LARR}", larr);
         
         (* --- Petscii.UcaseGlyph --- *)
         (* card suits *)
         ("{SPD}", spd); ("{HEA}", hea); ("{CLB}", clb); ("{DMD}", dmd);
         (* 2px-wide lines *)
         ("{HL0}", hl0); ("{HL1}", hl1); ("{HL2}", hl2); ("{HL3}", hl3);
         ("{HL4}", hl4); ("{HL5}", hl5); ("{HL6}", hl6); ("{VL0}", vl0);
         ("{VL1}", vl1); ("{VL2}", vl2); ("{VL3}", vl3); ("{VL4}", vl4);
         ("{VL5}", vl5); ("{VL6}", vl6);
         (* edge corners *)
         ("{TLEC}", tlec); ("{TREC}", trec); ("{BLEC}", blec);
         ("{BREC}", brec);
         (* rounded corners *)
         ("{TLRC}", tlrc); ("{TRRC}", trrc); ("{BLRC}", blrc);
         ("{BRRC}", brrc);
         (* triangles *)
         ("{TLT}", tlt); ("{TRT}", trt);
         (* diagonals *)
         ("{TLD}", tld); ("{BLD}", bld); ("{CROSS}", cross);
         (* circular glyphs *)
         ("{CIRC}", circ); ("{RING}", ring);
         (* misc *)
         ("{PI}", pi);
         
         (* --- Petscii.LcaseGlyph --- *)
         (* shades *)
         ("{RSHD}", rshd); ("{TLSHD}", tlshd); ("{BLSHD}", blshd);
         (* misc *)
         ("{CHECK}", check);
         
         (* --- Petscii.CtlChar --- *)
         (* cursor movements *)
         ("{UP}", up); ("{DN}", dn); ("{LF}", lf); ("{RT}", rt);
         (* colours *)
         ("{BLK}", blk); ("{WHT}", wht); ("{RED}", red); ("{CYN}", cyn);
         ("{PUR}", pur); ("{GRN}", grn); ("{LGRN}", lgrn); ("{BLU}", blu);
         ("{LBLU}", lblu); ("{YEL}", yel); ("{ORG}", org); ("{BRN}", brn);
         ("{LRED}", lred); ("{PNK}", pnk); ("{DGRY}", dgry); ("{MGRY}", mgry);
         ("{LGRY}", lgry);
         (* charset selection *)
         ("{RVSON}", rvson); ("{RVSOFF}", rvsoff); ("{SWON}", swon);
         ("{SWOFF}", swoff); ("{LCASE}", lcase); ("{UCASE}", ucase);
         (* function keys *)
         ("{F1}", f1); ("{F2}", f2); ("{F3}", f3); ("{F4}", f4); ("{F5}", f5);
         ("{F6}", f6); ("{F7}", f7); ("{F8}", f8);
         (* other keys *)
         ("{STOP}", stop); ("{RUN}", run); ("{CR}", cr); ("{HOME}", home);
         ("{CLR}", clr); ("{DEL}", del); ("{INST}", inst);
         ("{SHF-SPC}", shf_spc); ("{SHF-RET}", shf_ret);
         ("{CTL-LARR}", ctl_larr); ("{CTL-UARR}", ctl_uarr);
         ("{CTL-POUND}", ctl_pound);
         (* misc *)
         ("{NUL}", nul)
    ])

let of_token token =
  try Hashtbl.find token_ht token with Not_found ->
    if String.length token = 7 && token.[6] = '}' then
      match String.sub token 0 5 with
      | "{CTL-" -> ctl token.[5]
      | "{CBM-" -> cbm token.[5]
      | _ -> failwith "Petscii.of_token"
    else failwith "Petscii.of_token"

let of_string str =
  let valid_str_regexp = Str.regexp {|^\([^{}]*{[^{}]+}\)*[^{}]*$|} in
  let token_regexp = Str.regexp {|{[^{}]+}|} in
  if Str.string_match valid_str_regexp str 0 then
    str
    |> Str.global_substitute
         token_regexp
         (fun _ -> String.make 1 (of_token (Str.matched_string str)))
    |> String.map of_char
  else failwith "Petscii.of_string"
