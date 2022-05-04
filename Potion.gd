extends Node2D

var is_on_screen = false
onready var currentScene = get_tree().current_scene
onready var hud = get_tree().get_root().get_node(currentScene.name).get_node("HUD")

func _ready():
	$AnimationPlayer.play("Float")

func _on_Area2D_body_entered(body):
	if body.name == "Player":
		body.potion_count += 1
		hud.get_node("PotionCountLabel").text = str(body.potion_count)
		### not playing idk why
		if not $AudioStreamPlayer.playing:
			$AudioStreamPlayer.play()
		queue_free()


func _on_VisibilityNotifier2D_screen_entered():
	is_on_screen = true


func _on_VisibilityNotifier2D_screen_exited():
	is_on_screen = false
