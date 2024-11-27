extends Camera2D


# Called when the node enters the scene tree for the first time.
func _ready():
	# Ensure default zoom level
	# zoom = Vector2(1, 1)
	
	# Debug current camera settings
	print("Camera zoom: ", zoom)
	print("Viewport size: ", get_viewport_rect().size)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
