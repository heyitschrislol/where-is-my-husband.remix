extends Node2D

@onready var firstanim = $cutsceneAnim

func _ready():
	pass
func _process(_delta):
	pass


func start_cutscene():
	Dialogic.Inputs.paused = true
	firstanim.play("cutscene_sequence")


func _on_cutscene_finished():
	Dialogic.Inputs.paused = false

#@onready var anim_player = $cutsceneAnim
#
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
