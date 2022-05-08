extends Node2D

var is_on_screen = false
onready var currentScene = get_tree().current_scene
onready var hud = get_tree().get_root().get_node(currentScene.name).get_node("HUD")

func _ready():
	$AnimationPlayer.play("Hover")



func _on_Area2D_body_entered(body):
	if body.name == "Player":
		$Sprite/Area2D.set_collision_layer_bit(2, false)
		$Sprite/Area2D.set_collision_mask_bit(0, false)
		body.staff_count += 1
		hud.get_node("StaffCountLabel").text = str(body.staff_count)
		### not playing idk why
		if not $AudioStreamPlayer.playing:
			$AudioStreamPlayer.play()
		$AnimationPlayer.play("Collect")
		$CollectTimer.start()


func _on_CollectTimer_timeout():
	print("here")
	queue_free()
