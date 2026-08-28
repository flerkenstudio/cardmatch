type t = {
  name : string;
  symbols : string array;   (* one face symbol per pair_id slot *)
  card_face : string;       (* shown when face-up, if symbols exhausted *)
  hidden : string;
}

let card_backs = [| "S"; "H"; "D"; "C"; "*"; "o"; "^"; "#" |]

let classic =
  { name = "Classic";
    symbols = [| "A-S"; "A-H"; "A-D"; "A-C"; "K-S"; "K-H"; "K-D"; "K-C";
                 "Q-S"; "Q-H"; "Q-D"; "Q-C"; "J-S"; "J-H"; "J-D"; "J-C";
                 "10-S"; "10-H"; "10-D"; "10-C"; "9-S"; "9-H"; "9-D"; "9-C";
                 "8-S"; "8-H"; "8-D"; "8-C"; "7-S"; "7-H"; "7-D"; "7-C" |];
    card_face = "[?]"; hidden = "??" }

let animals =
  { name = "Animals";
    symbols = [| "Dog"; "Cat"; "Pan"; "Fox"; "Frg"; "Mky"; "Lio"; "Tig";
                 "Koa"; "Rbt"; "Owl"; "Pgn"; "Trt"; "Uni"; "Bee"; "Dph";
                 "But"; "Oct"; "Dsr"; "Prt"; "Elp"; "Grf"; "Whl"; "Hdg";
                 "Sql"; "Slo"; "Otr"; "Fla"; "Wlf"; "Der"; "Cow"; "Shp" |];
    card_face = "[A]"; hidden = "??" }

let space =
  { name = "Space";
    symbols = [| "Rkt"; "Ert"; "Mon"; "Plt"; "Str"; "Sun"; "Cmt"; "Sat";
                 "Ayl"; "Gal"; "Tel"; "UFO"; "Str"; "Dst"; "Shr"; "NwM";
                 "HfM"; "FlM"; "Shr"; "Str"; "Dst"; "Spk"; "Gal"; "Crb";
                 "Dmd"; "Blu"; "Org"; "Red"; "Ylw"; "Bolt"; "Fir"; "Ice" |];
    card_face = "[*]"; hidden = "??" }

let programming =
  { name = "Programming";
    symbols = [| "OC"; "PY"; "JV"; "RS"; "GO"; "TS"; "JS"; "CX";
                 "CS"; "PH"; "RB"; "SW"; "KT"; "LU"; "HA"; "EX";
                 "ML"; "FS"; "DA"; "EL"; "ER"; "CL"; "SC"; "PL";
                 "SQ"; "HT"; "CB"; "JQ"; "WS"; "NG"; "VU"; "RX" |];
    card_face = "fn"; hidden = "??" }

let all = [ classic; animals; space; programming ]

let of_name n =
  List.find_opt (fun t -> String.lowercase_ascii t.name
                           = String.lowercase_ascii n) all

(** Symbol for a face-up card, given its [pair_id] and the board's
    total [pair_count]. *)
let symbol t ~pair_id ~pair_count =
  let n = Array.length t.symbols in
  if pair_id < n then t.symbols.(pair_id)
  else if pair_count <= n then
    (* cycle through card ranks *)
    t.symbols.(pair_id mod n)
  else Printf.sprintf "%02d" (pair_id + 1)
