extends Node2D

@onready var charles = $scene_parts/characters/charles
@onready var player = $scene_parts/characters/player
@onready var smoke = $scene_parts/characters/smoke
@onready var door = $scene_parts/doorframe/door
@onready var exit_hallway = $exit_hallway

@onready var anim_player = $scene_parts/animation_player


func _ready():
	exit_hallway.dest_scene = "hallway"
	charles.dialog_signal.connect(_on_dialog_request)
	door.dialog_signal.connect(_on_dialog_request)

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



#func start_dialogue(timeline_name: String) -> void:
	## Start the dialogue
	#var layout = Dialogic.start(timeline_name)
	#
	## PAUSE the AnimationPlayer so the line stays on screen
	#anim_player.pause()
	#
	## Wait for Dialogic to finish this specific segment
	#Dialogic.timeline_ended.connect(_on_dialogue_finished, CONNECT_ONE_SHOT)
#
#func _on_dialogue_finished() -> void:
	## RESUME the AnimationPlayer to continue the sequence
	#anim_player.play()
	#
#func _on_dialogic_signal(argument:String):
	#if argument == "start_animation":
		#anim_player.play("charles_kitchen_event1")
