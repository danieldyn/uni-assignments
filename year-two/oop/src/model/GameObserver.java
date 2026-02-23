package model;

import model.pieces.Pawn;
import model.pieces.Piece;

public interface GameObserver {
    void onMoveMade(Move move);
    void onPieceCaptured(Piece piece);
    void onPlayerSwitch(Player currentPlayer);
    void onPawnPromotion(Pawn pawn);
    void onComputerPawnPromotion();
}