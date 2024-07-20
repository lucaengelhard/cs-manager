class_name PolygonRandPointGenerator



static func generate(polygon: PackedVector2Array)-> Vector2:
	var trianglesPoints := Geometry2D.triangulate_polygon(polygon)
	var triangle_count: int = trianglesPoints.size() / 3
	
	var triangles: Array[PackedVector2Array]
	
	for i in range(triangle_count):
		var a: Vector2 = polygon[trianglesPoints[3 * i + 0]]
		var b: Vector2 = polygon[trianglesPoints[3 * i + 1]]
		var c: Vector2 = polygon[trianglesPoints[3 * i + 2]]
		
		triangles.append(PackedVector2Array([a,b,c]))
	
	var random_triangle := triangles[randi_range(0, triangles.size() -1)]
	
	return random_triangle_point(random_triangle[0],random_triangle[1],random_triangle[2])

static func triangle_area(a: Vector2, b: Vector2, c: Vector2) -> float:
	return 0.5 * abs((c.x - a.x) * (b.y - a.y) - (b.x - a.x) * (c.y - a.y))

static func random_triangle_point(a: Vector2, b: Vector2, c: Vector2) -> Vector2:
	return a + sqrt(randf()) * (-a + b + randf() * (c - b))
