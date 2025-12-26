package ui.components;

import model.Game;
import model.GameObserver;
import model.Move;
import model.Player;
import model.pieces.Pawn;
import model.pieces.Piece;

import javax.swing.*;
import javax.swing.border.EmptyBorder;
import java.awt.*;
import java.util.List;

public class MoveHistoryPanel extends JPanel implements GameObserver {
    private List<Move> moves;
    private final Color MY_LIGHT_BLUE = new Color(161, 199, 235);
    private GridBagConstraints constraints;
    private int index = 1;

    public MoveHistoryPanel(Game game) {
        this.moves = game.getMoves();
        game.addObserver(this);
        this.setBackground(MY_LIGHT_BLUE);
        this.setBorder(new EmptyBorder(5, 5, 5, 5));
        this.setLayout(new GridBagLayout());

        constraints = new GridBagConstraints();
        constraints.insets = new Insets(5, 5, 5, 5);
        constraints.anchor = GridBagConstraints.NORTH;
        constraints.gridx = 0;
        constraints.gridy = 0;

        JLabel title = new JLabel("Move History");
        title.setFont(new Font("SansSerif", Font.BOLD, 20));
        this.add(title, constraints);
        constraints.gridy++;

        for (Move m : moves) {
            this.add(new MoveCard(index++ + ". " + m.toString()), constraints);
            constraints.gridy++;
        }
    }

    // Inner class
    private static class MoveCard extends JPanel {
        public MoveCard(String content) {
            this.setLayout(new GridBagLayout());
            JLabel contentLabel = new JLabel(content);
            contentLabel.setFont(new Font("SansSerif", Font.BOLD, 15));
            this.add(contentLabel);
        }
    }

    public void onMoveMade(Move move) {
        this.add(new MoveCard(index++ + ". " + move.toString()), constraints);
        constraints.gridy++;
        this.revalidate();
        this.repaint();
    }

    public void onPieceCaptured(Piece piece) { }

    public void onPlayerSwitch(Player currentPlayer) { }

    public void onPawnPromotion(Pawn pawn) { }
}
