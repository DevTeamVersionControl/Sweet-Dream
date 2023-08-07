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
extends JawbreakerState

@onready var timer := $Timer

var knockback : Vector2

func enter(msg := {}) -> void:
	if msg.has("knockback"):
		knockback = msg.get("knockback")
	else:
		knockback = Vector2.ZERO
	jawbreaker.animation_player.play("Stun")
	jawbreaker.animation_player.pause()
	timer.start()

func physics_update(_delta):
	jawbreaker.velocity = knockback
	jawbreaker.move_and_slide()

func _on_timer_timeout():
	if not is_instance_valid(jawbreaker.target):
		jawbreaker.target = get_tree().current_scene.player
	state_machine.transition_to("Idle")
