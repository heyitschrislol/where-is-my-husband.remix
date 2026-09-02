extends Node2D

#################################
#	TODO
#	-	add debug overlay showing Gamedata variables
#	-	add fade to scene transitions
#	-	add display for when achieving special tasks
#	-	add shadows to rooms with the door closed
#	-	look into object shadows
#	-	add music
#	-	fix dialogic letter sounds
#	-	add sounds for footsteps
#################################

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
@onready var obj_livingroom_cellphone = $objects/livingroom_objects/coffeetable/cellphone
@onready var obj_livingroom_whitecouch = $objects/livingroom_objects/whitecouch
@onready var obj_livingroom_greencouch = $objects/livingroom_objects/greencouch
@onready var obj_kitchen_fridge = $objects/kitchen_objects/fridge
#@onready var obj_kitchen_pantry = $objects/guestroom_objects/computer
#@onready var obj_kitchen_crumpled_note = $objects/guestroom_objects/computer


func _ready():
	#####	 DEBUG TEST STUFF REMOVE LATER	#####
	Dialogic.VAR.CHARLES.set('FIRST_SPANISH_CONVO',true)
	#Dialogic.VAR.set('FOUND_SPANISH_BOOK',true)
	#Dialogic.VAR.set('PLAYED_DUOLINGO',true)
	#Dialogic.VAR.CHARLES.set('FIRST_INTERACTION',false)
	#Gamedata.CAT_SPANISH_LEARNED = true
	#Gamedata.CHARLES_FIRST_INTERACTION = false
	#Gamedata.CHARLES_DIALOG_IN_SPANISH = false
#
	#Gamedata.LET_CHARLES_OUTSIDE = true
	#Gamedata.SMOKE_INSIDE = true
	#####								#####


	if Gamedata.GAME_START:
		Gamedata.store_character_positions(Vector2(452.0,444.0),Vector2(-869.0,-289.0),Vector2(1105.0,-705.0))
		#Gamedata.position_store["player"] = Vector2(-167.0,-77.0)
		#Gamedata.position_store["charles"] = Vector2(-869.0,-289.0)
		#Gamedata.position_store["smoke"] = Vector2(1105.0,-705.0)
		Gamedata.goto_cutscene("open_cutscene", true)
	elif Gamedata.LET_CHARLES_OUTSIDE and Gamedata.SMOKE_INSIDE and !Gamedata.SMOKE_FED:
		Gamedata.store_character_positions(Vector2(589,-157),Vector2(1085,-637),Vector2(582,-16))
		Gamedata.load_stored_positions()
		Gamedata.CHARLES_FOLLOW = false
		Gamedata.SMOKE_FOLLOW = true

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
		Gamedata.goto_cutscene("duolingo", false)
	elif argument == "start_cutsceneA":
		print("setting special positions")
		#Gamedata.store_character_positions(Vector2(589,-157),Vector2(1085,-637),Vector2(582,-16))
		#Gamedata.position_store["player"] = Vector2(735,-162)
		#Gamedata.position_store["smoke"] = Vector2(544,-448)
		#Gamedata.position_store["charles"] = Vector2(1045,-647)
		Gamedata.LET_CHARLES_OUTSIDE = true
		Gamedata.SMOKE_INSIDE = true
		Gamedata.goto_cutscene("cutscene_kitchenA", true)
	elif argument == "back_door":
		door_back.SPECIAL_DOOR = false
	elif argument == "holding_cat_food":
		Gamedata.HOLDING_CAT_FOOD = true
	elif argument == "feed_smoke":
		Gamedata.HOLDING_CAT_FOOD = false
	elif argument == "smoke_fed":
		Gamedata.SMOKE_FED = true
		Gamedata.SMOKE_FOLLOW = false
		smoke.idlelocation = Vector2(780,21)



func _on_timeline_ended():
	Dialogic.timeline_ended.disconnect(_on_timeline_ended)
	# do something else here
