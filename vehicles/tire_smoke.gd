class_name TireSmoke
extends Particles

onready var sound_player: AudioStreamPlayer3D = $tire_sound_player
onready var sound_playback: AudioStreamPlayback = $tire_sound_player.get_stream_playback()

func _ready() -> void:
	_update_sound(1)
	# sound_player.play()

func update(skidinfo: float) -> void:
	_update_sound(skidinfo)
	if skidinfo < 0.5:
		emitting = true
	else:
		emitting = false

func _update_sound(skidinfo: float) -> void:
	sound_player.pitch_scale = 1 + (1 - skidinfo)
	var to_fill = sound_playback.get_frames_available()
	var factor = (1 - skidinfo) * 2
	if to_fill <= 0:
		return
	while to_fill > 0:
		sound_playback.push_frame(Vector2(1.0, 1.0) * factor)
		factor += sin(factor) * 2
		to_fill -= 1
