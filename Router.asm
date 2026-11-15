Saved_Flags		equ $FFFFFE10
Route_ID		equ $FFFFFE11
Route_Step		equ $FFFFFE12

; Bit 0 ($01) = Eggman, Bit 1 ($02) = Tails, Bit 2 ($04) = Knuckles
; Route_ID: 0 = Eggman Route, 1 = Tails Route, 2 = Knuckles Route

Router_Init_Game:
		move.b	#$01,(Saved_Flags).w
		clr.b	(Route_ID).w
		clr.b	(Route_Step).w
		move.w	#$0B00,(Current_zone_and_act).w
		move.w	#$0B00,(Apparent_zone_and_act).w
		rts

Router_Rescue_Tails:
		bset	#1,(Saved_Flags).w
		bne.s	.already
		move.w	#sfx_Emerald,d0
		jmp	(Play_Sound_2).l
.already:
		rts

Router_Rescue_Knuckles:
		bset	#2,(Saved_Flags).w
		bne.s	.already
		move.w	#sfx_Emerald,d0
		jmp	(Play_Sound_2).l
.already:
		rts

Router_Lose_Eggman:
		bclr	#0,(Saved_Flags).w
		rts

Router_Next_Zone:
		addq.b	#1,(Route_Step).w
		moveq	#0,d0
		move.b	(Route_Step).w,d0
		cmpi.b	#2,d0
		bhs.s	Router_Select_Ending

		moveq	#0,d1
		move.b	(Route_ID).w,d1
		add.w	d1,d1
		add.w	d1,d1
		add.w	d0,d0
		add.w	d0,d1
		move.w	Route_Zones_Table(pc,d1.w),d2
		move.w	d2,(Current_zone_and_act).w
		move.w	d2,(Apparent_zone_and_act).w
		rts

Route_Zones_Table:
		dc.w	$0B00, $0601	; Route 0 (Eggman): Death Egg 1 -> Launch Base 2
		dc.w	$0001, $0200	; Route 1 (Tails): Angel Island 2 -> Marble Garden 1
		dc.w	$0700, $0801	; Route 2 (Knuckles): Mushroom Hill 1 -> Sandopolis 2

Router_Select_Ending:
		moveq	#0,d0
		move.b	(Saved_Flags).w,d0
		andi.w	#$07,d0
		add.w	d0,d0
		move.w	Ending_Zones_Table(pc,d0.w),d1
		move.w	d1,(Current_zone_and_act).w
		move.w	d1,(Apparent_zone_and_act).w
		rts

Ending_Zones_Table:
		dc.w	$0901		; 0 (000): Worst Ending (Sonic vs Sonic.EXE) - Lava Reef 2
		dc.w	$0500		; 1 (001): Eggman Solo - IceCap 1
		dc.w	$0101		; 2 (010): Tails Solo - Hydrocity 2
		dc.w	$0401		; 3 (011): Tails & Eggman Duo - Flying Battery 2
		dc.w	$0301		; 4 (100): Knuckles Solo - Carnival Night 2
		dc.w	$0A00		; 5 (101): Knuckles & Eggman Duo - Sky Sanctuary 1
		dc.w	$1601		; 6 (110): Tails & Knuckles Duo - Hidden Palace
		dc.w	$0C00		; 7 (111): Best Ending (Alla 3!) - The Doomsday Zone
