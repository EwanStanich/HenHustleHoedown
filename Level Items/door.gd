extends AnimatedSprite2D


var isOpened = 0

func _ready():
	play("Closed")


func _on_area_2d_body_entered(body):
	if "Player" in body.name:
		play("Open")
		if is_playing():
			set_frame_and_progress(1, 0)
		await animation_finished
		play("Opened")


func _on_area_2d_body_exited(body):
	if "Player" in body.name:
		play("Close")
		if is_playing():
			set_frame_and_progress(1, 0)
		await animation_finished
		play("Closed")
