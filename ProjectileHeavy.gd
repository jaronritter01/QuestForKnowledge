extends KinematicBody2D

var velocity = Vector2.ZERO
const SPEED = 500

func _ready():
	set_physics_process(false)
	
func shoot(direction):
	$ProjectileHeavyAnimation.play("heavySpell")
	var temp = global_transform
	var scene = get_tree().current_scene
	global_transform = temp
	position.x += direction * 45
	position.y += 6
	get_parent().remove_child(self)
	scene.add_child(self)
	$FizzleTimer.start()

func _physics_process(_delta):
	if position.x < -1024 or position.x > 10000:
		queue_free()


func _on_FizzleTimer_timeout():
	$ProjectileHeavyAnimation.play("fizzle")
	$RemoveTimer.start()


func _on_RemoveTimer_timeout():
	queue_free()
