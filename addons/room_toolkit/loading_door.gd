class_name LoadingDoor
extends Area2D

signal room_exited()

@export var target_path: String
@export var player_name: String = "Player"
@export var transition_delta := Vector2(50, 0)
@export var transition_time := 0.4
# TODO: smarter placement of the new room
## Position of the spawned-in [Room] relative to this door's parent [Room].
@export var room_spawn_position := Vector2(0, 0)
@export var tween_easing: Tween.EaseType = Tween.EASE_OUT
@export var tween_transition: Tween.TransitionType = Tween.TRANS_QUAD

var loaded_room: Room
var camera: BoundedCamera
var ld_active: bool = false

@onready var world := get_node("/root/World")


func _ready() -> void:
	var current_camera: Camera2D = get_viewport().get_camera_2d()
	if current_camera is BoundedCamera:
		camera = current_camera

	if not target_path.contains("res://"):
		push_error("Tried to load non-res path: ", target_path)
		return
	ResourceLoader.load_threaded_request(target_path)

	body_entered.connect(_on_body_entered)


func transition_camera(body: Node2D) -> void:
	var parameters := PhysicsPointQueryParameters2D.new()
	parameters.collide_with_areas = true
	parameters.collide_with_bodies = false
	parameters.position = body.position + transition_delta
	var areas := get_world_2d().direct_space_state.intersect_point(parameters)

	var new_boundary: CameraBoundary = null
	for area in areas:
		if area.collider is CameraBoundary:
			if not new_boundary:
				new_boundary = area.collider
			elif area.collider.bound_priority > new_boundary.bound_priority:
				new_boundary = area.collider

	if new_boundary:
		var old_smoothing_state: bool = camera.position_smoothing_enabled
		camera.position_smoothing_enabled = false
		camera.bound_enable = false
		camera.follow_enable = false
		var target_pos := camera.clamp_position_to_boundary(new_boundary, body.position + transition_delta)

		var camera_tween := create_tween()
		camera_tween.set_ease(tween_easing)
		camera_tween.set_trans(tween_transition)
		camera_tween.tween_property(camera, "position", target_pos, transition_time)
		camera_tween.tween_callback(camera_transition_ended.bind(old_smoothing_state))


func transition_player(body: Node2D) -> void:
	var player_tween := create_tween()
	#player_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	player_tween.tween_property(body, "position", body.position + transition_delta, transition_time)
	player_tween.tween_callback(player_transition_ended.bind(loaded_room, body))
	#loaded_room.set_active()


func camera_transition_ended(smoothing: bool) -> void:
	camera.bound_enable = true
	camera.follow_enable = true
	camera.position_smoothing_enabled = smoothing


func player_transition_ended(new_room: Room, player: Node) -> void:
	#get_parent().set_process(true)
	#get_parent().set_physics_process(true)
	player.set_process(true)
	player.set_physics_process(true)
	new_room.set_active()
	room_exited.emit()


func _on_body_entered(body: Node2D) -> void:
	if ld_active and body.name == player_name:
		get_parent().set_process(false)
		get_parent().set_physics_process(false)
		body.set_process(false)
		body.set_physics_process(false)
		# maybe the instantiation could be done in advance?
		# or we could defer this whole process
		loaded_room = ResourceLoader.load_threaded_get(target_path).instantiate()
		loaded_room.position = get_parent().position + room_spawn_position
		loaded_room.auto_activate = false
		world.add_child.call_deferred(loaded_room)

		if camera:
			transition_camera.call_deferred(body)
		transition_player.call_deferred(body)


func _on_room_activated() -> void:
	ld_active = true
