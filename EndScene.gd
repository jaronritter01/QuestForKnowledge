extends Node2D

func _on_RestartBtn_pressed():
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://BaseLevel.tscn")


func _on_ExitBtn_pressed():
	get_tree().quit()
