.include "constants.asm"
.include "macros.asm"

# =================================================================================================
# Explosions
# =================================================================================================

.data
explosion_obj: .word 0
.text

# void explosion_new(x, y)
.globl explosion_new
explosion_new:
enter s0, s1
	move s0, a0
	move s1, a1

	li a0, TYPE_EXPLOSION
	jal Object_new

	beq v0, 0, _exit_explosion_new

	sw s0, Object_x(v0)
	sw s1, Object_y(v0)

	li t0, EXPLOSION_HW
	li t1, EXPLOSION_HH

	sw t0, Object_hw(v0)
	sw t1, Object_hh(v0)

	li t0, EXPLOSION_ANIM_DELAY
	li t1, 0

	sw t0, Explosion_timer(v0)
	sw t1, Explosion_frame(v0)

	sw v0, explosion_obj

	_exit_explosion_new:
leave s0, s1

# ------------------------------------------------------------------------------

.globl explosion_update
explosion_update:
enter
	lw t0, Explosion_timer(a0)
	sub t0, t0, 1
	sw t0, Explosion_timer(a0)

	bne t0, 0, _exit_explosion_update

	li t0, EXPLOSION_ANIM_DELAY
	sw t0, Explosion_timer(a0)

	lw t0, Explosion_frame(a0)
	add t0, t0, 1
	sw t0, Explosion_frame(a0)

	blt t0, 6, _exit_explosion_update

	jal Object_delete

	_exit_explosion_update:
leave

# ------------------------------------------------------------------------------

.globl explosion_draw
explosion_draw:
enter
	la t0, spr_explosion_frames
	lw t1, Explosion_frame(a0)
	mul t1, t1, 4
	add t0, t0, t1
	lw a1, (t0)
	jal Object_blit_5x5_trans
leave