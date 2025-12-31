# Room Toolkit

Custom classes implementing flexible camera boundaries, background loading of new scenes, and screen transitions for 2D platformers. This plugin was made with room-based metroidvanias in mind, but ought to work with any plaformer with a similar structure.

## Classes

- `CameraBoundary` and `BoundedCamera`: Adding scrolling limits to a camera is as simple as outlining the game area with a `CameraBoundary` and replacing the stock `Camera2D`. The `BoundedCamera` also has some utilities to override player-following behavior for cutscenes (WIP).

- `LoadingDoor`: Load adjacent rooms on a separate thread and instantiate them once the player enters a door--no loading screens required.

- `Room`: Top-level node for managing `LoadingDoor`s

## External Assets

- The demo uses assets from TheoTheTorch's [Movement 2](https://github.com/TheoTheTorch/MOVEMENT-2) under an MIT license.
- The class icons and Godot logo are reused from the [Godot Engine](https://godotengine.org/), also under an MIT license.