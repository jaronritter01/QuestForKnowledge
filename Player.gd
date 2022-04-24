extends KinematicBody2D

### makes player spawn with no movement
var velocity = Vector2.ZERO
const SPEED = 150
const GRAVITY = 30
const JUMP = -600
onready var timer = get_node("Timer")
onready var hitTimer = get_node("HitTimer")
var firing = false
var hit = false
var hover = false
var projectile = preload("res://ProjectileLight.tscn")
var facing = 1
var jumpCount = 0
var lives = 3
var player = self
var can_move = true
var can_hover = true

func _ready():
	timer.set_wait_time(.8)
	timer.set_one_shot(true)
	hitTimer.set_wait_time(.5)
	hitTimer.set_one_shot(true)

func shoot_projectile():
	var spell = projectile.instance()
	var scence = get_tree().current_scene
	spell.position.x = self.position.x + (10 * facing)
	spell.position.y = self.position.y
	scence.add_child(spell)
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
				velocity.y = JUMP
			if jumpCount == 1:
				velocity.y = (JUMP * .70)
			jumpCount += 1
		
		if Input.is_action_just_pressed("fire_projectile_light") and not firing and not hit:
			firing = true
			if is_on_floor():
				$PlayerAnimations.speed_scale = 2;
				$PlayerAnimations.play("attack_a")
			else:
				$PlayerAnimations.speed_scale = 2;
				$PlayerAnimations.play("attack_g")
			timer.start()
			
		if Input.is_action_just_pressed("hover") and not is_on_floor() and can_hover:
			$HoverTimer.start()
			
		if Input.is_action_pressed("hover") and not is_on_floor() and can_hover:
			if not (velocity.x > 5 or velocity.x < -5) and not firing:
				$PlayerAnimations.animation = "idle_a"
				$PlayerAnimations.play("idle_a")
			hover = true
			velocity.y = -GRAVITY

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
			$PlayerAnimations.play("idle_g")
			$PlayerAnimations.speed_scale = 1.3
		
		if not is_on_floor():
			$PlayerAnimations.play("walk_a")
			$PlayerAnimations.speed_scale = 1.3
	
	### might play with this
	velocity.y = GRAVITY + velocity.y

	velocity = move_and_slide(velocity, Vector2.UP)

	velocity.x = lerp(velocity.x, 0, .75)


func hide_show_lives():
	var hud = self.get_parent().get_child(0)
	if lives == 2:
		hud.get_child(3).hide()
	elif lives == 1:
		hud.get_child(2).hide()
	else:
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
		set_collision_layer_bit(0, false)
		set_collision_mask_bit(5, false)
		reset()
	else:
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
		get_tree().change_scene("res://BaseLevel.tscn")


func _on_HitTimer_timeout():
	hit = false
	can_move = true
	if lives > 0:
		set_collision_layer_bit(0, true)
		set_collision_mask_bit(5, true)
	$PlayerAnimations.play("idle_g")


func _on_DeathTimer_timeout():
	var currentScene = get_tree().current_scene.name
	get_tree().change_scene("res://" + currentScene +  ".tscn")


func _on_DeathAnimation_timeout():
	hide()


func _on_HoverTimer_timeout():
	velocity.y = GRAVITY
	can_hover = false
	hover = false
