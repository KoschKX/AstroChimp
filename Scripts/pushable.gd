extends RigidBody2D

@export var gravity: int = 4000
var velocity: Vector2 = Vector2.ZERO
var time_delta: float = 0.0
var current_planet: Node
var picked: bool = false
var planets: Array

var thrown: bool = true
var thrown_tick: int = 0

var player: Node

func _ready():
	planets = get_node("/root/MainLevel/Planets").get_children()
	current_planet = planets[0]

	player = get_node("/root/MainLevel/Player")

func _physics_process(delta: float) -> void:
	if picked and not thrown:
		var sprite = player.get_node("AnimatedSprite2D") as AnimatedSprite2D
		#var rect = sprite.sprite_frames.get_frame(sprite.animation, sprite.frame).get_size() * (player.scale / 2)
		var rect = sprite.get_sprite_frames().get_frame_texture(sprite.animation, sprite.frame).get_size() * (player.scale / 2)

		self.rotation = player.rotation
		var offset = Vector2(rect.x * 0.5, 0).rotated(player.rotation)
		if sprite.flip_h:
			self.global_position = player.global_position + -offset
		else:
			self.global_position = player.global_position + offset
	elif thrown:
		var col_with_player = false
		var bodies = get_node("Area2D").get_overlapping_bodies()
		for body in bodies:
			if body.name == player.name:
				thrown_tick += 1
				col_with_player = true
		if not col_with_player:
			remove_collision_exception_with(player)
			thrown_tick = 0
			thrown = false

func _input(event: InputEvent) -> void:
	if player == null:
		return
	if Input.is_action_pressed("ui_pick"):
		var bodies = get_node("Area2D").get_overlapping_bodies()
		for body in bodies:
			if body.name == player.name and player.can_pick:
				picked = true
				player.can_pick = false
				add_collision_exception_with(player)
				player.is_carrying = true
				player.add_child(self)
	elif not Input.is_action_pressed("ui_pick") and picked:
		picked = false
		thrown = true
		player.can_pick = true
		velocity = player.velocity
		player.is_carrying = false
		var sprite = player.get_node("AnimatedSprite2D") as AnimatedSprite2D
		if not sprite.flip_h:
			var offset = Vector2(1500, -3000).rotated(player.rotation)
			print("throw right")
			apply_impulse(offset, Vector2())
		else:
			print("throw left")
			var offset = Vector2(-1500, -3000).rotated(player.rotation)
			apply_impulse(offset, Vector2())
