extends KinematicBody2D

var CIRCLE
export(NodePath) var CIRCLE_PATH
var gdir = Vector2();
const GRAVITY = 600

const WALK_SPEED = 10
const JUMP_FORCE = 200

var velocity = Vector2()
var screen_size
var center = Vector2()


func _ready():
	screen_size = get_viewport_rect().size
	

func _physics_process(delta):
		
	if CIRCLE_PATH != null:
		CIRCLE = get_node(CIRCLE_PATH)
	if CIRCLE:
		center = CIRCLE.position;
	
	# velocity.y += delta * GRAVITY
	#velocity.x -= delta * (center.x + GRAVITY)
	# velocity.y += delta * (center.y + GRAVITY)
	
	# GET GRAVITY DIRECTION (TOWARD PLANETS CORE)
	gdir = ( CIRCLE.position - self.position ).normalized()
	
	# GET ANGLE
	var angleTo = transform.y.angle_to(gdir)
	velocity += delta * gdir * GRAVITY
	
	if Input.is_action_pressed("ui_up") and is_on_floor():
		print("jump")
		velocity += -gdir*JUMP_FORCE
		
	# ROTATE ON PLANET
	var rotationSpeed = 100
	rotate(sign(angleTo) * min(delta * rotationSpeed, abs(angleTo)))
		
	#if Input.is_action_pressed("ui_left"):
	#	velocity.x = -WALK_SPEED
	#elif Input.is_action_pressed("ui_right"):
	#	velocity.x = WALK_SPEED
	#else:
	#	velocity.x = lerp(velocity.x, 0, 0.1)
	
	var angleToX = transform.y.angle_to(gdir)
	var rot = angleToX+90;
	if Input.is_action_pressed("ui_left"):
		velocity += Vector2(sin(rot), cos(rot)) * WALK_SPEED;
	elif Input.is_action_pressed("ui_right"):
		velocity += Vector2(sin(rot), cos(rot)) * WALK_SPEED * -1;

	
	 
	velocity = move_and_slide(velocity,  Vector2.UP)

