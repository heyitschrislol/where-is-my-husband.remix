extends Node

var gamedata_flags: Dictionary = {}


func set_flag(flag_name: StringName, value: bool = true) -> void:
	gamedata_flags[flag_name] = value

func get_flag(flag_name: StringName) -> bool:
	return gamedata_flags.get(flag_name, false)

func toggle_flag(flag_name: StringName) -> void:
	gamedata_flags[flag_name] = not get_flag(flag_name)
