extends Sprite2D

@onready var interaction_area: InteractionArea = $interaction_area

@export var closeup_image: Texture2D
@export var prompt_verb: String = "read"     ## shown as "[SPACEBAR] to read"
@export var flag_name: String = ""           ## optional Gamedata bool to set true
@export var dialogic_var: String = ""        ## optional Dialogic variable to set true
@export var timeline_after: String = ""      ## optional timeline once dismissed


func _ready() -> void:
	interaction_area.action_name = prompt_verb
	interaction_area.interact = Callable(self, "_on_view")


func _on_view() -> void:
	await Overlay.show_image(closeup_image)

	if flag_name != "":
		Gamedata.set(flag_name, true)
	if dialogic_var != "":
		Dialogic.VAR.set_variable(dialogic_var, true)

	if timeline_after != "":
		Gamedata._is_dialog_active = true
		Dialogic.start(timeline_after)
