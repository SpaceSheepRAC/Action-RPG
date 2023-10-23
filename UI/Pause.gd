extends Popup


func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		show()
		get_tree().paused = true


func _on_Button_pressed():
	hide()
	get_tree().paused = false
