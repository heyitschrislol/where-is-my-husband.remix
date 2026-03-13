extends Sprite2D

@onready var interaction_area: InteractionArea = $interaction_area
@onready var dialog_name = ""
@onready var collisionshape_interaction = $interaction_area/CollisionShape2D
@onready var spritetexture = texture
@onready var sprite_size: Vector2

signal dialog_signal(timeline_name: String,location: String,default_text: String)

func _ready():
	#var sprite_texture = sprite.texture
	if spritetexture:
		sprite_size = spritetexture.get_size()
		collisionshape_interaction.shape.size = (sprite_size * 1.5) * scale
	interaction_area.action_name = "interact"
	interaction_area.interact = Callable(self, "_special_interaction")

func _special_interaction():
	start_dialog(dialog_name)

func start_dialog(timeline):
	dialog_signal.emit(timeline,"")
