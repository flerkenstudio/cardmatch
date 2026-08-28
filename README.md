# CardMatch 2.0

A terminal-based memory-matching game built with **OCaml + Dune**, featuring a pure/testable game engine and terminal UI.

## ✨ Features

- 5 difficulty presets + custom board sizes
- 7 modes: Classic, Time Attack, Perfect, Blitz, Zen, Streak, Daily Challenge
- Combo scoring + difficulty multipliers
- Deterministic seeded boards
- Daily Challenge with the same board for everyone
- AI opponent with Easy, Normal, Hard, and Expert levels
- Local leaderboard and lifetime statistics
- Save & resume
- 4 terminal themes
- Keyboard navigation

## 🛠️ Requirements

- OCaml >= 4.14
- Dune >= 3.0
- Unix library

The application uses the OCaml standard library + Unix and has no runtime external dependencies.

## 🚀 GitHub Codespaces / Ubuntu Setup

Run these commands in the terminal:

```bash
sudo apt update
sudo apt install -y opam
opam init -y
eval $(opam env)
opam install -y dune alcotest
```

### Build

```bash
dune build
```

### Test

```bash
dune test
```

### Run

```bash
dune exec bin/main.exe
```

### ⚡ One-Command Setup

```bash
sudo apt update && sudo apt install -y opam && opam init -y && eval $(opam env) && opam install -y dune alcotest && dune build && dune test && dune exec bin/main.exe
```

## 🎮 Controls

| Key | Action |
|---|---|
| Arrow Keys | Move cursor |
| Enter | Flip card |
| H | Hint |
| P | Pause |
| R | Restart |
| Q | Main menu |

> Hints cost points and are disabled in Perfect mode.

## 🏗️ Architecture

```text
lib/core    → Pure game engine
lib/ui      → Terminal UI, themes, input, menus
lib/ai      → AI opponent
lib/persist  → Saves, leaderboard, statistics
lib/test    → Test suite
bin/        → Main executable
```

## 💾 Data

Save data, statistics, and leaderboard are stored in:

```text
$XDG_DATA_HOME/cardmatch
```

or, by default:

```text
~/.local/share/cardmatch
```

## ☕ Support the Project

Enjoying CardMatch 2.0? Support development with a coffee:

👉 **[Buy Me a Coffee — flerken](https://buymeacoffee.com/flerken)**

## 📄 License

See the repository license for the applicable terms.

---

**CardMatch 2.0 — Built with OCaml + Dune. 🃏☕**
