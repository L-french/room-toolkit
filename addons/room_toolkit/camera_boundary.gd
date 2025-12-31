class_name CameraBoundary
extends Area2D
## Dynamically limits camera movement when a [BoundedCamera]'s target is detected within.
##
## When a [CameraBoundary] is smaller than the [Viewport] in either the x or y axes,
## the camera will instead center on the [CameraBoundary] in that axis.
##
## The target should have an [Area2D] attached for detection to work properly. 
##
## For now, a [CameraBoundary] expects its collision shape to be an axis-aligned rectangle. 
## Other shapes can be used for detection, but the resulting camera limits will be rectangular.

signal boundary_transitioned()

@export var enable := true
@export_category("Boundary")
@export var custom_boundaries: Rect2
@export var bound_priority: int = 0
@export var detector_name: String = "CameraBoundaryDetector"
@export var collision_shape_name: String = "CollisionShape2D"


func _ready() -> void:
	var camera: Camera2D = get_viewport().get_camera_2d()
	if camera is BoundedCamera:
		boundary_transitioned.connect(camera._on_boundary_transitioned)
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)


func get_camera_boundary() -> Rect2:
	# TODO: operate on class
	# TODO: implement custom boundaries
	var bound_size: Vector2 = get_node(collision_shape_name).get_shape().get_rect().size
	var bound_position: Vector2 = get_node(collision_shape_name).global_position - (bound_size / 2)
	var bound_rect := Rect2(bound_position, bound_size)
	return bound_rect if bound_rect else Rect2(global_position, Vector2(0, 0))


func _on_area_entered(area: Area2D) -> void:
	# TODO: should we use a class, rather than relying on name?
	if area.name == detector_name and enable:
		# deferring here accounts for the player starting in a boundary when the scene is loaded.
		boundary_transitioned.emit.call_deferred()


func _on_area_exited(area: Area2D) -> void:
	if area.name == detector_name and enable:
		# deferring here accounts for the player starting in a boundary when the scene is loaded.
		boundary_transitioned.emit.call_deferred()
