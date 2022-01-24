class_name TireSmoke
extends Particles

onready var sound_player: AudioStreamPlayer3D = $tire_sound_player
onready var sound_playback: AudioStreamPlayback = $tire_sound_player.get_stream_playback()


func _ready() -> void:
	_update_sound(1)
	sound_player.playing = true
	sound_player.stream_paused = true


func update(skidinfo: float) -> void:
	_update_sound(skidinfo)
	if skidinfo < 0.25:
		emitting = true
		sound_player.stream_paused = false
	else:
		emitting = false
		sound_player.stream_paused = true


func _update_sound(skidinfo: float) -> void:
	sound_player.pitch_scale = 1 + pow(skidinfo, 2) - skidinfo / 3
