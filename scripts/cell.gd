#  This Source Code Form is subject to the terms of the Mozilla Public
#  License, v. 2.0. If a copy of the MPL was not distributed with this
#  file, You can obtain one at https://mozilla.org/MPL/2.0/.

#  Copyright (c) 2026 Uizoh


extends Button

signal choice_cell_pressed;

var row: int;
var col: int;

var choice_grid: GridDisplay;
var game: Node2D;


func _ready() -> void:
	game = get_tree().root.get_node("Game");
	choice_grid = game.get_node("ChoiceGrid");


func _on_pressed() -> void:
	game.cell_button_audio.play();
	
	if toggle_mode:
		pass
	else:
		choice_cell_pressed.emit(text);


func _on_toggled(toggled_on: bool) -> void:
	if toggled_on:
		choice_grid.set_selected_cell(row, col);
		choice_grid.visible = true;
	else:
		choice_grid.visible = false;
