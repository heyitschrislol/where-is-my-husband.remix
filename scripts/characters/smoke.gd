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
	start_dialog(timeline_name)

func _physics_process(_delta):
	#Gamedata.position_store["smoke"] = global_position
	if get_distance_to_player() <= follow_radius:
		set_state(States.IDLE)
	else:
		if Gamedata.SMOKE_FOLLOW:
			set_state(States.FOLLOWING)
		else:
			set_state(States.IDLE)
	update_anim()
	move_and_slide()
	update_anim()
	move_and_slide()


func start_dialog(timeline):
	#Gamedata.DIALOGLINE = lines.pick_random()
	Dialogic.VAR.set('INDEX',randf_range(1,3))
	dialog_signal.emit(timeline,location)

#func default_dialog():
	#Gamedata.DIALOGLINE = lines.pick_random()
	#var events : Array = []
	#var text_event = DialogicTextEvent.new()
	#text_event.text = Gamedata.DIALOGLINE
	#text_event.character = load("res://resources/dialogic/smoke.dch")
	#events.append(text_event)
	#var timeline : DialogicTimeline = DialogicTimeline.new()
	#timeline.events = events
	## if your events are already resources, you need to add this:
	##timeline.events_processed = true
	#Dialogic.start(timeline)
