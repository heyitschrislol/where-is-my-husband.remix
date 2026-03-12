class_name Player extends CharacterBody2D


@export var speed: float = 200.0
@export var inventory: Array[ContentItem] = []
@export var last_dir: String = "down"
@onready var player_sprite = $animated_sprite_2d
@export var is_stopped: bool

func _ready():
	player_sprite.play("idle_down")

func _physics_process(_delta):
	if not Gamedata._is_dialog_active:
		var direction = Vector2(
			Input.get_axis("ui_left", "ui_right"),
			Input.get_axis("ui_up", "ui_down")
		).normalized()

		velocity = direction * speed
		#print("player velocity: " + str(velocity))
		#print("player direction: " + str(direction))
		update_anim(direction)
		move_and_slide()

func update_anim(direction: Vector2):
	if direction == Vector2.ZERO:
		is_stopped = true
		match last_dir:
			"up":		player_sprite.play("idle_up")
			"down":		player_sprite.play("idle_down")
			"left":		player_sprite.play("idle_left")
			"right":	player_sprite.play("idle_right")
	else:
		if abs(direction.x) >= abs(direction.y):
			if direction.x > 0:
				last_dir = "right"
				player_sprite.play("walk_right")
			else:
				last_dir = "left"
				player_sprite.play("walk_left")
		else:
			if direction.y > 0:
				last_dir = "down"
				player_sprite.play("walk_down")
			else:
				last_dir = "up"
				player_sprite.play("walk_up")
