Pal_Eggman:
		binclude "eggman_bin/pal_eggman.bin"
		even

ArtUnc_Eggman:
		binclude "eggman_bin/art_eggman.bin"
		even

		include "eggman_bin/eggman_tables.asm"

Eggman_Jetpack_Start:
		tst.b	double_jump_flag(a0)
		bne.s	.done
		move.b	#2,double_jump_flag(a0)
		clr.b	double_jump_property(a0)
		move.w	#sfx_FlameAttack,d0
		jmp	(Play_Sound_2).l
.done:
		rts

Eggman_Jetpack_Fly:
		cmpi.b	#2,double_jump_flag(a0)
		bne.s	.done
		move.b	(Ctrl_1_held_logical).w,d0
		andi.b	#button_B_mask|button_C_mask|button_A_mask,d0
		beq.s	.stop
		subi.w	#$0048,y_vel(a0)
		cmpi.w	#-$0300,y_vel(a0)
		bge.s	.fuel
		move.w	#-$0300,y_vel(a0)
.fuel:
		addq.b	#1,double_jump_property(a0)
		cmpi.b	#90,double_jump_property(a0)
		blo.s	.done
.stop:
		move.b	#1,double_jump_flag(a0)
.done:
		rts

Eggman_Route_Frame:
		cmpi.b	#2,double_jump_flag(a0)
		bne.s	.notJet
		move.b	#5,mapping_frame(a0)
		rts
.notJet:
		cmpi.b	#2,anim(a0)
		bne.s	.notRoll
		move.b	#4,mapping_frame(a0)
		rts
.notRoll:
		cmpi.b	#4,anim(a0)
		bne.s	.notHurt
		move.b	#6,mapping_frame(a0)
		rts
.notHurt:
		move.w	ground_vel(a0),d0
		bpl.s	.absVel
		neg.w	d0
.absVel:
		cmpi.w	#$0080,d0
		blo.s	.idle
		move.b	(Level_frame_counter+1).w,d0
		lsr.b	#2,d0
		andi.b	#3,d0
		cmpi.b	#3,d0
		blo.s	.walkOk
		moveq	#1,d0
.walkOk:
		addq.b	#1,d0
		move.b	d0,mapping_frame(a0)
		rts
.idle:
		clr.b	mapping_frame(a0)
		rts

