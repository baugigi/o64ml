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
  let run	= '\131'	(* shift+run/stop *)
  let ret	= '\013'
  let shret	= '\141'	(* shift+return *)
  let home	= '\019'
  let clr	= '\147'	(* shift+clr/home *)
  let del	= '\020'
  let inst	= '\148'	(* shift+inst/del *)
  let shspc	= '\160'	(* shift+space *)
  let nul	= '\000'

  let cbm = function
    (* cbm+key *)
    | '1' -> '\129'
    | '2' .. '8' as ch -> Char.(chr (149 + code ch - code '2'))
    | bad_ch -> invalid_arg "Petscii.CtlChar.cbm"

  let ctl = function
    (* control+key *)
    | 'A' .. 'Z' as ch -> Char.(chr (1 + code ch - code 'A'))
    | 'a' .. 'z' as ch -> Char.(chr (1 + code ch - code 'a'))
    | '0' .. '9' as ch ->
       let i = Char.(code ch - code '0') in
       [| rvsoff; blk; wht; red; cyn; pur; grn; blu; yel; rvson |].(i)
    | ':' -> '\027'
    | ';' -> '\029'
    | '=' -> '\031'
    | '@' -> '\000'
    | '\163' (* ASCII *) | '\156' (* PETSCII *) ->
       '\028' (* control + British Pound sign *)
    | '^' -> '\030'
    | '\095' -> '\006' (* control + left arrow *)
    | bad -> invalid_arg ("Petscii.CtlChar.ctl: '" ^ String.make 1 bad ^ "'")

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
  let cvl	= '\221'
  let rvl	= '\170'
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
  let sh	= '\166'
  let bsh	= '\168'
  let lsh	= '\220'
  (* misc *)
  let pound	= '\156'	(* British Pound sign *)
  let uarr	= '^'		(* upwards arrow *)
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
  (* shades: (r)everse, diagonal *)
  let rsh	= '\255'
  let tlsh	= '\169'
  let blsh	= '\223'
  (* misc *)
  let check	= '\250'
end

include CtlChar
include UcaseGlyph
include LcaseGlyph

let of_char = function
  | 'A' .. 'Z' as ch -> Char.(chr (code ch + 0x80))
  | 'a' .. 'z' as ch -> Char.(chr (code ch - 0x20))
  | '_' -> under
  | '|' -> cvl
  | '\163' -> pound
  | ch -> ch

let token_ht =
  Hashtbl.of_seq
    (List.to_seq
     (List.map (fun (k, v) -> String.map of_char k, v)
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
         ("{SH}", sh); ("{BSH}", bsh); ("{LSH}", lsh);
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
         ("{RSH}", rsh); ("{TLSH}", tlsh); ("{BLSH}", blsh);
         (* misc *)
         ("{CHECK}", check);
         (* --- Petscii.CtlChar --- *)
         (* cursor movements *)
         ("{UP}", up); ("{DN}", dn); ("{LF}", lf); ("{RT}", rt);
         (* colours *)
         ("{BLK}", blk); ("{WHT}", wht); ("{RED}", red); ("{CYN}", cyn);
         ("{PUR}", pur); ("{GRN}", grn); ("{LGRN}", lgrn); ("{BLU}", blu);
         ("{LBLU}", lblu); ("{YEL}", yel); ("{ORG}", org); ("{BRN}", brn);
         ("{LRED}, lred); ({PNK}", pnk); ("{DGRY}", dgry); ("{MGRY}", mgry);
         ("{LGRY}", lgry);
         (* charset selection *)
         ("{RVSON}", rvson); ("{RVSOFF}", rvsoff); ("{SWON}", swon);
         ("{SWOFF}", swoff); ("{LCASE}", lcase); ("{UCASE}", ucase);
         (* function keys *)
         ("{F1}", f1); ("{F2}", f2); ("{F3}", f3); ("{F4}", f4); ("{F5}", f5);
         ("{F6}", f6); ("{F7}", f7); ("{F8}", f8);
         (* other keys *)
         ("{STOP}", stop); ("{RUN}", run); ("{RET}", ret); ("{SHRET}", shret);
         ("{HOME}", home); ("{CLR}", clr); ("{DEL}", del); ("{INST}", inst);
         ("{SHSPC}", shspc);
         (* control+key & cbm+key combinations *)
         ("{CTLPOUND}", ctl pound); ("{CTLUARR}", ctl uarr);
         ("{CTLLARR}", ctl larr);
         (* misc *)
         ("{NUL}", nul)
    ]))

let of_token token =
  try Hashtbl.find token_ht token with Not_found ->
    if String.length token = 6 && token.[5] = '}' then
      match String.sub token 0 3 with
      | "{CTL" -> ctl (token.[4])
      | "{CBM" -> cbm (token.[4])
      | _ -> invalid_arg "petscii_of_token"
    else invalid_arg "petscii_of_token"

let of_string str =
  let valid_str_regexp = Str.regexp {|^\([^{}]*{[^{}]+}\)*[^{}]*$|} in
  let token_regexp = Str.regexp {|{[^{}]+}|} in
  let str' = String.map of_char str in
  if Str.string_match valid_str_regexp str' 0 then
    Str.global_substitute
      token_regexp
      (fun _ -> String.make 1 (of_token (Str.matched_string str')))
      str'
  else invalid_arg "petsciify_string"
