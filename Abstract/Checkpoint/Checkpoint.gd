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
extends Area2D

const CHECKPOINT = preload("res://Abstract/Checkpoint/Checkpoint.wav")

@onready var animation_player = $AnimationPlayer

@onready var description := "default description"

var player_is_in_zone := false

func _ready():
	update()
	get_tree().current_scene.connect("update_checkpoint", update)

func _on_Checkpoint_body_entered(body):
	if body is Player:
		player_is_in_zone = true

func _on_Checkpoint_body_exited(body):
	if body is Player:
		player_is_in_zone = false

func _input(_event):
	if player_is_in_zone && Input.is_action_just_pressed("interact") && not get_tree().paused:
		if get_tree().current_scene.checkpoint_on(name):
			GameSaver.obj_save()
			get_tree().current_scene.player.heal(999999)
			get_tree().current_scene.player.set_health_packs(999999)
			get_tree().current_scene.start_rest_menu()
			GlobalVars.play_sound(CHECKPOINT)
		else:
			var checkpoint = {"Name":name, "Level":get_tree().current_scene.current_level.scene_file_path, "Description":description}
			get_tree().current_scene.set_checkpoint(checkpoint)
			animation_player.play("Opening")
			await animation_player.animation_finished
			get_tree().current_scene.checkpoint_update()
			GameSaver.obj_save()

func get_spawn_position() -> Vector2:
	return global_position

func update():
	if get_tree().current_scene.checkpoint_on(name):
		animation_player.play("Opened")
	else:
		animation_player.play("RESET")
		await get_tree().create_timer(0.1).timeout
		animation_player.play("Closed")
