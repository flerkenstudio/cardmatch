type t = { id : int; pair_id : int }

let make ~id ~pair_id = { id; pair_id }
let id c = c.id
let pair_id c = c.pair_id
let equal a b = a.pair_id = b.pair_id
let compare a b = compare a.id b.id
