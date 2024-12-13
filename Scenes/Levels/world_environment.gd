extends WorldEnvironment

var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	environment.sky_rotation.y = rng.randi_range(30, 70)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	environment.sky_rotation.y += + 0.00006 
	
	if environment.sky_rotation.y >= 360:
		environment.sky_rotation.y = 0
