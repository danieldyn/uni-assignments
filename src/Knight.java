import java.util.ArrayList;
import java.util.List;

public class Knight extends Piece {
    public Knight(Colours colour, Position position) {
        super(colour, position);
    }

    public Knight(String colour, String position) {
        super(colour, position);
    }

    public List<Position> getPossibleMoves(Board board) {
        Position selfPosition = getPosition();
        Position targetPosition;
        Piece targetPiece;
        List<Position> possibleMoves = new ArrayList<>();

        // Check left up
        targetPosition = selfPosition.getLeft().getLeft().getTop();
        if (targetPosition.isOnBoard()) {
            targetPiece = board.getPieceAt(targetPosition);
            if (targetPiece == null || targetPiece.getColour() != getColour()) {
                possibleMoves.add(targetPosition);
            }
        }

        // Check left down
        targetPosition = selfPosition.getLeft().getLeft().getBottom();
        if (targetPosition.isOnBoard()) {
            targetPiece = board.getPieceAt(targetPosition);
            if (targetPiece == null || targetPiece.getColour() != getColour()) {
                possibleMoves.add(targetPosition);
            }
        }

        // Check down left
        targetPosition = selfPosition.getBottom().getBottom().getLeft();
        if (targetPosition.isOnBoard()) {
            targetPiece = board.getPieceAt(targetPosition);
            if (targetPiece == null || targetPiece.getColour() != getColour()) {
                possibleMoves.add(targetPosition);
            }
        }

        // Check down right
        targetPosition = selfPosition.getBottom().getBottom().getRight();
        if (targetPosition.isOnBoard()) {
            targetPiece = board.getPieceAt(targetPosition);
            if (targetPiece == null || targetPiece.getColour() != getColour()) {
                possibleMoves.add(targetPosition);
            }
        }

        // Check right down
        targetPosition = selfPosition.getRight().getRight().getBottom();
        if (targetPosition.isOnBoard()) {
            targetPiece = board.getPieceAt(targetPosition);
            if (targetPiece == null || targetPiece.getColour() != getColour()) {
                possibleMoves.add(targetPosition);
            }
        }

        // Check right up
        targetPosition = selfPosition.getRight().getRight().getTop();
        if (targetPosition.isOnBoard()) {
            targetPiece = board.getPieceAt(targetPosition);
            if (targetPiece == null || targetPiece.getColour() != getColour()) {
                possibleMoves.add(targetPosition);
            }
        }

        // Check up right
        targetPosition = selfPosition.getTop().getTop().getRight();
        if (targetPosition.isOnBoard()) {
            targetPiece = board.getPieceAt(targetPosition);
            if (targetPiece == null || targetPiece.getColour() != getColour()) {
                possibleMoves.add(targetPosition);
            }
        }

        // Check up left
        targetPosition = selfPosition.getTop().getTop().getLeft();
        if (targetPosition.isOnBoard()) {
            targetPiece = board.getPieceAt(targetPosition);
            if (targetPiece == null || targetPiece.getColour() != getColour()) {
                possibleMoves.add(targetPosition);
            }
        }

        return possibleMoves;
    }

    public boolean checkForCheck(Board board, Position kingPosition) {
        return getPossibleMoves(board).contains(kingPosition);
    }

    public char type() {
        return 'N';
    }
}
