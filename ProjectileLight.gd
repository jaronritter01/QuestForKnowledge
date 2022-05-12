extends KinematicBody2D

var velocity = Vector2.ZERO
const SPEED = 500

func _ready():
	set_physics_process(false)
	
func shoot(direction):
	var temp = global_transform
	var scene = get_tree().current_scene
	get_parent().remove_child(self)
	scene.add_child(self)
	global_transform = temp
	if direction < 0:
		position.x += -24
		$ProjectileLightAnimation.flip_h = true
	velocity.x = SPEED * direction
	set_physics_process(true)

func _physics_process(_delta):
	if position.x < -1024 or position.x > 10000:
		queue_free()
		
# warning-ignore:return_value_discarded
	move_and_slide(velocity)
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		### this is handling when the projectile hits a wall or floor
		if collision:
			if collision.collider.name == "TileMap" or collision.collider.name == "TileMap2" or collision.collider.name == "PlayerTileMap":
				queue_free()
			elif "ProjectileHeavy" in collision.collider.name:
				collision.collider.fizzle()
				queue_free()


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
