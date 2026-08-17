
let x = 0.999999999;;
let y = 0.9999999999;;
let z = 1.7014118344E38;;
let s="ABC";;
type r = {s:string; x:float; y:float; z:float};;
let mio = {s=s;x=x;y=y;z=z} in print_string mio.s;;
