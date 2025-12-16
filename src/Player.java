import java.util.Iterator;
import java.util.List;
import java.util.ArrayList;
import java.util.TreeSet;

public class Player {
    private String name;
    private Colours colour;
    private List<Piece> capturedPieces;
    private TreeSet<ChessPair<Position, Piece>> ownedPieces;
    private int points;
    private Board board;

    public Player(String name, Colours colour) {
        this.name = name;
        this.colour = colour;
        capturedPieces = new ArrayList<Piece>();
        ownedPieces = new TreeSet<ChessPair<Position, Piece>>();
        points = 0;
    }

    public Player(String name, String colour) {
        this.name = name;
        if (colour.equals("WHITE")) {
            this.colour = Colours.WHITE;
        }
        else {
            this.colour = Colours.BLACK;
        }
        capturedPieces = new ArrayList<>();
        ownedPieces = new TreeSet<>();
        points = 0;
    }

    public Colours getColour() {
        return colour;
    }

    public String getName() {
        return name;
    }

    public Board getBoard() {
        return board;
    }

    public void setBoard(Board board) {
        this.board = board;
    }

    public void makeMove(Position from, Position to, Board board) throws InvalidMoveException {
        if (!board.isValidMove(from, to)) {
            throw new InvalidMoveException("Invalid move from " + from + " to " + to);
        }

        Piece targetPiece = board.getPieceAt(to);
        if (targetPiece != null) {
            switch (targetPiece.type()) {
                case 'P': setPoints(getPoints() + 10); break;
                case 'N':
                    case 'B': setPoints(getPoints() + 30); break;
                case 'R': setPoints(getPoints() + 50); break;
                case 'Q': setPoints(getPoints() + 90); break;
            }
            capturedPieces.add(targetPiece);
        }

        board.movePiece(from, to);
    }

    public List<Piece> getCapturedPieces() {
        return capturedPieces;
    }

    public List<ChessPair<Position, Piece>> getOwnedPieces() {
        ownedPieces.clear();

        if (board != null) {
            for (ChessPair<Position, Piece> pair : board.getPieces()) {
                if (pair.getValue().getColour() == colour) {
                    ownedPieces.add(pair);
                }
            }
        }

        return new ArrayList<>(ownedPieces);
    }

    public int getPoints() {
        return points;
    }

    public void setPoints(int points) {
        this.points = points;
    }

    public String toString() {
        return name;
    }
}
