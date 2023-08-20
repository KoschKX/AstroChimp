extends RigidBody2D

export (int) var gravity = 4000
var velocity = Vector2.ZERO
var time_delta = 0
var current_planet: Node
var picked = false
var planets: Array

var thrown=true;
var thrown_tick=0;

var player;

func _ready():
	planets = get_node("/root/MainLevel/Planets").get_children()
	current_planet = planets[0]
	
	player = get_node("/root/MainLevel/Player");

#func _process(delta):
#	pass

func _physics_process(delta):
	if picked == true and thrown==false:
		var sprite = player.get_node("AnimatedSprite");
		var rect = sprite.get_sprite_frames().get_frame(sprite.get_animation(),sprite.frame).get_size()*(player.scale/2)
		self.rotation = player.rotation
		var offset=Vector2(rect.x*0.5,0).rotated( player.rotation)
		if sprite.flip_h == true:
			self.global_position = Vector2(player.global_position.x,player.global_position.y)+-offset
		else:
			self.global_position = Vector2(player.global_position.x,player.global_position.y)+offset
	elif thrown == true:
		var col_w_player=false;
		var bodies = self.get_node("Area2D").get_overlapping_bodies()
		for body in bodies:
			if body.name == player.name:
				thrown_tick+=1
				col_w_player=true;
		if col_w_player==false:
			self.remove_collision_exception_with(player)
			thrown_tick=0;
			thrown=false;

func _input(event):
	if player==null:
		return;
	if Input.is_action_pressed("ui_pick"):
		var bodies = self.get_node("Area2D").get_overlapping_bodies()
		for body in bodies:
			#print(body.name+" : "+player.name)
			if body.name == player.name and player.can_pick == true:
				if player.can_pick == true:
					picked = true
					player.can_pick = false
					self.add_collision_exception_with(player)
					player.is_carrying=true
					player.add_child(self)
	if !Input.is_action_pressed("ui_pick") and picked == true:
		picked = false
		thrown = true
		player.can_pick = true
		velocity=player.velocity
		player.is_carrying=false
		if player.get_node("AnimatedSprite").flip_h == false:
			var offset=Vector2(1500,-3000).rotated(player.rotation)
			print("throw right")
			apply_impulse(Vector2(), offset)
		else:
			print("throw left")
			var offset=Vector2(-1500,-3000).rotated(player.rotation)
			apply_impulse(Vector2(), offset)
	
