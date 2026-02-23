package model.pieces;

import model.Board;
import model.Colours;
import model.Position;
import model.strategies.QueenMoveStrategy;

import java.util.List;

public class Queen extends Piece {
    public Queen(Colours colour, Position position) {
        super(colour, position);
        this.moveStrategy = new QueenMoveStrategy(colour);
    }

    public Queen(String colour, String position) {
        super(colour, position);
        this.moveStrategy = new QueenMoveStrategy(colour);
    }

    public List<Position> getPossibleMoves(Board board) {
        return moveStrategy.getPossibleMoves(board, getPosition());
    }

    public boolean checkForCheck(Board board, Position kingPosition) {
        return getPossibleMoves(board).contains(kingPosition);
    }

    public char type() {
        return 'Q';
    }
}
