class_name NPC extends CharacterBody2D

enum States { IDLE,FOLLOWING	}
var state : States = States.IDLE

@export var interaction_area: InteractionArea
@export var animated_sprite : AnimatedSprite2D
@export var timeline_name : String
@export var location: String
@export var lines: Array[String] = []
@export var player : Player


@export_group("Vision Ranges")
@export var detection_radius := 250.0
@export var follow_radius := 100.0
#@export var follow_radius := 200.0

signal dialog_signal(timeline_name: String,location: String,default_text: String)


func _ready():
	interaction_area.action_name = "speak"
	interaction_area.interact = Callable(self, "_on_interact")
	#animated_sprite.play("idle")


func _on_interact():
	pass
	#print("Dialogic command: " + timeline_names[0])
	#Gamedata._interaction_type = "speak"
	#start_dialog(timeline_name)

func _physics_process(_delta):
	if get_distance_to_player() <= detection_radius:
		set_state(States.FOLLOWING)
	else:
		set_state(States.IDLE)

	update_anim()
	move_and_slide()


func set_state(new_state: States) -> void:

	var follow_speed := 115.0
	var direction := player.global_position - global_position
	var distance = direction.length()
	var _previous_state := state
	var debugdata = {
		"npc-dir:"						:	direction,
		"npc-distance:"				:	distance,
		"npc-velocity.x:"			:	velocity.x,
		"npc-velocity.y:"			:	velocity.y,
		"npc-state:"					:	state
	}
	for x in debugdata:
		print(x, debugdata[x])
		print(get_distance_to_player())
	state = new_state

	if state == States.IDLE:
		idle_behavior()

	if state == States.FOLLOWING:
		follow_behavior(direction,follow_speed,distance)


func idle_behavior():
	velocity = Vector2.ZERO

func follow_behavior(direction,follow_speed,distance):
	velocity = direction.normalized()*follow_speed
	if distance > follow_radius:
		state = States.FOLLOWING
	if distance <= follow_radius:
		velocity = Vector2.ZERO


func update_anim():
		if !velocity:
			match player.last_dir:
				#"up":		animated_sprite.play("idle_up")
				#"down":		animated_sprite.play("idle_down")
				"left":		animated_sprite.play("idle_left")
				"right":	animated_sprite.play("idle_right")
		if abs(velocity.x) >= abs(velocity.y):
			if velocity.x > 0:
				animated_sprite.play("walk_right")
			else:
				animated_sprite.play("walk_left")
		else:
			if velocity.y > 0:
				animated_sprite.play("walk_down")
			else:
				animated_sprite.play("walk_up")
func get_distance_to_player() -> float:
	return player.global_position.distance_to(global_position)

#func start_dialog(timeline):
	#dialog_signal.emit(timeline,location,lines.pick_random())


####################
#		FOLLOW STATE
####################
