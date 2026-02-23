package model.strategies;

import model.Board;
import model.Position;

import java.util.List;

public interface MoveStrategy {
    List<Position> getPossibleMoves(Board board, Position from);
}
