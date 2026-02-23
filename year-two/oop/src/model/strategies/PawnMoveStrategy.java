package model.strategies;

import model.Board;
import model.Colours;
import model.Position;
import model.pieces.Piece;

import java.util.ArrayList;
import java.util.List;

public class PawnMoveStrategy implements MoveStrategy {
    private final Colours colour;

    public PawnMoveStrategy(Colours colour) {
        this.colour = colour;
    }

    public PawnMoveStrategy(String colour) {
        this.colour = Colours.valueOf(colour);
    }

    public List<Position> getPossibleMoves(Board board, Position from) {
        Position targetPosition;
        Piece targetPiece;
        List<Position> possibleMoves = new ArrayList<>();

        // Check ahead
        if (colour == Colours.WHITE) {
            targetPosition = from.getTop();
        } else {
            targetPosition = from.getBottom();
        }

        if (targetPosition.isOnBoard()) {
            targetPiece = board.getPieceAt(targetPosition);
            // Single step
            if (targetPiece == null) {
                possibleMoves.add(targetPosition);
                // Double step
                Position doubleStepTarget = null;
                if (colour == Colours.WHITE && from.getY() == 2) {
                    doubleStepTarget = targetPosition.getTop();
                }
                else if (colour == Colours.BLACK && from.getY() == 7) {
                    doubleStepTarget = targetPosition.getBottom();
                }
                if (doubleStepTarget != null && doubleStepTarget.isOnBoard()) {
                    if (board.getPieceAt(doubleStepTarget) == null) {
                        possibleMoves.add(doubleStepTarget);
                    }
                }
            }
        }

        // Check front left
        if (colour == Colours.WHITE) {
            targetPosition = from.getTop().getLeft();
        }
        else {
            targetPosition = from.getBottom().getRight();
        }
        if (targetPosition.isOnBoard()) {
            targetPiece = board.getPieceAt(targetPosition);
            if  (targetPiece != null && targetPiece.getColour() != colour) {
                possibleMoves.add(targetPosition);
            }
        }

        // Check front right
        if (colour == Colours.WHITE) {
            targetPosition = from.getTop().getRight();
        }
        else {
            targetPosition = from.getBottom().getLeft();
        }
        if (targetPosition.isOnBoard()) {
            targetPiece = board.getPieceAt(targetPosition);
            if (targetPiece != null && targetPiece.getColour() != colour) {
                possibleMoves.add(targetPosition);
            }
        }

        return possibleMoves;
    }
}
