import java.nio.file.Path;
import java.util.*;
import java.nio.file.Paths;

import java.io.IOException;

import org.json.simple.parser.ParseException;

import javax.swing.*;

public class Main {
    private List<User> existingUsers = new ArrayList<>();
    private Map<Integer, Game> existingGames = new HashMap<>();
    private User currentUser = null;
    private static final Main instance = new Main();

    private Main() { } // singleton

    public static Main getInstance() {
        return instance;
    }

    public User getCurrentUser() {
        return currentUser;
    }

    public void read() {
        try {
            Path accountsPath = Paths.get("src/input/accounts.json");
            Path gamesPath = Paths.get("src/input/games.json");

            existingUsers = JsonReaderUtil.readUsers(accountsPath);
            existingGames = JsonReaderUtil.readGamesAsMap(gamesPath);

            for (User user : existingUsers) {
                if (user.getActiveGameIds() != null) {
                    // Copy array to avoid concurrent modification exception
                    List<Integer> gameIdsCopy = new ArrayList<>(user.getActiveGameIds());
                    for (Integer integer : gameIdsCopy) {
                        Game game = existingGames.get(integer);
                        if (game != null) {
                            user.addGame(game);
                        }
                    }
                }
            }
        }
        catch (IOException | ParseException e) {
            System.err.println(e.getMessage());
        }
    }

    public void write() {
        System.out.println("Saving game state...");

        Path accountsPath = Paths.get("src/input/accounts.json");
        Path gamesPath = Paths.get("src/input/games.json");

        JsonWriterUtil.writeUsers(accountsPath, existingUsers);
        JsonWriterUtil.writeGames(gamesPath, existingGames);

        System.out.println("Save complete!");
    }

    public User login(String email, String password) {
        for (User user : existingUsers) {
            if (user.getEmail().equals(email) && user.getPassword().equals(password)) {
                currentUser = user;
                return user;
            }
        }
        return null;
    }

    public void logout() {
        currentUser = null;
    }

    public User newAccount(String email, String password) {
        User user = new User(email, password);
        currentUser = user;
        existingUsers.add(user);
        return user;
    }

    public static void main(String[] args) {
        instance.read();

        SwingUtilities.invokeLater(() -> new LoginScreen("Chess App"));

        //instance.write();
    }

    public Game startNewGame(String alias, String playerColour) {
        Player player = new Player(alias, playerColour);
        Player computer = null;
        if (playerColour.toUpperCase().equals("WHITE")) {
            computer = new Player("computer", "BLACK");
        }
        else {
            computer = new Player("computer", "WHITE");
        }

        int maxId = 1;
        for (int id : existingGames.keySet()) {
            if (id > maxId) {
                maxId = id;
            }
        }

        Game game = new Game(maxId + 1, player, computer);
        game.start();

        // Add to global list and user list
        existingGames.put(maxId + 1, game);
        currentUser.addGame(game);

        return game;
    }

    public void runGame(Game game, Scanner sc) {
        ExitCode result = game.play(sc);

        if (result == ExitCode.SAVE) {
            System.out.println("Game saved successfully. Feel free to resume it later.");
            return;
        }

        Player humanPlayer = game.getHumanPlayer();
        int Y = humanPlayer.getPoints();
        int X = currentUser.getPoints();

        int finalScoreChange = 0;

        switch (result) {
            case WIN_CHECKMATE:
                finalScoreChange = Y + 300;
                System.out.println("Victory! You've gained 300 points.");
                break;

            case LOSE_CHECKMATE:
                finalScoreChange = Y - 300;
                System.out.println("Defeat! You've been deducted 300 points.");
                break;

            case SURRENDER:
                finalScoreChange = Y - 150;
                System.out.println("Surrendered. You've been deducted 150 points.");
                break;

            case DRAW:
                finalScoreChange = Y;
                System.out.println("Draw. Points from captures added.");
                break;

            default:
                break;
        }

        // Update User Account
        int newTotal = X + finalScoreChange;
        if (newTotal < 0) { // a bit of decency here
            newTotal = 0;
        }

        currentUser.setPoints(newTotal);
        // Remove game from active lists since it is finished
        currentUser.removeGame(game);
        existingGames.remove(game.getId());

        System.out.println("Game Over. Total Points: " + newTotal);
    }
}
