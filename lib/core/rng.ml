type t = { mutable s : int64 }

let create seed =
  { s = Int64.of_int (if seed <= 0 then 88172645463325252 + seed else seed) }

let next64 t =
  let x = t.s in
  let x = Int64.logxor x (Int64.shift_left x 13) in
  let x = Int64.logxor x (Int64.shift_right_logical x 7) in
  let x = Int64.logxor x (Int64.shift_left x 17) in
  t.s <- x;
  x

(* uniform in [0, n) *)
let int t n =
  if n <= 1 then 0
  else Int64.to_int (Int64.logand (next64 t) 0x7FFFFFFFL) mod n

let bool t = int t 2 = 0

let float t =
  Int64.to_float (Int64.logand (next64 t) 0xFFFFFFFFFFFFFL)
  /. 4503599627370496.0
