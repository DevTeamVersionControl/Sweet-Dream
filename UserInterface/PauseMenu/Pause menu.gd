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

const SWITCH = preload("res://UserInterface/Menu-Selection-Change-D2-www.fesliyanstudios.com.mp3")
const SELECT = preload("res://UserInterface/Game-Menu-Selection-Z-www.fesliyanstudios.com.mp3")

@onready var item_list := $ItemList
@onready var sound_menu := $SoundMenu
@onready var sound_effect := $AudioStreamPlayer

var index := 0

func _ready():
	for i in range(0,item_list.get_item_count()):
		item_list.set_item_tooltip_enabled(i,false)
	item_list.set_focus_mode(Control.FOCUS_NONE)
	item_list.select(index)

func input():
	if Input.is_action_pressed("ui_cancel"):
		if visible:
			resume()
		else:
			mouse_filter = Control.MOUSE_FILTER_STOP
			get_parent().request_pause()
			visible = true
			item_list.select(0)
			index = 0
	if sound_menu.visible:
		sound_menu.input(null)
	else:
		if visible:
			if Input.is_action_just_pressed("ui_accept") && visible:
				select_option()
			if Input.is_action_pressed("ui_up"):
				sound_effect.stream = SWITCH
				sound_effect.play()
				index = int(clamp(index - 1, 0, item_list.get_item_count()-1))
				item_list.select(index)
			if Input.is_action_pressed("ui_down"):
				sound_effect.stream = SWITCH
				sound_effect.play()
				index = int(clamp(index + 1, 0, item_list.get_item_count()-1))
				item_list.select(index)

func select_option():
	sound_effect.stream = SELECT
	sound_effect.play()
	match item_list.get_item_text(item_list.get_selected_items()[0]):
		"Save":
			GameSaver.obj_save()
		"Settings":
			load_settings()
		"Main menu":
			GameSaver.obj_save()
			GlobalVars.initialize()
			get_tree().paused = false
			get_tree().change_scene_to_file("res://UserInterface/MainMenu/MainMenu.tscn")
		"Close game":
			GameSaver.obj_save()
			get_tree().get_root().propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
			get_tree().quit()
		"Resume":
			resume()
		"Sound":
			sound_menu.show()
		"Controls":
			get_parent().input_menu.show()
		"Back":
			load_menu()
	
func resume():
	if visible:
		mouse_filter = Control.MOUSE_FILTER_PASS
		get_parent().request_unpause()
		visible = false
		index = 0

func load_settings():
	item_list.clear()
	item_list.add_item("Sound")
	item_list.add_item("Controls")
	item_list.add_item("Back")
	index = 0
	item_list.select(index)

func load_menu():
	item_list.clear()
	item_list.add_item("Save")
	item_list.add_item("Resume")
	item_list.add_item("Settings")
	item_list.add_item("Main menu")
	item_list.add_item("Close game")	
	index = 0
	item_list.select(index)

func _on_item_list_item_clicked(new_index, _at_position, _mouse_button_index):
	index = new_index
	select_option()
