package ui;

import app.Main;
import model.User;
import ui.components.BackgroundPanel;

import javax.swing.*;
import javax.swing.border.*;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.MouseAdapter;
import java.awt.event.MouseEvent;

public class LoginScreen extends JFrame {
    private static final int SCREEN_WIDTH = 1500;
    private static final int SCREEN_HEIGHT = 750;
    private static final Color MY_WHITE = new Color(245, 245, 250);
    private static final Color MY_GREEN = new Color(38, 173, 46);
    private static final Color MY_BLUE = new Color(34, 56, 214);
    private final JTextField emailField;
    private final JPasswordField passwordField;

    public LoginScreen(String title) {
        super(title);
        this.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        this.setSize(SCREEN_WIDTH, SCREEN_HEIGHT);
        this.setLocationRelativeTo(null);
        this.setLayout(new GridLayout(1, 2));

        // Left hand side (login fields and buttons)
        JPanel leftPanel = new JPanel();
        leftPanel.setBackground(MY_WHITE);
        leftPanel.setLayout(new GridBagLayout());

        // Inner panel for login
        JPanel loginPanel = new JPanel();
        loginPanel.setBackground(MY_WHITE);
        loginPanel.setLayout(new GridBagLayout());

        // Constraints to help with alignment
        GridBagConstraints constraints = new GridBagConstraints();
        constraints.insets = new Insets(5, 5, 75, 5);
        constraints.gridx = 0; // There will be only one column
        constraints.gridy = 0; // Initial row goes to the welcome message
        JLabel message = new JLabel("Welcome! Please enter your credentials.");
        message.setFont(new Font("Sans Serif", Font.BOLD, 24));
        message.setForeground(Color.DARK_GRAY);
        loginPanel.add(message, constraints);

        constraints.gridy++; // Next row, email label
        constraints.insets = new Insets(5, 5, 5, 5);
        JLabel emailLabel = new JLabel("Email Address:");
        emailLabel.setFont(new Font("Sans Serif", Font.BOLD, 18));
        emailLabel.setForeground(Color.DARK_GRAY);
        loginPanel.add(emailLabel, constraints);

        constraints.gridy++; // Next row, email text field
        emailField = new JTextField(20);
        emailField.setPreferredSize(new Dimension(200, 40));
        emailField.setHorizontalAlignment(JTextField.CENTER);
        emailField.setFont(new Font("Sans Serif", Font.BOLD, 15));
        loginPanel.add(emailField, constraints);

        constraints.gridy++; // Next row, password label
        constraints.insets = new Insets(25, 5, 5, 5);
        JLabel passwordLabel = new JLabel("Password:");
        passwordLabel.setFont(new Font("Sans Serif", Font.BOLD, 18));
        passwordLabel.setForeground(Color.DARK_GRAY);
        loginPanel.add(passwordLabel, constraints);

        constraints.gridy++; // Next row, password text field
        constraints.insets = new Insets(5, 5, 5, 5);
        passwordField = new JPasswordField(20);
        passwordField.setPreferredSize(new Dimension(200, 40));
        passwordField.setHorizontalAlignment(JTextField.CENTER);
        passwordField.setFont(new Font("Sans Serif", Font.BOLD, 15));
        loginPanel.add(passwordField, constraints);

        // Buttons: natural size + centred in the column
        constraints.fill = GridBagConstraints.NONE;
        constraints.weightx = 0;
        constraints.anchor = GridBagConstraints.CENTER;
        constraints.insets = new Insets(50, 5, 5, 5);
        constraints.gridy++; // Next row, login button

        JButton loginButton = new JButton("Login");
        loginButton.setPreferredSize(new Dimension(120, 45));
        styleButton(loginButton, MY_GREEN);
        loginButton.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent e) {
                userLogin();
            }
        });
        loginPanel.add(loginButton, constraints);

        constraints.insets = new Insets(5, 5, 5, 5);
        constraints.gridy++; // Next row, "or" label
        JLabel orLabel = new JLabel("-- or --");
        orLabel.setFont(new Font("Sans Serif", Font.ITALIC, 12));
        orLabel.setForeground(Color.GRAY);
        loginPanel.add(orLabel, constraints);

        constraints.gridy++; // Next row, new account button
        JButton registerButton = new JButton("Create New Account");
        registerButton.setPreferredSize(new Dimension(210, 45));
        styleButton(registerButton, MY_BLUE);
        registerButton.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent e) {
                userRegister();
            }
        });
        loginPanel.add(registerButton, constraints);

        leftPanel.add(loginPanel);

        // Right hand side (image and fun fact, nothing to interact with)
        BackgroundPanel rightPanel = new BackgroundPanel("assets/backgrounds/splash-image.jpg");

        JTextArea funFactCard = new JTextArea("Did you know?\n\nThe name 'Checkmate' comes from the Persian term 'Shah Mat', which means 'The King is slain'.\n\n");
        funFactCard.setBackground(new Color(0, 0, 0, 150)); // 150 alpha for transparency
        funFactCard.setOpaque(true);
        funFactCard.setEditable(false);
        funFactCard.setForeground(Color.WHITE);
        funFactCard.setFont(new Font(Font.DIALOG, Font.ITALIC, 18));
        funFactCard.setBorder(new EmptyBorder(20, 20, 20, 20));
        funFactCard.setLineWrap(true);
        funFactCard.setWrapStyleWord(true);
        funFactCard.setPreferredSize(new Dimension(375, 175));

        rightPanel.add(funFactCard);

        // Final assembly
        this.add(leftPanel);
        this.add(rightPanel);

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

    private void userLogin() {
        String email = emailField.getText();
        String password = new String(passwordField.getPassword());

        // Use Main class' login method
        User user = Main.getInstance().login(email, password);
        if (user != null) {
            JOptionPane.showMessageDialog(this, "Login Successful!");
            SwingUtilities.invokeLater(() -> {
                try {
                    // Create and show the new screen, then dispose of the old one
                    new MainScreen(user);
                    this.dispose();
                }
                catch (Exception e) {
                    JOptionPane.showMessageDialog(this, "Error loading menu: " + e.getMessage());
                }
            });
        }
        else {
            JOptionPane.showMessageDialog(null, "Invalid email or password!");
        }
    }

    private void userRegister() {
        String email = emailField.getText();
        String password = new String(passwordField.getPassword());

        // Safety check
        if (email.isEmpty() || password.isEmpty()) {
            JOptionPane.showMessageDialog(null, "Please fill all the fields!");
            return;
        }

        // Use Main class' newAccount method
        User user = Main.getInstance().newAccount(email, password);
        if (user != null) {
            JOptionPane.showMessageDialog(this, "Account Successfully Created!");
            SwingUtilities.invokeLater(() -> {
                try {
                    // Create and show the new screen, then dispose of the old one
                    new MainScreen(user);
                    this.dispose();
                }
                catch (Exception e) {
                    JOptionPane.showMessageDialog(this, "Error loading menu: " + e.getMessage());
                }
            });
        }
    }
}
