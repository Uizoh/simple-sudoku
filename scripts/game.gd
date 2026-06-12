#  This Source Code Form is subject to the terms of the Mozilla Public
#  License, v. 2.0. If a copy of the MPL was not distributed with this
#  file, You can obtain one at https://mozilla.org/MPL/2.0/.

#  Copyright (c) 2026 Uizoh


extends Node2D


const Cell := preload("res://scenes/cell.tscn");
const CellButtonGroup := preload("res://scenes/ButtonGroups/new_button_group.tres");
const SolvedWindow := preload("res://scenes/solved_window.tscn");

var MainMenu := load("res://scenes/main_menu.tscn");


@onready var ui_button_audio: AudioStreamPlayer = $ClickUI;
@onready var cell_button_audio: AudioStreamPlayer = $ClickCell;

@onready var grid: GridDisplay = $"Grid9x9";

var game_grid: Array[PackedStringArray];
var cells: Array[Button];

const CELL_SIZE: Vector2 = Vector2(64, 64);
const GRID_SIZE: int = 9;
const SUBGRID_SIZE: int = 3;

var rng = RandomNumberGenerator.new();

var difficulty: int;
var empty_cells_count: int = 0;
var mistake_count: int = 0;
var time_passed: float = 0.0;


func _ready() -> void:
	rng.randomize();
	difficulty = rng.randi_range(52, 82); # Percentage of cells being hidden
	
	resize_game_grid();
	generate_game_grid(0, 0);
	generate_ui_grid_cells();


func _process(dt: float) -> void:
	time_passed += dt;


func resize_game_grid() -> void: 
	game_grid.resize(GRID_SIZE) # Create columns
	for i in range(GRID_SIZE):
		game_grid[i].resize(GRID_SIZE); # Create rows


func is_valid(current_row: int, current_col: int, num: String) -> bool:
	for col in range(current_col):
		if game_grid[current_row][col] == num:
			return false;
	
	for row in range(current_row):
		if game_grid[row][current_col] == num:
			return false;
	
	@warning_ignore("integer_division")
	var subgrid := Vector2i(int(current_row / 3) * 3, int(current_col / 3) * 3);
	
	for row in range(subgrid.x, subgrid.x + SUBGRID_SIZE):
		for col in range(subgrid.y, subgrid.y + SUBGRID_SIZE):
			if game_grid[row][col] == num:
				return false;
	
	return true;


func calculate_next_row_col(row: int, col: int) -> Vector2i:
	var next := Vector2i(row, col);
	
	if next.x < 8:
		next.x += 1;
	else:
		next.x = 0;
		next.y += 1;
	
	return next;


func generate_game_grid(row: int, col: int) -> bool:
	# Base case
	if row >= GRID_SIZE or col >= GRID_SIZE:
		return true;
	
	for i in range(GRID_SIZE):
		var nums: PackedStringArray = ['1', '2', '3', '4', '5', '6', '7', '8', '9'];
		var weights: PackedFloat32Array = [1, 1, 1, 1, 1, 1, 1, 1, 1];
		
		var idx = rng.rand_weighted(weights);
		weights[idx] = 0;
		
		if is_valid(row, col, nums[idx]):
			game_grid[row][col] = nums[idx]; # Insert num
			
			var next = calculate_next_row_col(row, col);
			
			# Recursive call to the next cell
			if generate_game_grid(next.x, next.y):
				return true;
			else:
				game_grid[row][col] = '0';
	
	return false; # Backtrack if no solution found


func generate_ui_grid_cells() -> void:
	for row in range(GRID_SIZE):
		for col in range(GRID_SIZE):
			var cell: Button = Cell.instantiate();
			grid.add_child(cell);
			cells.append(cell); # Keep reference of each cell
			
			calculate_chance_of_empty_cell(cell, row, col);
			
			# Configure cell specific properties
			cell.position = Vector2(CELL_SIZE.x * row, CELL_SIZE.y * col);
			cell.button_group = CellButtonGroup;
			cell.row = row;
			cell.col = col;


func calculate_chance_of_empty_cell(cell: Button, row, col) -> void:
	var chance = rng.randi_range(0, 100);
	
	if chance > difficulty:
		cell.text = '';
		empty_cells_count += 1;
	else:
		cell.text = game_grid[row][col];
		
		# Disable cell interactivity 
		cell.mouse_filter = Control.MOUSE_FILTER_IGNORE;
		cell.focus_mode = Control.FOCUS_NONE;


func _on_refresh_pressed() -> void:
	ui_button_audio.play();
	# Reset game state
	empty_cells_count = 0;
	mistake_count = 0;
	time_passed = 0.0;
	
	for row in range(GRID_SIZE):
		for col in range(GRID_SIZE):
			game_grid[row][col] = '0';
	
	difficulty = rng.randi_range(52, 82); # Re-roll
	generate_game_grid(0, 0); # Re-generate game grid
	
	# Configure each cell with new values
	for row in range(GRID_SIZE):
		for col in range(GRID_SIZE):
			var cell_idx: int = row * GRID_SIZE + col;
			var cell = cells[cell_idx];
			
			# Enable cell interactivity
			cell.mouse_filter = Control.MOUSE_FILTER_STOP;
			cell.focus_mode = Control.FOCUS_ALL;
			cell.button_pressed = false;
			
			cell.self_modulate = Color.WHITE; # Reset cell colour
			calculate_chance_of_empty_cell(cell, row, col);


func _on_back_pressed() -> void:
	ui_button_audio.play(); 
	get_tree().change_scene_to_packed(MainMenu);


func _on_sudoku_solved() -> void:
	add_child(SolvedWindow.instantiate());
