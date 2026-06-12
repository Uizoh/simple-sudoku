#  This Source Code Form is subject to the terms of the Mozilla Public
#  License, v. 2.0. If a copy of the MPL was not distributed with this
#  file, You can obtain one at https://mozilla.org/MPL/2.0/.

#  Copyright (c) 2026 Uizoh


extends Node2D


@onready var click_ui_audio: AudioStreamPlayer = $ClickUI;
@onready var how_to_window: ColorRect = $HowToWindow;

const MainGame := preload("res://scenes/game.tscn");


func _ready() -> void:
	pass 


func _on_play_pressed() -> void:
	click_ui_audio.play();
	get_tree().change_scene_to_packed(MainGame);


func _on_how_to_pressed() -> void:
	click_ui_audio.play();
	how_to_window.visible = true;


func _on_close_pressed() -> void:
	click_ui_audio.play();
	how_to_window.visible = false;
