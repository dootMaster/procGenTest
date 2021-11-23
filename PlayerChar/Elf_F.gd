extends KinematicBody2D

const ACCELERATION = 500
const MAX_SPEED = 80
const FRICTION = 500

var velocity = Vector2.ZERO
onready var animate = $AnimatedSprite

func _ready():
	animate.play('idle')

func _physics_process(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	
	if input_vector != Vector2.ZERO:
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
		animate.play('run')
		if input_vector.x > 0:
			animate.flip_h = false
		elif input_vector.x < 0:
			animate.flip_h = true 
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
		animate.play('idle')
	
	velocity = move_and_slide(velocity)
