# CardMatch 2.0

A terminal memory-matching game written in OCaml, with a pure/testable
core engine and an imperative terminal (TUI) shell.

## Features
- 5 difficulty presets (Easy -> Extreme) plus custom board sizes
- 7 game modes: Classic, Time Attack, Perfect, Blitz, Zen, Streak, Daily Challenge
- Combo-based scoring with difficulty multipliers
- Deterministic seeded boards (daily challenges are the same board for everyone)
- An AI opponent with 4 memory/skill levels (Easy/Normal/Hard/Expert)
- Local leaderboard, lifetime statistics, save & resume
- ANSI terminal UI with keyboard navigation and 4 selectable themes

## Requirements
- OCaml >= 4.14
- dune >= 3.0
- the `unix` findlib library (ships with the OCaml standard distribution)

No opam packages are required — everything here is written against the
stdlib + Unix, on purpose, so it builds anywhere a bare OCaml + dune
toolchain is available (e.g. `apt install ocaml-nox ocaml-dune` on Debian/Ubuntu).

## Build & run
```
dune build
dune exec bin/main.exe
```

## Run the tests
```
dune test
```
This runs a small hand-rolled assertion suite (`lib/test/test_core.ml`)
covering board generation/determinism, the flip/match state machine,
scoring, the countdown timer, and the AI's memory.

## Controls
- Arrow keys — move the cursor
- `Enter` — flip the selected card
- `H` — use a hint (costs points, disabled in Perfect mode)
- `P` — pause (resume / save & exit / restart / main menu)
- `R` — restart the current board
- `Q` — quit to the main menu

## Architecture
```
lib/core    - pure engine: Card, Rng, Difficulty, Board, Game_mode,
              Timer, Scoring, Game, Statistics. Zero I/O dependencies.
lib/ui      - terminal rendering, themes, raw-mode input, menus.
lib/ai      - AI opponent: bounded memory with decay + mistake rate.
lib/persist - save file, leaderboard, and stats file storage
              (plain-text formats, no external deps).
lib/test    - test suite.
bin/        - the executable shell (game loop, timing, menus).
```

Save data, stats, and the leaderboard are stored under
`$XDG_DATA_HOME/cardmatch` (or `~/.local/share/cardmatch` if
`XDG_DATA_HOME` isn't set).

## Notes on this build
This project was reconstructed from a multi-turn AI chat transcript that
built it in pieces and, by its own admission mid-transcript, left several
things broken (a syntactically invalid `hint_pair`, a `Memory` module whose
internals `Ai_player` reached into directly despite them being abstracted
away in `memory.mli`, a raw-mode terminal reader built around a fragile
`stty ... </dev/tty` shell-out, a corrupted string literal in the renderer,
an `Input.with_raw`-adjacent `unescape` that called `String.split_on_char`
with a 2-character string instead of a `char`, and a `bin/main.ml` with
unclosed parens and a call to an undefined placeholder function). All of
that has been fixed here, and the result has been compiled and exercised
end-to-end (menus, board rendering, flipping, matching, scoring) inside a
real pseudo-terminal, plus a passing test suite, before being packaged.
