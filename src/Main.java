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

    public void startNewGame(String alias, String playerColour) {
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

        //runGame(game, sc);
    }

    public void handleActiveGames(Scanner sc) {
        List<Game> games = currentUser.getActiveGames();
        if (games.isEmpty()) {
            System.out.println("You have no active games. Try starting a new one against the computer!");
            return;
        }

        System.out.println("Select a game ID:");
        for (Game g : games) {
            System.out.println("ID: " + g.getId());
        }

        Game selected = null;
        int id = 0;

        while (selected == null) {
            try {
                String input = sc.nextLine().trim();
                id = Integer.parseInt(input);

                for (Game g : games) {
                    if (g.getId() == id) {
                        selected = g;
                    }
                }

                if (selected == null) {
                    throw new InvalidCommandException("Invalid game ID. Try again.");
                }
            }
            catch (Exception e) {
                System.out.println(e.getMessage());
            }
        }
        String choice;

        while (true) {
            try {
                System.out.println("Choose an option for game " + id + ":");
                System.out.println("[1] Play/Resume");
                System.out.println("[2] View Details");
                System.out.println("[3] Delete");

                choice = sc.nextLine().trim();
                if (choice.equals("1") || choice.equals("2") || choice.equals("3")) {
                    break;
                }
                else {
                    throw new InvalidCommandException("Invalid option. Try again.");
                }
            }
            catch (InvalidCommandException e) {
                System.out.println(e.getMessage());
            }
        }

        if (choice.equals("1")) {
            selected.resume();
            runGame(selected, sc);
        }
        else if (choice.equals("2")) {
            System.out.println("Game information: \n" + selected);
        }
        else if (choice.equals("3")) {
            currentUser.removeGame(selected);
            existingGames.remove(id);
            System.out.println("Game deleted.");
        }
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
