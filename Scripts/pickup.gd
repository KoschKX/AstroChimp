extends Node

var picked = false

func _physics_process(delta):
	if picked == true:
		self.position = get_node("res://Characters/Player.tscn").global_position2D

func _input(event):
	if Input.is_action_just_pressed("ui_pick"):
		var bodies = $Area2D.get_overlapping_bodies()
		for body in bodies:
			if body.name == "Player" and get_node("res://Characters/Player.tscn").canPick == true:
				picked = true
				get_node("res://Characters/Player.tscn").canPick = false
	if Input.is_action_just_pressed("ui_drop") and picked == true:
		picked = false
		get_node("res://Characters/Player.tscn").canPick = true
		if get_node("res://Characters/Player.tscn").sprite.flip_h == false:
			apply_impulse(Vector2(90, -10), Vector2())
		else:
			apply_impulse(Vector2(-90, -10), Vector2())
	if Input.is_action_just_pressed("ui_throw") and picked == true:
		picked = false
		get_node("res://Characters/Player.tscn").canPick = true
		if get_node("res://Characters/Player.tscn").sprite.flip_h == false:
			apply_impulse(Vector2(150, -200), Vector2())
		else:
			apply_impulse(Vector2(-150, -200), Vector2())
