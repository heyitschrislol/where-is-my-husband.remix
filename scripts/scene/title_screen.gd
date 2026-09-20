extends CanvasLayer

@onready var title_txt = $center/vbox/title_txt
@onready var start_button = $center/vbox/press_start
@onready var start_label = $center/vbox/press_start_lbl
@onready var title_theme = $music
@onready var title_anim = $title_animation

var _starting := false   ## guard so the start sequence can only fire once

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# The "grow" animation owns the visibility of both labels, but disabled
	# is the real lock: a disabled Button ignores both clicks AND its Shortcut.
	start_button.disabled = true

	title_anim.play("grow")
	await title_anim.animation_finished

	start_button.disabled = false
	start_button.grab_focus()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_start_btn_pressed() -> void:
	if _starting:
		return
	_starting = true
	start_button.disabled = true

	# Fade the theme instead of cutting it dead when the scene is freed.
	var tween = create_tween()
	tween.tween_property(title_theme, "volume_db", -40.0, 0.6)
	await tween.finished

	Gamedata.start_new_game()
