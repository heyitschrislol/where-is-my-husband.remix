class_name NPCMachine extends CharacterBody2D


enum States { IDLE,FOLLOWING,MOVINGTO	}
var state : States = States.IDLE

@export var debugging: bool

@export var player : Player
@export var animated_sprite : AnimatedSprite2D
@export_group("Vision Ranges")
@export var detection_radius := 250.0
@export var follow_radius := 100.0
@export var follow_speed := 175.0

func _ready():

	pass


func _physics_process(_delta):
	pass
	#if get_distance_to_player() <= follow_radius:
		#set_state(States.IDLE)
	#else:
		#if Gamedata.CHARLES_FOLLOW:
			#set_state(States.FOLLOWING)
		#else:
			#set_state(States.IDLE)
	#update_anim()
	#move_and_slide()
	#if get_distance_to_player() <= detection_radius:
		#set_state(States.FOLLOWING)
	#else:
		#set_state(States.IDLE)
	#update_anim()
	#move_and_slide()


func set_state(new_state: States) -> void:
	var direction := player.global_position - global_position
	var distance = direction.length()
	var _previous_state := state

	state = new_state

	if state == States.IDLE:
		velocity = Vector2.ZERO
	if state == States.FOLLOWING:
		velocity = direction.normalized()*follow_speed
		if distance <= follow_radius:
			velocity = Vector2.ZERO
		elif distance > follow_radius:
			state = States.FOLLOWING
	if state == States.MOVINGTO:
		velocity = direction.normalized()*follow_speed
		if distance <= follow_radius:
			velocity = Vector2.ZERO
		elif distance > follow_radius:
			state = States.MOVINGTO

	if debugging:
		debugtext(direction,distance)


#func idle_behavior():
	#pass
#func follow_behavior(direction,follow_speed,distance):
	#pass

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

func get_distance_to_object(object_pos: Vector2) -> float:
	return object_pos.distance_to(global_position)

func debugtext(direction, distance):
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
