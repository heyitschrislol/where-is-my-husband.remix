extends Node

#var player = get_tree().get_first_node_in_group("player")
var current_scene = null
var previous_scene = null
var current_location = null
var player_previous_location = null
var _is_dialog_active: bool = false
#var _last_location: Array = [player.location.x,player.location.y]


##---SCENE LIST---##
var scene_paths = {
	"house"					:	"res://scenes/house.tscn",
	"duolingo"				:	"res://scenes/cutscenes/DuolingoLesson.tscn",
	"open_cutscene"			:	"res://scenes/cutscenes/open_cutscene.tscn",
	"cutscene_kitchenA"		:	"res://scenes/cutscenes/KitchenCharles_cutscene.tscn",
	"cutscene_kitchenB"		:	"res://scenes/cutscenes/KitchenSmokeFeeding_cutscene.tscn",
}


func _ready():
	var root = get_tree().root
	# Using a negative index counts from the end, so this gets the last child node of `root`.
	current_scene = root.get_child(-1)
	#var player = get_tree().get_first_node_in_group("player")
	#current_location = [player.location.x,player.location.y]

func goto_cutscene(cutscene: String):
	# Saves the current scene, loads the new one on top.
	# When the new scene emits `scene_finished`, swaps back.

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


func _on_dialogue_started():
	_is_dialog_active = true

func _on_dialogue_ended():
	_is_dialog_active = false


##	---------------------------------------------
##	--- PROGRESSION TRACKING
##	---------------------------------------------


var GAME_START = false
## KITCHEN
## -----------
var SMOKE_INSIDE = false
var SMOKE_FED = false
var CRUMPLED_NOTE_DROPPED = false
var CRUMPLED_NOTE_READ = false
## GUESTROOM
## -----------
var PMAIL_HACKED = false
var CAT_SPANISH_LEARNED = false
## BEDROOM
## -----------
var CHARLES_FIRST_INTERACTION = true
var CHARLES_DIALOG_IN_SPANISH = false
