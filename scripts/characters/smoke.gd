extends NPCMachine

@export var interaction_area: InteractionArea
@export var timeline_name : String
@export var location: String
@export var lines: Array[String] = []

signal dialog_signal(timeline_name: String,location: String)

func _ready():
	interaction_area.action_name = "speak"
	interaction_area.interact = Callable(self, "_on_interact")
	animated_sprite.play("idle_left")

func _on_interact():
	start_dialog(timeline_name)

func _physics_process(_delta):
	if Gamedata.CHARLES_FOLLOW:
		set_state(States.FOLLOWING)
	else:
		set_state(States.IDLE)
	update_anim()
	move_and_slide()


func start_dialog(timeline):
	Gamedata.DIALOGLINE = lines.pick_random()
	dialog_signal.emit(timeline,location)
