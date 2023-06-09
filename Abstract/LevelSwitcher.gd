# Sweet Dream, a sweet metroidvannia
#    Copyright (C) 2022 Kamran Charles Nayebi and William Duplain
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <https://www.gnu.org/licenses/>.
extends Node

signal level_loaded

const PLAYER = preload("res://Actors/Player/Player.tscn")

@onready var gui = $GUI
@onready var level_transition = gui.color_rect
@onready var hud = $HUD
@onready var shaker = $Shaker

@export var first_level : PackedScene 

var current_level : Node2D
var next_level : PackedScene
var door_location : String
var player : Player
var checkpoint = GlobalTypes.Checkpoint.new("Checkpoint",first_level)

func _ready():
	checkpoint = GlobalTypes.Checkpoint.new("Checkpoint",first_level)
	GlobalVars.initialize()
	var save_data = GameSaver.get_save("user://MoreSettings.json")
	hud.set_physics_process_internal(false)
	if save_data.has("Timer"):
		if save_data["Timer"]:
			hud.activate_timer()
	load_level(checkpoint.level, checkpoint.name)

func obj_save(game_data):
	game_data["checkpoint_level"] = checkpoint.level.resource_path
	game_data["checkpoint_name"] = checkpoint.name

func obj_load(game_data):
	checkpoint = GlobalTypes.Checkpoint.new(game_data["checkpoint_name"], load(game_data["checkpoint_level"]))

func change_level(new_level:String, portal_name:String):
	var tween = get_tree().create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(level_transition, "self_modulate", Color(0, 0, 0, 1), 1)
	tween.tween_callback(Callable(self, "_on_animation_finished").bind(new_level))
	gui.request_pause()
	door_location = portal_name

func _on_animation_finished(new_level:String):
	next_level = load(new_level)
	if next_level != null:
		load_level(next_level, door_location)
		gui.request_unpause()

func load_level(level:PackedScene, location:String):
	GameSaver.obj_save()
	if current_level != null:
		current_level.queue_free()
		remove_child(current_level)
	current_level = level.instantiate()
	add_child(current_level)
	player = PLAYER.instantiate()
	player.level_limit_min = Vector2(current_level.level_range_x.x, current_level.level_range_y.x)
	player.level_limit_max = Vector2(current_level.level_range_x.y, current_level.level_range_y.y)
	current_level.add_child(player)
	hud.connect_player()
	if location != "":
		var door_node = current_level.find_child(location)
		if door_node:
			player.camera.position_smoothing_enabled = false
			player.global_position = door_node.get_spawn_position()
	player.level_limit_min = Vector2(current_level.level_range_x.x, current_level.level_range_y.x)
	player.level_limit_max = Vector2(current_level.level_range_x.y, current_level.level_range_y.y)
	shaker.camera = player.camera
	var tween = get_tree().create_tween()
	tween.tween_property(level_transition, "self_modulate", Color(0, 0, 0, 0), 1)
	next_level = null
	gui.map.set_level(current_level.name)
	GlobalVars.apply_items()
	GameSaver.obj_load()
	emit_signal("level_loaded")

func die():
	next_level = checkpoint.level
	GlobalVars.health_packs = GlobalVars.max_health_packs
	GlobalVars.health = GlobalVars.max_health
	GlobalVars.sugar = GlobalVars.max_sugar
	call_deferred("load_level", next_level, checkpoint.name)

func set_checkpoint(new_checkpoint):
	checkpoint = new_checkpoint

func checkpoint_on(checkpoint_name) -> bool:
	return (checkpoint.name == checkpoint_name) && (load(current_level.scene_file_path) == checkpoint.level)

func start_dialog(dialog_file:String, story_point:int):
	gui.dialog.start(dialog_file, story_point)
	gui.request_pause()

func start_shop(shop_file:String, multiplier = 1.0):
	gui.shop.start(shop_file, multiplier)
	gui.request_pause()

func start_rest_menu():
	gui.rest_menu.start()
	gui.request_pause()
