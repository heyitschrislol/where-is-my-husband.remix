extends InteractItem

@onready var door_collision = $collision_shape_2d
@onready var door_sprite = $Sprite2D
#@onready var closed_sprite = $closed_sprite
#@onready var open_sprite = $open_sprite
@export var state = "closed"
@export var facing_direction = ""
@export var room_name = ""
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
	if room_name == "CLOSET":
		if Gamedata.PMAIL_HACKED:
			start_dialog("closet_ready")
		else:
			start_dialog(dialog_name)
	else:
		if state == "closed":
			Gamedata.reveal_room(room_name)
			#if Gamedata.
			if open_visible:
				visible = true
			else:
				visible = false
			door_collision.set_deferred("disabled", true)
			state = "open"
			interaction_area.action_name = "close door"
		elif state == "open":
			if closed_visible:
				visible = true
			else:
				visible = false
			door_collision.set_deferred("disabled", false)
			state = "closed"
			interaction_area.action_name = "open door"

func _check_door():
	#sprite.frame = 1 if sprite.frame == 0 else 0
	start_dialog(dialog_name)



func start_dialog(timeline):
	dialog_signal.emit(timeline,"","")

func _on_dialog_request(timeline_name: String,_location: String):
	Dialogic.timeline_ended.connect(_on_timeline_ended)
	Dialogic.start(timeline_name)
	#dialog.offset.x = _get_player().position.x
	#dialog.offset.y = _get_player().position.y
	Gamedata._is_dialog_active = true

func _on_timeline_ended():
	Dialogic.timeline_ended.disconnect(_on_timeline_ended)
	# do something else here
