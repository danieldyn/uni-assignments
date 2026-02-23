package model.pieces;

import model.Board;
import model.Colours;
import model.Position;
import model.strategies.RookMoveStrategy;

import java.util.List;

public class Rook extends Piece {
    public Rook(Colours colour, Position position) {
        super(colour, position);
        this.moveStrategy = new RookMoveStrategy(colour);
    }

    public Rook(String colour, String position) {
        super(colour, position);
        this.moveStrategy = new RookMoveStrategy(colour);
    }

    public List<Position> getPossibleMoves(Board board) {
        return moveStrategy.getPossibleMoves(board, getPosition());
    }

    public boolean checkForCheck(Board board, Position kingPosition) {
        return getPossibleMoves(board).contains(kingPosition);
    }

    public char type() {
        return 'R';
    }
}
