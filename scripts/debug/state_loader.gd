extends Node


const STATE_DATA : Dictionary = {
	"begin-state"	:	{
	"path"								:		"res://debug-states/beginning-state.json",
	"start_positions"		:			{	"player":Vector2(-70.0,-96.0),"charles":Vector2(-594.0,-359.0),"smoke":Vector2(90.0,-419.0)	}
	},
	"smoke-appears-state"	:	{
	"path"								:		"res://debug-states/smoke-appears-state.json",
	"start_positions"		:			{	"player":Vector2(-89.0,-228.0),"charles":Vector2(98.0,-418.0),"smoke":Vector2(-5.0,-350.0)	}
	},
	"mystery-note-state"		:		{
	"path"								:		"res://debug-states/mystery-note-state.json",
	"start_positions"		:			{	"player":Vector2(-5.0,-353.0),"charles":Vector2(45.0,-340.0),"smoke":Vector2(-21.0,-233.0)	}
	}
}

const DEBUG_STATE = STATE_DATA["smoke-appears-state"]
const DEBUG_STATE_TO_LOAD: String = DEBUG_STATE["path"]


func apply_debug_progression(file_path: String) -> void:
	if not FileAccess.file_exists(file_path):
		print("[Debug] No state file found at: ", file_path, " -> Starting completely clean.")
		return

	var file: FileAccess = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		print("[Debug] Error opening state file: ", FileAccess.get_open_error())
		return

	var json_text: String = file.get_as_text()
	file.close()

	var parsed_data = JSON.parse_string(json_text)

	if parsed_data is Dictionary:
		print("[Debug] Successfully loaded progression from: ", file_path)

		#####	--------	apply GameData flags 	--------	#####
		for flag in parsed_data["flags"]:
			set(flag, parsed_data[flag])
			print(" -> Set Gamedata flag '", flag, "' to: ", parsed_data[flag])


		#####	--------	apply Dialogic flags 	--------	#####
		for dflag in parsed_data["dialogic_flags"]:
			var value = parsed_data[dflag]
			Dialogic.VAR.set_variable(dflag, value)
			print(" -> Set Dialogic VAR '", dflag, "' to: ", value)
	else:
		print("[Debug] Failed to parse JSON. Double check syntax!")
