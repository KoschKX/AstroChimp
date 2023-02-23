extends KinematicBody2D

const SPEED = 20
var velocity = Vector2()

func _ready():
	rotation = PI
	rotation_degrees = 0

func _process(delta):

	var rotate_left = Input.is_action_pressed("ui_left");
	var rotate_right = Input.is_action_pressed("ui_right");

	if rotate_left:
		rotation_degrees -= SPEED * delta;

	if rotate_right:
		rotation_degrees += SPEED * delta;

	velocity = move_and_slide(velocity)
