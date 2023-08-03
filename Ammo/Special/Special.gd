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

#The very special attack

@export var SPEED = 400

@export var enemy_knockback := Vector2(1,1)

var direction = Vector2.ZERO
var damage_tick := true
var damage_tick_timer := 0.05

func _physics_process(delta):
	position += delta * SPEED * direction
	if not damage_tick:
		damage_tick_timer -= delta
		if damage_tick_timer <= 0.0:
			damage_tick_timer = 0.05
			damage_tick = true
	for body in get_overlapping_bodies():
		if body.is_in_group("enemy") && damage_tick:
			damage_tick = false
			$AudioStreamPlayer.play()
			body.take_damage(0.5, direction * enemy_knockback)

func launch(bullet_direction : Vector2, _strength) -> void:
	direction = bullet_direction.normalized()
	rotation = direction.angle()
	if direction.angle() > PI/2:
		$Sprite2D.flip_v = true
