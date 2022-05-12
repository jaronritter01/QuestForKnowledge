extends Node2D

func _ready():
	if not $AudioStreamPlayer.playing:
		$AudioStreamPlayer.play()
