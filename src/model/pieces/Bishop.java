package model.pieces;

import model.Board;
import model.Colours;
import model.Position;
import model.strategies.BishopMoveStrategy;

import java.util.List;

public class Bishop extends Piece {
    public Bishop(Colours colour, Position position) {
        super(colour, position);
        this.moveStrategy = new BishopMoveStrategy(colour);
    }

    public Bishop(String colour, String position) {
        super(colour, position);
        this.moveStrategy = new BishopMoveStrategy(colour);
    }

    public List<Position> getPossibleMoves(Board board) {
        return moveStrategy.getPossibleMoves(board, getPosition());
    }

    public boolean checkForCheck(Board board, Position kingPosition) {
        return getPossibleMoves(board).contains(kingPosition);
    }

    public char type() {
        return 'B';
    }
}
