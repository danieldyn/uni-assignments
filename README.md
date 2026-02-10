# Object-Oriented Programming
# Java Chess Game Assignment

## Table of Contents
- [Overview](#overview)
- [Game Rules & Mechanics](#game-rules--mechanics)
- [Design Patterns](#design-patterns)
- [Application Flow & GUI](#application-flow--gui)
- [Scoring System](#scoring-system)
- [Running the Application](#running-the-application)

## Overview

This repository features my 2-in-1 implementation for two Objected-Oriented Programming assignments. 
The central theme is a 2D Java chess game showcasing good usage of the fundamental principles of OOP, an interactive User Interface written in Swing and the integration of four adequate Design Patterns.

### Core Features

- **Player vs. Computer:** Interactive gameplay against an opponent with RNG moves.
- **User Management:** Authentication system with Login and Register functionalities.
- **Game Persistence:** Ability to save active games, view game history, and resume progress based on account data.
- **Visual Feedback:** A responsive GUI that highlights valid moves and updates the board state in real-time.

## Game Rules & Mechanics

The game is played on a standard $8\times8$ grid, with alternating black and white squares. Each player controls a set of 16 pieces: a King, a Queen, two Rooks, two Bishops, two Knights and eight Pawns.

### Movement Logic

The application implements specific movement strategies for every piece type:
- **King:** Moves one square in any direction.
- **Queen:** Moves any number of squares in any direction.
- **Rook:** Moves any number of squares horizontally or vertically.
- **Bishop:** Moves any number of squares diagonally.
- **Knight:** Moves in an "L" shape (two squares in one direction, then one perpendicular). Can also jump over pieces.
- **Pawn:** Moves forward one square (or two on the first move) and captures diagonally.

> **Note:** For the scope of this assignment, special moves (such as Castling or En Passant) are not implemented.

### End Game Conditions

The game concludes under three scenarios:
1.  **Checkmate:** The opponent's King is under attack and has no valid moves to escape this state.
2.  **Resignation:** The human player voluntarily forfeits the match.
3.  **Draw:** Declared if the computer "resigns" (e.g., in a stalemate loop of 3 repeated positions).

## Design Patterns

To ensure a robust architecture, the project integrates four mandatory Design Patterns:

### 1. Singleton Pattern
Used to restrict the `Main` class to a single instance. This central instance coordinates the global state of the application, including user sessions and active game management, initialising resources only when necessary (Lazy Initialisation).

### 2. Factory Pattern
Great choice to abstract the creation of objects. This pattern is utilised for:
- Initialising pieces on the board at the start of a game.
- Loading piece configurations from saved files (`games.json`).
- Handling Pawn promotion (transforming a Pawn into a Queen, Rook, Bishop, or Knight).

### 3. Strategy Pattern
Defines a family of algorithms that can be interchanged. In this project, it encapsulates:
- **Movement Logic:** Each piece (King, Rook, etc.) implements a `MoveStrategy` interface to calculate its own valid moves.
- **Scoring Logic:** Different strategies are used to calculate points based on game events (captures vs. checkmates).

### 4. Observer Pattern
Establishes a mechanism to notify multiple objects about events. Components such as the GUI, the Move History Logger, and the Score Manager act as **Observers** that react automatically when:
- A move is performed.
- A piece is captured.
- The turn switches between players.

## Application Flow & GUI

The application is entirely created using Java Swing. The user experience is divided into four main stages:

### Authentication
A login screen requiring an email and password. Users can also create a new account. Validation ensures credentials are correct before granting access.

### Main Menu
The central hub where users can:
- **Start New Game:** Input an alias and choose a side (White/Black).
- **Resume Game:** Select from a list of saved games in progress.
- **View Stats:** Check total score and number of games played.

### Game Board
The primary interface displaying the $8\times8$ grid.
- **Interaction:** Clicking a piece highlights valid moves; clicking a target square executes the move.
- **HUD:** Displays current turn, captured pieces, and real-time messages (e.g., "Check!", "Player Turn").
- **Controls:** Options to "Save & Exit" or "Resign".

### End Screen
Displays the final result (Victory/Defeat/Draw), the points earned/lost in the session, and the updated total score for the user.

## Scoring System

The application tracks a user's score ($X$) which updates based on the outcome of games and pieces captured ($Y$).

### Piece Values
Points awarded for capturing specific pieces:

|   Piece    | Points |
|:----------:|:------:|
| **Queen**  |   90   |
|  **Rook**  |   50   |
| **Bishop** |   30   |
| **Knight** |   30   |
|  **Pawn**  |   10   |

### Match Outcome Bonuses
- **Victory (Checkmate):** $X_{new} = X + Y + 300$
- **Defeat (Checkmate):** $X_{new} = X + Y - 300$
- **Draw / Opponent Resign:** $X_{new} = X + Y + 150$
- **Player Resign:** $X_{new} = X + Y - 150$

## Running the Application

- Ensure a Java Development Kit (at least JDK 1.8) is installed.
- The project is organised into several folders.
- Compile and run the `Main` class to launch the GUI.
- **Note:** Terminal output is used only for debugging; all gameplay interactions occur strictly within the windowed interface.
