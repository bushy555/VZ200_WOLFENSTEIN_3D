;   WOLFENSTEIN FPS CODE.  by Lawrence Kesteloot.  e: lk@teamten.com
;   POrted from original TRS80 model 1 to VZ by silly dave.
;   https://github.com/lkesteloot/trs80/tree/master/apps/wolf
;   https://en.wikipedia.org/wiki/Wolfenstein_3D$Development
;
; Found src code for trs80 on Lawrence github for the TRS80 Model 1.
; Grabbed it and ran with it. 
; Q - forward		Z - Show Map
; A - back		X - Menu
; M - left		C - Credits
; ,  - right
; s - straffe left
; d - straffe right
;
;
;
;		WALL
;		colour	  
;		Number	  Colour     Chr$()
;		------------------------------
;		0 	  green      143 
; 		16        yellow     159 
;		32        blue       175 
; 		48        red        191 
; 		64        buff       207 
; 		80 	  cyan       223 
;		96        magenta    239 
; 		112       orange     255 

wallcolour	equ 64  ; Buff

stride		equ 32  		; Break my stride. TRS80=64. VZ=32.
walltexture1	equ 138  + wallcolour	
walltexture2	equ 139  + wallcolour	
ceilingborder	equ 7    		; use 17 for mode(1)
floorborder	equ 7	 		; use 17 for mode(1)
ceilingtexture	equ 223			; cyan
floortexture	equ 255			; orange
topwalltexture1 equ 130  + wallcolour	; 130
topwalltexture2 equ 131  + wallcolour	; 129
bottomwalltexture1 equ 136+ wallcolour	; 
bottomwalltexture2 equ 132+ wallcolour	; 
SCREEN_WIDTH 	equ 32			; TRS80=64
SCREEN_HEIGHT 	equ 16			; NOT USED
MAZE_SIZE 	equ 8			; NOT USED
latch		equ $6800
video		equ $7000
origin		equ $7B00




	org		origin - 24
	defb		'VZF1'					; file type ID
	defb		"WOLFENSTEIN 3D",  0,0,0		; zero padded file name
	defb		$f1					; Binary or BASIC?
	defw		START					; start address
	org		origin
START:



entry:  ld	sp, 0

	call 	init
        call 	init_introscreen
menuscr:call 	init_menuscreen
next_frame:
        call 	get_key_update
        call 	fill_buffer
        call 	draw_screen
        jp 	next_frame



; -------------------------------------------
init:
; -------------------------------------------
	ei
	call	$01c9					; VZ ROM CLS
	ld	a, 0					; MODE(0)
	ld	($6800), a	
	ret

; -------------------------------------------
init_introscreen:
; -------------------------------------------

	di
;	ld	a, 8					; Mode(1)
;	ld	($6800), a

;	ld	hl, introscreen				; display intro screen
;	ld	de, $7000
;	ld	bc, 2048
;	ldir


	ld	a, 0					; MODE(0)
	ld	($6800), a	
	ei
	call	$01c9					; VZ ROM CLS

	ret





; -----------------------------------------------------------
init_menuscreen:
			; DISPLAY MENU
			; PLAY MENU SONG
			; PRESS <SPACE>.
; -----------------------------------------------------------

	di

	ld	hl, menu0			; -ROM String routine stuffs up
	ld	de, $7000			;
	ld	b, 255				;
msgloop0:ld	a, (hl)				; have tried every bloody thing under the sun.
	or	64				; Read string, per each chr$ do an "OR 64", display it.	
	ld	(de), a
	inc	hl
	inc	de
	djnz	msgloop0
	ld	b, 65+32
msgloop1:ld	a, (hl)
	or	64
	ld	(de), a
	inc	hl
	inc	de
	djnz	msgloop1
		

;	jp	skip_menu_song2

;	Attempt to use the Lydon91 player once for both mode(0) and mode(1)
; 	Using self modified code. Failed first time. So player is currently in twice for each mode.
;	May or may not come back to this if I can be bothered.
;
;	ld	hl, mask0
;	ld	(hl), $DD		;mask1	:	28 --> 20	MODE(1) then MODE(0)
;	ld	hl, mask1
;	ld	(hl), $21		;mask1	:	28 --> 20	MODE(1) then MODE(0)
;	ld	hl, mask2 
;	ld	(hl), $20		;mask2	:	28 --> 20	MODE(1) then MODE(0)
;	ld	hl, mask3
;	ld	(hl), $20		;mask3	:	28 --> 20	MODE(1) then MODE(0)
;	ld	hl, mask4
;	ld	(hl), $20		;mask4	:	28 --> 20	MODE(1) then MODE(0)
;	ld	hl, mask5
;	ld	(hl), $20		;mask5	:	OR A, 28 --> 00 NOP : MODE(1) then MODE(0)
;	inc	hl
;	ld	(hl), $20		;mask5	:	OR A, 28 --> 00 NOP : MODE(1) then MODE(0)
;
;	ld	hl, mask6
;	ld	(hl), $20		;mask5	:	OR A, 28 --> 00 NOP : MODE(1) then MODE(0)
;	inc	hl
;	ld	(hl), $20		;mask5	:	OR A, 28 --> 00 NOP : MODE(1) then MODE(0)
;
;	ld	hl, mask7
;	ld	(hl), $20		;mask5	:	OR A, 28 --> 00 NOP : MODE(1) then MODE(0)
;	inc	hl
;	ld	(hl), $20		;mask5	:	OR A, 28 --> 00 NOP : MODE(1) then MODE(0)


;skip_menu_song2:
;hereas	jp	hereas







	push	af
	push	bc
	push	de
	push	hl

;	di
;
;    x20 x10  x8   x4  x2  x1
; ----------------------------
;68FE  R   Q   E        W   T
;68FD  F   A   D  ctrl  S   G
;68FB  V   Z   C  SHFT  X   B
;68F7  4   1   3        2   5
;68EF  M  SPC  ,        .   N
;68DF  7   0   8   -    9   6
;68BF  U   P   I  RTN   O   Y
;687F  J   L   K   :    L   H
;

mkey_loop:
	ld 	a, ($68f7)		; Key : 1
	and	$10	
	jr 	z, mselectmaze1		; jump if <1> is pressed.
	ld 	a, ($68f7)		; Key : 2
	and	$2	
	jr 	z, mselectmaze2		; jump if <2> is pressed.
	ld 	a, ($68f7)		; Key : 3
	and	$8	
	jr 	z, mselectmaze3		; jump if <3> is pressed.
	ld 	a, ($68f7)		; Key : 4
	and	$20	
	jr 	z, mselectmaze4		; jump if <4> is pressed.
	ld 	a, ($68f7)		; Key : 5
	and	$1	
	jr 	z, mselectmaze5		; jump if <5> is pressed.
	ld 	a, ($68df)		; Key : 6
	and	$1	
	jr 	z, mselectmaze6		; jump if <6> is pressed.
	ld 	a, ($68df)		; Key : 7
	and	$20	
	jr 	z, mselectmaze7		; jump if <7> is pressed.
	ld 	a, ($68df)		; Key : 8
	and	$8	
	jr 	z, mselectmaze8		; jump if <8> is pressed.
	ld 	a, ($68df)		; Key : 9
	and	$2	
	jr 	z, mselectmaze9		; jump if <9> is pressed.
	ld 	a, ($68df)		; Key : 0
	and	$10	
	jr 	z, mselectmaze0		; jump if <0> is pressed.
	ld 	a, ($68EF)		; Key : SPACE
	and	$10	
	jr	nz, mkey_loop


	pop	hl			; Space is pressed. Play game.
	pop	de
	pop	bc
	pop	af


	ret				; continue on with game!


mselectmaze1:	ld	hl, level1
		jr	copymaze
mselectmaze2:	ld	hl, level2
		jr	copymaze
mselectmaze3:	ld	hl, level3
		jr	copymaze
mselectmaze4:	ld	hl, level4
		jr	copymaze
mselectmaze5:	ld	hl, level5
		jr	copymaze
mselectmaze6:	ld	hl, level6
		jr	copymaze
mselectmaze7:	ld	hl, level7
		jr	copymaze
mselectmaze8:	ld	hl, level8
		jr	copymaze
mselectmaze9:	ld	hl, level9
		jr	copymaze
mselectmaze0:	ld	hl, level0
		jr	copymaze


copymaze:ld	de, MAZE			; copy level into MAZE temp storage space
	ld	bc, 64 + 12			; size of map + title length
	ldir

	call	show_menu_map			; show map routine within Menu

	jp	mkey_loop






; -------------------------------------------
; Update model from inputs.
; https://www.trs-80.com/wordpress/zaps-patches-pokes-tips/keyboard-map/

; -------------------------------------------
get_key_update:
; -------------------------------------------
;	Read keyboard
;	Update position.  
		; Q - forward
		; A - back
		; M - left
		; ,  - right
		; s - straffe left
		; d - straffe right

;    x20 x10  x8   x4  x2  x1
; ----------------------------
;68FE  R   Q   E        W   T
;68FD  F   A   D  ctrl  S   G
;68FB  V   Z   C  SHFT  X   B
;68F7  4   1   3        2   5
;68EF  M  SPC  ,        .   N
;68DF  7   0   8   -    9   6
;68BF  U   P   I  RTN   O   Y
;687F  J   L   K   :    L   H
;

KeyX:	ld 	a, ($68FB)			; KEY: X MENU
	and	$2
	jr 	nz, not_X
	jp	menuscr

not_X:
KeyM:	ld 	a, ($68EF)			; KEY: M LEFT
	and	$20
	jr 	nz, not_m

        ld 	a, (dir)
        add	a, 1				; POV turn left,  screen goes right.
        and	63
        ld 	(dir), a
	jp 	end_keyboard
not_m:
keyComma:ld 	a, ($68EF)			; KEY: comma RIGHT
	and	$08
	jr 	nz, not_right

        ld 	a, (dir)
	sub 	1				; POV turn right,  screen goes left.
        and 	63
        ld 	(dir), a
	jp 	end_keyboard
not_right:

keyQ:	ld 	a,  ($68FE)			; KEY: Q Forwards
	and	$10
	jr 	nz,  not_q
	call 	premove
	ld 	a, (posX)
	ld 	hl, dir
        ld 	l, (hl)
        ld 	h, high (DIR_TABLE_X)
	ld 	h, (hl)
	sra 	h
	add 	a,  h
	ld 	(posX), a
	ld 	a, (posY)
	ld 	h, high (DIR_TABLE_Y)
	ld 	h, (hl)
	sra 	h
	add 	a,  h
	ld 	(posY), a
	call 	postmove
	jp 	end_keyboard
not_q:

keyA:	ld 	a,  ($68FD)			; KEY: A BACKWARDS
	and	$10
	jr 	nz,  not_a
	call 	premove
	ld 	a, (posX)
	ld 	hl, dir
        ld 	l, (hl)
        ld 	h, high (DIR_TABLE_X)
	ld 	h, (hl)
	sra 	h
	sub 	h
	ld 	(posX), a
	ld 	a, (posY)
	ld 	h, high (DIR_TABLE_Y)
	ld 	h, (hl)
	sra 	h
	sub 	h
	ld 	(posY), a
	call 	postmove
	jp 	end_keyboard
not_a:

	ld 	a, ($68fd)			; KEY: S  Staffe left
	and	$02
	jr 	nz,  not_s
	call 	premove
	ld 	a, (posX)
	ld 	hl, dir
        ld 	l, (hl)
        ld 	h, high (DIR_TABLE_Y)
	ld 	h, (hl)
	sra	 h
	add 	a,  h
	ld 	(posX), a
	ld 	a, (posY)
	ld 	h, high (DIR_TABLE_X)
	ld 	h, (hl)
	sra 	h
	sub 	h
	ld 	(posY), a
	call 	postmove
	jp 	end_keyboard
not_s:
keyD:	ld 	a,  ($68fd)			; KEY: D  Straffe right
	and	$08
	jr 	nz,  not_d
	call 	premove
	ld 	a, (posX)
	ld 	hl, dir
        ld 	l, (hl)
        ld 	h, high (DIR_TABLE_Y)
	ld 	h, (hl)
	sra 	h
	sub 	h
	ld 	(posX), a
	ld 	a, (posY)
	ld 	h, high (DIR_TABLE_X)
	ld 	h, (hl)
	sra 	h
	add 	a,  h
	ld 	(posY), a
	call 	postmove
	jp 	end_keyboard
not_d:
keyZ:	ld 	a,  ($68fB)			; KEY: Z  SHOW MAP
	and	$10
	jr 	nz,  not_z

	ld	a, (maponoff)
	cp	0
	jr	z, turnmapon			; map off. turn map on.
	cp	1
	jr	z, turnmapoff			; map on. turn map off.
	jr	not_z

turnmapon:ld	a, 1				; map was off. turn map on.
	ld	(maponoff), a
	jr	turnmap
turnmapoff:ld	a, 0				; map was on. turn map off.
	ld	(maponoff), a
turnmap:call	show_map

not_z:	ld 	a, ($68FB)			; Key : C for credits
	and	$8	
	jr 	nz, not_c
	call	show_credits			; jump to call if <C> is pressed.
not_c:
end_keyboard:
	ret


; ----------------------------------------

					; Save the player position so that if we
					; run into a wall, we can back off.
premove:ld 	a, (posX)
	ld 	(savePosX), a
	ld 	a, (posY)
	ld 	(savePosY), a
	ret
postmove:				; uint_8 mapX = posX >> 5;
        ld 	a, (posX)
        srl 	a
        srl 	a
        srl 	a
        srl 	a
        srl 	a
        ld 	l, a
        
        ld 	a, (posY)		; uint_8 mapY = (posY >> 5) << 3;
        srl 	a
        srl 	a
	and 	$38 ; 3 bits

        or 	l			; if (MAZE[mapY][mapX] != ' ')
        ld 	h, high(MAZE)
        ld 	l, a
        ld 	a, (hl)
        cp 	' '
        ret 	z ; not in wall

	ld 	a, (savePosX)		; In wall,  restore old position.
	ld 	(posX), a
	ld 	a, (savePosY)
	ld 	(posY), a

	ret


; -------------------------------------------
fill_buffer:
        ld 	hl,  BUFFER
        ld 	c,  0
        ld 	b,  SCREEN_WIDTH
fill_loop:
        call 	get_height
        ld 	(hl),  a
        inc 	hl
        inc 	c
        djnz 	fill_loop
        ret

; -------------------------------------------
draw_screen:
        ld 	de,  stride		; 64 ; Stride
        ld 	bc,  0 ; Column

hloop:  push bc

        ld 	hl,  BUFFER		        ; Load height from buffer.
        add 	hl,  bc
        ld 	a,  (hl)

	bit 	7,  a				; Test top bit for texture.
	jp 	z, texture_2
texture_1:
	ld 	iyl,  walltexture1 		; $80+1+4+16
	and 	$7F
        push 	af        
	ld 	h, high(TOP_TEXTURE_1)
	ld 	l, a
	ld 	a, (hl)
	ld 	ixh, a
	ld 	h, high(BOTTOM_TEXTURE_1)
	ld 	a, (hl)
	ld 	ixl, a
        pop 	af	
	jp 	end_texture
texture_2:
	ld 	iyl,  walltexture2		; $80+4
	and 	$7F
        push 	af        
	ld 	h, high(TOP_TEXTURE_2)
	ld 	l, a
	ld 	a, (hl)
	ld 	ixh, a
	ld 	h, high(BOTTOM_TEXTURE_2)
	ld 	a, (hl)
	ld 	ixl, a
        pop 	af	
end_texture:

	; See if we're too tall and should
	; remove the top/bottom character.
	cp 	24
	jr 	nz, not_too_tall
	push 	af
	ld 	a, iyl
	ld 	ixh, a
	ld 	ixl, a
	pop 	af
	dec 	a
not_too_tall:
	; Divide A by 3.
	ld 	h, high(DIV3)
	ld 	l, a
	ld 	a, (hl)
	; Height is now in A.

        ; Top of column.
        ld 	hl,  videobuffer  ;video
        add 	hl,  bc

        ; Ceiling.
        ld 	b,  ceilingborder
        jp 	toplooptest
toploop:
        ld 	(hl),   ceilingtexture		; 143	;128
        add 	hl,  de
        dec 	b
toplooptest:
        cp 	b ; Stop at a
        jp 	nz,  toploop

        ; Border between ceiling and wall.
        ld 	b, ixh
        ld 	(hl), b
        add 	hl,  de

        ; Wall.
        ld 	b,  a
        sla 	b
	ld 	c, iyl
        jp 	vlooptest
vloop:
        ld 	(hl),  c
        add 	hl,  de
        dec 	b
vlooptest:
        jp 	nz,  vloop

        ; Border between wall and floor.
        ld 	b, ixl
        ld 	(hl),  b
        add 	hl,  de

        ; Floor.
        ld 	b,  floorborder
        jp 	bottomlooptest
bottomloop:
        ld 	(hl),  floortexture	; 	143 + 16	;128
        add 	hl,  de
        dec 	b
bottomlooptest:
        cp 	b ; Stop at a
        jp 	nz,  bottomloop

        pop 	bc

        inc 	bc
        ld 	a,  c
;        cp 	64
	cp 	32
;	cp	16
        jp	nz,  hloop

	call	show_map

screen_update:				; from video_buffer to video.
	di					
	ld 	hl, videobuffer
	ld 	de, video
	ld 	bc, 512			; MODE1 : 2048-784			
screen_update_loop1:			; wait for first retrace
	ld 	a, (0x6800)
	rla
	jr 	c,screen_update_loop1		
	ldir				; copy first slice during the retrace			
;	ld 	bc, 784			; mode1: prepare for second slice. wait for second retrace
;screen_update_loop2:			; mode1: 
;	ld 	a, (0x6800)		; mode1: 
;	rla				; mode1: 
;	jr 	c,screen_update_loop2	; mode1: 
;	ldir				; mode1: ; copy the second slice during the retrace

        ret

; -------------------------------------------
; Given 0 <= C <= 63 column,  return 0 <= A <= 23 height.
; Set high bit of A to use different texture.

get_height:
        push 	hl
        push 	bc

        ; int8_t cameraX = 2*x - SCREEN_WIDTH; // x-coordinate in camera space
        sla 	c ; c *= 2
        ld 	a, c
        sub 	SCREEN_WIDTH ; c -= SCREEN_WIDTH
        ld 	(cameraX), a

	; int8_t dirX = DIR_TABLE_X[dir];
        ld 	hl, dir
        ld 	l, (hl)
        ld 	h, high(DIR_TABLE_X)
        ld 	a, (hl)
        ld 	(dirX), a
	; int8_t planeY = dirX;
        ld 	(planeY), a
	; int8_t dirY = DIR_TABLE_Y[dir];
        ld 	h, high(DIR_TABLE_Y)
        ld 	a, (hl)
        ld 	(dirY), a
	; int8_t planeX = -dirY;
        neg
        ld 	(planeX), a

        ; int8_t rayDirX = dirX + planeX * cameraX / SCREEN_WIDTH;
        ld 	a, (planeX)
        ld 	h, a
        ld 	a, (cameraX)
        ld 	e, a
        call 	signed_mult_8
        ; Divide by SCREEN_WIDTH (64) by shifting left and using high byte.
        add 	hl, hl
        add 	hl, hl
        ld 	a, (dirX)
        add 	a,  h
        ld 	(rayDirX), a

	; int8_t rayDirY = dirY + planeY * cameraX / SCREEN_WIDTH;
        ld 	a, (planeY)
        ld 	h, a
        ld 	a, (cameraX)
        ld 	e, a
        call 	signed_mult_8
        ; Divide by SCREEN_WIDTH (64) by shifting left and using high byte.
        add 	hl, hl
        add 	hl, hl
        ld 	a, (dirY)
        add 	a,  h
        ld 	(rayDirY), a

        ; // which box of the map we're in
	; uint_8 mapX = posX >> 5;
        ld 	a, (posX)
        srl 	a
        srl 	a
        srl 	a
        srl 	a
        srl 	a
        ld 	(mapX), a
        
	; uint_8 mapY = posY >> 5; (pre-shifted 3)
        ld 	a, (posY)
        srl 	a
        srl 	a
	and 	$38
        ld 	(mapY), a	

	; See if we're aligned with one of the
	; axes,  in which case we'll get a
	; divide-by-zero error. Special case
	; both of those.
	ld 	a, (rayDirX)
	or 	a
	jp 	nz, rayDirX_not_zero

 ; ----------------------------------------
	; uint8_t deltaDistY = SIGNED_DIV_TABLE[(uint8_t) rayDirY];
        ld 	h, high(SIGNED_DIV_TABLE)
        ld 	a, (rayDirY)
        ld 	l, a
        ld 	a, (hl)
        ld 	(deltaDistY), a

        ; if (rayDirY < 0) {
        ld 	a, (rayDirY)
        bit 	7, a
        jr 	z, rayDirYPos
        ; stepY = -1;
        ld 	a, -8
        ld 	(stepY), a
        ; sideDistY = (posY - mapY*32) * deltaDistY / 32;
        ld 	a, (posY)
	and 	$1F ; keep fractional part.
        jp 	rayDirYEnd
rayDirYPos:
        ; } else {
        ; stepY = 1;
        ld 	a, 8
        ld 	(stepY), a
        ; sideDistY = ((mapY + 1)*32 - posY) * deltaDistY / 32;
        ld 	a, (posY)
	and 	$1F ; keep fractional part.
	xor 	$1F ; subtract from 32.
rayDirYEnd:
        ld 	h, a
        ld 	a, (deltaDistY)
        ld 	e, a
        call 	mult8
        ; /= 32
        xor 	a
        add 	hl, hl
        rla
        add 	hl, hl
        rla
        add 	hl, hl
        rla
        ld 	l, h
        ld 	h, a
        ld 	(sideDistY), hl

        ; perform DDA
loop:
        ; sideDistY += deltaDistY;
        ld 	de, (sideDistY)
        ld 	a, (deltaDistY)
        ld 	l, a
        ld 	h, 0
        add 	hl, de
        ld 	(sideDistY), hl
        ; mapY += stepY;
        ld 	a, (mapY)
	ld 	hl, stepY
	add 	a,  (hl)
        ld 	(mapY), a

	; Check if ray has hit a wall
        ; if (MAZE[mapY][mapX] != ' ') hit = 1;
        ld 	a, (mapX)
	ld 	hl, mapY
	or 	(hl)
        ld 	h, high(MAZE)
        ld 	l, a
        ld 	a, (hl)
        cp 	' '
        jp 	z, loop

        ; Calculate distance projected on camera direction (Euclidean
        ; distance would give fisheye effect!)
        ; perpWallDist = sideDistY - deltaDistY;
        ld 	hl, (sideDistY)
        ld 	a, (deltaDistY)
        ld 	e, a
        ld 	d, 0
        or 	a
        sbc 	hl, de
        ld 	(dist), hl

 ; rayDirX = 0 -------------------------
	
	ld 	b, $00 ; Hit Y side.
	jp 	end_special_cases

rayDirX_not_zero:
	ld 	a, (rayDirY)
	or 	a
	jp 	nz, rayDirY_not_zero

 ; ----------------------------------------
        ; uint8_t deltaDistX = SIGNED_DIV_TABLE[(uint8_t) rayDirX];
        ld 	h, high(SIGNED_DIV_TABLE)
        ld 	a, (rayDirX)
        ld 	l, a
        ld 	a, (hl)
        ld 	(deltaDistX), a

        ; calculate step and initial sideDist
        ; if (rayDirX < 0) {
        ld 	a, (rayDirX)
        bit 	7, a
        jr 	z, rayDirXPos
        ; stepX = -1;
        ld 	a, -1
        ld 	(stepX), a
        ; sideDistX = (posX - mapX*32) * deltaDistX / 32;
        ld 	a, (posX)
	and 	$1F ; keep fractional part.
        jp 	rayDirXEnd
rayDirXPos:
        ; } else {
        ; stepX = 1;
        ld 	a, 1
        ld 	(stepX), a
        ; sideDistX = ((mapX + 1)*32 - posX) * deltaDistX / 32;
        ld 	a, (posX)
	and 	$1F ; keep fractional part.
	xor 	$1F ; subtract from 32.
rayDirXEnd:
        ld 	h, a
        ld 	a, (deltaDistX)
        ld 	e, a
        call 	mult8
        ; /= 32
        xor 	a
        add 	hl, hl
        rla
        add 	hl, hl
        rla
        add 	hl, hl
        rla
        ld 	l, h
        ld 	h, a
        ld 	(sideDistX), hl

        ; perform DDA
loop2:
        ; sideDistX += deltaDistX;
        ld 	hl, (sideDistX)
        ld 	a, (deltaDistX)
        ld 	e, a
        ld 	d, 0
        add 	hl, de
        ld 	(sideDistX), hl
        ; mapX += stepX;
        ld 	a, (mapX)
	ld 	hl, stepX
	add 	a,  (hl)
        ld 	(mapX), a

        ; Check if ray has hit a wall
        ; if (MAZE[mapY][mapX] != ' ') hit = 1;
        ld 	a, (mapX)
	ld 	hl, mapY
	or 	(hl)
        ld 	h, high(MAZE)
        ld 	l, a
        ld 	a, (hl)
        cp 	' '
        jp 	z, loop2

        ; Calculate distance projected on camera direction (Euclidean
        ; distance would give fisheye effect!)
	; perpWallDist = sideDistX - deltaDistX;
        ld 	hl, (sideDistX)
        ld 	a, (deltaDistX)
        ld 	e, a
        ld 	d, 0
        or 	a
        sbc 	hl, de
        ld 	(dist), hl
 ; rayDirY = zero -------------------------

	ld 	b, $80 ; Hit X side.
	jp 	end_special_cases

rayDirY_not_zero:
 ; neither is zero -------------------------
        ; uint8_t deltaDistX = SIGNED_DIV_TABLE[(uint8_t) rayDirX];
        ld 	h, high(SIGNED_DIV_TABLE)
        ld 	a, (rayDirX)
        ld 	l, a
        ld 	a, (hl)
        ld 	(deltaDistX), a
        
	; uint8_t deltaDistY = SIGNED_DIV_TABLE[(uint8_t) rayDirY];
        ld 	a, (rayDirY)
        ld 	l, a
        ld 	a, (hl)
        ld 	(deltaDistY), a

        ; calculate step and initial sideDist
        ; if (rayDirX < 0) {
        ld 	a, (rayDirX)
        bit 	7, a
        jr 	z, rayDirXPos1
        ; stepX = -1;
	ld 	ixl, -1
        ; sideDistX = (posX - mapX*32) * deltaDistX / 32;
        ld 	a, (posX)
	and 	$1F ; keep fractional part
        jp 	rayDirXEnd1
rayDirXPos1:
        ; } else {
        ; stepX = 1;
	ld 	ixl, 1
        ; sideDistX = ((mapX + 1)*32 - posX) * deltaDistX / 32;
	ld 	a, (posX)
	and 	$1F ; keep fractional part
	xor 	$1F ; subtract from 32
rayDirXEnd1:
        ld 	h, a
        ld 	a, (deltaDistX)
        ld 	e, a
        call 	mult8
        ; /= 32	
        xor 	a
        add 	hl, hl
        rla
        add 	hl, hl
        rla
        add 	hl, hl
        rla
        ld 	l, h
        ld 	h, a
        ld 	(sideDistX), hl

        ; if (rayDirY < 0) {
        ld 	a, (rayDirY)
        bit 	7, a
        jr 	z, rayDirYPos1
        ; stepY = -1;
	ld 	ixh, -8
        ; sideDistY = (posY - mapY*32) * deltaDistY / 32;
        ld 	a, (posY)
	and 	$1F
        jp 	rayDirYEnd1
rayDirYPos1:
        ; } else {
        ; stepY = 1;
	ld 	ixh, 8
        ; sideDistY = ((mapY + 1)*32 - posY) * deltaDistY / 32;
        ld 	a, (posY)
	and 	$1F ; keep fractional part
	xor 	$1F ; subtract from 32
rayDirYEnd1:
        ld 	h, a
        ld 	a, (deltaDistY)
        ld 	e, a
        call 	mult8
        ; /= 32
        xor 	a
        add 	hl, hl
        rla
        add 	hl, hl
        rla
        add 	hl, hl
        rla
        ld 	l, h
        ld 	h, a
        ld 	(sideDistY), hl

	; BC is pointer into map.
	; IXL = stepX.
	; IXH = stepY.
	ld 	a, (mapX)
	ld 	hl, mapY
	or 	(hl)
        ld 	b, high(MAZE)
	ld 	c, a

        ; perform DDA
loop3:
        ; jump to next map square,  either in x-direction,  or in y-direction
        ; if (sideDistX < sideDistY) {
        ld 	hl, (sideDistX)
        ld 	de, (sideDistY)
	or 	a ; clear carry
	sbc 	hl, de
	add 	hl, de
        jr 	nc, moveY ; jump if de <= hl (y < x)
        ; sideDistX += deltaDistX;
        ld 	a, (deltaDistX)
        ld 	e, a
        ld 	d, 0
        add 	hl, de
        ld 	(sideDistX), hl
        ; mapX += stepX;
	ld 	a, c
	add 	a, ixl
	ld 	c, a
        ; side = 0;
        xor 	a
        ld 	(side), a
        jp 	moveEnd
moveY:
        ; } else {
        ; sideDistY += deltaDistY;
        ld 	a, (deltaDistY)
        ld 	l, a
        ld 	h, 0
        add 	hl, de
        ld 	(sideDistY), hl
        ; mapY += stepY;
	ld 	a, c
	add 	a, ixh
	ld 	c, a
	; side = 1;
        ld 	a, 1
        ld 	(side), a
moveEnd:
        ; Check if ray has hit a wall
        ; if (MAZE[mapY][mapX] != ' ') hit = 1;
	ld 	a, (bc)
        cp 	' '
        jp 	z, loop3	

        ; Calculate distance projected on camera direction (Euclidean
        ; distance would give fisheye effect!)
	; if (side == 0) {
        ld 	a, (side)
        or 	a
        jp 	nz, hitYSide
	; perpWallDist = sideDistX - deltaDistX;
        ld 	hl, (sideDistX)
        ld 	a, (deltaDistX)
        ld 	e, a
        ld 	d, 0
        or 	a
        sbc 	hl, de
        ld 	(dist), hl
	ld 	b, $80 ; indicate hit X side.
        jp 	hitSideEnd
hitYSide:
        ; } else {
        ; perpWallDist = sideDistY - deltaDistY;
        ld 	hl, (sideDistY)
        ld 	a, (deltaDistY)
        ld 	e, a
        ld 	d, 0
        or 	a
        sbc 	hl, de
        ld 	(dist), hl
	ld 	b, $00 ; indicate hit Y side.
hitSideEnd:
 ; neither is zero -------------------------

	; End of the three special cases. By now the "dist" variable should 
	; be set and the "b" register should be $80 if we hit the X side and 
	; $00 if we hit the Y side.
end_special_cases:
	; Calculate height of line to draw on screen
	; uint8_t lineHeight = DIST_TO_HEIGHT[perpWallDist];
        ld 	a, (dist)
        ld 	h, high(DIST_TO_HEIGHT)
        ld 	l, a
        ld 	a, (hl)

	; Set high bit depending on side.
	or 	b

        pop 	bc
        pop 	hl
        ret


; -------------------------------------------
; Multiply 8-bit signed values.
; In:  Multiply H with E
; Out: HL = result

signed_mult_8:
        push 	af
        push 	de
        ld 	l, 0 ; sign counter
        ; Make H non-negative.
	bit 	7, h
        jp	z, h_not_negative
        ld 	a, h
        neg
        ld 	h, a
	inc 	l
h_not_negative:
        ; Make E non-negative.
	bit 	7, e
        jp 	z, e_not_negative
        ld 	a, e
        neg
        ld 	e, a
	inc 	l
e_not_negative:
        bit 	0, l
        jp 	z, hl_not_negative
        call 	mult8
        ; Negate HL.
        ld 	a, l
        cpl
        ld 	l, a
        ld 	a, h
        cpl
        ld 	h, a
        inc 	hl
        pop 	de
        pop 	af
	ret
hl_not_negative:
        call 	mult8
        pop 	de
        pop 	af
        ret

        
; -------------------------------------------
; Multiply 8-bit unsigned values.
; In:  Multiply H with E
; Out: HL = result,  D = 0

mult8:
	ld 	d, 0		; clear d
	ld 	l, d		; clear l
	ld 	b, 8		; number of bits
mullp4:	add 	hl, hl	; shift left into carry
	jr 	nc, no_add	; top bit was zero,  don't add
	add 	hl, de	; add E
no_add:	djnz 	mullp4
	ret




;; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
show_menu_map:			;too hard to re-use same show_map code coz of need for $7000 for menu and video_buffer for in-game.
				;so replicate this for menu at $7000 video.
				; SHOW MAP in menu
				; 8x8 Lines.
				; displays in direct video.
;; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

	ld	hl,  MAZE		
	ld	de,  $7000+32*8
	ld	bc,  8
	ldir
	ld	de,  $7000+32*9
	ld	bc,  8
	ldir
	ld	de,  $7000+32*10
	ld	bc,  8
	ldir
	ld	de,  $7000+32*11
	ld	bc,  8
	ldir
	ld	de,  $7000+32*12
	ld	bc,  8
	ldir
	ld	de,  $7000+32*13
	ld	bc,  8
	ldir
	ld	de,  $7000+32*14
	ld	bc,  8
	ldir
	ld	de,  $7000+32*15
	ld	bc,  8
	ldir

	ld	hl, leveltitle
	ld	de, $7000+9+12*32
	ld	bc, 12
	ldir


	ret

;; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
show_map:			; SHOW MAP by pressing <Z>
				; 8x8 Lines.
				; USED in Game
				; displays in screen buffer.

;; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
	exx

	ld	a, (maponoff)
	cp	1
	jr	nz, endmap		; if 0 then ignore drawing map.

	ld	hl,  MAZE		; else, a=1 (map on), so draw it.
	ld	de,  videobuffer+32*8
	ld	bc,  8
	ldir
	ld	de,  videobuffer+32*9
	ld	bc,  8
	ldir
	ld	de,  videobuffer+32*10
	ld	bc,  8
	ldir
	ld	de,  videobuffer+32*11
	ld	bc,  8
	ldir
	ld	de,  videobuffer+32*12
	ld	bc,  8
	ldir
	ld	de,  videobuffer+32*13
	ld	bc,  8
	ldir
	ld	de,  videobuffer+32*14
	ld	bc,  8
	ldir
	ld	de,  videobuffer+32*15
	ld	bc,  8
	ldir

	ld	de,  videobuffer+32*8			; show player on map.
	ld	a, (mapX)
	add	a, e
	ld	e, a
	ld	h, 0
	ld	a, (mapY)
	sla	a
	sla	a
	ld	l, a
	add	hl, de
	ld	a, "#"
	ld	(hl), a

endmap:	exx

	ret





;; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
show_credits:					; DISPLAY CREDITS
						; 7 lines.
						; 32x12 chars
;; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
	exx


	ei
	call	$01c9				; VZ ROM CLS
	di

	ld	hl, credits			; 
	ld	de, $7000			; 
	ld	b, 224				;
scloop0:ld	a, (hl)				; 
	or	64				; Read string, per each chr$ do an "OR 64", display it.	
	ld	(de), a
	inc	hl
	inc	de
	djnz	scloop0


	call	press_space	
	exx
	ret					


;; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
;;   Press <SPACE> to Start				
;; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
press_space:
spcloop:ld 	a,  (0x68ef)	
	and	0x10
	jr	z,   You_pressed_space
	jr 	nz,  spcloop
You_pressed_space:
	ret




cameraX:    db  0    ; int8_t
dirX: 	    db  0    ; int8_t
dirY: 	    db  0    ; int8_t
planeX:	    db  0    ; int8_t
planeY:     db  0    ; int8_t
rayDirX:    db  0    ; int8_t
rayDirY:    db  0    ; int8_t
mapX:	    db  1    ; uint8_t
mapY:	    db  1    ; uint8_t,  pre-shifted left 3
side:	    db  0    ; uint8_t,  was a NS or a EW wall hit?
dist:	    db  0    ; uint8_t
deltaDistX: db  0    ; uint8_t
deltaDistY: db  0    ; uint8_t
sideDistX:  dw  0    ; uint16_t   ; length of ray from current position to next x or y-side
sideDistY:  dw  0    ; uint16_t
stepX:	    db  0    ; int8_t     ; what direction to step in x or y-direction (either +1 or -1)
stepY:	    db  0    ; int8_t     ; pre-shifted left 3
hit:	    db  0    ; uint8_t
posX:	    db  116; 108  ;100	; Game state
posY:	    db  128
dir:	    db  4
maponoff:   db  1
savePosX:   db  0
savePosY:   db  0



menu0:	db "+-----  .WOLFENSTEIN 3D. ------+" 
	db "! SELECT MAZE      CONTROLS    !"
 	db "! MAZE#1 TO #9  Q :FORWARDS    !"     
	db "! (1-9)         A :BACKWARDS   !"
	db "!               M :TURN LEFT   !"     
 	db "!               , :TURN RIGHT  !" 
	db "! PRESS SPACE   S :STRAFF LEFT !"  
	db "!   TO PLAY     D :STRAFF RIGHT!"
	db "!               Z :MAP ON/OFF  !"
	db "!               X :MENU        !"
	db "!               C :CREDITS     !"

;           12345678901234567890123456789012
credits:db "VZ WOLFENSTEIN 3D      6KB VZ200"
        db "                        LASER210"
	db "CREDITS                         "
	db "WOLF ENGINE :LAWRENCE KESTELOOT."
	db "PORT TO VZ  :DAVE (2024)        "
        db "                                "
        db "    PRESS <SPACE> TO CONTINUE   "



        org ($ + 255) & $FF00
DIV3: ; Divide 0 to 24 by 3,  floored.
         db  0,0,0, 1,1,1, 2,2,2
         db  3,3,3, 4,4,4, 5,5,5
         db  6,6,6, 7,7,7, 8


level1:  db  "********"
	 db  "*      *"
	 db  "*      *"
	 db  "*      *"
	 db  "*      *"
	 db  "*      *"
	 db  "*      *"
	 db  "********"
level1title       db "OPEN",96,"SLATHER"

level2:	 db  "********"
	 db  "*      *"
	 db  "*      *"
	 db  "*  *   *"
	 db  "*   *  *"
	 db  "*      *"
	 db  "*      *"
	 db  "********"
level2title       db "RUN",96,"BABY",96,"RUN"




        org ($ + 255) & $FF00
TOP_TEXTURE_1: ; Map 0 to 24 to top characater.
	db topwalltexture1, topwalltexture1, topwalltexture1
	db topwalltexture1, topwalltexture1, topwalltexture1
	db topwalltexture1, topwalltexture1, topwalltexture1
	db topwalltexture1, topwalltexture1, topwalltexture1
	db topwalltexture1, topwalltexture1, topwalltexture1
	db topwalltexture1, topwalltexture1, topwalltexture1
	db topwalltexture1, topwalltexture1, topwalltexture1
	db topwalltexture1, topwalltexture1, topwalltexture1
	db topwalltexture1, topwalltexture1, topwalltexture1

;         db  128+16+32,128+4+8+16,128+1+2+4+16
;         db  128+16+32,128+4+8+16,128+1+2+4+16
;         db  128+16+32,128+4+8+16,128+1+2+4+16
;         db  128+16+32,128+4+8+16,128+1+2+4+16
;         db  128+16+32,128+4+8+16,128+1+2+4+16
;         db  128+16+32,128+4+8+16,128+1+2+4+16
;         db  128+16+32,128+4+8+16,128+1+2+4+16
;         db  128+16+32,128+4+8+16,128+1+2+4+16
;         db  128+16+32,128+4+8+16,128+1+2+4+16


level3:	 db  "********"
	 db  "*      *"
	 db  "*  *   *"
	 db  "*  *   *"
	 db  "*  *   *"
	 db  "*  *   *"
	 db  "*      *"
	 db  "********"
level3title       db "GET",96,"IN",96,"LINE",96

level4:	 db  "********"
	 db  "*      *"
	 db  "* *  * *"
	 db  "*      *"
	 db  "* *  * *"
	 db  "*  **  *"
	 db  "*      *"
	 db  "********"
level4title       db "SMILE",96,96,96,96,96,96,96


level5:	 db  "********"
	 db  "*      *"
	 db  "*****  *"
	 db  "*      *"
	 db  "* ******"
	 db  "* *    *"
	 db  "*   *  *"
	 db  "********"
level5title       db "FIND",96,"ME",96,96,96,96,96


	org ($ + 255) & $FF00
TOP_TEXTURE_2: ; Map 0 to 24 to top characater.
;         db  128+16+32,128+4+8,128+1+2+4
;         db  128+16+32,128+4+8,128+1+2+4
;         db  128+16+32,128+4+8,128+1+2+4
;         db  128+16+32,128+4+8,128+1+2+4
;         db  128+16+32,128+4+8,128+1+2+4
;         db  128+16+32,128+4+8,128+1+2+4
;         db  128+16+32,128+4+8,128+1+2+4
;         db  128+16+32,128+4+8,128+1+2+4
;         db  128+16+32,128+4+8,128+1+2+4
	db topwalltexture2, topwalltexture2, topwalltexture2
	db topwalltexture2, topwalltexture2, topwalltexture2
	db topwalltexture2, topwalltexture2, topwalltexture2
	db topwalltexture2, topwalltexture2, topwalltexture2
	db topwalltexture2, topwalltexture2, topwalltexture2
	db topwalltexture2, topwalltexture2, topwalltexture2
	db topwalltexture2, topwalltexture2, topwalltexture2
	db topwalltexture2, topwalltexture2, topwalltexture2
	db topwalltexture2, topwalltexture2, topwalltexture2


level6:	 db  "********"
	 db  "* *    *"
	 db  "* * ** *"
	 db  "* * *  *"
	 db  "* * * **"
	 db  "* * *  *"
	 db  "*   *  *"
	 db  "********"
level6title       db "FIND",96,"YOU",96,96,96,96

level7:	 db  "********"
	 db  "* *    *"
	 db  "*    * *"
	 db  "*    * *"
	 db  "*      *"
	 db  "*   ****"
	 db  "**     *"
	 db  "********"
level7title       db "FIGHT",96,"ARENA",96

level8:	 db  "********"
	 db  "* *  * *"
	 db  "* *  * *"
	 db  "*   ** *"
	 db  "* *    *"
	 db  "* *  * *"
	 db  "* *  * *"
	 db  "********"
level8title       db "LOST",96,96,96,96,96,96,96,96



	org ($ + 255) & $FF00
BOTTOM_TEXTURE_1:
;         db  128+1+2,128+1+4+8,128+1+4+16+32
;         db  128+1+2,128+1+4+8,128+1+4+16+32
;         db  128+1+2,128+1+4+8,128+1+4+16+32
;         db  128+1+2,128+1+4+8,128+1+4+16+32
;         db  128+1+2,128+1+4+8,128+1+4+16+32
;         db  128+1+2,128+1+4+8,128+1+4+16+32
;         db  128+1+2,128+1+4+8,128+1+4+16+32
;         db  128+1+2,128+1+4+8,128+1+4+16+32
;         db  128+1+2,128+1+4+8,128+1+4+16+32
	db	bottomwalltexture1, bottomwalltexture1, bottomwalltexture1
	db	bottomwalltexture1, bottomwalltexture1, bottomwalltexture1
	db	bottomwalltexture1, bottomwalltexture1, bottomwalltexture1
	db	bottomwalltexture1, bottomwalltexture1, bottomwalltexture1
	db	bottomwalltexture1, bottomwalltexture1, bottomwalltexture1
	db	bottomwalltexture1, bottomwalltexture1, bottomwalltexture1
	db	bottomwalltexture1, bottomwalltexture1, bottomwalltexture1
	db	bottomwalltexture1, bottomwalltexture1, bottomwalltexture1
	db	bottomwalltexture1, bottomwalltexture1, bottomwalltexture1

	org ($ + 255) & $FF00
BOTTOM_TEXTURE_2:
;         db  128+1+2,128+4+8,128+4+16+32
;         db  128+1+2,128+4+8,128+4+16+32
;         db  128+1+2,128+4+8,128+4+16+32
;         db  128+1+2,128+4+8,128+4+16+32
;         db  128+1+2,128+4+8,128+4+16+32
;         db  128+1+2,128+4+8,128+4+16+32
;         db  128+1+2,128+4+8,128+4+16+32
;         db  128+1+2,128+4+8,128+4+16+32
;         db  128+1+2,128+4+8,128+4+16+32
	db	bottomwalltexture2, bottomwalltexture2, bottomwalltexture2
	db	bottomwalltexture2, bottomwalltexture2, bottomwalltexture2
	db	bottomwalltexture2, bottomwalltexture2, bottomwalltexture2
	db	bottomwalltexture2, bottomwalltexture2, bottomwalltexture2
	db	bottomwalltexture2, bottomwalltexture2, bottomwalltexture2
	db	bottomwalltexture2, bottomwalltexture2, bottomwalltexture2
	db	bottomwalltexture2, bottomwalltexture2, bottomwalltexture2
	db	bottomwalltexture2, bottomwalltexture2, bottomwalltexture2
	db	bottomwalltexture2, bottomwalltexture2, bottomwalltexture2

BUFFER: ds SCREEN_WIDTH

      	org ($ + 255) & $FF00
MAZE:  	db  "********"		; TEMP storage space for maze copy "into"
	db  "*      *"
	db  "*      *"
	db  "*      *"
	db  "*      *"
	db  "*      *"
	db  "*      *"
	db  "********"
leveltitle: db "            "





level9:	 db  "********"
	 db  "*      *"
	 db  "*  **  *"
	 db  "* **** *"
	 db  "* **** *"
	 db  "*  **  *"
	 db  "*      *"
	 db  "********"
level9title       db "CROSSED",96,"UP",96,96


level0:	 db  "********"
	 db  "*      *"
	 db  "* * ** *"
	 db  "* * *  *"
	 db  "* **** *"
	 db  "*  * * *"
	 db  "* ** * *"
	 db  "********"
level0title       db "HIDDEN",96,"LEVEL"




        org ($ + 255) & $FF00
DIR_TABLE_X:
	 db  32,32,31,31,30,28,27,25
	 db  23,20,18,15,12,9,6,3
	 db  0,-3,-6,-9,-12,-15,-18,-20
	 db  -23,-25,-27,-28,-30,-31,-31,-32
	 db  -32,-32,-31,-31,-30,-28,-27,-25
	 db  -23,-20,-18,-15,-12,-9,-6,-3
	 db  0,3,6,9,12,15,18,20
	 db  23,25,27,28,30,31,31,32

        org ($ + 255) & $FF00
DIR_TABLE_Y:
	 db  0,-3,-6,-9,-12,-15,-18,-20
	 db  -23,-25,-27,-28,-30,-31,-31,-32
	 db  -32,-32,-31,-31,-30,-28,-27,-25
	 db  -23,-20,-18,-15,-12,-9,-6,-3
	 db  0,3,6,9,12,15,18,20
	 db  23,25,27,28,30,31,31,32
	 db  32,32,31,31,30,28,27,25
	 db  23,20,18,15,12,9,6,3

        org ($ + 255) & $FF00
SIGNED_DIV_TABLE: ; abs(255/v)
	 db  0,255,127,85,63,51,42,36
	 db  31,28,25,23,21,19,18,17
	 db  15,15,14,13,12,12,11,11
	 db  10,10,9,9,9,8,8,8
	 db  7,7,7,7,7,6,6,6
	 db  6,6,6,5,5,5,5,5
	 db  5,5,5,5,4,4,4,4
	 db  4,4,4,4,4,4,4,4
	 db  3,3,3,3,3,3,3,3
	 db  3,3,3,3,3,3,3,3
	 db  3,3,3,3,3,3,2,2
	 db  2,2,2,2,2,2,2,2
	 db  2,2,2,2,2,2,2,2
	 db  2,2,2,2,2,2,2,2
	 db  2,2,2,2,2,2,2,2
	 db  2,2,2,2,2,2,2,2
	 db  1,2,2,2,2,2,2,2
	 db  2,2,2,2,2,2,2,2
	 db  2,2,2,2,2,2,2,2
	 db  2,2,2,2,2,2,2,2
	 db  2,2,2,2,2,2,2,2
	 db  2,2,2,3,3,3,3,3
	 db  3,3,3,3,3,3,3,3
	 db  3,3,3,3,3,3,3,3
	 db  3,4,4,4,4,4,4,4
	 db  4,4,4,4,4,5,5,5
	 db  5,5,5,5,5,5,6,6
	 db  6,6,6,6,7,7,7,7
	 db  7,8,8,8,9,9,9,10
	 db  10,11,11,12,12,13,14,15
	 db  15,17,18,19,21,23,25,28
	 db  31,36,42,51,63,85,127,255

        org ($ + 255) & $FF00
DIST_TO_HEIGHT:
	 db  24,24,24,24,24,24,24,24
	 db  24,24,23,22,20,18,17,16 ; Make one 24 -> 23.
	 db  14,14,13,12,11,11,10,10
	 db  9,9,8,8,8,7,7,7
	 db  6,6,6,6,6,5,5,5
	 db  5,5,5,4,4,4,4,4
	 db  4,4,4,4,3,3,3,3
	 db  3,3,3,3,3,3,3,3
	 db  2,2,2,2,2,2,2,2
	 db  2,2,2,2,2,2,2,2
	 db  2,2,2,2,2,2,1,1
	 db  1,1,1,1,1,1,1,1
	 db  1,1,1,1,1,1,1,1
	 db  1,1,1,1,1,1,1,1
	 db  1,1,1,1,1,1,1,1
	 db  1,1,1,1,1,1,1,1
	 db  0,0,0,0,0,0,0,0
	 db  0,0,0,0,0,0,0,0
	 db  0,0,0,0,0,0,0,0
	 db  0,0,0,0,0,0,0,0
	 db  0,0,0,0,0,0,0,0
	 db  0,0,0,0,0,0,0,0
	 db  0,0,0,0,0,0,0,0
	 db  0,0,0,0,0,0,0,0
	 db  0,0,0,0,0,0,0,0
	 db  0,0,0,0,0,0,0,0
	 db  0,0,0,0,0,0,0,0
	 db  0,0,0,0,0,0,0,0
	 db  0,0,0,0,0,0,0,0
	 db  0,0,0,0,0,0,0,0
	 db  0,0,0,0,0,0,0,0
	 db  0,0,0,0,0,0,0,0

videobuffer	equ $

        end entry
