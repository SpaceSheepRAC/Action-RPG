extends Node2D

onready var joystick = $CanvasLayer/Joystick

func _ready():
	joystick.visible = false

func _input(event):
	if (event is InputEventScreenTouch) && event.is_pressed():
		joystick.visible = true
		joystick.position = event.position
	elif (event is InputEventScreenTouch) && !event.is_pressed():
		joystick.visible = false
		joystick.position = event.position
