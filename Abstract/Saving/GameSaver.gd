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

const DEFAULT_SAVE_PATH = "user://SaveData.json"

var save_path := DEFAULT_SAVE_PATH

func save():
	if not FileAccess.file_exists(save_path):
		return
	var save_data = get_save(save_path)
	for node in get_tree().get_nodes_in_group("save"):
		node.save(save_data)
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	file.store_line(JSON.stringify(save_data))
	file.close()

func load():
	var save_data : Dictionary = get_save(save_path)
	if save_data.size() == 0:
		return
	for node in get_tree().get_nodes_in_group("save"):
		node.load(save_data)

func partial_load(node:Node):
	var save_data : Dictionary = get_save(node.save_path)
	if save_data.size() == 0:
		return
	node.load(save_data)
	
func partial_save(node:Node) -> void:
	if not FileAccess.file_exists(node.save_path):
		return
	var save_data = get_save(node.save_path)
	node.save(save_data)
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	file.store_line(JSON.stringify(save_data))
	file.close()

func get_save(specific_save_path)->Dictionary:
	if not FileAccess.file_exists(specific_save_path):
		return {}
	var json_as_text = FileAccess.get_file_as_string(specific_save_path)
	var json_as_dict = JSON.parse_string(json_as_text)
	if json_as_text == "":
		return {}
	return json_as_dict
