# VZ200_WOLFENSTEIN_3D
Wolfenstein 3D engine demo for Z80 VZ200 and VZ300


;	VZ300 OR VZ200+16k. WOLF-LOW.VZ	MODE(0) version. 10k

;	VZ300 OR VZ200+16k. WOLF-HI.VZ	MODE(1) version. 10k

; VZ200 WOLF3D-VZ200.VZ 6k lo-res version (compressed and semi-optimsied for size). 
;
;   WOLFENSTEIN FPS ENGINE CODE for TRS80-model1 by Lawrence Kesteloot. 

;   https://github.com/lkesteloot/trs80/tree/master/apps/wolf

;   Wolf wiki: https://en.wikipedia.org/wiki/Wolfenstein_3D$Development

;   Music player by Lyndon Sharp, modified by Shiru.

;   Ported from original TRS80 model 1 to VZ by dave.

;   Intro tune by Dave

;   Menu tune by Shiru

;   Slapped together by dave over ~2 or so weeks. Released : 22/9/2024

;
;
; Found src code for trs80 on Lawrence github for the TRS80 Model 1.

      Q - forward		Z - Show Map (MODE0 game only)
      A - back		X - Menu
      M - left		C - Credits
      ,  - right
      s - straffe left
      d - straffe right

The lo-res Z80 engine code could easily be ported to any other Z80 computer with a text/low graphics resolution of 32x16, 64x32 etc.
VZ Start of ram, at $7B00 or $8000.   Video is at $7000. Keyboard, graphics modes and sound latch at $6800.




