extends CharacterBody3D


@onready var camera_mount = $camera_mount
@onready var animation_player = $visuals/mixamo_base/AnimationPlayer
@export var sens_horizontal: float = 0.2
@export var sens_vertical: float = 0.2
@onready var visuals = $visuals


const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var walk_speed: float = 3.0
var run_speed: float = 5.0
var is_running: bool = false
var is_locked: bool = false
var SPEED = 3.0

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * sens_horizontal))
		camera_mount.rotate_x(deg_to_rad(-event.relative.y))
		if camera_mount.rotation_degrees[0] > 60 :
			camera_mount.rotation_degrees[0] = 60
		if camera_mount.rotation_degrees[0] < -60 :
			camera_mount.rotation_degrees[0] = -60
			
func _physics_process(delta):

	if !animation_player.is_playing():
		is_locked = false
		
	if Input.is_action_just_pressed("kick"):
		if animation_player.current_animation != "kick":
			animation_player.play("kick")
			is_locked = true
	
	if Input.is_action_pressed("run"):
		SPEED = run_speed
		is_running = true
		#var run_direction = (transform.basis * Vector3(0, 0, -1)).normalized()
		#velocity.x = run_direction.x * SPEED
		#velocity.z = run_direction.z * SPEED
		#move_and_slide()
	else:
		SPEED = walk_speed	
		is_running = false
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "up", "down")

	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		if !is_locked:
			
			if is_running:
				if animation_player.current_animation != "running":
					animation_player.play("running")
					
			else:
					if animation_player.current_animation != "walking":
						animation_player.play("walking")
						
			visuals.look_at(position + direction)
		
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		
	else:
		if !is_locked:
			if animation_player.current_animation != "idle":
				animation_player.play("idle")
		velocity = Vector3.ZERO

	if !is_locked:
		move_and_slide()
