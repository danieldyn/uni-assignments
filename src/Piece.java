public abstract class Piece implements ChessPiece {
    private final Colours colour;
    private Position position;

    public Piece(Colours colour, Position position) {
        this.colour = colour;
        this.position = position;
    }

    public Piece(String colour, String position) {
        char c =  position.charAt(0);
        int i = position.charAt(1) - '0';
        this.position = new Position(c, i);
        this.colour = Colours.valueOf(colour);
    }

    public Colours getColour() {
        return colour;
    }

    public Position getPosition() {
        return position;
    }

    public void setPosition(Position position) {
        this.position = position;
    }

    public String typeAsString() {
        return "" + type();
    }

    public String toString() {
        return type() + "-" + getColour().toString().charAt(0);
    }
}
