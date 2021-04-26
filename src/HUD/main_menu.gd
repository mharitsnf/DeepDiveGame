extends Control

func _ready():
	Globals.current_level = self

func _physics_process(_delta):
	if Input.is_action_pressed("jump"):
		Globals.root.change_level_to("res://src/levels/Level1.tscn")
		set_physics_process(false)
