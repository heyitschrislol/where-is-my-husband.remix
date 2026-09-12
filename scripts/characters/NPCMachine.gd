class_name NPCMachine extends CharacterBody2D


enum States { IDLE,FOLLOWING,MOVINGTO	}
var state : States = States.IDLE

@export var debugging: bool

@export var player : Player
@export var animated_sprite : AnimatedSprite2D

@export_group("Movement Behavior")
@export var detection_radius := 250.0
@export var follow_radius := 100.0
@export var follow_speed := 175.0
@export var facing := "down"
@export_group("""""")

@export_group("Target Destination")
@export var arrival_threshold := 4.0
@export_group("")

@export var stuck_timeout := 4.0
var _best_distance := INF
var _stuck_time := 0.0
var destination_coords: Vector2 = Vector2.ZERO
var has_destination: bool = false
var waypoints: Array[Vector2] = []


signal destination_reached

func _ready():

	pass


func _physics_process(_delta):
	decide_state()
	apply_state(_delta)
	update_anim()
	move_and_slide()

func decide_state() -> void:
	state = States.IDLE

func apply_state(delta: float) -> void:
	match state:
		States.IDLE:
			velocity = Vector2.ZERO
		States.FOLLOWING:
			var to_player := player.global_position - global_position
			if to_player.length() <= follow_radius:
				velocity = Vector2.ZERO
			else:
				velocity = to_player.normalized() * follow_speed
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
	var step := follow_speed * delta  # how far one physics frame carries us

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

	velocity = to_target.normalized() * follow_speed


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
	var moving = velocity != Vector2.ZERO
	if moving:
		if abs(velocity.x) >= abs(velocity.y):
			if velocity.x > 0:
				facing = "right"
			elif velocity.x < 0:
				facing = "left"
		else:
			if velocity.y > 0:
				facing = "down"
			elif velocity.y < 0:
				facing = "up"
		animated_sprite.play("walk_" + facing)
	else:
		animated_sprite.play("idle_" + facing)
	#if not moving:
		#animated_sprite.play("idle_" + facing)
	#else:
		#animated_sprite.play("walk_" + facing)
		#if !velocity:
			#match player.last_dir:
				##"up":		animated_sprite.play("idle_up")
				##"down":		animated_sprite.play("idle_down")
				#"left":		animated_sprite.play("idle_left")
				#"right":	animated_sprite.play("idle_right")
		#if abs(velocity.x) >= abs(velocity.y):
			#if velocity.x > 0:
				#animated_sprite.play("walk_right")
			#else:
				#animated_sprite.play("walk_left")
		#else:
			#if velocity.y > 0:
				#animated_sprite.play("walk_down")
			#else:
				#animated_sprite.play("walk_up")

func get_distance_to_player() -> float:
	return player.global_position.distance_to(global_position)

func get_distance_to_object(object_pos: Vector2) -> float:
	return object_pos.distance_to(global_position)

func debugtext(direction,distance,debug_data: Dictionary = {}):
	for item in debug_data:
		var data_item =debug_data.get(item,0)
		if data_item:
			print(item, ": ", debug_data[item])
		else:
			print(item," is 0")
