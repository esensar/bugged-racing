(defmulti task first)

(defmethod task :default
  [[task-name]]
  (println "Unknown task:" task-name)
  (System/exit 1))

(require '[figwheel.main :as figwheel])

(defmethod task nil
  [_]
  (figwheel/-main "--build" "dev"))

(require '[music.core])

(defmethod task "play"
  [_]
  (music.core/-main "main_theme"))

(task *command-line-args*)
