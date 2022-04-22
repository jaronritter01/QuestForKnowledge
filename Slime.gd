extends KinematicBody2D

const GRAVITY = 30
var velocity = Vector2.ZERO
var health = 2

func _physics_process(delta):
	if health == 0:
		self.queue_free()

	velocity.y = GRAVITY + velocity.y
	velocity = move_and_slide(velocity, Vector2.UP)


func _on_Area2D_body_entered(body):
	if body.name == "ProjectileLight":
		health -= 1
		body.queue_free()


func _on_slimeCol_area_entered(area):
	area.get_parent().velocity.x *= -1
