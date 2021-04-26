extends Node

signal reset
signal unload_done

const LEVEL_TRANSITION = preload("res://src/HUD/LevelTransition.tscn")

var is_treasure_inside = false
var is_player_inside = false

func _ready():
	Globals.root = self
	Globals.screen = $Screen
	Globals.viewport = $ViewportContainer/Viewport
	
	var _e = connect("reset", self, "_on_reset")

func _on_body_entered_exit(body):
	if body.name == "Player": is_player_inside = true
	if body.name == "Treasure": is_treasure_inside = true
	
	if is_player_inside and is_treasure_inside:
		_next_level()

func _on_body_exited_exit(body):
	if body.name == "Player": is_player_inside = false
	if body.name == "Treasure": is_treasure_inside = false

func change_level_to(path, with_transition = true):
	_unload_level()
	yield(self, "unload_done")
	_load_level(path, with_transition)

func _next_level():
	# Get current path
	var next_level_path = Globals.current_level.next_level
	_unload_level()
	yield(self, "unload_done")
	_load_level(next_level_path)

func _on_reset():
	# Get current path
	var curr_level_path = Globals.current_level.source_path
	_unload_level()
	yield(self, "unload_done")
	_load_level(curr_level_path, false)

func _unload_level():
	var anim_player : AnimationPlayer = Globals.screen.get_node("AnimationPlayer")
	
	# Close curtain
	anim_player.play("close curtain")
	yield(anim_player, "animation_finished")
	
	# Remove current level from tree
	Globals.current_level.queue_free()
	yield(get_tree(), "idle_frame")
	emit_signal("unload_done")

func _load_level(level_path, with_transition = true):
	var anim_player : AnimationPlayer = Globals.screen.get_node("AnimationPlayer")
	
	# Get current path
	var next_level = load(level_path).instance()
	
	if with_transition:
		var level_transition = LEVEL_TRANSITION.instance()
		if next_level.name != "Finish":
			level_transition.set_transition_texts(next_level.level_number, next_level.level_title)
			
			# Add level transition
			Globals.viewport.add_child(level_transition)
			yield(get_tree(), "idle_frame")
			
			# Add open curtain
			anim_player.play("open curtain")
			yield(anim_player, "animation_finished")
			
			# Wait for 3 secs
			yield(get_tree().create_timer(3), "timeout")
			
			# Close curtain again
			anim_player.play("close curtain")
			yield(anim_player, "animation_finished")
			
		# Delete level transition
		level_transition.queue_free()
		yield(get_tree(), "idle_frame")
	
	# Add actual level
	Globals.viewport.add_child(next_level)
	yield(get_tree(), "idle_frame")
	
	# Open curtain
	anim_player.play("open curtain")
	yield(anim_player, "animation_finished")

func _unused():
	emit_signal("reset")
