extends AnimatedSprite2D

@onready var anim = $AnimationPlayer

#func _input(event):
	#if event is InputEventKey:
		#if Input.is_key_pressed(KEY_E):
			#open_gate()
		#if Input.is_key_pressed(KEY_TAB):
			#close_gate()

func open_gate():
	anim.play("Opening")
	await anim.animation_finished
	print("yes")

func close_gate():
		anim.play("Closing")
