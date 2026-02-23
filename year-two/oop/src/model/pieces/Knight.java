package model.pieces;

import model.Board;
import model.Colours;
import model.Position;
import model.strategies.KnightMoveStrategy;

import java.util.ArrayList;
import java.util.List;

public class Knight extends Piece {
    public Knight(Colours colour, Position position) {
        super(colour, position);
        this.moveStrategy = new KnightMoveStrategy(colour);
    }

    public Knight(String colour, String position) {
        super(colour, position);
        this.moveStrategy = new KnightMoveStrategy(colour);
    }

    public List<Position> getPossibleMoves(Board board) {
        return moveStrategy.getPossibleMoves(board, getPosition());
    }

    public boolean checkForCheck(Board board, Position kingPosition) {
        return getPossibleMoves(board).contains(kingPosition);
    }

    public char type() {
        return 'N';
    }
}
