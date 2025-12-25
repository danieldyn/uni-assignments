package ui.components;

import exceptions.InvalidMoveException;
import model.*;
import model.pieces.Piece;

import javax.imageio.ImageIO;
import javax.swing.*;
import javax.swing.border.EmptyBorder;
import javax.swing.border.LineBorder;
import java.awt.*;
import java.awt.image.BufferedImage;
import java.io.File;
import java.util.HashMap;
import java.util.Map;
import java.util.List;
import java.util.Collections;

public class BoardPanel extends JPanel implements GameObserver {
    private final int TILE_SIZE = 100;

    private final ChessSquare[][] squares = new ChessSquare[8][8];
    private final JPanel boardPanel;
    private final JLabel statusLabel;

    private final Game game;
    private final Board board;
    private ChessSquare selectedSquare = null;

    private Map<String, Image> pieceImages = new HashMap<>();
    private Image whiteTileImg, blackTileImg;

    private boolean isFlipped = false;

    public BoardPanel(User user, Game game) {
        this.game = game;
        this.board = game.getBoard();

        this.setLayout(new BorderLayout());
        loadAssets();

        // Board setup as a matrix of buttons
        if (game.getHumanPlayer().getColour() == Colours.BLACK) {
            isFlipped = true;
        }
        boardPanel = new JPanel(new GridLayout(8, 8));
        initialiseBoard();

        statusLabel = new JLabel("Current Turn: " + game.getCurrentPlayer().getColour(), SwingConstants.CENTER);
        statusLabel.setFont(new Font("SansSerif", Font.BOLD, 16));
        statusLabel.setBorder(new EmptyBorder(10, 0, 10, 0));

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
        // TODO highlighting last move
    }

    public void onPieceCaptured(Piece piece) {
        // TODO update graphics
    }

    public void onPlayerSwitch(Player currentPlayer) {
        statusLabel.setText(String.format("%s's Turn (Score: %d)", currentPlayer.getColour(), currentPlayer.getPoints()));
        checkGameState();

        // Trigger computer turn here
        if (currentPlayer.getName().equals("computer")) {
            // Run in separate thread to not freeze UI
            new Thread(() -> {
                try {
                    Thread.sleep(1000); // Thinking time
                }
                catch (InterruptedException ignored) {}

                // Use SwingUtilities to update UI from background thread
                SwingUtilities.invokeLater(() -> {
                    System.out.println("Computer Turn");
                    performComputerMove();
                });
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
                System.out.println("Selected: " + piece); // Debug only
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
                    // TODO Invalid move feedback could go here
                    System.out.println("Invalid Move");
                }
            }
        }
    }

    private void executeMove(Position from, Position to) {
        try {
            Player currentPlayer = game.getCurrentPlayer();
            Piece targetPiece = board.getPieceAt(to);

            // Game logic update
            currentPlayer.makeMove(from, to, board);
            game.addMove(currentPlayer, from, to, targetPiece);
            game.switchPlayer();

        }
        catch (InvalidMoveException e) {
            JOptionPane.showMessageDialog(this, e.getMessage());
            resetSelection();
        }
    }

    private void performComputerMove() {
        Player computer = game.getCurrentPlayer();
        List<ChessPair<Position, Piece>> pieces = computer.getOwnedPieces();
        Collections.shuffle(pieces);

        for (ChessPair<Position, Piece> pair : pieces) {
            Piece p = pair.getValue();
            Position from = p.getPosition();
            List<Position> moves = p.getPossibleMoves(board);
            Collections.shuffle(moves);

            for (Position destination : moves) {
                if (board.isValidMove(from, destination)) {
                    executeMove(from, destination);
                    return;
                }
            }
        }
    }

    private void checkGameState() {
        boolean inCheck = board.isKingInCheck(game.getCurrentPlayer().getColour());
        boolean checkMate = game.checkForCheckMate();

        if (checkMate && inCheck) {
            JOptionPane.showMessageDialog(this, "CHECKMATE! " + game.getCurrentPlayer().getColour() + " loses!");
            // TODO return to menu logic
        }
        else if (checkMate && !inCheck) {
            JOptionPane.showMessageDialog(this, "STALEMATE! It's a draw.");
        }
        else if (inCheck) {
            statusLabel.setText("CHECK! " + game.getCurrentPlayer().getColour() + " to move.");
            statusLabel.setForeground(Color.RED);
        }
        else {
            statusLabel.setForeground(Color.BLACK);
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
                square.addActionListener(e -> handleSquareClick(square));

                squares[row][col] = square;
                boardPanel.add(square);
            }
        }
    }

    // Custom button class
    private class ChessSquare extends JButton {
        int row, col;
        Image bgImage;
        private Image pieceImage = null;
        boolean isHighlighted = false;

        public ChessSquare(int row, int col, Image bgImage) {
            this.row = row;
            this.col = col;
            this.bgImage = bgImage;
            this.setContentAreaFilled(false);
            this.setFocusPainted(false);
            this.setBorder(null);
        }

        public void setHighlight(boolean val) {
            this.isHighlighted = val;
            this.repaint();
        }

        public void setPieceImage(Image img) {
            this.pieceImage = img;
            this.repaint();
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
            if (isHighlighted) {
                g.setColor(new Color(60, 255, 0, 100)); // Semi-transparent alpha
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