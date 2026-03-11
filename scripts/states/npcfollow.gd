extends State

@export var chase_speed := 75.0


func physics_process_state(_delta: float):

	var direction := player.global_position - npc.global_position

	var distance = direction.length()
	if distance > npc.chase_radius:
		transitioned.emit(self, "idle")
		return

	npc.velocity = direction.normalized()*chase_speed

	if distance <= npc.follow_radius:
		npc.velocity = Vector2.ZERO

	npc.move_and_slide()
