class_name BoundedCamera
extends Camera2D
## A [Camera2D] which may be assigned a [member target] to follow, respecting any [CameraBoundary]
## which overlaps the [member target].

@export_group("Boundaries")
@export var active_boundary: CameraBoundary
@export var bound_enable: bool = true

@export_group("Following")
@export var target: Node
@export var follow_enable: bool = true

@onready var width_delta: float = get_viewport_rect().size.x / 2
@onready var height_delta: float = get_viewport_rect().size.y / 2


func _ready() -> void:
	get_viewport().size_changed.connect(_on_viewport_size_changed)


func _process(_delta: float) -> void:
	if target and follow_enable:
		var new_pos: Vector2 = target.position
		if active_boundary and bound_enable:
			new_pos = clamp_position_to_boundary(active_boundary, target.position)
		position = new_pos


func clamp_position_to_boundary(boundary: CameraBoundary, target_position: Vector2) -> Vector2:
	if not boundary.enable:
		return target_position

	var clamped_pos: Vector2 = target_position
	var active_area: Rect2 = boundary.get_camera_boundary()
	if active_area.size.x > width_delta * 2:
		var bound_left: float = active_area.position.x + width_delta
		var bound_right: float = active_area.position.x + active_area.size.x - width_delta
		clamped_pos.x = clamp(clamped_pos.x, bound_left, bound_right)
	else:
		# if boundary is smaller than camera, just center camera in the boundary
		clamped_pos.x = active_area.position.x + (active_area.size.x / 2)
	if active_area.size.y > height_delta * 2:
		var bound_top: float = active_area.position.y + height_delta
		var bound_bottom: float = active_area.position.y + active_area.size.y - height_delta
		clamped_pos.y = clamp(clamped_pos.y, bound_top, bound_bottom)
	else:
		clamped_pos.y = active_area.position.y + (active_area.size.y / 2)
	return clamped_pos


func _on_viewport_size_changed() -> void:
	var window_size: Vector2 = get_viewport_rect().size
	width_delta = window_size.x / 2
	height_delta = window_size.y / 2


func _on_boundary_transitioned() -> void:
	var detector: Area2D = target.get_node("CameraBoundaryDetector")
	if detector:
		var candidates: Array[Area2D] = detector.get_overlapping_areas()
		var highest_priority: CameraBoundary = null
		for area in candidates:
			if area is CameraBoundary:
				if not highest_priority:
					highest_priority = area
				elif area.bound_priority > highest_priority.bound_priority:
					highest_priority = area
		if highest_priority:
			active_boundary = highest_priority
		else:
			active_boundary = null
