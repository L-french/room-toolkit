class_name Room
extends Node2D
## The base node representing a single Room. Provides context for [LoadingDoor]s. By default,
## the [Room] expects its Doors to be direct children of itself. This can be changed with the 
## [member allow_recursion] property.

signal room_activated()

## If true, recursively search all decendants to find [LoadingDoor]s. Otherwise, only direct
## children will be detected.
@export var allow_recursion := false

var auto_activate: bool = true


func _ready() -> void:
	var doors := find_children("*", "LoadingDoor", allow_recursion)
	for door in doors:
		room_activated.connect(door._on_room_activated)
		door.room_exited.connect(_on_room_exited)

	if auto_activate:
		room_activated.emit()


func set_active() -> void:
	room_activated.emit()


func _on_room_exited() -> void:
	queue_free()
