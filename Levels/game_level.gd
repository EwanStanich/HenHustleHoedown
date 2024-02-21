extends Node2D

@onready var capturedChickens = 0
var totalChickens = 0
var playerSleeping = false
var gameOver = false
var isEnteringName = false
var paused = false
var player
var chickens = []
var cows = []
var time = 0
var mins
var secs
var msecs
var label
var totalTime


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	for chicken in $Characters/Chickens.get_children():
		chickens.append(chicken)
		totalChickens += 1
	for cow in $Characters/Cows.get_children():
		chickens.append(cow)
	player = $Characters/Player
	player.set_bed($LevelItems/Bed.position)
	$UI/Chickns.text = "x " + str(capturedChickens)
	$UI/ChicknIcon.play("Icon")
	player.set_camera_limits(369,5,514,6)
	label = $GameOver/Name


func _physics_process(delta):
	if !gameOver and !paused:
		time += delta
		msecs = fmod(time, 1) * 100
		secs = fmod(time, 60)
		mins = fmod(time, 3600) / 60
		$UI/Timer/Minutes.text = "%02d:" % mins
		$UI/Timer/Seconds.text = "%02d." % secs
		$UI/Timer/Milliseconds.text = "%02d" % msecs


func _input(event):
	if event is InputEventKey:
		if Input.is_key_pressed(KEY_E) and playerSleeping and !gameOver:
			game_over()
		if Input.is_key_pressed(KEY_TAB) and !paused:
			pause_game()
		if isEnteringName:
			if event is InputEventKey and event.is_pressed():
				var key_text = event.as_text()			
				if key_text == "Backspace":
					var new_text = label.text.substr(0, label.text.length() - 1)
					label.text = new_text
				elif key_text == "Enter" and !label.text.is_empty():
					Game.level1 = true
					update_time(totalTime, label.text)
					Utils.saveGame()
					get_tree().change_scene_to_file("res://Levels/title_screen.tscn")
				elif label.text.length() > 6:
					pass
				elif "Shift" in key_text and key_text.length() == 7:
					label.text += key_text.right(1).to_upper()
				elif key_text.length() > 1:
					pass
				else:
					label.text += key_text.to_lower()


func _on_roof_area_body_entered(body):
	if body.name == "Player":
		var roof = get_node("TileMaps/Roofs")
		roof.set_layer_modulate(0, Color(1, 1, 1, 0.3))


func _on_roof_area_body_exited(body):
	if body.name == "Player":
		var roof = get_node("TileMaps/Roofs")
		if roof:
			roof.set_layer_modulate(0, Color(1, 1, 1, 1))


func _on_gate_detector_body_entered(body):
	if "Chicken" in body.name and !isEnteringName:
		body.set_collision_mask_value(2, true)
		if capturedChickens < totalChickens:
			capturedChickens += 1
		$UI/Chickns.text = "x " + str(capturedChickens)
		if capturedChickens == totalChickens:
			player.show_arrow()



func game_over():
	if capturedChickens == totalChickens:
		gameOver = true
		format_time()
		$UI.queue_free()
		$TileMaps/Roofs.queue_free()
		player.game_over = true
		var camera:Camera2D = player.get_node("Camera2D")
		var tween = get_tree().create_tween()
		tween.tween_property(camera, "zoom", Vector2(4,4), 3.5)
		await tween.finished
		var anim:AnimationPlayer = $EndGame/AnimationPlayer
		anim.play("Close")
		await anim.animation_finished
		isEnteringName = true
		var final_time:Label = $GameOver/FinalTime
		label.text = ""
		label.grab_focus()
		final_time.text = totalTime
		player.position = $GameOver.position
		camera.zoom = Vector2(1.2, 1.2)
		player.set_camera_limits(187.5, -10, 953, 650)


func format_time():
	var min = format_time_component(mins)
	var sec = format_time_component(secs)
	var msec = format_time_component(msecs)
	totalTime = min + ":" + sec + "." + msec


func update_time(time, name):
	Game.update_HS(Game.level1HS, time, name)
	Utils.saveGame()


func format_time_component(value):
	if value < 10:
		return "0" + str(floor(value))
	else:
		return str(floor(value))


func _on_bed_detector_body_entered(body):
	if "Player" in body.name:
		body.sleeping = true
		playerSleeping = true


func _on_bed_detector_body_shape_exited(body_rid, body, body_shape_index, local_shape_index):
	if "Player" in body.name:
		body.sleeping = false
		playerSleeping = false


func _on_arrow_bed_area_body_entered(body):
	player.hide_arrow()


func _on_arrow_bed_area_body_exited(body):
	if capturedChickens == totalChickens:
		player.show_arrow()


func pause_game():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	paused = true
	$Pause/Buttons.position = player.get_camera_position()
	$Pause.visible = true
	player.pause()
	for cow in cows:
		cow.pause()
	for chicken in chickens:
		chicken.pause()


func play_game():
	$Pause.visible = false
	player.play()
	for cow in cows:
		cow.play()
	for chicken in chickens:
		chicken.play()
	paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)		


func _on_play_button_up():
	play_game()


func _on_quit_button_up():
	get_tree().change_scene_to_file("res://Levels/title_screen.tscn")


func _on_restart_button_up():
	get_tree().reload_current_scene()
