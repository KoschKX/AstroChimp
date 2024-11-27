extends CharacterBody2D

@export var speed: int = 50
@export var jump_force: int = -1000
@export var booster_force: int = -3000
@export var gravity_scale: float = 50.0
@export var inertia: float = 1.0

@export var can_pick: bool = true

var gravity_dir: Vector2
var veloc: Vector2 = Vector2.ZERO
var move_veloc: Vector2 = Vector2.ZERO
var is_carrying: bool = false
var is_walking: bool = false
var is_running: bool = false
var is_jumping: bool = false
var is_pushing: bool = false
var is_grounded: bool = false
var is_onpushable: bool = false
var planets: Array
var current_planet: Node
var current_orbit: Node
var time_delta: float = 0.0
var canPick: bool = false

var debug_line: Vector2 = Vector2.ZERO

func _ready() -> void:
	planets = get_node("/root/MainLevel/Planets").get_children()
	current_planet = planets[0]
	current_orbit = current_planet.get_node("Orbit")
	_find_nearest_planet(current_planet)

func get_input() -> void:
	canPick = true
	is_walking = false
	move_veloc.x = 0

	if Input.is_action_pressed("walk_right"):
		move_veloc.x += speed
		is_walking = true
		$AnimatedSprite2D.flip_h = false

		if Input.is_action_pressed("ui_run"):
			move_veloc.x += speed * 1.5
			$AnimatedSprite2D.play("Run")
			is_walking = false
			is_running = true
		else:
			$AnimatedSprite2D.play("Walk")
	elif Input.is_action_pressed("walk_left"):
		move_veloc.x -= speed
		$AnimatedSprite2D.flip_h = true
		is_walking = true

		if Input.is_action_pressed("ui_run"):
			move_veloc.x -= speed * 1.5
			$AnimatedSprite2D.play("Run")
			is_walking = false
			is_running = true
		else:
			$AnimatedSprite2D.play("Walk")
	else:
		$AnimatedSprite2D.play("Walk")
		is_walking = false
		is_running = false

	if not is_on_floor():
		if is_pushing:
			$AnimatedSprite2D.play("Walk")
		else:
			$AnimatedSprite2D.play("Jump")
		is_walking = false
		is_running = false

const GRAVITY: float = 0.00000000000666726

func newtonian_gravity(delta: float, obj_1: Node2D, obj_2: Node2D) -> void:
	obj_1.veloc += (obj_2.global_position - obj_1.global_position).normalized() \
		* GRAVITY * obj_2.mass / pow(obj_2.global_position.distance_to(obj_1.global_position), 2) * delta
	obj_1.set_velocity(obj_1.veloc)
	obj_1.set_up_direction(Vector2.DOWN)
	obj_1.move_and_slide()
	obj_1.veloc

func _draw() -> void:
	draw_line(Vector2.ZERO, debug_line * 1000, Color(1, 0, 0), 1)

func getAxis(down: Vector2, axis: int) -> Vector2:
	# GET AXIS BASED ON CENTER
	if axis == 0:
		return down.rotated(deg_to_rad(-90))
	elif axis == 1:
		return down
	return Vector2.ZERO  # Default return for invalid axis values

func _physics_process(delta: float) -> void:
	get_input()
	time_delta += delta

	# SET CENTER OF GRAVITY AND ROTATION
	var down = (current_orbit.global_position - global_position).normalized()
	rotation = down.angle() - PI / 2

	is_pushing = false
	is_onpushable = false
	is_grounded = false

	# UNROTATED FLOOR NORMAL
	var floor_normal = get_floor_normal().rotated(-rotation)

	if not is_jumping and veloc:
		for c in range(get_slide_collision_count()):
			var col = get_slide_collision(c)
			if col.get_collider() is RigidBody2D and col.get_collider().is_in_group("Pushables"):
				# PUSH
				var push_force = inertia
				is_pushing = true
				col.get_collider().apply_central_impulse(-col.get_normal() * push_force)

	# ADD GRAVITY
	move_veloc.y += (current_orbit.gravity * delta) * gravity_scale

	# ADD CONTROLLED MOVEMENT
	veloc = getAxis(down, 0) * move_veloc.x
	veloc += getAxis(down, 1) * move_veloc.y

	# MOVE AND SLIDE
	var snap = getAxis(down, 1) * 32 if not is_jumping else Vector2.ZERO
	set_velocity(veloc)
	set_up_direction(-getAxis(down, 1))
	move_and_slide()

	# UPDATE MOVE AND SLIDE VELOCITY
	if is_on_floor():
		move_veloc = veloc.rotated(-rotation)

	# DEBUG FEEDBACK
	if is_on_floor():
		is_jumping = false
		if Input.is_action_just_pressed("jump"):
			is_jumping = true
			move_veloc.y = jump_force
			$AnimatedSprite2D.play("Jump")
		else:
			is_grounded = true
	else:
		if Input.is_action_just_pressed("jump"):
			move_veloc.y += booster_force

func _find_nearest_planet(smallest: Node) -> void:
	var new_smallest = smallest

	if not is_jumping:
		return

	for planet in planets:
		if not new_smallest:
			new_smallest = planet

		if global_position.distance_to(planet.global_position) < global_position.distance_to(new_smallest.global_position):
			new_smallest = planet

	if new_smallest != current_planet:
		is_jumping = false
		veloc.y = 1200

	current_planet = new_smallest
