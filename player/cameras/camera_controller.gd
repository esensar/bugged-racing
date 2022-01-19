class_name CameraController
extends Reference

const FOLLOW_CAMERA = preload("res://player/cameras/follow_camera.tscn")
const STATIC_CAMERA = preload("res://player/cameras/static_camera.tscn")

var _cameras = []


func attach_cameras_to(player_node: BuggedVehicle) -> void:
	var cockpit_camera = STATIC_CAMERA.instance()
	player_node.get_cockpit_position().add_child(cockpit_camera)
	cockpit_camera.rotate(Vector3.UP, deg2rad(180))
	var follow_camera = FOLLOW_CAMERA.instance()
	follow_camera.global_transform = player_node.global_transform.translated(
		-player_node.global_transform.basis.z * 100
	)
	follow_camera.follow_target_path = player_node.get_path()
	player_node.get_parent().add_child(follow_camera)
	var bumpera_camera = STATIC_CAMERA.instance()
	player_node.get_bumper_position().add_child(bumpera_camera)
	bumpera_camera.rotate(Vector3.UP, deg2rad(180))
	var hood_camera = STATIC_CAMERA.instance()
	player_node.get_hood_position().add_child(hood_camera)
	hood_camera.rotate(Vector3.UP, deg2rad(180))
	var static_follow_camera = STATIC_CAMERA.instance()
	player_node.get_static_follow_position().add_child(static_follow_camera)
	static_follow_camera.rotate(Vector3.UP, deg2rad(180))
	_cameras = [follow_camera, cockpit_camera, hood_camera, bumpera_camera, static_follow_camera]
	select_camera(GlobalSettings.selected_camera)


func select_camera(camera_index: int) -> void:
	var select_index = camera_index
	if camera_index < 0 or camera_index >= _cameras.size():
		select_index = 0

	GlobalSettings.selected_camera = select_index
	_cameras[select_index].current = true


func next_camera() -> void:
	select_camera(GlobalSettings.selected_camera + 1)
