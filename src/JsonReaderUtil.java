import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;
import org.json.simple.parser.ParseException;

import java.io.IOException;
import java.io.Reader;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public final class JsonReaderUtil {

    private JsonReaderUtil() {
    }

    public static List<User> readUsers(Path path) throws IOException, ParseException {
        if (path == null || !Files.exists(path)) {
            return new ArrayList<>();
        }
        try (Reader reader = Files.newBufferedReader(path, StandardCharsets.UTF_8)) {
            JSONParser parser = new JSONParser();
            Object root = parser.parse(reader);
            JSONArray arr = asArray(root);
            List<User> result = new ArrayList<>();

            if (arr == null) {
                return result;
            }

            for (Object item : arr) {
                JSONObject obj = asObject(item);
                if (obj == null) {
                    continue;
                }

                User usr = new User();
                usr.setEmail(asString(obj.get("email")));
                usr.setPassword(asString(obj.get("password")));
                usr.setPoints(asInt(obj.get("points"), 0));
                List<Integer> gameIds = new ArrayList<>();
                JSONArray games = asArray(obj.get("games"));
                if (games != null) {
                    for (Object gid : games) {
                        gameIds.add(asInt(gid, 0));
                    }
                }
                usr.setGames(gameIds);
                result.add(usr);
            }
            return result;
        }
    }

    public static Map<Integer, Game> readGamesAsMap(Path path) throws IOException, ParseException {
        Map<Integer, Game> map = new HashMap<>();
        if (path == null || !Files.exists(path)) {
            return map;
        }
        try (Reader reader = Files.newBufferedReader(path, StandardCharsets.UTF_8)) {
            JSONParser parser = new JSONParser();
            Object root = parser.parse(reader);
            JSONArray arr = asArray(root);
            if (arr == null) return map;
            for (Object item : arr) {
                JSONObject obj = asObject(item);
                if (obj == null) {
                    continue;
                }
                int id = asInt(obj.get("id"), -1);
                if (id < 0) {
                    continue;
                } // skip invalid
                Game g = new Game();
                g.setId(id);

                // players array
                JSONArray playersArr = asArray(obj.get("players"));
                if (playersArr != null) {
                    List<Player> players = new ArrayList<>();
                    for (Object pItem : playersArr) {
                        JSONObject pObj = asObject(pItem);
                        if (pObj == null) {
                            continue;
                        }
                        String email = asString(pObj.get("email"));
                        String color = asString(pObj.get("color"));
                        players.add(new Player(email, color));
                    }
                    g.setPlayers(players);
                }

                // currentPlayerColour
                g.setCurrentPlayerColour(asString(obj.get("currentPlayerColor")));

                // board array
                JSONArray boardArr = asArray(obj.get("board"));
                if (boardArr != null) {
                    List<Piece> board = new ArrayList<>();
                    for (Object bItem : boardArr) {
                        JSONObject bObj = asObject(bItem);
                        if (bObj == null) {
                            continue;
                        }

                        String type = asString(bObj.get("type"));
                        String colour = asString(bObj.get("color"));
                        String position = asString(bObj.get("position"));
                        board.add(PieceFactory.createPiece(type, colour, position));
                    }
                    g.setBoard(board);
                }

                // Parse optional moves array
                JSONArray movesArr = asArray(obj.get("moves"));
                if (movesArr != null) {
                    List<Move> moves = new ArrayList<>();
                    for (Object mItem : movesArr) {
                        JSONObject mObj = asObject(mItem);
                        if (mObj == null) {
                            continue;
                        }

                        String playerColor = asString(mObj.get("playerColor"));
                        String from = asString(mObj.get("from"));
                        String to = asString(mObj.get("to"));
                        moves.add(new Move(playerColor, from, to));
                    }
                    g.setMoves(moves);
                }
                map.put(id, g);
            }
        }
        return map;
    }

    // -------- helper converters --------

    private static JSONArray asArray(Object o) {
        return (o instanceof JSONArray) ? (JSONArray) o : null;
    }

    private static JSONObject asObject(Object o) {
        return (o instanceof JSONObject) ? (JSONObject) o : null;
    }

    private static String asString(Object o) {
        return o == null ? null : String.valueOf(o);
    }

    private static int asInt(Object o, int def) {
        if (o instanceof Number) return ((Number) o).intValue();
        try {
            return o != null ? Integer.parseInt(String.valueOf(o)) : def;
        } catch (NumberFormatException e) {
            return def;
        }
    }

    private static long asLong(Object o, long def) {
        if (o instanceof Number) return ((Number) o).longValue();
        try {
            return o != null ? Long.parseLong(String.valueOf(o)) : def;
        } catch (NumberFormatException e) {
            return def;
        }
    }
}
