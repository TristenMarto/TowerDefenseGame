extends Node

func _ready():
	load_main_menu()

func on_new_game_pressed():
	get_node("MainMenu").queue_free()
	var game_scene = load("res://Scenes/MainScenes/game_scene.tscn").instantiate()
	game_scene.connect("game_finished", unload_game)
	add_child(game_scene)

func unload_game(result):
	get_node("GameScene").queue_free()
	var main_menu = load("res://Scenes/UIScenes/main_menu.tscn").instantiate()
	add_child(main_menu)
	load_main_menu()

func on_quit_pressed():
	get_tree().quit()

func load_main_menu():
	get_node("MainMenu/M/HB/NewGame").connect("pressed", on_new_game_pressed)
	get_node("MainMenu/M/HB/Quit").connect("pressed", on_quit_pressed)
