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
var isLightning = false
var isMagnet = false
var onPlayer = false
var rightOnPlayer = false
var inPen = false
@onready var timer = $Timer
@onready var anim = $AnimatedSprite2D
var isSliding = false
var slideDirection = Vector2(0,0)


func _ready():
	$"Debug/Debug Bounce/DebugArrow".play("default")
	timer.wait_time = randf_range(1.5, 4)
	timer.one_shot = true
	timer.start()
	anim.play("Idle")
	if randf() > 0.5:
		anim.flip_h = true
	while move_direction.length() < 0.2:	
		move_direction = Vector2(
			randf_range(-1, 1),
			randf_range(-1, 1)
		)
	startingPosition = position
	$Exclamation.play("Panic")
	

func _physics_process(_delta):
	if paused:
		return
	if isSliding:
		velocity = slideDirection * 50
	else:
		if isLightning:
			move_speed = 200
		elif !touchingPlayer:
			move_speed = 50
		elif rightOnPlayer:
			move_speed = 0
		if isMoving or touchingPlayer or isLightning:
			velocity = move_speed * move_direction
		else:
			velocity = Vector2.ZERO

	var angle = atan2(move_direction.y, move_direction.x)
	if angle < 0:
		angle += 2 * PI
	$"Debug/Debug Bounce".rotation = angle
	$Debug/DebugDirection.text = str(move_direction)
	
	if touchingPlayer:
		if !isLightning:
			if playerClose and !isMagnet:
				move_speed += 1
			elif isMagnet:
				if onPlayer:
					move_speed = 20
				else:
					move_speed = 100
			else:
				move_speed = 95
		var direction_from_player = player.position - position
		if player.position.x < position.x:
			direction_from_player.x += 1.85
		if player.position.y < position.y:
			direction_from_player.y += 3
			
		if isMagnet and !inPen:
			move_direction = (direction_from_player).normalized()
		else:
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
	if isMoving and !rightOnPlayer:
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
			if isLightning:
				wall_bounce()
			else:
				isMoving = false
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


func _on_area_2d_4_body_entered(body):
	if "Player" in body.name:
		onPlayer = true


func _on_area_2d_4_body_exited(body):
	if "Player" in body.name:
		onPlayer = false


func _on_area_2d_5_body_entered(body):
	if "Player" in body.name:
		rightOnPlayer = true


func _on_area_2d_5_body_exited(body):
	if "Player" in body.name:
		rightOnPlayer = false


func pause():
	paused = true
	anim.pause()


func play():
	anim.play()
	paused = false


func lightning():
	isLightning = true
	$Exclamation.visible = true
	$LightningTimer.wait_time = 4
	$LightningTimer.start()


func _on_lightning_timer_timeout():
	isLightning = false
	$Exclamation.visible = false	
	move_speed = 50

func mudslide(awayPos):
	isSliding = true
	slideDirection = -(awayPos - position).normalized()
