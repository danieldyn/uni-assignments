package model;

import exceptions.InvalidMoveException;
import model.pieces.*;

import java.util.List;
import java.util.TreeSet;

public class Board {
    private TreeSet<ChessPair<Position, Piece>> pieces;

    public Board() {
        pieces = new TreeSet<>();
    }

    public void addPiece(Piece p) {
        if (p == null) {
            return;
        }
        Position pos = p.getPosition();
        pieces.add(new ChessPair<>(pos, p));
    }

    public void removePiece(Piece p) {
        Position pos = p.getPosition();
        pieces.remove(new ChessPair<>(pos, p));
    }

    public TreeSet<ChessPair<Position, Piece>> getPieces() {
        return pieces;
    }

    public void initialise() {
        // White back row
        addPiece(PieceFactory.createPiece("R", "WHITE", "A1"));
        addPiece(PieceFactory.createPiece("N", "WHITE", "B1"));
        addPiece(PieceFactory.createPiece("B", "WHITE", "C1"));
        addPiece(PieceFactory.createPiece("Q", "WHITE", "D1"));
        addPiece(PieceFactory.createPiece("K", "WHITE", "E1"));
        addPiece(PieceFactory.createPiece("B", "WHITE", "F1"));
        addPiece(PieceFactory.createPiece("N", "WHITE", "G1"));
        addPiece(PieceFactory.createPiece("R", "WHITE", "H1"));

        // White front row
        for (char c = 'A'; c <= 'H'; c++) {
            addPiece(PieceFactory.createPiece("P", "WHITE", "" + c + 2));
        }

        // Black back row
        addPiece(PieceFactory.createPiece("R", "BLACK", "A8"));
        addPiece(PieceFactory.createPiece("N", "BLACK", "B8"));
        addPiece(PieceFactory.createPiece("B", "BLACK", "C8"));
        addPiece(PieceFactory.createPiece("Q", "BLACK", "D8"));
        addPiece(PieceFactory.createPiece("K", "BLACK", "E8"));
        addPiece(PieceFactory.createPiece("B", "BLACK", "F8"));
        addPiece(PieceFactory.createPiece("N", "BLACK", "G8"));
        addPiece(PieceFactory.createPiece("R", "BLACK", "H8"));

        // Black front row
        for (char c = 'A'; c <= 'H'; c++) {
            addPiece(PieceFactory.createPiece("P", "BLACK", "" + c + 7));
        }
    }

    public Piece getPieceAt(Position position) {
        for (ChessPair<Position, Piece> pair : pieces) {
            if (pair.getKey().equals(position)) {
                return pair.getValue();
            }
        }
        return null;
    }

    public Position getKingPosition(Colours colour) {
        for (ChessPair<Position, Piece> pair : pieces) {
            Piece piece = pair.getValue();
            if (piece instanceof King && piece.getColour() == colour) {
                return piece.getPosition();
            }
        }
        return null; // never going to actually happen
    }

    public boolean isKingInCheck(Colours colour) {
        Position kingPosition = getKingPosition(colour);

        for (ChessPair<Position, Piece> pair : pieces) {
            Piece piece = pair.getValue();
            if (piece.getColour() != colour) {
                if (piece.checkForCheck(this, kingPosition)) {
                    return true;
                }
            }
        }

        return false;
    }

    public Piece makeTrialMove(Position from, Position to) {
        Piece sourcePiece = getPieceAt(from);
        Piece destinationPiece = getPieceAt(to);

        // Attempt to remove dest piece only if it exists
        if (destinationPiece != null) {
            removePiece(destinationPiece);
        }
        removePiece(sourcePiece); // Source piece surely exists when the function is called

        // Make the move and return dest piece for restoration
        sourcePiece.setPosition(to);
        addPiece(sourcePiece);

        return destinationPiece;
    }

    public void restoreTrialMove(Position from, Position to, Piece destinationPiece) {
        Piece sourcePiece = getPieceAt(to);

        // Move test piece back to its original place
        removePiece(sourcePiece);
        sourcePiece.setPosition(from);
        addPiece(sourcePiece);

        // Restore former dest piece if there was one
        if (destinationPiece != null) {
            addPiece(destinationPiece);
        }
    }

    public boolean containsOpponentKing(Position position,  Colours playerColour) {
        if (!position.isOnBoard()) {
            return false;
        }
        Piece piece = getPieceAt(position);
        if (piece == null) {
            return false;
        }
        return piece.getColour() != playerColour && piece instanceof King;
    }

    public boolean isValidMove(Position from, Position to) {
        // Moves take place on the board only
        if (!from.isOnBoard() || !to.isOnBoard()) {
            return false;
        }

        // The starting piece must exist in order to be moved
        Piece sourcePiece = getPieceAt(from);
        if (sourcePiece == null) {
            return false;
        }

        // Special check for Kings
        if (getPieceAt(from) instanceof King) {
            boolean conclusion = false;
            Colours playerColour = sourcePiece.getColour();
            conclusion |= containsOpponentKing(to.getTop(), playerColour);
            conclusion |= containsOpponentKing(to.getTop().getLeft(), playerColour);
            conclusion |= containsOpponentKing(to.getTop().getRight(), playerColour);
            conclusion |= containsOpponentKing(to.getRight(), playerColour);
            conclusion |= containsOpponentKing(to.getLeft(), playerColour);
            conclusion |= containsOpponentKing(to.getBottom(), playerColour);
            conclusion |= containsOpponentKing(to.getBottom().getLeft(), playerColour);
            conclusion |= containsOpponentKing(to.getBottom().getRight(), playerColour);
            if (conclusion) {
                return false;
            }
        }

        // Check if the move is possible by standard rules
        List<Position> moves = sourcePiece.getPossibleMoves(this);
        if (!moves.contains(to)) {
            return false;
        }

        // Simulate the move
        Piece capturedPiece = makeTrialMove(from, to);
        boolean conclusion = isKingInCheck(sourcePiece.getColour());
        restoreTrialMove(from, to, capturedPiece);

        return !conclusion;
    }

    public void movePiece(Position from, Position to) throws InvalidMoveException {
        if (!isValidMove(from, to)) {
            throw new InvalidMoveException("Invalid move from " + from + " to " + to);
        }

        Piece sourcePiece = getPieceAt(from);
        // Not a trial move actually, but the code can be reused
        makeTrialMove(from, to);
    }

    public String toString() {
        StringBuilder sb = new StringBuilder();

        sb.append("  -----------------------------------\n");
        for (int y = 8; y >= 1; y--) {
            sb.append(y);
            sb.append(" | ");
            for (char x = 'A'; x <= 'H'; x++) {
                Position pos = new Position(x, y);
                Piece p = getPieceAt(pos);
                if (p != null) {
                    sb.append(p);
                    sb.append(" ");
                }
                else {
                    sb.append("...");
                    sb.append(" ");
                }
            }
            sb.append("|\n");
        }
        sb.append("  -----------------------------------\n");
        sb.append("     A   B   C   D   E   F   G   H   \n");

        return sb.toString();
    }

    public String toString(Colours perspective) {
        StringBuilder sb = new StringBuilder();

        sb.append("  -----------------------------------\n");
        if (perspective == Colours.WHITE) {
            for (int y = 8; y >= 1; y--) {
                sb.append(y);
                sb.append(" | ");
                for (char x = 'A'; x <= 'H'; x++) {
                    Position pos = new Position(x, y);
                    Piece p = getPieceAt(pos);
                    if (p != null) {
                        sb.append(p);
                        sb.append(" ");
                    }
                    else {
                        sb.append("...");
                        sb.append(" ");
                    }
                }
                sb.append("|\n");
            }
        }
        else {
            for (int y = 1; y <= 8; y++) {
                sb.append(y);
                sb.append(" | ");
                for (char x = 'H'; x >= 'A'; x--) {
                    Position pos = new Position(x, y);
                    Piece p = getPieceAt(pos);
                    if (p != null) {
                        sb.append(p);
                        sb.append(" ");
                    }
                    else {
                        sb.append("...");
                        sb.append(" ");
                    }
                }
                sb.append("|\n");
            }
        }

        sb.append("  -----------------------------------\n");
        if (perspective == Colours.WHITE) {
            sb.append("     A   B   C   D   E   F   G   H   \n");
        }
        else {
            sb.append("     H   G   F   E   D   C   B   A   \n");
        }

        return sb.toString();
    }
}
