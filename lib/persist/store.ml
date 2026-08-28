let data_dir () =
  match Sys.getenv_opt "XDG_DATA_HOME" with
  | Some d -> Filename.concat d "cardmatch"
  | None ->
      (match Sys.getenv_opt "HOME" with
       | Some h -> Filename.concat h ".local/share/cardmatch"
       | None -> ".cardmatch")

let ensure_dir () =
  let d = data_dir () in
  if not (Sys.file_exists d) then Unix.mkdir d 0o755

let read_file path =
  try
    let ic = open_in_bin path in
    let n = in_channel_length ic in
    let s = really_input_string ic n in
    close_in ic;
    Some s
  with Sys_error _ -> None

let write_file path content =
  ensure_dir ();
  let oc = open_out_bin path in
  output_string oc content;
  close_out oc

let delete_file path =
  if Sys.file_exists path then Sys.remove path

let file_exists path = Sys.file_exists path

let save_path = Filename.concat (data_dir ()) "save.txt"
let stats_path = Filename.concat (data_dir ()) "stats.txt"
let leaderboard_path = Filename.concat (data_dir ()) "leaderboard.txt"
let config_path = Filename.concat (data_dir ()) "config.txt"
