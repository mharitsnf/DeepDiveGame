extends KinematicBody2D

export var move_speed = 10
export var jump_force = 50
export var carrying_jump_force = 50
export var coyote_time_frame = 5
var current_jump_force
var falling_frame_count = 0

var is_pressed = false
var is_released = false

export var acceleration = 20
export var friction = 20

var gravity_direction = Vector2.UP
var top_limit = -50

var direction := Vector2.ZERO
var velocity := Vector2.ZERO

var is_carrying = false

func _ready():
	Globals.player = self
	var _e = Globals.root.connect("reset", self, "_on_reset")

func _physics_process(delta):
	_update(delta)

func _update(_delta):
	# Remove 
	if global_position.y < top_limit:
		Globals.root.emit_signal("reset")
		return
	
	# Reset
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		if collision.collider.name == "Spikes":
			Globals.root.emit_signal("reset")
			return
		if collision.collider.name == "TreasurePass":
			Globals.root.emit_signal("reset")
			return
	
	# Reset manually
	if Input.is_action_pressed("ui_cancel"):
		Globals.root.emit_signal("reset")
		return
	
	direction.x = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
	if direction.x != 0:
		_apply_movement()
	else:
		_apply_friction()
	
	if is_on_floor():
		current_jump_force = jump_force if not is_carrying else carrying_jump_force
		is_pressed = false
		is_released = false
		falling_frame_count = 0
		
		velocity.y = Globals.gravity * gravity_direction.y
		
		if Input.is_action_just_pressed("jump"):
			is_pressed = true
			velocity.y -= current_jump_force * gravity_direction.y
	else:
		if is_pressed and not is_released:
			if Input.is_action_just_released("jump") or is_on_ceiling():
				is_released = true
				
			if current_jump_force < 1:
				is_released = true
			
			current_jump_force *= .5
			velocity.y -= current_jump_force * gravity_direction.y
			
		else:
			falling_frame_count += 1
			if is_on_ceiling(): velocity.y = 0
			if not is_pressed and Input.is_action_just_pressed("jump") and falling_frame_count <= coyote_time_frame:
				velocity.y = Globals.gravity * gravity_direction.y
				velocity.y -= current_jump_force * gravity_direction.y
				is_pressed = true
				return
				
			
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

func _on_reset():
	set_physics_process(false)

func _apply_movement():
	if abs(velocity.x) > move_speed:
		velocity.x = sign(velocity.x) * move_speed
	else:
		velocity.x += direction.x * acceleration

func _apply_friction():
	if abs(velocity.x) > friction:
		velocity.x -= sign(velocity.x) * friction
	else:
		velocity.x = 0

func change_carry_status():
	is_carrying = !is_carrying
	velocity.y = 0
	gravity_direction = - gravity_direction
