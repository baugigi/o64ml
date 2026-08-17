
let f = function
  | `A | `B | `C | `D | `E | `F | `G | `H | `I | `J | `K | `L | `M
  | `N | `O | `P | `Q | `R | `S | `T | `U | `V | `W | `X | `Y | `Z -> 0
  | `A' | `A0 | `A1 | `A2 | `A3 | `A4 | `A5 | `A6 | `A7 | `A8 | `A9
  | `AA | `AB | `AC | `AD | `AE | `AF | `AG | `AH | `AI | `AJ | `AK
  | `AL | `AM | `AN | `AO | `AP | `AQ | `AR | `AS | `AT | `AU | `AV
  | `AW | `AX | `AY | `AZ | `A_ | `Aa | `Ab | `Ac | `Ad | `Ae | `Af
  | `Ag | `Ah | `Ai | `Aj | `Ak | `Al | `Am | `An | `Ao | `Ap | `Aq
  | `Ar | `As | `At | `Au | `Av | `Aw | `Ax | `Ay | `Az -> 1
  | `B' | `B0 | `B1 | `B2 | `B3 | `B4 | `B5 | `B6 | `B7 | `B8 | `B9
  | `BA | `BB | `BC | `BD | `BE | `BF | `BG | `BH | `BI | `BJ | `BK
  | `BL | `BM | `BN | `BO | `BP | `BQ | `BR | `BS | `BT | `BU | `BV
  | `BW | `BX | `BY | `BZ | `B_ | `Ba | `Bb | `Bc | `Bd | `Be | `Bf
  | `Bg | `Bh | `Bi | `Bj | `Bk | `Bl | `Bm | `Bn | `Bo | `Bp | `Bq
  | `Br | `Bs | `Bt | `Bu | `Bv | `Bw | `Bx | `By | `Bz -> 2
  | `C' | `C0 | `C1 | `C2 | `C3 | `C4 | `C5 | `C6 | `C7 | `C8 | `C9
  | `CA | `CB | `CC | `CD | `CE | `CF | `CG | `CH | `CI | `CJ | `CK
  | `CL | `CM | `CN | `CO | `CP | `CQ | `CR | `CS | `CT | `CU | `CV
  | `CW | `CX | `CY | `CZ | `C_ | `Ca | `Cb | `Cc | `Cd | `Ce | `Cf
  | `Cg | `Ch | `Ci | `Cj | `Ck | `Cl | `Cm | `Cn | `Co | `Cp | `Cq
  | `Cr | `Cs | `Ct | `Cu | `Cv | `Cw | `Cx | `Cy | `Cz -> 3
  | `D' | `D0 | `D1 | `D2 | `D3 | `D4 | `D5 | `D6 | `D7 | `D8 | `D9
  | `DA | `DB | `DC | `DD | `DE | `DF | `DG | `DH | `DI | `DJ | `DK
  | `DL | `DM | `DN | `DO | `DP | `DQ | `DR | `DS | `DT | `DU | `DV
  | `DW | `DX | `DY | `DZ | `D_ | `Da | `Db | `Dc | `Dd | `De | `Df
  | `Dg | `Dh | `Di | `Dj | `Dk | `Dl | `Dm | `Dn | `Do | `Dp | `Dq
  | `Dr | `Ds | `Dt | `Du | `Dv | `Dw | `Dx | `Dy | `Dz -> 4
  | `E' | `E0 | `E1 | `E2 | `E3 | `E4 | `E5 | `E6 | `E7 | `E8 | `E9
  | `EA | `EB | `EC | `ED | `EE | `EF | `EG | `EH | `EI | `EJ | `EK
  | `EL | `EM | `EN | `EO | `EP | `EQ | `ER | `ES | `ET | `EU | `EV
  | `EW | `EX | `EY | `EZ | `E_ | `Ea | `Eb | `Ec | `Ed | `Ee | `Ef
  | `Eg | `Eh | `Ei | `Ej | `Ek | `El | `Em | `En | `Eo | `Ep | `Eq
  | `Er | `Es | `Et | `Eu | `Ev | `Ew | `Ex | `Ey | `Ez -> 5
  | `F' | `F0 | `F1 | `F2 | `F3 | `F4 | `F5 | `F6 | `F7 | `F8 | `F9
  | `FA | `FB | `FC | `FD | `FE | `FF | `FG | `FH | `FI | `FJ | `FK
  | `FL | `FM | `FN | `FO | `FP | `FQ | `FR | `FS | `FT | `FU | `FV
  | `FW | `FX | `FY | `FZ | `F_ | `Fa | `Fb | `Fc | `Fd | `Fe | `Ff
  | `Fg | `Fh | `Fi | `Fj | `Fk | `Fl | `Fm | `Fn | `Fo | `Fp | `Fq
  | `Fr | `Fs | `Ft | `Fu | `Fv | `Fw | `Fx | `Fy | `Fz -> 6
  | `G' | `G0 | `G1 | `G2 | `G3 | `G4 | `G5 | `G6 | `G7 | `G8 | `G9
  | `GA | `GB | `GC | `GD | `GE | `GF | `GG | `GH | `GI | `GJ | `GK
  | `GL | `GM | `GN | `GO | `GP | `GQ | `GR | `GS | `GT | `GU | `GV
  | `GW | `GX | `GY | `GZ | `G_ | `Ga | `Gb | `Gc | `Gd | `Ge | `Gf
  | `Gg | `Gh | `Gi | `Gj | `Gk | `Gl | `Gm | `Gn | `Go | `Gp | `Gq
  | `Gr | `Gs | `Gt | `Gu | `Gv | `Gw | `Gx | `Gy | `Gz -> 7
  | `H' | `H0 | `H1 | `H2 | `H3 | `H4 | `H5 | `H6 | `H7 | `H8 | `H9
  | `HA | `HB | `HC | `HD | `HE | `HF | `HG | `HH | `HI | `HJ | `HK
  | `HL | `HM | `HN | `HO | `HP | `HQ | `HR | `HS | `HT | `HU | `HV
  | `HW | `HX | `HY | `HZ | `H_ | `Ha | `Hb | `Hc | `Hd | `He | `Hf
  | `Hg | `Hh | `Hi | `Hj | `Hk | `Hl | `Hm | `Hn | `Ho | `Hp | `Hq
  | `Hr | `Hs | `Ht | `Hu | `Hv | `Hw | `Hx | `Hy | `Hz -> 8
  | `I' | `I0 | `I1 | `I2 | `I3 | `I4 | `I5 | `I6 | `I7 | `I8 | `I9
  | `IA | `IB | `IC | `ID | `IE | `IF | `IG | `IH | `II | `IJ | `IK
  | `IL | `IM | `IN | `IO | `IP | `IQ | `IR | `IS | `IT | `IU | `IV
  | `IW | `IX | `IY | `IZ | `I_ | `Ia | `Ib | `Ic | `Id | `Ie | `If
  | `Ig | `Ih | `z_ -> 9
;;

print_int (f `z_)
