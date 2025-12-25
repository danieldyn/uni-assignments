package model.strategies;

import model.Board;
import model.Colours;
import model.Position;
import model.pieces.Piece;

import java.util.ArrayList;
import java.util.List;

public class BishopMoveStrategy implements MoveStrategy {
    private final Colours colour;

    public BishopMoveStrategy(Colours colour) {
        this.colour = colour;
    }

    public BishopMoveStrategy(String colour) {
        this.colour = Colours.valueOf(colour);
    }

    public List<Position> getPossibleMoves(Board board, Position from) {
        Position targetPosition;
        Piece targetPiece;
        List<Position> possibleMoves = new ArrayList<>();

        // Check diagonal top left
        for (targetPosition = from.getTop().getLeft(); targetPosition.isOnBoard();
             targetPosition = targetPosition.getTop().getLeft()) {
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

        // Check diagonal bottom left
        for (targetPosition = from.getBottom().getLeft(); targetPosition.isOnBoard();
             targetPosition = targetPosition.getBottom().getLeft()) {
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

        // Check diagonal bottom right
        for (targetPosition = from.getBottom().getRight(); targetPosition.isOnBoard();
             targetPosition = targetPosition.getBottom().getRight()) {
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

        // Check diagonal top right
        for (targetPosition = from.getTop().getRight(); targetPosition.isOnBoard();
             targetPosition = targetPosition.getTop().getRight()) {
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
