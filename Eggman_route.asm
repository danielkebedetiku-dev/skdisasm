Eggman_Route_Start:
		move.b	#$01,(Saved_Flags).w
		clr.b	(Route_ID).w
		clr.b	(Route_Step).w
		move.w	#$0B00,(Current_zone_and_act).w
		move.w	#$0B00,(Apparent_zone_and_act).w
		rts

Eggman_Route_Update:
		tst.b	(Route_ID).w
		bne.s	.done
		move.w	(Current_zone_and_act).w,d0
		cmpi.w	#$0B00,d0
		beq.s	.zone1Sensor
		cmpi.w	#$0601,d0
		beq.s	.zone2Sensor
		rts

.zone1Sensor:
		cmpi.w	#$1800,x_pos(a0)
		blo.s	.done
		cmpi.w	#$0180,y_pos(a0)
		bhi.s	.done
		bset	#1,(Saved_Flags).w
		bne.s	.done
		move.w	#sfx_Emerald,d0
		jmp	(Play_Sound_2).l

.zone2Sensor:
		cmpi.w	#$2000,x_pos(a0)
		blo.s	.done
		cmpi.w	#$0200,y_pos(a0)
		bhi.s	.done
		bset	#2,(Saved_Flags).w
		bne.s	.done
		move.w	#sfx_Emerald,d0
		jmp	(Play_Sound_2).l

.done:
		rts

Eggman_Route_DarkPalette:
		tst.b	(Route_ID).w
		bne.s	.done
		move.w	#$000A,(Normal_palette+$1E).w
		move.w	#$0006,(Normal_palette+$1C).w
		move.w	#$000E,(Water_palette+$02).w
.done:
		rts

Eggman_Route_StageClear:
		tst.b	(Route_ID).w
		bne.s	.done
		jmp	Router_Next_Zone
.done:
		rts
