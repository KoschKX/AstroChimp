extends RigidBody2D

export (int) var gravity = 4000
var velocity = Vector2.ZERO
var time_delta = 0
var current_planet: Node
var picked = false
var planets: Array

var player;

func _ready():
	planets = get_node("/root/MainLevel/Planets").get_children()
	current_planet = planets[0]
	_get_closest_planet(current_planet)
	_start_closest_planet_timer()
	
	player = get_node("/root/MainLevel/Player");

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

#PICK UP SHIT
func _physics_process(delta):
	if picked == true:
		var sprite = player.get_node("AnimatedSprite");
		var rect = sprite.get_sprite_frames().get_frame(sprite.get_animation(),sprite.frame).get_size()*(player.scale/2)
		self.rotation = player.rotation
		if sprite.flip_h == true:
			self.global_position = Vector2(player.global_position.x-rect.x,player.global_position.y)
		else:
			self.global_position = Vector2(player.global_position.x+rect.x,player.global_position.y)

func _input(event):
	
	if player==null:
		return;
	if Input.is_action_pressed("ui_pick"):
		var bodies = self.get_node("Area2D").get_overlapping_bodies()
		for body in bodies:
			if body.name == player.name and player.can_pick == true:
				if player.can_pick == true:
					picked = true
					player.can_pick = false
					self.add_collision_exception_with(player)
					player.add_child(self)
	if !Input.is_action_pressed("ui_pick") and picked == true:
		picked = false
		player.can_pick = true
		self.remove_collision_exception_with(player)
		print("drop")
		if player.get_node("AnimatedSprite").flip_h == false:
			apply_impulse(Vector2(), Vector2(90, -10))
		else:
			apply_impulse(Vector2(), Vector2(-90, -10))
	if Input.is_action_pressed("ui_throw") and picked == true:
		print("throw")
		picked = false
		player.can_pick = true
		mode = MODE_RIGID
		if player.get_node("AnimatedSprite").flip_h == false:
			apply_impulse(Vector2(), Vector2(150, -200))
		else:
			apply_impulse(Vector2(), Vector2(-150, -200))
	#print("hello")
