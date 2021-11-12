(ns music.core
  (:require [edna.core :as edna]
            [clojure.java.io :as io]
            [clojure.string :as string]))

(def songs-dir "src/music/songs/")

(defn read-music [song]
  (load-file (str songs-dir song ".clj")))

(defn get-all-songs []
  (map #(string/replace (.getName %) ".clj" "") (.listFiles (io/file songs-dir))))

(defonce state (atom nil))

(defn -main [song]
  (swap! state edna/stop!)
  (reset! state (edna/play! (read-music song))))

(defmacro build-for-cljs []
  (edna/edna->data-uri (read-music "main_theme")))
