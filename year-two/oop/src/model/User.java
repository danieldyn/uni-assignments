package model;

import java.util.ArrayList;
import java.util.List;

public class User {
    private String email;
    private String password;
    private List<Game> activeGames;
    private List<Integer> activeGameIds;
    private int points;

    public User() {
        activeGames = new ArrayList<>();
        activeGameIds = new ArrayList<>();
    }

    public User(String email, String password) {
        this.email = email;
        this.password = password;
        activeGames = new ArrayList<>();
        activeGameIds = new ArrayList<>();
        this.points = 0;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public void setGames(List<Integer> gameIds) {
        this.activeGameIds = gameIds;
    }

    public void setPoints(int points) {
        if (points < 0) {
            points = 0;
            return;
        }
        this.points = points;
    }

    public String getEmail() {
        return email;
    }

    public String getPassword() {
        return password;
    }

    public int getPoints() {
        return points;
    }

    public List<Game> getActiveGames() {
        return activeGames;
    }

    public List<Integer> getActiveGameIds() {
        return activeGameIds;
    }

    public void addGame(Game g) {
        activeGames.add(g);
        if (!activeGameIds.contains(g.getId())) {
            activeGameIds.add(g.getId());
        }
    }

    public void removeGame(Game g) {
        activeGames.remove(g);
        if (g != null) {
            activeGameIds.remove((Integer)g.getId());
        }
    }
}
