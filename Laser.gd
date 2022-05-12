extends KinematicBody2D

onready var player = get_tree().get_root().get_node("BossScene").get_node("Player")
onready var boss = get_tree().get_root().get_node("BossScene").get_node("Boss")

func calc_angle():
	var x1 = boss.global_transform.origin.x
	var x2 = player.global_transform.origin.x
	var y1 = boss.global_transform.origin.y 
	print(y1)
	var y2 = player.global_transform.origin.y
	print(y2)
	
	var a = sqrt(pow((x2-x1), 2)+pow((y2-y1), 2)) ### calculate the distance b/t boss and player
	var b = abs(y2 - y1)
	var c = sqrt(pow(a, 2) - pow(b, 2))
	
	var angle_in_rad = acos(c/a)
	var angle_in_deg = angle_in_rad * (180/PI) + 15
	
	if (x2 < x1 and y2 > y1) or (x2 > x1 and y2 < y1):
		angle_in_deg *= -1
			
	return angle_in_deg

func look():
	var angle = calc_angle()
	$AnimatedSprite.rotation_degrees += angle
	$Area2D/CollisionShape2D.rotation_degrees += angle
		
func shoot(direction):
	if direction < 0:
		$AnimatedSprite.position.x -= 270
		$Area2D/CollisionShape2D.position.x -= 390
		$AnimatedSprite.flip_h = true
	else:
		$AnimatedSprite.position.x += 270
		$Area2D/CollisionShape2D.position.x += 270
		
	position.y -= 45
	$Timer.start()
#	set_physics_process(true)
	


func _on_Area2D_body_entered(body):
	print(body.name)


func _on_Timer_timeout():
	print("here")
	queue_free()
