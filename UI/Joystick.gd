extends Sprite

onready var button = $Button

var maxLen = 96
var ondraging = -1

signal position_changed(joystick_position)

func _input(event):
	if (event is InputEventScreenDrag) || ((event is InputEventScreenTouch) && event.is_pressed()):
		
		var mouse_distance = (event.position - self.global_position).length()
		
		if (mouse_distance <= (maxLen * 0.25)) || (event.get_index() == ondraging):
			ondraging = event.get_index()
			button.global_position = event.position
			
			if button.position.length() > maxLen:
				button.position = button.position.normalized() * maxLen
		emit_signal("position_changed",button.position.normalized())
		
	elif (event is InputEventScreenTouch) && !event.is_pressed():
		if event.get_index() == ondraging:
			button.position = Vector2.ZERO
			emit_signal("position_changed", Vector2.ZERO)
			ondraging = -1
