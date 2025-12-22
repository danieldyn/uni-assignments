import javax.swing.*;
import javax.swing.border.CompoundBorder;
import javax.swing.border.EmptyBorder;
import javax.swing.border.LineBorder;
import java.awt.*;
import java.awt.event.MouseAdapter;
import java.awt.event.MouseEvent;

public class MainScreen extends JFrame {
    private static final int SCREEN_WIDTH = 1500;
    private static final int SCREEN_HEIGHT = 750;
    private final Color MY_WHITE = new Color(245, 245, 250);
    private final Color MY_GREEN = new Color(38, 173, 46);
    private final Color MY_BLUE = new Color(34, 56, 214);
    private final Color MY_LIGHT_BLUE = new Color(161, 199, 235);

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
            // Unicode knight emergency
            iconLabel.setText("♞");
            iconLabel.setFont(new Font("Serif", Font.BOLD, 40));
            iconLabel.setForeground(Color.WHITE);
        }

        // Main menu title
        JLabel titleLabel = new JLabel("Main Menu");
        titleLabel.setFont(new Font("SansSerif", Font.BOLD, 26));
        titleLabel.setForeground(Color.WHITE);

        titlePanel.add(iconLabel);
        titlePanel.add(titleLabel);

        // Top right: "Logged in as: username"
        JPanel userPanel = new JPanel(new FlowLayout(FlowLayout.RIGHT));
        userPanel.setOpaque(false);
        JLabel userLabel = new JLabel("Logged in as: " + user.getEmail());
        userLabel.setFont(new Font("SansSerif", Font.BOLD, 16));
        userLabel.setForeground(Color.WHITE);

        userPanel.add(userLabel);

        // Header assembly
        headerPanel.add(titlePanel, BorderLayout.WEST);
        headerPanel.add(userPanel, BorderLayout.EAST);

        // Centre: main content
        JPanel centrePanel = new JPanel();
        centrePanel.setBackground(MY_WHITE);
        centrePanel.setLayout(new GridBagLayout());

        GridBagConstraints constraints = new GridBagConstraints();
        constraints.insets = new Insets(15, 15, 15, 15);
        constraints.fill = GridBagConstraints.BOTH;
        constraints.weightx = 1.0;
        constraints.weighty = 1.0;

        // Top left
        constraints.gridx = 0;
        constraints.gridy = 0;
        centrePanel.add(createMenuCard("Card One", "Subtitle One"), constraints);

        // Top right
        constraints.gridx = 1;
        constraints.gridy = 0;
        centrePanel.add(createMenuCard("Card Two", "Subtitle Two"), constraints);

        // Bottom left
        constraints.gridx = 0;
        constraints.gridy = 1;
        centrePanel.add(createMenuCard("Card Three", "Subtitle Three"), constraints);

        // Bottom right
        constraints.gridx = 1;
        constraints.gridy = 1;
        centrePanel.add(createMenuCard("Card Four", "Subtitle Four"), constraints);

        // Final assembly
        this.add(headerPanel, BorderLayout.NORTH);
        this.add(centrePanel, BorderLayout.CENTER);

        this.setVisible(true);
    }

    private JPanel createMenuCard(String title, String subtitle) {
        JPanel card = new JPanel();
        card.setLayout(new GridBagLayout());
        card.setBackground(Color.WHITE);
        card.setCursor(new Cursor(Cursor.HAND_CURSOR));

        // Line border with padding
        LineBorder line = new LineBorder(MY_WHITE, 1);
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
        subLabel.setFont(new Font("SansSerif", Font.PLAIN, 14));
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
                card.setBackground(Color.WHITE);
                // Hardcoded border colour for visibility
                LineBorder line = new LineBorder(new Color(200, 200, 200));
                EmptyBorder margin = new EmptyBorder(20, 20, 20, 20);
                card.setBorder(new CompoundBorder(line, margin));
            }
        });

        return card;
    }
}