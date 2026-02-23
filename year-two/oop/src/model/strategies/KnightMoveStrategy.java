package model.strategies;

import model.Board;
import model.Colours;
import model.Position;
import model.pieces.Piece;

import java.util.ArrayList;
import java.util.List;

public class KnightMoveStrategy implements MoveStrategy {
    private final Colours colour;

    public KnightMoveStrategy(Colours colour) {
        this.colour = colour;
    }

    public KnightMoveStrategy(String colour) {
        this.colour = Colours.valueOf(colour);
    }

    public List<Position> getPossibleMoves(Board board, Position from) {
        Position targetPosition;
        Piece targetPiece;
        List<Position> possibleMoves = new ArrayList<>();

        // Check left up
        targetPosition = from.getLeft().getLeft().getTop();
        if (targetPosition.isOnBoard()) {
            targetPiece = board.getPieceAt(targetPosition);
            if (targetPiece == null || targetPiece.getColour() != colour) {
                possibleMoves.add(targetPosition);
            }
        }

        // Check left down
        targetPosition = from.getLeft().getLeft().getBottom();
        if (targetPosition.isOnBoard()) {
            targetPiece = board.getPieceAt(targetPosition);
            if (targetPiece == null || targetPiece.getColour() != colour) {
                possibleMoves.add(targetPosition);
            }
        }

        // Check down left
        targetPosition = from.getBottom().getBottom().getLeft();
        if (targetPosition.isOnBoard()) {
            targetPiece = board.getPieceAt(targetPosition);
            if (targetPiece == null || targetPiece.getColour() != colour) {
                possibleMoves.add(targetPosition);
            }
        }

        // Check down right
        targetPosition = from.getBottom().getBottom().getRight();
        if (targetPosition.isOnBoard()) {
            targetPiece = board.getPieceAt(targetPosition);
            if (targetPiece == null || targetPiece.getColour() != colour) {
                possibleMoves.add(targetPosition);
            }
        }

        // Check right down
        targetPosition = from.getRight().getRight().getBottom();
        if (targetPosition.isOnBoard()) {
            targetPiece = board.getPieceAt(targetPosition);
            if (targetPiece == null || targetPiece.getColour() != colour) {
                possibleMoves.add(targetPosition);
            }
        }

        // Check right up
        targetPosition = from.getRight().getRight().getTop();
        if (targetPosition.isOnBoard()) {
            targetPiece = board.getPieceAt(targetPosition);
            if (targetPiece == null || targetPiece.getColour() != colour) {
                possibleMoves.add(targetPosition);
            }
        }

        // Check up right
        targetPosition = from.getTop().getTop().getRight();
        if (targetPosition.isOnBoard()) {
            targetPiece = board.getPieceAt(targetPosition);
            if (targetPiece == null || targetPiece.getColour() != colour) {
                possibleMoves.add(targetPosition);
            }
        }

        // Check up left
        targetPosition = from.getTop().getTop().getLeft();
        if (targetPosition.isOnBoard()) {
            targetPiece = board.getPieceAt(targetPosition);
            if (targetPiece == null || targetPiece.getColour() != colour) {
                possibleMoves.add(targetPosition);
            }
        }

        return possibleMoves;
    }
}
