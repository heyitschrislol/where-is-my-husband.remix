extends NPCMachine

@export var interaction_area: InteractionArea
@export var timeline_name : String
@export var location: String
@export var lines: Array[String] = []



signal dialog_signal(timeline: String,location: String)

var was_moving := false
var is_transitioning := false
var facing := "right"


func _ready():
	debugging
	interaction_area.action_name = "speak"
	interaction_area.interact = Callable(self, "_on_interact")
	animated_sprite.play("sitting_idle_" + facing)
	animated_sprite.animation_finished.connect(_on_animation_finished)
	dialog_signal.connect(_on_dialog_request)
	follow_speed = 100
	follow_radius = 40
	_check_transition_anims_not_looping()

func _check_transition_anims_not_looping():
	for anim_name in ["standing_motion_left", "standing_motion_right", "sitting_motion_left", "sitting_motion_right"]:
		if animated_sprite.sprite_frames.get_animation_loop(anim_name):
			push_warning("Charles: '%s' has Loop enabled — it should be a one-shot transition!" % anim_name)

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
		if Gamedata.CHARLES_FOLLOW:
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
		var debugdata = {
			"npc-dir"														:	direction,
			"npc-distance"											:	distance,
			#"npc-velocity.x"										:	velocity.x,
			#"npc-velocity.y"										:	velocity.y,
			"npc-state"													:	state,
			#"npc-follow-speed"								:	follow_speed,
			#"npc-follow-radius"							:	follow_radius,
			#"npc-detection-radius"					:	detection_radius,
			"player-speed"											:	player.speed,
			"player-velocity-x"							:	player.velocity.x,
			"player-velocity-y"							:	player.velocity.y
		}

		debugtext(direction, distance,debugdata)

func update_anim():
	if is_transitioning:
		return # a transition anim is playing — don't interrupt it

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

	if moving and not was_moving:
		# was sitting, now starts moving: stand up first
		is_transitioning = true
		animated_sprite.play("standing_motion_" + facing)
	elif not moving and was_moving:
		# was walking, now stops: sit down first
		is_transitioning = true
		animated_sprite.play("sitting_motion_" + facing)
	elif moving:
		animated_sprite.play("walk_" + facing)

	was_moving = moving

		#if velocity == Vector2.ZERO:
			#match player.last_dir:
				##"up"	:		animated_sprite.flip_h = true
				##"down":	animated_sprite.flip_h = false
				#"left":	animated_sprite.play("idle_left")
				#"right":	animated_sprite.play("idle_right")
#
		#elif abs(velocity.x) >= abs(velocity.y):
			#if velocity.x > 0:
				#animated_sprite.play("walk_right")
			#elif velocity.x < 0:
				#animated_sprite.play("walk_left")
				#animated_sprite.flip_h = true

func _on_animation_finished():
	if animated_sprite.animation.begins_with("standing_motion"):
		is_transitioning = false
		animated_sprite.play("walk_" + facing)
	elif animated_sprite.animation.begins_with("sitting_motion"):
		is_transitioning = false
		animated_sprite.play("sitting_idle_" + facing)


func start_dialog(timeline):
	dialog_signal.emit(timeline,location)
