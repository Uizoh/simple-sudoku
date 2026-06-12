class_name Game
extends Node2D

const Cell: PackedScene = preload("res://scenes/cell.tscn");
@onready var Grid: GridDisplay = $"Grid9x9";

var game_grid: Array[PackedStringArray];

const starting_points: Array[Vector2i] = [
	Vector2i(0, 0), Vector2i(0, 3), Vector2i(0, 6),
	Vector2i(3, 0), Vector2i(3, 3), Vector2i(3, 6),
	Vector2i(6, 0), Vector2i(6, 3), Vector2i(6, 6),
];

const CELL_SIZE: Vector2 = Vector2(64, 64);
const GRID_SIZE: int = 9;
const CUBICAL_SIZE: int = 3;

var rng = RandomNumberGenerator.new();

enum Difficulty {
	easy = 68,
	medium = 58,
	hard = 42
};

func _ready() -> void:
	rng.randomize();
	generate_game_grid();
	generate_ui_grid_cells();


func resize_game_grid() -> void: 
	game_grid.resize(GRID_SIZE) # Create columns
	for i in range(GRID_SIZE):
		game_grid[i].resize(GRID_SIZE); # Create rows


func calculated_weight(weights: PackedFloat32Array, current_col: int, current_row: int) -> PackedFloat32Array:
	var sub_weights = weights.duplicate();
	var val: int;
	
	for col in range(GRID_SIZE):
		if col == current_col:
			continue
		
		val = int(game_grid[col][current_row]);
		if val != 0:
			sub_weights[val - 1] = 0;
		
	for row in range(GRID_SIZE):
		if row == current_row:
			continue
		
		val = int(game_grid[current_col][row]);
		if val != 0:
			sub_weights[val - 1] = 0;
	
	return sub_weights;

func generate_game_grid() -> void:
	resize_game_grid();

	for i in range(GRID_SIZE):
		var col: int = starting_points[i].x;
		var row: int = starting_points[i].y;
		
		var nums: PackedStringArray = ['1', '2', '3', '4', '5', '6', '7', '8', '9'];
		var weights: PackedFloat32Array = [1, 1, 1, 1, 1, 1, 1, 1, 1];
		
		for c in range(col, col + CUBICAL_SIZE):
			for r in range(row, row + CUBICAL_SIZE):
				var idx = rng.rand_weighted(calculated_weight(weights, c, r));
				game_grid[c][r] = nums[idx]; # Insert elements for each row
				weights[idx] = 0;
	
	print(game_grid);


func generate_ui_grid_cells() -> void:
	for col in range(GRID_SIZE):
		for row in range(GRID_SIZE):
			var cell = Cell.instantiate();
			Grid.add_child(cell);
			
			
			if chance_of_empty_cell():
				cell.text = '';
			else: 
				cell.text = game_grid[col][row];
			
			cell.position = Vector2(CELL_SIZE.x * row, CELL_SIZE.y * col);



func chance_of_empty_cell() -> bool:
	var chance = rng.randi_range(0, 100);
	
	if chance > Difficulty.easy:
		return true
	else:
		return false
