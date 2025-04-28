extends Node2D

signal game_finished(result)

var map_node

var build_mode = false
var build_valid = false
var build_location
var build_tile
var build_type
var current_wave = 0
var enemies_in_wave = 0
var base_health = 100

func _ready():
	map_node = get_node("Map1")
	for i in get_tree().get_nodes_in_group("build_buttons"):
		i.pressed.connect(initiate_build_mode.bind(i.name))

func _process(_delta):
	if build_mode:
		update_tower_preview()

func _unhandled_input(event):
	if event.is_action_released("ui_cancel") and build_mode == true:
		cancel_build_mode()
	if event.is_action_released("ui_accept") and build_mode == true:
		verify_and_build()
		cancel_build_mode()

##
## Wave functions
##

func start_next_wave():
	var wave_data = retrieve_wave_data()
	await(get_tree().create_timer(0.2)).timeout
	spawn_enemies(wave_data)

func retrieve_wave_data():
	var wave_data = [["blue_tank", 2], ["blue_tank", 0.1], ["blue_tank", 1], ["blue_tank", 1], ["blue_tank", 0.1]]
	current_wave += 1
	enemies_in_wave = wave_data.size()
	return wave_data

func spawn_enemies(wave_data):
	for i in wave_data:
		var new_enemy = load("res://Scenes/Enemies/" + i[0] + ".tscn").instantiate()
		new_enemy.connect("base_damage", on_base_damage)
		map_node.get_node("Path").add_child(new_enemy, true)
		await(get_tree().create_timer(i[1])).timeout

func on_base_damage(damage):
	base_health -= damage
	if base_health <= 0:
		emit_signal("game_finished", false)
	else:
		get_node("UI").update_health_bar(base_health)

##
## Building functions
##
func initiate_build_mode(tower_type):
	if build_mode:
		cancel_build_mode()
	
	build_type = tower_type + "_t_1"
	build_mode = true
	get_node("UI").set_tower_preview(build_type, get_global_mouse_position())

func update_tower_preview():
	var mouse_position = get_local_mouse_position()
	var tilemap_layer = map_node.get_node("TileMapLayers/TowerExclusion")
	var current_tile = tilemap_layer.local_to_map(mouse_position)
	var tile_position_local = tilemap_layer.map_to_local(current_tile)
	
	if not tilemap_layer.get_cell_tile_data(current_tile):
		get_node("UI").update_tower_preview(tile_position_local, "fff")
		build_valid = true
		build_location = tile_position_local
		build_tile = current_tile
	else:
		get_node("UI").update_tower_preview(tile_position_local, "000")
		build_valid = false

func cancel_build_mode():
	build_mode = false
	build_valid = false
	get_node("UI/TowerPreview").free()

func verify_and_build():
	if build_valid:
		var new_tower = load("res://Scenes/Turrets/"+build_type+".tscn").instantiate()
		
		var turrets_node = map_node.get_node("Turrets")
		var tower_pos_in_turrets = turrets_node.to_local(map_node.get_node("TileMapLayers/TowerExclusion").to_global(build_location))
		
		new_tower.position = tower_pos_in_turrets
		new_tower.type = build_type
		new_tower.built = true
		new_tower.category = GameData.tower_data[build_type]["category"]
		map_node.get_node("Turrets").add_child(new_tower, true)
		map_node.get_node("TileMapLayers/TowerExclusion").set_cell(build_tile, 7, Vector2(1,0))
