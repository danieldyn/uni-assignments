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

    public void addMove(Player p, Position from, Position to, Piece capturedPiece) {
        Move move = new Move(p.getColour(), from, to);

        if (capturedPiece != null) {
            move.setCapturedPiece(capturedPiece);
            notifyPieceCaptured(capturedPiece);
        }

        moves.add(move);
        notifyMoveMade(move);
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

    // Game running related part
    public ExitCode play(Scanner sc) {
        boolean gameRunning = true;

        while (gameRunning) {
            System.out.println(board.toString(getHumanPlayer().getColour()));

            // Draw check
            if (checkDraw()) {
                System.out.println("The Computer surrenders due to stalemate/repetition.");
                return ExitCode.DRAW;
            }

            Player currentPlayer = getCurrentPlayer();
            System.out.println("Next to move: " + currentPlayer.getColour() + " (" + currentPlayer.getName() + ")");

            // Turn decision
            ExitCode result = ExitCode.CONTINUE;
            if (currentPlayer.getName().equals("computer")) {
                result = handleComputerTurn();
            }
            else {
                try {
                    result = handleUserTurn(sc, currentPlayer);
                }
                catch (InvalidMoveException e) {
                    System.out.println(e.getMessage());
                }
            }

            if (result == ExitCode.SAVE || result == ExitCode.SURRENDER) {
                return result;
            }

            // Check for conclusion after the turn ended
            boolean inCheck = board.isKingInCheck(getCurrentPlayer().getColour());
            boolean hasLegalMoves = !checkForCheckMate();

            if (inCheck && !hasLegalMoves) {
                System.out.println(board);

                if (currentPlayer.getName().equals("computer")) {
                    System.out.println("CHECKMATE! YOU LOSE!");
                    return ExitCode.LOSE_CHECKMATE;
                } else {
                    System.out.println("CHECKMATE! YOU WIN!");
                    return ExitCode.WIN_CHECKMATE;
                }
            }
            else if (!inCheck && !hasLegalMoves) {
                System.out.println(board);
                System.out.println("STALEMATE! The game is a draw.");
                return ExitCode.DRAW;
            }
        }

        return ExitCode.SAVE;
    }

    public ExitCode handleUserTurn(Scanner sc, Player player) throws InvalidMoveException {
        while (true) {
            if (board.isKingInCheck(player.getColour())) {
                System.out.println("You are in check!");
            }
            System.out.println("Enter move ('A2-A3'), piece to check ('A2'), 'surrender', or 'exit':");
            String input = sc.nextLine().trim().toUpperCase();

            if (input.equals("EXIT")) {
                return ExitCode.SAVE;
            }

            if (input.equals("SURRENDER")) {
                return ExitCode.SURRENDER;
            }

            // View possible moves
            if (input.length() == 2) {
                try {
                    Position pos = new Position(input);
                    Piece p = board.getPieceAt(pos);
                    if (pos.isOnBoard()) {
                        if (p != null && p.getColour() == player.getColour()) {
                            System.out.println("Selected: " + p);
                            List<Position> moves = p.getPossibleMoves(board);
                            System.out.println("Possible moves: " + moves);
                        }
                        else {
                            throw new InvalidCommandException("That is your opponent's piece! Try again.");
                        }
                    }
                    else {
                        throw new InvalidCommandException("Invalid position! Try again.");
                    }
                }
                catch (InvalidCommandException e) {
                    System.out.println(e.getMessage());
                }
                continue;
            }

            // Make move
            if (input.contains("-")) {
                String[] parts = input.split("-");
                if (parts.length != 2) {
                    System.out.println("Invalid input! Try again.");
                    continue;
                }

                try {
                    Position from = new Position(parts[0]);
                    Position to = new Position(parts[1]);

                    Piece p = board.getPieceAt(from);
                    if (p == null || p.getColour() != player.getColour()) {
                        throw new InvalidCommandException("Invalid position! Try again.");
                    }

                    Piece targetPiece = board.getPieceAt(to);
                    player.makeMove(from, to, board);
                    addMove(player, from, to, targetPiece);

                    switchPlayer();
                    return ExitCode.CONTINUE;

                }
                catch (InvalidCommandException e) {
                    System.out.println(e.getMessage());
                }
            }
            else {
                throw new  InvalidCommandException("Invalid input! Try again.");
            }
        }
    }

    public ExitCode handleComputerTurn() {
        System.out.println("Computer's turn..");
        try {
            Thread.sleep(2500);
        }
        catch (InterruptedException e) {
            System.out.println("Computer's move interrupted.");
        }

        Player computer = getCurrentPlayer();
        List<ChessPair<Position, Piece>> pieces = computer.getOwnedPieces();
        Collections.shuffle(pieces);

        for (ChessPair<Position, Piece> pair : pieces) {
            Piece p = pair.getValue();
            Position from = p.getPosition();
            List<Position> moves = p.getPossibleMoves(board);
            Collections.shuffle(moves);

            for (Position destination : moves) {
                if (board.isValidMove(p.getPosition(), destination)) {
                    try {
                        System.out.println("Computer moves: " + p.getPosition() + "-" + destination);

                        Piece target = board.getPieceAt(destination);
                        computer.makeMove(from, destination, board);
                        addMove(computer, from, destination, target);

                        switchPlayer();
                        return ExitCode.CONTINUE;
                    } catch (InvalidMoveException e) {
                        // Should not happen due to isValidMove check
                    }
                }
            }
        }
        return ExitCode.CONTINUE;
    }
}
