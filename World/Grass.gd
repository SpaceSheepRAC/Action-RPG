extends Node2D

const GrassEffects = preload("res://Effects/GrassEffect.tscn")

func create_grass_effect():
	var grassEffects = GrassEffects.instance()
	get_parent().add_child(grassEffects)
	grassEffects.global_position = global_position

func _on_HurtBox_area_entered(_area):
	create_grass_effect()
	queue_free()
