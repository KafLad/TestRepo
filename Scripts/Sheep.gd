extends KinematicBody2D

var movement = Vector2()
var tempState = 0
var state = 0
#0: Nothing, 1: right, 2: left, 3: down, 4: up, 5: r&d, 6: r&u, 7: l&d, 8: l&u
var movementsWithoutRest = 0
var restChance = 0
var restTimer = 0

func _physics_process(delta):
	if state == 0:
		movement.x = 0
		movement.y = 0
	elif state == 1:
		movement.x = 100
		movement.y = 0
	elif state == 2:
		movement.x = -100
		movement.y = 0
	elif state == 3:
		movement.x = 0
		movement.y = 100
	elif state == 4:
		movement.x = 0
		movement.y = -100
	elif state == 5:
		movement.x = 100
		movement.y = 100
	elif state == 6:
		movement.x = 100
		movement.y = -100
	elif state == 7:
		movement.x = -100
		movement.y = 100
	elif state == 8:
		movement.x = -100
		movement.y = -100
	move_and_slide(movement, Vector2(0,-1))

func _on_Timer_timeout():
	tempState = floor(rand_range(0,9))
	if tempState != 0:
		if movementsWithoutRest > 0:
			restChance += 0.25
		movementsWithoutRest += 1
	elif tempState == 0:
		movementsWithoutRest = 0
		restChance = 0
		restTimer = floor(rand_range(1,5))
	if restChance != 0:
		tempState = (floor(rand_range(0,9)) * restChance)
	if restChance == 1:
		tempState = 0
		restTimer -= 1
	
