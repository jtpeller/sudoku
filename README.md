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
- Options submenu, with options that influence appearance and the game.
- Candidate and normal modes
- Auto-candidate mode, which fills in valid candidates for you.

The game itself aims to implement:

- Super-auto-candidate mode. This is like auto-candidate mode, except it goes an extra-step to eliminate further (say, highlighting numbers that can clearly be a different value, eliminate numbers since it can only be a certain row/column in another box, etc.)
- Timer
- Stats?
- Achievements for Android and iOS?

## Installation

> [!IMPORTANT]
> Currently, I have only tested with the Web build and the Windows build.
> Also, don't just build my software and then publish it on another platform / store -- see LICENSE.

The following build instructions are to be used per platform:

- Linux (untested)

  ```sh
  flutter build linux --release
  ```

- Windows (tested)

    ```sh
    flutter build windows --release
    ```

- macOS (untested)

    ```sh
    flutter build macos --release
    ```

- Web (tested, tweaked for GitHub Pages deployment)

    ```sh
    flutter build web --base-href "/sudoku/" --release
    ```

- Android (tested, working in Android Studio)

    ```sh
    flutter build apk --release
    # OR, for app store bundle
    flutter build appbundle --release
    ```

- iOS (untested)

    ```sh
    flutter build ipa --release
    # TODO: probably need something with "export options"
    ```
