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
extends PlayerState

func enter(_msg := {}) -> void:
	player.camera_arm.position.y = 20.0
	player.velocity.x = 0
	player.animation_tree.set('parameters/Crouched/blend_position', 1 if player.facing_right else -1)
	player.animation_tree.set('parameters/Crouch/blend_position', 1 if player.facing_right else -1)
	player.animation_mode.travel("Crouched")
	player.camera_arm.position.x = 127 if player.facing_right else -127

func physics_update(delta: float) -> void:
	if not player.is_on_floor():
		state_machine.transition_to("Air")
		return
	
	player.velocity.y += player.GRAVITY * delta
	player.velocity.x = 0
	player.set_velocity(player.velocity)
	player.set_up_direction(Vector2.UP)
	player.move_and_slide()
	player.velocity = player.velocity
	
	if Input.is_action_just_pressed("move_up"):
		state_machine.transition_to("Air", {do_jump = true})
		player.camera_arm.position.y = -28.0
	elif Input.is_action_pressed("shoot") && GlobalVars.ammo_equipped_array.size() != 0 && player.can_shoot && GlobalVars.ammo_equipped_array[GlobalVars.equiped_ammo_index] != null:
		state_machine.transition_to("Aim", {crouched = true})
	elif !Input.is_action_pressed("crouch"):
		state_machine.transition_to("Idle")
		player.camera_arm.position.y = -28.0
	elif Input.is_action_pressed("special"):
			if GlobalVars.sugar >= GlobalVars.special_attack_sugar:
				state_machine.transition_to("Aim", {special = true})
				player.camera_arm.position.y = -28.0
