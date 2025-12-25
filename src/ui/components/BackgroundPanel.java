package ui.components;

import javax.imageio.ImageIO;
import javax.swing.*;
import java.awt.*;
import java.io.File;
import java.io.IOException;

public class BackgroundPanel extends JPanel {
    private Image img;

    public BackgroundPanel(String filePath) {
        // Text will be placed in the middle
        this.setLayout(new GridBagLayout());

        try {
            img = ImageIO.read(new File(filePath));
        }
        catch (IOException e) {
            System.out.println("Failed to load: " +  filePath);
            this.setBackground(Color.LIGHT_GRAY); // Placeholder
        }
    }

    protected void paintComponent(Graphics g) {
        super.paintComponent(g);
        if (img != null) {
            g.drawImage(img, 0, 0, this.getWidth(), this.getHeight(), this);
        }
    }
}
