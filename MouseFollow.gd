extends Area2D

var mousePosition = get_global_mouse_position()
var areaPosition = Vector2()

func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	print(mousePosition)
