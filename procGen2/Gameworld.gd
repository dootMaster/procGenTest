extends Node2D
class_name Gameworld

signal started
signal finished

enum Cell {OBSTACLES, GROUND, OUTER}

export var inner_size := Vector2(10, 8)
export var perimeter_size := Vector2(1, 2)
#export(float, 0, 1) var ground_probability := 0.1
export(float, 0, 1) var crack_probability := 0.1

# public variables
var size := inner_size + 2 * perimeter_size

# private variables
onready var _border_map: TileMap = $wall_layer
onready var _floor_map: TileMap = $ground_layer
var _rng := RandomNumberGenerator.new()
var _treeRNG := RandomNumberGenerator.new()
var Player = preload('res://PlayerChar/Elf_F.tscn')
var player = null

# --
func _ready() -> void:
	_rng.randomize()
	_treeRNG.randomize()
	setup()
	generate()
	player = Player.instance()
	add_child(player)
	player.position = Vector2(100, 100)
	
func setup() -> void:
	var map_size_px := size * _border_map.cell_size
	get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_2D, SceneTree.STRETCH_ASPECT_KEEP, map_size_px)
	OS.set_window_size(2 * map_size_px)
	
func generate() -> void:
	emit_signal('started')
	_generate_perimeter()
	_generate_inner()
	emit_signal("finished")
	
func _generate_perimeter() -> void:
	# corner wall tiles
	_border_map.set_cell(0, 0, 5)
	_border_map.set_cell(size.x - 1, 0, 6)
	_border_map.set_cell(0, size.y - 2, 7)
	_border_map.set_cell(size.x - 1, size.y - 2, 8)
	# left & right walls
	for y in range(1, size.y - 2):
		_border_map.set_cell(0, y, 3)
		_border_map.set_cell(size.x - 1, y, 4)
	#top & bottom walls
	for x in range(1, size.x - 1):
		for y in [0, size.y - 2]:
			_border_map.set_cell(x, y, 1)		
	
func _generate_inner() -> void:
	for x in range(0, size.x):
		for y in range(2, size.y - 1):
			var cell := _get_random_floor(crack_probability)
			_floor_map.set_cell(x, y, cell)
			
func get_random_tile(probability: int) -> int:
	return _pick_random_texture(Cell.GROUND) if _rng.randf() > probability else _pick_random_texture(Cell.OBSTACLES)
	
func _pick_random_texture(cell_type: int) -> int:
	var interval := Vector2()
	#if cell_type == Cell.OUTER:
	#	interval = Vector2(0, 0)
	if cell_type == Cell.GROUND:
		interval = Vector2(1, 7)
	#elif cell_type == Cell.OBSTACLES:
	#	interval = Vector2(0, 0)
	return _rng.randi_range(interval.x, interval.y)
	
func _get_random_floor(crack_probability: float) -> int:
	return 0 if _rng.randf() > crack_probability else _pick_random_texture(Cell.GROUND)
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed('ui_select'):
		generate()
