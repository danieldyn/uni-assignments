package model.pieces;

import model.Board;
import model.Colours;
import model.Position;
import model.strategies.PawnMoveStrategy;

import java.util.List;
import java.util.ArrayList;

public class Pawn extends Piece {
    public Pawn(Colours colour, Position position) {
        super(colour, position);
        this.moveStrategy = new PawnMoveStrategy(colour);
    }

    public Pawn(String colour, String position) {
        super(colour, position);
        this.moveStrategy = new PawnMoveStrategy(colour);
    }

    public List<Position> getPossibleMoves(Board board) {
        return moveStrategy.getPossibleMoves(board, getPosition());
    }

    public boolean checkForCheck(Board board, Position kingPosition) {
        return getPossibleMoves(board).contains(kingPosition);
    }

    public char type() {
        return 'P';
    }
}
