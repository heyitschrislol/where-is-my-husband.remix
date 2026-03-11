class_name NPC
extends CharacterBody2D


@onready var interaction_area: InteractionArea

#@onready var event_animations = $animations/AnimationPlayer
#@onready var location = Gamedata.current_scene.name
#@export var animated_sprite: Sprite2D
#@export var animated_sprite : AnimationPlayer
@export var animated_sprite : AnimatedSprite2D
@export var timeline_name : String
@export var location: String
@export var lines: Array[String] = []

signal dialog_signal(timeline_name: String,location: String,default_text: String)


func _ready():
	interaction_area.action_name = "speak"
	interaction_area.interact = Callable(self, "_on_interact")
	#animated_sprite.play("idle")


func _on_interact():
	#print("Dialogic command: " + timeline_names[0])
	#Gamedata._interaction_type = "speak"
	start_dialog(timeline_name)

func _physics_process(_delta):

	update_anim()
	#move_and_slide()

func update_anim():
	pass

func start_dialog(timeline):
	dialog_signal.emit(timeline,location,lines.pick_random())
