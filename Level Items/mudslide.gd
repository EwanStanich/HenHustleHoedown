extends AnimatedSprite2D


func _ready():
	play("default")


func _on_slip_zone_body_entered(body):
	if "Player" in body.name or "Chicken" in body.name:
		var distance1 = $AwayFrom.get_global_position().distance_to(body.position)
		var distance2 = $AwayFrom2.get_global_position().distance_to(body.position)
		if distance1 > distance2:
			body.mudslide($AwayFrom2.get_global_position())			
		else:
			body.mudslide($AwayFrom.get_global_position())


func _on_slip_zone_body_exited(body):
	if "Player" in body.name or "Chicken" in body.name:
		body.isSliding = false
