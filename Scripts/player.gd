extends KinematicBody2D

export (int) var speed = 1200
export (int) var jump_force = -2500
export (int) var booster_force = -3000
export (int,0,100) var gravity_scale = 50
export (int,0,200) var inertia = 100

var velocity = Vector2.ZERO
var is_jumping = false
var planets: Array
var current_planet: Node
var current_orbit: Node
var time_delta = 0

var debug_line = Vector2.ZERO

func _ready():
	planets = get_node("/root/MainLevel/Planets").get_children()
	current_planet = planets[0]
	current_orbit = current_planet.get_node("Orbit")
	_get_closest_planet(current_planet)
	_start_closest_planet_timer()


func get_input():
	velocity.x = 0
	if Input.is_action_pressed("walk_right"):
		velocity.x += speed
		$AnimatedSprite.play("Walk")
		$AnimatedSprite.flip_h = false
	elif Input.is_action_pressed("walk_left"):
		velocity.x -= speed
		$AnimatedSprite.play()
		$AnimatedSprite.flip_h = true
	else:
		$AnimatedSprite.playing = false
	if is_on_floor() == false:
		$AnimatedSprite.play("Jump")
	else: 
		$AnimatedSprite.play("Walk")


func _physics_process_old(delts):
	get_input();
	velocity = move_and_slide(velocity,Vector2.UP)

func _draw():
	if debug_line:
		draw_line(Vector2(0,0), debug_line, Color(255, 0, 0), 1)

func _physics_process(delta):
	get_input()
	
	time_delta += delta

	var gravity_dir = current_orbit.gravity_vec
	#rotation = (current_planet.global_transform.origin - transform.origin).angle() - PI/2
	rotation = (gravity_dir - transform.origin).angle() - PI/2
	
	velocity.y += (current_orbit.gravity  * delta) * gravity_scale
	
	#var snap = transform.y * 128 if !is_jumping else Vector2.ZERO
	var snap = transform.y * 32 if !is_jumping else Vector2.ZERO
	#var max_slope = deg2rad(slope_threshold);
	
	var col_count=0
	if velocity: # true if collided
		for c in get_slide_count():
			var col = get_slide_collision(c)
			if col.get_collider() is RigidBody2D:
				col_count+=1;
				var pos = col.position - col.collider.position;
				col.collider.apply_central_impulse(-col.normal * inertia)
	
	print(col_count)
	
	if col_count:
		velocity = move_and_slide_with_snap(velocity.rotated(rotation), snap, -transform.y, false, 4, PI/12, false)
	else:
		velocity = move_and_slide_with_snap(velocity.rotated(rotation), snap, -transform.y, true, 4, PI/2, false)
		
	velocity = velocity.rotated(-rotation)	
		
	#debug_line=transform.y * 300
	
	if is_on_floor():
		is_jumping = false
		if Input.is_action_just_pressed("jump"):
			is_jumping = true
			velocity.y = jump_force
			$AnimatedSprite.play("Jump")
	else:
		if Input.is_action_just_pressed("jump"):
			velocity.y += booster_force
			

func _get_closest_planet(smallest):
	var new_smallest = smallest
	var did_change = false
	
	if !is_jumping:
		return
	
	for planet in planets:
		if !new_smallest:
			new_smallest = planet

		if global_position.distance_to(planet.global_position) < global_position.distance_to(new_smallest.global_position):
			new_smallest = planet

	if new_smallest != current_planet:
		is_jumping = false
		velocity.y = 1200
		
	current_planet = new_smallest


func _start_closest_planet_timer():
	var timer = Timer.new()
	timer.wait_time = 0.1
	timer.connect("timeout", self, "_get_closest_planet", [current_planet])
	add_child(timer)
	timer.start()
	
