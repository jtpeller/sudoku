# sudoku

Cross-platform Sudoku game written using the Flutter framework.

My aim with this is to learn Flutter for cross-platform development.

## Table of Contents

- [sudoku](#sudoku)
  - [Table of Contents](#table-of-contents)
  - [Purpose](#purpose)
  - [Design](#design)
  - [Installation](#installation)

## Purpose

This is a project I've wanted to do for a while: make a cross-platform game.

The ultimate goal is to supersede my [very old and not-so-great attempt](https://www.github.com/jtpeller/SudokuJava) at a Sudoku game, plus it has the added benefit of being available on many other platforms.

## Design

This Sudoku game features:

- Splash screen
- Main Menu, with title and customized buttons
- Game page, which has the Sudoku grid and related buttons / etc.
- Options submenu, which I'm still figuring out how I want to tackle (if at all).

The game itself aims to implement:

- Candidate / normal mode (for placing numbers)
- Auto-candidate mode (the "hint" mode, which will do the work of elimination for you).
- Super-auto-candidate mode. This is like auto-candidate mode, except it goes an extra-step to eliminate further (say, highlighting numbers that can clearly be a different value, eliminate numbers since it can only be a certain row/column in another box, etc.)

## Installation

TODO
