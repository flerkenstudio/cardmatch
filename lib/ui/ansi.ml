(* minimal ANSI helpers *)
let reset = "\027[0m"
let bold s = "\027[1m" ^ s ^ reset
let red s = "\027[31m" ^ s ^ reset
let green s = "\027[32m" ^ s ^ reset
let yellow s = "\027[33m" ^ s ^ reset
let blue s = "\027[34m" ^ s ^ reset
let magenta s = "\027[35m" ^ s ^ reset
let cyan s = "\027[36m" ^ s ^ reset

let color_enabled = ref true

let wrap f s = if !color_enabled then f s else s

let clear () = print_string "\027[2J\027[H"
let hide_cursor () = print_string "\027[?25l"
let show_cursor () = print_string "\027[?25h"
