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
var http_request
var score_name
var reconnect_http_request


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	for chicken in $Characters/Chickens.get_children():
		chickens.append(chicken)
		totalChickens += 1
	for cow in $Characters/Cows.get_children():
		chickens.append(cow)
	player = $Characters/Player
	player.set_bed($LevelItems/Bed.position)
	$UI/Chickns.text = str(capturedChickens) + "/" + str(totalChickens)
	$UI/ChicknIcon.play("Icon")
	player.set_camera_limits(369,5,514,6)
	label = $GameOver/Name
	http_request = $HighscoreHTTPRequest


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
		if (Input.is_key_pressed(KEY_TAB) or Input.is_key_pressed(KEY_ESCAPE)) and !paused and !gameOver:
			pause_game()
		if isEnteringName:
			if event is InputEventKey and event.is_pressed():
				var key_text = event.as_text()			
				if key_text == "Backspace":
					var new_text = label.text.substr(0, label.text.length() - 1)
					label.text = new_text
				elif key_text == "Enter" and !label.text.is_empty():
					Game.level1 = true
					$GameOver/FinalTime.visible = false
					$GameOver/Name.visible = false
					$GameOver/EnterName.visible = false
					$GameOver/Loading.visible = true
					Utils.saveGame()
					update_time(label.text)
				elif label.text.length() > 9:
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
		$UI/Chickns.text = str(capturedChickens) + "/" + str(totalChickens)
		if capturedChickens == totalChickens:
			player.show_arrow()
			player.show_sleep()


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
		if Game.isOffline:
			Game.level1 = true
			Utils.saveGame()
			get_tree().change_scene_to_file("res://Levels/title_screen.tscn")
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


func update_time(name):
	score_name = name
	var score_data = score_name + " " + totalTime
	var url = "https://api.lootlocker.io/game/leaderboards/21217/submit"
	print(Game.playerToken)
	var header = ["Content-Type: application/json", "x-session-token: %s" % Game.playerToken]
	var method = HTTPClient.METHOD_POST
	var request_data = {
		"score": round(time * 100),
		"member_id": str(randi_range(0, 10000)),
		"metadata": score_data
	}
	
	http_request.request(url, header, method, JSON.stringify(request_data))


func format_time_component(value):
	if value < 10:
		return "0" + str(floor(value))
	else:
		return str(floor(value))


func _on_bed_detector_body_entered(body):
	if "Player" in body.name:
		body.sleeping = true
		playerSleeping = true
		if capturedChickens == totalChickens:
			player.show_e_key()


func _on_bed_detector_body_shape_exited(body_rid, body, body_shape_index, local_shape_index):
	if "Player" in body.name:
		body.sleeping = false
		playerSleeping = false
		player.hide_e_key()


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


func _on_highscore_http_request_request_completed(result, response_code, headers, body):
	if response_code != 200:
		await get_tree().create_timer(1.0).timeout
		reconnect_http_request = $ReconnectHTTPRequest
		Game.isOffline = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)		
		$ErrorMessage.visible = true
	else:
		var json_object = JSON.new()
		body = body.get_string_from_utf8()
		json_object.parse(body)
		print(json_object.get_data())
		get_tree().change_scene_to_file("res://Levels/title_screen.tscn")


func _on_reconnect_http_request_request_completed(result, response_code, headers, body):
	if response_code != 200:
		await get_tree().create_timer(1.0).timeout
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		$ErrorMessage.visible = true
	elif Game.hasConnected:
		Game.isOffline = false
		print("Player token: ", Game.playerToken)
		retry_score()
	else:
		Game.isOffline = false
		Game.hasConnected = true
		var json_object = JSON.new()
		body = body.get_string_from_utf8()
		json_object.parse(body)
		Game.playerToken = json_object.get_data()["session_token"]
		print("Player token: ", Game.playerToken)
		retry_score()


func retry_score():
	var score_data = score_name + " " + totalTime
	var url = "https://api.lootlocker.io/game/leaderboards/21217/submit"
	print(Game.playerToken)
	var header = ["Content-Type: application/json", "x-session-token: %s" % Game.playerToken]
	var method = HTTPClient.METHOD_POST
	var request_data = {
		"score": round(time * 100),
		"member_id": str(randi_range(0, 10000)),
		"metadata": score_data
	}
	
	http_request.request(url, header, method, JSON.stringify(request_data))


func _on_reconnect_token_button_up():
	$ErrorMessage.visible = false
	var url = "https://api.lootlocker.io/game/v2/session/guest"
	var header = []
	var method = HTTPClient.METHOD_POST
	var request_data = {
	"game_key": "dev_9aa726187e614b59a9c6fcc28131cd8e",
	"game_version": "1.0.0",
	"player_identifier": "1",
	"development_mode": true
	}
	
	reconnect_http_request.request(url, header, method, JSON.stringify(request_data))
