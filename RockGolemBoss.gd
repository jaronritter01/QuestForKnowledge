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
enum {
	IDLE = 0,
	WALKING = 1,
	JUMPING = 2,
	LASERATTACK = 3,
	THROWHANDATTACK = 4,
	HIT = 5,
	DEAD = 6,
	BLOCKING = 7
}


func flip():
	facing *= -1
	$AnimatedSprite.flip_h = not $AnimatedSprite.flip_h
	
func transition():
	if randomState == 1:
		state = LASERATTACK
	elif randomState == 0:
		state = THROWHANDATTACK
	elif randomState == -1:
		state = IDLE
	elif randomState == 2:
		state = WALKING
			
func _ready():
	state = IDLE
	$StartTimer.start()

func _physics_process(_delta):
	if state == IDLE:
		$AnimatedSprite.play("idle")
		transition()
		if not startTimerIsOn:
			startTimerIsOn = true
			$StartTimer.start()
	elif state == WALKING:
		velocity.x = SPEED * facing
		if is_on_wall():
			flip()
		if not startTimerIsOn:
			startTimerIsOn = true
			$StartTimer.start()
		transition()
		$AnimatedSprite.play("idle")
	elif state == LASERATTACK:
		velocity.x = 0
		if not attackTimerIsOn:
			attackTimerIsOn = true
			$LaserFireTimer.start()
		transition()
		$AnimatedSprite.play("laserAttack")
	elif state == THROWHANDATTACK:
		velocity.x = 0
		if not attackTimerIsOn:
			attackTimerIsOn = true
			$HandThrowTimer.start()
		transition()
		$AnimatedSprite.play("handThrow")
	velocity.y = GRAVITY + velocity.y

	velocity = move_and_slide(velocity, Vector2.UP, true)

	velocity.x = lerp(velocity.x, 0, .75)


func _on_LaserFireTimer_timeout():
	$LaserCooldownTimer.start()


func _on_LaserCooldownTimer_timeout():
	attackTimerIsOn = false
	if not startTimerIsOn:
		startTimerIsOn = true
		$StartTimer.start()


func _on_StartTimer_timeout():
	randomState = randGen.randi_range(-1,2)
	startTimerIsOn = false


func _on_HandThrowTimer_timeout():
	$HandThowCooldownTimer.start()


func _on_HandThowCooldownTimer_timeout():
	$AnimatedSprite.play("idle")
	attackTimerIsOn = false
	if not startTimerIsOn:
		startTimerIsOn = true
		$StartTimer.start()
