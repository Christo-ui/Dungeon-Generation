extends GridMap


# Called when the node enters the scene tree for the first time.
func _ready():
	var torchLocations = []
	torchLocations = get_used_cells_by_item(8)
	
	for pos in torchLocations:
		var particles = preload("res://Scenes/Tiles/torch_particles.tscn").instantiate()
		particles.position = Vector3(pos.x * 2 + 1, pos.y * 2, pos.z * 2 + .2)
		add_child(particles)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
