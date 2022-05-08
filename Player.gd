extends KinematicBody2D

### makes player spawn with no movement
var velocity = Vector2.ZERO
const SPEED = 150
const GRAVITY = 30
const JUMP = -500
onready var timer = get_node("Timer")
onready var hitTimer = get_node("HitTimer")
var firing = false
var hit = false
var hover = false
var projectile = preload("res://ProjectileLight.tscn")
var heavy = preload("res://ProjectileHeavy.tscn")
var facing = 1
var jumpCount = 0
var lives = 3
var player = self
var can_move = true
var can_hover = true
var current_item = 1
var potion_count = 0
var staff_count = 0
var is_powered_up = false
onready var currentScene = get_tree().current_scene
onready var hud = get_tree().get_root().get_node(currentScene.name).get_node("HUD")

enum {
	STAFF = 0,
	POTION = 1
}

func shoot_projectile():
	var spell = projectile.instance()
	var scence = get_tree().current_scene
	spell.position.x = self.position.x + (10 * facing)
	spell.position.y = self.position.y
	scence.add_child(spell)
	if not $LightSpellFx.playing:
		$LightSpellFx.play()
	spell.shoot(facing)

func shoot_heavy():
	var spell = heavy.instance()
	var scence = get_tree().current_scene
	
	scence.add_child(spell)
	spell.position.x = self.position.x + (10 * facing)
	spell.position.y = self.position.y - 2 
	spell.shoot(facing)
	
func _physics_process(_delta):
	if is_on_floor():
		jumpCount = 0
		hover = false
		can_hover = true
	
	if can_move:
		if Input.is_action_pressed("move_left"):
			velocity.x = -SPEED
			$PlayerAnimations.flip_h = true
			facing = -1
			
		if Input.is_action_pressed("move_right"):
			velocity.x = SPEED
			$PlayerAnimations.flip_h = false
			facing = 1
		
		if Input.is_action_just_pressed("jump") and (is_on_floor() or jumpCount < 2):
			if jumpCount == 0:
				if not $JumpFx.playing:
					$JumpFx.play()
				velocity.y = JUMP
			if jumpCount == 1:
				if not $JumpFx.playing:
					$JumpFx.play()
				velocity.y = (JUMP * .75)
			jumpCount += 1
		
		if Input.is_action_just_pressed("fire_projectile_light") and not firing and not hit:
			firing = true
			if is_on_floor():
				$PlayerAnimations.speed_scale = 2;
				$PlayerAnimations.play("spell_light_g")
			else:
				$PlayerAnimations.speed_scale = 2;
				$PlayerAnimations.play("spell_light_a")
			timer.start()
			
		if Input.is_action_just_pressed("heavy_attack") and not firing and not hit:
			firing = true
			if not $HeavySpellFx.playing:
				$HeavySpellFx.play()
			if is_on_floor():
				$PlayerAnimations.speed_scale = 2;
				$PlayerAnimations.play("attack_g")
			else:
				$PlayerAnimations.speed_scale = 2;
				$PlayerAnimations.play("attack_a")
			$HeavyTimer.start()
			
		if Input.is_action_just_pressed("hover") and not is_on_floor() and can_hover:
			if not $HoverFx.playing:
				$HoverFx.play()
			$HoverTimer.start()
			
		if Input.is_action_pressed("hover") and not is_on_floor() and can_hover:
			if not (velocity.x > 5 or velocity.x < -5) and not firing:
				$PlayerAnimations.animation = "idle_a"
				$PlayerAnimations.play("idle_a")
			hover = true
			velocity.y = -GRAVITY
			
		if Input.is_action_just_released("hover"):
			$HoverFx.stop()
		
	if Input.is_action_just_pressed("cycleItems"):
		if current_item == STAFF:
			hud.get_node("StaffIcon").visible = false
			hud.get_node("StaffCountLabel").visible = false
			hud.get_node("PotionIcon").visible = true
			hud.get_node("PotionCountLabel").visible = true
			current_item = POTION
		elif current_item == POTION:
			hud.get_node("StaffIcon").visible = true
			hud.get_node("StaffCountLabel").visible = true
			hud.get_node("PotionIcon").visible = false
			hud.get_node("PotionCountLabel").visible = false
			current_item = STAFF
			
	if Input.is_action_just_pressed("use_item"):
		if current_item == POTION and potion_count > 0 and lives < 3:
			if not $PotionDrinkFx.playing:
				$PotionDrinkFx.play()
			potion_count -= 1
			lives += 1
			hide_show_lives()
			hud.get_node("PotionCountLabel").text = str(potion_count)
		elif current_item == STAFF and staff_count > 0 and not is_powered_up:
			staff_count -= 1
			is_powered_up = true
			hud.get_node("StaffCountLabel").text = str(potion_count)

	### handle some animatons stuff
	if velocity.x > 5 or velocity.x < -5:
		if not firing and not hit:
			if not hover:
				$PlayerAnimations.play("walk_g")
			else:
				$PlayerAnimations.play("walk_a")
			$PlayerAnimations.speed_scale = 1.7
	
	if not hover and not hit and not firing:
		if velocity.x < 5 and velocity.x > -5:
			$HoverFx.stop()
			$PlayerAnimations.play("idle_g")
			$PlayerAnimations.speed_scale = 1.3
		
		if not is_on_floor():
			$PlayerAnimations.play("walk_a")
			$PlayerAnimations.speed_scale = 1.3
	
	var snap = Vector2.DOWN * 8 if jumpCount == 0 else Vector2.ZERO
	
	### might play with this
	velocity.y = GRAVITY + velocity.y

	velocity = move_and_slide_with_snap(velocity, snap, Vector2.UP, true)

	velocity.x = lerp(velocity.x, 0, .75)


func hide_show_lives():
	if lives == 3:
		hud.get_child(3).show()
		hud.get_child(2).show()
		hud.get_child(1).show()
	elif lives == 2:
		hud.get_child(3).hide()
		hud.get_child(2).show()
		hud.get_child(1).show()
	elif lives == 1:
		hud.get_child(3).hide()
		hud.get_child(2).hide()
		hud.get_child(1).show()
	else:
		hud.get_child(3).hide()
		hud.get_child(2).hide()
		hud.get_child(1).hide()


func bounce():
	velocity.y = (JUMP * .65)


func recoil(enemyX):
	velocity.y = (JUMP * .45)
	var myPos = global_transform.origin.x
	if myPos < enemyX:
		velocity.x = -900
	elif myPos > enemyX:
		velocity.x = 900

func hurt(amount):
	hit = true
	can_move = false
	$PlayerAnimations.play("hit")
	set_collision_layer_bit(0, false)
	set_collision_mask_bit(5, false)
	lives -= amount
	hide_show_lives()
	if lives <= 0:
		if not $DeathFx.playing:
			$DeathFx.play()
		set_collision_layer_bit(0, false)
		set_collision_mask_bit(5, false)
		reset()
	else:
		if not $HitFx.playing:
			$HitFx.play()
		hitTimer.start()

func reset():
	$PlayerAnimations.play("death")
	$DeathAnimation.start()
	$DeathTimer.start()
	

func _on_Timer_timeout():
	shoot_projectile()
	firing = false
	$PlayerAnimations.play("idle_g")


func _on_FallZone_body_entered(_body):
	lives -= 1
	hide_show_lives()
	if lives != 0 :
		position.x = 50
		position.y = 50
	else:
# warning-ignore:return_value_discarded
		get_tree().change_scene("res://" + currentScene +  ".tscn")


func _on_HitTimer_timeout():
	hit = false
	can_move = true
	if lives > 0:
		set_collision_layer_bit(0, true)
		set_collision_mask_bit(5, true)
	$PlayerAnimations.play("idle_g")


func _on_DeathTimer_timeout():
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://" + currentScene +  ".tscn")


func _on_DeathAnimation_timeout():
	hide()


func _on_HoverTimer_timeout():
	velocity.y = GRAVITY
	can_hover = false
	hover = false


func _on_HeavyTimer_timeout():
	shoot_heavy()
	firing = false
	$PlayerAnimations.play("idle_g")
	

func _on_EndZone_body_entered(body):
	var knight = get_tree().get_root().get_node(currentScene.name).get_node("Enemies").get_node("KnightEnemy")
	if body.name == "Player":
		### getting a funky error on scene change
		if knight == null:
# warning-ignore:return_value_discarded
			get_tree().change_scene("res://EndScene.tscn")
