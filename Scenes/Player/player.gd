extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var Camera = Camera3D.new()

func _on_ready():
	pass

func _physics_process(_delta):
	# Add the gravity.
	#if not is_on_floor():
		#velocity += get_gravity() * delta

	velocity.y = 0
	# Handle jump.
	if Input.is_action_pressed("ui_accept"):
		velocity.y += JUMP_VELOCITY
	
	if Input.is_action_pressed("Crouch"):
		velocity.y -= JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("Move_Left", "Move_Right", "Move_Up", "Move_Down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
