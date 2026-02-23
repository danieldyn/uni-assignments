package model.pieces;

import model.Board;
import model.Colours;
import model.Position;
import model.strategies.KingMoveStrategy;

import java.util.List;

public class King extends Piece {
    public King(Colours colour, Position position) {
        super(colour, position);
        this.moveStrategy = new KingMoveStrategy(colour);
    }

    public King(String colour, String position) {
        super(colour, position);
        this.moveStrategy = new KingMoveStrategy(colour);
    }

    public List<Position> getPossibleMoves(Board board) {
        return moveStrategy.getPossibleMoves(board, getPosition());
    }

    public boolean checkForCheck(Board board, Position kingPosition) {
        return getPossibleMoves(board).contains(kingPosition);
    }

    public char type() {
        return 'K';
    }
}
