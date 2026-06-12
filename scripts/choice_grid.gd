#  This Source Code Form is subject to the terms of the Mozilla Public
#  License, v. 2.0. If a copy of the MPL was not distributed with this
#  file, You can obtain one at https://mozilla.org/MPL/2.0/.

#  Copyright (c) 2026 Uizoh


@tool extends GridDisplay


signal sudoku_solved;

@onready var game: Node2D;
@onready var grid: GridDisplay = $".";

var selected_cell := Vector2i(0, 0);


func set_selected_cell(row: int, col: int) -> void:
	selected_cell.x = row;
	selected_cell.y = col;

func _ready() -> void:
	game = get_parent();
	create_choice_cells();


func create_choice_cells() -> void:
	for i in range(game.GRID_SIZE):
		var cell: Button = game.Cell.instantiate();
		cell.toggle_mode = false;
		cell.text = str(i+1);
		cell.choice_cell_pressed.connect(_on_choice_cell_pressed);
		grid.add_child(cell);
		cell.position = Vector2(game.CELL_SIZE.x * i, game.CELL_SIZE.y * 0);


func _on_choice_cell_pressed(num: String):
	var cell: Button = game.cells[selected_cell.x * game.GRID_SIZE + selected_cell.y];
	
	cell.text = num;
	
	if game.game_grid[selected_cell.x][selected_cell.y] == num:
		game.empty_cells_count -= 1;
		cell.self_modulate = Color.FOREST_GREEN;
		
		# Locking the cell
		cell.mouse_filter = Control.MOUSE_FILTER_IGNORE;
		cell.focus_mode = Control.FOCUS_NONE;
		cell.button_pressed = false;
	else: 
		game.mistake_count += 1;
		cell.self_modulate = Color.CRIMSON;
	
	if game.empty_cells_count == 0:
		sudoku_solved.emit();
