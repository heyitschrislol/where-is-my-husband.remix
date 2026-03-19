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

func _physics_process(_delta):
	if get_distance_to_player() <= follow_radius:
		set_state(States.IDLE)
	else:
		if Gamedata.SMOKE_FOLLOW:
			set_state(States.FOLLOWING)
		else:
			set_state(States.IDLE)
	update_anim()
	move_and_slide()

func set_state(new_state: States):
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
		#elif distance > follow_radius:
			#state = States.FOLLOWING

	if debugging:
		debugtext(direction,distance)

func update_anim():
		if velocity == Vector2.ZERO:
			match player.last_dir:
				#"up"	:		animated_sprite.flip_h = true
				#"down":	animated_sprite.flip_h = false
				"left":	animated_sprite.play("idle_left")
				"right":	animated_sprite.play("idle_right")

		elif abs(velocity.x) >= abs(velocity.y):
			if velocity.x > 0:
				animated_sprite.play("walk_right")
			elif velocity.x < 0:
				animated_sprite.play("walk_left")
				#animated_sprite.flip_h = true

func start_dialog(timeline):
	dialog_signal.emit(timeline,location)
