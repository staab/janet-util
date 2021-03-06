(import pq)

# Decoders

(def *decoders* pq/*decoders*)
(put pq/*decoders* 20 scan-number)   # int8
(put pq/*decoders* 1700 scan-number) # numeric
(put pq/*decoders* 2950 string)      # uuid
(put pq/*decoders* 1114 string)      # timestamp
(put pq/*decoders* 1184 string)      # timestamp
(put pq/*decoders* 1082 string)      # timestamp

# Encoders

(defn uuid        [x] (if x [2950 false x] nil))
(defn timestamp   [x] (if x [1114 false x] nil))
(defn timestamptz [x] (if x [1184 false x] nil))
(defn date        [x] (if x [1082 false x] nil))
(def json pq/json)
(def jsonb pq/jsonb)

# General purpose helpers

(var conn nil)

(defn connect [& args] (set conn (pq/connect ;args)))
(defn disconnect [] (set conn nil) (pq/close conn))
(defn ident [x] (pq/escape-identifier conn (string x)))
(defn liter [s] (if (number? s) s (pq/escape-literal conn (string s))))
(defn composite [& args] (string/join args " "))
(defn exec [& args] (pq/exec conn ;args))
(defn all [& args] (pq/all conn ;args))
(defn row [& args] (pq/row conn ;args))
(defn col [& args] (pq/col conn ;args))
(defn val [& args] (pq/val conn ;args))
(defn id [] (val "select uuid_generate_v4()"))

(defn iter [query &opt opts & params]
  (let [cur (ident (id))
        chunk-size (liter (get opts :chunk-size 100))
        get-chunk |(all (composite "FETCH FORWARD" chunk-size cur))]
    (var done? false)
    (exec (composite "DECLARE" cur "CURSOR FOR" query) ;params)
    (loop [chunk :iterate (get-chunk) :until (empty? chunk)]
      (each row chunk (yield row)))
    (exec (composite "CLOSE" cur))))

# More Specific

(defn refresh-login-code [tbl code-field expires-field id]
  (val
    (composite
      `UPDATE ` tbl
      `SET ` code-field ` = CASE
             WHEN ` expires-field ` > now() at time zone 'utc'
             THEN coalesce(` code-field `, floor(random() * 100000 + 100000)::text)
             ELSE floor(random() * 100000 + 100000)::text
           END,
           ` expires-field ` = now() at time zone 'utc' + INTERVAL '10 minute'
       WHERE id = $1
       RETURNING ` code-field)
    (uuid id)))
