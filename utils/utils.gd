class_name Utils

static func get_collision_layers(layers: Array[int]) -> float:
	var res: float = 0
	
	for layer in layers:
		if layer != 0:
			res += pow(2, layer-1)
	
	return res
