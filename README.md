🃏 CardMatch
A terminal memory/concentration card game in OCaml 🎴

Built as a functional core + imperative shell — the way Jane Street writes real systems.

OCaml · Dune · Alcotest

✨ Highlights
🧠 Pure game logic — no I/O, no hidden mutation in the core
🔒 Abstract state — impossible to corrupt the game from outside the module
🎲 Seeded shuffle — reproducible boards = testable randomness
✅ Unit tested — Alcotest suite covering rules and immutability
⚡ Total pattern matches — adding a rank is a compile error, not a runtime bug
🚀 Build & Run
# 1️⃣ Install dependencies
opam install dune alcotest

# 2️⃣ Build
dune build

# 3️⃣ Run tests
dune test

# 4️⃣ Play! 🎮
dune exec bin/main.exe
🎮 How to Play
Rule	Detail
🎯 Goal	Match all pairs of cards
🔢 Matching	Cards match on rank (Ace–Ten) — suits are just cosmetic 💅
🖱️ Moves	Pick two indices per turn
✅ Match	Pair stays revealed as **
❌ Miss	Cards flip back to ??
🏆 Win	All pairs found — done in the fewest attempts!
 ??  ??  ??  ??
 ??  A♥  ??  ??     ← one card revealed...
 ??  ??  ??  ??
 ??  ??  ??  ??
🏗️ Project Structure
cardmatch/
├── 📁 bin/
│   └── main.ml            🖥️  Game loop, printing, stdin parsing
├── 📁 lib/
│   ├── game.ml            🧠  Pure game logic (no I/O!)
│   ├── game.mli           🔒  Module interface — state is abstract
│   └── test/
│       └── test_game.ml   ✅  Alcotest unit tests
└── 📄 dune-project        ⚙️  Build config
🎨 Design Notes
♾️ Immutability
reveal and play_turn never mutate their argument — they Array.copy first and return a fresh board/state. Tests assert this.

🔒 Abstract State
game.mli exposes type state with no constructor, so attempts and pairs_found can only change through play_turn — they can never drift out of sync with the board. cell stays concrete so the renderer and tests can pattern match on it.

🎲 Seeded Shuffle
make_board rows cols seed uses Fisher–Yates over a Random.State.t built from the seed → same seed = same board = testable randomness.

⚡ Total Pattern Matches
Every match on cell / rank / suit covers all constructors. Add a new rank? The compiler forces you to handle it everywhere. Compile-time safety > runtime bugs. 🛡️

📚 What I Learned
🧩 Algebraic data types & exhaustive pattern matching
♻️ Immutable updates (functional core style)
📦 Module design with .mli interface files
🧪 Unit testing with Alcotest
🔨 Real-world OCaml tooling: opam, dune
Built while preparing for a Software Engineering internship application 💼

⭐ Star this repo if you found it useful!
