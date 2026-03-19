extends StaticBody2D

signal dialog_signal(timeline_name: String,location: String,default_text: String)

@export var SPECIAL_DOOR: bool
@onready var sprite = $Sprite2D
@onready var door_collision = $collision_shape_2d
@onready var interaction_area: InteractionArea = $interaction_area
@export var dialog_name = ""
@onready var state = "closed"


func _ready():
	interaction_area.action_name = "interact"
	dialog_signal.connect(_on_dialog_request)
	if SPECIAL_DOOR:
		interaction_area.interact = Callable(self, "_special_interaction")
	else:
		interaction_area.interact = Callable(self, "_open_door")


func _open_door():
	if state == "closed":
		visible = false
		door_collision.set_deferred("disabled", true)
		#door_collision.position.x = position_array["opened"][0]
		#door_collision.position.y = position_array["opened"][1]
		#sprite.position.x = position_array["opened"][0]
		#sprite.position.y = position_array["opened"][1]
		state = "open"
	elif state == "open":
		visible = true
		door_collision.set_deferred("disabled", false)
		#door_collision.position.x = position_array["default"][0]
		#door_collision.position.y = position_array["default"][1]
		#sprite.position.x = position_array["default"][0]
		#sprite.position.y = position_array["default"][1]
		state = "closed"

func _on_dialog_request(timeline_name: String,_location: String):
	Dialogic.timeline_ended.connect(_on_timeline_ended)
	var dialog = Dialogic.start(timeline_name)
	dialog.offset.x = _get_player().position.x
	dialog.offset.y = _get_player().position.y
	Gamedata._is_dialog_active = true

func _on_timeline_ended():
	Dialogic.timeline_ended.disconnect(_on_timeline_ended)
	# do something else here

func _get_player():
	return get_tree().get_first_node_in_group("player")

func _special_interaction():
	#sprite.frame = 1 if sprite.frame == 0 else 0
	start_dialog(dialog_name)

func start_dialog(timeline):
	dialog_signal.emit(timeline,"")
