package model;

import exceptions.InvalidMoveException;
import exceptions.InvalidCommandException;
import model.pieces.Pawn;
import model.pieces.Piece;
import model.pieces.PieceFactory;
import model.pieces.Queen;

import java.util.*;

public class Game {
    private int id;
    private Board board;
    private List<Player> players;
    private List<Move> moves;
    private int currentPlayerIndex;
    private List<GameObserver> observers;

    public Game() {
        players = new ArrayList<>();
        moves = new ArrayList<>();
        board = new Board();
        observers = new ArrayList<>();
    }

    public Game(int id, Player player1, Player player2) {
        this.id = id;
        players = new ArrayList<>(2);
        players.add(player1);
        player1.setBoard(board);
        players.add(player2);
        player2.setBoard(board);
        board = new Board();
        moves = new ArrayList<>();
        observers = new ArrayList<>();
    }

    public void addObserver(GameObserver observer) {
        observers.add(observer);
    }

    public void removeObserver(GameObserver observer) {
        observers.remove(observer);
    }

    private void notifyMoveMade(Move move) {
        for (GameObserver observer : observers) {
            observer.onMoveMade(move);
        }
    }

    private void notifyPlayerSwitch(Player player) {
        for (GameObserver observer : observers) {
            observer.onPlayerSwitch(player);
        }
    }

    private void notifyPieceCaptured(Piece piece) {
        for (GameObserver observer : observers) {
            observer.onPieceCaptured(piece);
        }
    }

    private void notifyPawnPromotion(Pawn pawn) {
        for (GameObserver observer : observers) {
            observer.onPawnPromotion(pawn);
        }
    }

    public List<Player> getPlayers() {
        return players;
    }

    public void setPlayers(List<Player> players) {
        this.players = players;
    }

    public void setBoard(List<Piece> boardArray) {
        for (Piece piece : boardArray) {
            board.addPiece(piece);
        }
    }

    public Set<ChessPair<Position, Piece>> getBoardPieces() {
        return board.getPieces();
    }

    public List<Move> getMoves() {
        return moves;
    }

    public void setMoves(List<Move> moves) {
        this.moves = moves;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getId() {
        return id;
    }

    public Board getBoard() {
        return board;
    }

    public void setCurrentPlayerColour(String colour) {
        Colours playerColour = Colours.valueOf(colour);
        if (players.get(0).getColour() == playerColour) {
            currentPlayerIndex = 0;
        }
        else {
            currentPlayerIndex = 1;
        }
    }

    public void start() {
        board.initialise();
        if (!moves.isEmpty()) {
            moves.clear();
        }
        setCurrentPlayerColour("WHITE");
        players.get(0).setBoard(board);
        players.get(1).setBoard(board);
    }

    public void resume() {
        players.get(0).setBoard(board);
        players.get(1).setBoard(board);
    }

    public void switchPlayer() {
        currentPlayerIndex = (currentPlayerIndex + 1) % 2;
        notifyPlayerSwitch(players.get(currentPlayerIndex));
    }

    public Player getCurrentPlayer() {
        return players.get(currentPlayerIndex);
    }

    public Player getHumanPlayer() {
        if (players.get(0).getName().equals("computer")) {
            return players.get(1);
        }
        return players.get(0);
    }

    public String toString(){
        return "Players: " + players + "\nBoard:\n" + board + "\nMoves: " + moves;
    }

    public boolean checkForCheckMate() {
        Player currentPlayer = getCurrentPlayer();

        if (!board.isKingInCheck(currentPlayer.getColour())) {
            return false;
        }

        for (ChessPair<Position, Piece> pair : currentPlayer.getOwnedPieces()) {
            Piece piece = pair.getValue();
            for (Position destination : piece.getPossibleMoves(board)) {
                if (board.isValidMove(piece.getPosition(), destination)) {
                    return false;
                }
            }
        }

        return true;
    }

    public void addMove(Player player, Position from, Position to, Piece capturedPiece) {
        Move move = new Move(player.getColour(), from, to);
        Piece movedPiece = board.getPieceAt(to);

        if (capturedPiece != null) {
            move.setCapturedPiece(capturedPiece);
            notifyPieceCaptured(capturedPiece);
        }

        moves.add(move);
        notifyMoveMade(move); // Observer notification

        // Pawn promotion
        if (movedPiece instanceof Pawn) {
            int y = movedPiece.getPosition().getY();
            // White reaches 8, Black reaches 1
            if ((movedPiece.getColour() == Colours.WHITE && y == 8) ||
                    (movedPiece.getColour() == Colours.BLACK && y == 1)) {
                if (player.getName().equals("computer")) {
                    // Random piece choice
                    List<String> pieces = new ArrayList<>(4);
                    pieces.add("Rook");
                    pieces.add("Bishop");
                    pieces.add("Knight");
                    pieces.add("Queen");
                    Collections.shuffle(pieces);
                    promotePawn((Pawn)movedPiece, pieces.get(0));
                }
                else {
                    notifyPawnPromotion((Pawn)movedPiece);
                }
            }
        }
    }

    public void promotePawn(Pawn pawn, String pieceType) {
        Piece newPiece =  PieceFactory.createPiece(pieceType, pawn.getColour(), pawn.getPosition());
        board.removePiece(pawn);
        board.addPiece(newPiece);
    }

    public boolean checkDraw() {
        int size = moves.size();
        if (size < 8) return false;

        Move lastMove = moves.get(size - 1);
        Move move4 = moves.get(size - 5);
        Move move8;
        if (size >= 9) {
            move8 = moves.get(size - 9);
        }
        else {
            move8 = null;
        }

        if (move8 != null) {
            boolean sameMoveSequence = lastMove.toString().equals(move4.toString()) &&
                                       lastMove.toString().equals(move8.toString());

            Move oppLast = moves.get(size - 2);
            Move opp4 = moves.get(size - 6);
            Move opp8;
            if (size >= 10){
                opp8 = moves.get(size - 10);
            }
            else {
                opp8 = null;
            }

            boolean opponentRepeating = false;
            if (opp8 != null) {
                opponentRepeating = oppLast.toString().equals(opp4.toString()) &&
                                    oppLast.toString().equals(opp8.toString());
            }

            return sameMoveSequence && opponentRepeating;
        }

        return false;
    }

    public ExitCodes getGameState() {
        Player currentPlayer = getCurrentPlayer();
        boolean inCheck = board.isKingInCheck(currentPlayer.getColour());
        boolean hasLegalMoves = !checkForCheckMate();

        if (!hasLegalMoves) {
            if (inCheck) {
                return ExitCodes.LOSE_CHECKMATE;
            }
            else {
                return ExitCodes.DRAW;
            }
        }

        if (checkDraw()) {
            return ExitCodes.DRAW;
        }

        return ExitCodes.CONTINUE;
    }

    public void processTurn(Position from, Position to) throws InvalidCommandException {
        Player currentPlayer = getCurrentPlayer();
        Piece targetPiece = board.getPieceAt(to);

        // Game logic update
        currentPlayer.makeMove(from, to, board);
        addMove(currentPlayer, from, to, targetPiece);
        switchPlayer();
    }

    public void handleComputerTurn() {
        Player computer = getCurrentPlayer();
        List<ChessPair<Position, Piece>> pieces = computer.getOwnedPieces();
        Collections.shuffle(pieces);

        for (ChessPair<Position, Piece> pair : pieces) {
            Piece p = pair.getValue();
            Position from = p.getPosition();
            List<Position> moves = p.getPossibleMoves(board);
            Collections.shuffle(moves);

            for (Position destination : moves) {
                if (board.isValidMove(from, destination)) {
                    Piece targetPiece = board.getPieceAt(destination);
                    computer.makeMove(from, destination, board);
                    addMove(computer, from, destination, targetPiece);
                    switchPlayer();
                    return;
                }
            }
        }
    }
}
