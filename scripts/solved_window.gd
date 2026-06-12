#  This Source Code Form is subject to the terms of the Mozilla Public
#  License, v. 2.0. If a copy of the MPL was not distributed with this
#  file, You can obtain one at https://mozilla.org/MPL/2.0/.

#  Copyright (c) 2026 Uizoh


extends Polygon2D


var game: Node2D;

@onready var time_taken: RichTextLabel = $TimeTaken;
@onready var mistakes_made: RichTextLabel = $MistakesMade;


func _ready() -> void:
	game = get_tree().root.get_node("Game");
	
	var time = get_time();
	
	time_taken.text += ("[color=coral]" + time);
	mistakes_made.text += ("[color=blue_violet]" + str(game.mistake_count)); 


func get_time() -> String:
	var time = int(game.time_passed);
	
	@warning_ignore("integer_division")
	var hours := int(time / 3600);
	@warning_ignore("integer_division")
	var mins := int((int(time) % 3600) / 60);
	var secs := int(time) % 60;
	
	return "%d:%02d:%02d" % [hours, mins, secs];


func _on_close_pressed() -> void:
	game.ui_button_audio.play();
	queue_free();
