extends CharacterBody2D


@export var move_speed:float = 50
@export var move_direction:Vector2
var isMoving = false
var touchingPlayer = false
var touchingAnimal = false
var touchingTileMap = false
var playerClose = false
var paused = false
var startingPosition
var player
@onready var timer = $Timer
@onready var anim = $AnimatedSprite2D


func _ready():
	timer.wait_time = randf_range(1.5, 4)
	timer.one_shot = true
	timer.start()
	anim.play("Idle")
	if randf() > 0.5:
		anim.flip_h = true

func _physics_process(_delta):
	if paused:
		return
	if isMoving or touchingPlayer:
		velocity = move_speed * move_direction
	else:
		velocity = Vector2.ZERO
	
	if touchingPlayer:
		if playerClose:
			move_speed = 120
		else:
			move_speed = 95
		print("Player: " + str(player.position))
		print("Chicken: " + str(position))
		var direction_from_player = player.position - position
		if player.position.x < position.x:
			direction_from_player.x += 1.85
		if player.position.y < position.y:
			direction_from_player.y += 3
			
		move_direction = -(direction_from_player).normalized()
	
	move_and_slide()
	pick_state()


func move_chicken():	
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
	timer.wait_time = randf_range(0.5, 1.3)


func pick_state():
	if isMoving:
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
		if ("Cow" in body.name or "Chicken" in body.name) and body != $CollisionShape2D:
			touchingAnimal = true
			move_direction = -(body.position - position).normalized()
			startingPosition = position
		if "TileMap" in body.name and !touchingPlayer:
			touchingTileMap = true
			isMoving = false
			timer.wait_time = 0.5
			anim.play("Idle")


func _on_area_2d_body_exited(body):
	if "TileMap" in body.name:
		touchingTileMap = false
	if ("Cow" in body.name or "Chicken" in body.name) and body != $CollisionShape2D:
		touchingAnimal = false



func _on_timer_timeout():
	if touchingPlayer:
		timer.start()
		return
	if !isMoving: # and randf() > 0.6:
		isMoving = true
		move_chicken()
	else:
		isMoving = false
	timer.start()


func wall_bounce():
	if !startingPosition:
		move_direction = -move_direction
		startingPosition = position
		return
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


func _on_area_2d_2_body_entered(body):
	if "Player" in body.name:
		startingPosition = position
		player = body
		isMoving = true
		touchingPlayer = true


func _on_area_2d_2_body_exited(body):
	if "Player" in body.name:
			isMoving = false
			touchingPlayer = false


func _on_area_2d_3_body_entered(body):
	if "Player" in body.name:
		playerClose = true


func _on_area_2d_3_body_exited(body):
	if "Player" in body.name:
		playerClose = false


func pause():
	paused = true
	anim.pause()


func play():
	anim.play()
	paused = false
