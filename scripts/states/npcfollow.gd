extends State
class_name NPCFollow

@export var npc: CharacterBody2D
@export var move_speed := 40.0
var player: CharacterBody2D

func enter():
	player.get_tree().get_first_node_in_group("player")


func physics_update(_delta: float):
	#var direction = player.global_position - npc.global_position
	#if direction.length
	npc.velocity = Vector2()
