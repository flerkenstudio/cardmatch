# 🃏 CardMatch

**A terminal-based memory/concentration card game built in OCaml** 🎴

CardMatch is a small functional-programming project demonstrating how to build a game using a **functional core + imperative shell** architecture.

Built with:

`OCaml` · `Dune` · `Alcotest`

---

## ✨ Features

- 🧠 **Pure game logic** — core game functions perform no I/O
- 🔒 **Abstract game state** — state cannot be directly corrupted from outside the module
- ♻️ **Immutable updates** — game operations return new state instead of mutating the existing state
- 🎲 **Seeded shuffle** — deterministic randomness makes boards reproducible and testable
- 🃏 **4×4 memory board** — 16 cards containing 8 matching pairs
- 🎯 **Rank-based matching** — cards match based on rank; suits are cosmetic
- ✅ **Unit tested** — game rules and immutability are covered by Alcotest
- ⚡ **Exhaustive pattern matching** — OCaml's compiler helps catch unhandled cases
- 🛡️ **Module interface** — `.mli` keeps the internal game state abstract

---

## 🚀 Quick Start

### 1. Install dependencies

```bash
opam install dune alcotest
```

### 2. Build the project

```bash
dune build
```

### 3. Run the tests

```bash
dune test
```

### 4. Start the game

```bash
dune exec bin/main.exe
```

---

## 🎮 How to Play

The game starts with a **4×4 board containing 16 hidden cards**.

Your goal is to find all matching pairs.

### Rules

| Rule | Description |
|---|---|
| 🎯 Goal | Match all pairs of cards |
| 🃏 Board | 4×4 grid containing 16 cards |
| 🔢 Matching | Cards match by **rank** (Ace–Ten) |
| 🎴 Suits | Suits are cosmetic and do not affect matching |
| 🖱️ Selection | Select two card indices per turn |
| ✅ Match | Matching cards remain revealed |
| ❌ Miss | Non-matching cards are hidden again |
| 🏆 Win | Find all pairs |

### Example

```text
CardMatch  (seed 7)

      c0   c1   c2   c3
r0   ??   ??   ??   ??
r1   ??   ??   ??   ??
r2   ??   ??   ??   ??
r3   ??   ??   ??   ??

First card (0-15, or q to quit): 0
Second card (0-15, or q to quit): 1
```

If the cards do not match:

```text
No match.

      c0   c1   c2   c3
r0   ??   ??   ??   ??
r1   ??   ??   ??   ??
r2   ??   ??   ??   ??
r3   ??   ??   ??   ??
```

---

## 🏗️ Project Structure

```text
cardmatch/
│
├── 📁 bin/
│   ├── dune
│   └── main.ml
│       └── Game loop, terminal UI and input handling
│
├── 📁 lib/
│   ├── dune
│   ├── game.ml
│   │   └── Core game logic
│   ├── game.mli
│   │   └── Public module interface
│   │
│   └── 📁 test/
│       ├── dune
│       └── test_game.ml
│           └── Alcotest test suite
│
├── 📄 dune-project
├── 📄 README.md
└── 📄 .gitignore
```

---

## 🧠 Architecture

CardMatch follows a **functional core + imperative shell** design.

```text
                    CardMatch
                        │
             ┌──────────┴──────────┐
             │                     │
       Functional Core       Imperative Shell
             │                     │
        game.ml                 main.ml
             │                     │
       Game rules              Terminal UI
       Game state              User input
       Board logic             Game loop
       Pure functions          Printing
```

### Functional Core

`lib/game.ml` contains the game's core logic.

It is responsible for:

- Creating the board
- Shuffling cards
- Revealing cards
- Checking matches
- Tracking attempts
- Tracking matched pairs
- Determining whether the game has been won

The core avoids I/O and unnecessary mutation.

### Imperative Shell

`bin/main.ml` handles:

- Terminal output
- Reading user input
- Running the game loop
- Calling the functional game logic

This separation keeps the game rules easier to test and reason about.

---

## ♻️ Immutability

Game operations such as `reveal` and `play_turn` do not mutate the original state.

Instead, they create updated copies and return a new state.

Conceptually:

```text
Old State
    │
    │ play_turn
    ▼
New State
```

This makes the game state predictable and allows tests to verify that previous states remain unchanged.

---

## 🔒 Abstract Game State

The public interface in:

```text
lib/game.mli
```

keeps the internal `state` representation abstract.

External code cannot directly modify internal values such as:

- Attempts
- Pairs found
- Board state

State changes happen through the module's public functions.

This provides stronger guarantees that the different parts of the game state cannot accidentally become inconsistent.

---

## 🎲 Deterministic Randomness

The board uses a seeded random number generator.

For example:

```text
seed = 7
```

produces a reproducible board.

This gives us:

```text
Same seed
    ↓
Same shuffle
    ↓
Same board
    ↓
Reproducible tests
```

This is particularly useful when testing randomized behavior.

---

## ⚡ Exhaustive Pattern Matching

The project makes use of OCaml's exhaustive pattern matching.

Game types such as cards, ranks and suits are handled through pattern matching.

This allows the compiler to warn us when a new constructor is introduced but not handled somewhere else.

For example:

```text
Add a new rank
      ↓
Compiler detects missing cases
      ↓
Developer fixes them
```

This provides compile-time protection against certain classes of runtime bugs.

---

## 🧪 Testing

CardMatch uses **Alcotest** for automated testing.

The current test suite covers:

- ✅ Card matching
- ✅ Board generation
- ✅ Seeded shuffling
- ✅ Immutable card revealing
- ✅ Winning turns
- ✅ Mismatched cards flipping back
- ✅ Illegal moves

Run the complete test suite with:

```bash
dune test
```

Example successful output:

```text
Testing `CardMatch'.

[OK] game logic 0 is_match.
[OK] game logic 1 make_board.
[OK] game logic 2 seeded shuffle.
[OK] game logic 3 reveal is pure.
[OK] game logic 4 play_turn wins.
[OK] game logic 5 mismatch flips back.
[OK] game logic 6 illegal turn raises.

Test Successful
7 tests run.
```

---

## 🛠️ Development Commands

### Build

```bash
dune build
```

### Run tests

```bash
dune test
```

### Run the game

```bash
dune exec bin/main.exe
```

### Clean build artifacts

```bash
dune clean
```

---

## 📚 Concepts Demonstrated

This project demonstrates several important OCaml and software-engineering concepts:

- Algebraic data types
- Pattern matching
- Exhaustive pattern matching
- Functional programming
- Immutable state
- Module interfaces
- Abstract types
- Pure functions
- Deterministic randomness
- Unit testing
- Dune build system
- OPAM package management
- Functional core + imperative shell architecture

---

## 🎯 Future Improvements

Potential future versions could add:

- 🎨 Improved terminal UI
- 🔢 Score system
- ⏱️ Timer
- 📊 Move counter
- 🎚️ Multiple difficulty levels
- 💡 Hint system
- 🏆 High-score leaderboard
- 💾 Save/load games
- 🤖 AI opponent
- 🌐 Web-based interface
- 👥 Multiplayer mode

---

## 📖 What I Learned

Building CardMatch provided practical experience with:

- Designing functional game logic
- Managing immutable state
- Creating module interfaces with `.mli`
- Writing automated tests with Alcotest
- Working with deterministic randomness
- Organizing an OCaml project with Dune
- Separating application logic from I/O

---

## 💼 Project Purpose

CardMatch was built as a practical project while preparing for **software engineering internship applications**.

The goal was to use a small game to explore functional programming concepts and demonstrate clean software architecture in OCaml.

---

## ⭐ Project Status

**Current version:** Functional terminal game

```text
Build        ✅
Tests        ✅
Game         ✅
Architecture ✅
```

The project is intentionally small and serves as a foundation for future gameplay and UI improvements.

---

## 📄 License

See the repository for licensing information.
