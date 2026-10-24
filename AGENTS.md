# Project: Padee (Flutter app)

A Burmese Buddhist chanting / prayer-bead counter app. The user taps the screen; every tap = one bead count.

## Core concepts
- Plan: has a name and a list of Days.
- Day (DayTask): has `phrases` (List<String>), `beadsPerRound` (int, taps in one round), `rounds` (int).
  - Each tap advances to the next phrase: phrase shown = phrases[bead % phrases.length].
  - When bead reaches beadsPerRound -> round++ and bead = 0.
  - When round reaches rounds -> the day is complete (confetti).
- Progress per plan: day (0-based current day), round (completed rounds), bead (taps in current round).

## Rules for every task
1. Do ONLY what the current prompt asks. Do not refactor or restyle unrelated code.
2. Do not add any package that the prompt does not name. If a package is named, add it with `flutter pub add <name>`.
3. Keep all UI text in Burmese (Myanmar Unicode). Never translate existing Burmese strings into English.
4. Never break existing saved data. When adding fields to a model, `fromJson` must use safe defaults (`json['x'] ?? default`).
5. All local data stays in SharedPreferences (JSON). Keys already used: `plans_v2`, `progress_v2`, `current_plan_v2`.
6. After each task run `flutter analyze` and fix every error and warning you introduced.
7. Use null-safe Dart, `const` where possible, and `if (!mounted) return;` after every `await` that precedes using BuildContext.
8. Use Material 3. Do not use deprecated `withOpacity`; use `withValues(alpha: x)`.
9. At the end of each task, reply with: (a) list of files changed, (b) how to manually test it.
