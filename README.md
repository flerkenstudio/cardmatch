# CardMatch

A terminal memory / concentration card game in OCaml, built as a **functional core + imperative shell**:

- `lib/game.ml` — pure game logic (no I/O, no hidden mutation)
- `lib/game.mli` — the module interface; `state` is abstract
- `bin/main.ml` — the game loop, printing and stdin parsing
- `lib/test/test_game.ml` — Alcotest unit tests

## Build & run

```bash
opam install dune alcotest
dune build
dune test
dune exec bin/main.exe
```

## Design notes

- **Immutability.** `reveal` and `play_turn` never mutate their argument; they
  `Array.copy` first and return a new board/state. Tests assert this.
- **Abstract state.** `game.mli` exposes `type state` with no constructor, so
  `attempts` and `pairs_found` can only change through `play_turn` and can
  never drift out of sync with the board. `cell` stays concrete because the
  renderer and the tests pattern match on it.
- **Seeded shuffle.** `make_board rows cols seed` uses Fisher–Yates over a
  `Random.State.t` built from the seed, so the same seed always gives the same
  board — that is what makes the shuffle testable.
- **Total pattern matches.** Every match on `cell` / `rank` / `suit` covers all
  constructors, so adding a rank is a compile error, not a runtime bug.

## Rules

Cards match on **rank** (Ace–Ten), suits are cosmetic; each board has two copies
of each chosen rank. Pick two indices per turn: match → `**`, miss → back to `??`.

## What I learned

Algebraic data types and exhaustive pattern matching, immutable updates,
module design with `.mli` files, and unit testing with Alcotest.
