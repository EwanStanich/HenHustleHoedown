extends CharacterBody2D


@export var move_speed:float = 10
@export var move_direction:Vector2
var isMoving = false
var touchingPlayer = false
var touchingAnimal = false
var touchingTileMap = false
var paused = false
var startingPosition
@onready var timer = $Timer
@onready var anim = $AnimatedSprite2D


func _ready():
	timer.wait_time = randf_range(1.5, 4)
	timer.one_shot = true
	timer.start()
	anim.play("Idle")
	if randf() > 0.5:
		anim.flip_h = true
	startingPosition = position

func _physics_process(_delta):
	if paused:
		return
	
	if isMoving:
		velocity = move_speed * move_direction
	else:
		velocity = Vector2.ZERO
	
	if touchingPlayer:
		anim.play("Idle")
		move_and_collide(Vector2.ZERO)
	elif touchingAnimal:
		move_and_collide(velocity * _delta)
	else:
		move_and_slide()
	
	pick_state()


func move_cow():	
	if touchingTileMap:
		wall_bounce()
	elif touchingAnimal:
		pass
	else:
		startingPosition = position
		move_direction = Vector2.ZERO
		while move_direction.length() < 0.2:	
			move_direction = Vector2(
				randf_range(-1, 1),
				randf_range(-1, 1)
			)
		startingPosition = position
	timer.wait_time = randf_range(1, 3)


func pick_state():
	if isMoving and !touchingPlayer:
		anim.play("Walking")
	else:
		anim.play("Idle")
	
	if isMoving:
		if move_direction.x > 0:
			anim.flip_h = false
		else:
			anim.flip_h = true


func _on_area_2d_body_entered(body):
	if body.get_node("CollisionShape2D") != get_node("CollisionShape2D"):
		var a = body.name
		if ("Cow" in body.name or "Chicken" in body.name) and body != $CollisionShape2D:
			touchingAnimal = true
			move_direction = -(body.position - position).normalized()
			startingPosition = position
		if "TileMap" in body.name:
			touchingTileMap = true
			isMoving = false
			anim.play("Idle")
		if "Player" in body.name:
			touchingPlayer = true


func _on_area_2d_body_exited(body):
	if "TileMap" in body.name:
		touchingTileMap = false
	if "Player" in body.name:
			touchingPlayer = false
	if ("Cow" in body.name or "Chicken" in body.name) and body != $CollisionShape2D:
		touchingAnimal = false



func _on_timer_timeout():
	if !isMoving: # and randf() > 0.6:
		isMoving = true
		move_cow()
	else:
		isMoving = false
	timer.start()


func wall_bounce():
	var current_position = position
	var direction = position - startingPosition
	
	if direction.x >= 0:
		move_direction.x = randf_range(-1, 0)
	else:
		move_direction.x = randf_range(0, 1)
	if direction.y >= 0:
		move_direction.y = randf_range(-1, 0)
	else:
		move_direction.y = randf_range(0, 1)
	startingPosition = position


func pause():
	paused = true
	anim.pause()


func play():
	anim.play()
	paused = false
