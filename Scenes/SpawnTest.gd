extends Node2D

var sheepScene = preload("res://Scenes/Sheep.tscn")
var sheepArray = []
var screen_dimension
var population = floor(rand_range(1,26))
onready var sheepSpawner = $SheepSpawner


func _ready():
	screen_dimension = OS.get_window_size()
	var rand = RandomNumberGenerator.new()
	for i in range(0, population):
		rand.randomize()
		_create_sheep(rand.randf() * screen_dimension.x, rand.randf() * screen_dimension.y)


func _create_sheep(x, y):
	var shep = sheepScene.instance()
	shep.position.y = y
	shep.position.x = x
	sheepArray.append(shep)
	sheepSpawner.add_child(shep)
	
