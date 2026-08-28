type t = {
  mutable running : bool;
  mutable elapsed_ms : int;
  limit_ms : int option;   (* None = count up, e.g. Classic/Zen *)
}

let make ?limit_s () =
  { running = false; elapsed_ms = 0;
    limit_ms = Option.map (fun s -> s * 1000) limit_s }

let start t = t.running <- true
let pause t = t.running <- false
let resume t = t.running <- true
let stop t = t.running <- false

let tick t ms = if t.running then t.elapsed_ms <- t.elapsed_ms + ms

let elapsed_ms t = t.elapsed_ms

let remaining_ms t =
  match t.limit_ms with
  | None -> None
  | Some l -> Some (max 0 (l - t.elapsed_ms))

let expired t =
  match remaining_ms t with
  | Some r when r = 0 && t.limit_ms <> None -> true
  | _ -> false

let is_running t = t.running

let format_ms ms =
  let total_s = ms / 1000 in
  Printf.sprintf "%02d:%02d" (total_s / 60) (total_s mod 60)
