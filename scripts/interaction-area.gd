extends Area2D
class_name InteractionArea

@export var action_name: String = "interact"

var interact: Callable = func():
	pass


func _on_body_entered(_body: Node2D) -> void:
	if not _body.is_in_group("player"):
		return
	InteractionManager.register_area(self)

func _on_body_exited(_body: Node2D) -> void:
	if not _body.is_in_group("player"):
		return
	InteractionManager.unregister_area(self)
