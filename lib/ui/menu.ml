let render_menu ~title ~items ~selected =
  let b = Buffer.create 512 in
  Buffer.add_string b "================================================\n";
  Buffer.add_string b (Printf.sprintf " %s\n" (Ansi.wrap Ansi.cyan title));
  Buffer.add_string b "================================================\n";
  List.iteri (fun i item ->
    let marker = if i = selected then ">" else " " in
    let line = Printf.sprintf "  %s %s" marker item in
    let line =
      if i = selected then Ansi.wrap Ansi.yellow line else line
    in
    Buffer.add_string b (Renderer.pad_to line 46 ^ "\n"))
    items;
  Buffer.add_string b "================================================\n";
  Buffer.add_string b "  Up/Down Navigate   ENTER Select   Q Quit\n";
  Buffer.contents b

(** Run a menu; returns index of chosen item, or None if quit. *)
let run ~title ~items =
  let selected = ref 0 in
  let quit = ref false in
  let result = ref None in
  let n = List.length items in
  Input.with_raw (fun () ->
    while not !quit && !result = None do
      Ansi.clear ();
      print_string (render_menu ~title ~items ~selected:!selected);
      flush stdout;
      match Input.read_key () with
      | Input.Up -> selected := (!selected + n - 1) mod n
      | Input.Down -> selected := (!selected + 1) mod n
      | Input.Enter -> result := Some !selected
      | Input.Char ('q' | 'Q') | Input.Eof -> quit := true
      | _ -> ()
    done);
  !result
