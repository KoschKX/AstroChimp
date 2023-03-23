extends KinematicBody2D

export (int) var gravity = 4000
var velocity = Vector2.ZERO
var time_delta = 0
var current_planet: Node

var planets: Array

func _ready():
	planets = get_node("/root/MainLevel/Planets").get_children()
	current_planet = planets[0]
	_get_closest_planet(current_planet)
	_start_closest_planet_timer()
	$AnimatedSprite.play("Idle")
#func _process(delta):
#	pass

#func _physics_process(delta):
	#time_delta += delta
	
	#var gravity_dir = current_planet.global_transform.origin - global_transform.origin
	#rotation = gravity_dir.angle() - PI/2
	
	#Physics2DServer.area_set_param(current_planet.get_node("Orbit").space, Physics2DServer.AREA_PARAM_GRAVITY_VECTOR, gravity_dir*2000)
		
	#print(gravity_dir.normalized())
	#Physics2DServer.area_set_param(get_world_2d().space, Physics2DServer.AREA_PARAM_GRAVITY_VECTOR, gravity_dir.normalized())
	
	#current_planet.get_node("Orbit").gravity_vec = gravity_dir
	#velocity.y += gravity * delta
	
	#var snap = transform.y * 128
	#velocity = move_and_slide_with_snap(velocity.rotated(rotation), snap, -transform.y, false, 2, PI/3)
	#velocity = velocity.rotated(-rotation)

func _get_closest_planet(smallest):
	var new_smallest = smallest
	var did_change = false
	
	for planet in planets:
		if !new_smallest:
			new_smallest = planet

		if global_position.distance_to(planet.global_position) < global_position.distance_to(new_smallest.global_position):
			new_smallest = planet

	if new_smallest != current_planet:
		velocity.y = 1200
		
	current_planet = new_smallest

func _start_closest_planet_timer():
	var timer = Timer.new()
	timer.wait_time = 0.1
	timer.connect("timeout", self, "_get_closest_planet", [current_planet])
	add_child(timer)
	timer.start()
