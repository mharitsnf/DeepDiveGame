extends Area2D

func _ready():
	yield(get_tree(), "idle_frame")
	var _e1 = connect("body_entered", Globals.root, "_on_body_entered_exit")
	var _e2 = connect("body_exited", Globals.root, "_on_body_exited_exit")

