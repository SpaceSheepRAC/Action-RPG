extends Camera2D

func _ready():
	auto_set_limits()

func auto_set_limits():
	limit_left = 0
	limit_right = 0
	limit_top = 0
	limit_bottom = 0
	var tilemaps = get_tree().get_nodes_in_group("tilemap")
	for tilemap in tilemaps:
		if tilemap is TileMap:
			var used = tilemap.get_used_rect()
			limit_left = min(used.position.x * tilemap.cell_size.x, limit_left)
			limit_right = max(used.end.x * tilemap.cell_size.x, limit_right)
			limit_top = min(used.position.y * tilemap.cell_size.y, limit_top)
			limit_bottom = max(used.end.y * tilemap.cell_size.y, limit_bottom)
