extends Node2D

#################################
#	--------------------|
#		**	TODO	**
#	--------------------|
#	(MUST-HAVE)	-	!!		FINISH THE GAME STORY BEATS UP TO THE GAME ENDING	!!
#									(smoke drops clue, clue leads to PC, PC opens Firefox to fake email server site, read email
#									leads to the mysteriously locked bedroom closet, game ends after closet gives a pop-up
#									window with game's final message
# (MUST-HAVE)	-	add visibility-blocking overlay to only reveal areas that have already been visited
#	(MUST-HAVE)	-	 implement all remaining tasks required as part of story progression
# (MUST-HAVE)	-	add fade to scene transitions
#	(MUST-HAVE)	-	add display for when achieving special tasks
#	(MUST-HAVE)	-	add sound-effects
#	(MUST-HAVE)	-	fix dialogic letter sounds
#	(MUST-HAVE)	-	add game pause functionality
#	(MUST-HAVE)	-	create title/press start screen
#								-	look into object shadows
# 							- add music
#								-	add debug overlay showing Gamedata variables
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
@onready var obj_kitchen_torn_note = $"objects/kitchen_objects/torn_note"
@onready var obj_diningroom_crumpled_note = $"objects/diningroom_objects/crumpled_note"
#@onready var obj_kitchen_pantry = $objects/guestroom_objects/computer
#@onready var obj_kitchen_crumpled_note = $objects/guestroom_objects/computer


func _ready():
	#####	 DEBUG TEST STUFF REMOVE LATER	#####
	Dialogic.VAR.CHARLES.set('FIRST_SPANISH_CONVO',true)
	Dialogic.VAR.set('FOUND_SPANISH_BOOK',true)
	Dialogic.VAR.set('PLAYED_DUOLINGO',true)
	Dialogic.VAR.CHARLES.set('FIRST_INTERACTION',false)
	Gamedata.CAT_SPANISH_LEARNED = true
	Gamedata.CHARLES_FIRST_INTERACTION = false
	Gamedata.CHARLES_DIALOG_IN_SPANISH = false
#
	#Gamedata.LET_CHARLES_OUTSIDE = true
	#Gamedata.SMOKE_INSIDE = true
	#####								#####

	obj_kitchen_torn_note.visible = false
	obj_kitchen_torn_note.process_mode = Node.PROCESS_MODE_DISABLED
	obj_diningroom_crumpled_note.visible = false
	obj_diningroom_crumpled_note.process_mode = Node.PROCESS_MODE_DISABLED
	if Gamedata.GAME_START:
		Gamedata.store_character_positions(Vector2(-70.0,-96.0),Vector2(-594.0,-359.0),Vector2(90.0,-419.0))
		#Gamedata.position_store["player"] = Vector2(-167.0,-77.0)
		#Gamedata.position_store["charles"] = Vector2(-869.0,-289.0)
		#Gamedata.position_store["smoke"] = Vector2(1105.0,-705.0)
		Gamedata.goto_cutscene("open_cutscene", true)
	elif Gamedata.LET_CHARLES_OUTSIDE and Gamedata.SMOKE_INSIDE:
		if not Gamedata.SMOKE_FED and not Gamedata.HOLDING_CAT_FOOD:
			Gamedata.store_character_positions(Vector2(-89.0,-228.0),Vector2(98.0,-418.0),Vector2(-5.0,-350.0))
			Gamedata.load_stored_positions()
			Gamedata.CHARLES_FOLLOW = false
			Gamedata.SMOKE_FOLLOW = false
		#elif not Gamedata.SMOKE_FED and Gamedata.HOLDING_CAT_FOOD:

		elif Gamedata.SMOKE_FED:
			Gamedata.SMOKE_FOLLOW = false
			#Gamedata.SMOKE_DESTINATION_SET = true


	Dialogic.timeline_started.connect(Gamedata._on_dialogue_started)
	Dialogic.timeline_ended.connect(Gamedata._on_dialogue_ended)
	Dialogic.signal_event.connect(_on_dialogic_signal)

	if Gamedata.PENDING_SMOKE_ROUTE != "":
		_start_pending_smoke_route.call_deferred()
#func _process(_delta):

	#Dialogic.signal_event.connect(_on_dialogic_signal)



func _on_dialog_request(timeline_name: String,_location: String):
	Dialogic.timeline_ended.connect(_on_timeline_ended)
	Dialogic.start(timeline_name)
	Gamedata._is_dialog_active = true

	#var dialog = Dialogic.start(timeline_name)			DELETE?
	#player.add_child(dialog)
	#dialog.offset.x = player.position.x			DELETE
	#dialog.offset.y = player.position.y			DELETTE

	#get_viewport().set_input_as_handled()

func _on_dialogic_signal(argument:String):
	#if argument == "spanish_book_taken":
	if argument == "play_duolingo":
		_on_play_duolingo()


	elif argument == "start_cutsceneA":
		print("setting special positions")
		_on_let_charles_outside()

	elif argument == "holding_cat_food":
		_on_holding_cat_food()
	elif argument == "food_placed":
		_on_food_placed()
	elif argument == "smoke_fed":
		_on_smoke_fed()

	#elif argument == "crumpled_note_taken":
		#_on_crumpled_note_taken()
	elif argument == "crumpled_note_opened":
		_on_crumpled_note_opened()
	elif argument == "crumpled_note_dropped":
		_on_crumpled_note_dropped()
	#elif argument=="read_torn_note":
		#_on_torn_note_interaction()

func route(route_node: Node2D) -> Array[Vector2]:
	var points: Array[Vector2] = []
	for child in route_node.get_children():
		if child is Marker2D:
			points.append(child.global_position)
	return points

#func _on_story_event():
	#pass

func _on_first_charles_interaction():
	pass

func _on_spanish_book_found():
	pass

func _on_play_duolingo():
	Gamedata.goto_cutscene("duolingo", false)

func _on_learned_cat_spanish():
	pass

func _on_charles_dialog_in_spanish():
	pass

func _on_let_charles_outside():
	Gamedata.LET_CHARLES_OUTSIDE = true
	Gamedata.SMOKE_INSIDE = true
	Gamedata.PENDING_SMOKE_ROUTE = "BackDoorToWaitSpot"
	Gamedata.goto_cutscene("cutscene_kitchenA", true)
	door_back.SPECIAL_DOOR = false
	var points = route($routes/BackDoorToWaitSpot)
	#points.append($Markers/FoodBowl.global_position)
	var smoke = Gamedata._get_cats().filter(func(n): return n.name == "smoke")[0]
	#var cats = Gamedata._get_cats()
	smoke.move_along(points)
	await smoke.destination_reached

func _on_holding_cat_food():
	Gamedata.HOLDING_CAT_FOOD = true
	Gamedata.give_item("cat_food")

func _on_food_placed():
	Gamedata.FOOD_PLACED = true
	Gamedata.HOLDING_CAT_FOOD = false
	#Gamedata.move_npc_to("smoke", $markers/FoodDish.global_position)
	var points = route($routes/WaitSpotToFoodDish)
	var player_points = route($routes/PlayerStepAside)
	points.append($markers/FoodDish.global_position)
	var smoke = Gamedata._get_cats().filter(func(n): return n.name == "smoke")[0]
	player.move_along(player_points)
	await player.destination_reached
	smoke.move_along(points)
	await smoke.destination_reached
	#smoke.animated_sprite.play("chow_down")
	Gamedata.SMOKE_CHOW_DOWN = true

func _on_smoke_fed():
	Gamedata.SMOKE_FED = true
	Gamedata.SMOKE_FOLLOW = false
	Gamedata.CRUMPLED_NOTE_DROPPED = true
	obj_diningroom_crumpled_note.visible = true
	obj_diningroom_crumpled_note.process_mode = Node.PROCESS_MODE_INHERIT

#func _on_crumpled_note_taken():
	##Gamedata.give_item("crumpled_note")
	#obj_diningroom_crumpled_note.visible = false
	#obj_diningroom_crumpled_note.process_mode = Node.PROCESS_MODE_DISABLED


	#pass

func _on_crumpled_note_opened():
	var points = route($routes/PlayerMoveToIsland)
	player.move_along(points)
	await player.destination_reached
	Gamedata.give_item("torn_note")
	obj_kitchen_torn_note.visible = true
	obj_kitchen_torn_note.process_mode = Node.PROCESS_MODE_INHERIT
	Gamedata.CRUMPLED_NOTE_OPENED = true


func _on_crumpled_note_dropped():
	obj_diningroom_crumpled_note.visible = true
	obj_diningroom_crumpled_note.process_mode = Node.PROCESS_MODE_INHERIT
	Gamedata.CRUMPLED_NOTE_DROPPED = true
#
#
#func _on_torn_note_interaction():
	##Gamedata.show_item("torn_note")
	#pass

func _on_access_computer():
	pass

func _on_pmail_hacked():
	pass



func _on_timeline_ended():
	Dialogic.timeline_ended.disconnect(_on_timeline_ended)
	# do something else here

func _start_pending_smoke_route() -> void:
	var route_name := Gamedata.PENDING_SMOKE_ROUTE
	Gamedata.PENDING_SMOKE_ROUTE = ""   # clear first — this must never fire twice
	var route_node = $routes.get_node_or_null(route_name)
	if route_node == null:
		push_warning("No route node named '%s' under House/Routes" % route_name)
		return
	smoke.move_along(route(route_node))
	await smoke.destination_reached
	#if Gamedata.SMOKE_SPECIAL_ANIM:
		#smoke.animated_sprite.play("chow_down")
	print("smoke finished her route")
