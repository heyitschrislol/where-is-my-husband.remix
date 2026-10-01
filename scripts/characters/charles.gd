extends NPCMachine

@export var interaction_area: InteractionArea
@export var timeline_name : String
@export var location: String
@export var lines: Array[String] = []

signal dialog_signal(timeline: String,location: String)

var was_moving := false
var is_transitioning := false


func _ready():
	#debugging
	interaction_area.action_name = "speak"
	interaction_area.interact = Callable(self, "_on_interact")
	animated_sprite.play("sitting_idle_" + facing)
	animated_sprite.animation_finished.connect(_on_animation_finished)
	dialog_signal.connect(_on_dialog_request)

	_check_transition_anims_not_looping()

func _check_transition_anims_not_looping():
	for anim_name in ["standing_motion_left", "standing_motion_right", "sitting_motion_left", "sitting_motion_right"]:
		if animated_sprite.sprite_frames.get_animation_loop(anim_name):
			push_warning("Charles: '%s' has Loop enabled — it should be a one-shot transition!" % anim_name)

func _on_dialog_request(timeline: String,_location: String):
	Dialogic.timeline_ended.connect(_on_timeline_ended)
	Dialogic.start(timeline_name)
	#player.add_child(dialog)
	#dialog.offset.x = player.position.x
	#dialog.offset.y = player.position.y
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
	elif Gamedata.CHARLES_FOLLOW:
		state = States.FOLLOWING
	else:
		state = States.IDLE

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

func _on_animation_finished():
	if animated_sprite.animation.begins_with("standing_motion"):
		is_transitioning = false
		animated_sprite.play("walk_" + facing)
	elif animated_sprite.animation.begins_with("sitting_motion"):
		is_transitioning = false
		animated_sprite.play("sitting_idle_" + facing)


func start_dialog(timeline):
	dialog_signal.emit(timeline,location)
