package model;

public class Position implements Comparable<Position>{
    private final char x;
    private final int y;

    public Position(char x, int y) {
        this.x = x;
        this.y = y;
    }

    public Position(String s) {
        this.x = s.charAt(0);
        this.y = s.charAt(1) - '0';
    }

    public char getX() {
        return x;
    }

    public int getY() {
        return y;
    }

    public Position getTop() {
        return new Position(x, y + 1);
    }

    public Position getBottom() {
        return new Position(x, y - 1);
    }

    public Position getLeft() {
        return new Position((char)(x - 1), y);
    }

    public Position getRight() {
        return new Position((char)(x + 1), y);
    }

    public Position moveTo(char x, int y) {
        return new Position(x, y);
    }

    public int compareTo(Position pos) {
        if (y < pos.y) {
            return -1;
        }
        else if (y > pos.y) {
            return 1;
        }
        if (x < pos.x) {
            return -1;
        }
        else if (x > pos.x) {
            return 1;
        }
        return 0;
    }

    public boolean equals(Object o) {
        if (!(o instanceof Position)) {
            return false;
        }
        Position p = (Position) o;
        return this.compareTo(p) == 0;
    }

    public boolean isOnBoard() {
        return x >= 'A' && x <= 'H' && y >= 1 && y <= 8;
    }

    public String toString() {
        if (isOnBoard()) {
            return "" + x + y;
        }
        else {
            return "None";
        }
    }
}
