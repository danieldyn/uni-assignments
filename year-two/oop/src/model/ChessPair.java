package model;

public class ChessPair<K, V> implements Comparable<ChessPair<K, V>>{
    private final K key;
    private final V value;

    public ChessPair(K key, V value) {
        this.key = key;
        this.value = value;
    }

    public K getKey() {
        return key;
    }

    public V getValue() {
        return value;
    }

    public int compareTo(ChessPair<K, V> chessPair) {
        Position key1 = (Position) this.key;
        Position key2 = (Position) chessPair.key;
        return key1.compareTo(key2);
    }

    public int hashCode() {
        return key.hashCode();
    }

    public String toString() {
        return key.toString() + "-" + value.toString();
    }
}
