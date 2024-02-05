extends ParallaxBackground


@export var scrollSpeed = 40


func _physics_process(delta):
	scroll_offset.x -= scrollSpeed * delta
