class_name PlayerController
extends Node

enum TEAM {CT, T}
const team_color = {
	TEAM.CT:Color.BLUE,
	TEAM.T:Color.RED
}
enum MOVEMODE {MOUSE, RANDOM, TARGET}

@onready var player_scene = preload("res://scenes/player/player.tscn")

var is_ready := false

func _ready():
	spawn_players()
	is_ready = true

func spawn_players():
	for child in get_children():
		child.free()
	
	
	var current_map = get_parent().find_child("MapController").currentMap as Map
	var ct_spawn_points = current_map.spawns.ct
	var t_spawn_points = current_map.spawns.t
	
	if ct_spawn_points.points[0] == null or t_spawn_points.points[0] == null:
		print("Spawn points missing")
		return
	
	for i in 10:
		var new_player = player_scene.instantiate() as Player
		var spawn_point: Node2D
		if i < 5:
			new_player.team = TEAM.CT
			spawn_point = ct_spawn_points.points.pop_at(randi_range(0, ct_spawn_points.points.size() -1))
			new_player.level = ct_spawn_points.level
			ct_spawn_points.erase(spawn_point)
		else:
			new_player.team = TEAM.T
			spawn_point =  t_spawn_points.points.pop_at(randi_range(0, t_spawn_points.points.size() -1))
			new_player.level = t_spawn_points.level
			t_spawn_points.erase(spawn_point)
		
		new_player.global_position = spawn_point.global_position
		new_player.movemode = MOVEMODE.MOUSE #TODO: change later
		
		add_child(new_player)
		
func _on_map_controller_map_loaded(currentMap):
	if is_ready:
		spawn_players()
