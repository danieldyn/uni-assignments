public class PieceFactory {
    private static final PieceFactory instance = new PieceFactory();

    private PieceFactory() { } // Singleton

    public static PieceFactory getInstance() {
        return instance;
    }

    public static Piece createPiece(String type, String colour, String position) {
        // For safety
        type = type.toUpperCase();
        colour = colour.toUpperCase();
        switch (type) {
            case "P": return new Pawn(colour, position);
            case "N": return new Knight(colour, position);
            case "B": return new Bishop(colour, position);
            case "R": return new Rook(colour, position);
            case "Q": return new Queen(colour, position);
            case "K": return new King(colour, position);
            default: return null;
        }
    }
}
