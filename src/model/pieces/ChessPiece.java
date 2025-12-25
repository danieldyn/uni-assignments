package model.pieces;

import model.Board;
import model.Position;

import java.util.List;

public interface ChessPiece {
    List<Position> getPossibleMoves(Board board);
    boolean checkForCheck(Board board, Position kingPosition);
    char type();
}
