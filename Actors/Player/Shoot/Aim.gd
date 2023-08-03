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

# Workaround because "animation_finished" signal is not emitted when it finishes so I have to estimate the time the animation will take
# Will probably need to change when the real animation comes and forget about it and have a really annoying bug to find
const SHOOT_ANIMATION_TIME = 0.1
const CHARGE = 1
const SPECIAL = preload("res://Ammo/Special/Special.tscn")

var bullet_strength : float
var crouched : bool
var special : bool

@onready var audio_stream_player = $AudioStreamPlayer
@onready var secondary_audio_stream_player = $AudioStreamPlayer2
@onready var tertiary_audio_stream_player = $AudioStreamPlayer3

var held_ammo

func enter(msg := {}) -> void:
	player.shoot_bar.visible = true
	player.shoot_bar.scale.x = 0
	bullet_strength = 0
	player.velocity.x = 0
	
	if msg.has("special"):
		special = true
	else:
		special = false
	
	if msg.has("crouched") || not player.is_on_floor():
		player.animation_mode.travel("Crouched")
		crouched = true
		player.bullet_center.position = Vector2(0,-10)
		player.bullet_forward.position = Vector2(21 if player.facing_right else -21,-10)
	else:
		player.animation_mode.travel("Idle")
		crouched = false
		player.bullet_center.position = Vector2(0,-35)
		player.bullet_forward.position = Vector2(13 if player.facing_right else -13,-35)
	
	match(GlobalVars.ammo_equipped_array[GlobalVars.equiped_ammo_index].type):
		GlobalTypes.AMMO_TYPE.once:
			shoot_animation()
		GlobalTypes.AMMO_TYPE.constant:
			pass
		GlobalTypes.AMMO_TYPE.charge:
			pass

func physics_update(delta: float) -> void:
	player.velocity.y += player.GRAVITY * delta
	player.set_velocity(player.velocity)
	player.set_up_direction(Vector2.UP)
	player.move_and_slide()
	player.velocity = player.velocity
	if GlobalVars.ammo_equipped_array[GlobalVars.equiped_ammo_index].type == GlobalTypes.AMMO_TYPE.charge && Input.is_action_pressed("shoot"):
		bullet_strength += delta
		if bullet_strength >= CHARGE:
			bullet_strength = CHARGE
	player.shoot_bar.scale.x = bullet_strength/100
	if Input.is_action_just_released("shoot"):
		if bullet_strength > 0.5:
			shoot_animation()
		else:
			player.shoot_bar.visible = false
			state_machine.transition_to("Idle" if !crouched else "Crouched")
			
	var input_direction_x: float = (
		Input.get_action_strength("move_right")
		- Input.get_action_strength("move_left")
	)
	# Check to see if the player needs to turn around
	if player.facing_right != (input_direction_x > 0) && input_direction_x != 0:
		player.facing_right = input_direction_x > 0
		player.sprite.flip_h = !player.facing_right
		player.animation_tree.set('parameters/Run/blend_position', 1 if player.facing_right else -1)
		player.animation_tree.set('parameters/Idle/blend_position', 1 if player.facing_right else -1)
		player.camera_arm.position.x = 127 if player.facing_right else -127

func shoot_animation():
	player.animation_mode.travel("Shoot" if !crouched else "ShootCrouched")
	player.shoot_bar.visible = false
	await get_tree().create_timer(SHOOT_ANIMATION_TIME).timeout
	player.cooldown_bar.visible = true
	if player.is_on_floor():
		state_machine.transition_to("Idle" if !crouched else "Crouched")
	else:
		state_machine.transition_to("Air")

# Shoots individual bullets
func shoot(position:NodePath) -> void:
	if special:
		var special_bullet = SPECIAL.instantiate()
		get_tree().current_scene.add_child(special_bullet)
		special_bullet.global_position = player.get_node(position).global_position
		special_bullet.launch((player.get_node(position).global_position - player.bullet_center.global_position).normalized(), bullet_strength)
		GlobalVars.sugar -= GlobalVars.special_attack_sugar
		player.update_display()
	else:
		if !player.can_shoot or GlobalVars.ammo_equipped_array[GlobalVars.equiped_ammo_index] == null:
			return
		player.can_shoot = false
		var bullet = GlobalVars.ammo_equipped_array[GlobalVars.equiped_ammo_index].scene.instantiate()
		get_tree().current_scene.add_child(bullet)
		
		bullet.global_position = player.get_node(position).global_position
		
		player.cooldown_timer.start(GlobalVars.ammo_equipped_array[GlobalVars.equiped_ammo_index].cooldown)
		
		var knockback = bullet.launch((player.get_node(position).global_position - player.bullet_center.global_position).normalized(), bullet_strength)
		
	#	GlobalVars.sugar -= GlobalVars.ammo_equipped_array[GlobalVars.equiped_ammo_index].sugar
		
		if !crouched:
			state_machine.transition_to("Knockback", {0: knockback})
		
		#Play sound
		if audio_stream_player.playing:
			if secondary_audio_stream_player.playing:
				tertiary_audio_stream_player.pitch_scale = 2 - GlobalVars.ammo_equipped_array[GlobalVars.equiped_ammo_index].sugar/3
				tertiary_audio_stream_player.play()
			else:
				secondary_audio_stream_player.pitch_scale = 2 - GlobalVars.ammo_equipped_array[GlobalVars.equiped_ammo_index].sugar/3
				secondary_audio_stream_player.play()
		else:
			audio_stream_player.pitch_scale = 2 - GlobalVars.ammo_equipped_array[GlobalVars.equiped_ammo_index].sugar/3
			audio_stream_player.play()

func _on_cooldown_timer_timeout() -> void:
	player.can_shoot = true
	player.cooldown_bar.visible = false
