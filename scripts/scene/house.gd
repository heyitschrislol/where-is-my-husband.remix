extends Node2D

# CHARACTERS
@onready var charles =$characters/charles
@onready var player = $characters/player
@onready var smoke = $characters/smoke

# DOORS
@onready var door_front = $objects/doors/front
@onready var door_back = $objects/doors/back
@onready var door_bathroom = $objects/doors/bathroom
@onready var door_bedroom = $objects/doors/bedroom
@onready var door_bedroom_closet = $objects/doors/bedroom_closet
@onready var door_bedroom_bathroom = $objects/doors/bedroom_bathroom
@onready var door_guestroom = $objects/doors/guestroom

# INTERACTABLE OBJECTS
@onready var obj_guestroom_bookshelf = $objects/guestroom_objects/bookshelf
@onready var obj_guestroom_computer = $objects/guestroom_objects/computer


func _ready():
	#####	 DEBUG TEST STUFF REMOVE LATER	#####
	#Dialogic.VAR.set('FIRST_SPANISH_CONVO',true)
	#Dialogic.VAR.set('FOUND_SPANISH_BOOK',true)
	#Dialogic.VAR.set('PLAYED_DUOLINGO',true)
	#Dialogic.VAR.set('FIRST_CHARLES_INTERACTION',false)
	#Gamedata.CAT_SPANISH_LEARNED = true
	#Gamedata.CHARLES_FIRST_INTERACTION = false
	#Gamedata.CHARLES_DIALOG_IN_SPANISH = false
	#####								#####


	if Gamedata.GAME_START:
		Gamedata.GAME_START = false
		Gamedata.goto_cutscene("open_cutscene")

	obj_guestroom_bookshelf.dialog_name = "guestroom_bookshelf"
	obj_guestroom_computer.dialog_name = "guestroom_computer"
	door_back.dialog_name = "kitchen_door"
	obj_guestroom_bookshelf.dialog_signal.connect(_on_dialog_request)
	obj_guestroom_computer.dialog_signal.connect(_on_dialog_request)
	charles.dialog_signal.connect(_on_dialog_request)
	smoke.dialog_signal.connect(_on_dialog_request)
	door_back.dialog_signal.connect(_on_dialog_request)
	Dialogic.timeline_started.connect(Gamedata._on_dialogue_started)
	Dialogic.timeline_ended.connect(Gamedata._on_dialogue_ended)
	Dialogic.signal_event.connect(_on_dialogic_signal)

#func _process(_delta):

	#Dialogic.signal_event.connect(_on_dialogic_signal)



func _on_dialog_request(timeline_name: String,_location: String):
	Dialogic.timeline_ended.connect(_on_timeline_ended)
	var dialog = Dialogic.start(timeline_name)
	#player.add_child(dialog)
	dialog.offset.x = player.position.x
	dialog.offset.y = player.position.y
	Gamedata._is_dialog_active = true

	#get_viewport().set_input_as_handled()

func _on_dialogic_signal(argument:String):
	if argument == "play_duolingo":
		Gamedata.goto_cutscene("duolingo")


func _on_timeline_ended():
	Dialogic.timeline_ended.disconnect(_on_timeline_ended)
	# do something else here
