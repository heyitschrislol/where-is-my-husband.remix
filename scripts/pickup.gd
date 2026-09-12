extends Sprite2D

@onready var interaction_area: InteractionArea = $interaction_area

@export var item_id: String = ""            ## key in Gamedata.item_db
@export var flag_name: String = ""          ## optional Gamedata bool to set true
@export var dialogic_var: String = ""       ## optional Dialogic variable to set true
@export var disappear_on_pickup: bool = true

var _taken := false


func _ready() -> void:
	interaction_area.action_name = "take"
	interaction_area.interact = Callable(self, "_on_pickup")


func _on_pickup() -> void:
	if _taken:
		return
	_taken = true

	if flag_name != "":
		Gamedata.set(flag_name, true)
	if dialogic_var != "":
		Dialogic.VAR.set_variable(dialogic_var, true)

	await Gamedata.give_item(item_id)

	if disappear_on_pickup:
		queue_free()
