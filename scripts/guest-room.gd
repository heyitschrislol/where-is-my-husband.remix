extends Node2D

@onready var player = $scene_parts/characters/player
@onready var anim_player = $scene_parts/animation_player

##---INTERACTABLES---##
@onready var computer = $scene_parts/objects/computer
@onready var bookshelf = $scene_parts/objects/books
@onready var exit_hallway = $exit_hallway
@onready var door = $scene_parts/objects/door

func _ready():
	#exit_hallway.dialog_signal.connect(_on_dialog_request)
	exit_hallway.dest_scene = "hallway"
	computer.dialog_signal.connect(_on_dialog_request)
	bookshelf.dialog_signal.connect(_on_dialog_request)

func _process(_delta):
	Dialogic.timeline_started.connect(Gamedata._on_dialogue_started)
	Dialogic.timeline_ended.connect(Gamedata._on_dialogue_ended)
	#Dialogic.signal_event.connect(_on_dialogic_signal)



func _on_dialog_request(timeline_name: String,location: String,default_text: String):
	Dialogic.timeline_ended.connect(_on_timeline_ended)
	Dialogic.start(timeline_name)
	Gamedata._is_dialog_active = true

	#get_viewport().set_input_as_handled()

func _on_dialogic_signal(argument:String):
	if argument == "start_animation":
		anim_player.play("run_away")


func _on_timeline_ended():
	Dialogic.timeline_ended.disconnect(_on_timeline_ended)
	# do something else here
