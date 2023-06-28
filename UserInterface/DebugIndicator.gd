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
extends CanvasLayer

@export var trigger : NodePath
@export var target_player = false

@onready var trigger_obj = get_node_or_null(trigger)


func _ready():
	if target_player:
		await get_tree().create_timer(0.2).timeout
		get_tree().current_scene.player.connect("debug_update", Callable(self, "on_update"))
	elif trigger_obj:
		trigger_obj.connect("debug_update", Callable(self, "on_update"))

func on_update(vari):
	$Label.set_text(String(vari))
