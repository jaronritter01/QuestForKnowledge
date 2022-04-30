extends KinematicBody2D

var health = 8
export var facing = -1
export var can_fall = false
var velocity = Vector2.ZERO
const SPEED = 50
const GRAVITY = 30
const JUMP = -500
var state = 0
var attacked = false
var dead = false

# Knight States
enum {
	IDLE = 0,
	WALKING = 1,
	JUMPING = 2,
	ATTACKING = 3,
	HIT = 4,
	DEAD = 5,
	BLOCKING = 6,
	FALLING = 7
}

func _ready():
	state = WALKING
	$FloorChecker.position.x = $CollisionShape2D.shape.get_extents().x * facing
	$AnimatedSprite/SwordArea/SwordHitBox.position.x = ($CollisionShape2D.shape.get_extents().x * facing) + (facing * 12)
	if facing == -1:
		$AnimatedSprite.flip_h = true
		
	$FloorChecker.enabled = not can_fall
	
	

func _physics_process(_delta):
	if health == 0:
		state = DEAD
	
	var player = get_tree().get_root().get_child(0).get_child(1)
	var distance_to_hit = look(player.position) if look(player.position) else 50
	
	if state == IDLE:
		$AnimatedSprite.play("idle")
		### Transition from idle to walking
		if velocity.x > 5 or velocity.x < -5:
			state = WALKING
		if velocity.y > 5 or velocity.y < -5:
			state = JUMPING
		if distance_to_hit < 50:
			state = ATTACKING
			
	elif state == WALKING:
		$AnimatedSprite.play("walk")
		velocity.x = SPEED * facing
		if is_on_wall() or not $FloorChecker.is_colliding() and not can_fall and is_on_floor():
			flip()
			
		for i in get_slide_count():
			var collision = get_slide_collision(i)
			var colliders = ["TileMap", "TileMap2", "OneWayGround"]
			if collision.collider and collision.collider.name in colliders:
				velocity.x =  SPEED * facing
		
		### transition to jump
		if (velocity.y > 5 or velocity.y < -5) and not is_on_floor():
			state = JUMPING
			
		if distance_to_hit < 50:
			state = ATTACKING
			
	elif state == JUMPING:
		$AnimatedSprite.play("jump")
		if is_on_floor():
			state = IDLE
			
	elif state == ATTACKING:
		$AnimatedSprite.play("attack")
		$AnimatedSprite/SwordArea/SwordHitBox.disabled = false
		velocity.x = (SPEED * .3) * facing
		if not attacked:
			attacked = true
			$AttackTimer.start()
			
	elif state == HIT:
		$AnimatedSprite.play("hurt")
		hit(player)
		state = IDLE
	
	elif state == DEAD:
		$AnimatedSprite.play("die")
		velocity.x = 0
		if not dead:
			dead = true
			$DeathTimer.start()
		
	velocity.y = GRAVITY + velocity.y
	velocity = move_and_slide(velocity, Vector2.UP)
	
func flip():
	facing *= -1
	$AnimatedSprite.flip_h = not $AnimatedSprite.flip_h
	$FloorChecker.position.x = $CollisionShape2D.shape.get_extents().x * facing
	$AnimatedSprite/SwordArea/SwordHitBox.position.x = ($CollisionShape2D.shape.get_extents().x * facing) + (facing * 12)


func _on_AttackTimer_timeout():
	$AnimatedSprite/SwordArea/SwordHitBox.disabled = true
	attacked = false
	state = WALKING
	
func hit(player):
	var playerPos = player.global_transform.origin
	var knightPos = global_transform.origin
	
	if playerPos.x < knightPos.x :
		velocity.x = 500
	if playerPos.x > knightPos.x:
		velocity.x = -500

### Used to handle the knight following the player
func look(player_position):
	var playerG = get_tree().get_root().get_child(0).get_child(1)
	var space_state = get_world_2d().direct_space_state
	var result = space_state.intersect_ray(position, player_position,
	 [self], collision_mask)
	if result and result.collider.name == "Player":
		var player = result.collider.global_transform.origin
		var knight = global_transform.origin
		
		if player.x < knight.x and facing == 1:
			flip()
		if player.x > knight.x and facing == -1:
			flip()
	
	return global_position.distance_to(playerG.position)


func _on_HitBox_body_entered(body):
	if body.name == "ProjectileLight":
		state = HIT
		health -= 1
		body.queue_free()
	if body.name == "ProjectileHeavy":
		state = HIT
		health -= 2
		body.fizzle()


func _on_DeathTimer_timeout():
	queue_free()


func _on_SwordArea_body_entered(body):
	if body.name == "Player":
		body.recoil(global_transform.origin.x)
		body.hurt(1)
