# CardMatch 2.0

A terminal memory-matching game written in **OCaml**, with a pure/testable core engine and an imperative terminal (TUI) shell.

---

## ✨ Features

- 🎯 **5 difficulty presets** — Easy → Extreme
- 🧩 **Custom board sizes**
- 🎮 **7 game modes**
  - Classic
  - Time Attack
  - Perfect
  - Blitz
  - Zen
  - Streak
  - Daily Challenge
- 🔥 **Combo-based scoring**
- 📈 **Difficulty multipliers**
- 🎲 **Deterministic seeded boards**
- 📅 **Daily Challenge** — same board for everyone
- 🤖 **AI opponent**
  - Easy
  - Normal
  - Hard
  - Expert
- 🏆 **Local leaderboard**
- 📊 **Lifetime statistics**
- 💾 **Save & resume**
- 🎨 **4 selectable terminal themes**
- ⌨️ **Keyboard navigation**
- 🧪 **Pure/testable game engine**
- ⚡ **No external runtime dependencies**

---

# 🛠️ Requirements

- **OCaml >= 4.14**
- **Dune >= 3.0**
- `unix` findlib library

The project intentionally uses only the **OCaml standard library + Unix**.

No additional opam packages are required for the application itself.

This means it can be built anywhere a bare OCaml + Dune toolchain is available, such as Debian, Ubuntu, or GitHub Codespaces.

---

# 🚀 Quick Start — GitHub Codespaces / Ubuntu

If you are running **CardMatch 2.0 inside GitHub Codespaces**, open the terminal and run the following commands.

### 1. Update Ubuntu packages

```bash
sudo apt update
```

### 2. Install OPAM

```bash
sudo apt install -y opam
```

### 3. Initialize OPAM

```bash
opam init -y
```

Load the OPAM environment:

```bash
eval $(opam env)
```

### 4. Install Dune and Alcotest

```bash
opam install -y dune alcotest
```

> **Note:** CardMatch 2.0 itself does not require external opam packages at runtime. Alcotest is included in the development setup for environments where it is used for testing or future test development.

### 5. Build the project

```bash
dune build
```

### 6. Run the tests

```bash
dune test
```

### 7. Start CardMatch 2.0 🎮

```bash
dune exec bin/main.exe
```

---

# ⚡ One-Command Setup

For a fresh **GitHub Codespaces / Ubuntu** environment, you can install the development tools, build, test, and launch the game with one command:

```bash
sudo apt update && sudo apt install -y opam && opam init -y && eval $(opam env) && opam install -y dune alcotest && dune build && dune test && dune exec bin/main.exe
```

### What this command does

1. Updates the Ubuntu package list
2. Installs OPAM
3. Initializes OPAM
4. Loads the OPAM environment
5. Installs Dune and Alcotest
6. Builds CardMatch 2.0
7. Runs the test suite
8. Starts the game

---

# 🔨 Build & Run

If OCaml and Dune are already installed:

```bash
dune build
```

Run the game:

```bash
dune exec bin/main.exe
```

---

# 🧪 Run Tests

Run the complete test suite:

```bash
dune test
```

The test suite covers:

- Board generation
- Seed determinism
- Flip/match state machine
- Scoring
- Countdown timer
- AI memory
- Core game behavior

The tests are located under:

```text
lib/test/test_core.ml
```

---

# 🎮 Controls

| Key | Action |
|---|---|
| `Arrow Keys` | Move the cursor |
| `Enter` | Flip the selected card |
| `H` | Use a hint |
| `P` | Pause |
| `R` | Restart the current board |
| `Q` | Quit to the main menu |

### Hint

Using a hint costs points.

Hints are disabled in **Perfect Mode**.

### Pause Menu

Press `P` to open the pause menu.

Available options include:

- Resume
- Save & Exit
- Restart
- Main Menu

---

# 🎮 Game Modes

CardMatch 2.0 includes **7 game modes**.

### Classic

The standard memory-matching experience.

### Time Attack

Match all cards before the timer runs out.

### Perfect

Focus on achieving a perfect run.

Hints are disabled.

### Blitz

A faster and more intense version of CardMatch.

### Zen

A relaxed mode focused on playing without pressure.

### Streak

Keep making successful matches to maintain your streak.

### Daily Challenge

Play the daily seeded board.

Every player receives the same board for the challenge.

---

# 🤖 AI Opponent

CardMatch 2.0 includes an AI opponent with four skill levels:

| Level | Description |
|---|---|
| **Easy** | Limited memory and higher mistake rate |
| **Normal** | Balanced memory and mistakes |
| **Hard** | Strong memory and fewer mistakes |
| **Expert** | Advanced memory and very low mistake rate |

The AI uses:

- Bounded memory
- Memory decay
- Configurable mistake rates
- Multiple skill levels

---

# 🏆 Scoring

CardMatch 2.0 uses a combo-based scoring system.

Your score is affected by:

- Successful matches
- Combo streaks
- Difficulty
- Game mode
- Hints
- Mistakes
- Overall performance

Higher difficulties provide score multipliers.

---

# 🎲 Deterministic Boards

CardMatch 2.0 supports deterministic seeded board generation.

This provides:

- Reproducible games
- Testable board generation
- Consistent Daily Challenges
- The same Daily Challenge board for every player

---

# 💾 Save Data

CardMatch stores local player data under:

```text
$XDG_DATA_HOME/cardmatch
```

If `XDG_DATA_HOME` is not set, it uses:

```text
~/.local/share/cardmatch
```

Stored data includes:

- Save/resume information
- Leaderboard
- Lifetime statistics

The persistence layer uses plain-text formats and has no external dependencies.

---

# 🏗️ Architecture

```text
CardMatch 2.0
│
├── lib/
│   │
│   ├── core/
│   │   ├── Card
│   │   ├── Rng
│   │   ├── Difficulty
│   │   ├── Board
│   │   ├── Game_mode
│   │   ├── Timer
│   │   ├── Scoring
│   │   ├── Game
│   │   └── Statistics
│   │
│   ├── ui/
│   │   ├── Terminal rendering
│   │   ├── Themes
│   │   ├── Raw-mode input
│   │   └── Menus
│   │
│   ├── ai/
│   │   └── AI opponent
│   │
│   ├── persist/
│   │   ├── Save files
│   │   ├── Leaderboard
│   │   └── Statistics
│   │
│   └── test/
│       └── Test suite
│
└── bin/
    └── main.ml
```

### Core

```text
lib/core
```

Contains the pure game engine.

The core is designed to have **zero I/O dependencies**, making it easier to test and reason about.

### UI

```text
lib/ui
```

Contains:

- Terminal rendering
- Themes
- Raw terminal input
- Menus
- Keyboard navigation

### AI

```text
lib/ai
```

Contains the AI opponent.

The AI uses:

- Bounded memory
- Memory decay
- Configurable mistake rates
- Multiple skill levels

### Persistence

```text
lib/persist
```

Handles:

- Save files
- Leaderboards
- Player statistics

### Tests

```text
lib/test
```

Contains the test suite for the core game engine.

### Executable

```text
bin/
```

Contains the main terminal application and game loop.

---

# 🧪 Development Workflow

For normal development, use:

```bash
dune build
```

Then run tests:

```bash
dune test
```

Then launch the game:

```bash
dune exec bin/main.exe
```

A convenient development cycle is:

```bash
dune build && dune test && dune exec bin/main.exe
```

---

# 🔍 Project Philosophy

CardMatch 2.0 is intentionally designed around a:

**Pure Core Engine + Imperative Terminal Shell**

architecture.

The goal is to keep game logic:

- Deterministic
- Testable
- Reusable
- Independent from terminal I/O
- Easy to extend

This makes it possible to add new:

- Game modes
- AI behavior
- Scoring systems
- Interfaces
- Persistence features
- Board configurations

without tightly coupling everything together.

---

# 📝 Notes on This Build

This project was reconstructed from a multi-turn AI chat transcript that built the project incrementally.

During development, several issues were identified and fixed, including:

- A syntactically invalid `hint_pair`
- A `Memory` module abstraction issue accessed directly by `Ai_player`
- A fragile raw-mode terminal reader based around `stty ... </dev/tty`
- A corrupted string literal in the renderer
- An invalid `String.split_on_char` call using a 2-character string instead of a `char`
- Unclosed parentheses in `bin/main.ml`
- A call to an undefined placeholder function

These issues have been fixed.

The resulting project has been:

- ✅ Compiled successfully
- ✅ Tested with the project's test suite
- ✅ Exercised end-to-end in a real pseudo-terminal
- ✅ Tested through menus
- ✅ Tested through board rendering
- ✅ Tested through card flipping
- ✅ Tested through matching
- ✅ Tested through scoring

---

# 📦 Quick Command Reference

### Install environment

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

### Build + Test + Run

```bash
dune build && dune test && dune exec bin/main.exe
```

### Complete fresh Ubuntu/Codespaces setup

```bash
sudo apt update && sudo apt install -y opam && opam init -y && eval $(opam env) && opam install -y dune alcotest && dune build && dune test && dune exec bin/main.exe
```

---

# ☕ Support the Project

If you enjoy **CardMatch 2.0** and want to support future updates, you can buy me a coffee.

Your support helps keep the project alive and gives me more motivation to build new features and open-source projects. ❤️

### ☕ Buy Me a Coffee

👉 **[Support CardMatch 2.0 — Buy Me a Coffee](https://buymeacoffee.com/flerken)**

Thank you for supporting open-source development! 🚀

---

# 📄 License

See the repository license for the applicable terms.

---

## ❤️ CardMatch 2.0

Built with **OCaml + Dune**.

Designed around a clean functional core and a terminal-first gaming experience.

**Made with code, coffee, and a lot of card flipping. 🃏☕**
