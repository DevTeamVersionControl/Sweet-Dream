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

#Defines enums and classes visible for all objects
enum AMMO_TYPE{once, charge, constant}
enum STATUS{slow}

class Ammo:
	var name : String
	var type : int
	var cooldown : float
	var damage : float
	var sugar : float
	var scene : PackedScene
	var texture : Texture2D
	func _init(ammo_name, ammo_type, ammo_cooldown, ammo_damage, ammo_sugar, ammo_scene, ammo_texture):
		name = ammo_name
		type = ammo_type
		cooldown = ammo_cooldown
		damage = ammo_damage
		sugar = ammo_sugar
		scene = ammo_scene
		texture = ammo_texture

class Checkpoint:
	var name:String
	var level:PackedScene
	func _init(init_name, init_level):
		name = init_name
		level = init_level

class ConstEffect:
	var type:STATUS
	var ressource:PackedScene
	var icon
	func _init(init_type:STATUS, init_ressource:PackedScene, init_icon):
		type = init_type
		ressource = init_ressource
		icon = init_icon

class Effect:
	var instance
	var icon
	func _init(init_icon, init_instance = null):
		instance = init_instance
		icon = init_icon
