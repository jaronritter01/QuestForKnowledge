extends KinematicBody2D

var velocity = Vector2.ZERO
const SPEED = 150
const GRAVITY = 30
var facing = -1
var state = -1
var randGen = RandomNumberGenerator.new()
var randomState = -1
var startTimerIsOn = false
var attackTimerIsOn = false
export var health = 100
var is_dead = false
onready var player = get_tree().get_root().get_node("BossScene").get_node("Player")
onready var player_pos = player.global_transform.origin
var boss_pos = global_transform.origin
var is_hit = false
var hit_timer_is_on = false
var rockHandProj = preload("res://RockHandProjectile.tscn")
var laserProj = preload("res://Laser.tscn")
var is_blocking = false
var bounced_off_wall = false
var curLaser

enum {
	IDLE = 0,
	WALKING = 1,
	THROWHANDATTACK = 2,
	BLOCKING = 3
	JUMPING = 4,
	LASERATTACK = 5,
	HIT = 6,
	DEAD = 7,
}

enum {
	HEAD = 0,
	BODY = 1,
	ARM = 2,
	BACK = 3
}

func follow():
	var space_state = get_world_2d().direct_space_state
	var result = space_state.intersect_ray(position, player.position,
	 [self], collision_mask)

	if result and result.collider.name == "Player":
		var playerG = player.global_transform.origin
		var boss = global_transform.origin
		
		if (playerG.x < boss.x and facing == 1) and \
		 (global_position.distance_to(player.position) < 160) and (not bounced_off_wall):
			flip()
		if (playerG.x > boss.x and facing == -1) and \
		(global_position.distance_to(player.position) < 160) and (not bounced_off_wall):
			flip()
	
	return global_position.distance_to(player.position)
	
func shoot_rock_hand():
	var hand = rockHandProj.instance()
	var scence = get_tree().current_scene
	hand.position.x = self.position.x + (12 * facing)
	hand.position.y = self.position.y - 35
	scence.add_child(hand)
	hand.shoot(facing)
	
func shoot_laser():
	var laser = laserProj.instance()
	self.add_child(laser)
	laser.shoot(facing)
	return laser
	
	
func flip():
	facing *= -1
	$AnimatedSprite.flip_h = not $AnimatedSprite.flip_h
	$ArmOneHitBox.position.x = ($CollisionShape2D.shape.get_extents().x * facing) + (facing * 35)
	$BackHitBox.position.x = ($CollisionShape2D.shape.get_extents().x * -facing) + (-facing * 9)
	$HeadHitBox.position.x = ($CollisionShape2D.shape.get_extents().x * facing) - (facing * 2)
	if facing == -1:
		$WallDetector.rotation_degrees = 90
		$ArmOneHitBox/CollisionShape2D.rotation_degrees = 15
		$BodyHitBox.position.x =  ($CollisionShape2D.shape.get_extents().x * facing) - (facing * 3)
	elif facing == 1:
		$WallDetector.rotation_degrees = 270
		$ArmOneHitBox/CollisionShape2D.rotation_degrees = -15
		$BodyHitBox.position.x =  ($CollisionShape2D.shape.get_extents().x * facing) + (facing * 22)
			
func _ready():
	boss_pos = global_transform.origin
	state = THROWHANDATTACK

func _physics_process(_delta):
	var _distance_to_hit = follow() if follow() else 50
	if $WallDetector.is_colliding():
		bounced_off_wall = true
		flip()
		$BounceTimer.start()
	if health <= 0:
		state = DEAD
	if state == IDLE:
		$ArmOneHitBox.set_collision_mask_bit(3, true)
		$AnimatedSprite.play("idle")
		if not startTimerIsOn:
			startTimerIsOn = true
			$StartTimer.start()
	elif state == WALKING:
		$ArmOneHitBox.set_collision_mask_bit(3, true)
		velocity.x = SPEED * facing
		if is_on_wall():
			flip()
		if not startTimerIsOn:
			startTimerIsOn = true
			$StartTimer.start()
	elif state == LASERATTACK:
		player_pos = player.global_transform.origin
		boss_pos = global_transform.origin
		$ArmOneHitBox.set_collision_mask_bit(3, true)
		velocity.x = 0
		if not attackTimerIsOn:
			$AnimatedSprite.play("laserAttack")
			attackTimerIsOn = true
			$LaserFireTimer.start()
		
	elif state == THROWHANDATTACK:
		player_pos = player.global_transform.origin
		boss_pos = global_transform.origin
		if (player_pos.x < boss_pos.x and facing == -1) \
		or (player_pos.x > boss_pos.x and facing == 1 ):
			velocity.x = 0
			$ArmOneHitBox.set_collision_mask_bit(3, false)
			if not attackTimerIsOn:
				attackTimerIsOn = true
				$AnimatedSprite.play("handThrow")
				if not $RockFireSoundFX.playing:
					$RockFireSoundFX.play()
				$HandThrowTimer.start()
		if not startTimerIsOn:
			startTimerIsOn = true
			$StartTimer.start()
	elif state == HIT:
		$AnimatedSprite.play("hit")
		if not $BossHitSoundFX.playing:
			$BossHitSoundFX.play()
		$ArmOneHitBox.set_collision_mask_bit(3, true)
		set_modulate(Color(255, 255, 255)) ### CHANGE COLOR
		if not hit_timer_is_on:
			is_hit = true
			hit_timer_is_on = true
			$HitTimer.start()
	elif state == BLOCKING:
		$AnimatedSprite.play("blocking")
		is_blocking = true
		if not startTimerIsOn:
			startTimerIsOn = true
			$StartTimer.start()
	elif state == JUMPING:
		pass
	elif state == DEAD:
		if is_dead == false:
			$AnimatedSprite.play("death")
			is_dead = true
			$HandThrowTimer.stop()
			$HandThowCooldownTimer.stop()
			$StartTimer.stop()
			$HitTimer.stop()
			$BlockCooldown.stop()
			$DeathTimer.start()
			$HeadHitBox.set_collision_mask_bit(0, false)
			$BodyHitBox.set_collision_mask_bit(0, false)
			$ArmOneHitBox.set_collision_mask_bit(0, false)
			$BackHitBox.set_collision_mask_bit(0, false)
	velocity.y = GRAVITY + velocity.y

	velocity = move_and_slide(velocity, Vector2.UP, true)

	velocity.x = lerp(velocity.x, 0, .75)


func _on_LaserFireTimer_timeout():
	shoot_laser()
	attackTimerIsOn = false


func _on_HandThrowTimer_timeout():
	shoot_rock_hand()
	$HandThowCooldownTimer.start()


func _on_HandThowCooldownTimer_timeout():
	$AnimatedSprite.play("idle")
	attackTimerIsOn = false
			
			
func handleHit(body, bodyPart):
	### register the hit
	if not hit_timer_is_on:
		if (bodyPart != ARM) and (not is_blocking) and (not "RockHandProjectile" in body.name):
			state = HIT
		if "ProjectileLight" in body.name:
			if not is_blocking:
				match bodyPart:
					HEAD:
						health -= 3
					BODY:
						health -= 1
					BACK:
						health -= 2
			body.queue_free()
		elif "ProjectileHeavy" in body.name:
			if not is_blocking:
				match bodyPart:
					HEAD:
						health -= 5
					BODY:
						health -= 2
					BACK:
						health -= 3
					ARM:
						### minimal damage with a stronger spell
						health -= 1
			body.fizzle()
	if "Player" in body.name:
		body.hurt(1)
		body.recoil(global_transform.origin.x)

func _on_HeadHitBox_body_entered(body):
	handleHit(body, HEAD)


func _on_BodyHitBox_body_entered(body):
	handleHit(body, BODY)


func _on_ArmOneHitBox_body_entered(body):
	handleHit(body, ARM)


func _on_BackHitBox_body_entered(body):
	if not is_blocking:
		flip()
	handleHit(body, BACK)


func _on_DeathTimer_timeout():
	# warning-ignore:return_value_discarded
	get_tree().change_scene("res://EndScene.tscn")


func _on_HitTimer_timeout():
	state = randGen.randi_range(0,3)
	hit_timer_is_on = false
	is_hit = false
	set_modulate(Color(1, 1, 1)) ### CHANGE COLOR


func _on_BlockTimer_timeout():
	$AnimatedSprite.play("blocking")
	$BlockCooldown.start()


func _on_BlockCooldown_timeout():
	$AnimatedSprite.play("idle")
	state = IDLE
	is_blocking = false


func _on_StartTimer_timeout():
	startTimerIsOn = false
	is_blocking = false
	state = randGen.randi_range(0,3)


func _on_BounceTimer_timeout():
	bounced_off_wall = false


func _on_EndTimer_timeout():
	# warning-ignore:return_value_discarded
	get_tree().change_scene("res://EndScene.tscn")
