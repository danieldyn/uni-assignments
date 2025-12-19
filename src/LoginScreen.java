import javax.swing.*;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

public class LoginScreen extends JFrame {
    private final JTextField emailField;
    private final JPasswordField passwordField;

    public LoginScreen(String title) {
        super(title);
        this.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        this.setSize(1600, 1000);
        this.setLocationRelativeTo(null);
        this.setLayout(new GridLayout(1, 2));

        // Left hand side (login fields and buttons)
        JPanel leftPanel = new JPanel();
        leftPanel.setBackground(Color.WHITE);
        leftPanel.setLayout(new GridBagLayout());

        // Inner panel for login
        JPanel loginPanel = new JPanel();
        loginPanel.setBackground(Color.WHITE);
        loginPanel.setLayout(new GridBagLayout());

        // Constraints to help with alignment
        GridBagConstraints constraints = new GridBagConstraints();
        constraints.insets = new Insets(5, 5, 75, 5);
        constraints.gridx = 0; // There will be only one column
        constraints.gridy = 0; // Initial row goes to welcome message
        JLabel message = new JLabel("Enter your credentials and choose login option");
        message.setFont(new Font("Times New Roman", Font.BOLD, 20));
        loginPanel.add(message, constraints);

        constraints.gridy++; // Next row, email label
        constraints.insets = new Insets(5, 5, 5, 5);
        JLabel emailLabel = new JLabel("Email Address:");
        emailLabel.setFont(new Font(Font.DIALOG, Font.BOLD, 20));
        loginPanel.add(emailLabel, constraints);

        constraints.gridy++; // Next row, email text field
        emailField = new JTextField(20);
        emailField.setPreferredSize(new Dimension(200, 25));
        emailField.setFont(new Font(Font.DIALOG, Font.BOLD, 13));
        emailField.setFont(new Font(Font.DIALOG, Font.PLAIN, 15));
        loginPanel.add(emailField, constraints);

        constraints.gridy++; // Next row, password label
        constraints.insets = new Insets(25, 5, 5, 5);
        JLabel passwordLabel = new JLabel("Password:");
        passwordLabel.setFont(new Font(Font.DIALOG, Font.BOLD, 20));
        loginPanel.add(passwordLabel, constraints);

        constraints.gridy++; // Next row, password text field
        constraints.insets = new Insets(5, 5, 5, 5);
        passwordField = new JPasswordField(20);
        passwordField.setPreferredSize(new Dimension(200, 25));
        passwordField.setFont(new Font(Font.DIALOG, Font.PLAIN, 15));
        loginPanel.add(passwordField, constraints);

        // Buttons: natural size + centred in the column
        constraints.fill = GridBagConstraints.NONE;
        constraints.weightx = 0;
        constraints.anchor = GridBagConstraints.CENTER;
        constraints.insets = new Insets(50, 5, 5, 5);
        constraints.gridy++; // Next row, login button

        JButton loginButton = new JButton("Login");
        loginButton.setPreferredSize(new Dimension(120, 45));
        loginButton.setBackground(Color.WHITE);
        loginButton.setFont(new Font(Font.DIALOG, Font.BOLD, 15));
        loginButton.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent e) {
                userLogin();
            }
        });
        loginPanel.add(loginButton, constraints);

        constraints.insets = new Insets(5, 5, 5, 5);
        constraints.gridy++; // Next row, "or" label
        JLabel orLabel = new JLabel("-- OR --");
        orLabel.setForeground(Color.GRAY);
        loginPanel.add(orLabel, constraints);

        constraints.gridy++; // Next row, new account button
        JButton registerButton = new JButton("Create New Account");
        registerButton.setPreferredSize(new Dimension(210, 45));
        registerButton.setBackground(Color.WHITE);
        registerButton.setFont(new Font(Font.DIALOG, Font.BOLD, 15));
        registerButton.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent e) {
                userRegister();
            }
        });
        loginPanel.add(registerButton, constraints);

        leftPanel.add(loginPanel);

        // Right hand side (image, nothing to interact with)
        // TODO add content here
        JPanel rightPanel = new JPanel();
        rightPanel.setBackground(new Color(45, 45, 45));
        JLabel placeholderText = new JLabel("Image Here");
        placeholderText.setForeground(Color.BLUE);
        rightPanel.add(placeholderText);

        this.add(leftPanel);
        this.add(rightPanel);
        this.setVisible(true);
    }

    private void userLogin() {
        String email = emailField.getText();
        String password = new String(passwordField.getPassword());

        // Use Main class' login method
        User user = Main.getInstance().login(email, password);
        if (user != null) {
            JOptionPane.showMessageDialog(null, "Login Successful!");
            this.dispose();
            // TODO open main game window after successful login
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
            JOptionPane.showMessageDialog(null, "Account Successfully Created!");
            this.dispose();
            // TODO open main game window after successful account creation
        }
    }
}