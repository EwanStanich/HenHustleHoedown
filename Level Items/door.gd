extends AnimatedSprite2D


var isOpened = 0

func _ready():
	play("Closed")


func _on_area_2d_body_entered(body):
	if body.name == "Player":
		play("Open")
		if is_playing():
			set_frame_and_progress(1, 0)
		await animation_finished
		play("Opened")


func _on_area_2d_body_exited(body):
	if body.name == "Player":
		play("Close")
		if is_playing():
			set_frame_and_progress(1, 0)
		await animation_finished
		play("Closed")
