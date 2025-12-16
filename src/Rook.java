import java.util.ArrayList;
import java.util.List;

public class Rook extends Piece {
    public Rook(Colours colour, Position position) {
        super(colour, position);
    }

    public Rook(String colour, String position) {
        super(colour, position);
    }

    public List<Position> getPossibleMoves(Board board) {
        Position selfPosition = getPosition();
        Position targetPosition;
        Piece targetPiece;
        List<Position> possibleMoves = new ArrayList<>();

        // Check above
        for (targetPosition = selfPosition.getTop(); targetPosition.isOnBoard();
             targetPosition = targetPosition.getTop()) {
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

        // Check below
        for (targetPosition = selfPosition.getBottom(); targetPosition.isOnBoard();
             targetPosition = targetPosition.getBottom()) {
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

        // Check left
        for (targetPosition = selfPosition.getLeft(); targetPosition.isOnBoard();
             targetPosition = targetPosition.getLeft()) {
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

        // Check right
        for (targetPosition = selfPosition.getRight(); targetPosition.isOnBoard();
             targetPosition = targetPosition.getRight()) {
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
        return 'R';
    }
}
