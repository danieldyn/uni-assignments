package model.strategies;

import model.Board;
import model.Colours;
import model.Position;
import model.pieces.King;
import model.pieces.Piece;

import java.util.ArrayList;
import java.util.List;

public class KingMoveStrategy implements MoveStrategy {
    private final Colours colour;

    public KingMoveStrategy(Colours colour) {
        this.colour = colour;
    }

    public KingMoveStrategy(String colour) {
        this.colour = Colours.valueOf(colour);
    }

    public List<Position> getPossibleMoves(Board board, Position from) {
        Position targetPosition;
        Piece targetPiece;
        List<Position> possibleMoves = new ArrayList<>();

        // Check top
        targetPosition = from.getTop();
        if (targetPosition.isOnBoard()) {
            targetPiece = board.getPieceAt(targetPosition);
            if (targetPiece == null) {
                possibleMoves.add(targetPosition);
            }
            else if (targetPiece.getColour() != colour && !(targetPiece instanceof King)) {
                possibleMoves.add(targetPosition);
            }
        }

        // Check top left
        targetPosition = from.getTop().getLeft();
        if (targetPosition.isOnBoard()) {
            targetPiece = board.getPieceAt(targetPosition);
            if (targetPiece == null) {
                possibleMoves.add(targetPosition);
            }
            else if (targetPiece.getColour() != colour && !(targetPiece instanceof King)) {
                possibleMoves.add(targetPosition);
            }
        }

        // Check left
        targetPosition = from.getLeft();
        if (targetPosition.isOnBoard()) {
            targetPiece = board.getPieceAt(targetPosition);
            if (targetPiece == null) {
                possibleMoves.add(targetPosition);
            }
            else if (targetPiece.getColour() != colour && !(targetPiece instanceof King)) {
                possibleMoves.add(targetPosition);
            }
        }

        // Check bottom left
        targetPosition = from.getBottom().getLeft();
        if (targetPosition.isOnBoard()) {
            targetPiece = board.getPieceAt(targetPosition);
            if (targetPiece == null) {
                possibleMoves.add(targetPosition);
            }
            else if (targetPiece.getColour() != colour && !(targetPiece instanceof King)) {
                possibleMoves.add(targetPosition);
            }
        }

        // Check bottom
        targetPosition = from.getBottom();
        if (targetPosition.isOnBoard()) {
            targetPiece = board.getPieceAt(targetPosition);
            if (targetPiece == null) {
                possibleMoves.add(targetPosition);
            }
            else if (targetPiece.getColour() != colour && !(targetPiece instanceof King)) {
                possibleMoves.add(targetPosition);
            }
        }

        // Check bottom right
        targetPosition = from.getBottom().getRight();
        if (targetPosition.isOnBoard()) {
            targetPiece = board.getPieceAt(targetPosition);
            if (targetPiece == null) {
                possibleMoves.add(targetPosition);
            }
            else if (targetPiece.getColour() != colour && !(targetPiece instanceof King)) {
                possibleMoves.add(targetPosition);
            }
        }

        // Check right
        targetPosition = from.getRight();
        if (targetPosition.isOnBoard()) {
            targetPiece = board.getPieceAt(targetPosition);
            if (targetPiece == null) {
                possibleMoves.add(targetPosition);
            }
            else if (targetPiece.getColour() != colour && !(targetPiece instanceof King)) {
                possibleMoves.add(targetPosition);
            }
        }

        // Check top right
        targetPosition = from.getTop().getRight();
        if (targetPosition.isOnBoard()) {
            targetPiece = board.getPieceAt(targetPosition);
            if (targetPiece == null) {
                possibleMoves.add(targetPosition);
            }
            else if (targetPiece.getColour() != colour && !(targetPiece instanceof King)) {
                possibleMoves.add(targetPosition);
            }
        }

        return possibleMoves;
    }

}
