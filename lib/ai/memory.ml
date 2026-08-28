type knowledge = {
  pair_id : int;
  confidence : float;   (* 0.0-1.0 decays over turns *)
}

type t = {
  known : (int, knowledge) Hashtbl.t;   (* index -> knowledge *)
  mutable turn_count : int;
}

let create () =
  { known = Hashtbl.create 32; turn_count = 0 }

let remember t ~index ~pair_id =
  Hashtbl.replace t.known index
    { pair_id; confidence = 1.0 }

let forget t index = Hashtbl.remove t.known index

let forget_matched t indices =
  List.iter (fun i -> forget t i) indices

(** Memory decays - lower AI difficulty forgets faster. *)
let decay t ~retention =
  let drop = ref [] in
  Hashtbl.iter (fun i k ->
    let c = k.confidence *. retention in
    if c < 0.05 then drop := i :: !drop
    else Hashtbl.replace t.known i { k with confidence = c })
    t.known;
  List.iter (fun i -> Hashtbl.remove t.known i) !drop

let next_turn t = t.turn_count <- t.turn_count + 1

let known_pair t =
  (* find two known indices sharing a pair_id *)
  let by_pair = Hashtbl.create 16 in
  Hashtbl.iter (fun i k ->
    match Hashtbl.find_opt by_pair k.pair_id with
    | None -> Hashtbl.add by_pair k.pair_id [ i ]
    | Some l -> Hashtbl.replace by_pair k.pair_id (i :: l))
    t.known;
  Hashtbl.fold (fun _ v acc ->
    match acc with
    | Some _ -> acc
    | None -> if List.length v >= 2 then Some v else None)
    by_pair None

let known_indices t =
  Hashtbl.fold (fun i _ acc -> i :: acc) t.known []

let memory_size t = Hashtbl.length t.known

let find_pair_id t index =
  match Hashtbl.find_opt t.known index with
  | Some k -> Some k.pair_id
  | None -> None

(** Find a known index (other than [exclude]) remembered with the
    given [pair_id]. *)
let find_partner t ~exclude ~pair_id =
  Hashtbl.fold (fun i k acc ->
    match acc with
    | Some _ -> acc
    | None -> if i <> exclude && k.pair_id = pair_id then Some i else None)
    t.known None
