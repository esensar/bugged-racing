(defmulti task first)

(defmethod task :default
  [[task-name]]
  (println "Unknown task:" task-name)
  (System/exit 1))

(require
  '[edna.core :as edna]
  '[music.core :as c]
  '[cljs.build.api :as api]
  '[clojure.java.io :as io])

(defn delete-children-recursively! [f]
  (when (.isDirectory f)
    (doseq [f2 (.listFiles f)]
      (delete-children-recursively! f2)))
  (when (.exists f) (io/delete-file f)))

(defmethod task nil
  [_]
  (let [out-file "resources/public/main.js"
        out-dir "resources/public/main.out"]
    (println "Building main.js")
    (delete-children-recursively! (io/file out-dir))
    (api/build "src" {:main          'music.core
                      :optimizations :advanced
                      :output-to     out-file
                      :output-dir    out-dir
                      :infer-externs true})
    (delete-children-recursively! (io/file out-dir))
    (println "Build complete:" out-file)
    (System/exit 0)))

(defn export-song-wav [song]
  (let [wav-name (str song ".wav")
        build-dir "target"
        output-file (io/file build-dir wav-name)]
    (.mkdir (io/file build-dir))
    (println "Building" wav-name)
    (edna/export! (c/read-music song) {:type :wav, :out output-file})
    (println "Build complete:" wav-name)
    (println "Song saved into:" (.getPath output-file))))

(defmethod task "wav"
  [[_ song]]
  (export-song-wav song)
  (System/exit 0))

(defmethod task "soundtrack"
  [_]
  (run! #(task ["wav" %]) (c/get-all-songs))
  (System/exit 0))

(task *command-line-args*)
