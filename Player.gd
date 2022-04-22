extends KinematicBody2D

### makes player spawn with no movement
var velocity = Vector2.ZERO
const SPEED = 150
const GRAVITY = 30
const JUMP = -600
onready var timer = get_node("Timer")
var firing = false
var projectile = preload("res://ProjectileLight.tscn")
var facing = 1
var jumpCount = 0
var lives = 3

func _ready():
	timer.set_wait_time(.8)
	timer.set_one_shot(true)

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
	### run by game 60x/sec
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
		
	if Input.is_action_just_pressed("fire_projectile_light") and firing == false:
		firing = true
		$PlayerAnimations.speed_scale = 2;
		$PlayerAnimations.play("attack_g")
		timer.start()

	### handle some animatons stuff
	if velocity.x > 5 or velocity.x < -5:
		if firing == false:
			$PlayerAnimations.play("walk_g")
			$PlayerAnimations.speed_scale = 1.7
		
	if velocity.x < 5 and velocity.x > -5:
		if firing == false:
			$PlayerAnimations.play("idle_g")
			$PlayerAnimations.speed_scale = 1.3
		
	if (velocity.y < -5 or velocity.y > 5) and (velocity.x < 5 and velocity.x > -5):
		if firing == false:
			$PlayerAnimations.play("idle_a")
			$PlayerAnimations.speed_scale = 1.3
	elif (velocity.y < -5 or velocity.y > 5) and (velocity.x > 5 or velocity.x < -5):
		if firing == false:
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
