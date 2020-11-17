extends RigidBody2D

var mousePosition = get_global_mouse_position()
var objPosition = Vector2()

func _input(event):
	if event is InputEventMouseMotion:
		mousePosition = event.position
	
func _physics_process(delta):
	position = mousePosition
