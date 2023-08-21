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
signal update_checkpoint

const PLAYER = preload("res://Actors/Player/Player.tscn")

@export_file("*.tscn") var first_level : String

@onready var gui = $GUI
@onready var level_transition = gui.color_rect.get_material()
@onready var hud = $HUD
@onready var shaker = $Shaker
@onready var checkpoint = {"Name":"Checkpoint", "Level":first_level, "Description":"The first checkpoint"}

var current_level : Node2D
var next_level : PackedScene
var door_location : String
var player : Player

func _ready():
	checkpoint = {"Name":"Checkpoint", "Level":first_level, "Description":"The first checkpoint"}
	GlobalVars.initialize()
	var save_data = GameSaver.get_save("user://MoreSettings.json")
	hud.set_physics_process_internal(false)
	if save_data.has("Timer"):
		if save_data["Timer"]:
			hud.activate_timer()
	load_level(load(checkpoint["Level"]), checkpoint["Name"])
	checkpoint_update()

func obj_save(game_data):
	game_data["current_checkpoint"] = checkpoint

func obj_load(game_data):
	checkpoint = game_data["current_checkpoint"]

func change_level(new_level:String, portal_name:String):
	var tween = get_tree().create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(level_transition, "shader_parameter/dissolve_state", 2, 1)
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
	tween.tween_property(level_transition, "shader_parameter/dissolve_state", 0, 1)
	next_level = null
	gui.map.set_level(current_level.name)
	GlobalVars.apply_items()
	GameSaver.obj_load()
	emit_signal("level_loaded")

func die():
	for item in GlobalVars.inventory:
		if item.has("Fragile"):
			GlobalVars.remove_from_inventory(item["Name"])
	GlobalVars.health_packs = GlobalVars.max_health_packs
	GlobalVars.health = GlobalVars.max_health
	load_with_checkpoint()
	

func load_with_checkpoint():
	next_level = load(checkpoint["Level"])
	call_deferred("load_level", next_level, checkpoint["Name"])

func set_checkpoint(new_checkpoint):
	checkpoint = new_checkpoint

func checkpoint_on(checkpoint_name) -> bool:
	return (checkpoint["Name"] == checkpoint_name) && (current_level.scene_file_path == checkpoint["Level"])

func start_dialog(dialog_file:String, story_point:int):
	gui.dialog.start(dialog_file, story_point)
	gui.request_pause()

func start_shop(shop_file:String, multiplier = 1.0):
	gui.shop.start(shop_file, multiplier)
	gui.request_pause()

func start_rest_menu():
	gui.rest_menu.start()

func checkpoint_update():
	emit_signal("update_checkpoint")
	if not GlobalVars.visited_checkpoints.has(checkpoint):
		GlobalVars.visited_checkpoints.append(checkpoint)
