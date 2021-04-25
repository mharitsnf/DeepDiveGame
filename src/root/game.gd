extends Node

signal reset

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
		_change_level()

func _on_body_exited_exit(body):
	if body.name == "Player": is_player_inside = false
	if body.name == "Treasure": is_treasure_inside = false

func _change_level():
	var anim_player : AnimationPlayer = Globals.screen.get_node("AnimationPlayer")
	
	# Close curtain
	anim_player.play("close curtain")
	yield(anim_player, "animation_finished")
	
	# Get current path
	var next_level_path = Globals.current_level.next_level
	
	# Remove current level from tree
	Globals.current_level.queue_free()
	
	# Create new instance and attach it to the viewport again
	# once added, the level will automatically set itself as the current level
	var next_level_new_instance = load(next_level_path).instance()
	Globals.viewport.add_child(next_level_new_instance)
	
	yield(get_tree().create_timer(.4), "timeout")
	
	anim_player.play("open curtain")
	yield(anim_player, "animation_finished")

func _on_reset():
	var anim_player : AnimationPlayer = Globals.screen.get_node("AnimationPlayer")
	
	# Close curtain
	anim_player.play("close curtain")
	yield(anim_player, "animation_finished")
	
	# Get current path
	var curr_level_path = Globals.current_level.source_path
	
	# Remove current level from tree
	Globals.current_level.queue_free()
	
	# Create new instance and attach it to the viewport again
	# once added, the level will automatically set itself as the current level
	var curr_level_new_instance = load(curr_level_path).instance()
	Globals.viewport.add_child(curr_level_new_instance)
	
	yield(get_tree().create_timer(.4), "timeout")
	
	anim_player.play("open curtain")
	yield(anim_player, "animation_finished")

func _unused():
	emit_signal("reset")
