extends KinematicBody2D

export var throw_speed = 100
export var jump_force = 50

var gravity_direction = Vector2.DOWN
var velocity = Vector2.ZERO

var is_carried = false

func _ready():
	Globals.treasure = self

func _physics_process(_delta):
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		if collision.collider.name == "Spikes":
			_reset()
	
	if not is_carried:
		if is_on_ceiling():
			velocity.y = 0
		
		if is_on_floor():
			velocity.y = 0
			velocity.x = 0
		else:
			velocity.y += Globals.gravity * gravity_direction.y
			velocity.y = clamp(velocity.y, -400, 400)
	else:
		global_position = Globals.player.global_position - Vector2(0, 16)
			
	var _mns = move_and_slide(velocity, - gravity_direction)

func _reset():
	Globals.root.emit_signal("reset")
	set_physics_process(false)

func throw(direction : Vector2):
	is_carried = false
	velocity.x = direction.x * throw_speed
	velocity.y -= jump_force * gravity_direction.y

func put():
	is_carried = false

func _on_Area2D_body_entered(_body):
	is_carried = true
	Globals.player.change_carry_status()
