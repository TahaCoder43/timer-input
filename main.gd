extends Control

var signal_resized_window := false
var resize_tween: Tween

func _ready() -> void:
	var root = get_tree().get_root()
	root.name = "timer-input"
	root.title = "timer-input"
	var main_lineedit: LineEdit = $"PanelContainer/MarginContainer/HBoxContainer/LineEdit"
	main_lineedit.grab_focus()
	# TODO time to compile this program to a binary, try to compile it in muslc somehow
