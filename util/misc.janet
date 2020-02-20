(def ffirst (comp first first))

(defn tp
  "Prints a label and a value, and returns the value"
  [l x]
  (printf "%s: %j" (string l) x) x)

(defn omit [remove-ks dict]
  "Returns a copy of dict with remove-ks removed"
  (def r (table ;(kvs dict)))
  (each k remove-ks (put r k nil))
  r)

(defn pick [select-ks dict]
  "Returns a subset of dict based on select-ks"
  (def r @{})
  (each k select-ks (put r k (get dict k)))
  r)

(defn enumerate
  "Returns an array of [index, value] pairs"
  [xs]
  (def r @[])
  (loop [i :range [0 (length xs)]]
    (array/push r [i (in xs i)]))
  r)
