extends Node
## Plays a blip as Dialogic reveals letters. Autoloaded as "TypeSound".

const SKIP_CHARS := " \n\t"   # no blip on whitespace
const PLAY_EVERY := 2         # blip every Nth eligible character

## Key = DialogicCharacter display_name, lowercased.
const VOICES := {
	"charles": {"sound": "type_charles", "pitch": 0.9},
	"smoke":   {"sound": "type_smoke",   "pitch": 0.6},
}
const DEFAULT_VOICE := {"sound": "type_default", "pitch": 1.0}

var _counter := 0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	# The dialogue layout is instantiated at runtime, so the text node does
	# not exist yet. Re-check on every text event; is_connected() makes the
	# repeat calls harmless.
	Dialogic.Text.about_to_show_text.connect(_hook_text_nodes)

func _hook_text_nodes(_info: Dictionary) -> void:
	print("DEBUG: _info ->")
	print(_info)
	print("DEBUG: get_nodes_in_group(dialogic_dialog_text) ")
	print(get_tree().get_nodes_in_group("dialogic_dialog_text"))
	for node in get_tree().get_nodes_in_group("dialogic_dialog_text"):
		if not node.continued_revealing_text.is_connected(_on_char_revealed):
			node.continued_revealing_text.connect(_on_char_revealed)
		if not node.started_revealing_text.is_connected(_on_text_started):
			node.started_revealing_text.connect(_on_text_started)

func _on_text_started() -> void:
	_counter = 0

func _on_char_revealed(new_character: String) -> void:
	print(new_character)
	if new_character.is_empty() or new_character in SKIP_CHARS:
		return
	_counter += 1
	if _counter % PLAY_EVERY != 0:
		return
	var voice: Dictionary = _voice_for_speaker()
	Audio.play(voice.sound, -8.0, voice.pitch * randf_range(0.97, 1.03))

func _voice_for_speaker() -> Dictionary:
	var speaker: DialogicCharacter = Dialogic.Text.get_current_speaker()
	if speaker == null:
		return DEFAULT_VOICE
	return VOICES.get(speaker.display_name.to_lower(), DEFAULT_VOICE)
