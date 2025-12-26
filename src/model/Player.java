package model;

import exceptions.InvalidMoveException;
import model.pieces.Piece;
import model.strategies.StandardScoreStrategy;

import java.util.List;
import java.util.ArrayList;
import java.util.TreeSet;

public class Player {
    private String name;
    private Colours colour;
    private List<Piece> capturedPieces;
    private TreeSet<ChessPair<Position, Piece>> ownedPieces;
    private int points;
    private Board board;
    StandardScoreStrategy scoreStrategy;

    public Player(String name, Colours colour) {
        this.name = name;
        this.colour = colour;
        capturedPieces = new ArrayList<>();
        ownedPieces = new TreeSet<>();
        points = 0;
        scoreStrategy = new StandardScoreStrategy();
    }

    public Player(String name, String colour) {
        this.name = name;
        if (colour.toUpperCase().equals("WHITE")) {
            this.colour = Colours.WHITE;
        }
        else {
            this.colour = Colours.BLACK;
        }
        capturedPieces = new ArrayList<>();
        ownedPieces = new TreeSet<>();
        points = 0;
        scoreStrategy = new StandardScoreStrategy();
    }

    public Colours getColour() {
        return colour;
    }

    public String getName() {
        return name;
    }

    public Board getBoard() {
        return board;
    }

    public void setBoard(Board board) {
        this.board = board;
    }

    public void makeMove(Position from, Position to, Board board) throws InvalidMoveException {
        if (!board.isValidMove(from, to)) {
            throw new InvalidMoveException("Invalid move from " + from + " to " + to);
        }

        Piece targetPiece = board.getPieceAt(to);
        if (targetPiece != null) {
            points += scoreStrategy.getScoreForCapture(targetPiece);
            capturedPieces.add(targetPiece);
        }

        board.movePiece(from, to);
    }

    public List<Piece> getCapturedPieces() {
        return capturedPieces;
    }

    public List<ChessPair<Position, Piece>> getOwnedPieces() {
        ownedPieces.clear();

        if (board != null) {
            for (ChessPair<Position, Piece> pair : board.getPieces()) {
                if (pair.getValue().getColour() == colour) {
                    ownedPieces.add(pair);
                }
            }
        }

        return new ArrayList<>(ownedPieces);
    }

    public int getPoints() {
        return points;
    }

    public void setPoints(int points) {
        this.points = points;
    }

    public String toString() {
        return name;
    }
}
