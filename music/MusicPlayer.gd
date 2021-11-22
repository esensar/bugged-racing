extends Node

export var main_theme: AudioStream

var current_theme = null

onready var themes = {"main": main_theme}
onready var player: AudioStreamPlayer = $Player


func play_theme(theme: String) -> void:
	if theme != current_theme:
		player.stream = themes[theme]
		player.play()
		current_theme = theme
