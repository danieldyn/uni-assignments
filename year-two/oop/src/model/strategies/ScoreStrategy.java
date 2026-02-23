package model.strategies;

import model.pieces.Piece;

public interface ScoreStrategy {
    int getScoreForCapture(Piece capturedPiece);
    int getScoreForDraw();
    int getScoreForSurrender();
    int getScoreForWin();
    int getScoreForLoss();
}
