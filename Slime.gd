extends KinematicBody2D

const GRAVITY = 30
var SPEED = 50
var velocity = Vector2.ZERO
var health = 1
export var direction = -1
export var can_fall = true

func _ready():
	$FloorDetector.position.x = $CollisionShape2D.shape.get_extents().x * direction
	if direction == 1:
		$AnimatedSprite.flip_h = true
		
	$FloorDetector.enabled = not can_fall
	
	if not can_fall:
		set_modulate(Color(1, 1, 15))

func _physics_process(delta):
	if $FloorDetector.get_collider() != null: 
		if $FloorDetector.get_collider().name != "TileMap" and $FloorDetector.get_collider().name != "TileMap2":
			print($FloorDetector.get_collider())
	if is_on_wall() or not $FloorDetector.is_colliding() and not can_fall and is_on_floor():
		flip()
	
	velocity.y += GRAVITY
	velocity.x =  SPEED * direction
	### NOTE: must tell what direction is up for the is_on_wall() to work
	velocity = move_and_slide(velocity, Vector2.UP)
	
func handle_death():
	SPEED = 0
	set_collision_layer_bit(5, false)
	set_collision_mask_bit(0, false)
	$SquashChecker.set_collision_layer_bit(5, false)
	$SquashChecker.set_collision_mask_bit(0, false)
	$SidesChecker.set_collision_layer_bit(5, false)
	$SidesChecker.set_collision_mask_bit(0, false)
	
func _on_SquashChecker_body_entered(body):
	if body.name == "Player":
		$AnimatedSprite.play("squash")
		handle_death()
		body.bounce()
		health -= 1
		
	if health <= 0:
		$Timer.start()


func _on_SidesChecker_body_entered(body):
	### fix this bug where player gets stun locked
	if body.name == "Player":
		body.hurt(1)
		body.recoil(global_transform.origin.x)
		if direction != body.facing:
			flip()
		if direction == -1 and body.global_transform.origin.x <= self.global_transform.origin.x:
			flip()
		elif direction == 1 and body.global_transform.origin.x >= self.global_transform.origin.x:
			flip()

	if body.name == "ProjectileLight":
		health -= 1
		body.queue_free()
		
	if body.name == "ProjectileHeavy":
		health -= 2
	
	if health <= 0:
		$AnimatedSprite.play("hit")
		handle_death()
		$Timer.start()


func _on_Timer_timeout():
	queue_free()

func flip():
	direction *= -1
	$AnimatedSprite.flip_h = not $AnimatedSprite.flip_h
	$FloorDetector.position.x = $CollisionShape2D.shape.get_extents().x * direction
