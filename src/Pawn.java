import java.util.List;
import java.util.ArrayList;

public class Pawn extends Piece {
    private boolean hasMoved;

    public Pawn(Colours colour, Position position) {
        super(colour, position);
        hasMoved = false;
    }

    public Pawn(String colour, String position) {
        super(colour, position);
    }

    public void setHasMoved() {
        this.hasMoved = true;
    }

    public List<Position> getPossibleMoves(Board board) {
        Position selfPosition = getPosition();
        Position targetPosition;
        Piece targetPiece;
        List<Position> possibleMoves = new ArrayList<>();

        // Check ahead
        if (getColour() == Colours.WHITE) {
            targetPosition = selfPosition.getTop();
        } else {
            targetPosition = selfPosition.getBottom();
        }

        if (targetPosition.isOnBoard()) {
            targetPiece = board.getPieceAt(targetPosition);
            // Single step
            if (targetPiece == null) {
                possibleMoves.add(targetPosition);
                // Double step
                if (!hasMoved) {
                    Position doubleStepTarget = null;
                    // Only on starting row
                    if (getColour() == Colours.WHITE && getPosition().getY() == 2) {
                        doubleStepTarget = targetPosition.getTop();
                    }
                    else if (getColour() == Colours.BLACK && getPosition().getY() == 7) {
                        doubleStepTarget = targetPosition.getBottom();
                    }
                    if (doubleStepTarget != null && doubleStepTarget.isOnBoard()) {
                        if (board.getPieceAt(doubleStepTarget) == null) {
                            possibleMoves.add(doubleStepTarget);
                        }
                    }
                }
            }
        }

        // Check front left
        if (getColour() == Colours.WHITE) {
            targetPosition = selfPosition.getTop().getLeft();
        }
        else {
            targetPosition = selfPosition.getBottom().getRight();
        }
        if (targetPosition.isOnBoard()) {
            targetPiece = board.getPieceAt(targetPosition);
            if  (targetPiece != null && targetPiece.getColour() != getColour()) {
                possibleMoves.add(targetPosition);
            }
        }

        // Check front right
        if (getColour() == Colours.WHITE) {
            targetPosition = selfPosition.getTop().getRight();
        }
        else {
            targetPosition = selfPosition.getBottom().getLeft();
        }
        if (targetPosition.isOnBoard()) {
            targetPiece = board.getPieceAt(targetPosition);
            if (targetPiece != null && targetPiece.getColour() != getColour()) {
                possibleMoves.add(targetPosition);
            }
        }

        return possibleMoves;
    }

    public boolean checkForCheck(Board board, Position kingPosition) {
        return getPossibleMoves(board).contains(kingPosition);
    }

    public char type() {
        return 'P';
    }
}
