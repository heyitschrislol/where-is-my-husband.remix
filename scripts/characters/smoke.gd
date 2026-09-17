extends NPCMachine

@export var interaction_area: InteractionArea
@export var timeline_name : String
@export var location: String
@export var lines: Array[String] = []


signal dialog_signal(timeline: String,location: String)

func _ready():
	interaction_area.action_name = "speak"
	interaction_area.interact = Callable(self, "_on_interact")
	animated_sprite.play("idle_left")
	dialog_signal.connect(_on_dialog_request)
	follow_speed = 55
	follow_radius = 45
	#arrival_threshold = 10


func _on_dialog_request(timeline: String,_location: String):
	Dialogic.timeline_ended.connect(_on_timeline_ended)
	var dialog = Dialogic.start(timeline)
	#player.add_child(dialog)
	dialog.offset.x = player.position.x
	dialog.offset.y = player.position.y
	Gamedata._is_dialog_active = true

func _on_timeline_ended():
	Dialogic.timeline_ended.disconnect(_on_timeline_ended)
	# do something else here

func _on_interact():
	#Gamedata.position_store["charles"] = global_position
	start_dialog(timeline_name)

func decide_state() -> void:
	if has_destination:
		state = States.MOVINGTO
	elif Gamedata.SMOKE_FOLLOW:
		state = States.FOLLOWING
	else:
		state = States.IDLE

#func _physics_process(_delta):
	#if Gamedata.SMOKE_FOLLOW:
		#if get_distance_to_player() <= follow_radius:
			#set_state(States.IDLE)
		#else:
			#set_state(States.FOLLOWING)
	#elif Gamedata.SMOKE_DESTINATION_SET:
		#set_state(States.MOVINGTO)
		#if get_distance_to_object(destination_coords) <= follow_radius:
			#set_state(States.IDLE)
		#else:
			#set_state(States.MOVINGTO)
	#else:
		#set_state(States.IDLE)
	##else:
		##set_state(States.IDLE)
	#update_anim()
	#move_and_slide()

#func set_state(new_state: States):
	#var direction := player.global_position - global_position
	#var distance = direction.length()
#
#
	#var _previous_state := state
	#state = new_state
#
	#if state == States.IDLE:
		#velocity = Vector2.ZERO
	#elif state == States.FOLLOWING:
		#velocity = direction.normalized()*follow_speed
		#if distance <= follow_radius:
			#velocity = Vector2.ZERO
		##elif distance > follow_radius:
			##state = States.FOLLOWING
	#elif state == States.MOVINGTO:
		#if not destination_coords.is_zero_approx():
			#var objdirection : Vector2 = destination_coords - global_position
			#var objdistance = objdirection.length()
			#velocity = objdirection.normalized()*follow_speed
			#if objdistance <= arrival_threshold:
				#velocity = Vector2.ZERO

	#if debugging:
		#debugtext(direction,distance)

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

	if not moving:
		if Gamedata.SMOKE_CHOW_DOWN:
			animated_sprite.play("chow_down")
		else:
			animated_sprite.play("idle_" + facing)
	else:
		animated_sprite.play("walk_" + facing)


func start_dialog(timeline):
	dialog_signal.emit(timeline,location)
