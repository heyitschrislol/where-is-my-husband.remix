extends Node2D

signal scene_finished

@onready var doorplayer = $sceneparts/doorframe/door/AnimationPlayer
@onready var baileyplayer = $bailey/AnimationPlayer
@onready var charlesplayer = $charles/AnimationPlayer
@onready var smokeplayer = $smoke/AnimationPlayer
@onready var last = false

func _ready():
	Dialogic.signal_event.connect(_on_dialogic_signal)
	start_dialogue("cutscene_kitchenA")



func start_dialogue(cutscene: String) -> void:
	##	1. (bailey/charles anim.play(walk-to-door)) 			bailey and charles walk to island area
	##	2. (dialogic cutscene_kitchenA)							bailey says she'll let charles outside
	##	3. (bailey anim.play(open-door)) 						bailey moves to door
	##	4. (door anim.play(open)) 								door opens
	## 	5. (charles anim.play(to-outside))						charles walks outside
	##	6. (smoke anim.play(to-inside)							smoke walks inside
	##	7. (dialogic cutscene_kitchenB)							bailey welcomes smoke



	# Start the dialogue
	print("dialog started "+cutscene)
	var layout = Dialogic.start("dtl_cutscene_kitchenA")
	#print("current timeline: ")




	# Wait for Dialogic to finish this specific segment
	last = true
	Dialogic.timeline_ended.connect(_on_dialogue_finished, CONNECT_ONE_SHOT)


	## PAUSE the AnimationPlayer so the line stays on screen
	#anim_player.pause()


func _on_dialogic_started():
	#var dialog_node = Dialogic.get_current_timeline_node()
	#var dialog_node = Dialogic.get_current_timeline_node()
	#Dialogic.current_timeline.follow_viewport_enabled = false # If using SubViewport
	pass

func _on_dialogue_finished() -> void:
	# RESUME the AnimationPlayer to continue the sequence
	#Gamedata.goto_scene("res://world/scenes/Kitchen.tscn")
	#dialog_node.follow_viewport_enabled = true
	if last:
		scene_finished.emit()

func _on_dialogic_signal(argument:String):
	if argument == "kitchen_start":
		baileyplayer.play("walk-to-door")
		charlesplayer.play("walk-to-door")
		await baileyplayer.animation_finished
		await charlesplayer.animation_finished
	elif argument == "kitchen_charles_leave":
		baileyplayer.play("open-door")
		await baileyplayer.animation_finished
		doorplayer.play("open")
		await doorplayer.animation_finished
		charlesplayer.play("to-outside")
		await charlesplayer.animation_finished
