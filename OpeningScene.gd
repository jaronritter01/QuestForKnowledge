extends Node2D


func _ready():
	if not $AudioStreamPlayer.playing:
		$AudioStreamPlayer.play()

func _on_ChangeSceneBtn_pressed():
	if not $ClickSound.playing:
		$ClickSound.play()
	get_tree().change_scene("res://BaseLevel.tscn")
