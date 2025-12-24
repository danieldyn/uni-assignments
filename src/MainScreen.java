import javax.swing.*;
import javax.swing.border.CompoundBorder;
import javax.swing.border.EmptyBorder;
import javax.swing.border.LineBorder;
import java.awt.*;
import java.awt.event.MouseAdapter;
import java.awt.event.MouseEvent;
import java.util.List;

public class MainScreen extends JFrame {
    private static final int SCREEN_WIDTH = 1500;
    private static final int SCREEN_HEIGHT = 750;
    private final Color MY_WHITE = new Color(245, 245, 250);
    private final Color MY_GREEN = new Color(38, 173, 46);
    private final Color MY_BLUE = new Color(34, 56, 214);
    private final Color MY_LIGHT_BLUE = new Color(161, 199, 235);
    private final Color MY_GREY = new Color(124, 140, 163);
    private final Color MY_LIGHT_GRAY = new Color(156, 156, 156);

    public MainScreen(User user) {
        super("Chess App - Main Menu");
        this.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        this.setSize(SCREEN_WIDTH, SCREEN_HEIGHT);
        this.setLocationRelativeTo(null);
        this.setLayout(new BorderLayout());

        // Header (North)
        JPanel headerPanel = new JPanel();
        headerPanel.setLayout(new BorderLayout());
        headerPanel.setBackground(MY_GREEN);
        headerPanel.setBorder(new EmptyBorder(15, 25, 15, 25));

        // Top left: icon + "Main Menu"
        JPanel titlePanel = new JPanel(new FlowLayout(FlowLayout.LEFT, 15, 0));
        titlePanel.setOpaque(false);

        // Icon setup
        JLabel iconLabel = new JLabel();
        try {
            ImageIcon icon = new ImageIcon("assets/icons/game_icon.png");
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
        JLabel titleLabel = new JLabel("Main Menu");
        titleLabel.setFont(new Font("SansSerif", Font.BOLD, 26));
        titleLabel.setForeground(MY_WHITE);

        titlePanel.add(iconLabel);
        titlePanel.add(titleLabel);

        // Top right: "Logged in as: username"
        JPanel userPanel = new JPanel(new FlowLayout(FlowLayout.RIGHT));
        userPanel.setOpaque(false);
        JLabel userLabel = new JLabel("Logged in as: " + user.getEmail());
        userLabel.setFont(new Font("SansSerif", Font.BOLD, 16));
        userLabel.setForeground(MY_WHITE);

        userPanel.add(userLabel);

        // Header assembly
        headerPanel.add(titlePanel, BorderLayout.WEST);
        headerPanel.add(userPanel, BorderLayout.EAST);

        // Centre: main content displayed vertically
        JPanel centrePanel = new JPanel();
        centrePanel.setBackground(MY_LIGHT_GRAY);
        centrePanel.setLayout(new GridBagLayout());
        centrePanel.setBorder(new EmptyBorder(30, SCREEN_WIDTH / 4, 30, SCREEN_WIDTH / 4));

        GridBagConstraints constraints = new GridBagConstraints();
        constraints.fill = GridBagConstraints.HORIZONTAL;
        constraints.weightx = 0.4;
        constraints.anchor = GridBagConstraints.NORTH;

        // User stat card at the top
        constraints.gridx = 0;
        constraints.gridy = 0;

        JPanel statsContainer = new JPanel(new GridLayout(1, 2, 20, 0));
        statsContainer.setBackground(MY_LIGHT_GRAY);
        statsContainer.add(createStatisticCard("Total Points", String.valueOf(user.getPoints()), "★", Color.ORANGE));
        statsContainer.add(createStatisticCard("Active Games", String.valueOf(user.getActiveGames().size()), "♟", MY_GREEN));
        constraints.insets = new Insets(0,0, 30, 0);
        centrePanel.add(statsContainer, constraints);

        // Resume existing game
        constraints.gridy++;
        constraints.insets = new Insets(0, 0, 15, 0);
        JPanel continueCard = createMenuCard("Resume Game", "Continue a game in progress.");
        continueCard.addMouseListener(new MouseAdapter() {
            public void mouseClicked(MouseEvent e) {
                handleResumeGame();
            }
        });
        centrePanel.add(continueCard, constraints);

        // New game
        constraints.gridy++;
        constraints.insets = new Insets(0, 0, 15, 0);
        JPanel newGameCard = createMenuCard("New Game", "Start a new game against the computer");
        newGameCard.addMouseListener(new MouseAdapter() {
            public void mouseClicked(MouseEvent e) {
                handleNewGame();
            }
        });
        centrePanel.add(newGameCard, constraints);

        // Logout
        constraints.gridy++;
        constraints.insets = new Insets(0, 0, 50, 0);
        JPanel logoutCard = createMenuCard("Logout", "Return to the login screen");
        logoutCard.addMouseListener(new MouseAdapter() {
            public void mouseClicked(MouseEvent e) {
                handleLogout();
            }
        });
        centrePanel.add(logoutCard, constraints);

        // Final assembly
        this.add(headerPanel, BorderLayout.NORTH);
        this.add(centrePanel, BorderLayout.CENTER);

        this.setVisible(true);
    }

    private JPanel createStatisticCard(String title, String value, String iconUnicode, Color colour) {
        JPanel card = new JPanel(new GridBagLayout());
        LineBorder line = new LineBorder(MY_GREY, 2);
        EmptyBorder margin = new EmptyBorder(15, 20, 15, 20);
        card.setBackground(MY_LIGHT_BLUE);
        card.setBorder(new CompoundBorder(line, margin));

        GridBagConstraints constraints = new GridBagConstraints();
        constraints.gridx = 0;
        constraints.gridy = 0;
        constraints.anchor = GridBagConstraints.CENTER;

        // Icon on the left
        JLabel icon = new JLabel(iconUnicode);
        icon.setFont(new Font("SansSerif", Font.PLAIN, 40));
        icon.setForeground(colour);
        card.add(icon, constraints);

        // Statistic in the centre
        constraints.gridy++;
        JLabel valLabel = new JLabel(value);
        valLabel.setFont(new Font("SansSerif", Font.BOLD, 36));
        valLabel.setForeground(Color.DARK_GRAY);
        card.add(valLabel, constraints);

        // Title on the right
        constraints.gridy++;
        JLabel titleLabel = new JLabel(title);
        titleLabel.setFont(new Font("SansSerif", Font.BOLD, 18));
        titleLabel.setForeground(MY_GREY);
        card.add(titleLabel, constraints);

        return card;
    }

    private JPanel createMenuCard(String title, String subtitle) {
        JPanel card = new JPanel();
        card.setLayout(new GridBagLayout());
        card.setBackground(MY_WHITE);
        card.setCursor(new Cursor(Cursor.HAND_CURSOR));

        // Line border with padding
        LineBorder line = new LineBorder(MY_GREY, 2);
        EmptyBorder margin = new EmptyBorder(20, 20, 20, 20);
        card.setBorder(new CompoundBorder(line, margin));

        // Card contents
        GridBagConstraints constraints = new GridBagConstraints();
        constraints.gridx = 0;
        constraints.gridy = 0;

        JLabel titleLabel = new JLabel(title);
        titleLabel.setFont(new Font("SansSerif", Font.BOLD, 22));
        titleLabel.setForeground(MY_BLUE);
        card.add(titleLabel, constraints);

        constraints.gridy++;
        constraints.insets = new Insets(10, 0, 0, 0);

        JLabel subLabel = new JLabel(subtitle);
        subLabel.setFont(new Font("SansSerif", Font.PLAIN, 16));
        subLabel.setForeground(Color.GRAY);
        card.add(subLabel, constraints);

        // Mouse hover effect
        card.addMouseListener(new MouseAdapter() {
            public void mouseEntered(MouseEvent e) {
                card.setBackground(MY_LIGHT_BLUE);
                LineBorder line = new LineBorder(MY_BLUE, 2);
                EmptyBorder margin = new EmptyBorder(19, 19, 19, 19);
                card.setBorder(new CompoundBorder(line, margin));
            }

            public void mouseExited(MouseEvent e) {
                card.setBackground(MY_WHITE);
                // Hardcoded border colour for visibility
                LineBorder line = new LineBorder(MY_GREY, 2);
                EmptyBorder margin = new EmptyBorder(20, 20, 20, 20);
                card.setBorder(new CompoundBorder(line, margin));
            }
        });

        return card;
    }

    private void handleLogout() {
        Main.getInstance().logout();
        JOptionPane.showMessageDialog(this, "You have been logged out!");

        // Replace with the login screen
        this.dispose();
        new LoginScreen("Chess App");
    }

    private void handleNewGame() {
        JPanel inputPanel = new JPanel(new GridLayout(4, 1, 5, 5));
        inputPanel.setBackground(MY_WHITE);

        // Alias selection
        JLabel aliasLabel = new JLabel("Enter your Alias:");
        aliasLabel.setFont(new Font("SansSerif", Font.BOLD, 14));
        JTextField aliasField = new JTextField();

        // Colour selection
        JLabel colourLabel = new JLabel("Choose your colour:");
        colourLabel.setFont(new Font("SansSerif", Font.BOLD, 14));
        String[] colours = {"White", "Black"};
        JComboBox<String> colourBox = new JComboBox<>(colours);

        inputPanel.add(aliasLabel);
        inputPanel.add(aliasField);
        inputPanel.add(colourLabel);
        inputPanel.add(colourBox);

        // Draw a child option pane
        int result = JOptionPane.showConfirmDialog(this, inputPanel,"New Game Setup",
                                                    JOptionPane.OK_CANCEL_OPTION, JOptionPane.PLAIN_MESSAGE);

        if (result == JOptionPane.OK_OPTION) {
            String alias = aliasField.getText().trim();
            String colour = (String)colourBox.getSelectedItem();

            // Safety check
            if (alias.isEmpty()) {
                JOptionPane.showMessageDialog(this, "Alias cannot be empty!", "Error", JOptionPane.ERROR_MESSAGE);
                handleNewGame();
                return;
            }
            if (colour == null) {
                JOptionPane.showMessageDialog(this, "Colour cannot be empty!", "Error", JOptionPane.ERROR_MESSAGE);
                handleNewGame();
                return;
            }

            Game newGame = Main.getInstance().startNewGame(alias, colour);

            // Replace with game window
            this.dispose();
            new GameScreen(Main.getInstance().getCurrentUser(), newGame);
        }
    }

    private void handleResumeGame() {
        List<Game> activeGames = Main.getInstance().getCurrentUser().getActiveGames();

        // Edge case for no games
        if (activeGames == null || activeGames.isEmpty()) {
            JOptionPane.showMessageDialog(this,"You have no active games to resume.\nTry starting a new game against the computer!",
                                        "No Active Games", JOptionPane.INFORMATION_MESSAGE);
            return;
        }

        // Inner class for list items
        class GameListItem {
            private final Game game;

            public GameListItem(Game game) {
                this.game = game;
            }

            public Game getGame() {
                return game;
            }

            public String toString() {
                return String.format("Game #%s | %s to Move | Score: %s | Moves made: %s | Pieces left: %s",
                                        game.getId(), game.getCurrentPlayer(),
                                        game.getHumanPlayer().getPoints(),
                                        game.getMoves().size(),
                                        game.getBoardPieces().size()
                );
            }
        }

        GameListItem[] options = new GameListItem[activeGames.size()];
        for (int i = 0; i < activeGames.size(); i++) {
            options[i] = new GameListItem(activeGames.get(i));
        }

        // Selection pane
        Object selection = JOptionPane.showInputDialog(
                this,"Select a game to continue:","Resume Game", JOptionPane.QUESTION_MESSAGE,
                null, options, options[0]
        );

        // User selection
        if (selection != null) {
            Game selectedGame = ((GameListItem) selection).getGame();

            // Replace with game screen
            this.dispose();
            selectedGame.resume();
            new GameScreen(Main.getInstance().getCurrentUser(), selectedGame);
        }
    }
}