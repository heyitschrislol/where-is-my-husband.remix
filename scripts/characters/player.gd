class_name Player extends CharacterBody2D

enum States { IDLE,WALKING,MOVINGTO	}
var state : States = States.IDLE

@export var speed: float = 85.0
@export var inventory: Array[ContentItem] = []
@export var last_dir: String = "down"
@onready var player_sprite = $animated_sprite_2d
@export var is_stopped: bool
#@export var facing := "down"

@export_group("Target Destination")
@export var arrival_threshold := 4.0
@export var moving_to_speed : float = 0.0
@export_group("")

@export var stuck_timeout := 4.0
var _best_distance := INF
var _stuck_time := 0.0
var destination_coords: Vector2 = Vector2.ZERO
var has_destination: bool = false
var waypoints: Array[Vector2] = []

var input_dir: Vector2 = Vector2.ZERO

## STEP AUDIO ##
const STEP_DISTANCE := 40.0   # pixels between footsteps — tune by ear
var _distance_since_step := 0.0

signal destination_reached

func _ready():
	pass

func _physics_process(_delta):

	decide_state()
	apply_state(_delta)
	update_anim()
	move_and_slide()
	_update_footsteps(_delta)

func decide_state() -> void:
	input_dir = Vector2(
		Input.get_axis("ui_left", "ui_right"),
		Input.get_axis("ui_up", "ui_down")
	).normalized()

	if has_destination:
		state = States.MOVINGTO
	elif input_dir != Vector2.ZERO and not Gamedata.is_input_blocked():
		state = States.WALKING
	else:
		state = States.IDLE


func apply_state(delta: float) -> void:
	match state:
		States.IDLE:
			velocity = Vector2.ZERO
		States.WALKING:
			velocity = input_dir * speed
		States.MOVINGTO:
			_step_toward_destination(delta)




func _step_toward_destination(delta: float) -> void:
	if not has_destination:
		velocity = Vector2.ZERO
		return

	var to_target := destination_coords - global_position
	var distance := to_target.length()
	if distance < _best_distance - 1.0:
		_best_distance = distance
		_stuck_time = 0.0
	else:
		_stuck_time += delta
		if _stuck_time > stuck_timeout:
			push_warning("%s stuck en route to %s" % [name, destination_coords])
			global_position = destination_coords
			_best_distance = INF
			_stuck_time = 0.0
	var step := speed * delta  # how far one physics frame carries us

	# Stop if we're inside the threshold OR if one more frame would overshoot.
	if distance <= max(arrival_threshold, step):
		if not waypoints.is_empty():
			destination_coords = waypoints.pop_front()
			_step_toward_destination(delta)   # re-aim immediately, same frame
			return

		velocity = Vector2.ZERO
		has_destination = false
		state = States.IDLE
		destination_reached.emit()
		return

	velocity = to_target.normalized() * speed


## Public API — this is what the rest of the game calls.
func move_to(target: Vector2) -> void:
	_best_distance = INF
	_stuck_time = 0.0
	waypoints.clear()
	destination_coords = target
	has_destination = true
	state = States.MOVINGTO

## Walk a multi-point route. The final point is the destination.
func move_along(points: Array[Vector2]) -> void:
	_best_distance = INF
	_stuck_time = 0.0
	if points.is_empty():
		return
	waypoints = points.duplicate()   # duplicate so we don't mutate the caller's array
	destination_coords = waypoints.pop_front()
	has_destination = true
	state = States.MOVINGTO

func cancel_move_to() -> void:
	waypoints.clear()
	has_destination = false
	velocity = Vector2.ZERO
	if state == States.MOVINGTO:
		state = States.IDLE

func set_state(new_state: States) -> void:
	#var direction := player.global_position - global_position
	var direction = Vector2(
			Input.get_axis("ui_left", "ui_right"),
			Input.get_axis("ui_up", "ui_down")
		).normalized()
	var distance = direction.length()
	var _previous_state := state

	state = new_state

	if state == States.IDLE:
		velocity = Vector2.ZERO
	if state == States.WALKING:
		velocity = direction.normalized()*speed
	#if state == States.FOLLOWING:
		#velocity = direction.normalized()*speed
		#if distance <= follow_radius:
			#velocity = Vector2.ZERO
		#elif distance > follow_radius:
			#state = States.FOLLOWING
	if state == States.MOVINGTO:
		velocity = direction.normalized()*speed
		state = States.MOVINGTO

func update_anim():
	var moving = velocity != Vector2.ZERO
	if moving:
		if abs(velocity.x) >= abs(velocity.y):
			if velocity.x > 0:
				last_dir = "right"
			elif velocity.x < 0:
				last_dir = "left"
		else:
			if velocity.y > 0:
				last_dir = "down"
			elif velocity.y < 0:
				last_dir = "up"
		player_sprite.play("walk_" + last_dir)
	else:
		player_sprite.play("idle_" + last_dir)


func _update_footsteps(delta: float) -> void:
	if velocity.length() < 1.0:
		# Standing still. Prime the counter so the first step after
		# starting to walk lands quickly instead of feeling delayed.
		_distance_since_step = STEP_DISTANCE * 0.5
		return

	_distance_since_step += velocity.length() * delta
	if _distance_since_step >= STEP_DISTANCE:
		_distance_since_step = 0.0
		Audio.play_varied("footstep", -8.0)


func get_distance_to_object(object_pos: Vector2) -> float:
	return object_pos.distance_to(global_position)
