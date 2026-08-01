@tool
extends EditorPlugin

var inspector: EditorInspectorPlugin

func _enter_tree() -> void:
	inspector = load("uid://c0g0u5c74wftx").new()
	add_inspector_plugin(inspector)

func _exit_tree() -> void:
	remove_inspector_plugin(inspector)
