package model.strategies;

import model.Board;
import model.Colours;
import model.Position;

import java.util.List;

public class QueenMoveStrategy implements MoveStrategy {
    private final Colours colour;

    public QueenMoveStrategy(Colours colour) {
        this.colour = colour;
    }

    public QueenMoveStrategy(String colour) {
        this.colour = Colours.valueOf(colour);
    }

    public List<Position> getPossibleMoves(Board board, Position from) {
        BishopMoveStrategy strategy1 = new BishopMoveStrategy(colour);
        RookMoveStrategy strategy2 = new RookMoveStrategy(colour);

        List<Position> possibleMoves = strategy1.getPossibleMoves(board, from);
        List<Position> possibleMoves2 = strategy2.getPossibleMoves(board, from);
        possibleMoves.addAll(possibleMoves2);

        return possibleMoves;
    }
}
