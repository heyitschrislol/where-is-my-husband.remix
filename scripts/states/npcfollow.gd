extends State

@export var follow_speed := 75.0


func physics_process_state(_delta: float):

	var direction := player.global_position - npc.global_position

	var distance = direction.length()
	if distance > npc.follow_radius:
		transitioned.emit(self, "follow")
		return

	npc.velocity = direction.normalized()*follow_speed

	if distance <= npc.follow_radius:
		npc.velocity = Vector2.ZERO

	npc.move_and_slide()
