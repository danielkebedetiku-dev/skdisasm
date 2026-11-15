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
