    ;;    game state memory location
    .equ CURR_STATE, 0x1000              ; current game state
    .equ GSA_ID, 0x1004                     ; gsa currently in use for drawing
    .equ PAUSE, 0x1008                     ; is the game paused or running
    .equ SPEED, 0x100C                      ; game speed
    .equ CURR_STEP,  0x1010              ; game current step
    .equ SEED, 0x1014              ; game seed
    .equ GSA0, 0x1018              ; GSA0 starting address
    .equ GSA1, 0x1038              ; GSA1 starting address
    .equ SEVEN_SEGS, 0x1198             ; 7-segment display addresses
    .equ CUSTOM_VAR_START, 0x1200 ; Free range of addresses for custom variable definition
    .equ CUSTOM_VAR_END, 0x1300
    .equ LEDS, 0x2000                       ; LED address
    .equ RANDOM_NUM, 0x2010          ; Random number generator address
    .equ BUTTONS, 0x2030                 ; Buttons addresses

    ;; states
    .equ INIT, 0
    .equ RAND, 1
    .equ RUN, 2

    ;; constants
    .equ N_SEEDS, 4
    .equ N_GSA_LINES, 8
    .equ N_GSA_COLUMNS, 12
    .equ MAX_SPEED, 10
    .equ MIN_SPEED, 1
    .equ PAUSED, 0x00
    .equ RUNNING, 0x01

main:
	addi sp, zero, 0x2000 ; initialise stack pointer
	call reset_game
	call get_input
	addi sp, sp, -4
	stw v0, 0(sp)
	loop:
		add a0, zero, v0
		call select_action
		ldw a0, 0(sp)
		addi sp, sp, 4
		call update_state
		call update_gsa
		call mask
		call draw_gsa
		call wait
		call decrement_step
		add t0, zero, v0
		call get_input
		addi sp, sp, -4
		stw v0, 0(sp)
		addi t1, zero, 1 ; have to manage the edgecapture
		bne t0, t1, loop
	jmpi main

font_data:
    .word 0xFC ; 0
    .word 0x60 ; 1
    .word 0xDA ; 2
    .word 0xF2 ; 3
    .word 0x66 ; 4
    .word 0xB6 ; 5
    .word 0xBE ; 6
    .word 0xE0 ; 7
    .word 0xFE ; 8
    .word 0xF6 ; 9
    .word 0xEE ; A
    .word 0x3E ; B
    .word 0x9C ; C
    .word 0x7A ; D
    .word 0x9E ; E
    .word 0x8E ; F

seed0:
    .word 0xC00
    .word 0xC00
    .word 0x000
    .word 0x060
    .word 0x0A0
    .word 0x0C6
    .word 0x006
    .word 0x000

seed1:
    .word 0x000
    .word 0x000
    .word 0x05C
    .word 0x040
    .word 0x240
    .word 0x200
    .word 0x20E
    .word 0x000

seed2:
    .word 0x000
    .word 0x010
    .word 0x020
    .word 0x038
    .word 0x000
    .word 0x000
    .word 0x000
    .word 0x000

seed3:
    .word 0x000
    .word 0x000
    .word 0x090
    .word 0x008
    .word 0x088
    .word 0x078
    .word 0x000
    .word 0x000


    ;; Predefined seeds   
SEEDS:
    .word seed0
    .word seed1
    .word seed2
    .word seed3

mask0:
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF

mask1:
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0x1FF
	.word 0x1FF
	.word 0x1FF

mask2:
	.word 0x7FF
	.word 0x7FF
	.word 0x7FF
	.word 0x7FF
	.word 0x7FF
	.word 0x7FF
	.word 0x7FF
	.word 0x7FF

mask3:
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0x000

mask4:
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0x000


MASKS:
    .word mask0
    .word mask1
    .word mask2
    .word mask3
    .word mask4

; BEGIN:reset_game
reset_game:
	addi sp, sp, -4
	stw ra, 0(sp)
	stw zero, GSA_ID(zero)
	addi t1, zero, 1
	stw t1, CURR_STEP(zero)
	stw zero, SEED(zero)
	addi t0, zero, 4
	ldw t0, font_data(t0)
	stw t0, SEVEN_SEGS+12(zero)
	ldw t0, font_data(zero)
	stw t0, SEVEN_SEGS+8(zero)	
	stw t0, SEVEN_SEGS+4(zero)
	stw t0, SEVEN_SEGS+0(zero)
	stw zero, CURR_STATE(zero)
	stw zero, GSA_ID(zero)
	stw zero, PAUSE(zero)
	stw t1, SPEED(zero)
	;set seed 0
	ldw a0, seed0(zero)
	add a1, zero, zero
	stw zero, GSA1(zero)
	call set_gsa
	ldw a0, seed0+4(zero)
	addi a1, zero, 1
	stw zero, GSA1+4(zero)
	call set_gsa
	ldw a0, seed0+8(zero)
	addi a1, zero, 2
	stw zero, GSA1+8(zero)
	call set_gsa
	ldw a0, seed0+12(zero)
	addi a1, zero, 3
	stw zero, GSA1+12(zero)
	call set_gsa
	ldw a0, seed0+16(zero)
	addi a1, zero, 4
	stw zero, GSA1+16(zero)
	call set_gsa
	ldw a0, seed0+20(zero)
	addi a1, zero, 5
	stw zero, GSA1+20(zero)
	call set_gsa
	ldw a0, seed0+24(zero)
	addi a1, zero, 6
	stw zero, GSA1+24(zero)
	call set_gsa
	ldw a0, seed0+28(zero)
	addi a1, zero, 7
	stw zero, GSA1+28(zero)
	call set_gsa
	; --
	call mask
	call draw_gsa
	ldw ra, 0(sp)
	addi sp, sp, 4
	ret
; END:reset_game

; BEGIN:clear_leds
clear_leds:
	add t0, zero, zero
	stw t0, LEDS(zero)
	stw t0, LEDS+4(zero)
	stw t0, LEDS+8(zero)
	ret
; END:clear_leds

; BEGIN:decrement_step
decrement_step:
	ldw t5, PAUSE(zero)
	ldw t1, CURR_STATE(zero)
	addi t2, zero, RUN 
	ldw t3, CURR_STEP(zero)
	beq t5, zero, 24
	bne t2, t1, 20 ; not equal to run
	bne t3, zero, 8 ; not equal 0, not done
	addi v0, zero, 1
	ret
	addi t3, t3, -1
	stw t3, CURR_STEP(zero)
	andi t0, t3, 0xF
	slli t0, t0, 2
	ldw t0, font_data(t0)
	stw t0, SEVEN_SEGS+12(zero)
	srli t3, t3, 4
	andi t0, t3, 0xF
	slli t0, t0, 2
	ldw t0, font_data(t0)
	stw t0, SEVEN_SEGS+8(zero)
	srli t3, t3, 4
	andi t0, t3, 0xF
	slli t0, t0, 2
	ldw t0, font_data(t0)
	stw t0, SEVEN_SEGS+4(zero)
	srli t3, t3, 4
	andi t0, t3, 0xF
	slli t0, t0, 2
	ldw t0, font_data(t0)
	stw t0, SEVEN_SEGS+0(zero)
	add v0, zero, zero 
	ret
	
; END:decrement_step

; BEGIN:find_neighbours
find_neighbours:
	addi sp, sp, -4
	stw ra, 0(sp)
	addi s0, zero, 0x7;for mod 8
	addi s1, zero, 0xC; 12
	add s6, zero, a0; stock in s6 x coord
	add s7, zero, a1; stock in s7 y coord 
	add s2, zero, zero ; counter for how many neighbour cell
	add s3, zero, zero ; x2
	add s4, zero, zero ;y2
	add a0, zero, s7
	;get x,y current state and store in v1
	call get_gsa
	add v1, zero, v0
	srl v1, v1, s6
	andi v1, v1, 1
	; get neighbours	
	addi s3, s6, 1 ;x+
	blt s3, s1, 4
	sub s3, s3, s1
	addi s4, s7, 1
	and s4, s4, s0
	call is_neighbour
	add s2, s2, v0
	addi s3, s6, 1 ; x+
	blt s3, s1, 4
	sub s3, s3, s1
	add s4, s7, zero
	and s4, s4, s0
	call is_neighbour
	add s2, s2, v0
	addi s3, s6, 1 ;x+
	blt s3, s1, 4
	sub s3, s3, s1
	addi s4, s7, -1
	and s4, s4, s0
	call is_neighbour
	add s2, s2, v0
; --
	add s3, s6, zero
	addi s4, s7, 1
	and s4, s4, s0
	call is_neighbour
	add s2, s2, v0
	addi s3, s6, -1 ; x-
	andi s3, s3, 0xF
	blt s3, s1, 4
	addi s3, s3, -4
	addi s4, s7, -1
	and s4, s4, s0
	call is_neighbour
	add s2, s2, v0
	addi s3, s6, -1 ; x-
	andi s3, s3, 0xF
	blt s3, s1, 4
	addi s3, s3, -4
	add s4, s7, zero
	and s4, s4, s0
	call is_neighbour
	add s2, s2, v0
	add s3, s6, zero
	addi s4, s7, -1
	and s4, s4, s0
	call is_neighbour
	add s2, s2, v0
	addi s3, s6, -1 ; x-
	andi s3, s3, 0xF
	blt s3, s1, 4
	addi s3, s3, -4
	addi s4, s7, 1
	and s4, s4, s0
	call is_neighbour
	add s2, s2, v0
	add v0, zero, s2
	ldw ra, 0(sp)
	addi sp, sp, 4
	ret
; END:find_neighbours

; BEGIN:update_gsa
update_gsa: ;TODO If Pause do not change anything
	addi sp, sp, -4 
	stw ra, 0(sp)
	ldw t7, PAUSE(zero)
	beq t7, zero, 132
	addi t6, zero, 0x8 ; y counter
	loop_y2:
		addi t6, t6, -1
		add t4, zero, zero
		addi t7, zero, 0xC
		loop_x2:
			addi t7, t7, -1
			slli t4, t4, 1
			add a0, zero, t7
			add a1, zero, t6
			addi sp, sp, -12
			stw t6 , 8(sp)
			stw t7, 4(sp)
			stw t4, 0(sp)
			call find_neighbours
			add a0, zero, v0
			add a1, zero, v1
			call cell_fate
			ldw t4, 0(sp)
			ldw t7, 4(sp)
			ldw t6, 8(sp)
			addi sp, sp, 12
			andi v0, v0, 1
			or t4, t4, v0
			bne t7, zero, loop_x2
		ldw t0, GSA_ID(zero)
		slli t7, t6, 0x2
		beq t0, zero, 4
		stw t4, GSA0(t7);
		bne t0, zero, 4
		stw t4, GSA1(t7)
		bne t6, zero, loop_y2
	ldw t0, GSA_ID(zero)
	xori t0, t0, 1
	stw t0, GSA_ID(zero)
	ldw ra, 0(sp)
	addi sp, sp, 4
	ret
; END:update_gsa

; BEGIN:mask
mask: ; TODO: HAS NOT BEEN TESTED
	addi sp, sp, -4
	stw ra, 0(sp)
	ldw t1, SEED(zero)
	; mask0
	add t4, zero, zero
	bne t1, t4, fmask1
	fmask0:
		addi a0, zero, 0
		call get_gsa
		ldw t3, mask0(zero)
		addi a1, zero, 0
		and a0, v0, t3
		call set_gsa ; 0
		addi a0, zero, 1
		call get_gsa
		ldw t3, mask0+4(zero)
		addi a1, zero, 1
		and a0, v0, t3
		call set_gsa ;1
		addi a0, zero, 2
		call get_gsa
		ldw t3, mask0+8(zero)
		addi a1, zero, 2
		and a0, v0, t3
		call set_gsa ;2
		addi a0, zero, 3
		call get_gsa
		ldw t3, mask0+12(zero)
		addi a1, zero, 3
		and a0, v0, t3
		call set_gsa ;3 
		addi a0, zero, 4
		call get_gsa
		ldw t3, mask0+16(zero)
		addi a1, zero, 4
		and a0, v0, t3
		call set_gsa ;4
		addi a0, zero, 5
		call get_gsa
		ldw t3, mask0+20(zero)
		addi a1, zero, 5
		and a0, v0, t3
		call set_gsa ;5
		addi a0, zero, 6
		call get_gsa
		ldw t3, mask0+24(zero)
		addi a1, zero, 6
		and a0, v0, t3
		call set_gsa ;6
		addi a0, zero, 7
		call get_gsa
		ldw t3, mask0+28(zero)
		addi a1, zero, 7
		and a0, v0, t3
		call set_gsa ;7
	fmask1:
		addi t4, t4, 1
		bne t1, t4, fmask2
		addi a0, zero, 0
		call get_gsa
		ldw t3, mask1(zero)
		addi a1, zero, 0
		and a0, v0, t3
		call set_gsa ;0
		addi a0, zero, 1
		call get_gsa
		ldw t3, mask1+4(zero)
		addi a1, zero, 1
		and a0, v0, t3
		call set_gsa ;1
		addi a0, zero, 2
		call get_gsa
		ldw t3, mask1+8(zero)
		addi a1, zero, 2
		and a0, v0, t3
		call set_gsa ;2
		addi a0, zero, 3
		call get_gsa
		ldw t3, mask1+12(zero)
		addi a1, zero, 3
		and a0, v0, t3
		call set_gsa ;3
		addi a0, zero, 4
		call get_gsa
		ldw t3, mask1+16(zero)
		addi a1, zero, 4
		and a0, v0, t3
		call set_gsa ;4
		addi a0, zero, 5
		call get_gsa
		ldw t3, mask1+20(zero)
		addi a1, zero, 5
		and a0, v0, t3
		call set_gsa ;5
		addi a0, zero, 6
		call get_gsa
		ldw t3, mask1+24(zero)
		addi a1, zero, 6
		and a0, v0, t3
		call set_gsa ;6
		addi a0, zero, 7
		call get_gsa
		ldw t3, mask1+28(zero)
		addi a1, zero, 7
		and a0, v0, t3
		call set_gsa ;7
	fmask2:
		addi t4, t4, 1
		bne t1, t4, fmask3
		addi a0, zero, 0
		call get_gsa
		ldw t3, mask2(zero)
		addi a1, zero, 0
		and a0, v0, t3
		call set_gsa ;0
		addi a0, zero, 1
		call get_gsa
		ldw t3, mask2+4(zero)
		addi a1, zero, 1
		and a0, v0, t3
		call set_gsa ;1
		addi a0, zero, 2
		call get_gsa
		ldw t3, mask2+8(zero)
		addi a1, zero, 2
		and a0, v0, t3
		call set_gsa ;2
		addi a0, zero, 3
		call get_gsa
		ldw t3, mask2+12(zero)
		addi a1, zero, 3
		and a0, v0, t3
		call set_gsa ;3
		addi a0, zero, 4
		call get_gsa
		ldw t3, mask2+16(zero)
		addi a1, zero, 4
		and a0, v0, t3
		call set_gsa ;4
		addi a0, zero, 5
		call get_gsa
		ldw t3, mask2+20(zero)
		addi a1, zero, 5
		and a0, v0, t3
		call set_gsa ;5
		addi a0, zero, 6
		call get_gsa
		ldw t3, mask2+24(zero)
		addi a1, zero, 6
		and a0, v0, t3
		call set_gsa ;6
		addi a0, zero, 7
		call get_gsa
		ldw t3, mask2+28(zero)
		addi a1, zero, 7
		and a0, v0, t3
		call set_gsa ;7
	fmask3:
		addi t4, t4, 1
		bne t1, t4, fmask4
		addi a0, zero, 0
		call get_gsa
		ldw t3, mask3(zero)
		addi a1, zero, 0
		and a0, v0, t3
		call set_gsa ;0
		addi a0, zero, 1
		call get_gsa
		ldw t3, mask3+4(zero)
		addi a1, zero, 1
		and a0, v0, t3
		call set_gsa ;1
		addi a0, zero, 2
		call get_gsa
		ldw t3, mask3+8(zero)
		addi a1, zero, 2
		and a0, v0, t3
		call set_gsa ;2
		addi a0, zero, 3
		call get_gsa
		ldw t3, mask3+12(zero)
		addi a1, zero, 3
		and a0, v0, t3
		call set_gsa ;3
		addi a0, zero, 4
		call get_gsa
		ldw t3, mask3+16(zero)
		addi a1, zero, 4
		and a0, v0, t3
		call set_gsa ;4
		addi a0, zero, 5
		call get_gsa
		ldw t3, mask3+20(zero)
		addi a1, zero, 5
		and a0, v0, t3
		call set_gsa ;5
		addi a0, zero, 6
		call get_gsa
		ldw t3, mask3+24(zero)
		addi a1, zero, 6
		and a0, v0, t3
		call set_gsa ;6
		addi a0, zero, 7
		call get_gsa
		ldw t3, mask3+28(zero)
		addi a1, zero, 7
		and a0, v0, t3
		call set_gsa ;7
	fmask4:
		addi t4, t4, 1
		bne t1, t4, endmask
		addi a0, zero, 0
		call get_gsa
		ldw t3, mask4(zero)
		addi a1, zero, 0
		and a0, v0, t3
		call set_gsa ;0
		addi a0, zero, 1
		call get_gsa
		ldw t3, mask4+4(zero)
		addi a1, zero, 1
		and a0, v0, t3
		call set_gsa ;1
		addi a0, zero, 2
		call get_gsa
		ldw t3, mask4+8(zero)
		addi a1, zero, 2
		and a0, v0, t3
		call set_gsa ;2
		addi a0, zero, 3
		call get_gsa
		ldw t3, mask4+12(zero)
		addi a1, zero, 3
		and a0, v0, t3
		call set_gsa ;3
		addi a0, zero, 4
		call get_gsa
		ldw t3, mask4+16(zero)
		addi a1, zero, 4
		and a0, v0, t3
		call set_gsa ;4
		addi a0, zero, 5
		call get_gsa
		ldw t3, mask4+20(zero)
		addi a1, zero, 5
		and a0, v0, t3
		call set_gsa ;5
		addi a0, zero, 6
		call get_gsa
		ldw t3, mask4+24(zero)
		addi a1, zero, 6
		and a0, v0, t3
		call set_gsa ;6
		addi a0, zero, 7
		call get_gsa
		ldw t3, mask4+28(zero)
		addi a1, zero, 7
		and a0, v0, t3
		call set_gsa ;7
	endmask:
		ldw ra, 0(sp)
		addi sp, sp, 4
		ret
	
; END:mask

; BEGIN:set_pixel
set_pixel:
	slli t0, a0, 3
	andi t0, t0, 0x0000001F
	add t0, t0, a1
	addi t1, zero, 0x00000001
	sll t1, t1, t0
	ldw t2, LEDS(a0)
	or t1, t1, t2
	stw t1, LEDS(a0)
	ret
; END:set_pixel

; BEGIN:wait
wait:
	addi sp, sp, -4
	stw ra, 0(sp)
	addi t2, zero, 0
	addi t0, zero, 1
	slli t7, t0, 0x17
	ldw t0, SPEED(zero)
	jmpi looptimer
	ldw ra, 0(sp)
	addi sp, sp, 4
	ret
; END:wait

; BEGIN:draw_gsa
draw_gsa:
	addi sp, sp, -4
	stw ra, 0(sp)
	add t7, zero, zero ; loop on line
	addi s0, zero, 0xC; 12
	addi s1, zero, 0x8 ; 8
	addi s2, zero, 0x4 ;4
	addi s3, zero, 0x8; 8
	call clear_leds
	loop_y:
		add t6, zero, zero ; loop on column
		add a0, zero, t7 ; load line t6 
		call get_gsa
		add t3, zero, v0
		; get return value in v0
		loop_x:
			andi t4, t3, 1

			set_pixel_v2:
				slli t0, t6, 3 ;x : t0 = x*8
				andi t0, t0, 0x0000001F
				add t0, t0, t7 ;y: :t0 = x*8+y
				add t1, zero, t4
				sll t1, t1, t0
				ldw t2, LEDS(t6)
				or t1, t1, t2
				stw t1, LEDS(t6)

			srli t3, t3, 1 
			addi t6, t6, 1
			bne t6, s0, loop_x
		addi t7, t7, 1
		bne t7, s1, loop_y
	ldw ra, 0(sp)
	addi sp, sp, 4
	ret
; END:draw_gsa

; BEGIN:update_state
update_state:
	addi sp, sp, -4
	stw ra, 0(sp)
	andi t7, a0, 0x1  ; b0 is pressed
	beq t7, zero, 44
	ldw t7, CURR_STATE(zero)
	addi t7, t7, -2
	beq t7, zero, 20
	ldw t7, SEED(zero)
	addi t7, t7, -4
	bne t7, zero, 20
	addi t1, zero, RAND
	stw t1, CURR_STATE(zero)
	ldw ra, 0(sp)
	addi sp, sp, 4
	ret
	srli a0, a0, 1
	andi t7, a0, 0x1
	beq t7, zero, 40;BUTTON Is 1
	ldw t1, CURR_STATE(zero)
	addi t1, t1, -2
	beq t1, zero, 20 ; no in rand or init
	addi t1, zero, RUN
	stw t1, CURR_STATE(zero)
	addi t1, zero, 1
	stw t1, PAUSE(zero)
	ldw ra, 0(sp)
	addi sp, sp, 4
	ret
	;BUTTON 3 state is run
	srli a0, a0, 2
	andi t7, a0, 0x1
	beq t7, zero, 16 ; is button 3 
	ldw t1, CURR_STATE(zero)
	addi t1, t1, -2
	bne t1, zero, 4 ; is in run ?
	call reset_game
	ldw ra, 0(sp)
	addi sp, sp, 4
	ret
; END:update_state


; BEGIN:change_speed
change_speed:
	ldw t0, SPEED(zero)
	addi t1, zero, MIN_SPEED
	addi t2, zero, MAX_SPEED
	beq a0, zero, 8 ;a0 == 1 decrement
	beq t0, t1, 4
	addi t0, t0, -1
	bne a0, zero, 8 ;a0 == 0 increment
	beq t0, t2, 4
	addi t0, t0, 1
	stw t0, SPEED(zero)
	ret
; END:change_speed

; BEGIN:pause_game
pause_game:
	ldw t0, PAUSE(zero)
	xori t0, t0, 1
	stw t0, PAUSE(zero)
	ret
; END:pause_game

; BEGIN:change_steps
change_steps: 
	ldw t0, CURR_STEP(zero); see doc p. 10
	beq a0, zero, 4
	addi t0, t0, 1
	beq a1, zero, 4
	addi t0, t0, 0x10
	beq a2, zero, 4
	addi t0, t0, 0x100
	stw t0, CURR_STEP(zero)
	ret
; END:change_steps


; BEGIN:select_action
select_action:
	addi sp, sp, -4
	stw ra, 0(sp)
	; BUTTON 0
	andi t7, a0, 0x1
	beq t7, zero, 44 ;if 0 is pushed
	ldw t7, CURR_STATE(zero)
	addi t7, t7, -2
	beq t7, zero, 16 
	call increment_seed
	ldw ra, 0(sp)
	addi sp, sp, 4
	ret
	call pause_game
	ldw ra, 0(sp)
	addi sp, sp, 4
	ret
	; BUTTON 1
	srli a0, a0, 1
	andi t7, a0, 0x1
	beq t7, zero, 32 ;if 1 is pushed
	ldw t7, CURR_STATE(zero)
	addi t7, t7, -2
	bne t7, zero, 8 ; if not in run
	addi a0, zero, 0; increase speed
	call change_speed
	ldw ra, 0(sp)
	addi sp, sp, 4
	ret
	; BUTTON 2
	srli a0, a0, 1
	andi t7, a0, 0x1
	beq t7, zero, 60 ;if 2 is pushed
	ldw t7, CURR_STATE(zero)
	addi t7, t7, -2
	bne t7, zero, 20; if run do not branch
	addi a0, zero, 1
	call change_speed
	ldw ra, 0(sp)
	addi sp, sp, 4
	ret
	addi a2, zero, 1
	add a1, zero, zero
	add a0, zero, zero
	call change_steps 
	ldw ra, 0(sp)
	addi sp, sp, 4
	ret
	; BUTTON 3
	srli a0, a0, 1
	andi t7, a0, 0x1
	beq t7, zero, 52 ;if 3 is pushed
	ldw t7, CURR_STATE(zero)
	addi t7, t7, -2
	bne t7, zero, 12; if run do not branch
	ldw ra, 0(sp)
	addi sp, sp, 4
	ret
	add a0, zero, zero
	addi a1, zero, 1
	add a2, zero, zero
	call change_steps 
	ldw ra, 0(sp)
	addi sp, sp, 4
	ret
	; BUTTON 4
	srli a0, a0, 1
	andi t7, a0, 0x1
	beq t7, zero, 44 ;if 3 is pushed
	ldw t7, CURR_STATE(zero)
	addi t7, t7, -2
	bne t7, zero, 16; if run do not branch
	call random_gsa
	ldw ra, 0(sp)
	addi sp, sp, 4
	ret
	add a2, zero, zero
	add a1, zero, zero
	addi a0, zero, 1
	call change_steps 
	ldw ra, 0(sp)
	addi sp, sp, 4
	ret
; END:select_action

; BEGIN:cell_fate
cell_fate:
	addi s3, zero, 3 
	addi s2, zero, 2
	add v0, zero, a1
	blt a0, s3, 4 ;if bigger than 3
	add v0, zero, zero
	bge a0, s2, 4 ; if smaller than 2
	add v0, zero, zero
	bne a0, s3, 4 ; if eq 3
	addi v0, zero, 1
	ret
; END:cell_fate

; BEGIN:random_gsa
random_gsa:
	addi sp, sp, -4
	stw ra, 0(sp)
	addi s1, zero, 0x8 ; 8 -y
	loop_y_rgsa:
		addi s1, s1, -1
		add t2, zero, zero
		addi s0, zero, 0xC;
		loop_x_rgsa:
			addi s0, s0, -1
			ldw t1, RANDOM_NUM(zero) 
			andi t1, t1, 1 ; modulo 2
			or t2, t2, t1
			slli t2, t2, 1
			bne s0, zero, loop_x_rgsa
		add a0, zero, t2 ; data set
		add a1, zero, s1; y set
		call set_gsa;
		bne s1, zero, loop_y_rgsa
	ldw ra, 0(sp)
	addi sp, sp, 4
	ret
; END:random_gsa

; BEGIN:increment_seed
increment_seed:
	addi sp, sp, -4
	stw ra, 0(sp)
	ldw t0, CURR_STATE(zero)
	addi t7, zero, INIT
	addi t6, zero, 4
	bne t0, t7, 16 ; state == init
	ldw t1, SEED(zero)
	beq t1, t6, 8
	addi t1, t1, 1
	stw t1, SEED(zero)
	addi t7, zero, RAND
	bne t0, t7, fseed1 ;state == RAND
	call random_gsa
	ldw ra, 0(sp)
	addi sp, sp, 4
	ret 
	;SEEDS(10*4)
	;seed1 ---------------
	fseed1:
		addi t7, zero, 1
		bne t1, t7, fseed2
		ldw a0, seed1(zero)
		add a1, zero, zero
		call set_gsa
		addi t2, t2, 4
		ldw a0, seed1+4(zero)
		addi a1, zero, 1
		call set_gsa
		ldw a0, seed1+8(zero)
		addi a1, zero, 2
		call set_gsa
		ldw a0, seed1+12(zero)
		addi a1, zero, 3
		call set_gsa
		ldw a0, seed1+16(zero)
		addi a1, zero, 4
		call set_gsa
		ldw a0, seed1+20(zero)
		addi a1, zero, 5
		call set_gsa
		ldw a0, seed1+24(zero)
		addi a1, zero, 6
		call set_gsa
		ldw a0, seed1+28(zero)
		addi a1, zero, 7
		call set_gsa
	;seed2 -------------
	fseed2:
		addi t7, zero, 2
		bne t1, t7, fseed3
		ldw a0, seed2(zero)
		add a1, zero, zero
		call set_gsa
		ldw a0, seed2+4(zero)
		addi a1, zero, 1
		call set_gsa
		ldw a0, seed2+8(zero)
		addi a1, zero, 2
		call set_gsa
		ldw a0, seed2+12(zero)
		addi a1, zero, 3
		call set_gsa
		ldw a0, seed2+16(zero)
		addi a1, zero, 4
		call set_gsa
		ldw a0, seed2+20(zero)
		addi a1, zero, 5
		call set_gsa
		ldw a0, seed2+24(zero)
		addi a1, zero, 6
		call set_gsa
		ldw a0, seed2+28(zero)
		addi a1, zero, 7
		call set_gsa
	;seed3-------------
	fseed3:
		addi t7, zero, 3
		bne t1, t7, endseed
		ldw a0, seed3(zero)
		add a1, zero, zero
		call set_gsa
		ldw a0, seed3+4(zero)
		addi a1, zero, 1
		call set_gsa
		ldw a0, seed3+8(zero)
		addi a1, zero, 2
		call set_gsa
		ldw a0, seed3+12(zero)
		addi a1, zero, 3
		call set_gsa
		ldw a0, seed3+16(zero)
		addi a1, zero, 4
		call set_gsa
		ldw a0, seed3+20(zero)
		addi a1, zero, 5
		call set_gsa
		ldw a0, seed3+24(zero)
		addi a1, zero, 6
		call set_gsa
		ldw a0, seed3+28(zero)
		addi a1, zero, 7
		call set_gsa
	endseed:
		addi t7, zero, 4
		bne t1, t7, 4
		call random_gsa
		;end of seed
		ldw ra, 0(sp)
		addi sp, sp, 4	
		ret
; END:increment_seed


; BEGIN:get_input
get_input:
	ldw v0, BUTTONS+4(zero)
	stw zero, BUTTONS+4(zero)
	ret
; END:get_input

; BEGIN:set_gsa
set_gsa:
	ldw t0, GSA_ID(zero)
	slli t7, a1, 0x2
	beq t0, zero, 4
	stw a0, GSA1(t7)
	bne t0, zero, 4
	stw a0, GSA0(t7)
	ret
; END:set_gsa

; BEGIN:get_gsa
get_gsa:
	ldw t0, GSA_ID(zero)
	slli a0, a0, 0x2
	ldw v0, GSA0(a0)
	beq t0, zero, 4
	ldw v0, GSA1(a0)
	srli a0, a0, 0x2
	ret
; END:get_gsa

; BEGIN:helper
looptimer:
	add t2, t2, t0
	bltu t2, t7, looptimer
	ret

is_neighbour:
	addi sp, sp, -4
	stw ra, 0(sp)
	add a0, zero, s4
	call get_gsa
	srl v0, v0, s3
	andi v0, v0, 1
	ldw ra, 0(sp)
	addi sp, sp, 4
	ret

; END:helper






