extends CharacterBody2D


@export var move_speed:float = 100
@export var starting_anim = Vector2(0, 1)
const blend = "parameters/Idle/blend_position"
const blend2 = "parameters/Walk/blend_position"
@onready var anim = $AnimationTree
@onready var state_machine =  anim.get("parameters/playback")
@onready var timer = $Flicker
var sleeping = false
var game_over = false
var paused = false
var arrowShowing = false
var bedPosition = Vector2(0,0)

func _ready():
	timer.start()
	anim.set(blend, starting_anim)

func _physics_process(_delta):
	if game_over or paused:
		return
	var input_direction = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	)
	
	velocity = input_direction * move_speed
	
	if arrowShowing:
		$Arrow.visible = true
		$Arrow.rotation = angle_between_points(bedPosition, position)
	else:
		$Arrow.visible = false
	
	update_animation(input_direction)
	move_and_slide()
	pick_new_state()

func update_animation(move_input:Vector2):
	if (move_input != Vector2.ZERO):
		if (move_input.y != 0):
			move_input.x = 0
		anim.set(blend, move_input)
		anim.set(blend2, move_input)


func pick_new_state():
	state_machine.travel("Idle")
	if sleeping:
		state_machine.travel("Sleep")
		return
	elif (velocity != Vector2.ZERO):
		state_machine.travel("Walk")


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


func play():
	anim.active = true
	paused = false
	Light2D


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


func _on_flicker_timeout():
	var energy = randf_range(1.1, 1.4)
	$OutsideLight.energy = energy
	$HillLight.energy = energy
	$InsideLight.energy = energy
	timer.start()
