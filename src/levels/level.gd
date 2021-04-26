extends Node2D

export (String) var source_path
export (String) var next_level
export (int) var level_number
export (String) var level_title

func _ready():
	assert(source_path)
	assert(next_level)
	
	Globals.current_level = self
