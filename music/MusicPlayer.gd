extends Node

export var main_theme: AudioStream

onready var themes = {"main": main_theme}

onready var player: AudioStreamPlayer = $Player


func play_theme(theme: String) -> void:
	player.stream = themes[theme]
	player.play()
