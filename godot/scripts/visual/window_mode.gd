extends Node
## Global display shortcut, including paused gameplay and focused menus.
var _window: Window
var _previous_mode := Window.MODE_WINDOWED
var _previous_size := Vector2i.ZERO
var _previous_position := Vector2i.ZERO


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_window = get_tree().root


func _input(event: InputEvent) -> void:
	var key := event as InputEventKey
	if key == null or not key.pressed or key.echo or key.keycode != KEY_F11:
		return
	toggle_fullscreen()
	get_viewport().set_input_as_handled()


func toggle_fullscreen() -> void:
	if _window.mode in [Window.MODE_FULLSCREEN, Window.MODE_EXCLUSIVE_FULLSCREEN]:
		_window.mode = _previous_mode
		if _previous_mode == Window.MODE_WINDOWED and _previous_size != Vector2i.ZERO:
			_window.size = _previous_size
			_window.position = _previous_position
	else:
		_previous_mode = _window.mode
		_previous_size = _window.size
		_previous_position = _window.position
		_window.mode = Window.MODE_FULLSCREEN
