extends KinematicBody2D

const GRAVITY = 30
var SPEED = 50
var velocity = Vector2.ZERO
var health = 1
const JUMP_FORCE = -500
export var direction = -1
export var can_fall = true
var jumped = false
var on_screen = false
var is_dead = false

func _ready():
	$FloorDetector.position.x = $CollisionShape2D.shape.get_extents().x * direction
	if direction == 1:
		$AnimatedSprite.flip_h = true
		
	$FloorDetector.enabled = not can_fall
	
	if not can_fall:
		set_modulate(Color(1, 1, 15))

func _physics_process(_delta):
	if is_on_wall() or not $FloorDetector.is_colliding() and not can_fall and is_on_floor():
		flip()
	
	velocity.y += GRAVITY
	if(not jumped):
		velocity.x =  SPEED * direction
	### NOTE: must tell what direction is up for the is_on_wall() to work
	velocity = move_and_slide(velocity, Vector2.UP)
	
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		var colliders = ["TileMap", "TileMap2", "OneWayGround"]
		if collision.collider.name in colliders:
			if not $SlimeWalkSoundFX.playing and on_screen:
				$SlimeWalkSoundFX.play()
			velocity.x =  SPEED * direction
	
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
		is_dead = true
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
		is_dead = true
		handle_death()
		$Timer.start()


func _on_Timer_timeout():
	queue_free()

func flip():
	direction *= -1
	$AnimatedSprite.flip_h = not $AnimatedSprite.flip_h
	$FloorDetector.position.x = $CollisionShape2D.shape.get_extents().x * direction


func _on_Area2D_body_entered(body):
	if body.name == "Player":
		var player = body.global_transform.origin
		var slime = global_transform.origin
		if not jumped and ((player.x < slime.x and direction < 0) or (player.x > slime.x and direction > 0)):
			jumped = true
			if not $JumpSoundFX.playing:
				$JumpSoundFX.play()
			velocity.x = direction * 130
			velocity.y = JUMP_FORCE
			$JumpTimer.start()


func _on_JumpTimer_timeout():
	jumped = false


func _on_VisibilityNotifier2D_screen_entered():
	on_screen = true


func _on_VisibilityNotifier2D_screen_exited():
	on_screen = false
