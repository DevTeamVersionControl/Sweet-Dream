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
extends Control

signal dialog_end
signal talk

const SWITCH = preload("res://UserInterface/Menu-Selection-Change-D2-www.fesliyanstudios.com.mp3")
const SELECT = preload("res://UserInterface/Game-Menu-Selection-Z-www.fesliyanstudios.com.mp3")

@onready var item_list = $ItemList
@onready var description = $Description
@onready var sound_effect := $SoundEffect

var items
var index := 0

func start():
	item_list.set_focus_mode(FOCUS_NONE)
	item_list.select(0)
	item_list.clear()
	show()
	get_parent().request_pause()
	load_items()

func load_items() -> void:
	default_load()
	for i in items.size():
		item_list.add_item("Checkpoint " + str(i + 1))
		item_list.set_item_tooltip_enabled(i, false)
	if item_list.get_item_count() > 0:
		item_list.select(0)

func close_dialog()->void:
	if visible:
		visible = false
		get_parent().request_unpause()
		set_process_internal(false)
		emit_signal("dialog_end")

func input(_event):
	if visible:
		if Input.is_action_just_pressed("ui_cancel") or Input.is_action_pressed("show_inventory"):
			close_dialog()
			get_tree().get_root().set_input_as_handled()
		if Input.is_action_just_pressed("ui_select") or Input.is_action_just_pressed("ui_accept"):
			select_checkpoint()
		if Input.is_action_pressed("ui_down"):
			sound_effect.stream = SWITCH
			sound_effect.play()
			index = int(clamp(index + 1, 0, item_list.get_item_count()-1))
			item_list.select(index)
		if Input.is_action_pressed("ui_up"):
			sound_effect.stream = SWITCH
			sound_effect.play()
			index = int(clamp(index - 1, 0, item_list.get_item_count()-1))
			item_list.select(index)

func default_load():
	items = GlobalVars.visited_checkpoints

func select_checkpoint():
	sound_effect.stream = SELECT
	sound_effect.play()
	var selected_checkpoint = items[item_list.get_selected_items()[0]]
	get_tree().current_scene.checkpoint = selected_checkpoint
	get_tree().current_scene.load_with_checkpoint()
	close_dialog()

func _on_item_list_item_clicked(new_index, at_position, mouse_button_index):
	if index != -1:
		description.text = items[new_index]["Description"]
		index = new_index
		select_checkpoint()
