(import json)

(defn send-json [status body & args]
  (let [opts (table ;args)]
    (merge
      {:status status
       :body (json/encode body)
       :headers (merge {"Content-Type" ct/json} (get opts :headers {}))}
      (omit [:headers] opts))))

(defn get-cookie [req k]
  (let [xs (->>
            (get-in req [:headers "Cookie"])
            (string/split "; ")
            (map |(string/split "=" $)))]
    ((table ;(flatten xs)) k)))
