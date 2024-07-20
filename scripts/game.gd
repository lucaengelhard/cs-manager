extends Node2D

@onready var map := $Map
@onready var player_scene = load("res://scenes/player.tscn")
@onready var player_node = $Player

var players: Array[Player]

# Called when the node enters the scene tree for the first time.
func _ready():
	var ctSpawn: Area2D = map.ctSpawn
	var tSpawn: Area2D = map.tSpawn
	
	var ctSpawn_area: CollisionPolygon2D = ctSpawn.get_child(0)
	var tSpawn_area: CollisionPolygon2D = tSpawn.get_child(0)
	
	if ctSpawn_area is CollisionPolygon2D && tSpawn_area is CollisionPolygon2D:
		for i in range(10):
			if i < 5:
				spawnPlayer(Player.TEAM.CT, ctSpawn_area)
			else:
				spawnPlayer(Player.TEAM.T, tSpawn_area)
		
	return
	# TODO: spawn within spawn regions
	for i in range(10):
		add_child(Player.new())
		
	for child in get_children():
		if child is Player:
			players.append(child)
			
	for player in players:
		player.player_dead.connect(_on_player_dead)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _draw():
	draw_circle(Vector2(408, -215.5921),10, Color.RED)

func spawnPlayer(team: Player.TEAM, spawn_area:CollisionPolygon2D, id: int = 0):
	var spawnpoint := PolygonRandPointGenerator.generate(spawn_area.polygon)
	
	var newNode = Player.new()
	
	assert(player_scene is PackedScene)
	var instance = player_scene.instantiate()
	assert(instance is CharacterBody2D)
		
	for child in instance.get_children():
		if child.get_parent():
			child.get_parent().remove_child(child)
			
		newNode.add_child(child)
		
	newNode.team = team
	newNode.movemode = Player.MOVEMODE.Random
	
	newNode.collision_layer =  pow(2, 2-1)
	newNode.collision_mask =  pow(2, 3-1)
	
	newNode.global_position = spawn_area.global_position + spawnpoint 
	# TODO: Works, aber muss runterskaliert werden, weil Karte skaliert wurde
	
	add_child(newNode)
	#instance.global_position = spawn_area.global_position + spawnpoint # TODO: Works, aber muss runterskaliert werden, weil Karte skaliert wurde
	#add_child(instance)


func _on_player_dead(player: Player):
	print(player)
