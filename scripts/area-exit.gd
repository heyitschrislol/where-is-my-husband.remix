extends Node2D

@onready var interaction_area: InteractionArea = $interaction_area
@onready var location = Gamedata.current_scene.name
@export var dest_scene: String
@export var dest_path: String
#signal dialog_signal(timeline_name: String,location: String,default_text: String)

func _ready():
	dest_path = Gamedata.scene_paths[dest_scene]
	interaction_area.action_name = "enter"
	interaction_area.interact = Callable(self, "_move_to_area")

func _move_to_area():
	Gamedata.goto_scene(dest_path)
	#sprite.frame = 1 if sprite.frame == 0 else 0
	#start_dialog("kitchen_door")
	#pass

func start_animation(animation,direction):
	pass

#func start_dialog(timeline):
	#dialog_signal.emit(timeline,"","")
