extends KinematicBody2D

var velocity = Vector2.ZERO
const SPEED = 800
onready var player = get_tree().get_root().get_node("BossScene").get_node("Player")
onready var boss = get_tree().get_root().get_node("BossScene").get_node("Boss")

func look():
	var space_state = get_world_2d().direct_space_state
	var result = space_state.intersect_ray(boss.position, player.position,
	 [boss], 1)
	if result and result.collider.name == "Player":
		var playerR = player.global_transform.origin
		var bossR = boss.global_transform.origin
		bossR.x -= 12
		bossR.y -= 35
		velocity = (playerR - bossR).normalized() * SPEED
		var angle = calc_angle()
		$AnimatedSprite.rotation_degrees += angle
		$CollisionShape2D.rotation_degrees += angle

func calc_angle():
	var x1 = boss.global_transform.origin.x
	var x2 = player.global_transform.origin.x
	var y1 = boss.global_transform.origin.y
	var y2 = player.global_transform.origin.y
	if x2 < x1:
		x1 -= 12
		y1 -= 35
	
	var a = sqrt(pow((x2-x1), 2)+pow((y2-y1), 2)) ### calculate the distance b/t boss and player
	var b = abs(y2 - y1)
	var c = sqrt(pow(a, 2) - pow(b, 2))
	
	var angle_in_rad = acos(c/a)
	var angle_in_deg = angle_in_rad * (180/PI)
	
	if (x2 < x1 and y2 > y1) or (x2 > x1 and y2 < y1):
		angle_in_deg *= -1
			
	return angle_in_deg

func shoot(direction):
	var temp = global_transform
	var scene = get_tree().current_scene
	get_parent().remove_child(self)
	scene.add_child(self)
	global_transform = temp
	if direction < 0:
		position.x += -24
		$AnimatedSprite.flip_h = true
	look()
	set_physics_process(true)

func _physics_process(_delta):	
# warning-ignore:return_value_discarded
	move_and_slide(velocity)
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		### this is handling when the projectile hits a wall or floor
		if collision:
			if collision.collider.name == "TileMap" or collision.collider.name == "TileMap2"\
			 or collision.collider.name == "PlayerTileMap":
				queue_free()
			elif "ProjectileHeavy" in collision.collider.name:
				collision.collider.fizzle()
				queue_free()
			elif "Player" in collision.collider.name:
				queue_free()
				collision.collider.hurt(1)
				collision.collider.recoil(boss.position.x)
