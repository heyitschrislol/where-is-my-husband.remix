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
	follow_speed = 55
	follow_radius = 45
	dialog_signal.connect(_on_dialog_request)
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
