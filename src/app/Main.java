package app;

import model.ExitCodes;
import model.Game;
import model.Player;
import model.User;
import ui.LoginScreen;
import utils.JsonReaderUtil;
import utils.JsonWriterUtil;

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

    private Main() {
    } // singleton

    public static Main getInstance() {
        return instance;
    }

    public User getCurrentUser() {
        return currentUser;
    }

    public void read() {
        try {
            Path accountsPath = Paths.get("input/accounts.json");
            Path gamesPath = Paths.get("input/games.json");

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
        } catch (IOException | ParseException e) {
            System.err.println(e.getMessage());
        }
    }

    public void write() {
        System.out.println("Saving game state...");

        Path accountsPath = Paths.get("input/accounts.json");
        Path gamesPath = Paths.get("input/games.json");

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
        } else {
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

    public void deleteGame(Game game) {
        currentUser.removeGame(game);
        existingGames.remove(game.getId());
    }
}
