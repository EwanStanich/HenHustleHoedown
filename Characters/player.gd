extends CharacterBody2D


@export var move_speed:float = 100
@export var starting_anim = Vector2(0, 1)
const blend = "parameters/Idle/blend_position"
const blend2 = "parameters/Walk/blend_position"
@onready var anim = $Normal/AnimationTree
@onready var state_machine =  anim.get("parameters/playback")
@onready var magnet_anim = $Magnet/AnimationTree2
@onready var magnet_state_machine =  magnet_anim.get("parameters/playback")
@onready var timer = $Flicker
var sleeping = false
var game_over = false
var paused = false
var arrowShowing = false
var bedPosition = Vector2(0,0)
var isSliding = false
var slideDirection = Vector2(0,0)
var isMagnet = false
var tutorial = false

func _ready():
	$"Debug/Debug Bounce/DebugArrow".play("default")
	$Sleep.play("Sleep")
	timer.start()
	anim.set(blend, starting_anim)
	magnet_anim.set(blend, starting_anim)


func _physics_process(_delta):
	if game_over or paused:
		return
	
	var angle = atan2(slideDirection.y, slideDirection.x)
	if angle < 0:
		angle += 2 * PI
	$"Debug/Debug Bounce".rotation = angle
	$Debug/DebugDirection.text = str(slideDirection)
	
	var input_direction = Vector2(
			Input.get_action_strength("right") - Input.get_action_strength("left"),
			Input.get_action_strength("down") - Input.get_action_strength("up")
		)
	
	if isSliding:
		velocity = slideDirection * 50
	elif tutorial:
		velocity = Vector2(0,0)
	else:
		velocity = input_direction * move_speed
	
	if arrowShowing:
		$ArrowPointer.rotation = angle_between_points(bedPosition, position)
	
	update_animation(input_direction)
	move_and_slide()
	pick_new_state()

func update_animation(move_input:Vector2):
	if (move_input != Vector2.ZERO):
		if (move_input.y != 0):
			move_input.x = 0
		anim.set(blend, move_input)
		anim.set(blend2, move_input)
		magnet_anim.set(blend, move_input)
		magnet_anim.set(blend2, move_input)


func pick_new_state():
	state_machine.travel("Idle")
	magnet_state_machine.travel("Idle")
	if sleeping:
		state_machine.travel("Sleep")
		magnet_state_machine.travel("Sleep")
		return
	elif (velocity != Vector2.ZERO):
		state_machine.travel("Walk")
		magnet_state_machine.travel("Walk")


func set_bed(position):
	bedPosition = position


func angle_between_points(a: Vector2, b: Vector2) -> float:
	if a.x < b.x:
		return PI + atan((a.y-b.y)/(a.x-b.x))
	else:
		return atan((a.y-b.y)/(a.x-b.x))  


func set_camera_limits(b, t, r, l):
	$Camera2D.limit_bottom = b
	$Camera2D.limit_top = t
	$Camera2D.limit_right = r
	$Camera2D.limit_left = l


func get_camera_position():
	return $Camera2D.get_screen_center_position()


func pause():
	paused = true
	anim.active = false
	magnet_anim.active = false


func play():
	anim.active = true
	magnet_anim.active = true	
	paused = false


func set_light_layer(layer):
	if layer == 1:
		$OutsideLight.visible = false
		$HillLight.visible = false
		$InsideLight.visible = true
	elif layer == 2:
		$OutsideLight.visible = true
		$HillLight.visible = false
		$InsideLight.visible = false
	elif layer == 3:
		$OutsideLight.visible = false
		$HillLight.visible = true
		$InsideLight.visible = false
	else:
		$OutsideLight.visible = false
		$HillLight.visible = false
		$InsideLight.visible = false


func _on_flicker_timeout():
	var energy = randf_range(1.1, 1.4)
	$OutsideLight.energy = energy
	$HillLight.energy = energy
	$InsideLight.energy = energy
	timer.start()


func show_arrow():
	arrowShowing = true
	$ArrowPointer.visible = true
	$ArrowPointer/Arrow.play("Point")


func hide_arrow():
	$ArrowPointer.visible = false
	arrowShowing = false


func show_sleep():
	$Sleep.visible = true


func hide_sleep():
	$Sleep.visible = false


func show_e_key():
	$"E-Key".visible = true
	$"E-Key/E".play('play')


func hide_e_key():
	$"E-Key".visible = false


func mudslide(awayPos):
	isSliding = true
	slideDirection = -(awayPos - position).normalized()


func switch_animation():
	if $Normal.visible:
		$Magnet.visible = true		
		$Normal.visible = false
	else:
		$Normal.visible = true
		$Magnet.visible = false

func set_down():
	anim.set(blend, starting_anim)


func set_tutorial(x:bool):
	tutorial = x
