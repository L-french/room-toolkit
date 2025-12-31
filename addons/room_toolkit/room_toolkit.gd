@tool
extends EditorPlugin


func _enable_plugin() -> void:
	# Add autoloads here.
	pass


func _disable_plugin() -> void:
	# Remove autoloads here.
	pass


func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	add_custom_type("Room", "Node2D", preload("room.gd"), preload("Room.svg"))
	add_custom_type("BoundedCamera", "Camera2D", preload("bounded_camera.gd"), preload("BoundedCamera.svg"))
	add_custom_type("CameraBoundary", "Area2D", preload("camera_boundary.gd"), preload("CameraBoundary.svg"))
	add_custom_type("LoadingDoor", "Area2D", preload("loading_door.gd"), preload("LoadingDoor.svg"))


func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	remove_custom_type("Room")
	remove_custom_type("BoundedCamera")
	remove_custom_type("CameraBoundary")
	remove_custom_type("LoadingDoor")
