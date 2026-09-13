extends Sprite2D

@onready var interaction_area: InteractionArea = $interaction_area

@export var timeline_before: String = "guestroom_computer"
@export var timeline_after: String = "guestroom_computer_pmail"


func _ready() -> void:
	interaction_area.action_name = "use"
	interaction_area.interact = Callable(self, "_on_use")


func _on_use() -> void:
	var timeline := timeline_after if Gamedata.TORN_NOTE_READ else timeline_before
	Gamedata._is_dialog_active = true
	Dialogic.start(timeline)
