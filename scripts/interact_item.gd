class_name InteractItem extends StaticBody2D

@onready var sprite = $Sprite2D
@onready var interaction_area: InteractionArea = $interaction_area
@export var action_name = ""
@export var dialog_name = ""
#@onready var spritetexture = sprite.texture
@onready var sprite_size: Vector2

signal dialog_signal(argument: String,location: String,default_text: String)

func _ready():
	dialog_signal.connect(_on_dialog_request)
	if action_name != "":
		set_interaction_text(action_name)
	interaction_area.interact = Callable(self, "_special_interaction")

func _on_dialog_request(argument: String = "",_location: String = ""):
	Dialogic.timeline_ended.connect(_on_timeline_ended)
	Dialogic.start(dialog_name)
	Gamedata._is_dialog_active = true

func _get_player():
	return get_tree().get_first_node_in_group("player")

func _on_timeline_ended():
	Dialogic.timeline_ended.disconnect(_on_timeline_ended)
	# do something else here

func _special_interaction():
	start_dialog(dialog_name)

func start_dialog(timeline):
	dialog_signal.emit(timeline,"")

func set_interaction_text(action_name: String):
	interaction_area.action_name = action_name
