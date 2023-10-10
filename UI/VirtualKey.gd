extends Node2D

func _on_ButtonA_pressed():
	Input.action_press("attack")


func _on_ButtonA_released():
	Input.action_release("attack")


func _on_ButtonB_pressed():
	Input.action_press("roll")


func _on_ButtonB_released():
	Input.action_release("roll")
