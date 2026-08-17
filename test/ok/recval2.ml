
let rec myval = (f, 1, myval)
and f _ = match myval with (_, x, _) -> x
and a = [| 1.; 2. |]
;;
let x() = f 100;;
x();;
