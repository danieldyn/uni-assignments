import java.util.ArrayList;
import java.util.List;

public class Bishop extends Piece {
    public Bishop(Colours colour, Position position) {
        super(colour, position);
    }

    public Bishop(String colour, String position) {
        super(colour, position);
    }

    public List<Position> getPossibleMoves(Board board) {
        Position selfPosition = getPosition();
        Position targetPosition;
        Piece targetPiece;
        List<Position> possibleMoves = new ArrayList<>();

        // Check diagonal top left
        for (targetPosition = selfPosition.getTop().getLeft(); targetPosition.isOnBoard();
             targetPosition = targetPosition.getTop().getLeft()) {
            targetPiece = board.getPieceAt(targetPosition);
            if (targetPiece == null) {
                possibleMoves.add(targetPosition);
            }
            else if (targetPiece.getColour() != getColour()) {
                possibleMoves.add(targetPosition);
                break;
            }
            else {
                break;
            }
        }

        // Check diagonal bottom left
        for (targetPosition = selfPosition.getBottom().getLeft(); targetPosition.isOnBoard();
            targetPosition = targetPosition.getBottom().getLeft()) {
            targetPiece = board.getPieceAt(targetPosition);
            if (targetPiece == null) {
                possibleMoves.add(targetPosition);
            }
            else if (targetPiece.getColour() != getColour()) {
                possibleMoves.add(targetPosition);
                break;
            }
            else {
                break;
            }
        }

        // Check diagonal bottom right
        for (targetPosition = selfPosition.getBottom().getRight(); targetPosition.isOnBoard();
            targetPosition = targetPosition.getBottom().getRight()) {
            targetPiece = board.getPieceAt(targetPosition);
            if (targetPiece == null) {
                possibleMoves.add(targetPosition);
            }
            else if (targetPiece.getColour() != getColour()) {
                possibleMoves.add(targetPosition);
                break;
            }
            else {
                break;
            }
        }

        // Check diagonal top right
        for (targetPosition = selfPosition.getTop().getRight(); targetPosition.isOnBoard();
            targetPosition = targetPosition.getTop().getRight()) {
            targetPiece = board.getPieceAt(targetPosition);
            if (targetPiece == null) {
                possibleMoves.add(targetPosition);
            }
            else if (targetPiece.getColour() != getColour()) {
                possibleMoves.add(targetPosition);
                break;
            }
            else {
                break;
            }
        }

        return possibleMoves;
    }

    public boolean checkForCheck(Board board, Position kingPosition) {
        return getPossibleMoves(board).contains(kingPosition);
    }

    public char type() {
        return 'B';
    }
}
