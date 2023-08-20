extends KinematicBody2D

export (int) var speed = 1200
export (int) var jump_force = -2500
export (int) var booster_force = -3000
export (int,0,100) var gravity_scale = 50
export (int,0,200) var inertia = 100

export (bool) var can_pick = true

var gravity_dir

var velocity = Vector2.ZERO
var move_velocity = Vector2.ZERO
var is_carrying = false
var is_walking = false
var is_running = false
var is_jumping = false
var is_pushing = false
var is_grounded = false
var is_onpushable = false
var planets: Array
var current_planet: Node
var current_orbit: Node
var time_delta = 0
var canPick = false

var debug_line = Vector2.ZERO

func _ready():
	planets = get_node("/root/MainLevel/Planets").get_children()
	current_planet = planets[0]
	current_orbit = current_planet.get_node("Orbit")
	_find_nearest_planet(current_planet)
	
func get_input():
	canPick = true
	is_walking = false
	move_velocity.x = 0
	if Input.is_action_pressed("walk_right"):
		move_velocity.x += speed
		is_walking = true
		$AnimatedSprite.flip_h = false
		if Input.is_action_pressed("ui_run"):
			move_velocity.x += speed *1.5
			$AnimatedSprite.play("Run")
			is_walking = false
			is_running = true
		else: 
			$AnimatedSprite.play("Walk")	
	elif Input.is_action_pressed("walk_left"):
		move_velocity.x -= speed
		$AnimatedSprite.flip_h = true
		is_walking = true
		if Input.is_action_pressed("ui_run"):
			move_velocity.x -= speed *1.5
			$AnimatedSprite.play("Run")
			is_walking = false
			is_running = true
		else: 
			$AnimatedSprite.play("Walk")
	else:
		$AnimatedSprite.play("Walk")
		$AnimatedSprite.playing = false
		is_walking = false
		is_running = false
		
	if is_on_floor() == false:
		if is_pushing:
			$AnimatedSprite.play("Walk")
		else:
			$AnimatedSprite.play("Jump")
		is_walking = false
		is_running = false
		
	#else:
		#$AnimatedSprite.play("Walk")

const GRAVITY = 0.00000000000666726
func newtonian_gravity(delta, obj_1, obj_2):
	obj_1.velocity += (obj_2.global_transform.origin\
		- obj_1.global_transform.origin).normalized()\
		* GRAVITY * obj_2.mass\
		/ pow((obj_2.global_transform.origin.\
		distance_to(obj_1.global_transform.origin)), 2) * delta
	obj_1.move_and_slide(obj_1.velocity, Vector2.DOWN)

func _draw():
	draw_line(Vector2(0,0), debug_line*1000, Color(255, 0, 0), 1)
	

func getAxis(down, axis):
	if axis==0:
		return down.rotated(deg2rad(-90))
	if axis==1:
		return down
		
func _physics_process(delta):
	get_input()
	
	time_delta += delta

	var down = (current_orbit.gravity_vec - transform.origin).normalized() 
	# down = Vector2.DOWN
	rotation = down.angle() - PI/2

	is_pushing=false
	is_onpushable=false
	is_grounded=false
	
	var floor_normal=get_floor_normal().rotated(-rotation)
	
	if !is_jumping and velocity:
				
		for c in get_slide_count():
			var col = get_slide_collision(c)
			if col.get_collider() is RigidBody2D && col.collider.is_in_group("Pushables"):
				
				# PUSH 
				var cpos = col.position - col.collider.position;
				var push_dir = position.direction_to(cpos)
				var push_dist = col.normal.distance_to(push_dir);
				#if push_dist < 1.5:
				var push_force=inertia;
				is_pushing=true
				col.collider.apply_central_impulse(-col.normal * push_force)
				#if move_velocity.x>0:
					#col.collider.apply_central_impulse(getAxis(down,0) * push_force)
				#elif move_velocity.x<0:
					#col.collider.apply_central_impulse(-getAxis(down,0) * push_force)
				#else:
					#is_onpushable=true

	if !is_on_wall():
		#print("wall")
		pass
		
	print(is_pushing)
		
	move_velocity.y+=(current_orbit.gravity * delta) * gravity_scale
	
	velocity = getAxis(down, 0) * move_velocity.x
	velocity += getAxis(down, 1) * move_velocity.y

	var snap = getAxis(down, 1) * 32 if !is_jumping else Vector2.ZERO

	velocity = move_and_slide_with_snap(velocity, snap, -getAxis(down, 1), true, 4, deg2rad(50), false)
	
	if is_on_floor():
		move_velocity = velocity.rotated(-rotation)

	#debug_line=velocity.rotated(-rotation)
	#update()
	
	if is_on_floor():
		is_jumping = false
		if Input.is_action_just_pressed("jump"):
			is_jumping = true
			move_velocity.y = jump_force
			$AnimatedSprite.play("Jump")
		else:
			is_grounded=true
	else:
		if Input.is_action_just_pressed("jump"):
			move_velocity.y += booster_force
	
	
	

func _find_nearest_planet(smallest):
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
