extends Node2D

signal scene_finished

@onready var anim_player = $scene_parts/cutsceneAnim



func _ready():
	Dialogic.signal_event.connect(_on_dialogic_signal)
	start_dialogue("startingscene")
func _process(_delta):
	pass

func start_dialogue(timeline_name: String) -> void:
	# Start the dialogue
	Dialogic.start(timeline_name)

	await anim_player.animation_finished

	Dialogic.start("startingscene2")
	# Wait for Dialogic to finish this specific segment
	Dialogic.timeline_ended.connect(_on_dialogue_finished, CONNECT_ONE_SHOT)


	## PAUSE the AnimationPlayer so the line stays on screen
	#anim_player.pause()



func _on_dialogue_finished() -> void:
	# RESUME the AnimationPlayer to continue the sequence
	scene_finished.emit()

func _on_dialogic_signal(argument:String):
	if argument == "start_animation":
		anim_player.play("slow_walk")
