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

#Handles winding up
const DASH_SPEED = 500

var charging := false

func enter(_msg := {}) -> void:
	if jawbreaker.health > 0:
		jawbreaker.animation_player.play("WindUp" if jawbreaker.facing_right else "WindUpLeft")
#	jawbreaker.audio_stream_player.stream = jawbreaker.WIND_UP
#	jawbreaker.audio_stream_player.volume_db = -4
#	jawbreaker.audio_stream_player.play()

func physics_update(delta: float) -> void:
	if not jawbreaker.stunned:
		if charging:
			jawbreaker.velocity.x += delta * (DASH_SPEED if jawbreaker.facing_right else -DASH_SPEED)/24.0
			if -DASH_SPEED > jawbreaker.velocity.x || jawbreaker.velocity.x > DASH_SPEED:
				if state_machine.state.name == "WindUp":
					state_machine.transition_to("Charge")
		
		jawbreaker.velocity.y += jawbreaker.gravity
		jawbreaker.velocity *= 1-(1-jawbreaker.speed_scale)/2
		jawbreaker.move_and_slide()
		jawbreaker.velocity /= 1-(1-jawbreaker.speed_scale)/2

func charge():
	charging = true
	var tween = get_tree().create_tween()
	tween.tween_property(jawbreaker, "velocity", Vector2(DASH_SPEED if jawbreaker.facing_right else -DASH_SPEED,0), 14.0/24.0)
