package model.strategies;

import model.Board;
import model.Colours;
import model.Position;
import model.pieces.Piece;

import java.util.ArrayList;
import java.util.List;

public class RookMoveStrategy implements MoveStrategy {
    private final Colours colour;

    public RookMoveStrategy(Colours colour) {
        this.colour = colour;
    }

    public RookMoveStrategy(String colour) {
        this.colour = Colours.valueOf(colour.toUpperCase());
    }

    public List<Position> getPossibleMoves(Board board, Position from) {
        Position targetPosition;
        Piece targetPiece;
        List<Position> possibleMoves = new ArrayList<>();

        // Check above
        for (targetPosition = from.getTop(); targetPosition.isOnBoard();
             targetPosition = targetPosition.getTop()) {
            targetPiece = board.getPieceAt(targetPosition);
            if (targetPiece == null) {
                possibleMoves.add(targetPosition);
            }
            else if (targetPiece.getColour() != colour) {
                possibleMoves.add(targetPosition);
                break;
            }
            else {
                break;
            }
        }

        // Check below
        for (targetPosition = from.getBottom(); targetPosition.isOnBoard();
             targetPosition = targetPosition.getBottom()) {
            targetPiece = board.getPieceAt(targetPosition);
            if (targetPiece == null) {
                possibleMoves.add(targetPosition);
            }
            else if (targetPiece.getColour() != colour) {
                possibleMoves.add(targetPosition);
                break;
            }
            else {
                break;
            }
        }

        // Check left
        for (targetPosition = from.getLeft(); targetPosition.isOnBoard();
             targetPosition = targetPosition.getLeft()) {
            targetPiece = board.getPieceAt(targetPosition);
            if (targetPiece == null) {
                possibleMoves.add(targetPosition);
            }
            else if (targetPiece.getColour() != colour) {
                possibleMoves.add(targetPosition);
                break;
            }
            else {
                break;
            }
        }

        // Check right
        for (targetPosition = from.getRight(); targetPosition.isOnBoard();
             targetPosition = targetPosition.getRight()) {
            targetPiece = board.getPieceAt(targetPosition);
            if (targetPiece == null) {
                possibleMoves.add(targetPosition);
            }
            else if (targetPiece.getColour() != colour) {
                possibleMoves.add(targetPosition);
                break;
            }
            else {
                break;
            }
        }

        return possibleMoves;
    }
}
