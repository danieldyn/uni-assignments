import javax.swing.*;
import javax.swing.border.CompoundBorder;
import javax.swing.border.EmptyBorder;
import javax.swing.border.LineBorder;
import java.awt.*;
import java.awt.event.MouseAdapter;
import java.awt.event.MouseEvent;
import java.util.List;

public class GameScreen extends JFrame {
    private static final int SCREEN_WIDTH = 1500;
    private static final int SCREEN_HEIGHT = 1000;
    private final Color MY_WHITE = new Color(245, 245, 250);
    private final Color MY_GREEN = new Color(38, 173, 46);
    private final Color MY_BLUE = new Color(34, 56, 214);
    private final Color MY_LIGHT_BLUE = new Color(161, 199, 235);
    private final Color MY_GREY = new Color(124, 140, 163);
    private final Color MY_LIGHT_GRAY = new Color(156, 156, 156);

    public GameScreen(User user, Game game) {
        super("Chess Game");
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
        centrePanel.setBackground(MY_LIGHT_GRAY);
        centrePanel.setLayout(new GridBagLayout());
        centrePanel.setBorder(new EmptyBorder(30, 30, 30,30));

        GridBagConstraints constraints = new GridBagConstraints();
        constraints.fill = GridBagConstraints.HORIZONTAL;
        constraints.weightx = 0;
        constraints.anchor = GridBagConstraints.NORTH;

        // TODO move history on the left
        constraints.gridx = 0;
        constraints.gridy = 0;
        JPanel moveHistoryPanel = new JPanel(new GridBagLayout());
        moveHistoryPanel.setBackground(MY_LIGHT_GRAY);
        moveHistoryPanel.setOpaque(false);
        moveHistoryPanel.add(new JLabel("MOVE HISTORY HERE"), constraints);

        // Interactive board in the centre
        constraints.gridx++;
        constraints.insets = new Insets(0, 15, 0, 15);
        JPanel boardPanel = new BoardPanel(user, game);
        centrePanel.add(boardPanel, constraints);

        // TODO buttons, captured pieces etc
        constraints.gridx++;
        JPanel utilPanel = new JPanel(new GridBagLayout());
        utilPanel.setBackground(MY_LIGHT_GRAY);
        utilPanel.setOpaque(false);
        utilPanel.add(new JLabel("BUTTONS AND DATA HERE"), constraints);

        // Final assembly
        this.add(headerPanel, BorderLayout.NORTH);
        this.add(moveHistoryPanel, BorderLayout.WEST);
        this.add(centrePanel, BorderLayout.CENTER);
        this.add(utilPanel, BorderLayout.EAST);

        this.setVisible(true);
    }
}
