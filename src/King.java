import java.util.ArrayList;
import java.util.List;

public class King extends Piece {
    public King(Colours colour, Position position) {
        super(colour, position);
    }

    public King(String colour, String position) {
        super(colour, position);
    }

    public List<Position> getPossibleMoves(Board board) {
        Position selfPosition = getPosition();
        Position targetPosition;
        Piece targetPiece;
        List<Position> possibleMoves = new ArrayList<>();

        // Check top
        targetPosition = selfPosition.getTop();
        if (targetPosition.isOnBoard()) {
            targetPiece = board.getPieceAt(targetPosition);
            if (targetPiece == null) {
                possibleMoves.add(targetPosition);
            }
            else if (targetPiece.getColour() != getColour() && !(targetPiece instanceof King)) {
                possibleMoves.add(targetPosition);
            }
        }

        // Check top left
        targetPosition = selfPosition.getTop().getLeft();
        if (targetPosition.isOnBoard()) {
            targetPiece = board.getPieceAt(targetPosition);
            if (targetPiece == null) {
                possibleMoves.add(targetPosition);
            }
            else if (targetPiece.getColour() != getColour() && !(targetPiece instanceof King)) {
                possibleMoves.add(targetPosition);
            }
        }

        // Check left
        targetPosition = selfPosition.getLeft();
        if (targetPosition.isOnBoard()) {
            targetPiece = board.getPieceAt(targetPosition);
            if (targetPiece == null) {
                possibleMoves.add(targetPosition);
            }
            else if (targetPiece.getColour() != getColour() && !(targetPiece instanceof King)) {
                possibleMoves.add(targetPosition);
            }
        }

        // Check bottom left
        targetPosition = selfPosition.getBottom().getLeft();
        if (targetPosition.isOnBoard()) {
            targetPiece = board.getPieceAt(targetPosition);
            if (targetPiece == null) {
                possibleMoves.add(targetPosition);
            }
            else if (targetPiece.getColour() != getColour() && !(targetPiece instanceof King)) {
                possibleMoves.add(targetPosition);
            }
        }

        // Check bottom
        targetPosition = selfPosition.getBottom();
        if (targetPosition.isOnBoard()) {
            targetPiece = board.getPieceAt(targetPosition);
            if (targetPiece == null) {
                possibleMoves.add(targetPosition);
            }
            else if (targetPiece.getColour() != getColour() && !(targetPiece instanceof King)) {
                possibleMoves.add(targetPosition);
            }
        }

        // Check bottom right
        targetPosition = selfPosition.getBottom().getRight();
        if (targetPosition.isOnBoard()) {
            targetPiece = board.getPieceAt(targetPosition);
            if (targetPiece == null) {
                possibleMoves.add(targetPosition);
            }
            else if (targetPiece.getColour() != getColour() && !(targetPiece instanceof King)) {
                possibleMoves.add(targetPosition);
            }
        }

        // Check right
        targetPosition = selfPosition.getRight();
        if (targetPosition.isOnBoard()) {
            targetPiece = board.getPieceAt(targetPosition);
            if (targetPiece == null) {
                possibleMoves.add(targetPosition);
            }
            else if (targetPiece.getColour() != getColour() && !(targetPiece instanceof King)) {
                possibleMoves.add(targetPosition);
            }
        }

        // Check top right
        targetPosition = selfPosition.getTop().getRight();
        if (targetPosition.isOnBoard()) {
            targetPiece = board.getPieceAt(targetPosition);
            if (targetPiece == null) {
                possibleMoves.add(targetPosition);
            }
            else if (targetPiece.getColour() != getColour() && !(targetPiece instanceof King)) {
                possibleMoves.add(targetPosition);
            }
        }

        return possibleMoves;
    }

    public boolean checkForCheck(Board board, Position kingPosition) {
        return getPossibleMoves(board).contains(kingPosition);
    }

    public char type() {
        return 'K';
    }
}
