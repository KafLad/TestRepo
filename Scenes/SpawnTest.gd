extends Node2D

var sheepScene = preload("res://Scenes/Sheep.tscn")
var sheepArray = []
var screen_dimension
var flockmates = []#Array of all local flockmates of the current sheep
var population = floor(rand_range(1,26))
var max_speed = 25 #max speed
var max_force = 1 #max force acted upon a sheep per frame
var shepard_radius = 200 #radius in which seek-force takes effect.
var brake_radius = 100 #radius around shepard. sheep in this radius will slow down. Set to 0 to disable
var comfort_zone = 64 #maximum radius in which sheep will respond to local flockmates.
						# This should at least be bigger than the sheep's collisionshape
var field_of_view = .75 #view angle [-1 = 360°, 0 = 180°, 1 = 0°] so at 1 the sheep will practically be blind
onready var sheepSpawner = $SheepSpawner

#These variables determine how forces are weighted against each other. 0 turns a force off
var master_factor = 1 #handles intensity of all forces except friction
var seek_factor = 0 #desire to seek the shepard
var separation_factor = 0.5 #desire to gain distance to other sheep
var alignment_factor = 0.5 #desire to align movement with other sheep
var cohesion_factor = 0.5 #desire to find average position of other sheep
var random_factor = 0 #desire to fuck around
var friction_factor = 0.01 #percentage of velocity loss per frame

var current_sheep

#Velocity - the actual movement
var vel

#Acceleration/Desire - movement's target
var acc
# the acceleration-vector will be processed by the various steering functions
# it describes the desired target of a sheep

var steer 
#Steering = (acc - vel) ; movement's change over time
#this bad boy will be added to the current velocity in the end when all the math is done

var pos  #Position - Shortcut for sheep.get_global_position()
var dir  #Direction - Shortcut for vel.angle()

#setters and getters for sheep's individual velocity
func get_vel():
	return vel

func set_vel(v):
	vel = v

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
	

func _physics_process(delta):
	for sheep in sheepArray:
		current_sheep = sheep
		var wr = weakref(sheep)
		if !wr.get_ref():
			continue
			
		_get_variables(sheep)
		
		calc_master(sheep)
		
		#check if any forces have been calced. if not: do nothing
		if steer != Vector2.ZERO:
			apply_forces()
			#It is important to limit the Velocity. Otherwise the sheep will reach light speed in no time...
			sheep.set_vel(vel.clamped(max_speed*.5))
		else:
			continue
		update()
		

func _get_variables(sheep):
	pos = sheep.get_global_position()
	vel = sheep.get_vel()
	dir = vel.angle()
	acc = Vector2.ZERO
	steer = Vector2.ZERO
	flockmates = get_flockmates(sheep)

func get_flockmates(sheep):
	var fm = []
	for s in sheepArray:
		var wr = weakref(s)
		if  !wr.get_ref():
			return
		var spos = s.get_global_position()
		if pos.distance_to(spos) <= comfort_zone && \
		pos.distance_to(spos) > 0:
			var nbdir = (spos - pos).normalized()
			if nbdir.dot(vel.normalized()) >= field_of_view:
				if s != null:
					fm.append(s)
	return fm
		
		
func calc_master(sheep):
	if flockmates && !flockmates.empty():
		sheep.flocking = true
		calc_separation()
		calc_alignment()
		calc_cohesion()
	else:
		# sheep.flocking = false
		pass
func calc_separation():
	if separation_factor == 0:
		return
	
	var average = Vector2.ZERO
	
	for f in flockmates:
		average += f.get_global_position() - pos
	average /= flockmates.size()
	
	acc = -average #notice that minus? That's Repulsion.
	steer += acc * separation_factor

#Alignment finds the average direction all local flockmates are moving.
#Combine this with a pinch of Separation if you want a bird-like movement-pattern
func calc_alignment():
	if alignment_factor == 0:
		return
	
	var average = Vector2.ZERO
	
	for f in flockmates:
		average += f.get_vel()
	average /= flockmates.size()
	
	acc = average
	steer += acc * alignment_factor


#Cohesion finds the Vector for the average position of all local flockmates.
#Crank this up if you want your sheep to move more streamlined with less traffic jam
func calc_cohesion():
	if cohesion_factor == 0:
		return
	
	var average = Vector2.ZERO
	
	for f in flockmates:
		average += f.get_global_position() - pos
	average /= flockmates.size()
	
	acc = average
	steer += acc * cohesion_factor
	
	
func apply_forces():
	#this force will be stored inside the sheep-scene for drawing purposes.
	current_sheep.force = steer*master_factor
	
	
	vel += steer.clamped(max_force*master_factor)
	
	#friction gets applied directly to velocity.
	vel *= 1-friction_factor
		
		
		
		
