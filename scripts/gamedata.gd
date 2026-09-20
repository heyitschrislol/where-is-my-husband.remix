extends Node

#var player = get_tree().get_first_node_in_group("player")
var current_scene = null
var previous_scene = null
var current_location = null
var player_previous_location = null
var _is_dialog_active: bool = false   			## owned by Dialogic timelines ONLY
var _is_popup_active: bool = false    				## owned by ItemPopup ONLY
##---PRE-SCENE POSITIONS---##
var position_store : Dictionary[String,Vector2] = {}

var CHARLES_FOLLOW = false
var SMOKE_FOLLOW = false
var SMOKE_CHOW_DOWN = false

#var GAME_START = true
var GAME_START = false

## KITCHEN
## -----------
var PENDING_SMOKE_ROUTE: String = ""
var LET_CHARLES_OUTSIDE = false
var SMOKE_INSIDE = false
var HOLDING_CAT_FOOD = false
var FOOD_PLACED = false
var SMOKE_FED = false

var CRUMPLED_NOTE_DROPPED = false
var CRUMPLED_NOTE_TAKEN = false
var CRUMPLED_NOTE_OPENED = false
var TORN_NOTE_READ = false


## GUESTROOM
## -----------
var PMAIL_HACKED = false
var FOUND_SPANISH_BOOK = false
var CAT_SPANISH_LEARNED = false
## BEDROOM
## -----------
var CHARLES_FIRST_INTERACTION = true
var CHARLES_DIALOG_IN_SPANISH = false

## ROOM SHADOWS
## -----------
var HALLBATH_REVEALED = false
var MASTERBATH_REVEALED = false
var BEDROOM_REVEALED = false
var GUESTROOM_REVEALED = false
var BACKYARD_REVEALED = false
var CLOSET_REVEALED = false

#func get_door_room(room_name: String) -> bool:
	#var rooms = {
		#"HALLBATH"			:	HALLBATH_REVEALED,
		#"MASTERBATH"		:	MASTERBATH_REVEALED,
		#"BEDROOM"				:	BEDROOM_REVEALED,
		#"GUESTROOM"		:	GUESTROOM_REVEALED,
		#"CLOSET"				:	CLOSET_REVEALED,
		#"BACKYARD"			:	BACKYARD_REVEALED
	#}
	#return rooms[room_name]


##---SIGNALS---##
signal room_revealed(room_name: String)

func reveal_room(room_name: String) -> void:
	var flag_name = room_name + "_REVEALED"
	if not get(flag_name):
		set(flag_name, true)
		room_revealed.emit(room_name)


##---SCENE LIST---##
var scene_paths = {
	"house"					:	"res://scenes/house.tscn",
	"duolingo"				:	"res://scenes/cutscenes/DuolingoLesson.tscn",
	"open_cutscene"			:	"res://scenes/cutscenes/open_cutscene.tscn",
	"cutscene_kitchenA"		:	"res://scenes/cutscenes/KitchenCharles_cutscene.tscn",
	"cutscene_kitchenB"		:	"res://scenes/cutscenes/KitchenSmokeFeeding_cutscene.tscn"
}



func _ready():
	var root = get_tree().root
	# Using a negative index counts from the end, so this gets the last child node of `root`.
	current_scene = root.get_child(-1)
	#var player = get_tree().get_first_node_in_group("player")
	#current_location = [player.location.x,player.location.y]

func _process(_delta: float):
	if CHARLES_DIALOG_IN_SPANISH and !LET_CHARLES_OUTSIDE:
		CHARLES_FOLLOW = true
		SMOKE_FOLLOW = false
	elif LET_CHARLES_OUTSIDE and SMOKE_INSIDE and !SMOKE_FED:
		CHARLES_FOLLOW = false
		SMOKE_FOLLOW = false
	else:
		CHARLES_FOLLOW = false
		SMOKE_FOLLOW = false




##---ITEM LIST---##
var item_db := {
	"spanish_book": {
		"name": "the ability to speak Cat Spanish",
		"icon": "res://assets/art/PNG/objects/spanishbook-full.png",
		"timeline-after":""
	},
	"cat_food": {
		"name": "a Cup of Chicken Recipe Senior Cat Food",
		"icon": "res://assets/art/PNG/special/a_bag_of_science_diet_senior_7.png",
		"timeline-after":""
	},
	"crumpled_note": {
		"name": "a Crumpled Note",
		"icon": "res://assets/art/PNG/portraits/a_crumpled-up_piece_of_paper_w.png",
		"timeline-after":""
	},
	"torn_note": {
		"name": "an Uncrumpled Note - it is torn",
		"icon": "res://assets/art/PNG/special/SECRET-NOTE-fixed.png",
		"timeline-after":"torn_note_reading"
	},
}

## Awards an item to the player and shows the popup.
## Awaitable: await Gamedata.give_item("spanish_book")
func give_item(item_id: String) -> void:
	if not item_db.has(item_id):
		push_error("Gamedata.give_item: unknown item id '%s'" % item_id)
		return
	var data = item_db[item_id]
	await Overlay.show_item(data["name"], load(data["icon"]),data["timeline-after"])

#func show_item(item_id: String) -> void:
	#if not item_db.has(item_id):
		#push_error("Gamedata.give_item: unknown item id '%s'" % item_id)
		#return
	#var data = item_db[item_id]
	#await ItemCloseup.show_item(data["name"], load(data["icon"]))

## Single source of truth for "the player should not be controlling anything".
func is_input_blocked() -> bool:
	return _is_dialog_active or _is_popup_active





func move_npc_to(npc_name: String, coords: Vector2) -> Node:
	for npc in get_tree().get_nodes_in_group("npcs"):
		if npc.name == npc_name:
			npc.move_to(coords)
			return npc
	push_warning("move_npc_to: no NPC named " + npc_name)
	return null


# Saves the current scene, loads the new one on top.
# When the new scene emits `scene_finished`, swaps back.
func goto_cutscene(cutscene: String, custompos: bool):
	if !custompos:
		var pnode = get_node("/root/House/characters/player")
		var cnode = get_node("/root/House/characters/charles")
		var snode = get_node("/root/House/characters/smoke")
		store_character_positions(pnode.position,cnode.position,snode.position)
	var return_scene_path = current_scene.scene_file_path
	print(scene_paths[cutscene])
	_deferred_goto_cutscene.call_deferred(scene_paths[cutscene], return_scene_path)

func _deferred_goto_cutscene(path: String, return_path: String):
	# Free the current scene
	current_scene.free()

	# Load and instance the cutscene
	var s = ResourceLoader.load(path)
	current_scene = s.instantiate()
	get_tree().root.add_child(current_scene)
	get_tree().current_scene = current_scene

# When the cutscene says it's done, go back to where we came from
	current_scene.scene_finished.connect(func():
		goto_scene(return_path)
	)

func goto_scene(path):
	# This function will usually be called from a signal callback,
	# or some other function in the current scene.
	# Deleting the current scene at this point is
	# a bad idea, because it may still be executing code.
	# This will result in a crash or unexpected behavior.

	# The solution is to defer the load to a later time, when
	# we can be sure that no code from the current scene is running:

	# Set the variable that tracks the previous scene location in order to determine
	# where the player character should spawn in the next scene change
	#previous_scene = current_scene

	#player_previous_location = current_location
	_deferred_goto_scene.call_deferred(path)


func _deferred_goto_scene(path):
	# It is now safe to remove the current scene.
	current_scene.free()

	# Load the new scene.
	var s = ResourceLoader.load(path)

	# Instance the new scene.
	current_scene = s.instantiate()

	# Add it to the active scene, as child of root.
	get_tree().root.add_child(current_scene)


	# Optionally, to make it compatible with the SceneTree.change_scene_to_file() API.
	get_tree().current_scene = current_scene

	# Place characters at their previous locations
	#set_character_positions()
	#get_tree.call_deferred("load_stored_positions")
	load_stored_positions()

## Entry point from the title screen. Starts a fresh playthrough.
## Deliberately does NOT call load_stored_positions() — house.gd seeds
## the opening positions itself when GAME_START is true.
func start_new_game() -> void:
	#GAME_START = true
	_deferred_start_new_game.call_deferred()

func _deferred_start_new_game() -> void:
	# Free whatever is on screen (the title screen).
	var old = get_tree().current_scene
	if is_instance_valid(old):
		old.free()

	var s = ResourceLoader.load(scene_paths["house"])

	# current_scene MUST be assigned before add_child(). add_child() fires
	# house.gd::_ready() immediately, and that calls goto_cutscene(), which
	# reads current_scene.scene_file_path.
	current_scene = s.instantiate()
	get_tree().root.add_child(current_scene)
	get_tree().current_scene = current_scene

func _on_dialogue_started():
	_is_dialog_active = true

func _on_dialogue_ended():
	_is_dialog_active = false

func _get_player():
	return get_tree().get_first_node_in_group("player")
func _get_cats():
	return get_tree().get_nodes_in_group("npc")



##	---------------------------------------------
##	--- PROGRESSION TRACKING
##	---------------------------------------------

func store_character_positions(ppos: Vector2, cpos: Vector2, spos: Vector2):
	position_store["player"] = ppos
	position_store["charles"] = cpos
	position_store["smoke"] = spos
func load_stored_positions():
	#set_global_
	var pnode = get_node("/root/House/characters/player")
	pnode.set_position(position_store["player"])
	var cnode = get_node("/root/House/characters/charles")
	cnode.set_position(position_store["charles"])
	var snode = get_node("/root/House/characters/smoke")
	snode.set_position(position_store["smoke"])
func set_character_positions(ppos: Vector2, cpos: Vector2, spos: Vector2):
	var pnode = get_node("/root/House/characters/player")
	pnode.set_position(ppos)
	var cnode = get_node("/root/House/characters/charles")
	cnode.set_position(cpos)
	var snode = get_node("/root/House/characters/smoke")
	snode.set_position(spos)
	#if p:
		#position_store["player"] = p
	#else:
		#position_store["player"] = pnode.global_position
	#if c:
		#position_store["charles"] = c
	#else:
		#position_store["charles"] = cnode.global_position
	#if s:
		#position_store["smoke"] = s
	#else:
		#position_store["smoke"] = snode.global_position
