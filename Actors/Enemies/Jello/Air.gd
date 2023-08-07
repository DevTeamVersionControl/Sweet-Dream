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
extends JelloEnemyState

func enter(msg := {}) -> void:
	jello.animation_player.play("Air")
	if not msg.has("do_jump"):
		jello.velocity.y = -jello.JUMP_VELOCITY_Y
		jello.velocity.x = jello.JUMP_VELOCITY_X if jello.facing_right else -jello.JUMP_VELOCITY_X
	else:
		jello.animation_player.seek(1.0/24*17, true)

func physics_update(delta):
	if not is_equal_approx(1.0, jello.speed_scale):
		delta *= jello.speed_scale / 1.5
	jello.velocity.y += jello.GRAVITY
	var collision = jello.move_and_collide(jello.velocity * delta)
	if collision && jello.health > 0:
		# Keeps it from being stuck on a ceiling
		if collision.get_normal().y < -0.3:
			state_machine.transition_to("Land")
		else:
			jello.velocity = jello.velocity.bounce(collision.get_normal())
			collision = null
	# Turn around
	if jello.facing_right == (jello.velocity.x < 0):
		jello.facing_right = not jello.velocity.x < 0
		jello.sprite.flip_h = !jello.facing_right
