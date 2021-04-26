extends KinematicBody2D

export var move_speed = 10
export var jump_force = 50
export var carryng_jump_force = 50

var gravity_direction = Vector2.UP
var top_limit = -50

var direction := Vector2.ZERO
var velocity := Vector2.ZERO

var is_carrying = false

func _ready():
	Globals.player = self

func _physics_process(delta):
	_update(delta)

func _update(_delta):
	# Remove 
	if global_position.y < top_limit:
		_reset()
	
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		if collision.collider.name == "Spikes":
			_reset()
	
	direction.x = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
	velocity.x = direction.x * move_speed
	
	if is_on_ceiling():
		velocity.y = 0
	
	if is_on_floor():
		velocity.y = 0
		if Input.is_action_pressed("jump"):
			var jf = jump_force if not is_carrying else carryng_jump_force
			velocity.y -= jf * gravity_direction.y
	else:
		velocity.y += Globals.gravity * gravity_direction.y
		velocity.y = clamp(velocity.y, -400, 400)
	
	if is_carrying:
		if Input.is_action_pressed("throw"):
			if direction.x != 0:
				Globals.treasure.throw(direction)
				change_carry_status()
			else:
				Globals.treasure.put()
				change_carry_status()
	
	var _mns = move_and_slide(velocity, -gravity_direction)

func _reset():
	Globals.root.emit_signal("reset")
	set_physics_process(false)

func change_carry_status():
	is_carrying = !is_carrying
	velocity.y = 0
	gravity_direction = - gravity_direction
