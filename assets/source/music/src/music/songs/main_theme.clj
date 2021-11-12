(ns music.songs.main-theme
  (:require
    [clojure.set :as set]
    [edna.core :as edna]))

(def tempo 72)

(defn intro [volume]
  #{
    [:piano {:octave 4
             :tempo tempo
             :volume volume}
     1/4 :-d :-a 1/8 :-e :-c 1/4 :-g :e :c
     1/2 :-d
     1/4 :-d :-a 1/8 :-e :-c 1/4 :-g :d :-f 1/8 :e :g 1/4 :f :a 1/16 :g 1/4 :f  1/2 :c] })

(defn verse [volume]
  #{
    [:piano {:octave 4
             :tempo tempo
             :volume volume}
     1/16 #{:-d :f#} 1/8 #{:-e :+f} :a 1/2 #{:f# :+d}
     :r :r
     1/16 #{:-c :g#} 1/8 #{:-e :+f} :b 1/2 #{:+d :f#}]
    [:steel-drum {:octave 3
                  :tempo tempo
                  :volume (quot volume 2) }
     1/8 :-a :a :b 1/2 :a
     :c :c
     :a 1/8 :b :a :-a]
    [:acoustic-bass {:octave 3
                     :tempo tempo
                     :volume (quot volume 3) }
     1/8 :-a :a :b 1/2 :a
     :c :c
     :a 1/8 :b :a :-a]})

(defn pre-chorus [volume]
  #{
    [:steel-drum {:octave 3
                  :tempo (* 2 tempo)
                  :volume volume}
     1/8 :a 1/4 :a 1/8 :b 1/2 :-a]
    [:acoustic-bass {:octave 3
                     :tempo (* 2 tempo)
                     :volume volume}
     1/8 :b 1/4 :c 1/8 :g 1/2 :-g#]
    })

(defn chorus [volume]
  #{
    [:piano {:octave 3
             :tempo tempo
             :volume volume}
     1/16 #{:-d :f#} 1/8 #{:-e :+f} :a 1/4 #{:f# :+d}
     1/16 :c :r :d :r :e :r :f
     1/16 :r 1/4 :d 1/8 :r :r
     1/16 :f :r :e :r :d :r :c ]
    [:acoustic-bass {:octave 3
                     :tempo tempo
                     :volume (quot volume 3) }
     1/16 :-a :a :b :c 1/4 :a
     1/64 (repeat 7 [:c :d :g :-f])
     1/16 :a :c :b :a 1/4 :-b
     1/64 (repeat 7 [:-b :a :c :-g])] })

(concat
  (map intro [20 40 80 100])
  (map verse [100 80])
  (map pre-chorus [60 80])
  (map verse [100])
  (map pre-chorus [60 80])
  (map chorus [100 100])
  (map verse [100 60])
  (map chorus [40 20]))
