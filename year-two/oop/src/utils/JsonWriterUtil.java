package utils;

import model.*;

import model.pieces.Piece;
import org.json.simple.JSONArray;
import org.json.simple.JSONObject;

import java.io.FileWriter;
import java.io.IOException;
import java.nio.file.Path;
import java.util.*;

public final class JsonWriterUtil {

    private JsonWriterUtil() {
    }

    public static void writeUsers(Path path, List<User> users) {
        JSONArray userList = new JSONArray();

        for (User user : users) {
            JSONObject userObj = new JSONObject();
            userObj.put("email", user.getEmail());
            userObj.put("password", user.getPassword());
            userObj.put("points", user.getPoints());

            JSONArray gameIds = new JSONArray();
            if (user.getActiveGameIds() != null) {
                gameIds.addAll(user.getActiveGameIds());
            }
            userObj.put("games", gameIds);

            userList.add(userObj);
        }

        writeToFile(path, userList);
    }

    public static void writeGames(Path path, Map<Integer, Game> existingGames) {
        JSONArray gamesList = new JSONArray();

        for (Game game : existingGames.values()) {
            JSONObject gameObj = new JSONObject();
            gameObj.put("id", game.getId());

            // Players
            JSONArray players = new JSONArray();
            if (game.getPlayers() != null) {
                for (Player player : game.getPlayers()) {
                    JSONObject playerObj = new JSONObject();
                    playerObj.put("email", player.getName());
                    playerObj.put("color", player.getColour().toString());
                    players.add(playerObj);
                }
            }
            gameObj.put("players", players);
            gameObj.put("currentPlayerColor", game.getCurrentPlayer().getColour().toString());

            // Board
            JSONArray boardArray = new JSONArray();
            Set<ChessPair<Position, Piece>> pieces = game.getBoardPieces();

            if (pieces != null) {
                for (ChessPair<Position, Piece> pair : pieces) {
                    Piece piece = pair.getValue();
                    JSONObject pieceObj = new JSONObject();
                    pieceObj.put("type", piece.typeAsString());
                    pieceObj.put("color", piece.getColour().toString());
                    pieceObj.put("position", piece.getPosition().toString());
                    boardArray.add(pieceObj);
                }
            }
            gameObj.put("board", boardArray);

            // Moves
            JSONArray movesArray = new JSONArray();
            if (game.getMoves() != null) {
                for (Move move : game.getMoves()) {
                    JSONObject moveObj = new JSONObject();
                    moveObj.put("playerColor", move.getPlayerColour().toString());
                    moveObj.put("from", move.getFrom().toString());
                    moveObj.put("to", move.getTo().toString());
                    movesArray.add(moveObj);
                }
            }
            gameObj.put("moves", movesArray);

            gamesList.add(gameObj);
        }

        writeToFile(path, gamesList);
    }

    public static void writeToFile(Path path, JSONArray jsonArray) {
        String rawJson = jsonArray.toJSONString();
        String readableJson = toHumanFormat(rawJson);

        try (FileWriter file = new FileWriter(path.toFile())) {
            file.write(readableJson);
            file.flush();
        } catch (IOException e) {
            System.err.println("Error writing to file " + path + ": " + e.getMessage());
        }
    }

    public static String toHumanFormat(String jsonString) {
        StringBuilder prettyJSONBuilder = new StringBuilder();
        int indentLevel = 0;
        boolean inQuote = false;

        for (char charFromJson : jsonString.toCharArray()) {
            switch (charFromJson) {
                case '"':
                    inQuote = !inQuote;
                    prettyJSONBuilder.append(charFromJson);
                    break;
                case ' ':
                    if (inQuote) {
                        prettyJSONBuilder.append(charFromJson);
                    }
                    break;
                case '{':
                case '[':
                    prettyJSONBuilder.append(charFromJson);
                    if (!inQuote) {
                        indentLevel++;
                        appendIndentedNewLine(indentLevel, prettyJSONBuilder);
                    }
                    break;
                case '}':
                case ']':
                    if (!inQuote) {
                        indentLevel--;
                        appendIndentedNewLine(indentLevel, prettyJSONBuilder);
                    }
                    prettyJSONBuilder.append(charFromJson);
                    break;
                case ',':
                    prettyJSONBuilder.append(charFromJson);
                    if (!inQuote) {
                        appendIndentedNewLine(indentLevel, prettyJSONBuilder);
                    }
                    break;
                default:
                    prettyJSONBuilder.append(charFromJson);
            }
        }
        return prettyJSONBuilder.toString();
    }

    private static void appendIndentedNewLine(int indentLevel, StringBuilder stringBuilder) {
        stringBuilder.append("\n");
        for (int i = 0; i < indentLevel; i++) {
            // 2 spaces for indentation
            stringBuilder.append("  ");
        }
    }
}