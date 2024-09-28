;
;	WOLF-LOW.VZ	MODE(0) version
;	WOLF-HI.VZ	MODE(1) version
;
;   WOLFENSTEIN FPS CODE.  by Lawrence Kesteloot.  e: lk@teamten.com
;   https://github.com/lkesteloot/trs80/tree/master/apps/wolf
;   Ported from original TRS80 model 1 to VZ by silly dave.
;   Wolf wiki: https://en.wikipedia.org/wiki/Wolfenstein_3D$Development
;   Music player by Lyndon Sharp, modified by Shiru.
;   Intro tune by Dave
;   Menu tune by Shiru
;   Slapped together by dave over ~2 or so weeks. Released : 22/9/2024
;
;
; Found src code for trs80 on Lawrence github for the TRS80 Model 1.
; Grabbed it and ran with it. 
; Q - forward		Z - Show Map (MODE0 game only)
; A - back		X - Menu
; M - left		C - Credits
; ,  - right
; s - straffe left
; d - straffe right
;
;
;
;
; ------------------------------------------------------------
;
;	c	: seems to be working ok.  Blue coloured wall.
;	D 
;	E	; with lyndon 1bit music. try.
;	H	; intro + music + mode(0) + menu + key + game. TRY.
; 	I	; Z=MAP
;	I2	; working. current.
;mode0	I3	: column texture 1 and 2
;	J	: stable mode 0
;	j2a	: both tunes. 2nd tune needs mode0 in player
;	k	: intro tune. 2nd tune turned off. 6 mazes (working). inscreen map working. stable.
;	k1	: fiddling with postion. no luck
;	k2	: second tune on menu - seperate player.
;	k3	: 2nd tune working. Fiddling with keys & showmap within 2nd tune playing
;	k5      : credits
;	k6	: credits
;	k74     : stable
;	k75	: credit music player
;	k84	: seems to be stable. levels 1-0. 
;
;	To do:
;		- initial port			done
;		- 32x16 operation		done
;		- intro screen			done
;		- intro tunes			done
;		- do map			done
;		- player positon on map		done
;		- second tune being on menu	done
;		- texture sides on walls	fail
;		- mode 1
;		- add credits			done
;		- music in credits              done
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
origin		equ $8000
videobuffer	equ $AB00


        org $8000

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
	ld	a, 8					; Mode(1)
	ld	($6800), a

	ld	hl, introscreen				; display intro screen
	ld	de, $7000
	ld	bc, 2048
	ldir

	ld	hl, intro_music_data			; Play intro music
	call 	playlyndon91

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

	ld	hl, wolf_menu_tune		; play menu/credit tune.
	call	playlyndon91menu

skip_menu_song:
	ret





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
						; 12 lines.
						; 32x12 chars
;; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
	exx


	ei
	call	$01c9				; VZ ROM CLS
	di

	ld	hl, credits			; 
	ld	de, $7000			; 
	ld	b, 255				;
scloop0:ld	a, (hl)				; 
	or	64				; Read string, per each chr$ do an "OR 64", display it.	
	ld	(de), a
	inc	hl
	inc	de
	djnz	scloop0
	ld	b, 129
scloop1:ld	a, (hl)
	or	64
	ld	(de), a
	inc	hl
	inc	de
	djnz	scloop1

	ld	hl, wolf_menu_tune		; play menu/credit tune
	call	playlyndon91menu
	
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
credits:db "VZ WOLFENSTEIN 3D               "
        db "                                "
	db "            CREDITS             "
	db "WOLF ENGINE :LAWRENCE KESTELOOT."
	db "PORT TO VZ  :DAVE (2024)        "
	db "INTRO MUSIC :DAVE.              "
	db "MENU MUSIC  :SHIRU.             "
	db "MUSIC PLAYER:LYNDON SHARP.      "
	db "             MODIFIED BY SHIRU. "
        db "                                "
        db "                                "
        db "    PRESS <SPACE> TO CONTINUE   "


;msg_press_space1:   db  "PRESS"
;msg_press_space2:   db  124, "SPACE", 126
;msg_press_space3:   db  "TO", 96, "PLAY"





        org ($ + 255) & $FF00
DIV3: ; Divide 0 to 24 by 3,  floored.
         db  0,0,0, 1,1,1, 2,2,2
         db  3,3,3, 4,4,4, 5,5,5
         db  6,6,6, 7,7,7, 8

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





; ===========================================
;
;Beeper music engine  ---  LYNDON91 engine, by Lyndon Sharp.
;
;	
;Two channels of tone, no volume or timbre control, non-interrupting sampled drums
;Originally written by Lyndon Sharp circa 1991
;Reverse engineered from Bubble Dizzy game and modified by Shiru, 06'2017
; ===========================================
;
; INTRO MUSIC PLAYER.
; PLAYS WOLF THEME: "WONDERING WHERE MY LOVED ONES ARE".
;    ...chucked together crappily by Dave in 1-Tracker.


;musicplayer:
songmask	equ	8
playlyndon91:
;play
	di
	ld 	c, (hl)			;read first channel pointer
	inc 	hl
	ld 	b, (hl)
	inc 	hl
	ld 	(ch1_ptr), bc
	ld 	c, (hl)			;read first channel loop pointer
	inc 	hl
	ld 	b, (hl)
	inc 	hl
	ld 	(ch1_loop), bc
	ld 	c, (hl)			;read second channel pointer
	inc 	hl
	ld 	b, (hl)
	inc 	hl
	ld 	(ch2_ptr), bc
	ld 	c, (hl)			;read second channel loop pointer
	inc 	hl
	ld 	b, (hl)
	inc 	hl
	ld 	(ch2_loop), bc
	ld 	c, (hl)			;read loop portion length
	inc 	hl
	ld 	b, (hl)
	inc 	hl
	ld 	(loop_len), bc
	ld 	c, (hl)			;read song length
	inc 	hl
	ld 	b, (hl)
	inc 	hl
	ld 	a, (hl)			;read song speed
	inc 	hl
	ld 	(song_speed), a

play_loop
	call play_row
	push	af

; --------------------------------------------------------------------------------------------------
;   Press <S> to Start				
; --------------------------------------------------------------------------------------------------

s_key3:	ld 	a, (0x68fd)	
	and	0x02
	jr	nz, continue8	;you_didnt_press_S_key
you_pressed_s_key:
	pop	af
	ret			; continue on with game!
	
continue8:			; you_didnt_press_Space_key:	
	pop	af		; Keep playing the tunes!
play_not_done
	dec  	bc
	ld   	a, b
	or   	c
	jp   	nz, play_loop

	ret		; loop/no loop



ch1_loop 	equ $+1
	ld   	hl, 0
	ld   	(ch1_ptr), hl
ch2_loop 	equ $+1
	ld   	hl, 0
	ld   	(ch2_ptr), hl
loop_len 	equ $+1
	ld   	bc,0
	jp   	play_loop
play_row
	push 	bc
mask0	equ	$
mask1	equ	$+1
mask2	equ	$+2

	ld   	ix, $2828	;1010			;tone channels beeper port mask
	ld   	d, 0
ch1_ptr 	equ $+1
	ld   	hl, 0				;read first channel pointer
	ld   	c, (hl)				;read note byte
	ld   	a, c
	and  	$3F				;note is in 6 lower bits
	jr   	nz, $+5				;if it is non-zero, it is note number
	ld   	ixl, 0				;otherwise mute channel by clearing the mask
	inc  	hl					;advance channel pointer
	ld   	(ch1_ptr), hl		;store channel pointer
	ld   	e, a				;calculate offset in the note table
	ld   	hl, note_table
	add  	hl, de
	ld   	a, (hl)				;load divider
	ld   	(ch1_div), a		;store it to the sound loop code
ch2_ptr 	equ $+1
	ld   	hl, 0				;the same for second channel
	ld   	b, (hl)
	ld   	a, b
	and  	$3F
	jr   	nz, $+5
	ld   	ixh, 0
	inc  	hl
	ld   	(ch2_ptr), hl
	ld   	e, a
	ld   	hl, note_table
	add  	hl, de
	ld   	a, (hl)
	ld   	(ch2_div), a
	
	ld   	a, b				;get drum number from the top 2 bits of both channels
	rlca					;channel 2 has bits 3 and 2, channel 2 has bits 1 and 0
	rlca
	rl   	c
	rla
	rl   	c
	rla
	and  	$0F				;drum numbers pre-shifted by 1, so there is just 8 drums possible
	ld   	c, a				;calculate offset in the sample list
	ld   	b, 0
	jr 	z, empty_sample		;new code to cut samples once they done playing, 6*32*8 equ 1536 bits per sample
	ld 	a, 5
	ld 	(sample_len), a
empty_sample
	ld   	hl, sample_pointers
	add  	hl, bc
	ld   	a, (hl)				;load pointer from the sample list
	inc  	hl
	ld   	h, (hl)
	ld   	l, a
	ld   	(sample_ptr), hl	;store it to the sound loop code
	ld   	a, $12				;setup channels state
	ld   	(ch1_decay), a
	ld   	a,$1A
	ld   	(ch2_decay), a
	ld   	l, a
	xor  	a
	ex	af, af'
	xor  	a
mask3	equ 	$+1
	ld   	h, $28
	ld   	de, $0101
	exx
	ld  	bc, $0808
sample_ptr 	equ $+1
	ld   	hl, sample_0
		
;	ld   	d, $21					;sample output bit mask
mask4	equ	$+1
	ld   	d, $28	; music mask with mode(1)	;sample output bit mask
	exx
	
song_speed 	equ $+1
	ld   	c, 0				;duration of the outer loop
	
sound_loop_1
	ld   	b, 0				;duration of the inner loop

sound_loop_2
	ex	af, af'
	dec  	l
	jr   	nz, $+3
	xor  	a

mask5	equ	$
	or	songmask			; keep mode(1) for intro screen, Mode(0) for menu

	ld	($6800), a			;channel 1
	dec  	d
	jr   	nz, delay_3
	
ch1_div 	equ $+1
	ld   	d, 0
	xor  	ixl
ch1_decay equ $+1
	ld   	l, 0
delay_3_ret
	exx
	ld   	e, a
	ld   	a, (hl)
	and  	d

mask6	equ	$
	or	songmask			; keep mode(1)

	ld	($6800), a		
	add  	iy, iy			;timing, IY does not do anything
	add  	iy, iy
	rlc  	(hl)			;shift sample bits in place
	dec  	b
	jp   	nz, delay_1
	inc  	hl
	ld   	b, c
delay_1_ret
	ld  	a, e
	exx
	ex	af, af'
	dec  	h
	jr   	nz, $+3
	xor  	a

mask7	equ	$
	or	songmask		; keep mode(1)

	ld	($6800), a		;channel 2
	add  	iy,iy
	dec  	e
	jr   	nz,delay_2
ch2_div 	equ $+1
	ld   	e,0
	xor  	ixh
ch2_decay 	equ $+1
	ld   	h,0
delay_2_ret
	djnz 	sound_loop_2
	push 	af			;old part of this code has been optimized a bit, sample cutting is added
	push 	hl
sample_len 	equ $+1
	ld 	a,0
	or 	a
	jr 	nz,sample_count
	exx
	ld 	d,a
	exx
	jr 	no_sample_cut
sample_count
	dec 	a
	ld 	(sample_len),a
no_sample_cut
	ld 	hl,	ch1_decay
	inc 	(hl)
	ld 	hl,ch2_decay
	ld 	a,(hl)
	sub 	4
	ld 	(hl),a
	pop 	hl
	pop 	af
	dec  	c
	jp   	nz,sound_loop_1
	pop  	bc
	ret
	
delay_1	jp   	delay_1_ret
delay_2	xor  	$00
	jp   	delay_2_ret
delay_3	xor  	$00
	jp   	delay_3_ret




	


; ===========================================
;
;Beeper music engine  ---  LYNDON91 engine, by Lyndon Sharp.
;
;	
;Two channels of tone, no volume or timbre control, non-interrupting sampled drums
;Originally written by Lyndon Sharp circa 1991
;Reverse engineered from Bubble Dizzy game and modified by Shiru, 06'2017
; ===========================================
;
; MENU MUSIC PLAYER
; PLAYS SHIRU'S TEST EXAMPLE INTRO THEME FOR LYNDON91 ENGINE.
;


playlyndon91menu:

	di
	ld 	c, (hl)			;read first channel pointer
	inc 	hl
	ld 	b, (hl)
	inc 	hl
	ld 	(mch1_ptr), bc
	ld 	c, (hl)			;read first channel loop pointer
	inc 	hl
	ld 	b, (hl)
	inc 	hl
	ld 	(mch1_loop), bc
	ld 	c, (hl)			;read second channel pointer
	inc 	hl
	ld 	b, (hl)
	inc 	hl
	ld 	(mch2_ptr), bc
	ld 	c, (hl)			;read second channel loop pointer
	inc 	hl
	ld 	b, (hl)
	inc 	hl
	ld 	(mch2_loop), bc
	ld 	c, (hl)			;read loop portion length
	inc 	hl
	ld 	b, (hl)
	inc 	hl
	ld 	(mloop_len), bc
	ld 	c, (hl)			;read song length
	inc 	hl
	ld 	b, (hl)
	inc 	hl
	ld 	a, (hl)			;read song speed
	inc 	hl
	ld 	(msong_speed), a

mplay_loop
	call 	mplay_row

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
	jr	nz, m_cont_play
;	jr 	z, mplay_game2		
	pop	hl			; <SPACE> is pressed, continue game
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
m_cont_play:
	pop	hl
	pop	de
	pop	bc
	pop	af

mplay_not_done
	dec  	bc
	ld   	a, b
	or   	c
	jp   	nz, mplay_loop

;	ret				; djm	; loop/no loop

mch1_loop 	equ $+1
	ld   	hl, 0
	ld   	(mch1_ptr), hl
mch2_loop 	equ $+1
	ld   	hl, 0
	ld   	(mch2_ptr), hl
mloop_len 	equ $+1
	ld   	bc, 0
	jp   	mplay_loop

mplay_row
	push 	bc
	ld   	ix, $2020	;1010		;tone channels beeper port mask
	ld   	d, 0
mch1_ptr 	equ $+1
	ld   	hl, 0				;read first channel pointer
	ld   	c, (hl)				;read note byte
	ld   	a, c
	and  	$3F				;note is in 6 lower bits
	jr   	nz, $+5				;if it is non-zero, it is note number
	ld   	ixl, 0				;otherwise mute channel by clearing the mask
	inc  	hl				;advance channel pointer
	ld   	(mch1_ptr), hl			;store channel pointer
	ld   	e, a				;calculate offset in the note table
	ld   	hl, note_table
	add  	hl, de
	ld   	a, (hl)				;load divider
	ld   	(mch1_div), a			;store it to the sound loop code
mch2_ptr 	equ $+1
	ld   	hl, 0				;the same for second channel
	ld   	b, (hl)
	ld   	a, b
	and  	$3F
	jr   	nz, $+5
	ld   	ixh, 0
	inc  	hl
	ld   	(mch2_ptr), hl
	ld   	e, a
	ld   	hl, note_table
	add  	hl, de
	ld   	a, (hl)
	ld   	(mch2_div), a
	ld   	a, b				;get drum number from the top 2 bits of both channels
	rlca					;channel 2 has bits 3 and 2, channel 2 has bits 1 and 0
	rlca
	rl   	c
	rla
	rl   	c
	rla
	and  	$0F				;drum numbers pre-shifted by 1, so there is just 8 drums possible
	ld   	c, a				;calculate offset in the sample list
	ld   	b, 0
	jr 	z, mempty_sample		;new code to cut samples once they done playing, 6*32*8 equ 1536 bits per sample
	ld 	a, 5
	ld 	(msample_len), a
mempty_sample
	ld   	hl, sample_pointers
	add  	hl, bc
	ld   	a, (hl)				;load pointer from the sample list
	inc  	hl
	ld   	h, (hl)
	ld   	l, a
	ld   	(msample_ptr), hl		;store it to the sound loop code
	ld   	a, $12				;setup channels state
	ld   	(mch1_decay), a
	ld   	a,$1A
	ld   	(mch2_decay), a
	ld   	l, a
	xor  	a
	ex	af, af'
	xor  	a
	ld   	h, $20
	ld   	de, $0101
	exx
	ld  	bc, $0808
msample_ptr 	equ $+1
	ld   	hl, sample_0
	ld   	d, $21				; music mask with mode(1)	;sample output bit mask
	exx
msong_speed 	equ $+1
	ld   	c, 0				;duration of the outer loop
msound_loop_1
	ld   	b, 0				;duration of the inner loop
msound_loop_2
	ex	af, af'
	dec  	l
	jr   	nz, $+3
	xor  	a
	ld	($6800), a			;channel 1
	dec  	d
	jr   	nz, mdelay_3
mch1_div 	equ $+1
	ld   	d, 0
	xor  	ixl
mch1_decay equ $+1
	ld   	l, 0
mdelay_3_ret
	exx
	ld   	e, a
	ld   	a, (hl)
	and  	d
	ld	($6800), a		
	add  	iy, iy				;timing, IY does not do anything
	add  	iy, iy
	rlc  	(hl)				;shift sample bits in place
	dec  	b
	jp   	nz, mdelay_1
	inc  	hl
	ld   	b, c
mdelay_1_ret
	ld  	a, e
	exx
	ex	af, af'
	dec  	h
	jr   	nz, $+3
	xor  	a
	ld	($6800), a			;channel 2
	add  	iy,iy
	dec  	e
	jr   	nz,mdelay_2
mch2_div 	equ $+1
	ld   	e,0
	xor  	ixh
mch2_decay 	equ $+1
	ld   	h,0
mdelay_2_ret
	djnz 	msound_loop_2
	push 	af				;old part of this code has been optimized a bit, sample cutting is added
	push 	hl
msample_len 	equ $+1
	ld 	a,0
	or 	a
	jr 	nz,msample_count
	exx
	ld 	d,a
	exx
	jr 	mno_sample_cut
msample_count
	dec 	a
	ld 	(msample_len),a
mno_sample_cut
	ld 	hl, mch1_decay
	inc 	(hl)
	ld 	hl, mch2_decay
	ld 	a,(hl)
	sub 	4
	ld 	(hl),a
	pop 	hl
	pop 	af
	dec  	c
	jp   	nz, msound_loop_1
	pop  	bc
	ret
	
mdelay_1:jp   	mdelay_1_ret
mdelay_2:xor  	$00
	jp   	mdelay_2_ret
mdelay_3:xor  	$00
	jp   	mdelay_3_ret



note_table:
	db $00,$FA,$EB,$DE,$D2,$C6,$BB,$B0,$A6,$9D,$94,$8C,$84,$7C,$75,$6F
	db $69,$63,$5D,$58,$53,$4E,$4A,$46,$42,$3E,$3B,$37,$34,$31,$2E,$2C
	db $29,$27,$25,$23,$21,$1F,$1D,$1C,$1A,$19,$17,$16,$15,$14,$12,$00

	
sample_pointers:
	dw sample_0
	dw sample_4
	dw sample_3
	dw sample_2
	dw sample_1
	dw sample_0
	dw sample_0
	dw sample_0
	
	;original samples, each is $c0 long, padded with zeroes, one sample is empty
	
sample_0:
	ds $c0,0
	
sample_1:
	db $8F,$02,$07,$E7,$DF,$10,$00,$FF,$FF,$0C,$00,$E7,$FF,$9F,$00,$00
	db $FF,$FF,$10,$00,$FF,$FF,$1F,$00,$20,$FF,$DF,$10,$60,$FF,$FF,$5F
	db $00,$41,$FF,$FF,$18,$00,$EF,$FF,$97,$00,$00,$FB,$FF,$1E,$00,$E3
	db $FF,$5D,$00,$00,$FF,$FF,$9F,$00,$60,$FF,$9F,$00,$00,$E7,$36,$B7
	db $00,$00,$6B,$AF     
	ds $c0-$44,0

sample_2:
	db $DD,$04,$E0,$FF,$FF,$12,$00,$00,$00,$A0,$F7,$FF,$FF,$FF,$FF,$9E
	db $00,$00,$00,$00,$00,$03,$FF,$FF,$FF,$FF,$DF,$00,$00,$00,$00,$E0
	db $DF,$7F,$04,$00,$40,$80,$E2,$EF,$FF,$FF,$FB,$FE,$10,$06,$10,$38
	db $01,$84,$83,$0E,$52,$69,$29,$85,$83,$3E,$6C,$FC,$24,$D2,$03,$1C
	db $2E,$F4,$F0,$51,$A9,$84,$52,$1C,$D0,$73,$A9,$07,$5A,$59,$E8,$03
	db $E0,$87,$38,$3D,$F0,$04,$D6,$83,$2D,$AE,$D4,$F9,$90,$03,$89,$24
	db $78,$F8,$50,$E0,$9F,$76,$51,$8D,$D2,$73,$1E,$10,$07,$E1,$E7,$60
	db $61,$91,$2F,$98,$0D,$48,$06,$04,$24,$D2,$53,$89
	ds $c0-$7c,0
	
sample_3:
	db $88,$0B,$A3,$21,$F2,$E0,$38,$7E,$19,$04,$F9,$8F,$76,$A3,$EC,$90
	db $44,$D2,$6F,$D1,$27,$5D,$00,$36,$52,$4A,$21,$84
	ds $c0-$1c,0
	
sample_4:
	db $FD,$02,$62,$FF,$FF,$DF,$00,$00,$00,$00,$E1,$FF,$FF,$FF,$FF,$FF
	db $18,$00,$00,$00,$00,$00,$E6,$FF,$FF,$FF,$FF,$1C,$00,$00,$00,$00
	db $E3,$FF,$1E,$00,$00,$00,$00,$E7,$FF,$FF,$FF,$FF
	ds $c0-$2c,0


intro_music_data:			;compiled music data
music_data:
	dw .ptr1,.loop1
	dw .ptr2,.loop2
	dw $0001
	dw $009e
	db $06
.ptr1:	db $19,$19,$19,$20,$20,$20,$20,$20,$20,$20,$20,$20,$25,$25,$25,$20
	DB $20,$20,$25,$25,$25,$20,$20,$20,$19,$19,$19,$19,$19,$19,$00,$00
	DB $00,$00,$00,$00,$15,$15,$15,$1c,$1c,$1c,$1c,$1c,$1c,$1c,$1c,$1c
	DB $21,$21,$21,$1c,$1c,$1c,$21,$21,$21,$1c,$1c,$1c,$15,$15,$15,$00
	db $80,$80,$80,$00,$19,$19,$19,$20,$a0,$20,$20,$20,$20,$20,$20,$20
	db $a5,$25,$25,$20,$20,$20,$25,$25,$a5,$20,$20,$20,$19,$19,$19,$19
	db $99,$19,$00,$00,$00,$00,$00,$00,$95,$15,$15,$1c,$1c,$1c,$1c,$1c
	db $9c,$1c,$1c,$1c,$21,$21,$21,$1c,$9c,$1c,$21,$21,$21,$1c,$1c,$1c
	DB $95,$15,$15,$15,$15,$15,$00,$00,$00,$00,$00,$00,$80,$00,$80,$00
	DB $80,$00,$80,$80,$80,$80,$80,$80,$80,$80,$80,$00,$00
.loop1:	DB $00
.ptr2:	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$40,$19,$19,$19,$20,$20,$20,$20,$60,$20
	db $20,$20,$20,$25,$25,$25,$60,$20,$20,$25,$25,$25,$20
	db $20,$60,$19,$19,$19,$19,$19,$19,$00,$40,$00,$00,$00
	db $00,$15,$15,$15,$5c,$1c,$1c,$1c,$1c,$1c,$1c,$1c,$5c
	db $21,$21,$21,$1c,$1c,$1c,$21,$61,$21,$1c,$1c,$1c,$15
	db $15,$15,$55,$15,$15,$00,$40,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $40
.loop2: db $00


;-------------------------------------------------------------------------
wolf_menu_tune:				;compiled music data
;-------------------------------------------------------------------------

	dw .ptr1b,.loop1b
	dw .ptr2b,.loop2b
	dw $0040
	dw $0040
	db $06
.ptr1b
.loop1b
	db $8d, $0d, $19, $19, $8d, $0d, $19, $19, $0d, $0d
	db $99, $19, $8d, $0d, $19, $19, $89, $09, $95, $15
	db $89, $09, $15, $15, $09, $09, $95, $15, $89, $09
	db $15, $15, $86, $06, $12, $12, $86, $06, $12, $12
	db $06, $06, $92, $12, $86, $06, $92, $12, $88, $08
	db $14, $14, $88, $08, $14, $14, $88, $88, $94, $14
	db $88, $88, $14, $14


.ptr2b
.loop2b
	db $1c, $1c, $5c, $1c, $5b, $1b, $5c, $1c, $5c, $1c
	db $00, $00, $40, $00, $40, $00, $1c, $1c, $1c, $1c
	db $5b, $1b, $5c, $1c, $5c, $1c, $00, $00, $40, $00
	db $80, $80, $17, $17, $57, $17, $55, $15, $57, $17
	db $57, $17, $00, $00, $40, $00, $00, $00, $19, $19
	db $59, $19, $59, $19, $59, $19, $1b, $5b, $1b, $1b
	db $5b, $5b, $9b, $9b




;-------------------------------------------------------------------------
introscreen:		; WOlf 3d Intro screen
			; 4 colour.  128x64 resolution. (32 bytes x 64)
;-------------------------------------------------------------------------
db $0BB,$0BB,$0BB,$0BB,$0B0,$00B,$0BB,$0BB,$0BB,$0BB,$0BB,$0BB,$022,$0EE,$02C,$0BB
db $0BB,$0BB,$0BB,$0BB,$0BB,$0BB,$0BB,$0BB,$0BB,$0BB,$0BB,$0BB,$0BB,$0BB,$0BB,$0BB
db $0BB,$0BB,$0BB,$0BB,$095,$056,$0ED,$056,$0EE,$0EE,$0EE,$015,$056,$0C5,$055,$0BB
db $0BB,$0BB,$0BB,$0BB,$0BB,$0BB,$0BB,$0BB,$0BB,$0BB,$0BB,$0BB,$0BB,$0BB,$0BB,$0BB
db $0BB,$0BB,$0BB,$0BA,$055,$065,$0A5,$055,$0AE,$0EE,$0ED,$056,$066,$056,$066,$0BB
db $0BB,$0BB,$0BB,$0BB,$0BB,$0BB,$0BB,$0BB,$0BB,$0BB,$0BB,$0BB,$0BB,$0BB,$0BB,$0BB
db $0BB,$0BB,$0BB,$0B9,$055,$055,$065,$055,$06E,$0EE,$0E9,$055,$0A9,$055,$0AB,$0BB
db $0BB,$0BB,$0BB,$0BB,$0BB,$0BA,$0EE,$0EE,$0E9,$0BB,$0BB,$0BB,$0BB,$0BB,$0BB,$0BB
db $0BB,$0BB,$0BB,$0B9,$056,$055,$055,$055,$06E,$0EE,$0ED,$055,$0BA,$055,$0BB,$0BB
db $0BB,$0BB,$0BB,$0BB,$0BB,$0A5,$0BB,$0BB,$095,$06E,$0EE,$0EE,$0EE,$0EE,$0EE,$0EE
db $0EE,$0EE,$0EE,$0ED,$05A,$055,$065,$095,$06E,$055,$0B9,$055,$0B5,$055,$059,$056
db $0E5,$06D,$05B,$095,$056,$055,$06D,$05B,$099,$0AE,$056,$095,$0BB,$0BB,$0BB,$0BB
db $0BB,$0BB,$0BB,$0BA,$056,$055,$065,$095,$069,$055,$055,$055,$095,$055,$055,$056
db $055,$065,$059,$055,$059,$055,$055,$056,$055,$055,$056,$055,$0BB,$0BB,$0BB,$0BB
db $0BB,$0BB,$0BB,$0BB,$096,$055,$069,$055,$055,$059,$055,$055,$099,$055,$055,$055
db $095,$055,$055,$055,$069,$055,$055,$055,$095,$059,$055,$055,$0BB,$0BB,$0BB,$0BB
db $0BB,$0BB,$0BB,$0BB,$0AB,$055,$055,$055,$055,$059,$055,$055,$0B9,$055,$055,$055
db $055,$055,$059,$05A,$0B9,$055,$055,$055,$055,$059,$055,$055,$0BB,$0BB,$0BB,$0BB
db $0BB,$0BB,$0BB,$0BB,$0BA,$065,$055,$069,$059,$05A,$055,$095,$0B9,$0A5,$065,$0A5
db $059,$065,$055,$055,$059,$095,$065,$0A5,$059,$059,$096,$055,$0BB,$0BB,$0BB,$0BB
db $0BB,$0BB,$0BB,$0BB,$0BE,$055,$0D5,$0D5,$055,$079,$055,$057,$0B9,$055,$055,$0F5
db $095,$065,$079,$055,$05D,$057,$055,$0D5,$095,$079,$05E,$057,$0BB,$0BB,$0BB,$0BB
db $0BB,$0BB,$0BB,$0BB,$0AE,$055,$055,$055,$075,$07D,$05D,$057,$0BF,$057,$055,$057
db $0D5,$075,$05E,$0F5,$05D,$055,$055,$05F,$0D5,$07D,$057,$057,$0EE,$0EE,$0EE,$0EE
db $0EE,$0EE,$0EE,$0EE,$0EE,$055,$075,$057,$0F5,$07D,$05D,$057,$0D7,$057,$055,$05D
db $077,$075,$0FF,$0F5,$0DD,$05F,$055,$075,$0D5,$0F9,$07F,$05D,$0EE,$0EE,$0EE,$0EE
db $0EE,$0AE,$0EE,$0EE,$0EF,$0FF,$0FF,$0FF,$0BF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF
db $0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0FF,$0EE,$0EE,$0EE,$0EE
db $0EE,$0EE,$0EE,$0EE,$0EF,$0FF,$0BF,$0FB,$0BB,$0FF,$0BB,$0BF,$0EF,$0FF,$0EE,$0FF
db $0BF,$0EE,$0FE,$0FF,$0BB,$0FF,$0BB,$0FE,$0EF,$0FB,$0FE,$0FF,$0BB,$0BB,$0BB,$0BB
db $0BA,$0AA,$0AA,$0BA,$0BA,$0AB,$0AA,$0BB,$0BB,$0AB,$0BB,$0BB,$0FF,$0FF,$0EE,$0EB
db $0AB,$0BB,$0BB,$0AE,$0EE,$0BB,$0BB,$0BB,$0B8,$0BA,$0BB,$0AE,$0EE,$0EE,$0EE,$0EE
db $0EE,$0AA,$0AA,$0AE,$0BB,$0EE,$0FF,$0BB,$0BB,$0AA,$0EE,$0EF,$0FF,$0FE,$0EE,$0EE
db $0FB,$0BB,$0BB,$0BB,$0B2,$082,$0BB,$0BB,$0B0,$000,$02E,$0EE,$0EE,$0EE,$0EE,$0EE
db $0EE,$0AA,$0AE,$0BB,$0BB,$0AA,$0AA,$0BA,$0BA,$0AA,$0AB,$0BA,$0EE,$0EE,$0EE,$0EE
db $0BB,$0BB,$0BB,$0BB,$0A5,$055,$04B,$0BB,$095,$055,$054,$0BB,$0BB,$0BB,$0BB,$0BB
db $0BA,$0AA,$0AA,$0BB,$0BB,$0AE,$0FE,$0AA,$0EE,$0AA,$0AA,$0EA,$0EE,$0EE,$0EE,$0EE
db $0EE,$0EE,$0EE,$0EE,$0EA,$065,$05A,$0EE,$056,$066,$055,$05A,$0EE,$0EE,$0EE,$0EE
db $0EE,$0AA,$0AA,$0BB,$0BB,$0BB,$0AE,$0FB,$0BA,$0AA,$0AA,$0AA,$0AE,$0EE,$0EE,$0EE
db $0EE,$0EE,$0EE,$0EE,$0EE,$0A5,$05B,$0BA,$055,$055,$055,$056,$0BB,$0BB,$0BB,$0BB
db $0BB,$0AA,$0AE,$0BB,$0BB,$0BB,$0BB,$0BB,$0BA,$0AA,$0AA,$0AA,$0AA,$0AE,$0EE,$0EE
db $0EE,$0EE,$0EE,$0EE,$0EE,$0E5,$05B,$0BB,$05A,$055,$065,$055,$0BB,$0BB,$0BB,$0BB
db $0BB,$0AB,$0BB,$0BB,$0BB,$0BB,$0BB,$0BB,$0BB,$0AA,$0AA,$0AA,$0AA,$0AB,$0BB,$0BB
db $0BB,$0BB,$0BB,$0BB,$0B9,$0B5,$05B,$0B9,$059,$055,$069,$055,$0BB,$0BB,$0BB,$0BB
db $0BB,$0BB,$0BB,$0BB,$0BF,$0FF,$0EE,$0EE,$0EA,$0AA,$0AA,$0AA,$0AA,$0AA,$0EE,$0EE
db $0EE,$0EE,$0EE,$0EE,$0ED,$055,$065,$055,$096,$055,$06D,$055,$0BB,$0BB,$0BB,$0BB
db $0BB,$0BB,$0BB,$0BB,$0FD,$0D5,$0DE,$0EE,$0EA,$0AA,$0AA,$0AA,$0AA,$0AA,$0BB,$0BB
db $0BB,$0BB,$0BB,$0BB,$0B9,$055,$055,$056,$0E9,$0A5,$06A,$055,$0BB,$0BB,$0BB,$0BB
db $0BB,$0BB,$0BB,$0BB,$0DF,$0BB,$05E,$0EE,$0EA,$0AA,$0AA,$0AA,$0AA,$0AA,$0AE,$0EE
db $0EE,$0EE,$0EE,$0EE,$0E7,$0A5,$05A,$0AB,$0B9,$055,$07D,$055,$0BB,$0BB,$0BB,$0BB
db $0BB,$0BB,$0BB,$0BB,$0FD,$0F7,$0BB,$0BB,$0BA,$0AA,$0AA,$0AA,$0AA,$0AA,$0AB,$0BB
db $0BB,$0BB,$0BB,$0BB,$097,$0E5,$05F,$0FB,$0B7,$055,$065,$057,$0BB,$0BB,$0BB,$0BB
db $0BB,$0BB,$0BB,$0BA,$0FF,$0F5,$05E,$0EE,$0EA,$0AA,$0AA,$0AA,$0AA,$0AA,$0AA,$0BB
db $0BB,$0BB,$0BB,$0BB,$095,$0F5,$07E,$0BB,$0B5,$055,$0F5,$07F,$0BB,$0BB,$0BB,$0BB
db $0BB,$0BB,$0BB,$0BB,$0F7,$05F,$07B,$0BB,$0BA,$0AA,$0AA,$0AA,$0AA,$0AA,$0AA,$0AE
db $0EE,$0EE,$0EE,$0EE,$0FF,$0FF,$0FF,$0BB,$0BF,$0FF,$0FF,$0FB,$0BB,$0BB,$0BB,$0BB
db $0BB,$0BB,$0BB,$0BB,$07D,$055,$05E,$0EE,$0EE,$0AA,$0AA,$0AA,$0AA,$0AA,$0AA,$0AE
db $0EE,$0EE,$0EE,$0EE,$0EF,$0BB,$0BB,$0BB,$0BF,$0EA,$0AA,$0EE,$0EE,$0EE,$0EE,$0EE
db $0EE,$0EE,$0EE,$0D6,$0F9,$0D7,$0FB,$0BB,$0BA,$0AA,$0AA,$0AA,$0AA,$0AA,$0AA,$0AE
db $0EE,$0EE,$0EE,$0EE,$0EB,$0AF,$0BB,$0BB,$0AE,$0EE,$0EE,$0EE,$0EE,$0EE,$0EE,$0EE
db $0EE,$0EE,$0EE,$056,$0B5,$055,$07B,$0BB,$0BA,$0AA,$0AA,$0AA,$0AA,$0AA,$0AA,$0AA
db $0BB,$0BB,$0BB,$0B9,$055,$0AB,$0BB,$0BB,$0BB,$0BB,$0BB,$0BB,$0BB,$0BB,$0AA,$0AA
db $0BB,$0BB,$0B9,$06B,$0BD,$055,$07E,$0EE,$0EE,$0AA,$0AA,$0AA,$0AA,$0AA,$0AA,$0AA
db $0AE,$0EE,$0EE,$0E5,$095,$06E,$0EE,$0EE,$0EE,$0EE,$0EE,$0EE,$0EA,$0EA,$0AA,$0AA
db $0BB,$0BB,$095,$06E,$0EE,$0FF,$0EE,$0EE,$0EE,$0AA,$0AA,$0AA,$0AA,$0AA,$0AA,$0AA
db $0AB,$0BB,$0BB,$0B5,$055,$06E,$0EE,$0EE,$0EE,$0EE,$0EE,$0AA,$0BA,$0AA,$0AA,$0AA
db $0EE,$0EE,$05A,$06E,$0EE,$0EA,$066,$0EE,$0EE,$0AA,$0AA,$0AA,$0AA,$0AA,$0AA,$0AA
db $0AA,$0BB,$0BB,$096,$056,$05B,$0BB,$0BB,$0BB,$0BB,$0BA,$0AA,$0AA,$0EA,$0AA,$0AA
db $0BB,$0BB,$06F,$09E,$0EE,$0ED,$055,$06E,$0EE,$0AA,$0AA,$0AA,$0AA,$0AA,$0AA,$0AA
db $0AA,$0BB,$0BB,$0A7,$055,$09B,$0BB,$0AE,$0AA,$0EA,$0AB,$0BA,$0AA,$0EE,$0AA,$0AA
db $0BB,$0BA,$0ED,$07E,$0EE,$0EA,$055,$05B,$0BA,$0AA,$0AA,$0AA,$0AA,$0AA,$0AA,$0AA
db $0AA,$0BB,$0BA,$0AE,$055,$0EE,$0EE,$0AE,$0AA,$0BB,$0BA,$0AE,$0AA,$0BA,$0AA,$0AA
db $0BB,$0BB,$0BF,$077,$0BB,$0BE,$0A9,$056,$0EE,$0AA,$0AA,$0AA,$0AA,$0AA,$0AA,$0AA
db $0AA,$0BB,$0BA,$0AE,$0DF,$09B,$0BA,$0AE,$0AA,$0AA,$0AA,$0AA,$0AA,$0AA,$0AA,$0AA
db $0BB,$0BB,$0BD,$055,$0EE,$0EE,$0E5,$056,$0EE,$0AA,$0AA,$0AA,$0AA,$0AA,$0AA,$0AA
db $0AA,$0BB,$0BD,$0EE,$0D5,$055,$0AE,$0AA,$0AA,$0AA,$0AA,$0AA,$0AA,$0AA,$0AA,$0AA
db $0BB,$0BB,$0BF,$055,$06B,$0BB,$095,$056,$0EE,$0AA,$0AA,$0AA,$0AA,$0AA,$0AA,$0AA
db $0AA,$0BB,$0B5,$0FD,$055,$055,$06E,$0EE,$0AA,$0EE,$0AA,$0EA,$0AE,$0FA,$0AA,$0AA
db $0BB,$0BB,$0BB,$0E5,$055,$0BB,$0A5,$056,$0EE,$0AA,$0AA,$0AA,$0AA,$0AA,$0AA,$0AA
db $0AA,$0BB,$0B7,$0D9,$055,$075,$05A,$0AA,$0AA,$0AA,$0AA,$0AB,$0AA,$0BA,$0AA,$0AA
db $0BB,$0BB,$0BB,$0A5,$055,$05B,$0B5,$056,$0EE,$0AA,$0AA,$0AA,$0AA,$0AB,$0AA,$0AA
db $0AA,$0AB,$09F,$0D7,$0D5,$075,$05A,$0AE,$0AA,$0AA,$0AA,$0BA,$0AA,$0BB,$0AA,$0AA
db $0BB,$0BB,$0BB,$0B9,$055,$055,$055,$056,$0EE,$0AA,$0AA,$0AA,$0AA,$0AA,$0AA,$0AA
db $0AA,$0EE,$0FF,$0B5,$0ED,$05D,$05E,$0EE,$0AB,$0AA,$0AA,$0AA,$0AA,$0BA,$0AA,$0AA
db $0BB,$0BB,$0BB,$0BA,$0A9,$055,$055,$05B,$0BA,$0AA,$0AA,$0AA,$0AA,$0AA,$0AA,$0AA
db $0AA,$0BB,$097,$0BE,$057,$0BD,$05E,$0EE,$0EE,$0EE,$0AB,$0AA,$0AA,$0EA,$0AA,$0AA
db $0BB,$0BB,$0BB,$0BB,$0FA,$055,$055,$06E,$0EE,$0AA,$0AA,$0AA,$0AA,$0AA,$0AA,$0AA
db $0AA,$0EE,$0D7,$0F7,$055,$0B5,$05B,$0AA,$0EE,$0EE,$0FB,$0BB,$0BB,$0AA,$0AA,$0AA
db $0EE,$0EE,$0EE,$0EE,$0BB,$0A9,$099,$0BB,$0BA,$0AA,$0AA,$0AA,$0AA,$0AA,$0AA,$0AA
db $0AE,$0EA,$0D5,$0D5,$077,$055,$07A,$0AA,$079,$0AA,$0AA,$0EE,$0EE,$0EE,$0AA,$0AA
db $0BB,$0BB,$0BB,$0BB,$0BB,$0BB,$0BB,$0BB,$0BA,$0AA,$0AA,$0AA,$0AA,$0AA,$0AA,$0AA
db $0BB,$066,$095,$055,$07D,$055,$069,$0D6,$0F6,$09B,$06E,$0B6,$066,$0BB,$0AA,$0AA
db $0EE,$0EE,$0EE,$0EE,$0EE,$0EE,$0E6,$0EE,$0EE,$0AA,$0AA,$0AA,$0AA,$0AA,$0AA,$0BB
db $0B6,$0BA,$0E9,$055,$07F,$057,$0D9,$0B9,$0AA,$0AE,$0D9,$0B9,$0AB,$09A,$0BB,$0BB
db $0BB,$0BB,$0BB,$0BB,$0BB,$0BB,$0AE,$0BB,$0BA,$0AA,$0AA,$0AA,$0AA,$0AA,$0AA,$09A
db $069,$0E6,$07D,$055,$07F,$056,$06A,$06A,$066,$07D,$0A6,$05A,$069,$099,$099,$099
db $0BB,$0BB,$0BB,$0BB,$0A6,$0BB,$065,$06E,$0EE,$0AA,$0AA,$0AA,$0AA,$0AA,$0AA,$0BB
db $055,$056,$059,$055,$075,$056,$055,$055,$059,$095,$096,$065,$065,$066,$066,$056
db $0EE,$0EE,$0EE,$0EE,$0EF,$095,$055,$0BB,$0BA,$0AA,$0AA,$0AA,$0AA,$0AA,$0AA,$0E9
db $0A6,$066,$095,$055,$07D,$056,$05A,$069,$099,$06A,$066,$059,$099,$099,$066,$065
db $0BB,$0BB,$0BB,$0BB,$0B9,$055,$056,$0EE,$0EE,$0AA,$0AA,$0AA,$0AA,$0AA,$0AE,$0E5
db $066,$066,$097,$05D,$07B,$055,$0A5,$099,$099,$055,$066,$065,$099,$066,$0A6,$069
db $0BB,$0BB,$0BB,$0BA,$055,$056,$0A5,$06E,$0EE,$0AA,$0AA,$0AA,$0AA,$0AA,$0AE,$055
db $055,$055,$055,$0BF,$09B,$0F5,$055,$055,$055,$055,$055,$055,$055,$055,$055,$055
db $0BB,$0BB,$0BB,$0BE,$0AA,$0AB,$06A,$05B,$0BA,$0AA,$0AA,$0AA,$0AA,$0AA,$0B9,$055
db $055,$055,$055,$0BB,$09A,$095,$055,$055,$055,$055,$055,$055,$055,$055,$055,$055
db $0BB,$0BB,$0BB,$0AB,$0FF,$055,$095,$056,$0EE,$0AA,$0AA,$0AA,$0AA,$0AB,$0B5,$055
db $055,$055,$055,$0BB,$06F,$095,$055,$055,$055,$055,$055,$059,$055,$055,$055,$055
db $0BB,$0BB,$0BB,$095,$0AA,$0AB,$0A5,$056,$0EE,$0AA,$0AA,$0AA,$0AA,$0AB,$095,$055
db $055,$055,$055,$0BA,$0EB,$0A5,$055,$055,$055,$055,$055,$055,$055,$055,$055,$055
db $0BB,$0BB,$0BA,$066,$0FF,$0FB,$095,$056,$0EE,$0AA,$0AA,$0AA,$0AA,$0BB,$055,$055
db $055,$055,$055,$0BB,$0BB,$055,$055,$055,$055,$055,$055,$055,$055,$055,$055,$055
db $0BB,$0BB,$0B9,$059,$06A,$0BB,$0A5,$065,$0BA,$0AA,$0AA,$0AA,$0AA,$0ED,$055,$055
db $055,$055,$055,$055,$055,$055,$055,$055,$055,$055,$055,$055,$055,$055,$055,$055
db $0BB,$0BB,$0BB,$05A,$0BF,$0BB,$0A5,$059,$0BA,$0AA,$0AA,$0AA,$0AB,$0B5,$055,$055
db $055,$055,$055,$055,$055,$055,$055,$055,$055,$055,$055,$055,$055,$055,$055,$055
db $0BB,$0BB,$0B9,$055,$0AB,$0BB,$0BA,$056,$0EE,$0AA,$0AA,$0AA,$0BB,$095,$055,$055
db $055,$055,$055,$055,$055,$055,$055,$055,$055,$055,$055,$055,$055,$055,$055,$055
db $0BB,$0BB,$0B9,$055,$06E,$0EE,$0ED,$056,$0EE,$0AA,$0AA,$0AA,$0EE,$055,$055,$055
db $055,$055,$055,$055,$055,$055,$055,$055,$055,$055,$055,$055,$055,$055,$055,$055
db $0BB,$0BB,$0BA,$055,$0BB,$0BB,$0B9,$056,$0EE,$0AA,$0AA,$0AB,$0B9,$055,$055,$055
db $055,$055,$055,$055,$055,$055,$055,$055,$055,$055,$055,$055,$055,$055,$055,$055
db $0BB,$0BB,$0BA,$066,$06E,$0EE,$0ED,$055,$0BA,$0AA,$0AA,$0AE,$0E5,$055,$055,$055
db $055,$055,$055,$055,$055,$055,$055,$055,$055,$055,$055,$055,$055,$055,$055,$055
db $0BB,$0BB,$0BB,$0AB,$0BB,$0BB,$0BA,$056,$0EE,$0AA,$0AA,$0BB,$095,$055,$055,$055
db $055,$055,$055,$055,$055,$055,$055,$055,$055,$055,$055,$055,$055,$055,$055,$055
db $0BB,$0BB,$0BB,$0BB,$0BB,$0BB,$0BB,$09A,$0EE,$0AA,$0AA,$0EE,$055,$055,$055,$055
db $055,$055,$055,$055,$055,$055,$055,$055,$055,$055,$055,$055,$055,$055,$055,$055
 ; ---------------------------------------------------------

        end entry
