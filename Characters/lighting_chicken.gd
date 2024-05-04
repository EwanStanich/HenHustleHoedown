extends Node2D

var start
var right = true
@onready var anim = $AnimatedSprite2D


func _ready():
	start = position.x
	anim.play("Walking")
	$Exclamation.play("Panic")

func _physics_process(delta):
	if right:
		position += Vector2(-6,0)
		anim.flip_h = true
	else:
		position += Vector2(6,0)
		anim.flip_h = false
	
	if position.x <= start - 100:
		right = false
	elif position.x >= start + 100:
		right = true
	
