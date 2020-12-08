.include "constants.asm"
.include "macros.asm"

# =================================================================================================
# Bullet
# =================================================================================================

.data
bullet_obj: .word 0
.text

# void bullet_new(x: a0, y: a1, angle: a2)
.globl bullet_new
bullet_new:
enter s0, s1, s2
	move s0, a0
	move s1, a1
	move s2, a2

	li a0, TYPE_BULLET
	jal Object_new

	beq v0, 0, _exit_bullet_new

	sw s0, Object_x(v0)
	sw s1, Object_y(v0)
	sw v0, bullet_obj

	
	li a0, BULLET_THRUST
	move a1, s2
	jal to_cartesian

	lw t0, bullet_obj
	sw v0, Object_vx(t0)
	sw v1, Object_vy(t0)

	li t1, BULLET_LIFE##################################################################################################################################################
	#li t1, 50
 	sw t1, Bullet_frame(t0)

 	_exit_bullet_new:
leave s0, s1, s2

# ------------------------------------------------------------------------------

.globl bullet_update
bullet_update:
enter s0
	move s0, a0

	lw t0, Bullet_frame(a0)
	sub t0, t0, 1
	sw t0, Bullet_frame(a0)

	lw t0, Bullet_frame(a0)
	bne t0, 0, _wrap_and_accumulate_bullet

	move a0, s0
	jal Object_delete
	j _exit_update

	_wrap_and_accumulate_bullet:
		move a0, s0
		jal Object_accumulate_velocity

		move a0, s0
		jal Object_wrap_position

	_exit_update:
leave s0

# ------------------------------------------------------------------------------

.globl bullet_draw
bullet_draw:
enter
	lw t0, Object_x(a0)
	lw t1, Object_y(a0)

	sra a0, t0, 8
	sra a1, t1, 8
	li a2, COLOR_RED
	jal display_set_pixel
leave