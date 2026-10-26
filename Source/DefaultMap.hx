class DefaultMap {
    public static inline function getOrSet<K, V>(map: Map<K, V>, key: K, defaultValue: V): V {
        if (!map.exists(key)) {
            map.set(key, defaultValue);
        }
        return map.get(key);
    }
}

