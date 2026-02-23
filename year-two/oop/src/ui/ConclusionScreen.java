package ui;

import app.Main;
import model.ExitCodes;
import model.Game;
import model.User;

import javax.swing.*;
import javax.swing.border.CompoundBorder;
import javax.swing.border.EmptyBorder;
import javax.swing.border.LineBorder;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.MouseAdapter;
import java.awt.event.MouseEvent;

public class ConclusionScreen extends JFrame {
    private static final int SCREEN_WIDTH = 1500;
    private static final int SCREEN_HEIGHT = 1000;

    private static final Color MY_WHITE = new Color(245, 245, 250);
    private static final Color MY_GREEN = new Color(38, 173, 46);
    private static final Color MY_BLUE = new Color(34, 42, 116);
    private static final Color MY_LIGHT_BLUE = new Color(161, 199, 235);
    private static final Color MY_RED = new Color(229, 45, 45);

    public ConclusionScreen(Game game, ExitCodes exitCode) {
        super("Game Over");
        this.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        this.setSize(SCREEN_WIDTH, SCREEN_HEIGHT);
        this.setLocationRelativeTo(null);
        this.setLayout(new GridBagLayout());
        this.getContentPane().setBackground(MY_LIGHT_BLUE);

        // Content card
        JPanel cardPanel = new JPanel();
        cardPanel.setLayout(new BoxLayout(cardPanel, BoxLayout.Y_AXIS));
        cardPanel.setBackground(MY_WHITE);
        cardPanel.setMaximumSize(new Dimension(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2));
        LineBorder line = new LineBorder(MY_BLUE, 4);
        EmptyBorder margin = new EmptyBorder(40, 60, 40, 60);
        cardPanel.setBorder(new CompoundBorder(line, margin));

        // Win/Loss message
        JLabel titleLabel = new JLabel(getConclusionTitle(exitCode));
        titleLabel.setFont(new Font("SansSerif", Font.BOLD, 32));
        titleLabel.setAlignmentX(Component.CENTER_ALIGNMENT);
        titleLabel.setForeground(MY_BLUE);

        // Points
        int pointsChange = Main.getInstance().gameConclusion(game, exitCode);
        JLabel pointsLabel = new JLabel(pointsChange + " Points");
        pointsLabel.setFont(new Font("SansSerif", Font.BOLD, 48));
        pointsLabel.setAlignmentX(Component.CENTER_ALIGNMENT);
        if (pointsChange >= 0) {
            pointsLabel.setForeground(MY_GREEN);
        }
        else {
            pointsLabel.setForeground(MY_RED);
        }

        // Extra text
        JLabel subtitleLabel = new JLabel(getConclusionSubtitle(exitCode));
        subtitleLabel.setFont(new Font("SansSerif", Font.BOLD, 18));
        subtitleLabel.setAlignmentX(Component.CENTER_ALIGNMENT);
        subtitleLabel.setForeground(Color.GRAY);

        // Buttons panel
        JPanel buttonPanel = new JPanel(new FlowLayout(FlowLayout.CENTER, 20, 20));
        buttonPanel.setBackground(MY_WHITE);
        buttonPanel.setAlignmentX(Component.CENTER_ALIGNMENT);
        buttonPanel.setMaximumSize(new Dimension(SCREEN_WIDTH, 100));

        JButton menuButton = new JButton("Back to Main Menu");
        menuButton.setPreferredSize(new Dimension(200, 50));
        styleButton(menuButton, MY_GREEN);
        menuButton.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent e) {
                returnToMenu();
            }
        });

        JButton exitButton = new JButton("Exit App");
        exitButton.setPreferredSize(new Dimension(200, 50));
        styleButton(exitButton, MY_BLUE);
        exitButton.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent e) {
                exitApp();
            }
        });

        buttonPanel.add(menuButton);
        buttonPanel.add(exitButton);

        // Assembly
        cardPanel.add(titleLabel);
        cardPanel.add(Box.createVerticalStrut(20));
        cardPanel.add(pointsLabel);
        cardPanel.add(Box.createVerticalStrut(10));
        cardPanel.add(subtitleLabel);
        cardPanel.add(Box.createVerticalStrut(40));
        cardPanel.add(buttonPanel);

        // Constraints
        GridBagConstraints constraints = new GridBagConstraints();
        constraints.gridx = 0;
        constraints.gridy = 0;
        constraints.weightx = 1.0;
        constraints.weighty = 1.0;
        constraints.anchor = GridBagConstraints.CENTER;

        this.add(cardPanel, constraints);
        this.setVisible(true);
    }

    private String getConclusionTitle(ExitCodes code) {
        switch (code) {
            case WIN_CHECKMATE: return "VICTORY!";
            case LOSE_CHECKMATE: return "DEFEAT";
            case DRAW: return "DRAW";
            case SURRENDER: return "SURRENDERED";
            default: return "GAME OVER";
        }
    }

    private String getConclusionSubtitle(ExitCodes code) {
        switch (code) {
            case WIN_CHECKMATE: return "Checkmate! Well played.";
            case LOSE_CHECKMATE: return "You were checkmated.";
            case DRAW: return "Stalemate or Repetition.";
            case SURRENDER: return "You have surrendered the game.";
            default: return "";
        }
    }

    private void styleButton(JButton button, Color baseColour) {
        button.setFont(new Font("SansSerif", Font.BOLD, 14));
        button.setForeground(Color.WHITE);
        button.setBackground(baseColour);
        button.setFocusPainted(false);
        button.setCursor(new Cursor(Cursor.HAND_CURSOR));

        LineBorder line = new LineBorder(baseColour, 2);
        EmptyBorder margin = new EmptyBorder(5, 15, 5, 15);
        button.setBorder(new CompoundBorder(line, margin));

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

    private void returnToMenu() {
        // Reload the data from disk before heading to the main menu
        Main.getInstance().reload();
        User reloadedUser = Main.getInstance().getCurrentUser();

        SwingUtilities.invokeLater(() -> {
            try {
                // Create and show the new screen, then dispose of the old one
                new MainScreen(reloadedUser);
                this.dispose();
            }
            catch (Exception e) {
                JOptionPane.showMessageDialog(this, "Error loading menu: " + e.getMessage());
            }
        });
    }

    private void exitApp() {
        System.exit(0);
    }
}
