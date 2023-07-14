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
extends VBoxContainer

var effects := {}

func _ready():
	pass # Replace with function body.

func update_health(max_health = 10.0, current_health = 5.0):
	$HealthBar.max_value = max_health
	$HealthBar.value = current_health

func add_status_effect(status = GlobalTypes.STATUS.slow):
	if effects.has(status):
		effects[status].icon.get_children()[0].text = str(1 + int(effects[status].icon.get_children()[0].text))
		effects[status].instance.add_stack()
	else:
		effects[status] = GlobalTypes.Effect.new(add_icon(GlobalVars.get_effect(status).icon))
		match(status):
			GlobalTypes.STATUS.slow:
				effects[status].instance = GlobalVars.get_effect(status).ressource.instantiate()
				get_parent().add_child(effects[status].instance)
	get_tree().create_timer(8.0).connect("timeout", remove_status_effect.bind(status))

func add_icon(icon:CompressedTexture2D) -> HBoxContainer:
	var box = HBoxContainer.new()
	
	var label = Label.new()
	label.set("theme_override_font_sizes/font_size", 130)
	label.text = str(1)
	
	var texture = TextureRect.new()
	texture.texture = icon
	texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	texture.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	
	box.add_child(label)
	box.add_child(texture)
	$StatusEffects.add_child(box)
	return box

func remove_status_effect(status) -> void:
	if effects.has(status):
		if is_instance_valid(effects[status].instance):
			effects[status].instance.remove_stack()
			if int(effects[status].icon.get_children()[0].text) <= 1:
				effects[status].icon.queue_free()
				effects.erase(status)
			else:
				effects[status].icon.get_children()[0].text = str(int(effects[status].icon.get_children()[0].text) - 1)

