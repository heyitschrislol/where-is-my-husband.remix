extends CharacterBody2D

#@export var speed: float = 300.0


@onready var interaction_area: InteractionArea = $interaction_area
@onready var character_sprite = $body/animated_sprite_2d
@onready var event_animations = $animations/AnimationPlayer


func _ready():
	interaction_area.interact = Callable(self, "_on_interact")
	character_sprite.play("idle_right")

func _on_interact():
	pass



func _physics_process(delta):
	#var direction = Input.get_axis("ui_left", "ui_right")
	#if direction:
		#velocity.x = direction * speed
	#else:
		#velocity.x = move_toward(velocity.x, 0, speed)
	update_anim()
	move_and_slide()

func update_anim():
	if velocity.x != 0:
		character_sprite.play("walking")
	else:
		character_sprite.play("idle_right")
	if velocity.x > 0:
		character_sprite.flip_h = false
	elif velocity.x < 0:
		character_sprite.flip_h = true

#const SPEED = 300.0
#const JUMP_VELOCITY = -400.0


#func _physics_process(delta: float) -> void:
	## Add the gravity.
	#if not is_on_floor():
		#velocity += get_gravity() * delta
#
	## Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY
#
	## Get the input direction and handle the movement/deceleration.
	## As good practice, you should replace UI actions with custom gameplay actions.
	#var direction := Input.get_axis("ui_left", "ui_right")
	#if direction:
		#velocity.x = direction * SPEED
	#else:
		#velocity.x = move_toward(velocity.x, 0, SPEED)
#
	#move_and_slide()
