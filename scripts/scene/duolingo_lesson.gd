extends CanvasLayer

signal lesson_completed(success: bool)
signal scene_finished

##	--	UI ELEMENTS
##	----------------------
@onready var question_label = $Control/BubbleTexture/QuestionLabel
@onready var answer_grid = $Control/AnswerGrid
@onready var feedback_label = $Control/FeedbackLabel
@onready var continue_btn = $Control/ContinueButton
@onready var progress_bar = $Control/ProgressBar
@onready var heart_label = $Control/HeartLabel  # shows ❤️❤️❤️
@onready var guy_image = $Control/GuyTexture
@onready var speech_bubble = $Control/BubbleTexture
@onready var iconA = preload("res://assets/art/Scene/duolingo/duocheckbtn1.png")
@onready var iconB = preload("res://assets/art/Scene/duolingo/duocheckbtn2.png")

##	--	SOUND EFFECTS
##	----------------------
@onready var sfx_correct = $Control/CorrectSound
@onready var sfx_wrong = $Control/IncorrectSound
@onready var sfx_passed = $Control/spanishlearnedSound


var current_question_index = 0
var mistakes = 0
var max_mistakes = 0  # 0 = must be perfect

var questions = [
	{
		"prompt": "What does 'afuera' mean?",
		"answers": ["Outside", "Hungry", "Door", "Sleep"],
		"correct": 0,
		"image"	 : "res://assets/art/Scene/duolingo/duo_guy1.png"
	},
	{
		"prompt": "How do you say 'he wants' in Spanish?",
		"answers": ["come", "quiere", "gato", "casa"],
		"correct": 1,
		"image"	 : "res://assets/art/Scene/duolingo/duo_guy2.png"
	}
	#},
	#{
		#"prompt": "Translate: 'El gato tiene hambre'",
		#"answers": ["The cat is outside", "The cat is sleeping", "The cat is hungry", "The cat wants in"],
		#"correct": 2,
		#"image"	 : "res://assets/art/Scene/duolingo/duo_guy3.png"
#
	#},
	#{
		#"prompt": "What does 'puerta' mean?",
		#"answers": ["Window", "Door", "Floor", "Wall"],
		#"correct": 1,
		#"image"	 : "res://assets/art/Scene/duolingo/duo_guy4.png"
#
	#},
	#{
		#"prompt": "Charles says 'Quiero salir.' What does he want?",
		#"answers": ["To eat", "To sleep", "To go outside", "To play"],
		#"correct": 2,
		#"image"	 : "res://assets/art/Scene/duolingo/duo_guy5.png"
#
	#}
]

func _ready():
	progress_bar.max_value = questions.size()
	progress_bar.value = 0

	#continue_btn.hide()
	feedback_label.hide()
	load_question()

func load_question():
	var q = questions[current_question_index]
	question_label.text = q["prompt"]
	progress_bar.value = current_question_index

	# Clear old buttons
	for child in answer_grid.get_children():
		child.queue_free()

	# Create answer buttons
	for i in range(q["answers"].size()):
		var btn = Button.new()
		btn.text = q["answers"][i]
		btn.pressed.connect(_on_answer_pressed.bind(i))
		answer_grid.add_child(btn)

	# Set character image
	guy_image.texture = load(q["image"])
	feedback_label.hide()
	continue_btn.icon = iconA

func _on_answer_pressed(index: int):
	var correct = questions[current_question_index]["correct"]

	# Disable all buttons
	for btn in answer_grid.get_children():
		btn.disabled = true

	if index == correct:
		feedback_label.text = "✓ Correct!"
		feedback_label.modulate = Color.GREEN
		sfx_correct.play()
	else:
		feedback_label.text = "✗ Wrong! The answer was: " + questions[current_question_index]["answers"][correct]
		feedback_label.modulate = Color.RED
		mistakes += 1
		sfx_wrong.play()

	continue_btn.icon = iconB
	feedback_label.show()

func _on_continue_button_pressed() -> void:
	current_question_index += 1

	if current_question_index >= questions.size():
		# Lesson over
		if mistakes == 0:
			_on_lesson_passed()
		else:
			_on_lesson_failed()
	else:
		load_question()#func _on_continue_button_pressed():

func _on_lesson_passed():
	Gamedata.CAT_SPANISH_LEARNED = true
	Dialogic.VAR.set_variable("PLAYED_DUOLINGO", true)
	feedback_label.text = "🎉 ¡Perfecto! Lesson Complete!"
	feedback_label.modulate = Color.GREEN
	sfx_passed.play()
	feedback_label.show()
	continue_btn.text = "Continue"
	continue_btn.pressed.disconnect(_on_continue_button_pressed)
	continue_btn.pressed.connect(_close_lesson)

func _on_lesson_failed():
	# Restart the lesson — must be perfect!
	feedback_label.text = "You made mistakes. Try again!"
	feedback_label.modulate = Color.RED
	feedback_label.show()
	continue_btn.text = "Try Again"
	continue_btn.pressed.disconnect(_on_continue_button_pressed)
	continue_btn.pressed.connect(_restart_lesson)

func _restart_lesson():
	current_question_index = 0
	mistakes = 0
	continue_btn.pressed.disconnect(_restart_lesson)
	continue_btn.pressed.connect(_on_continue_button_pressed)
	load_question()

func _close_lesson():
	Gamedata.CAT_SPANISH_LEARNED = true
	Dialogic.VAR.set_variable("PLAYED_DUOLINGO", true)
	scene_finished.emit()
	#queue_free()
