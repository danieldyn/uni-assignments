package ui.components;

import exceptions.InvalidMoveException;
import model.*;
import model.pieces.Piece;
import model.pieces.Pawn;
import ui.ConclusionScreen;
import ui.GameScreen;

import javax.imageio.ImageIO;
import javax.swing.*;
import javax.swing.border.EmptyBorder;
import javax.swing.border.LineBorder;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.image.BufferedImage;
import java.io.File;
import java.util.HashMap;
import java.util.Map;
import java.util.List;

public class BoardPanel extends JPanel implements GameObserver {
    private final int TILE_SIZE = 100;
    private final Color MY_WHITE = new Color(245, 245, 250);
    private static final Color MY_BLUE = new Color(34, 42, 116);

    private final ChessSquare[][] squares = new ChessSquare[8][8];
    private final JPanel boardPanel;
    private final JLabel statusLabel;

    private final Game game;
    private final Board board;
    private ChessSquare selectedSquare = null;

    private Map<String, Image> pieceImages = new HashMap<>();
    private Image whiteTileImg, blackTileImg;

    private boolean isFlipped = false;
    private final GameScreen parentScreen;

    public BoardPanel(User user, Game game, GameScreen parentScreen) {
        this.game = game;
        this.board = game.getBoard();
        this.parentScreen = parentScreen;

        this.setLayout(new BorderLayout());
        loadAssets();

        // Board setup as a matrix of buttons
        if (game.getHumanPlayer().getColour() == Colours.BLACK) {
            isFlipped = true;
        }
        boardPanel = new JPanel(new GridLayout(8, 8));
        initialiseBoard();

        statusLabel = new JLabel("Current Turn: " + game.getCurrentPlayer().getName(), SwingConstants.CENTER);
        statusLabel.setFont(new Font("SansSerif", Font.BOLD, 20));
        statusLabel.setBorder(new LineBorder(MY_BLUE, 2));

        this.add(boardPanel, BorderLayout.CENTER);
        this.add(statusLabel, BorderLayout.SOUTH);

        this.setVisible(true);
        game.addObserver(this);
        refreshBoard();
        onPlayerSwitch(game.getCurrentPlayer());
    }

    public void onMoveMade(Move move) {
        resetSelection();
        refreshBoard();
        highlightLastMove(move);
    }

    public void onPieceCaptured(Piece piece) { }

    public void onPawnPromotion(Pawn pawn) {
        JPanel inputPanel = new JPanel(new GridLayout(4, 1, 5, 5));
        inputPanel.setBackground(MY_WHITE);
        inputPanel.setBorder(new EmptyBorder(10, 10, 10, 10));

        JLabel pieceLabel = new JLabel("Choose the piece to promote your pawn to:");
        pieceLabel.setFont(new Font("SansSerif", Font.BOLD, 14));
        String[] pieces = {"Rook", "Bishop", "Knight", "Queen"};
        JComboBox<String> pieceBox = new JComboBox<>(pieces);

        inputPanel.add(pieceLabel);
        inputPanel.add(pieceBox);

        // Draw a child option pane
        int result = JOptionPane.showConfirmDialog(this, inputPanel,"Pawn Promotion",
                JOptionPane.OK_CANCEL_OPTION, JOptionPane.PLAIN_MESSAGE);

        if (result == JOptionPane.OK_OPTION) {
            String pieceType = (String)pieceBox.getSelectedItem();

            // Safety check
            if (pieceType == null) {
                JOptionPane.showMessageDialog(this, "Alias cannot be empty!", "Error", JOptionPane.ERROR_MESSAGE);
                onPawnPromotion(pawn);
                return;
            }

            game.promotePawn(pawn, pieceType);
        }
    }

    public void onComputerPawnPromotion() {
        refreshBoard();
    }

    public void onPlayerSwitch(Player currentPlayer) {
        statusLabel.setText(String.format("%s's Turn (Score: %d)", currentPlayer.getName(), currentPlayer.getPoints()));
        checkGameState();

        // Trigger computer turn here
        if (currentPlayer.getName().equals("computer")) {
            // Run in separate thread to avoid freezing UI
            new Thread(() -> {
                try {
                    Thread.sleep(2500); // Milliseconds
                }
                catch (InterruptedException ignored) { }

                SwingUtilities.invokeLater(game::handleComputerTurn);
            }).start();
        }
    }

    private Position toPosition(int row, int col) {
        int r = row, c = col;

        if (isFlipped) {
            r = 7 - row;
            c = 7 - col;
        }

        char x = (char)('A' + c);
        int y = 8 - r;
        return new Position(x, y);
    }

    private Point fromPosition(Position pos) {
        int col = pos.getX() - 'A';
        int row = 8 - pos.getY();

        if (isFlipped) {
            col = 7 - col;
            row = 7 - row;
        }

        return new Point(col, row);
    }

    private void handleSquareClick(ChessSquare clickedSquare) {
        // Prevent clicking if game is over or computer is thinking
        if (game.getCurrentPlayer().getName().equals("computer")) {
            return;
        }

        Position clickedPos = toPosition(clickedSquare.row, clickedSquare.col);
        if (selectedSquare == null) {
            Piece piece = board.getPieceAt(clickedPos);

            // Safety checks before selecting and highlighting
            if (piece != null && piece.getColour() == game.getCurrentPlayer().getColour()) {
                selectedSquare = clickedSquare;
                selectedSquare.setBorder(new LineBorder(Color.YELLOW, 3));
                highlightLegalMoves(piece);
            }
        }
        else
        {
            if (clickedSquare == selectedSquare) {
                resetSelection();
                return;
            }

            Position fromPos = toPosition(selectedSquare.row, selectedSquare.col);

            // Check valid move
            if (board.isValidMove(fromPos, clickedPos)) {
                executeMove(fromPos, clickedPos);
            }
            else {
                Piece p = board.getPieceAt(clickedPos);
                if (p != null && p.getColour() == game.getCurrentPlayer().getColour()) {
                    resetSelection();
                    handleSquareClick(clickedSquare); // Recursive select
                }
                else {
                    statusLabel.setText("Invalid Move!");
                }
            }
        }
    }

    private void executeMove(Position from, Position to) {
        try {
            game.processTurn(from, to);
        }
        catch (InvalidMoveException e) {
            JOptionPane.showMessageDialog(this, e.getMessage());
            resetSelection();
        }
    }

    private void checkGameState() {
        ExitCodes status = game.getGameState();

        switch (status) {
            case LOSE_CHECKMATE:
                statusLabel.setText("CHECKMATE! Game Over.");
                statusLabel.setForeground(Color.RED);

                // 2 second wait before transition
                Timer delayTimer = new Timer(2000, new ActionListener() {
                    public void actionPerformed(ActionEvent e) {
                        parentScreen.dispose();
                        if (game.getCurrentPlayer().getName().equals("computer")) {
                            new ConclusionScreen(game, ExitCodes.WIN_CHECKMATE);
                        }
                        else {
                            new ConclusionScreen(game, ExitCodes.LOSE_CHECKMATE);
                        }
                    }
                });

                delayTimer.setRepeats(false); // Only run once
                delayTimer.start();
                break;

            case WIN_CHECKMATE:
                statusLabel.setText("--->  CHECKMATE! Game Over.  <---");
                statusLabel.setForeground(Color.RED);
                
                delayTimer = new Timer(2000, new ActionListener() {
                    public void actionPerformed(ActionEvent e) {
                        parentScreen.dispose();
                        new ConclusionScreen(game, ExitCodes.WIN_CHECKMATE);
                    }
                });

                delayTimer.setRepeats(false); // Only run once
                delayTimer.start();
                break;

            case DRAW:
                statusLabel.setText("--->  IT'S A DRAW! Game Over.  <---");
                statusLabel.setForeground(Color.RED);

                delayTimer = new Timer(2000, new ActionListener() {
                    public void actionPerformed(ActionEvent e) {
                        parentScreen.dispose();
                        new ConclusionScreen(game, ExitCodes.DRAW);
                    }
                });

                delayTimer.setRepeats(false); // Only run once
                delayTimer.start();
                break;

            case CONTINUE:
                if (board.isKingInCheck(game.getCurrentPlayer().getColour())) {
                    statusLabel.setText("CHECK! " + game.getCurrentPlayer().getName() + " to move.");
                    statusLabel.setForeground(Color.RED);
                }
                else {
                    statusLabel.setForeground(Color.BLACK);
                }
                break;

            default:
                break;
        }
    }

    private void highlightLegalMoves(Piece p) {
        List<Position> moves = p.getPossibleMoves(board);
        for (Position pos : moves) {
            // Validity check
            if (board.isValidMove(p.getPosition(), pos)) {
                Point point = fromPosition(pos);
                squares[point.y][point.x].setHighlight(true);
            }
        }
        boardPanel.repaint();
    }

    private void highlightLastMove(Move move) {
        // Clear old highlights
        for (int r = 0; r < 8; r++) {
            for (int c = 0; c < 8; c++) {
                squares[r][c].setLastMove(false);
            }
        }

        // New highlights
        if (move != null) {
            Point from = fromPosition(move.getFrom());
            Point to = fromPosition(move.getTo());

            squares[from.y][from.x].setLastMove(true);
            squares[to.y][to.x].setLastMove(true);
        }

        boardPanel.repaint();
    }

    private void refreshBoard() {
        for (int row = 0; row < 8; row++) {
            for (int col = 0; col < 8; col++) {
                Position pos = toPosition(row, col);
                Piece p = board.getPieceAt(pos);

                if (p != null) {
                    // Map piece to image by string concatenation
                    String key = p.getColour().toString().toLowerCase() + "_" + p.getClass().getSimpleName().toLowerCase();
                    squares[row][col].setPieceImage(pieceImages.get(key));
                }
                else {
                    squares[row][col].setPieceImage(null);
                }
            }
        }
    }

    private void resetSelection() {
        if (selectedSquare != null) {
            selectedSquare.setBorder(null);
        }
        selectedSquare = null;
        for (int row = 0; row < 8; row++) {
            for (int col = 0; col < 8; col++) {
                squares[row][col].setHighlight(false);
            }
        }
        boardPanel.repaint();
    }

    private void loadAssets() {
        try {
            whiteTileImg = ImageIO.read(new File("assets/tiles/white_tile.png")).getScaledInstance(TILE_SIZE, TILE_SIZE, Image.SCALE_SMOOTH);
            blackTileImg = ImageIO.read(new File("assets/tiles/black_tile.png")).getScaledInstance(TILE_SIZE, TILE_SIZE, Image.SCALE_SMOOTH);

            // Map the pieces class' names
            String[] colors = {"white", "black"};
            String[] types = {"pawn", "rook", "knight", "bishop", "queen", "king"};

            for (String c : colors) {
                for (String t : types) {
                    String key = c + "_" + t;
                    BufferedImage img = ImageIO.read(new File("assets/pieces/" + key + ".png"));
                    pieceImages.put(key, img.getScaledInstance(TILE_SIZE, TILE_SIZE, Image.SCALE_SMOOTH));
                }
            }
        }
        catch (Exception e) {
            System.err.println("Error loading assets: " + e.getMessage());
        }
    }

    private void initialiseBoard() {
        for (int row = 0; row < 8; row++) {
            for (int col = 0; col < 8; col++) {
                boolean isWhite = (row + col) % 2 == 0;
                Image bg;
                if (isWhite) {
                    bg = whiteTileImg;
                }
                else {
                    bg = blackTileImg;
                }

                ChessSquare square = new ChessSquare(row, col, bg);
                square.setPreferredSize(new Dimension(TILE_SIZE, TILE_SIZE));
                square.addActionListener(new ActionListener() {
                    public void actionPerformed(ActionEvent e) {
                        handleSquareClick(square);
                    }
                });

                squares[row][col] = square;
                boardPanel.add(square);
            }
        }
    }

    // Custom button class
    private static class ChessSquare extends JButton {
        int row, col;
        Image bgImage;
        private Image pieceImage = null;
        boolean isHighlighted = false;
        boolean isLastMove = false;

        public ChessSquare(int row, int col, Image bgImage) {
            this.row = row;
            this.col = col;
            this.bgImage = bgImage;
            this.setContentAreaFilled(false);
            this.setFocusPainted(false);
            this.setBorder(null);
            this.setCursor(Cursor.getPredefinedCursor(Cursor.HAND_CURSOR));
        }

        public void setHighlight(boolean val) {
            this.isHighlighted = val;
            this.repaint();
        }

        public void setPieceImage(Image img) {
            this.pieceImage = img;
            this.repaint();
        }

        public void setLastMove(boolean val) {
            this.isLastMove = val;
        }

        protected void paintComponent(Graphics g) {
            // Tile background
            if (bgImage != null) {
                g.drawImage(bgImage, 0, 0, getWidth(), getHeight(), this);
            }
            else {
                if ((row + col) % 2 == 0) {
                    g.setColor(Color.WHITE);
                }
                else {
                    g.setColor(Color.GRAY);
                }
                g.fillRect(0, 0, getWidth(), getHeight());
            }

            // Check for highlight
            if (isLastMove) {
                g.setColor(new Color(195, 255, 0, 100)); // Semi-transparent alpha
                g.fillRect(0, 0, getWidth(), getHeight());
            }

            if (isHighlighted) {
                g.setColor(new Color(58, 255, 0, 100)); // Semi-transparent alpha
                g.fillRect(0, 0, getWidth(), getHeight());
            }

            // Check for piece
            if (pieceImage != null) {
                // Centre the image
                int x = (getWidth() - pieceImage.getWidth(null)) / 2;
                int y = (getHeight() - pieceImage.getHeight(null)) / 2;
                g.drawImage(pieceImage, x, y, this);
            }
        }
    }
}