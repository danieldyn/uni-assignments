package model;

import model.pieces.Piece;

public class Move {
    private final Colours playerColour;
    private final Position from, to;
    private Piece capturedPiece;

    public Move(Colours playerColour, Position from, Position to) {
        this.playerColour = playerColour;
        this.from = from;
        this.to = to;
    }

    public Move(String playerColour, String from, String to) {
        this.playerColour = Colours.valueOf(playerColour);
        this.from = new Position(from);
        this.to = new Position(to);
    }

    public Move(Colours playerColour, Position from, Position to, Piece capturedPiece) {
        this.playerColour = playerColour;
        this.from = from;
        this.to = to;
        this.capturedPiece = capturedPiece;
    }

    public Colours getPlayerColour() {
        return playerColour;
    }

    public Position getFrom() {
        return from;
    }

    public Position getTo() {
        return to;
    }

    public Piece getCapturedPiece() {
        return capturedPiece;
    }

    public void setCapturedPiece(Piece capturedPiece) {
        this.capturedPiece = capturedPiece;
    }

    public String toString() {
        return playerColour + " " + from + "->" + to;
    }
}
