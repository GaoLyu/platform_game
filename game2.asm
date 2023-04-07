.eqv 	base_address	0x10008000
#hamster color
.eqv 	black		0x00000000
.eqv	gold		0xffffd700
.eqv	oldlace		0xfffdf5e6
.eqv	moccasin	0xffffe4b5
.eqv 	tan		0xffd2b48c
#background color
.eqv	skyblue		0xffe0ffff
#platform color
.eqv	green		0xff00ff00
#jet plane color
.eqv	darkgreen	0xff006400
.eqv 	seagreen 	0xff2e8b57
.eqv 	red		0xffff0000
.eqv 	firered		0xffb22222
#enemy color:
.eqv 	yellow		0xffffff00 #hat
.eqv 	orange		0xffffa500 #hat
.eqv 	orangered	0xff800000 #eye
.eqv	sienna		0xffffe4e1 #eyebrow
.eqv	maroon		0xffffb6c1 #face



.eqv 	obstacleNum	4
.eqv	platNum		4
.eqv    bulletNum	4



.data
platLen:	.word	15,  20,  23 , 24
platX:		.word	50, 25, 40, 29
platYhead:	.word	20,  40, 0, 60	
platYtail:	.word 	34,  59, 22, 83
bulletX:	.word	64, 64, 64, 64
bulletY:	.space	16
bulletSpeed:	.space	16
enemy:		.word   1, 1  	# first one represent y coordinate (1-59 inclusive), second one is 1 if moving right, 0 if moving left


smashed:		.asciiz "you are smashed\n"
shoot:		.asciiz "you are shoot\n"
.text
# $t8=top right row of the hamster
# $t9=top right column of the hamster
# $s0=sleep time
# $s1=number of jump happened
# $s2=check if is successful jump, 1 if successful
setup:
	#draw background
	li $s0, 100
	li $s1, 0
	li $s2, 0			# $s0=1000=initial sleep time
	li 	$t0, base_address	# $t0=the base address for display
	li 	$t1, 4096		# $t1=64*64=4096 units
	li 	$t2, skyblue		# $t2=skyblue color
bg:	sw   	$t2, 0($t0)		# paint the whole screen to skyblue
	addi 	$t0, $t0, 4 		# advance to next unit position in display
	addi 	$t1, $t1, -1		# decrement number of units
	bnez 	$t1, bg			# repeat while number of units is not zero
	# have painted the whole screen to skyblue
	# draw jet plane
	# pass the middle of the plane to function draw_jetplane
	li $a0, 15
	jal draw_jetplane
	li $a0, 45
	jal draw_jetplane
	
	li $a0, green
	jal draw_platform
	
	#draw hamster
	li $t8,27
	li $t9,2
	jal draw_hamster
	
	jal draw_enemy
	# finished initializing, start game loop
gameloop:
	jal move_enemy
	jal bullet
	jal check_collision
	jal move_platform	# move platform
	# if jumped half times, then need to continue jumping no matter what user input
	andi $t0, $s1, 1
	beq $t0, 1, w_2
	# get input from user
	# check if user has input something
	li $t0, 0xffff0000 	# $t0=address of 0xffff0000 
	lw $t1, 0($t0)		# $t1=whether user has input something
	
	beq $t1, 1, keypress_happened # if user input something, branch to keypress_happened and respond accordingly
	li $s2, 0 		# if user do not input something, make jump to be unsuccessful
	# we are here, now need to check collision and add gravity
sleep:	#jal check_collision
	jal gravity_hamster
	
	addi $v0, $zero, 32		# syscall sleep
	add $a0, $zero, $s0
	syscall
	
			# decrement sleepTime	
	j gameloop
		
	
keypress_happened:
	lw $t2, 4($t0)		# $t2=user input
	beq $t2, 97, a_2		# if input='a', branch to a
	beq $t2, 100, d_2		# if input='d', branch to d
	beq $t2, 119, w_2	# if input='w', branch to w_2
	beq $t2, 112, setup	# if input='p', branch to set_up
	beq $t2, 113, END_PROGRAM
	j sleep
	
a_2:
	li $s2, 0	# let $s2 to be not successful
	# if $t9<3, can not move left twice, branch to a_1
	ble $t9, 3, w_1
	# if there are green platforms 2 unit on the left, cannot move 2 unit left, branch to a_1
	# by checking the color of tail of platform+4
	# $t0=iteration
	# $t1=address of platX
	# $t2=address of platYtail
	# $t3=platX[$t2]
	# $t4=platYtail[$t2]
	# $t5=address of tail in frame
	# $t6=color of address of tail in frame+4
	li $t0, 0
	la $t1, platX
	la $t2, platYtail
a_2_check:lw $t3, 0($t1)
	lw $t4, 0($t2)
	sll $t5, $t3, 8
	add $t5, $t4, $t5
	add $t5, $t4, $t5
	add $t5, $t4, $t5
	add $t5, $t4, $t5
	addi $t5, $t5, base_address
	lw $t6, 8($t5)
	beq $t6, black, w_1
	# check the next platform tail
	addi $t0, $t0, 1
	addi $t1, $t1, 4
	addi $t2, $t2, 4
	bne $t0, platNum, a_2_check
	# we are here, so can move left
	# erase the current hamster
	# update $t9=$t9-1 and draw the new hamster
	jal erase_hamster
	addi $t9, $t9, -2
	jal draw_hamster
	j sleep
	
			
a_1:	li $s2, 0	# let $s2 to be not successful
	# if $t9<2 can not move left
	ble $t9, 2, sleep
	# if there are green platforms on the left, cannot move left
	# by checking the color of tail of platform+4
	# $t0=iteration
	# $t1=address of platX
	# $t2=address of platYtail
	# $t3=platX[$t2]
	# $t4=platYtail[$t2]
	# $t5=address of tail in frame
	# $t6=color of address of tail in frame+4
	li $t0, 0
	la $t1, platX
	la $t2, platYtail
a_1_check:lw $t3, 0($t1)
	lw $t4, 0($t2)
	sll $t5, $t3, 8
	add $t5, $t4, $t5
	add $t5, $t4, $t5
	add $t5, $t4, $t5
	add $t5, $t4, $t5
	addi $t5, $t5, base_address
	lw $t6, 4($t5)
	beq $t6, black, sleep
	beq $t6, gold, sleep
	beq $t6, oldlace, sleep
	beq $t6, moccasin, sleep
	beq $t6, tan, sleep
	# check the next platform tail
	addi $t0, $t0, 1
	addi $t1, $t1, 4
	addi $t2, $t2, 4
	bne $t0, platNum, a_1_check
	# we are here, so can move left
	# erase the current hamster
	# update $t9=$t9-1 and draw the new hamster
	jal erase_hamster
	addi $t9, $t9, -1
	jal draw_hamster
	j sleep

d_2:	li $s2, 0	# let $s2 to be not successful
	# if $t9>54 can not move right twice
	bgt $t9, 54, d_1
	# if there are green platforms 2 units on the right, cannot move right 2 unit
	# by checking the color of head of platform+4
	# $t0=iteration
	# $t1=address of platX
	# $t2=address of platYhead
	# $t3=platX[$t2]
	# $t4=platYhead[$t2]
	# $t5=address of head in frame
	# $t6=color of address of head in frame-8
	li $t0, 0
	la $t1, platX
	la $t2, platYhead
d_2_check:lw $t3, 0($t1)
	lw $t4, 0($t2)
	sll $t5, $t3, 8
	add $t5, $t4, $t5
	add $t5, $t4, $t5
	add $t5, $t4, $t5
	add $t5, $t4, $t5
	addi $t5, $t5, base_address
	addi $t5, $t5, -8
	lw $t6, 0($t5)
	beq $t6, black, d_1
	
	# check the next platform tail
	addi $t0, $t0, 1
	addi $t1, $t1, 4
	addi $t2, $t2, 4
	bne $t0, platNum, d_2_check
	# we are here, so can move right
	# erase the current hamster
	# update $t9=$t9+1 and draw the new hamster
	jal erase_hamster
	addi $t9, $t9, 2
	jal draw_hamster
	j sleep

d_1:	li $s2, 0	# let $s2 to be not successful
	# if $t9>54 can not move right twice
	bgt $t9, 54, sleep
	# if there are green platforms 1 unit on the right, cannot move right
	# by checking the color of head of platform+4
	# $t0=iteration
	# $t1=address of platX
	# $t2=address of platYhead
	# $t3=platX[$t2]
	# $t4=platYhead[$t2]
	# $t5=address of head in frame
	# $t6=color of address of head in frame-8
	li $t0, 0
	la $t1, platX
	la $t2, platYhead
d_1_check:lw $t3, 0($t1)
	lw $t4, 0($t2)
	sll $t5, $t3, 8
	add $t5, $t4, $t5
	add $t5, $t4, $t5
	add $t5, $t4, $t5
	add $t5, $t4, $t5
	addi $t5, $t5, base_address
	addi $t5, $t5, -4
	lw $t6, 0($t5)
	beq $t6, black, sleep
	
	# check the next platform tail
	addi $t0, $t0, 1
	addi $t1, $t1, 4
	addi $t2, $t2, 4
	bne $t0, platNum, d_1_check
	# we are here, so can move right
	# erase the current hamster
	# update $t9=$t9+1 and draw the new hamster
	jal erase_hamster
	addi $t9, $t9, 1
	jal draw_hamster
	j sleep
	
	
w_2:	# check if can jump
	bge $s1, 4, sleep
	# check if can move up 2 unit
	blt $t8, 12, w_1		# if $t8<12, cannot move up 2 units, branch to w_1 to see if can move up 1 unit
	blt $t8, 11, no_jump		# if $t8<11, cannot move up, branch to no_jump
	# we are here, so may jump 2 units, still need to check if there are platforms above
	# by checking the color below every platform pixel
	# for each platform
	# for each pixel in this platform
	# if color 2 units below is hamster color, branch to w_1
	# if color 1 unit below is hamster color, branch to no jump
	
	# $t0=outerloop iteration
	# $t1=innerloop iteration
	# $t2=address of platLen
	# $t3=address of platX
	# $t4=address of platYhead
	# $t5=platLen[$t0]
	# $t6=platX[$t0]
	# $t7=platYhead[$t0]
	# $s3=address of pixel below the platformhead and $t1*4 to the right
	# $s4=color of pixel below platform
	li $t0, 0
	la $t2, platLen
	la $t3, platX
	la $t4, platYhead
outer_loop_w2:	
	lw $t5, 0($t2)
	lw $t6, 0($t3)
	lw $t7, 0($t4)
	li $t1, 0
	sll $s3, $t6, 8
	add $s3, $t7, $s3
	add $s3, $t7, $s3
	add $s3, $t7, $s3
	add $s3, $t7, $s3
	addi $s3, $s3, base_address
	addi $s3, $s3, 512
inner_loop_w2:	
	lw $s4, 0($s3)
	# if 2 units below is hamster color, branch to w_1
	beq $s4, black, w_1
	beq $s4, gold, w_1
	beq $s4, oldlace, w_1
	beq $s4, moccasin, w_1
	beq $s4, tan, w_1
	
	# else, increment $t1 and do inner loop
	addi $t1, $t1, 1
	addi $s3, $s3, 4
	bne $t1, $t5, inner_loop_w2 
	# we are here, so finished this platform, check the next one
	# increment $t0 and do outer loop
	addi $t0, $t0, 1
	addi $t2, $t2, 4
	addi $t3, $t3, 4
	addi $t4, $t4, 4
	bne $t0, platNum, outer_loop_w2 
	# we are here, so can move 2 units up
	# erase hamster, update $t8, draw, update $s1, $s2
	jal erase_hamster
	addi $t8, $t8, -2
	jal draw_hamster
	addi $s1, $s1, 1	# increment $s1 number of jumps by 1
	li $s2, 1		# jump is successful, so $s2=1
	
	j sleep
						
w_1:	# check if can move up 1 unit
	blt $t8, 11, no_jump		# if $t8<11, cannot move up, branch to no_jump
	# we are here, so may jump 1 unit, still need to check if there are platforms above
	# by checking the color 1 unit below every platform pixel
	# for each platform
	# for each pixel in this platform
	# if color 1 unit below is hamster color, branch to no jump
	
	# $t0=outerloop iteration
	# $t1=innerloop iteration
	# $t2=address of platLen
	# $t3=address of platX
	# $t4=address of platYhead
	# $t5=platLen[$t0]
	# $t6=platX[$t0]
	# $t7=platYhead[$t0]
	# $s3=address of pixel below the platformhead and $t1*4 to the right
	# $s4=color of pixel below platform
	li $t0, 0
	la $t2, platLen
	la $t3, platX
	la $t4, platYhead
outer_loop_w1:	
	lw $t5, 0($t2)
	lw $t6, 0($t3)
	lw $t7, 0($t4)
	li $t1, 0
	sll $s3, $t6, 8
	add $s3, $t7, $s3
	add $s3, $t7, $s3
	add $s3, $t7, $s3
	add $s3, $t7, $s3
	addi $s3, $s3, base_address
	addi $s3, $s3, 256
inner_loop_w1:	
	lw $s4, 0($s3)
	# if 1 unit below is hamster color, branch to no_jump
	beq $s4, black, no_jump
	beq $s4, gold, no_jump
	beq $s4, oldlace, no_jump
	beq $s4, moccasin, no_jump
	beq $s4, tan, no_jump
	# else, increment $t1 and do inner loop
	addi $t1, $t1, 1
	addi $s3, $s3, 4
	bne $t1, $t5, inner_loop_w1
	# we are here, so finished this platform, check the next one
	# increment $t0 and do outer loop
	addi $t0, $t0, 1
	addi $t2, $t2, 4
	addi $t3, $t3, 4
	addi $t4, $t4, 4
	bne $t0, platNum, outer_loop_w1 
	# we are here, so can move 1 unit up
	# erase hamster, update $t8, draw, update $s1, $s2
	jal erase_hamster
	addi $t8, $t8, -1
	jal draw_hamster
	addi $s1, $s1, 1 	# increment $s1 number of jumps by 1
	li $s2, 1		# jump is successful, so $s2=1
	j sleep
	
no_jump:
	addi $s1, $s1, 1	# increment $s1 number of jumps by 1
	li $s2, 0		# jump is not successful, so $s2=0
	j sleep

gravity_hamster:
	#If hamster is jumping, i.e. 1<=$s1<4, and $s2=1, no gravity for hamster
	blt $s1, 1, do_gravity_hamster
	bge $s1, 4, do_gravity_hamster
	bne $s2, 1, do_gravity_hamster
	jr $ra
	
do_gravity_hamster:	
	# save old registers
	addi $sp, $sp, -40
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $t3, 12($sp)
	sw $t4, 16($sp)
	sw $t5, 20($sp)
	sw $t6, 24($sp)
	sw $t7, 28($sp)
	sw $a0, 32($sp)
	sw $ra, 36($sp)																
	#if hamster is not on platform, move down 1 unit
	#check if the color below the bottom of the hamster is green
	#if yes, then already on the platform, branch to restore_gravity_hamster
	#$t0=address of the top left pixel of hamster
	#$t1=color of the pixel below the bottom of hamster
	beq $t8,51,restore_gravity_hamster_s1
	sll $t0, $t8, 8
	add $t0, $t0, $t9
	add $t0, $t0, $t9
	add $t0, $t0, $t9
	add $t0, $t0, $t9
	addi $t0, $t0, base_address
	lw $t1, 3324($t0)
	beq $t1, green, restore_gravity_hamster_s1
	
	lw $t1, 3328($t0)
	beq $t1, green, restore_gravity_hamster_s1
	lw $t1, 3332($t0)
	beq $t1, green, restore_gravity_hamster_s1
	lw $t1, 3336($t0)
	beq $t1, green, restore_gravity_hamster_s1
	lw $t1, 3340($t0)
	beq $t1, green, restore_gravity_hamster_s1
	lw $t1, 3344($t0)
	beq $t1, green, restore_gravity_hamster_s1
	lw $t1, 3348($t0)
	beq $t1, green, restore_gravity_hamster_s1
	lw $t1, 3352($t0)
	beq $t1, green, restore_gravity_hamster_s1
	lw $t1, 3356($t0)
	beq $t1, green, restore_gravity_hamster_s1
	# we are here, so need to move hamster 1 unit down
	li $s2, 0
	# if is at middle of jump, can still jump
	beq $s1, 0, no_jump_gravity
	j jump_gravity_next
no_jump_gravity:
	li $s1, 4
jump_gravity_next:	
	jal erase_hamster
	addi $t8, $t8, 1
	jal draw_hamster
	# check if now hamster is on platform
	beq $t8,51,restore_gravity_hamster_s1
	sll $t0, $t8, 8
	add $t0, $t0, $t9
	add $t0, $t0, $t9
	add $t0, $t0, $t9
	add $t0, $t0, $t9
	addi $t0, $t0, base_address
	lw $t1, 3324($t0)
	beq $t1, green, restore_gravity_hamster_s1
	lw $t1, 3328($t0)
	beq $t1, green, restore_gravity_hamster_s1
	lw $t1, 3332($t0)
	beq $t1, green, restore_gravity_hamster_s1
	lw $t1, 3336($t0)
	beq $t1, green, restore_gravity_hamster_s1
	lw $t1, 3340($t0)
	beq $t1, green, restore_gravity_hamster_s1
	lw $t1, 3344($t0)
	beq $t1, green, restore_gravity_hamster_s1
	lw $t1, 3348($t0)
	beq $t1, green, restore_gravity_hamster_s1
	lw $t1, 3352($t0)
	beq $t1, green, restore_gravity_hamster_s1
	lw $t1, 3356($t0)
	beq $t1, green, restore_gravity_hamster_s1
	j restore_gravity_hamster
restore_gravity_hamster_s1:
	li $s1, 0	
restore_gravity_hamster:
	#restore registers
	lw $t0, 0($sp)
	lw $t1, 4($sp)
	lw $t2, 8($sp)
	lw $t3, 12($sp)
	lw $t4, 16($sp)
	lw $t5, 20($sp)
	lw $t6, 24($sp)
	lw $t7, 28($sp)
	lw $a0, 32($sp)
	lw $ra, 36($sp)
	addi $sp, $sp, 40
	jr $ra


draw_hamster:
	# precondition: 0<=$t8<=51,2<=y<=55
	# save old registers
	addi $sp, $sp, -12
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $ra, 8($sp)
	#calculate top right address, store in $t0, $t1 as temporary register
	#$t0=x*256=$t8*256
	#$t1=y*4=$t9*4
	#$t0=$t0+$t1+base_address
	sll $t0, $t8, 8
	sll $t1, $t9, 2
	add $t0, $t0, $t1
	addi $t0, $t0, base_address
	# paint black to all black hamster pixels
	# store black color in $t1
	addi $t1, $zero, black
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 20($t0)
	sw $t1, 24($t0)
	sw $t1, 252($t0)
	sw $t1, 264($t0)
	sw $t1, 272($t0)
	sw $t1, 284($t0)
	sw $t1, 508($t0)
	sw $t1, 520($t0)
	sw $t1, 528($t0)
	sw $t1, 540($t0)
	sw $t1, 768($t0)
	sw $t1, 780($t0)
	sw $t1, 792($t0)
	sw $t1, 1028($t0)
	sw $t1, 1044($t0)
	sw $t1, 1280($t0)
	sw $t1, 1304($t0)
	sw $t1, 1532($t0)
	sw $t1, 1564($t0)
	sw $t1, 1788($t0)
	sw $t1, 1820($t0)
	sw $t1, 2040($t0)
	sw $t1, 2052($t0)
	sw $t1, 2068($t0)
	sw $t1, 2080($t0)
	sw $t1, 2296($t0)
	sw $t1, 2308($t0)
	sw $t1, 2324($t0)
	sw $t1, 2336($t0)
	sw $t1, 2552($t0)
	sw $t1, 2572($t0)
	sw $t1, 2592($t0)
	sw $t1, 2812($t0)
	sw $t1, 2844($t0)
	sw $t1, 3072($t0)
	sw $t1, 3076($t0)
	sw $t1, 3080($t0)
	sw $t1, 3084($t0)
	sw $t1, 3088($t0)
	sw $t1, 3092($t0)
	sw $t1, 3096($t0)
	# paint oldlace to all oldlace hamster pixels
	# store oldlace color in $t1
	li $t1, oldlace
	sw $t1, 2560($t0)
	sw $t1, 2564($t0)
	sw $t1, 2568($t0)
	sw $t1, 2576($t0)
	sw $t1, 2580($t0)
	sw $t1, 2584($t0)
	sw $t1, 2816($t0)
	sw $t1, 2820($t0)
	sw $t1, 2824($t0)
	sw $t1, 2828($t0)
	sw $t1, 2832($t0)
	sw $t1, 2836($t0)
	sw $t1, 2840($t0)
	# paint gold to all gold hamster pixels
	# store gold color in $t1
	li $t1, gold
	sw $t1, 776($t0)
	sw $t1, 784($t0)
	sw $t1, 1032($t0)
	sw $t1, 1036($t0)
	sw $t1, 1040($t0)
	sw $t1, 1284($t0)
	sw $t1, 1288($t0)
	sw $t1, 1292($t0)
	sw $t1, 1296($t0)
	sw $t1, 1300($t0)
	sw $t1, 1536($t0)
	sw $t1, 1540($t0)
	sw $t1, 1544($t0)
	sw $t1, 1548($t0)
	sw $t1, 1552($t0)
	sw $t1, 1556($t0)
	sw $t1, 1560($t0)
	sw $t1, 1792($t0)
	sw $t1, 1796($t0)
	sw $t1, 1800($t0)
	sw $t1, 1804($t0)
	sw $t1, 1808($t0)
	sw $t1, 1812($t0)
	sw $t1, 1816($t0)
	sw $t1, 2044($t0)
	sw $t1, 2048($t0)
	sw $t1, 2056($t0)
	sw $t1, 2060($t0)
	sw $t1, 2064($t0)
	sw $t1, 2072($t0)
	sw $t1, 2076($t0)
	sw $t1, 2300($t0)
	sw $t1, 2304($t0)
	sw $t1, 2312($t0)
	sw $t1, 2316($t0)
	sw $t1, 2320($t0)
	sw $t1, 2328($t0)
	sw $t1, 2332($t0)
	sw $t1, 2556($t0)
	sw $t1, 2588($t0)
	# paint moccasin to all moccasin hamster pixels
	# store moccasin color in $t1
	li $t1, moccasin
	sw $t1, 516($t0)
	sw $t1, 532($t0)
	sw $t1, 772($t0)
	sw $t1, 788($t0)
	# paint tan to all tan hamster pixels
	# store tan color in $t1
	li $t1, tan
	sw $t1, 256($t0)
	sw $t1, 260($t0)
	sw $t1, 276($t0)
	sw $t1, 280($t0)
	sw $t1, 512($t0)
	sw $t1, 536($t0)		
	#restore registers
	lw $t0, 0($sp)
	lw $t1, 4($sp)
	lw $ra, 8($sp)
	addi $sp, $sp, 12
	jr $ra


draw_jetplane:
	addi $sp, $sp, -12
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $ra, 8($sp)
	#calculate the top middle address
	#$t0 stores address, $t1 stores color
	sll $t0, $a0, 2
	addi $t0, $t0, base_address
	li $t1, darkgreen
	#0
	sw $t1, 0($t0)
	#1
	sw $t1, 256($t0)
	#2
	sw $t1, 508($t0)
	sw $t1, 512($t0)
	sw $t1, 516($t0)
	#3
	sw $t1, 732($t0)
	sw $t1, 736($t0)
	sw $t1, 740($t0)
	sw $t1, 744($t0)
	sw $t1, 760($t0)
	sw $t1, 776($t0)
	sw $t1, 792($t0)
	sw $t1, 796($t0)
	sw $t1, 800($t0)
	sw $t1, 804($t0)
	#4
	sw $t1, 1000($t0)
	sw $t1, 1004($t0)
	sw $t1, 1008($t0)
	sw $t1, 1012($t0)
	sw $t1, 1020($t0)
	sw $t1, 1024($t0)
	sw $t1, 1028($t0)
	sw $t1, 1032($t0)
	sw $t1, 1036($t0)
	sw $t1, 1040($t0)
	sw $t1, 1044($t0)
	sw $t1, 1048($t0)
	#5
	sw $t1, 1224($t0)
	sw $t1, 1228($t0)
	sw $t1, 1232($t0)
	sw $t1, 1236($t0)
	sw $t1, 1240($t0)
	sw $t1, 1244($t0)
	sw $t1, 1268($t0)
	sw $t1, 1276($t0)
	sw $t1, 1280($t0)
	sw $t1, 1284($t0)
	sw $t1, 1292($t0)
	sw $t1, 1316($t0)
	sw $t1, 1320($t0)
	sw $t1, 1324($t0)
	sw $t1, 1328($t0)
	sw $t1, 1332($t0)
	sw $t1, 1336($t0)
	#6
	sw $t1, 1484($t0)
	sw $t1, 1488($t0)
	sw $t1, 1492($t0)
	sw $t1, 1500($t0)
	sw $t1, 1504($t0)
	sw $t1, 1508($t0)
	sw $t1, 1512($t0)
	sw $t1, 1516($t0)
	sw $t1, 1520($t0)
	sw $t1, 1524($t0)
	sw $t1, 1532($t0)
	sw $t1, 1536($t0)
	sw $t1, 1540($t0)
	sw $t1, 1548($t0)
	sw $t1, 1552($t0)
	sw $t1, 1556($t0)
	sw $t1, 1560($t0)
	sw $t1, 1564($t0)
	sw $t1, 1568($t0)
	sw $t1, 1572($t0)
	sw $t1, 1580($t0)
	sw $t1, 1584($t0)
	sw $t1, 1588($t0)
	#7
	sw $t1, 1740($t0)
	sw $t1, 1748($t0)
	sw $t1, 1760($t0)
	sw $t1, 1764($t0)
	sw $t1, 1768($t0)
	sw $t1, 1780($t0)
	sw $t1, 1792($t0)
	sw $t1, 1804($t0)
	sw $t1, 1816($t0)
	sw $t1, 1820($t0)
	sw $t1, 1824($t0)
	sw $t1, 1836($t0)
	sw $t1, 1840($t0)
	sw $t1, 1844($t0)
	#8
	sw $t1, 2000($t0)
	sw $t1, 2012($t0)
	sw $t1, 2016($t0)
	sw $t1, 2024($t0)
	sw $t1, 2028($t0)
	sw $t1, 2040($t0)
	sw $t1, 2056($t0)
	sw $t1, 2068($t0)
	sw $t1, 2072($t0)
	sw $t1, 2080($t0)
	sw $t1, 2084($t0)
	sw $t1, 2096($t0)
	#9
	sw $t1, 2272($t0)
	sw $t1, 2276($t0)
	sw $t1, 2280($t0)
	sw $t1, 2300($t0)
	sw $t1, 2304($t0)
	sw $t1, 2308($t0)
	sw $t1, 2328($t0)
	sw $t1, 2332($t0)
	sw $t1, 2336($t0)
	# paint sea green
	li $t1, seagreen
	
	sw $t1, 764($t0)
	sw $t1, 768($t0)
	sw $t1, 772($t0)
	sw $t1, 1016($t0)
	sw $t1, 1020($t0)
	sw $t1, 1028($t0)
	sw $t1, 1032($t0)
	sw $t1, 1272($t0)
	sw $t1, 1288($t0)
	
	sw $t1, 1528($t0)
	sw $t1, 1544($t0)
	
	sw $t1, 1784($t0)
	sw $t1, 1788($t0)
	sw $t1, 1796($t0)
	sw $t1, 1800($t0)
	
	sw $t1, 2044($t0)
	sw $t1, 2048($t0)
	sw $t1, 2052($t0)
	# paint red 
	li $t1, red
	sw $t1, 1744($t0)
	sw $t1, 1840($t0)
	sw $t1, 2020($t0)
	sw $t1, 2076($t0)
	
	lw $t0, 0($sp)
	lw $t1, 4($sp)
	lw $ra, 8($sp)
	addi $sp, $sp, 12
	jr $ra
	
draw_platform:
	addi $sp, $sp, -44
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $t3, 12($sp)
	sw $t4, 16($sp)
	sw $t5, 20($sp)
	sw $t6, 24($sp)
	sw $t7, 28($sp)
	sw $s3, 32($sp)
	sw $s4, 36($sp)
	sw $ra, 40($sp)
	
	#$t0=base_address
	#$t1=green
	#$t2=iteration
	#$t3=address of platX array
	#$t4=address of platYhead array
	#$t5=address of platYtail array
	#$t6=platX[$t2]
	#$t7=platYhead[$t2], then iterate until $t7=$t8
	#$s3=platYtail[$t2]
	#$s4=address of the array coordinate
	li $t0, base_address 	# $t0=the base address for display
	add $t1, $zero, $a0		# $t1=color of character
	li $t2, 0		# $t2 is iteration number
	la $t3, platX		# $t3=address of platX array
	la $t4, platYhead		# $t4=address of platYhead array
	la $t5, platYtail	# $t5=address of platYtail array
	#convert (x,y) to position in display and store in $t9
	#s3=x*256, $s4=y*4, $s4=$s3+$s4+base_address
loopPlatXY:	lw $t6, 0($t3)		# $t6=platX[$t2]
	lw $t7, 0($t4)		# $t7=platYhead[$t2]
	lw $s3, 0($t5)		# $s3=platYtail[$t2]
	#if $t7<0 || $t7>63, dont draw, $t7++
loopPlatY:	blt $t7, 0, nextPlat
	bgt $t7, 63, nextPlat
	#we are here, so can draw the platform
	#convert ($t6, $t7) to address in frame
	lw $t6, 0($t3)		# $t6=platX[$t2]
	sll $t6, $t6,8 		# $t6=$t6*256
	add $s4, $zero, $t7	# $s4=$t7
	sll $s4, $s4, 2		# $s4=$t7*4
	add $s4, $s4, $t6	# $s4=$t6+$s4
	addi $s4, $s4, base_address	#$s4=$t6+$s4+base_address
	sw $t1, 0($s4)		# paint to brown
	# increment $t7 until $t7=$s3
	addi $t7, $t7, 1
	ble $t7, $s3, loopPlatY
	# outer loop
nextPlat:	addi $t2, $t2, 1	# iteration ++
	addi $t3, $t3, 4	# update memory address of element in manX
	addi $t4, $t4, 4	# update memory address of element in manYhead
	addi $t5, $t5, 4	# update memory address of element in manYtail
	
	blt $t2,platNum, loopPlatXY
	
	#restore registers
	lw $t0, 0($sp)
	lw $t1, 4($sp)
	lw $t2, 8($sp)
	lw $t3, 12($sp)
	lw $t4, 16($sp)
	lw $t5, 20($sp)
	lw $t6, 24($sp)
	lw $t7, 28($sp)
	lw $s3, 32($sp)
	lw $s4, 36($sp)
	lw $ra, 40($sp)
	addi $sp, $sp, 44
	jr $ra

erase_hamster:
	# precondition: 0<=$t8<=51,2<=y<=55
	# save old registers
	addi $sp, $sp, -12
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $ra, 8($sp)
	#calculate top right address, store in $t0, $t1 as temporary register
	#$t0=$t8*256
	#$t1=$t9*4
	#$t0=$t0+$t1+base_address
	sll $t0, $t8, 8
	sll $t1, $t9, 2
	add $t0, $t0, $t1
	addi $t0, $t0, base_address
	addi $t1, $zero, skyblue
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 20($t0)
	sw $t1, 24($t0)
	sw $t1, 252($t0)
	sw $t1, 264($t0)
	sw $t1, 272($t0)
	sw $t1, 284($t0)
	sw $t1, 508($t0)
	sw $t1, 520($t0)
	sw $t1, 528($t0)
	sw $t1, 540($t0)
	sw $t1, 768($t0)
	sw $t1, 780($t0)
	sw $t1, 792($t0)
	sw $t1, 1028($t0)
	sw $t1, 1044($t0)
	sw $t1, 1280($t0)
	sw $t1, 1304($t0)
	sw $t1, 1532($t0)
	sw $t1, 1564($t0)
	sw $t1, 1788($t0)
	sw $t1, 1820($t0)
	sw $t1, 2040($t0)
	sw $t1, 2052($t0)
	sw $t1, 2068($t0)
	sw $t1, 2080($t0)
	sw $t1, 2296($t0)
	sw $t1, 2308($t0)
	sw $t1, 2324($t0)
	sw $t1, 2336($t0)
	sw $t1, 2552($t0)
	sw $t1, 2572($t0)
	sw $t1, 2592($t0)
	sw $t1, 2812($t0)
	sw $t1, 2844($t0)
	sw $t1, 3072($t0)
	sw $t1, 3076($t0)
	sw $t1, 3080($t0)
	sw $t1, 3084($t0)
	sw $t1, 3088($t0)
	sw $t1, 3092($t0)
	sw $t1, 3096($t0)
	sw $t1, 2560($t0)
	sw $t1, 2564($t0)
	sw $t1, 2568($t0)
	sw $t1, 2576($t0)
	sw $t1, 2580($t0)
	sw $t1, 2584($t0)
	sw $t1, 2816($t0)
	sw $t1, 2820($t0)
	sw $t1, 2824($t0)
	sw $t1, 2828($t0)
	sw $t1, 2832($t0)
	sw $t1, 2836($t0)
	sw $t1, 2840($t0)
	sw $t1, 776($t0)
	sw $t1, 784($t0)
	sw $t1, 1032($t0)
	sw $t1, 1036($t0)
	sw $t1, 1040($t0)
	sw $t1, 1284($t0)
	sw $t1, 1288($t0)
	sw $t1, 1292($t0)
	sw $t1, 1296($t0)
	sw $t1, 1300($t0)
	sw $t1, 1536($t0)
	sw $t1, 1540($t0)
	sw $t1, 1544($t0)
	sw $t1, 1548($t0)
	sw $t1, 1552($t0)
	sw $t1, 1556($t0)
	sw $t1, 1560($t0)
	sw $t1, 1792($t0)
	sw $t1, 1796($t0)
	sw $t1, 1800($t0)
	sw $t1, 1804($t0)
	sw $t1, 1808($t0)
	sw $t1, 1812($t0)
	sw $t1, 1816($t0)
	sw $t1, 2044($t0)
	sw $t1, 2048($t0)
	sw $t1, 2056($t0)
	sw $t1, 2060($t0)
	sw $t1, 2064($t0)
	sw $t1, 2072($t0)
	sw $t1, 2076($t0)
	sw $t1, 2300($t0)
	sw $t1, 2304($t0)
	sw $t1, 2312($t0)
	sw $t1, 2316($t0)
	sw $t1, 2320($t0)
	sw $t1, 2328($t0)
	sw $t1, 2332($t0)
	sw $t1, 2556($t0)
	sw $t1, 2588($t0)
	sw $t1, 516($t0)
	sw $t1, 532($t0)
	sw $t1, 772($t0)
	sw $t1, 788($t0)
	sw $t1, 256($t0)
	sw $t1, 260($t0)
	sw $t1, 276($t0)
	sw $t1, 280($t0)
	sw $t1, 512($t0)
	sw $t1, 536($t0)		
	#restore registers
	lw $t0, 0($sp)
	lw $t1, 4($sp)
	lw $ra, 8($sp)
	addi $sp, $sp, 12
	jr $ra

move_platform:
	# save old registers
	addi $sp, $sp, -64
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $t3, 12($sp)
	sw $t4, 16($sp)
	sw $t5, 20($sp)
	sw $t6, 24($sp)
	sw $t7, 28($sp)
	sw $s5, 32($sp)
	sw $s6, 36($sp)
	sw $s7, 40($sp)
	sw $s2, 44($sp)
	sw $s3, 48($sp)
	sw $s4, 52($sp)
	sw $a0, 56($sp)
	sw $ra, 60($sp)
	#$t0=iteration
	#$t1=address of platLen array
	#$t2=address of platX array
	#$t3=address of platYhead array
	#$t4=address of platYtail array
	#$t5=platLen[$t2]
	#$t6=platX[$t2]
	#$t7=platYhead[$t2]
	#$s5=platYtail[$t2]
	#$s7=$t6*256
	#$s6=address of (x,y)
	#$s2=skyblue
	#$s3=green
	#$s4=color at the new head of the platform
	li $s2,skyblue		# $s2=skyblue
	li $s3, green		# $s3=green
	li $t0,0		# $t0=iteration
	la $t1, platLen		# $t1=address of platXLen array
	la $t2, platX		# $t2=address of platX array
	la $t3, platYhead	# $t3=address of platYhead array
	la $t4, platYtail	# $t4=address of platYtail array
	
loop_move_platform:
	lw $t5, 0($t1)		# $t5=platXLen[$t0]
	lw $t6, 0($t2)		# $t6=platX[$t0]
	lw $t7, 0($t3)		# $t7=platYhead[$t0]
	lw $s5, 0($t4)		# $s5=platYtail[$t0]
	
	# paint tail to skyblue
	bgt $s5, 63, done_skyblue_tail 	# if platYtail[$t0]>63, no need to paint to skyblue, branch to done_skyblue_tail
	#we are here, so we need to paint tail to skyblue
	sll $s7, $t6,8 		# $s7=$t6(platX[$t0])*256
	add $s6, $zero, $s5	# $s6=$s5(platYtail[$t0])
	sll $s6, $s6, 2		# $s6=$s5*4
	add $s6, $s6, $s7	# $s6=$s7+$s6
	addi $s6, $s6, base_address	#$s6=$s7+$s6+base_address
	li $s2, skyblue
	sw $s2, 0($s6)		# paint to skyblue
	
	# move head and tail 1 left
	
done_skyblue_tail:
	addi $s5, $s5, -1	# move tail 1 left
	# check if tail >=0
	blt $s5, 0, new_platform	# if new tail<0, need to create new platform and draw it
	# we are here, so new tail >= 0, update new tail and new head to the array
	
	addi $t7, $t7, -1	# move head 1 left
	sw $t7, 0($t3)
	sw $s5, 0($t4)
	# check if new head<0, if new head<0, no need to paint it, branch to next_platform
	blt $t7, 0, next_platform
	# we are here, so new head>=0
	# check if new head position is hamster
	# if yes, then move hamster 1 left
	# if cannot move hamster 1 left, smash and game over
	# else draw it to green
	sll $s7, $t6,8 		# $s7=$t6*256
	add $s6, $zero, $t7	# $s6=$t7
	sll $s6, $s6, 2		# $s6=$t7*4
	add $s6, $s6, $s7	# $s6=$s7+$s6
	addi $s6, $s6, base_address	#$s6=$s7+$s6+base_address
	lw $s4, 0($s6)
	beq $s4, black, fake_a
return_fake_a:
	li $a0, green
	jal draw_platform
	#sw $s3, 0($s6)		# paint to green
next_platform:
	addi $t0, $t0, 1	# iteration ++
	addi $t1, $t1, 4	# update memory address of element in platLen
	addi $t2, $t2, 4	# update memory address of element in platX
	addi $t3, $t3, 4	# update memory address of element in platXhead
	addi $t4, $t4, 4	# update memory address of element in platXtail
	blt $t0,platNum, loop_move_platform	# if $t0<platNum, move the next platform
	# we are here, so we have updated all platforms. go to restore_platform
	j restore_platform
new_platform:
	#set random number for platX
	#set random number for platLen
	#set platYhead[$t0]=31
	#draw the head
	li $v0, 42		# generate random number for platX from 0-35(inclusive)
	
	li $a1, 36
	syscall
	addi $a0, $a0,25		# $a0=random number + 25, platX between 25-60
	sw $a0, 0($t2)		# platX[$t0]=random number
	li $t7,63		# $t7=platYhead[$t0]=63
	sw $t7, 0($t3)		# platYhead[$t0]=63
	li $v0, 42		# generate random number for platLen from 0-10 (inclusive)
	li $a1, 11
	syscall
	addi $a0,$a0, 15		# $a0=random number +15, from 15-25
	sw $a0, 0($t1)		# platLen[$t0]=random number
	lw $t5, 0($t1)		# $t5=platLen[$t0]
	lw $t6, 0($t2)		# $t6=random number for platX=platX[$t0]
	add $s5, $t7, $a0	# $s5=random number for platYhead + random number for platLen=platYtail[$t0]
	addi $s5, $s5,-1
	sw $s5, 0($t4)		# platYtail[$t0]=platYhead[$t0]+platLen[$t0]-1
	
	#draw head
	sll $s7, $t6,8 		# $s7=$t6*256
	add $s6, $zero, $t7	# $s6=$t7
	sll $s6, $s6, 2		# $s6=$t7*4
	add $s6, $s6, $s7	# $s6=$s7+$s6
	addi $s6, $s6, base_address	#$s6=$s7+$s6+base_address
	sw $s3, 0($s6)		# paint to green
	
	j next_platform
		
restore_platform:	
	#restore registers
	lw $t0, 0($sp)
	lw $t1, 4($sp)
	lw $t2, 8($sp)
	lw $t3, 12($sp)
	lw $t4, 16($sp)
	lw $t5, 20($sp)
	lw $t6, 24($sp)
	lw $t7, 28($sp)
	lw $s5, 32($sp)
	lw $s6, 36($sp)
	lw $s7, 40($sp)
	lw $s2, 44($sp)
	lw $s3, 48($sp)
	lw $s4, 52($sp)
	lw $a0, 56($sp)
	lw $ra, 60($sp)
	addi $sp, $sp, 64
	jr $ra

fake_a:
	li $s2, 0	# let $s2 to be not successful
	# if $t9<=2 can not move left
	ble $t9, 2, smash
	jal erase_hamster
	addi $t9, $t9, -1
	jal draw_hamster
	j return_fake_a
	
bullet:
	# save old registers
	addi $sp, $sp, -64
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $t3, 12($sp)
	sw $t4, 16($sp)
	sw $t5, 20($sp)
	sw $t6, 24($sp)
	sw $t7, 28($sp)
	sw $s5, 32($sp)
	sw $s6, 36($sp)
	sw $s7, 40($sp)
	sw $s2, 44($sp)
	sw $s3, 48($sp)
	sw $s4, 52($sp)
	sw $a0, 56($sp)
	sw $ra, 60($sp)
	# $t0=iteration number
	# $t1=address of bulletX
	# $t2=address of bulletY
	# $t3=address of bulletSpeed
	# $t4=bulletX[$t0]
	# $t5=bulletY[$t0]
	# $t6=bulletSpeed[$t0]
	# $t7=current bullet address in frame
	# $s2=color
	li $t0, 0
	la $t1, bulletX
	la $t2, bulletY
	la $t3, bulletSpeed
bullet_loop:
	lw $t4, 0($t1)
	lw $t5, 0($t2)
	lw $t6, 0($t3)
	
	
	# if $t4>=64, generate a new bullet
	bge $t4, 64, new_bullet
	# we are here, so should move the bullet according to its speed
	# erase current bullet
	sll $t7, $t4, 8
	add $t7, $t7, $t5
	add $t7, $t7, $t5
	add $t7, $t7, $t5
	add $t7, $t7, $t5
	addi $t7, $t7, base_address
	li $s2, skyblue
	sw $s2, 0($t7)
	sw $s2, 4($t7)
	sw $s2, 256($t7)
	sw $s2, 260($t7)
	# update bulletX and draw new bullet
	add $t4, $t4, $t6
	sw $t4, 0($t1)
	sll $t7, $t4, 8
	add $t7, $t7, $t5
	add $t7, $t7, $t5
	add $t7, $t7, $t5
	add $t7, $t7, $t5
	addi $t7, $t7, base_address
	li $s2, firered
	# if $t4=63, just draw 2 pixels
	beq $t4, 63, draw_2_bullet_pixel
	bge $t4, 64, next_bullet
	# we are here, so can draw the whole bullet
	sw $s2, 256($t7)
	sw $s2, 260($t7)
draw_2_bullet_pixel:
	sw $s2, 0($t7)
	sw $s2, 4($t7)
next_bullet:
	addi $t0, $t0, 1
	addi $t1, $t1, 4
	addi $t2, $t2, 4
	addi $t3, $t3, 4
	blt $t0, bulletNum, bullet_loop
	j restore_bullet
	
new_bullet:
	# 33% chance to generate new bullet
	li $v0, 42		
	li $a1, 3
	syscall
	# if $a0=0 or 1, next_bullet
	# if $a0=2, generate new bullet
	beq $a0, 0, next_bullet
	beq $a0, 1, next_bullet
	# $t4=bulletX[$t0]=10
	li $t4, 10
	sw $t4, 0($t1)
	# $t5=bulletY[$t0]=random number from 0 to 62
	li $v0, 42		
	li $a1, 63
	syscall
	move $t5, $a0
	sw $t5, 0($t2)
	# $t6=bulletSpeed[$t0]=random number from 1 to 3
	li $v0, 42		
	li $a1, 3
	syscall
	addi $a0, $a0, 1
	move $t6, $a0
	sw $t6, 0($t3)
	# draw bullet
	sll $t7, $t4, 8
	add $t7, $t7, $t5
	add $t7, $t7, $t5
	add $t7, $t7, $t5
	add $t7, $t7, $t5
	addi $t7, $t7, base_address
	li $s2, firered
	sw $s2, 256($t7)
	sw $s2, 260($t7)
	sw $s2, 0($t7)
	sw $s2, 4($t7)
	j next_bullet
	
restore_bullet:	#restore registers
	lw $t0, 0($sp)
	lw $t1, 4($sp)
	lw $t2, 8($sp)
	lw $t3, 12($sp)
	lw $t4, 16($sp)
	lw $t5, 20($sp)
	lw $t6, 24($sp)
	lw $t7, 28($sp)
	lw $s5, 32($sp)
	lw $s6, 36($sp)
	lw $s7, 40($sp)
	lw $s2, 44($sp)
	lw $s3, 48($sp)
	lw $s4, 52($sp)
	lw $a0, 56($sp)
	lw $ra, 60($sp)
	addi $sp, $sp, 64
	jr $ra
	
check_collision:	
	# save old registers
	addi $sp, $sp, -64
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $t3, 12($sp)
	sw $t4, 16($sp)
	sw $t5, 20($sp)
	sw $t6, 24($sp)
	sw $t7, 28($sp)
	sw $s5, 32($sp)
	sw $s6, 36($sp)
	sw $s7, 40($sp)
	sw $s2, 44($sp)
	sw $s3, 48($sp)
	sw $s4, 52($sp)
	sw $a0, 56($sp)
	sw $ra, 60($sp)
	#$t0=iteration
	#$t1=address of bulletX
	#$t2=address of bulletY
	#$t3=bulletX[$t0]
	#$t4=bulletY[$t0]
	#$t5=address in frame
	#$t6=color
	
	li $t0, 0
	la $t1, bulletX
	la $t2, bulletY
check_each_collision:	
	lw $t3, 0($t1)
	lw $t4, 0($t2)
	sll $t5, $t3, 8
	add $t5, $t5, $t4
	add $t5, $t5, $t4
	add $t5, $t5, $t4
	add $t5, $t5, $t4
	addi $t5, $t5, base_address
	
	# separate situations based on column
	beq $t4, 0, check_right_collision
	beq $t4, 62, check_left_collision
	j check_both_collision
	
check_next_collision:
	addi $t0, $t0, 1
	addi $t1, $t1, 4
	addi $t2, $t2, 4
	blt $t0, bulletNum, check_each_collision	
	
	lw $t0, 0($sp)
	lw $t1, 4($sp)
	lw $t2, 8($sp)
	lw $t3, 12($sp)
	lw $t4, 16($sp)
	lw $t5, 20($sp)
	lw $t6, 24($sp)
	lw $t7, 28($sp)
	lw $s5, 32($sp)
	lw $s6, 36($sp)
	lw $s7, 40($sp)
	lw $s2, 44($sp)
	lw $s3, 48($sp)
	lw $s4, 52($sp)
	lw $a0, 56($sp)
	lw $ra, 60($sp)
	addi $sp, $sp, 64
	jr $ra

check_right_collision:
	# separate situations based on row position
	ble $t3, 61, check1		
	beq $t3, 62, check2
	beq $t3, 63, check3
	bgt $t3, 63, check_next_collision					
check_left_collision:
	ble $t3, 61, check4		
	beq $t3, 62, check5
	beq $t3, 63, check6
	bgt $t3, 63, check_next_collision										
check_both_collision:
	ble $t3, 61, check7		
	beq $t3, 62, check8
	beq $t3, 63, check9
	bgt $t3, 63, check_next_collision
										
check1:
	lw $t6, 264($t5)
	beq $t6, black, collision
	lw $t6, 512($t5)
	beq $t6, black, collision
	lw $t6, 516($t5)
	beq $t6, black, collision
	lw $t6, 520($t5)
	beq $t6, black, collision
	j check_next_collision																				
check2:
	lw $t6, 264($t5)
	beq $t6, black, collision
	j check_next_collision	
check3:
	lw $t6, 8($t5)
	beq $t6, black, collision
	j check_next_collision	
check4:	
	lw $t6, 252($t5)
	beq $t6, black, collision
	lw $t6, 512($t5)
	beq $t6, black, collision
	lw $t6, 516($t5)
	beq $t6, black, collision
	lw $t6, 508($t5)
	beq $t6, black, collision
	j check_next_collision	
check5: 
	lw $t6, 252($t5)
	beq $t6, black, collision
	j check_next_collision	
	
check6:
	addi $t5, $t5, -4
	lw $t6, 0($t5)
	beq $t6, black, collision
	addi $t5, $t5, 4
	j check_next_collision	
check7:	
	lw $t6, 264($t5)
	beq $t6, black, collision
	lw $t6, 512($t5)
	beq $t6, black, collision
	lw $t6, 516($t5)
	beq $t6, black, collision
	lw $t6, 520($t5)
	beq $t6, black, collision
	lw $t6, 252($t5)
	beq $t6, black, collision
	lw $t6, 508($t5)
	beq $t6, black, collision
	j check_next_collision	
check8:
	lw $t6, 252($t5)
	beq $t6, black, collision
	lw $t6, 264($t5)
	beq $t6, black, collision
	j check_next_collision	
check9:
	addi $t5, $t5, -4
	lw $t6, 0($t5)
	beq $t6, black, collision
	addi $t5, $t5, 4
	lw $t6, 8($t5)
	beq $t6, black, collision
	j check_next_collision	

	
draw_enemy:
	addi $sp, $sp, -28
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $t3, 12($sp)
	sw $t4, 16($sp)
	sw $a0, 20($sp)
	sw $ra, 24($sp)
	# $t0=address of enemy
	# $t1=y coordinate=enemy[0]
	# $t2=right or left=enemy[1]
	# $t3=address in frame
	# $t4=color
	
	la $t0, enemy
	lw $t1, 0($t0)
	lw $t2, 4($t0)
	sll $t3, $t1, 2
	addi $t3, $t3, 14848
	addi $t3, $t3, base_address
	li $t4, orange
	sw $t4, 0($t3)
	sw $t4, 12($t3)
	li $t4, yellow
	sw $t4, 4($t3)
	sw $t4, 8($t3)
	li $t4, maroon
	#1
	sw $t4, 252($t3)
	sw $t4, 256($t3)
	sw $t4, 260($t3)
	sw $t4, 264($t3)
	sw $t4, 268($t3)
	sw $t4, 272($t3)
	#3
	sw $t4, 764($t3)
	sw $t4, 772($t3)
	sw $t4, 776($t3)
	sw $t4, 784($t3)
	#4
	sw $t4, 1020($t3)
	sw $t4, 1024($t3)
	sw $t4, 1028($t3)
	sw $t4, 1032($t3)
	sw $t4, 1036($t3)
	sw $t4, 1040($t3)
	#5
	sw $t4, 1276($t3)
	sw $t4, 1280($t3)
	sw $t4, 1292($t3)
	sw $t4, 1296($t3)
	li $t4, sienna
	sw $t4, 512($t3)
	sw $t4, 524($t3)
	li $t4, orangered
	sw $t4, 768($t3)
	sw $t4, 780($t3)
	sw $t4, 1284($t3)
	sw $t4, 1288($t3)
	beq $t2, 1, right_enemy
left_enemy:
	li $t4, sienna
	sw $t4, 508($t3)
	sw $t4, 520($t3)
	li $t4, maroon
	sw $t4, 516($t3)
	sw $t4, 528($t3)
	j restore_draw_enemy
right_enemy:
	li $t4, maroon
	sw $t4, 508($t3)
	sw $t4, 520($t3)
	li $t4, sienna
	sw $t4, 516($t3)
	sw $t4, 528($t3)
restore_draw_enemy:	
	lw $t0, 0($sp)
	lw $t1, 4($sp)
	lw $t2, 8($sp)
	lw $t3, 12($sp)
	lw $t4, 16($sp)
	lw $a0, 20($sp)
	lw $ra, 24($sp)
	addi $sp, $sp, 28
	jr $ra		

erase_enemy:
	addi $sp, $sp, -28
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $t3, 12($sp)
	sw $t4, 16($sp)
	sw $a0, 20($sp)
	sw $ra, 24($sp)
	# $t0=address of enemy
	# $t1=y coordinate=enemy[0]
	# $t2=right or left=enemy[1]
	# $t3=address in frame
	# $t4=color
	
	la $t0, enemy
	lw $t1, 0($t0)
	lw $t2, 4($t0)
	sll $t3, $t1, 2
	addi $t3, $t3, 14848
	addi $t3, $t3, base_address
	li $t4, skyblue
	sw $t4, 0($t3)
	sw $t4, 12($t3)
	sw $t4, 4($t3)
	sw $t4, 8($t3)
	sw $t4, 252($t3)
	sw $t4, 256($t3)
	sw $t4, 260($t3)
	sw $t4, 264($t3)
	sw $t4, 268($t3)
	sw $t4, 272($t3)
	sw $t4, 764($t3)
	sw $t4, 772($t3)
	sw $t4, 776($t3)
	sw $t4, 784($t3)
	sw $t4, 1020($t3)
	sw $t4, 1024($t3)
	sw $t4, 1028($t3)
	sw $t4, 1032($t3)
	sw $t4, 1036($t3)
	sw $t4, 1040($t3)
	sw $t4, 1276($t3)
	sw $t4, 1280($t3)
	sw $t4, 1292($t3)
	sw $t4, 1296($t3)
	sw $t4, 516($t3)
	sw $t4, 528($t3)
	sw $t4, 772($t3)
	sw $t4, 784($t3)
	sw $t4, 1284($t3)
	sw $t4, 1288($t3)
	sw $t4, 508($t3)
	sw $t4, 520($t3)
	sw $t4, 516($t3)
	sw $t4, 528($t3)	
	lw $t0, 0($sp)
	lw $t1, 4($sp)
	lw $t2, 8($sp)
	lw $t3, 12($sp)
	lw $t4, 16($sp)
	lw $a0, 20($sp)
	lw $ra, 24($sp)
	addi $sp, $sp, 28
	jr $ra			
				
move_enemy:
	addi $sp, $sp, -28
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $t3, 12($sp)
	sw $t4, 16($sp)
	sw $a0, 20($sp)
	sw $ra, 24($sp)
	# $t0=address of enemy
	# $t1=y coordinate=enemy[0]
	# $t2=right or left=enemy[1]
	la $t0, enemy
	lw $t1, 0($t0)
	lw $t2, 4($t0)
	jal erase_enemy
	#decide whether go left or go right
	#if y=1, left, keep y, change to right, change eyebrow
	#if y=1, right, erase, y+1, draw
	#if y=59, left, erase, y-1, draw
	#if y=59, right, keep y, change to left, change eyebrow
	#else, left, y-1, right, y+1
	beq $t1, 1, left_most_enemy
	beq $t1, 59, right_most_enemy
	#we are here, so 1<y<59
	beq $t2, 1, middle_right
	#we are here, so move left	
middle_left:
	addi $t1, $t1, -1
	sw $t1, 0($t0)
	jal draw_enemy
	j restore_move_enemy
middle_right:
	addi $t1, $t1, 1
	sw $t1, 0($t0)
	jal draw_enemy
	j restore_move_enemy
left_most_enemy:
	beq $t2, 1, middle_right
	beq $t2, 0, left_change_right_enemy
right_most_enemy:
	beq $t2, 1, right_change_left_enemy
	beq $t2, 0, middle_left
left_change_right_enemy:
	li $t2, 1
	sw $t2, 4($t0)
	jal draw_enemy
	j restore_move_enemy
right_change_left_enemy:
	li $t2, 0
	sw $t2, 4($t0)
	jal draw_enemy
	j restore_move_enemy
restore_move_enemy:	
	lw $t0, 0($sp)
	lw $t1, 4($sp)
	lw $t2, 8($sp)
	lw $t3, 12($sp)
	lw $t4, 16($sp)
	lw $a0, 20($sp)
	lw $ra, 24($sp)
	addi $sp, $sp, 28
	jr $ra		
		
																
							
												
collision:																																																			
	li $v0, 4	# print "you are shoot\n"
	la $a0, shoot
	syscall
	j END_PROGRAM
																																																																																																	
smash:	li $s3, red
	sw $s3, 0($s6)		# paint to red
	li $v0, 4	# print "you are smashed\n"
	la $a0, smashed
	syscall
	j END_PROGRAM
	
END_PROGRAM:
	li $v0, 10 # terminate the program gracefully
	syscall