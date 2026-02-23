package model.pieces;

import model.Colours;
import model.Position;

public class PieceFactory {
    private static final PieceFactory instance = new PieceFactory();

    private PieceFactory() { } // Singleton

    public static PieceFactory getInstance() {
        return instance;
    }

    public static Piece createPiece(String type, String colour, String position) {
        // For safety
        type = type.toUpperCase();
        colour = colour.toUpperCase();
        switch (type) {
            case "P": return new Pawn(colour, position);
            case "N": return new Knight(colour, position);
            case "B": return new Bishop(colour, position);
            case "R": return new Rook(colour, position);
            case "Q": return new Queen(colour, position);
            case "K": return new King(colour, position);
            default: return null;
        }
    }

    public static Piece createPiece(String type, Colours colour, Position position) {
        switch (type.toUpperCase()) {
            case "PAWN": return new Pawn(colour, position);
            case "KNIGHT": return new Knight(colour, position);
            case "BISHOP": return new Bishop(colour, position);
            case "ROOK": return new Rook(colour, position);
            case "QUEEN": return new Queen(colour, position);
            case "KING": return new King(colour, position);
            default: return null;
        }
    }
}
