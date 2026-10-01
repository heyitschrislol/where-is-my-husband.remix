extends InteractItem

@onready var door_collision = $collision_shape_2d
@onready var door_sprite = $Sprite2D
#@onready var closed_sprite = $closed_sprite
#@onready var open_sprite = $open_sprite
@export var state = "closed"
@export var facing_direction = ""
@export var room_name = ""
@export var passable : bool = true
#@export var dialog_condition

var northsouth_texture = load("res://assets/art/PNG/objects/white_wooden_bedroom_door_32X48.png")
var eastwest_texture = load("res://assets/art/PNG/objects/white_wooden_bedroom_door_open_32X48.png")
var open_visible : bool
var closed_visible : bool


func _ready():
	if facing_direction == "northsouth":
		open_visible = false
		closed_visible = true
		door_sprite.texture = northsouth_texture
		visible = true
	elif facing_direction == "eastwest":
		open_visible = true
		closed_visible = false
		visible = false
		door_sprite.texture = eastwest_texture
	action_name = "open door"
	interaction_area.action_name = action_name
	dialog_signal.connect(_on_dialog_request)
	interaction_area.interact = Callable(self, "_open_door")


func _open_door():
	if passable:
		_operate_door()
	else:
		if room_name == "BACKYARD":
				_door_dialog("kitchen_door")
		elif room_name == "CLOSET":
			_door_dialog("closet_gaslight")
		#elif room_name == "TESTDOOR":
			#if not Gamedata.TEST_DOOR:
				#_door_dialog("test_back_door")
			#else:
				#passable = true
				#_operate_door()


## Public API for story choreography (called from house.gd).
func unlock_and_open() -> void:
	passable = true
	if state == "closed":
		_operate_door()

func _operate_door():
	if state == "closed":
		Gamedata.reveal_room(room_name)
		Audio.play("door_open")
		#if Gamedata.
		if open_visible:
			visible = true
		else:
			visible = false
		door_collision.set_deferred("disabled", true)
		state = "open"
		interaction_area.action_name = "close door"
	elif state == "open":
		Audio.play("door_close")
		if closed_visible:
			visible = true
		else:
			visible = false
		door_collision.set_deferred("disabled", false)
		state = "closed"
		interaction_area.action_name = "open door"

func _door_dialog(_dialog_name : String = ""):
	#sprite.frame = 1 if sprite.frame == 0 else 0
	if _dialog_name != "":
		start_dialog(_dialog_name)
	else:
		start_dialog(dialog_name)

func start_dialog(timeline):
	dialog_signal.emit(timeline,"")

func _on_dialog_request(argument: String = "",location: String = ""):
	if argument == "":
		Dialogic.timeline_ended.connect(_on_timeline_ended)
		Dialogic.start(dialog_name)
		Gamedata._is_dialog_active = true
		return

	Dialogic.timeline_ended.connect(_on_timeline_ended)
	Dialogic.start(argument)
	Gamedata._is_dialog_active = true



func _on_timeline_ended():
	Dialogic.timeline_ended.disconnect(_on_timeline_ended)
	# do something else here
