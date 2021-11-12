# Bugged racing music source

Music for this game is builts using [edna](https://github.com/oakes/edna) clojure library, which uses [alda](https://github.com/alda-lang/alda) underneath.

To build this project, you'll need the Clojure CLI tool:

https://clojure.org/guides/deps_and_cli

To develop in a browser with live code reloading:

`clj -M dev.clj`


To build a release version for the web:

`clj -M prod.clj`


To play the song once:

`clj -M dev.clj play [song]`


To build wav:

`clj -M prod.clj wav [song]`

To build wav for all songs:

`clj -M prod.clj soundtrack`
