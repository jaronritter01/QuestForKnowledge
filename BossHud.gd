extends Control

onready var boss = get_tree().get_root().get_node("BossScene").get_node("Boss")

func _ready():
	if boss != null:
		$ProgressBar.max_value = boss.health


func _physics_process(_delta):
	if is_instance_valid(boss):
		$ProgressBar.value = boss.health if boss else 0
