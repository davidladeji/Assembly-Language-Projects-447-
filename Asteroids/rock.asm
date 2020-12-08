.include "constants.asm"
.include "macros.asm"

# =================================================================================================
# Rocks
# =================================================================================================

.data
rock_obj: .word 0
.text

.globl rocks_count
rocks_count:
enter
	la t0, objects
	li t1, 0
	li v0, 0

	_rocks_count_loop:
		lw t2, Object_type(t0)
		beq t2, TYPE_ROCK_L, _rocks_count_yes
		beq t2, TYPE_ROCK_M, _rocks_count_yes
		bne t2, TYPE_ROCK_S, _rocks_count_continue
		_rocks_count_yes:
			inc v0
	_rocks_count_continue:
	add t0, t0, Object_sizeof
	inc t1
	blt t1, MAX_OBJECTS, _rocks_count_loop
leave

# ------------------------------------------------------------------------------

# void rocks_init(int num_rocks)
.globl rocks_init
rocks_init:
enter s0, s1
	move s0, a0
	li s1, 0

	beq s1, s0, _exit_rocks_init

	_rock_creation_loop:
		li a0, 0x200
		jal random
		li t0, 0x300
		add t0, t0, v0
		li t1, 0x400
		div t0, t1
		mfhi a1

		li a0, 0x200
		jal random
		li t0, 0x300
		add t0, t0, v0
		li t1, 0x400
		div t0, t1
		mfhi a0

		
		li a2, TYPE_ROCK_L
		jal rock_new
		add s1, s1, 1
		bne s1, s0, _rock_creation_loop


	_exit_rocks_init:
leave s0, s1

# ------------------------------------------------------------------------------

# void rock_new(x, y, type)
rock_new:
enter s0, s1, s2
	move s0, a0
	move s1, a1
	move s2, a2

	move a0, s2
	jal Object_new

	sw v0, rock_obj
	li t0, TYPE_ROCK_S
	sub t0, t0, s2

	beq t0, 0, _create_rock_S
	beq t0, 1, _create_rock_M # ------------------------------------------------------------------------------

	_create_rock_L:
		li t0, ROCK_L_HW
		li t1, ROCK_L_HH

		lw t2, rock_obj
		sw t0, Object_hw(t2)
		sw t1, Object_hh(t2)

		sw s0, Object_x(t2)
		sw s1, Object_y(t2)

		sw t2, rock_obj

		li a0, 360
		jal random

		li a0, ROCK_VEL
		move a1, v0
		jal to_cartesian

		lw t0, rock_obj
		sw v0, Object_vx(t0)
		sw v1, Object_vy(t0)

		j _exit_rock_new

	_create_rock_M:
		li t0, ROCK_M_HW
		li t1, ROCK_M_HH

		lw t2, rock_obj
		sw t0, Object_hw(t2)
		sw t1, Object_hh(t2)

		sw s0, Object_x(t2)
		sw s1, Object_y(t2)

		sw t2, rock_obj

		li a0, 360
		jal random

		li a0, ROCK_VEL
		mul a0, a0, 4
		move a1, v0
		jal to_cartesian

		lw t0, rock_obj
		sw v0, Object_vx(t0)
		sw v1, Object_vy(t0)

		j _exit_rock_new

	_create_rock_S:
		li t0, ROCK_S_HW
		li t1, ROCK_S_HH

		lw t2, rock_obj
		sw t0, Object_hw(t2)
		sw t1, Object_hh(t2)

		sw s0, Object_x(t2)
		sw s1, Object_y(t2)

		sw t2, rock_obj

		li a0, 360
		jal random

		li a0, ROCK_VEL
		mul a0, a0, 12
		move a1, v0
		jal to_cartesian

		lw t0, rock_obj
		sw v0, Object_vx(t0)
		sw v1, Object_vy(t0)	

	_exit_rock_new:
leave s0, s1, s2

# ------------------------------------------------------------------------------

.globl rock_update
rock_update:
enter s0
	move s0, a0

	jal Object_accumulate_velocity

	move a0, s0
	jal Object_wrap_position

	move a0, s0
	jal rock_collide_with_bullets
leave s0

# ------------------------------------------------------------------------------

rock_collide_with_bullets:
enter s0, s1, s2
	la s0, objects
	li s1, 0
	move s2, a0

	_Object_bullet_type_loop:

		lw t0, Object_type(s0)
		li t1, TYPE_BULLET
		sub t0, t1, t0
		bne t0, 0, _increment_label

	_check_for_bullet_position:
		move a0, s2
		lw a1, Object_x(s0)
		lw a2, Object_y(s0)
		jal Object_contains_point

	beq v0, 0, _increment_label

	_rock_hit_and_bullet_delete_:
		move a0, s2
		jal rock_get_hit

		move a0, s0
		jal Object_delete
		j _exit_bullet_collide

	_increment_label:
		add s0, s0, Object_sizeof
		inc s1
		blt s1, MAX_OBJECTS, _Object_bullet_type_loop

	_exit_bullet_collide:
leave s0, s1, s2
# ------------------------------------------------------------------------------

rock_get_hit:
enter s0
	move s0, a0

	lw t0, Object_type(s0)
	li t1, TYPE_ROCK_S
	sub t0, t1, t0

	beq t0, 0, _exit_rock_get_hit
	beq t0, 1, _get_hit_M

	lw a0, Object_x(s0)
	lw a1, Object_y(s0)
	li a2, TYPE_ROCK_M
	jal rock_new
	
	lw a0, Object_x(s0)
	lw a1, Object_y(s0)
	li a2, TYPE_ROCK_M
	jal rock_new

	j _exit_rock_get_hit

	_get_hit_M:
		lw a0, Object_x(s0)
		lw a1, Object_y(s0)
		li a2, TYPE_ROCK_S
		jal rock_new
		
		lw a0, Object_x(s0)
		lw a1, Object_y(s0)
		li a2, TYPE_ROCK_S
		jal rock_new

		j _exit_rock_get_hit
		


	#jal Object_delete
	#print_str "BOOM!"
	#move a0, a1
	#syscall_print_int
	#newline

	_exit_rock_get_hit:
		lw a0, Object_x(s0)
		lw a1, Object_y(s0)
		jal explosion_new
		move a0, s0
		jal Object_delete
leave s0

# ------------------------------------------------------------------------------

.globl rock_collide_l
rock_collide_l:
enter
	jal rock_get_hit
	li a0, 3
	jal player_damage
leave

# ------------------------------------------------------------------------------

.globl rock_collide_m
rock_collide_m:
enter
	jal rock_get_hit
	li a0, 2
	jal player_damage
leave

# ------------------------------------------------------------------------------

.globl rock_collide_s
rock_collide_s:
enter
	jal rock_get_hit
	li a0, 1
	jal player_damage
leave

# ------------------------------------------------------------------------------

.globl rock_draw_l
rock_draw_l:
enter
	la a1, spr_rock_l
	jal Object_blit_5x5_trans
leave

# ------------------------------------------------------------------------------

.globl rock_draw_m
rock_draw_m:
enter
	la a1, spr_rock_m
	jal Object_blit_5x5_trans
leave

# ------------------------------------------------------------------------------

.globl rock_draw_s
rock_draw_s:
enter
	la a1, spr_rock_s
	jal Object_blit_5x5_trans
leave