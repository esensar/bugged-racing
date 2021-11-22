(ns music.songs.main-theme)

(def tempo 72)

(defn intro [volume]
  (set
    (map
      (fn [instrument] [instrument {:octave 2
                                    :tempo tempo
                                    :volume volume}
                        1/4 :-d :-a 1/8 :-e :-c 1/4 :-g :e :c
                        1/2 :-d
                        1/4 :-d :-a 1/8 :-e :-c 1/4 :-g :d :-f 1/8 :e :g 1/4 :f :a 1/16 :g 1/4 :f  1/2 :c]) [:piano :violin :acoustic-bass])))

(concat
  (map intro [70 100]))
