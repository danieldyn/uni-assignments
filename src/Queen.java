import java.util.List;

public class Queen extends Piece {
    public Queen(Colours colour, Position position) {
        super(colour, position);
    }

    public Queen(String colour, String position) {
        super(colour, position);
    }

    public List<Position> getPossibleMoves(Board board) {
        Bishop bishop = new Bishop(getColour(), getPosition());
        Rook rook = new Rook(getColour(), getPosition());

        // Queen = Bishop + Rook
        List<Position> possibleMoves = bishop.getPossibleMoves(board);
        List<Position> possibleMovesRook = rook.getPossibleMoves(board);

        possibleMoves.addAll(possibleMovesRook);
        return possibleMoves;
    }

    public boolean checkForCheck(Board board, Position kingPosition) {
        return getPossibleMoves(board).contains(kingPosition);
    }

    public char type() {
        return 'Q';
    }
}
