extends CharacterBody2D

@export var speed: int = 1200
@export var jump_speed: int = -1800
@export var gravity: int = 4000

var velocity = Vector2.ZERO
var is_jumping = false
var planets: Array
var current_planet: Node
var time_delta = 0


func _ready():
	planets = get_node("/root/MainLevel/Planets").get_children()
	current_planet = planets[0]
	_get_closest_planet(current_planet)
	_start_closest_planet_timer()


func get_input():
	velocity.x = 0
	if Input.is_action_pressed("walk_right"):
		velocity.x += speed
		$AnimatedSprite2D.play()
		$AnimatedSprite2D.flip_h = false
	elif Input.is_action_pressed("walk_left"):
		velocity.x -= speed
		$AnimatedSprite2D.play()
		$AnimatedSprite2D.flip_h = true
	else:
		$AnimatedSprite2D.playing = false


func _physics_process(delta):
	get_input()
	
	time_delta += delta

	var gravity_dir = current_planet.global_transform.origin - global_transform.origin
	rotation = gravity_dir.angle() - PI/2
	
	velocity.y += gravity * delta
	var snap = transform.y * 128 if !is_jumping else Vector2.ZERO
	set_velocity(velocity.rotated(rotation))
	# TODOConverter3To4 looks that snap in Godot 4 is float, not vector like in Godot 3 - previous value `snap`
	set_up_direction(-transform.y)
	set_floor_stop_on_slope_enabled(false)
	set_max_slides(2)
	set_floor_max_angle(PI/3)
	move_and_slide()
	velocity = velocity
	velocity = velocity.rotated(-rotation)

	if is_on_floor():
		is_jumping = false
		if Input.is_action_just_pressed("jump"):
			is_jumping = true
			velocity.y = jump_speed

