extends Control

func set_transition_texts(level_number, level_title):
	$VBoxContainer/TransitionLabel.text = "level " + str(level_number)
	$VBoxContainer/TransitionLabel2.text = level_title
