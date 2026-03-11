extends Node

@export var sprite : AnimatedSprite2D
@onready var npc : NPC = get_owner()


func _physics_process(delta: float) -> void:
	if !npc.alive:
		return
	if npc.stunned:
		sprite.play("stunned")
		return
	if !npc.velocity:
		sprite.play("idle")
		return
	sprite.flip_h = npc.velocity.x < 0
	var animation_name = "walk"
	if npc.velocity.length() > 50:
		animation_name = "run"

	if sprite.flip_h:
		animation_name += "_left"
	else:
		animation_name += "_right"
	sprite.play(animation_name)
