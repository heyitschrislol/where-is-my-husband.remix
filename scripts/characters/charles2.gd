extends CharacterBody2D

@onready var interaction_area: InteractionArea = $interaction_area
@onready var character_sprite = $body/animated_sprite_2d
@onready var event_animations = $animations/AnimationPlayer
#@onready var location = Gamedata.current_scene.name
@onready var location = "bedroom"

#@export var speed: float = 300.0
@export var timeline_name = "bedroom_charles"

signal dialog_signal(timeline_name: String,location: String)

@export var lines: Array[String] = [
]

func _ready():
	interaction_area.action_name = "speak"
	interaction_area.interact = Callable(self, "_on_interact")
	character_sprite.play("idle")

func _on_interact():
	print("Dialogic command: " + timeline_name)
	#Gamedata._interaction_type = "speak"
	start_dialog("bedroom_charles")

func _physics_process(_delta):
	#var direction = Input.get_axis("ui_left", "ui_right")
	#if direction:
		#velocity.x = direction * speed
	#else:
		#velocity.x = move_toward(velocity.x, 0, speed)
	update_anim()
	#move_and_slide()

func update_anim():
	if velocity.x != 0:
		character_sprite.play("walking")
	else:
		character_sprite.play("idle")
	if velocity.x > 0:
		character_sprite.flip_h = false
	elif velocity.x < 0:
		character_sprite.flip_h = true

func start_dialog(timeline):
	Gamedata.DIALOGLINE = lines.pick_random()
	dialog_signal.emit(timeline,location)
