package ui.components;

import model.Game;
import model.GameObserver;
import model.Move;
import model.Player;
import model.pieces.Pawn;
import model.pieces.Piece;

import javax.swing.*;
import javax.swing.border.EmptyBorder;
import javax.swing.border.LineBorder;
import javax.swing.border.TitledBorder;
import java.awt.*;
import java.util.List;

public class MoveHistoryPanel extends JPanel implements GameObserver {
    private List<Move> moves;
    private GridBagConstraints constraints;
    private int index = 1;
    private JPanel listPanel;

    private static final Color MY_LIGHT_BLUE = new Color(161, 199, 235);
    private static final Color MY_BLUE = new Color(34, 42, 116);
    private static final Color MY_WHITE = new Color(245, 245, 250);

    public MoveHistoryPanel(Game game) {
        this.moves = game.getMoves();
        game.addObserver(this);

        this.setLayout(new BorderLayout());
        this.setBackground(MY_LIGHT_BLUE);
        this.setBorder(new EmptyBorder(10, 10, 10, 10));

        // Inner container (panel)
        listPanel = new JPanel(new GridBagLayout());
        listPanel.setBackground(MY_WHITE);
        listPanel.setBorder(new TitledBorder( new LineBorder(MY_BLUE, 4), "Move History",
                        TitledBorder.LEFT, TitledBorder.TOP, new Font("SansSerif", Font.BOLD, 20)
        ));

        // List constraints
        constraints = new GridBagConstraints();
        constraints.insets = new Insets(2, 5, 2, 5);
        constraints.anchor = GridBagConstraints.NORTH;
        constraints.fill = GridBagConstraints.HORIZONTAL;
        constraints.weightx = 1.0;
        constraints.gridx = 0;
        constraints.gridy = 0;

        for (Move m : moves) {
            addMoveToPanel(m);
        }

        // 5. Add a "Pusher" component to force items to the top
        // This prevents the list from vertically centering if there are few moves
        //GridBagConstraints pushConstraints = new GridBagConstraints();
        //pushConstraints.gridx = 0;
        //pushConstraints.gridy = 9999;
        //pushConstraints.weighty = 1.0; // Consume all vertical space
        //listPanel.add(new JPanel() {{ setOpaque(false); }}, pushConstraints);

        // Assembly
        this.add(listPanel, BorderLayout.CENTER);
    }

    private void addMoveToPanel(Move move) {
        MoveCard card = new MoveCard(index++ + ". " + move.toString());
        listPanel.add(card, constraints);
        constraints.gridy++; // Move to next row
    }

    // Inner class for the rows
    private static class MoveCard extends JPanel {
        public MoveCard(String content) {
            this.setLayout(new FlowLayout(FlowLayout.LEFT));
            this.setOpaque(false);

            JLabel contentLabel = new JLabel(content);
            contentLabel.setFont(new Font("SansSerif", Font.BOLD, 15));
            this.add(contentLabel);
        }
    }

    public void onMoveMade(Move move) {
        addMoveToPanel(move);

        // Refresh UI
        this.revalidate();
        this.repaint();
    }

    public void onPieceCaptured(Piece piece) { }

    public void onPlayerSwitch(Player currentPlayer) { }

    public void onPawnPromotion(Pawn pawn) { }

    public void onComputerPawnPromotion() { }
}