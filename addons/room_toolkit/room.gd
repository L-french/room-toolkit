class_name Room
extends Node2D

signal room_activated()

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
