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
const SELECTED_SPRITE = preload("res://UserInterface/Inventory/selected.png")

@onready var item_list = $ItemList
@onready var description = $Description
@onready var money = $Money
@onready var selected1 := $Slot1/Selected
@onready var selected2 := $Slot2/Selected
@onready var texture1 := $Slot1/TextureRect
@onready var texture2 := $Slot2/TextureRect
@onready var sound_effect := $SoundEffect
@onready var icon_container := $IconContainer
@onready var selected_container := $SelectedContainer

var items
var ammo := []
var item_list_focus := true
var ammo_select_focus := false
var index := 0

func start():
	item_list.set_focus_mode(FOCUS_NONE)
	item_list.select(0)
	item_list.clear()
	show()
	get_parent().request_pause()
	load_items()
	money.text = "Artifacts : " + str(GlobalVars.artifacts)
	if GlobalVars.ammo_equipped_array[0] != null:
		texture1.texture = load(GlobalVars.get_from_inventory(GlobalVars.ammo_equipped_array[0].name)["Icon"])
	if GlobalVars.ammo_equipped_array[1] != null:
		texture2.texture = load(GlobalVars.get_from_inventory(GlobalVars.ammo_equipped_array[1].name)["Icon"])

func load_items() -> void:
	default_load()
	for i in items.size():
		item_list.add_item(items[i]["Name"])
		item_list.set_item_tooltip_enabled(i,false)
	if item_list.get_item_count() > 0:
		item_list.select(0)
		item_list_focus = true

func close_dialog()->void:
	if visible:
		visible = false
		get_parent().request_unpause()
		set_process_internal(false)
		emit_signal("dialog_end")

func _input(_event):
	if visible:
		if Input.is_action_just_pressed("ui_cancel") or Input.is_action_pressed("show_inventory"):
			close_dialog()
			get_tree().get_root().set_input_as_handled()
		if Input.is_action_just_pressed("ui_select") or Input.is_action_just_pressed("ui_accept"):
			if not item_list_focus:
				sound_effect.stream = SELECT
				sound_effect.play()
				if not ammo_select_focus:
					index = 0
					ammo_select_focus = true
					selected_container.get_children()[index].texture = SELECTED_SPRITE
				else:
					if selected1.visible:
						select_item(0)
					else:
						select_item(1)
		if Input.is_action_pressed("ui_right"):
			if ammo_select_focus:
				sound_effect.stream = SWITCH
				sound_effect.play()
				selected_container.get_children()[index].texture = null
				index = int(clamp(index + 1, 0, selected_container.get_children().size()-1))
				selected_container.get_children()[index].texture = SELECTED_SPRITE
			else:
				if selected1.visible:
					selected2.show()
					selected1.hide()
				elif selected2.visible:
					selected1.show()
					selected2.hide()
				else:
					selected1.show()
					item_list.deselect_all()
					item_list_focus = false
		if Input.is_action_pressed("ui_left"):
			if ammo_select_focus:
				sound_effect.stream = SWITCH
				sound_effect.play()
				selected_container.get_children()[index].texture = null
				index = int(clamp(index - 1, 0, selected_container.get_children().size()-1))
				selected_container.get_children()[index].texture = SELECTED_SPRITE
			else:
				if selected1.visible:
					selected1.hide()
					item_list_focus = true
					index = 0
					item_list.select(index)
					_on_item_list_item_selected(index)
				elif selected2.visible:
					selected2.hide()
					item_list_focus = true
					index = 0
					item_list.select(index)
					_on_item_list_item_selected(index)
				else:
					selected2.show()
					item_list.deselect_all()
					item_list_focus = false
		if Input.is_action_pressed("ui_down"):
			if item_list_focus:
				sound_effect.stream = SWITCH
				sound_effect.play()
				index = int(clamp(index + 1, 0, item_list.get_item_count()-1))
				item_list.select(index)
				_on_item_list_item_selected(index)
			else:
				if selected1.visible:
					selected1.hide()
					selected2.show()
				elif selected2.visible:
					selected2.hide()
					item_list_focus = true
					index = 0
					item_list.select(index)
					_on_item_list_item_selected(index)
		if Input.is_action_pressed("ui_up"):
			if item_list_focus:
				sound_effect.stream = SWITCH
				sound_effect.play()
				index = int(clamp(index - 1, 0, item_list.get_item_count()-1))
				item_list.select(index)
				_on_item_list_item_selected(index)
			else:
				if selected1.visible:
					selected1.hide()
					item_list_focus = true
					item_list.select(0)
					_on_item_list_item_selected(0)
				elif selected2.visible:
					selected1.show()
					selected2.hide()
	else:
		if Input.is_action_pressed("show_inventory"):
			start()

func select_item(new_index : int) -> void:
	while GlobalVars.ammo_equipped_array.size() < 2:
		GlobalVars.ammo_equipped_array.append(null)
	GlobalVars.ammo_equipped_array[new_index] = GlobalVars.get_ammo(ammo[index]["Name"])
#	if new_index == 0:
#		texture1.texture = load(ammo[index]["Icon"])
#	else:
#		texture2.texture = load(ammo[index]["Icon"])
	if GlobalVars.ammo_equipped_array[0] != null:
		texture1.texture = load(GlobalVars.get_from_inventory(GlobalVars.ammo_equipped_array[0].name)["Icon"])
	if GlobalVars.ammo_equipped_array[1] != null:
		texture2.texture = load(GlobalVars.get_from_inventory(GlobalVars.ammo_equipped_array[1].name)["Icon"])
	ammo_select_focus = false
	selected_container.get_children()[index].texture = null
	get_tree().current_scene.player.update_display()

func default_load():
	for i in icon_container.get_child_count():
		if i > 0:
			icon_container.get_children()[i].queue_free()
			selected_container.get_children()[i].queue_free()
		else:
			icon_container.get_children()[i].texture = null
	items = GlobalVars.inventory.duplicate(true)
	for item in items:
		if not item.has("Description"):
			items.erase(item)
		if item.has("Ammo"):
			ammo.append(item)
			if icon_container.get_children()[0].texture != null:
				icon_container.add_child(icon_container.get_children()[icon_container.get_children().size()-1].duplicate())
				selected_container.add_child(selected_container.get_children()[selected_container.get_children().size()-1].duplicate())
				selected_container.get_children()[selected_container.get_children().size()-1].texture = null
			icon_container.get_children()[icon_container.get_children().size()-1].texture = load(item["Icon"])

func _on_item_list_item_selected(new_index):
	description.text = items[new_index]["Description"]
	index = new_index
