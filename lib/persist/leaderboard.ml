type entry = {
  player : string;
  score : int;
  time_ms : int;
  difficulty : string;
  mode : string;
  date : string;
  seed : int;
}

exception Corrupted of string

let sanitize s =
  let s = String.map (fun c -> if c = '|' then '_' else c) s in
  let s = String.map (fun c -> if c = '\n' then ' ' else c) s in
  if String.length s > 24 then String.sub s 0 24 else s

let encode e =
  Printf.sprintf "%s|%d|%d|%s|%s|%s|%d"
    (sanitize e.player) e.score e.time_ms
    (sanitize e.difficulty) (sanitize e.mode) (sanitize e.date) e.seed

let decode line =
  match String.split_on_char '|' line with
  | [ player; score; time_ms; difficulty; mode; date; seed ] ->
      let int_or k s =
        match int_of_string_opt s with
        | Some i -> i
        | None -> raise (Corrupted ("bad int in " ^ k)) in
      { player; score = int_or "score" score;
        time_ms = int_or "time" time_ms;
        difficulty; mode; date;
        seed = int_or "seed" seed }
  | _ -> raise (Corrupted "bad leaderboard line")

let load () =
  match Store.read_file Store.leaderboard_path with
  | None -> []
  | Some content ->
      String.split_on_char '\n' content
      |> List.filter (fun l -> l <> "")
      |> List.filter_map (fun l ->
          try Some (decode l) with Corrupted _ -> None)

let save entries =
  Store.write_file Store.leaderboard_path
    (String.concat "\n" (List.map encode entries) ^ "\n")

let better a b = a.score > b.score

let take n l =
  let rec aux n l = match l with
    | [] -> []
    | x :: r -> if n <= 0 then [] else x :: aux (n - 1) r
  in
  aux n l

let add entry =
  let entries = load () in
  let entries = entry :: entries in
  let entries = List.sort (fun a b -> compare b.score a.score) entries in
  let entries = if List.length entries > 100 then take 100 entries else entries in
  save entries;
  List.mapi (fun i e -> (i + 1, e)) entries
  |> List.find_opt (fun (_, e) -> e = entry)
  |> Option.map fst

let top ?(limit = 10) ?mode ?difficulty () =
  load ()
  |> List.filter (fun e ->
      (match mode with Some m -> e.mode = m | None -> true)
      && (match difficulty with Some d -> e.difficulty = d | None -> true))
  |> take limit
