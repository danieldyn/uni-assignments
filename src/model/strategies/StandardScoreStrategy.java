package model.strategies;

import model.pieces.Piece;

public class StandardScoreStrategy implements ScoreStrategy {
    public int getScoreForCapture(Piece capturedPiece) {
        if (capturedPiece == null) {
            return 0;
        }

        switch (capturedPiece.type()) {
            case 'P': return 10;
            case 'N':
                case 'B': return 30;
            case 'R': return 50;
            case 'Q': return 90;
            default: return 0;
        }
    }

    public int getScoreForDraw() {
        return 150;
    }

    public int getScoreForSurrender() {
        return -150;
    }

    public int getScoreForWin() {
        return 300;
    }

    public int getScoreForLoss() {
        return -300;
    }
}
