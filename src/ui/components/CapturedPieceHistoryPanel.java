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
import java.util.Comparator;
import java.util.List;

public class CapturedPieceHistoryPanel extends JPanel implements GameObserver {
    private final Game game;
    private final JPanel humanCapturedPanel;
    private final JPanel computerCapturedPanel;

    private static final String W_KING = "♔";
    private static final String W_QUEEN = "♕";
    private static final String W_ROOK = "♖";
    private static final String W_BISHOP = "♗";
    private static final String W_KNIGHT = "♘";
    private static final String W_PAWN = "♙";

    private static final String B_KING = "♚";
    private static final String B_QUEEN = "♛";
    private static final String B_ROOK = "♜";
    private static final String B_BISHOP = "♝";
    private static final String B_KNIGHT = "♞";
    private static final String B_PAWN = "♟";

    private static final Color MY_LIGHT_BLUE = new Color(161, 199, 235);
    private static final Color MY_BLUE = new Color(34, 42, 116);
    private static final Color MY_WHITE = new Color(245, 245, 250);

    public CapturedPieceHistoryPanel(Game game) {
        this.game = game;
        game.addObserver(this);

        // Vertical stack
        this.setLayout(new BoxLayout(this, BoxLayout.Y_AXIS));
        this.setBorder(new EmptyBorder(10, 10, 10, 10));
        this.setBackground(MY_LIGHT_BLUE);
        humanCapturedPanel = createSectionPanel("Your Captures");
        computerCapturedPanel = createSectionPanel("Opponent's Captures");

        // Final assembly
        this.add(humanCapturedPanel);
        this.add(Box.createVerticalStrut(15)); // Spacer
        this.add(computerCapturedPanel);
        refreshView();
    }

    private JPanel createSectionPanel(String title) {
        JPanel panel = new JPanel();
        panel.setLayout(new FlowLayout(FlowLayout.LEFT, 5, 5));
        panel.setBackground(MY_WHITE);

        panel.setBorder(new TitledBorder(new LineBorder(MY_BLUE, 4), title,
                TitledBorder.LEFT, TitledBorder.TOP, new Font("SansSerif", Font.BOLD, 20)
        ));

        panel.setPreferredSize(new Dimension(250, 300));
        return panel;
    }

    private void refreshView() {
        // Clear old data
        humanCapturedPanel.removeAll();
        computerCapturedPanel.removeAll();
        Player human = game.getHumanPlayer();
        Player computer = game.getComputerPlayer();

        // Refresh panels
        if (human != null) {
            fillPanel(humanCapturedPanel, human.getCapturedPieces());
        }
        if (computer != null) {
            fillPanel(computerCapturedPanel, computer.getCapturedPieces());
        }

        this.revalidate();
        this.repaint();
    }

    private void fillPanel(JPanel panel, List<Piece> pieces) {
        if (pieces == null) {
            return;
        }

        // Sort by class name for even layout
        pieces.sort(new Comparator<Piece>() {
            public int compare(Piece o1, Piece o2) {
                return o1.getClass().getName().compareTo(o2.getClass().getName());
            }
        });

        for (Piece p : pieces) {
            JLabel label = new JLabel(getUnicodeSymbol(p));
            label.setFont(new Font("Serif", Font.PLAIN, 40));
            panel.add(label);
        }
    }

    private String getUnicodeSymbol(Piece p) {
        boolean isWhite = p.getColour().toString().equals("WHITE");
        char type = p.type();

        if (isWhite) {
            switch (type) {
                case 'K': return W_KING;
                case 'Q': return W_QUEEN;
                case 'R': return W_ROOK;
                case 'B': return W_BISHOP;
                case 'N': return W_KNIGHT;
                case 'P': return W_PAWN;
                default: return "?";
            }
        } else {
            switch (type) {
                case 'K': return B_KING;
                case 'Q': return B_QUEEN;
                case 'R': return B_ROOK;
                case 'B': return B_BISHOP;
                case 'N': return B_KNIGHT;
                case 'P': return B_PAWN;
                default: return "?";
            }
        }
    }

    public void onMoveMade(Move move) { }

    public void onPieceCaptured(Piece piece) {
        refreshView();
    }

    public void onPlayerSwitch(Player currentPlayer) { }

    public void onPawnPromotion(Pawn pawn) { }

    public void onComputerPawnPromotion() { }
}
