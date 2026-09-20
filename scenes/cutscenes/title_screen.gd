extends CanvasLayer

@onready var title_txt = $center/vbox/title_txt
@onready var start_button = $center/vbox/press_start
@onready var start_label = $center/vbox/press_start_lbl
@onready var title_theme = $music
@onready var title_anim = $title_animation


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_start_btn_pressed():
	pass
