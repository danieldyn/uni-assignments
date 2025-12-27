package ui;

import app.Main;
import model.ExitCodes;
import model.Game;
import model.User;
import ui.components.BoardPanel;
import ui.components.CapturedPieceHistoryPanel;
import ui.components.MoveHistoryPanel;

import javax.swing.*;
import javax.swing.border.CompoundBorder;
import javax.swing.border.EmptyBorder;
import javax.swing.border.LineBorder;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.MouseAdapter;
import java.awt.event.MouseEvent;
import java.util.List;

public class GameScreen extends JFrame {
    private User currentUser;
    private Game currentGame;

    private static final int SCREEN_WIDTH = 1500;
    private static final int SCREEN_HEIGHT = 1000;
    private static final Color MY_WHITE = new Color(245, 245, 250);
    private static final Color MY_GREEN = new Color(38, 173, 46);
    private static final Color MY_BLUE = new Color(34, 42, 116);
    private static final Color MY_LIGHT_BLUE = new Color(161, 199, 235);
    private static final Color MY_GREY = new Color(124, 140, 163);
    private static final Color MY_LIGHT_GRAY = new Color(156, 156, 156);
    private static final Color MY_RED = new Color(229, 45, 45);

    public GameScreen(User user, Game game) {
        super("Chess Game");
        currentUser = user;
        currentGame = game;
        this.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        this.setSize(SCREEN_WIDTH, SCREEN_HEIGHT);
        this.setLocationRelativeTo(null);
        this.setLayout(new BorderLayout());

        // Header (North)
        JPanel headerPanel = new JPanel();
        headerPanel.setLayout(new BorderLayout());
        headerPanel.setBackground(MY_GREEN);
        headerPanel.setBorder(new EmptyBorder(15, 25, 15, 25));

        // Top left: icon + game
        JPanel titlePanel = new JPanel(new FlowLayout(FlowLayout.LEFT, 15, 0));
        titlePanel.setOpaque(false);

        // Icon setup
        JLabel iconLabel = new JLabel();
        try {
            ImageIcon icon = new ImageIcon("assets/icons/game.png");
            // Scale to 40x40 px
            Image scaledImage = icon.getImage().getScaledInstance(45, 45, Image.SCALE_SMOOTH);
            iconLabel.setIcon(new ImageIcon(scaledImage));
        }
        catch (Exception e) {
            // Unicode knight fallback
            iconLabel.setText("♞");
            iconLabel.setFont(new Font("Serif", Font.BOLD, 40));
            iconLabel.setForeground(MY_WHITE);
        }

        // Main menu title
        JLabel titleLabel = new JLabel("Chess Game");
        titleLabel.setFont(new Font("SansSerif", Font.BOLD, 26));
        titleLabel.setForeground(MY_WHITE);

        titlePanel.add(iconLabel);
        titlePanel.add(titleLabel);

        // Top right: involved players
        JPanel userPanel = new JPanel(new FlowLayout(FlowLayout.RIGHT));
        userPanel.setOpaque(false);
        JLabel userLabel = new JLabel( " (" + user.getPoints() + ") " + user.getEmail() + " versus Computer");
        userLabel.setFont(new Font("SansSerif", Font.BOLD, 16));
        userLabel.setForeground(MY_WHITE);

        userPanel.add(userLabel);

        // Header assembly
        headerPanel.add(titlePanel, BorderLayout.WEST);
        headerPanel.add(userPanel, BorderLayout.EAST);

        // Centre: main content displayed horizontally
        JPanel centrePanel = new JPanel();
        centrePanel.setBackground(MY_LIGHT_BLUE);
        centrePanel.setLayout(new GridBagLayout());
        centrePanel.setBorder(new LineBorder(MY_BLUE, 2));

        // Move history on the left
        JPanel moveHistoryPanel = new MoveHistoryPanel(game);
        JScrollPane scrollPane = new JScrollPane(moveHistoryPanel);
        scrollPane.setPreferredSize(new Dimension(225, 0));
        scrollPane.getVerticalScrollBar().setUnitIncrement(16);

        // Interactive board in the centre
        JPanel boardPanel = new BoardPanel(user, game, this);
        centrePanel.add(boardPanel);

        // Panel with captured pieces and action buttons on the right
        JPanel utilPanel = new JPanel(new GridBagLayout());
        utilPanel.setBackground(MY_LIGHT_BLUE);

        GridBagConstraints constraints = new GridBagConstraints();
        constraints.gridx = 0;
        constraints.gridy = 0;
        utilPanel.add(new CapturedPieceHistoryPanel(game), constraints);
        constraints.gridy++;
        constraints.insets = new Insets(20, 0, 0, 0);

        JButton saveButton = new JButton("Save & Exit");
        saveButton.setPreferredSize(new Dimension(175, 50));
        styleButton(saveButton, MY_GREEN);
        saveButton.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent e) {
                saveGame();
            }
        });
        utilPanel.add(saveButton, constraints);
        constraints.gridy++;

        JButton surrenderButton = new JButton("Surrender");
        surrenderButton.setPreferredSize(new Dimension(175, 50));
        styleButton(surrenderButton, MY_RED);
        surrenderButton.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent e) {
                surrender();
            }
        });
        utilPanel.add(surrenderButton, constraints);
        constraints.gridy++;

        JButton quitButton = new JButton("Quit Without Saving");
        quitButton.setPreferredSize(new Dimension(175, 50));
        styleButton(quitButton, MY_BLUE);
        quitButton.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent e) {
                quitGame();
            }
        });
        utilPanel.add(quitButton, constraints);

        // Final assembly
        this.add(headerPanel, BorderLayout.NORTH);
        this.add(scrollPane, BorderLayout.WEST);
        this.add(centrePanel, BorderLayout.CENTER);
        this.add(utilPanel, BorderLayout.EAST);

        this.setVisible(true);
    }

    private void styleButton(JButton button, Color baseColour) {
        button.setFont(new Font("SansSerif", Font.BOLD, 14));
        button.setForeground(Color.WHITE);
        button.setBackground(baseColour);
        button.setFocusPainted(false); // Helps when clicking
        button.setCursor(new Cursor(Cursor.HAND_CURSOR)); // Turns cursor into a hand

        // Line border with padding
        LineBorder line = new LineBorder(baseColour, 2);
        EmptyBorder margin = new EmptyBorder(5, 15, 5, 15);
        button.setBorder(new CompoundBorder(line, margin));

        // Mouse hovering effect
        button.addMouseListener(new MouseAdapter() {
            public void mouseEntered(MouseEvent e) {
                button.setBackground(Color.WHITE);
                button.setForeground(baseColour);
            }

            public void mouseExited(MouseEvent e) {
                button.setBackground(baseColour);
                button.setForeground(Color.WHITE);
            }
        });
    }

    private void saveGame() {
        // Save game changes
        Main.getInstance().write();
        Main.getInstance().reload();
        this.dispose();
        new MainScreen(currentUser);
    }

    private void quitGame() {
        int response = JOptionPane.showConfirmDialog(this,
                "Are you sure you want to quit? Unsaved progress will be lost.",
                "Confirm Quit", JOptionPane.YES_NO_OPTION, JOptionPane.WARNING_MESSAGE);

        if (response == JOptionPane.YES_OPTION) {
            Main.getInstance().reload();
            User currentUser = Main.getInstance().getCurrentUser();
            // Return to Main Screen
            this.dispose();
            new MainScreen(currentUser);
        }
    }

    private void surrender() {
        int response = JOptionPane.showConfirmDialog(this,
                "Are you sure you want to surrender? You will be deducted points for this.",
                "Confirm Surrender", JOptionPane.YES_NO_OPTION, JOptionPane.WARNING_MESSAGE);

        if (response == JOptionPane.YES_OPTION) {
            this.dispose();
            new ConclusionScreen(currentGame, ExitCodes.SURRENDER);
        }
    }
}
