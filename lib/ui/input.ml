exception Not_a_tty

let with_raw f =
  try
    let old = Unix.tcgetattr Unix.stdin in
    let raw = { old with
                Unix.c_icanon = false;
                c_echo = false;
                c_vmin = 1;
                c_vtime = 0 } in
    Unix.tcsetattr Unix.stdin Unix.TCSANOW raw;
    Fun.protect
      ~finally:(fun () -> Unix.tcsetattr Unix.stdin Unix.TCSANOW old)
      f
  with Unix.Unix_error _ -> raise Not_a_tty

type key =
  | Up | Down | Left | Right
  | Enter
  | Char of char
  | Escape
  | Eof

let read_key () =
  match (try Some (input_char stdin) with End_of_file -> None) with
  | None -> Eof
  | Some '\027' ->
      (match (try Some (input_char stdin) with End_of_file -> None) with
       | Some '[' ->
           (match (try Some (input_char stdin) with End_of_file -> None) with
            | Some 'A' -> Up | Some 'B' -> Down
            | Some 'C' -> Right | Some 'D' -> Left
            | Some c -> Char c
            | None -> Escape)
       | Some c -> Char c
       | None -> Escape)
  | Some ('\n' | '\r') -> Enter
  | Some ('\004' | '\003') -> Eof
  | Some c -> Char c
