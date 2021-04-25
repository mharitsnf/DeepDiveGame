extends Area2D

func _ready():
	yield(get_tree(), "idle_frame")
	connect("body_entered", Globals.root, "_on_body_entered_exit")
	connect("body_exited", Globals.root, "_on_body_exited_exit")

