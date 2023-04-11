#####################################################################
#
# CSCB58 Winter 2023 Assembly Final Project
# University of Toronto, Scarborough
#
# Student: Gaoyueyang Lyu, 1007624625, lyugaoyu, gaoyueyang.lyu@mail.utoronto.ca
#
# Bitmap Display Configuration:
# - Unit width in pixels: 4 
# - Unit height in pixels: 4 
# - Display width in pixels: 256 
# - Display height in pixels: 512 
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestones have been reached in this submission?
# 
# - Milestone 3 
#
# Which approved features have been implemented for milestone 3?
# (See the assignment handout for the list of additional features)
# 1. Health & score
# 2. Fail condition
# 3. Win condition
# 4. Moving objects
# 5. Moving platforms
# 6. Shoot enemies
# 7. Double jump
# 8. Start menu
#
# Link to video demonstration for final submission:
# - https://utoronto.zoom.us/rec/share/ovNOjhJBsZwkgXWJNoDIWEDGsz5nbtGcvWZUWjfncyj72h4yoGfbpQsS5APwvKuP.Jt2lnSgIR8uiNcxY
#
# Are you OK with us sharing the video with people outside course staff?
# - yes, and please share this project github link as well!
# - https://github.com/GaoLyu/platform_game
# Any additional information that the TA needs to know:
# - I have 2 pick-up effetcs: nuts help to restore health, and
#   carrots enable the hamster to jump when it has already jumped twice
#   or when it is falling down and shouldn't be able to jump
# - Because the height of platforms is completely random, sometimes they
#   may all float high in the air and makes it hard to jump to. 
#   But it's still possible to get onto it as long as you have enough carrots!
# 

#####################################################################




.eqv 	base_address	0x10008000
#hamster color
.eqv 	black		0x00000000
.eqv	gold		0xffffd700
.eqv	oldlace		0xfffdf5e6
.eqv	moccasin	0xffffe4b5
.eqv 	tan		0xffd2b48c

.eqv 	black1		0x008f1d21
.eqv	gold1		0x00e78877
.eqv	oldlace1	0x00fbe2d2
.eqv	moccasin1	0x00db5a6b
.eqv 	tan1		0x00fbe2d2
#background color
.eqv	skyblue		0xffe0ffff
#platform color
.eqv	green		0xff00ff01
#jet plane color
.eqv	darkgreen	0xff006400
.eqv 	seagreen 	0xff2e8b57
.eqv 	red		0xffff0000
.eqv 	firered		0xffb22222
#enemy color:
.eqv 	yellow		0xffffff00 #hat
.eqv 	orange		0xffffa500 #hat
.eqv 	orangered	0x00ff1053 #eye
.eqv	sienna		0xffffe4e1 #eyebrow
.eqv	maroon		0xffffb6c1 #face
#nut color
.eqv	brown		0xffa52a2a
.eqv 	burlywood	0xffdeb887
#carrot color
.eqv 	forestgreen	0xff228822
.eqv 	limegreen	0xff32cd32
.eqv 	lime		0xff00ff00
.eqv	tomato		0xffff6347
.eqv	darkorange	0xffff8c00
.eqv 	orange2		0xffffa501

.eqv 	obstacleNum	4
.eqv	platNum		4
.eqv    bulletNum	4
.eqv 	win		5
.eqv    gray		0x00f2f2f2
.eqv 	darkgray	0x00829191
.eqv 	ground		0x00470b15	
.eqv	wordcolor	0x00f3efef
.data
platLen:	.word	15,  20,  23 , 22
platX:		.word	50, 25, 40, 29
platYhead:	.word	20,  40, 0, 60	
platYtail:	.word 	34,  59, 22, 81
platElement:	.word	0,  1,  1,  -1
elementPosition:	.word	24,  28,  20, 65

bulletX:	.word	64, 64, 64, 64
bulletY:	.space	16
bulletSpeed:	.space	16
enemy:		.word   1, 1  	# first one represent y coordinate (1-59 inclusive), second one is 1 if moving right, 0 if moving left
kill_enemy_num:	.word	0

.text
# $t8=top right row of the hamster
# $t9=top right column of the hamster
# $s0=sleep time
# $s1=number of jump happened
# $s2=check if is successful jump, 1 if successful
# $a2=eat_nut_num
# $a3=health
# $fp=score

menu:	#draw background
	li 	$t0, base_address	# $t0=the base address for display
	li 	$t1, 4096		# $t1=64*64=4096 units
	li 	$t2, skyblue		# $t2=skyblue color
bg1:	sw   	$t2, 0($t0)		# paint the whole screen to skyblue
	addi 	$t0, $t0, 4 		# advance to next unit position in display
	addi 	$t1, $t1, -1		# decrement number of units
	bnez 	$t1, bg1
	
	li 	$t0, base_address	# $t0=the base address for display
	addi $t0, $t0, 16384
	li 	$t1, 640		# $t1=10*64=640 units
	li 	$t2, ground		# $t2=ground color
draw_ground:	sw   	$t2, 0($t0)		# paint the selected screen to ground color
	addi 	$t0, $t0, 4 		# advance to next unit position in display
	addi 	$t1, $t1, -1		# decrement number of units
	bnez 	$t1, draw_ground
	#draw the black back ground
	li 	$t0, base_address	# $t0=the base address for display
	addi $t0, $t0, 18944
	li 	$t1, 3456	# $t1=54*64=3456 units
	li 	$t2, black		# $t2=ground color
draw_bground:	sw   	$t2, 0($t0)		# paint the selected screen to ground color
	addi 	$t0, $t0, 4 		# advance to next unit position in display
	addi 	$t1, $t1, -1		# decrement number of units
	bnez 	$t1, draw_bground
	# draw heart:
	li $a0, 168
	jal draw_heart
	li $a0, 200
	jal draw_heart
	li $a0, 232
	jal draw_heart
	# draw good_luck
	li $t0, base_address
	addi $t0, $t0, 24068
	li $t1, 0x00ffc2b4
	#0
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	sw $t1, 24($t0)
	sw $t1, 28($t0)
	sw $t1, 32($t0)
	sw $t1, 36($t0)
	sw $t1, 40($t0)
	sw $t1, 48($t0)
	sw $t1, 52($t0)
	sw $t1, 56($t0)
	sw $t1, 60($t0)
	sw $t1, 64($t0)
	sw $t1, 72($t0)
	sw $t1, 76($t0)
	sw $t1, 80($t0)
	sw $t1, 84($t0)
	sw $t1, 100($t0)
	sw $t1, 104($t0)
	sw $t1, 108($t0)
	sw $t1, 112($t0)
	sw $t1, 116($t0)
	sw $t1, 124($t0)
	sw $t1, 128($t0)
	sw $t1, 132($t0)
	sw $t1, 136($t0)
	sw $t1, 140($t0)
	sw $t1, 156($t0)
	sw $t1, 160($t0)

	sw $t1, 180($t0)
	sw $t1, 184($t0)
	sw $t1, 192($t0)
	sw $t1, 196($t0)
	sw $t1, 204($t0)
	sw $t1, 208($t0)
	sw $t1, 212($t0)
	sw $t1, 216($t0)
	sw $t1, 220($t0)
	sw $t1, 228($t0)
	sw $t1, 232($t0)
	sw $t1, 240($t0)
	sw $t1, 244($t0)
	#1
	li $t1, 0x00ffd8bf
	addi $t0, $t0, 256
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	sw $t1, 24($t0)
	sw $t1, 28($t0)
	sw $t1, 36($t0)
	sw $t1, 40($t0)
	sw $t1, 48($t0)
	sw $t1, 52($t0)
	sw $t1, 60($t0)
	sw $t1, 64($t0)
	sw $t1, 76($t0)
	sw $t1, 80($t0)
	sw $t1, 100($t0)
	sw $t1, 104($t0)
	sw $t1, 112($t0)
	sw $t1, 116($t0)
	sw $t1, 124($t0)
	sw $t1, 128($t0)
	sw $t1, 136($t0)
	sw $t1, 140($t0)
	sw $t1, 156($t0)
	sw $t1, 160($t0)
	sw $t1, 180($t0)
	sw $t1, 184($t0)
	sw $t1, 192($t0)
	sw $t1, 196($t0)
	sw $t1, 204($t0)
	sw $t1, 208($t0)
	sw $t1, 216($t0)
	sw $t1, 220($t0)
	sw $t1, 228($t0)
	sw $t1, 232($t0)
	sw $t1, 240($t0)
	sw $t1, 244($t0)
	#2
	li $t1, 0x00ffe5b4
	addi $t0, $t0, 256
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	sw $t1, 24($t0)
	sw $t1, 28($t0)
	sw $t1, 48($t0)
	sw $t1, 52($t0)
	sw $t1, 76($t0)
	sw $t1, 80($t0)
	sw $t1, 100($t0)
	sw $t1, 104($t0)
	sw $t1, 112($t0)
	sw $t1, 116($t0)
	sw $t1, 124($t0)
	sw $t1, 128($t0)
	sw $t1, 156($t0)
	sw $t1, 160($t0)
	sw $t1, 180($t0)
	sw $t1, 184($t0)
	sw $t1, 192($t0)
	sw $t1, 196($t0)
	sw $t1, 204($t0)
	sw $t1, 208($t0)
	sw $t1, 228($t0)
	sw $t1, 232($t0)
	sw $t1, 240($t0)
	sw $t1, 244($t0)
	#3
	li $t1, 0x00ffe8cc
	addi $t0, $t0, 256
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	sw $t1, 12($t0)
	sw $t1, 24($t0)
	sw $t1, 28($t0)
	sw $t1, 32($t0)
	sw $t1, 36($t0)
	sw $t1, 52($t0)
	sw $t1, 56($t0)
	sw $t1, 60($t0)
	sw $t1, 76($t0)
	sw $t1, 80($t0)
	sw $t1, 100($t0)
	sw $t1, 104($t0)
	sw $t1, 112($t0)
	sw $t1, 116($t0)
	sw $t1, 124($t0)
	sw $t1, 128($t0)
	sw $t1, 132($t0)
	sw $t1, 136($t0)
	sw $t1, 156($t0)
	sw $t1, 160($t0)
	sw $t1, 180($t0)
	sw $t1, 184($t0)
	sw $t1, 192($t0)
	sw $t1, 196($t0)
	sw $t1, 204($t0)
	sw $t1, 208($t0)
	sw $t1, 228($t0)
	sw $t1, 232($t0)
	sw $t1, 236($t0)
	sw $t1, 240($t0)
	#4
	li $t1, 0x00ffeeb4
	addi $t0, $t0, 256
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	sw $t1, 24($t0)
	sw $t1, 28($t0)
	sw $t1, 60($t0)
	sw $t1, 64($t0)
	sw $t1, 76($t0)
	sw $t1, 80($t0)
	sw $t1, 100($t0)
	sw $t1, 104($t0)
	sw $t1, 112($t0)
	sw $t1, 116($t0)
	sw $t1, 124($t0)
	sw $t1, 128($t0)
	sw $t1, 156($t0)
	sw $t1, 160($t0)
	sw $t1, 180($t0)
	sw $t1, 184($t0)
	sw $t1, 192($t0)
	sw $t1, 196($t0)
	sw $t1, 204($t0)
	sw $t1, 208($t0)
	sw $t1, 228($t0)
	sw $t1, 232($t0)
	sw $t1, 240($t0)
	sw $t1, 244($t0)
	#5
	li $t1, 0x00ffe4e1
	addi $t0, $t0, 256
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	sw $t1, 24($t0)
	sw $t1, 28($t0)
	sw $t1, 60($t0)
	sw $t1, 64($t0)
	sw $t1, 76($t0)
	sw $t1, 80($t0)
	sw $t1, 100($t0)
	sw $t1, 104($t0)
	sw $t1, 112($t0)
	sw $t1, 116($t0)
	sw $t1, 124($t0)
	sw $t1, 128($t0)
	sw $t1, 156($t0)
	sw $t1, 160($t0)
	sw $t1, 180($t0)
	sw $t1, 184($t0)
	sw $t1, 192($t0)
	sw $t1, 196($t0)
	sw $t1, 204($t0)
	sw $t1, 208($t0)
	sw $t1, 228($t0)
	sw $t1, 232($t0)
	sw $t1, 240($t0)
	sw $t1, 244($t0)
	#6
	li $t1, 0x00fbf3f6
	addi $t0, $t0, 256
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	sw $t1, 24($t0)
	sw $t1, 28($t0)
	sw $t1, 36($t0)
	sw $t1, 40($t0)
	sw $t1, 48($t0)
	sw $t1, 52($t0)
	sw $t1, 60($t0)
	sw $t1, 64($t0)
	sw $t1, 76($t0)
	sw $t1, 80($t0)
	sw $t1, 100($t0)
	sw $t1, 104($t0)
	sw $t1, 112($t0)
	sw $t1, 116($t0)
	sw $t1, 124($t0)
	sw $t1, 128($t0)
	sw $t1, 156($t0)
	sw $t1, 160($t0)
	sw $t1, 180($t0)
	sw $t1, 184($t0)
	sw $t1, 192($t0)
	sw $t1, 196($t0)
	sw $t1, 204($t0)
	sw $t1, 208($t0)
	sw $t1, 216($t0)
	sw $t1, 220($t0)
	sw $t1, 228($t0)
	sw $t1, 232($t0)
	sw $t1, 240($t0)
	sw $t1, 244($t0)
	#7
	li $t1, 0x00ffffff
	addi $t0, $t0, 256
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	sw $t1, 12($t0)
	sw $t1, 24($t0)
	sw $t1, 28($t0)
	sw $t1, 32($t0)
	sw $t1, 36($t0)
	sw $t1, 40($t0)
	sw $t1, 48($t0)
	sw $t1, 52($t0)
	sw $t1, 56($t0)
	sw $t1, 60($t0)
	sw $t1, 64($t0)
	sw $t1, 76($t0)
	sw $t1, 80($t0)
	sw $t1, 100($t0)
	sw $t1, 104($t0)
	sw $t1, 108($t0)
	sw $t1, 112($t0)
	sw $t1, 116($t0)
	sw $t1, 124($t0)
	sw $t1, 128($t0)
	sw $t1, 156($t0)
	sw $t1, 160($t0)
	sw $t1, 164($t0)
	sw $t1, 168($t0)
	sw $t1, 172($t0)
	sw $t1, 180($t0)
	sw $t1, 184($t0)
	sw $t1, 188($t0)
	sw $t1, 192($t0)
	sw $t1, 196($t0)
	sw $t1, 204($t0)
	sw $t1, 208($t0)
	sw $t1, 212($t0)
	sw $t1, 216($t0)
	sw $t1, 220($t0)
	sw $t1, 228($t0)
	sw $t1, 232($t0)
	sw $t1, 240($t0)
	sw $t1, 244($t0)
	# draw carrot:
	li $t0, base_address
	addi $t0, $t0, 16664
	
	li $t1, lime
	sw $t1, 0($t0)
	sw $t1, 256($t0)
	li $t1, limegreen
	sw $t1, 260($t0)
	li $t1, forestgreen
	sw $t1, 512($t0)
	sw $t1, 516($t0)
	sw $t1, 520($t0)
	li $t1,	wordcolor 
	sw $t1, 1032($t0)
	sw $t1, 1544($t0)
	
	li $t1, orange2
	sw $t1, 504($t0)
	sw $t1, 508($t0)
	sw $t1, 756($t0)
	sw $t1, 1008($t0)
	sw $t1, 1260($t0)
	li $t1, darkorange
	sw $t1, 760($t0)
	sw $t1, 764($t0)
	sw $t1, 1012($t0)
	sw $t1, 1016($t0)
	sw $t1, 1264($t0)
	li $t1, tomato
	sw $t1, 768($t0)
	sw $t1, 1020($t0)
	sw $t1, 1024($t0)
	sw $t1, 1268($t0)
	sw $t1, 1272($t0)
	sw $t1, 1516($t0)
	sw $t1, 1520($t0)
	
	#draw zeros
	li $a0, 40
	jal erase_num
	jal draw_0
	li $a0, 64
	jal erase_num
	jal draw_0
	li $a0, 116
	jal erase_num
	jal draw_0
	li $a0, 140
	jal erase_num
	jal draw_0
	#draw enemy
	li $t0, base_address
	addi $t0, $t0,16988
	li $t1, orange
	sw $t1, 0($t0)
	sw $t1, 12($t0)
	li $t1, yellow
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	li $t1, maroon
	#1
	sw $t1, 252($t0)
	sw $t1, 256($t0)
	sw $t1, 260($t0)
	sw $t1, 264($t0)
	sw $t1, 268($t0)
	sw $t1, 272($t0)
	#3
	sw $t1, 764($t0)
	sw $t1, 772($t0)
	sw $t1, 776($t0)
	sw $t1, 784($t0)
	#4
	sw $t1, 1020($t0)
	sw $t1, 1024($t0)
	sw $t1, 1028($t0)
	sw $t1, 1032($t0)
	sw $t1, 1036($t0)
	sw $t1, 1040($t0)
	#5
	sw $t1, 1276($t0)
	sw $t1, 1280($t0)
	sw $t1, 1292($t0)
	sw $t1, 1296($t0)
	li $t1, sienna
	sw $t1, 512($t0)
	sw $t1, 524($t0)
	li $t1, orangered
	sw $t1, 768($t0)
	sw $t1, 780($t0)
	sw $t1, 1284($t0)
	sw $t1, 1288($t0)

	li $t1, maroon
	sw $t1, 508($t0)
	sw $t1, 520($t0)
	li $t1, sienna
	sw $t1, 516($t0)
	sw $t1, 528($t0)
	#draw words
	li $t1, black
	addi $t0, $zero, base_address
	addi $t0, $t0, 5120
	
	#0
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	sw $t1, 24($t0)
	sw $t1, 28($t0)
	sw $t1, 32($t0)
	sw $t1, 36($t0)
	sw $t1, 40($t0)
	sw $t1, 48($t0)
	sw $t1, 52($t0)
	sw $t1, 68($t0)
	sw $t1, 72($t0)
	
	sw $t1, 80($t0)
	sw $t1, 84($t0)
	sw $t1, 88($t0)
	sw $t1, 92($t0)
	sw $t1, 96($t0)

	sw $t1, 104($t0)
	sw $t1, 108($t0)
	sw $t1, 112($t0)
	sw $t1, 116($t0)

	sw $t1, 124($t0)
	sw $t1, 128($t0)
	sw $t1, 132($t0)
	sw $t1, 136($t0)
	sw $t1, 140($t0)

	sw $t1, 148($t0)
	sw $t1, 152($t0)
	sw $t1, 156($t0)
	sw $t1, 160($t0)
	sw $t1, 164($t0)



	sw $t1, 180($t0)
	sw $t1, 184($t0)
	sw $t1, 188($t0)
	sw $t1, 192($t0)
	sw $t1, 196($t0)

	sw $t1, 204($t0)
	sw $t1, 208($t0)

	sw $t1, 216($t0)
	sw $t1, 220($t0)

	sw $t1, 228($t0)
	sw $t1, 232($t0)
	
	sw $t1, 244($t0)
	sw $t1, 248($t0)
	addi $t0, $t0, 256
	#1
	sw $t1, 0($t0)
	sw $t1, 4($t0)

	sw $t1, 12($t0)
	sw $t1, 16($t0)

	sw $t1, 24($t0)
	sw $t1, 28($t0)

	sw $t1, 36($t0)
	sw $t1, 40($t0)

	sw $t1, 48($t0)
	sw $t1, 52($t0)
	sw $t1, 56($t0)

	sw $t1, 64($t0)
	sw $t1, 68($t0)
	sw $t1, 72($t0)

	sw $t1, 80($t0)
	sw $t1, 84($t0)

	sw $t1, 92($t0)
	sw $t1, 96($t0)
	
	sw $t1, 108($t0)
	sw $t1, 112($t0)
	
	sw $t1, 124($t0)
	sw $t1, 128($t0)
	
	sw $t1, 136($t0)
	sw $t1, 140($t0)
	
	sw $t1, 148($t0)
	sw $t1, 152($t0)
	
	sw $t1, 160($t0)
	sw $t1, 164($t0)
	
	sw $t1, 180($t0)
	sw $t1, 184($t0)
	
	sw $t1, 192($t0)
	sw $t1, 196($t0)
	
	sw $t1, 204($t0)
	sw $t1, 208($t0)
	
	sw $t1, 216($t0)
	sw $t1, 220($t0)
	
	sw $t1, 228($t0)
	sw $t1, 232($t0)
	sw $t1, 236($t0)
	
	sw $t1, 244($t0)
	sw $t1, 248($t0)
	addi $t0, $t0, 256
	#2
	sw $t1, 0($t0)
	sw $t1, 4($t0)

	sw $t1, 12($t0)
	sw $t1, 16($t0)
	
	sw $t1, 24($t0)
	sw $t1, 28($t0)
	
	sw $t1, 36($t0)
	sw $t1, 40($t0)
	
	sw $t1, 48($t0)
	sw $t1, 52($t0)
	sw $t1, 56($t0)
	sw $t1, 60($t0)
	sw $t1, 64($t0)
	sw $t1, 68($t0)
	sw $t1, 72($t0)
	
	sw $t1, 80($t0)
	sw $t1, 84($t0)
	
	sw $t1, 108($t0)
	sw $t1, 112($t0)
	
	sw $t1, 124($t0)
	sw $t1, 128($t0)
	
	sw $t1, 148($t0)
	sw $t1, 152($t0)

	sw $t1, 160($t0)
	sw $t1, 164($t0)
	
	sw $t1, 180($t0)
	sw $t1, 184($t0)
	
	sw $t1, 192($t0)
	sw $t1, 196($t0)
	
	sw $t1, 204($t0)
	sw $t1, 208($t0)
	
	sw $t1, 216($t0)
	sw $t1, 220($t0)
	
	sw $t1, 228($t0)
	sw $t1, 232($t0)
	sw $t1, 236($t0)
	sw $t1, 240($t0)
	sw $t1, 244($t0)
	sw $t1, 248($t0)
	addi $t0, $t0,256
	#3
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	
	sw $t1, 24($t0)
	sw $t1, 28($t0)
	sw $t1, 32($t0)
	sw $t1, 36($t0)
	sw $t1, 40($t0)
	
	sw $t1, 48($t0)
	sw $t1, 52($t0)
	
	sw $t1, 60($t0)
	
	sw $t1, 68($t0)
	sw $t1, 72($t0)
	
	sw $t1, 84($t0)
	sw $t1, 88($t0)
	sw $t1, 92($t0)
	
	sw $t1, 108($t0)
	sw $t1, 112($t0)
	
	sw $t1, 124($t0)
	sw $t1, 128($t0)
	sw $t1, 132($t0)
	sw $t1, 136($t0)
	
	sw $t1, 148($t0)
	sw $t1, 152($t0)
	sw $t1, 156($t0)
	sw $t1, 160($t0)
	
	sw $t1, 180($t0)
	sw $t1, 184($t0)
	sw $t1, 188($t0)
	sw $t1, 192($t0)
	
	sw $t1, 204($t0)
	sw $t1, 208($t0)
	
	sw $t1, 216($t0)
	sw $t1, 220($t0)
	
	sw $t1, 228($t0)
	sw $t1, 232($t0)
	
	sw $t1, 240($t0)
	sw $t1, 244($t0)
	sw $t1, 248($t0)
	addi $t0, $t0, 256
	#4
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	
	sw $t1, 24($t0)
	sw $t1, 28($t0)
	
	sw $t1, 36($t0)
	sw $t1, 40($t0)
	
	sw $t1, 48($t0)
	sw $t1, 52($t0)
	
	sw $t1, 68($t0)
	sw $t1, 72($t0)
	
	sw $t1, 92($t0)
	sw $t1, 96($t0)
	
	sw $t1, 108($t0)
	sw $t1, 112($t0)
	
	sw $t1, 124($t0)
	sw $t1, 128($t0)
	
	sw $t1, 148($t0)
	sw $t1, 152($t0)
	
	sw $t1, 160($t0)
	sw $t1, 164($t0)
	
	sw $t1, 180($t0)
	sw $t1, 184($t0)
	
	sw $t1, 192($t0)
	sw $t1, 196($t0)
	
	sw $t1, 204($t0)
	sw $t1, 208($t0)
	
	sw $t1, 216($t0)
	sw $t1, 220($t0)
	
	sw $t1, 228($t0)
	sw $t1, 232($t0)
	
	sw $t1, 244($t0)
	sw $t1, 248($t0)
	
	addi $t0, $t0, 256
	#5
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	
	sw $t1, 24($t0)
	sw $t1, 28($t0)
	
	sw $t1, 36($t0)
	sw $t1, 40($t0)
	
	sw $t1, 48($t0)
	sw $t1, 52($t0)
	
	sw $t1, 68($t0)
	sw $t1, 72($t0)
	
	sw $t1, 92($t0)
	sw $t1, 96($t0)
	
	sw $t1, 108($t0)
	sw $t1, 112($t0)
	
	sw $t1, 124($t0)
	sw $t1, 128($t0)
	
	sw $t1, 148($t0)
	sw $t1, 152($t0)
	
	sw $t1, 160($t0)
	sw $t1, 164($t0)
	
	sw $t1, 180($t0)
	sw $t1, 184($t0)
	
	sw $t1, 192($t0)
	sw $t1, 196($t0)
	
	sw $t1, 204($t0)
	sw $t1, 208($t0)
	
	sw $t1, 216($t0)
	sw $t1, 220($t0)
	
	sw $t1, 228($t0)
	sw $t1, 232($t0)
	
	sw $t1, 244($t0)
	sw $t1, 248($t0)
	
	addi $t0, $t0, 256
	#6
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	
	sw $t1, 24($t0)
	sw $t1, 28($t0)
	
	sw $t1, 36($t0)
	sw $t1, 40($t0)
	
	sw $t1, 48($t0)
	sw $t1, 52($t0)
	
	sw $t1, 68($t0)
	sw $t1, 72($t0)
	sw $t1, 80($t0)
	sw $t1, 84($t0)
	sw $t1, 92($t0)
	sw $t1, 96($t0)
	
	sw $t1, 108($t0)
	sw $t1, 112($t0)
	
	sw $t1, 124($t0)
	sw $t1, 128($t0)
	sw $t1, 136($t0)
	sw $t1, 140($t0)
	sw $t1, 148($t0)
	sw $t1, 152($t0)
	
	sw $t1, 160($t0)
	sw $t1, 164($t0)
	
	sw $t1, 180($t0)
	sw $t1, 184($t0)
	
	sw $t1, 192($t0)
	sw $t1, 196($t0)
	
	sw $t1, 204($t0)
	sw $t1, 208($t0)
	
	sw $t1, 216($t0)
	sw $t1, 220($t0)
	
	sw $t1, 228($t0)
	sw $t1, 232($t0)
	
	sw $t1, 244($t0)
	sw $t1, 248($t0)
	addi $t0, $t0, 256
	#7
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	sw $t1, 24($t0)
	sw $t1, 28($t0)
	sw $t1, 32($t0)
	sw $t1, 36($t0)
	sw $t1, 40($t0)
	sw $t1, 48($t0)
	sw $t1, 52($t0)
	sw $t1, 68($t0)
	sw $t1, 72($t0)
	
	sw $t1, 80($t0)
	sw $t1, 84($t0)
	sw $t1, 88($t0)
	sw $t1, 92($t0)
	sw $t1, 96($t0)

	
	sw $t1, 108($t0)
	sw $t1, 112($t0)
	

	sw $t1, 124($t0)
	sw $t1, 128($t0)
	sw $t1, 132($t0)
	sw $t1, 136($t0)
	sw $t1, 140($t0)

	sw $t1, 148($t0)
	sw $t1, 152($t0)
	
	sw $t1, 160($t0)
	sw $t1, 164($t0)



	sw $t1, 180($t0)
	sw $t1, 184($t0)
	
	sw $t1, 192($t0)
	sw $t1, 196($t0)

	sw $t1, 204($t0)
	sw $t1, 208($t0)
	sw $t1, 212($t0)
	sw $t1, 216($t0)
	sw $t1, 220($t0)

	sw $t1, 228($t0)
	sw $t1, 232($t0)
	
	sw $t1, 244($t0)
	sw $t1, 248($t0)
	#start, quit
	#!!! set $t0
	#0
	addi $t0, $t0, 1080
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	sw $t1, 20($t0)
	sw $t1, 24($t0)
	sw $t1, 28($t0)
	
	sw $t1, 52($t0)
	sw $t1, 56($t0)
	sw $t1, 60($t0)
	sw $t1, 64($t0)
	
	sw $t1, 72($t0)
	sw $t1, 76($t0)
	sw $t1, 80($t0)
	sw $t1, 84($t0)
	sw $t1, 88($t0)
	
	sw $t1, 96($t0)
	sw $t1, 100($t0)
	sw $t1, 104($t0)
	sw $t1, 108($t0)
	sw $t1, 112($t0)
	
	sw $t1, 120($t0)
	sw $t1, 124($t0)
	sw $t1, 128($t0)
	sw $t1, 132($t0)
	
	#1
	addi $t0, $t0, 256
	sw $t1, 0($t0)
	
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	
	sw $t1, 24($t0)
	sw $t1, 28($t0)
	
	sw $t1, 40($t0)
	
	sw $t1, 56($t0)
	sw $t1, 60($t0)
	
	sw $t1, 72($t0)
	sw $t1, 76($t0)
	
	sw $t1, 84($t0)
	sw $t1, 88($t0)
	
	sw $t1, 96($t0)
	sw $t1, 100($t0)
	
	sw $t1, 108($t0)
	sw $t1, 112($t0)
	
	sw $t1, 124($t0)
	sw $t1, 128($t0)
	
	
	#2
	addi $t0, $t0, 256
	sw $t1, 0($t0)
	
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	
	sw $t1, 40($t0)
	
	sw $t1, 56($t0)
	sw $t1, 60($t0)
	
	sw $t1, 72($t0)
	sw $t1, 76($t0)
	
	sw $t1, 84($t0)
	sw $t1, 88($t0)
	
	sw $t1, 96($t0)
	sw $t1, 100($t0)
	
	sw $t1, 108($t0)
	sw $t1, 112($t0)
	
	sw $t1, 124($t0)
	sw $t1, 128($t0)

	
	#3
	addi $t0, $t0, 256
	
	sw $t1, 16($t0)
	sw $t1, 20($t0)
	sw $t1, 24($t0)
	
	sw $t1, 56($t0)
	sw $t1, 60($t0)
	
	sw $t1, 72($t0)
	sw $t1, 76($t0)
	sw $t1, 80($t0)
	sw $t1, 84($t0)
	sw $t1, 88($t0)
	
	sw $t1, 96($t0)
	sw $t1, 100($t0)
	sw $t1, 104($t0)
	sw $t1, 108($t0)
	
	sw $t1, 124($t0)
	sw $t1, 128($t0)

	
	#4
	addi $t0, $t0, 256
	
	sw $t1, 24($t0)
	sw $t1, 28($t0)
	
	sw $t1, 56($t0)
	sw $t1, 60($t0)
	
	sw $t1, 72($t0)
	sw $t1, 76($t0)
	
	sw $t1, 84($t0)
	sw $t1, 88($t0)
	
	sw $t1, 96($t0)
	sw $t1, 100($t0)
	
	sw $t1, 108($t0)
	sw $t1, 112($t0)
	
	sw $t1, 124($t0)
	sw $t1, 128($t0)

	
	#5
	addi $t0, $t0, 256
	sw $t1, 24($t0)
	sw $t1, 28($t0)
	
	sw $t1, 56($t0)
	sw $t1, 60($t0)
	
	sw $t1, 72($t0)
	sw $t1, 76($t0)
	
	sw $t1, 84($t0)
	sw $t1, 88($t0)
	
	sw $t1, 96($t0)
	sw $t1, 100($t0)
	
	sw $t1, 108($t0)
	sw $t1, 112($t0)
	
	sw $t1, 124($t0)
	sw $t1, 128($t0)
	#6
	addi $t0, $t0, 256
		
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	
	sw $t1, 24($t0)
	sw $t1, 28($t0)
	
	sw $t1, 56($t0)
	sw $t1, 60($t0)
	
	sw $t1, 72($t0)
	sw $t1, 76($t0)
	
	sw $t1, 84($t0)
	sw $t1, 88($t0)
	
	sw $t1, 96($t0)
	sw $t1, 100($t0)
	
	sw $t1, 108($t0)
	sw $t1, 112($t0)
	
	
	sw $t1, 124($t0)
	sw $t1, 128($t0)

	
	#7
	addi $t0, $t0, 256
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	sw $t1, 20($t0)
	sw $t1, 24($t0)
	sw $t1, 28($t0)
	
	sw $t1, 56($t0)
	sw $t1, 60($t0)
	
	sw $t1, 72($t0)
	sw $t1, 76($t0)
	
	sw $t1, 84($t0)
	sw $t1, 88($t0)
	
	sw $t1, 96($t0)
	sw $t1, 100($t0)
	
	sw $t1, 108($t0)
	sw $t1, 112($t0)
	
	
	sw $t1, 124($t0)
	sw $t1, 128($t0)
	#8
	addi $t0, $t0, 256
	#9
	addi $t0, $t0, 256
	
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	sw $t1, 20($t0)
	sw $t1, 24($t0)
	sw $t1, 28($t0)
	
	sw $t1, 56($t0)
	sw $t1, 60($t0)
	
	sw $t1, 68($t0)
	sw $t1, 72($t0)
	sw $t1, 80($t0)
	sw $t1, 84($t0)
	sw $t1, 88($t0)
	sw $t1, 92($t0)
	sw $t1, 100($t0)
	sw $t1, 104($t0)
	sw $t1, 108($t0)
	sw $t1, 112($t0)
	
	#10
	addi $t0, $t0, 256
	sw $t1, 0($t0)
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	
	sw $t1, 24($t0)
	sw $t1, 28($t0)
	
	sw $t1, 44($t0)
	sw $t1, 56($t0)
	sw $t1, 60($t0)
	
	sw $t1, 68($t0)
	sw $t1, 72($t0)
	
	sw $t1, 84($t0)
	sw $t1, 88($t0)
	
	sw $t1, 104($t0)
	sw $t1, 108($t0)
	
	
	#11
	addi $t0, $t0, 256
	sw $t1, 0($t0)
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	
	sw $t1, 24($t0)
	sw $t1, 28($t0)
	
	sw $t1, 44($t0)
	sw $t1, 56($t0)
	sw $t1, 60($t0)
	
	sw $t1, 68($t0)
	sw $t1, 72($t0)
	
	sw $t1, 84($t0)
	sw $t1, 88($t0)
	
	sw $t1, 104($t0)
	sw $t1, 108($t0)
	
	
	#12
	addi $t0, $t0, 256
	
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	
	sw $t1, 24($t0)
	sw $t1, 28($t0)
	
	sw $t1, 56($t0)
	sw $t1, 60($t0)
	
	sw $t1, 68($t0)
	sw $t1, 72($t0)
	
	sw $t1, 84($t0)
	sw $t1, 88($t0)
	
	sw $t1, 104($t0)
	sw $t1, 108($t0)
	
	
	#13
	addi $t0, $t0, 256
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	
	sw $t1, 24($t0)
	sw $t1, 28($t0)
	
	sw $t1, 56($t0)
	sw $t1, 60($t0)
	
	sw $t1, 68($t0)
	sw $t1, 72($t0)
	
	sw $t1, 84($t0)
	sw $t1, 88($t0)
	
	sw $t1, 104($t0)
	sw $t1, 108($t0)
	
	#14
	addi $t0, $t0, 256
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	
	sw $t1, 24($t0)
	sw $t1, 28($t0)
	
	sw $t1, 56($t0)
	sw $t1, 60($t0)
	
	sw $t1, 68($t0)
	sw $t1, 72($t0)
	
	sw $t1, 84($t0)
	sw $t1, 88($t0)
	
	sw $t1, 104($t0)
	sw $t1, 108($t0)
	
	#15
	addi $t0, $t0, 256
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	
	sw $t1, 24($t0)
	sw $t1, 28($t0)
	sw $t1, 32($t0)
	sw $t1, 56($t0)
	sw $t1, 60($t0)
	
	sw $t1, 68($t0)
	sw $t1, 72($t0)
	
	sw $t1, 84($t0)
	sw $t1, 88($t0)
	
	sw $t1, 104($t0)
	sw $t1, 108($t0)
	
	#16
	addi $t0, $t0, 256
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	sw $t1, 20($t0)
	sw $t1, 24($t0)
	sw $t1, 28($t0)
	
	sw $t1, 56($t0)
	sw $t1, 60($t0)
	sw $t1, 64($t0)
	sw $t1, 68($t0)
	sw $t1, 72($t0)
	sw $t1, 80($t0)
	sw $t1, 84($t0)
	sw $t1, 88($t0)
	sw $t1, 92($t0)
	sw $t1, 104($t0)
	sw $t1, 108($t0)
	
	li $a0, 32
	jal draw_jetplane
	li $t8,51
	li $t9,55
	jal draw_hamster
	la $t0,enemy
	li $t1, 1
	sw $t1, 0($t0)
	sw $t1,4($t0)
	jal draw_enemy
	li $fp,0
	#draw bullet
	li $t1, red
	li $t0, 6460
	li $fp, 0
	#score
	jal draw_score
	jal draw_word_score
	addi $t0, $t0,base_address
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 256($t0)
	sw $t1, 260($t0)
	li $t0, 3232
	addi $t0, $t0,base_address
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 256($t0)
	sw $t1, 260($t0)
	li $t0, 12252
	addi $t0, $t0,base_address
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 256($t0)
	sw $t1, 260($t0)
	li $t0, 10260
	addi $t0, $t0,base_address
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 256($t0)
	sw $t1, 260($t0)
check_start:
	#check user input
	li $t0, 0xffff0000 	# $t0=address of 0xffff0000 
	lw $t1, 0($t0)		# $t1=whether user has input something
	
	beq $t1, 1, continue_check_start
	j check_start
continue_check_start:
	lw $t1, 4($t0)
	beq $t1, 115, setup	# press 's'
	beq $t1, 113, END_PROGRAM	# press 'q'
	j check_start
setup:
	li $a0, 40
	jal erase_num
	jal draw_0
	li $a0, 64
	jal erase_num
	jal draw_0
	li $a0, 116
	jal erase_num
	jal draw_0
	li $a0, 140
	jal erase_num
	jal draw_0
	#draw background
	li $s0, 300
	li $s1, 0
	li $s2, 0
	li $a2, 3
	li $a3, 0
	li $a0, 168
	jal draw_heart
	li $a0, 200
	jal draw_heart
	li $a0, 232
	jal draw_heart
	#initialize platLen			
	la $t0, platLen
	li $t1, 15
	sw $t1, 0($t0)
	li $t1, 20
	sw $t1, 4($t0)
	li $t1, 23
	sw $t1, 8($t0)
	li $t1, 24
	sw $t1, 12($t0)
	#initialize platX
	la $t0, platX
	li $t1, 50
	sw $t1, 0($t0)
	li $t1, 25
	sw $t1, 4($t0)
	li $t1, 40
	sw $t1, 8($t0)
	li $t1, 29
	sw $t1, 12($t0)
	#initialize platYhead
	la $t0, platYhead
	li $t1, 20
	sw $t1, 0($t0)
	li $t1, 40
	sw $t1, 4($t0)
	li $t1, 0
	sw $t1, 8($t0)
	li $t1, 60
	sw $t1, 12($t0)
	#initialize platYtail
	la $t0, platYtail
	li $t1, 34
	sw $t1, 0($t0)
	li $t1, 59
	sw $t1, 4($t0)
	li $t1, 22
	sw $t1, 8($t0)
	li $t1, 83
	sw $t1, 12($t0)
	#initialize platElement
	la $t0, platElement
	li $t1, 0
	sw $t1, 0($t0)
	li $t1, 1
	sw $t1, 4($t0)
	li $t1, 1
	sw $t1, 8($t0)
	li $t1, -1
	sw $t1, 12($t0)
	#initialize elementPosition
	la $t0, elementPosition
	li $t1, 24
	sw $t1, 0($t0)
	li $t1, 36
	sw $t1, 4($t0)
	li $t1, 20
	sw $t1, 8($t0)
	li $t1, 65
	sw $t1, 12($t0)
	#initialize bulletX
	la $t0, bulletX
	li $t1, 64
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	sw $t1, 12($t0)
	#initialize enemy
	la $t0, enemy
	li $t1, 1
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	li $fp, 0
	jal draw_score
	
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
	addi $fp, $fp, 1
	jal draw_row_64
	jal move_enemy
	jal bullet
	jal check_collision
	jal check_enemy
	
	jal move_platform	# move platform
	jal check_eat_carrot
	jal check_eat_nut
	# get input from user
	# check if user has input something
	li $t0, 0xffff0000 	# $t0=address of 0xffff0000 
	lw $t1, 0($t0)		# $t1=whether user has input something
	
	beq $t1, 1, keypress_happened # if user input something, branch to keypress_happened and respond accordingly
	li $s2, 0 		# if user do not input something, make jump to be unsuccessful
	# we are here, now need to check collision and add gravity
sleep:	#jal check_collision
	jal gravity_hamster
	jal check_hit_enemy
	jal draw_score
	addi $v0, $zero, 32		# syscall sleep
	add $a0, $zero, $s0
	
	syscall
	blt $s0, 60, gameloop
	li $v0, 42
	li $a1, 5
	beq $a0,0,decrement_sleep
	j gameloop
decrement_sleep:
	addi $s0, $s0, -3		# decrement sleepTime	
	j gameloop
		
	
keypress_happened:
	lw $t2, 4($t0)		# $t2=user input
	beq $t2, 97, a_2		# if input='a', branch to a
	beq $t2, 100, d_2		# if input='d', branch to d
	beq $t2, 119, w_2	# if input='w', branch to w_2
	beq $t2, 112, menu	# if input='p', branch to set_u
	beq $t2, 113, END_PROGRAM
	j sleep
	
a_2:
	li $s2, 0	# let $s2 to be not successful
	# if $t9<3, can not move left twice, branch to a_1
	ble $t9, 3, a_1
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
	beq $t6, black, a_1
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
	# if $t9>55 can not move right once
	bgt $t9, 55, sleep
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
	bge $s1, 4, continue_check_w_2
	j continue_w_2
continue_check_w_2:
	beq $a3,0, sleep
	addi $a3, $a3, -1
	jal draw_carrot_num
	li $s1,0	
continue_w_2:
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
	# $s5=left boundary
	# $s6=right boundary
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
	sll $s5, $t6, 8
	addi $s5, $s5, base_address
	addi $s5, $s5, 512
	addi $s6, $s5, 252
inner_loop_w2:	
	# if base_address+$t6*256<=$s3<=base_address+$t6*256+63*4, should check
	# otherwise, increment $t1 and do inner loop
	blt $s3, $s5, next_inner_loop_w2
	bgt $s3, $s6, next_inner_loop_w2
	lw $s4, 0($s3)
	# if 2 units below is hamster color, branch to w_1
	beq $s4, black, w_1
	beq $s4, gold, w_1
	beq $s4, oldlace, w_1
	beq $s4, moccasin, w_1
	beq $s4, tan, w_1
	
	# else, increment $t1 and do inner loop
next_inner_loop_w2:
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
	# if jumped half times, then need to continue jumping no matter what user input
	andi $t0, $s1, 1
	beq $t0, 1, continue_jump2
	j sleep
continue_jump2:
	addi $v0, $zero, 32		# syscall sleep
	add $a0, $zero, 2
	syscall
	j w_2
	
						
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
	sll $s5, $t6, 8
	addi $s5, $s5, base_address
	addi $s5, $s5, 256
	addi $s6, $s5, 252
inner_loop_w1:	
	# if base_address+$t6*256<=$s3<=base_address+$t6*256+63*4, should check
	# otherwise, increment $t1 and do inner loop
	blt $s3, $s5, next_inner_loop_w1
	bgt $s3, $s6, next_inner_loop_w1
	lw $s4, 0($s3)
	# if 1 unit below is hamster color, branch to no_jump
	beq $s4, black, no_jump
	beq $s4, gold, no_jump
	beq $s4, oldlace, no_jump
	beq $s4, moccasin, no_jump
	beq $s4, tan, no_jump
	# else, increment $t1 and do inner loop
next_inner_loop_w1:
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
	# if jumped half times, then need to continue jumping no matter what user input
	andi $t0, $s1, 1
	beq $t0, 1, continue_jump1
	j sleep
continue_jump1:
	addi $v0, $zero, 32		# syscall sleep
	add $a0, $zero, 2
	syscall
	j w_2
	
	
no_jump:
	addi $s1, $s1, 1	# increment $s1 number of jumps by 1
	li $s2, 0		# jump is not successful, so $s2=0
	j sleep

gravity_hamster:
	#If hamster is jumping, i.e. 1<=$s1<=4, and $s2=1, no gravity for hamster
	blt $s1, 1, do_gravity_hamster
	bgt $s1, 4, do_gravity_hamster
	bne $s2, 1, do_gravity_hamster
	
	# 1<=$s1<=4 and $s2=1, can skip do_gravity
	# but if $s1=4, let $s2=0, then next time need to do gravity
	beq $s1,4, set_s2_gravity
	j skip_gravity
set_s2_gravity:
	li $s2, 0	
skip_gravity:
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
	beq $t1, orange, restore_gravity_hamster_s1
	beq $t1, yellow, restore_gravity_hamster_s1
	lw $t1, 3328($t0)
	beq $t1, green, restore_gravity_hamster_s1
	beq $t1, orange, restore_gravity_hamster_s1
	beq $t1, yellow, restore_gravity_hamster_s1
	lw $t1, 3332($t0)
	beq $t1, green, restore_gravity_hamster_s1
	beq $t1, orange, restore_gravity_hamster_s1
	beq $t1, yellow, restore_gravity_hamster_s1
	lw $t1, 3336($t0)
	beq $t1, green, restore_gravity_hamster_s1
	beq $t1, orange, restore_gravity_hamster_s1
	beq $t1, yellow, restore_gravity_hamster_s1
	lw $t1, 3340($t0)
	beq $t1, green, restore_gravity_hamster_s1
	beq $t1, orange, restore_gravity_hamster_s1
	beq $t1, yellow, restore_gravity_hamster_s1
	lw $t1, 3344($t0)
	beq $t1, green, restore_gravity_hamster_s1
	beq $t1, orange, restore_gravity_hamster_s1
	beq $t1, yellow, restore_gravity_hamster_s1
	lw $t1, 3348($t0)
	beq $t1, green, restore_gravity_hamster_s1
	beq $t1, orange, restore_gravity_hamster_s1
	beq $t1, yellow, restore_gravity_hamster_s1
	lw $t1, 3352($t0)
	beq $t1, green, restore_gravity_hamster_s1
	beq $t1, orange, restore_gravity_hamster_s1
	beq $t1, yellow, restore_gravity_hamster_s1
	lw $t1, 3356($t0)
	beq $t1, green, restore_gravity_hamster_s1
	beq $t1, orange, restore_gravity_hamster_s1
	beq $t1, yellow, restore_gravity_hamster_s1
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
	beq $t1, orange, restore_gravity_hamster_s1
	beq $t1, yellow, restore_gravity_hamster_s1
	lw $t1, 3328($t0)
	beq $t1, green, restore_gravity_hamster_s1
	beq $t1, orange, restore_gravity_hamster_s1
	beq $t1, yellow, restore_gravity_hamster_s1
	lw $t1, 3332($t0)
	beq $t1, green, restore_gravity_hamster_s1
	beq $t1, orange, restore_gravity_hamster_s1
	beq $t1, yellow, restore_gravity_hamster_s1
	lw $t1, 3336($t0)
	beq $t1, green, restore_gravity_hamster_s1
	beq $t1, orange, restore_gravity_hamster_s1
	beq $t1, yellow, restore_gravity_hamster_s1
	lw $t1, 3340($t0)
	beq $t1, green, restore_gravity_hamster_s1
	beq $t1, orange, restore_gravity_hamster_s1
	beq $t1, yellow, restore_gravity_hamster_s1
	lw $t1, 3344($t0)
	beq $t1, green, restore_gravity_hamster_s1
	beq $t1, orange, restore_gravity_hamster_s1
	beq $t1, yellow, restore_gravity_hamster_s1
	lw $t1, 3348($t0)
	beq $t1, green, restore_gravity_hamster_s1
	beq $t1, orange, restore_gravity_hamster_s1
	beq $t1, yellow, restore_gravity_hamster_s1
	lw $t1, 3352($t0)
	beq $t1, green, restore_gravity_hamster_s1
	beq $t1, orange, restore_gravity_hamster_s1
	beq $t1, yellow, restore_gravity_hamster_s1
	lw $t1, 3356($t0)
	beq $t1, green, restore_gravity_hamster_s1
	beq $t1, orange, restore_gravity_hamster_s1
	beq $t1, yellow, restore_gravity_hamster_s1
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
	addi $t0, $t0, -256
	addi $t0, $t0, base_address
	li $t1, darkgreen
	
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
	addi $sp, $sp, -56
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
	sw $s5, 40($sp)
	sw $s6, 44($sp)
	sw $a0, 48($sp)
	sw $ra, 52($sp)
	
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
	#$s5=address of platElement
	#$s6=platElement[$t2]
	li $t0, base_address 	# $t0=the base address for display
	add $t1, $zero, $a0		# $t1=color of character
	li $t2, 0		# $t2 is iteration number
	la $t3, platX		# $t3=address of platX array
	la $t4, platYhead		# $t4=address of platYhead array
	la $t5, platYtail	# $t5=address of platYtail array
	la $s5, platElement	# $s5=address pf platElement
	#convert (x,y) to position in display and store in $t9
	#s3=x*256, $s4=y*4, $s4=$s3+$s4+base_address
loopPlatXY:	
	lw $s6, 0($s5)
	beq $s6, 0, d_nut
	beq $s6, 1, d_carrot
	j finished_draw_element
d_nut:	add $a0, $0, $t2
	jal draw_nut
	j finished_draw_element
d_carrot:add $a0, $0, $t2
	jal draw_carrot
	j finished_draw_element
finished_draw_element:	
	lw $t6, 0($t3)		# $t6=platX[$t2]
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
	addi $t3, $t3, 4	# update memory address of element in platX
	addi $t4, $t4, 4	# update memory address of element in platYhead
	addi $t5, $t5, 4	# update memory address of element in platYtail
	addi $s5, $s5, 4	# update memory address of element in platElement
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
	lw $s5, 40($sp)
	lw $s6, 44($sp)
	lw $a0, 48($sp)
	lw $ra, 52($sp)
	addi $sp, $sp, 56
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
	addi $sp, $sp, -80
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
	sw $a2, 64($sp)
	sw $a3, 68($sp)
	sw $s0, 72($sp)
	sw $v1, 76($sp)
	
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
	#$a2=address of platElement
	#$s0=address of elementPosition
	#$a3=platElement[$t0]
	
	li $s2,skyblue		# $s2=skyblue
	li $s3, green		# $s3=green
	li $t0,0		# $t0=iteration
	la $t1, platLen		# $t1=address of platXLen array
	la $t2, platX		# $t2=address of platX array
	la $t3, platYhead	# $t3=address of platYhead array
	la $t4, platYtail	# $t4=address of platYtail array
	la $a2, platElement
	la $s0, elementPosition
	
loop_move_platform:
	lw $a3, 0($a2)
	beq $a3, -1, continue_loop_move
	beq $a3, 0, e_nut
	beq $a3, 1, e_carrot
	j continue_loop_move
e_nut:
	add $a0, $zero, $t0
	jal erase_nut
	j continue_loop_move
e_carrot:
	add $a0, $zero, $t0
	jal erase_carrot
	j continue_loop_move
continue_loop_move:
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
	
	
	#sw $s3, 0($s6)		# paint to green
next_platform:
	# deal with element
	# if $a3=-1, create new element
	# if $a3=0 or 1, see if need to delete it, or move the position and redraw
	beq $a3, -1, create_new_element
	beq $a3, 0, check_move_nut
	beq $a3, 1, check_move_carrot
	j continue_next_platform
check_move_nut:
	li $v0, 42
	li $a1, 10
	syscall
	beq $a0, 0, remove_element
	lw $v1, 0($s0)
	addi $v1, $v1, -1
	sw $v1, 0($s0)
	
	j continue_next_platform
remove_element:
	li $a3, -1
	sw $a3, 0($a2)
	j continue_next_platform
check_move_carrot:
	li $v0, 42
	li $a1,10
	syscall
	beq $a0, 0, remove_element
	lw $v1, 0($s0)
	addi $v1, $v1, -1
	sw $v1, 0($s0)
	
	j continue_next_platform	
create_new_element:
	li $v0, 42
	li $a1, 25
	syscall
	beq $a0, 0, create_new_nut
	beq $a0, 1, create_new_carrot
	beq $a0, 2, create_new_carrot
	j continue_next_platform
create_new_nut:
	sw $a0,0($a2)
	li $v0, 42
	addi $a1, $t5, 0
	syscall
	add $a0, $a0, $t7
	sw $a0, 0($s0)
	
	j continue_next_platform
create_new_carrot:
	sw $a0,0($a2)
	li $v0, 42
	addi $a1, $t5, 0
	syscall
	add $a0, $a0, $t7
	sw $a0, 0($s0)
	
	j continue_next_platform		
continue_next_platform:	
	addi $t0, $t0, 1	# iteration ++
	addi $t1, $t1, 4	# update memory address of element in platLen
	addi $t2, $t2, 4	# update memory address of element in platX
	addi $t3, $t3, 4	# update memory address of element in platXhead
	addi $t4, $t4, 4	# update memory address of element in platXtail
	addi $a2, $a2, 4	# update memory address of element in platElement
	addi $s0, $s0, 4
	blt $t0,platNum, loop_move_platform	# if $t0<platNum, move the next platform
	# we are here, so we have updated all platforms. go to restore_platform
	li $a0, green
	jal draw_platform
	j restore_platform
new_platform:
	#set random number for platX
	#set random number for platLen
	#set platYhead[$t0]=31
	#draw the head
	#set platElement[$t0]=-1
	li $a3, -1
	sw $a3,0($a2)
	li $v0, 42		# generate random number for platX from 0-35(inclusive)
	
	li $a1, 36
	syscall
	addi $a0, $a0,25		# $a0=random number + 25, platX between 25-60
	sw $a0, 0($t2)		# platX[$t0]=random number
	li $t7,63		# $t7=platYhead[$t0]=63
	sw $t7, 0($t3)		# platYhead[$t0]=63
	li $v0, 42		# generate random number for platLen from 0-8 (inclusive)
	li $a1, 9
	syscall
	addi $a0,$a0, 15		# $a0=random number +15, from 15-23
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
	lw $a2, 64($sp)
	lw $a3, 68($sp)
	lw $s0, 72($sp)
	lw $v1, 76($sp)
	addi $sp, $sp, 80
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
	li $a1, 10
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
restore_check_collision:	
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
die_one_life_bullet:
	# remove the bullet
	li $t6, skyblue
	sw $t6, 0($t5)
	sw $t6, 4($t5)
	sw $t6, 256($t5)
	sw $t6, 260($t5)
	li $t3,64
	sw $t3, 0($t1)
	addi $a2, $a2, -1
	#if now $a2=2, erase the third heart
	#if $a2=1, erase the second heart
	beq $a2, 2, erase_third_bullet
	beq $a2, 1, erase_second_bullet
erase_third_bullet:
	li $a0, 232
	jal erase_heart
	j continue_die_one_life_bullet
erase_second_bullet:
	li $a0, 200
	jal erase_heart
	j continue_die_one_life_bullet
continue_die_one_life_bullet:
	jal draw_red_hamster
	addi $v0, $zero, 32		# syscall sleep
	li $a0, 15
	syscall
	jal draw_hamster
	
	
	j restore_check_collision
	
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
	sw $t4, 768($t3)
	sw $t4, 780($t3)
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
	
	sw $t4, 512($t3)
	sw $t4, 524($t3)	
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
	addi $sp, $sp, -32
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $t3, 12($sp)
	sw $t4, 16($sp)
	sw $t5, 20($sp)
	sw $a0, 24($sp)
	sw $ra, 28($sp)
	# $t0=address of enemy
	# $t1=y coordinate=enemy[0]
	# $t2=right or left=enemy[1]
	# $t5=random number
	la $t0, enemy
	lw $t1, 0($t0)
	lw $t2, 4($t0)
	beq $t1, -1, new_enemy
	jal erase_enemy
	li $v0, 42
	li $a1, 3
	syscall
	addi $t5, $a0,1 # generate random speed from 1-3(inclusive)
	#decide whether go left or go right
	#if y<=3, left, keep y, change to right, change eyebrow
	#if y<=3, right, erase, y+RV, draw
	#if y>=57, left, erase, y-RV, draw
	#if y>=57, right, keep y, change to left, change eyebrow
	#else, left, y-RV, right, y+RV
	ble $t1, 3, left_most_enemy
	bge $t1, 57, right_most_enemy
	#we are here, so 1<y<59
	beq $t2, 1, middle_right
	#we are here, so move left	
middle_left:
	sub $t1, $t1, $t5
	sw $t1, 0($t0)
	jal draw_enemy
	j restore_move_enemy
middle_right:
	add $t1, $t1, $t5
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
new_enemy:
	li $v0, 42
	li $a1, 50
	syscall
	bne $a0, 0, restore_move_enemy	# if $a0!=0, do not create the enemy
	li $v0, 42
	li $a1, 53
	syscall
	addi $t5, $a0, 4	# 4<=$t5<=56
	sw $t5, 0($t0)
	li $v0, 42
	li $a1, 2
	syscall
	sw $a0, 4($t0)
	jal draw_enemy
restore_move_enemy:	
	lw $t0, 0($sp)
	lw $t1, 4($sp)
	lw $t2, 8($sp)
	lw $t3, 12($sp)
	lw $t4, 16($sp)
	lw $t5, 20($sp)
	lw $a0, 24($sp)
	lw $ra, 28($sp)
	addi $sp, $sp, 32
	jr $ra		
		
																
check_enemy:
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
	#$t0=adress of enemy
	#$t1=enemy[0]
	#$t2=enemy[1]
	#$t3=address in frame
	#$t4=color
	la $t0, enemy
	lw $t1, 0($t0)
	lw $t2, 4($t0)
	sll $t3, $t1, 2
	addi $t3, $t3, 14848
	addi $t3, $t3, base_address
	# if enemy is moving right, check right side
	beq $t2, 0, check_left_side_enemy
check_right_side_enemy:
	lw $t4, 252($t3)
	beq $t4, black, dead_by_enemy
	lw $t4, 508($t3)
	beq $t4, black, dead_by_enemy
	lw $t4, 764($t3)
	beq $t4, black, dead_by_enemy
	lw $t4, 1020($t3)
	beq $t4, black, dead_by_enemy
	lw $t4, 1276($t3)
	beq $t4, black, dead_by_enemy
	beq $t1, 59, restore_check_enemy
	
	lw $t4, 20($t3)
	beq $t4, black, dead_by_enemy
	lw $t4, 276($t3)
	beq $t4, black, dead_by_enemy
	lw $t4, 532($t3)
	beq $t4, black, dead_by_enemy
	lw $t4, 788($t3)
	beq $t4, black, dead_by_enemy
	lw $t4, 1044($t3)
	beq $t4, black, dead_by_enemy
	lw $t4, 1300($t3)
	beq $t4, black, dead_by_enemy
check_left_side_enemy:
	lw $t4, 272($t3)
	beq $t4, black, dead_by_enemy
	lw $t4, 528($t3)
	beq $t4, black, dead_by_enemy
	lw $t4, 784($t3)
	beq $t4, black, dead_by_enemy
	lw $t4, 1040($t3)
	beq $t4, black, dead_by_enemy
	lw $t4, 1296($t3)
	beq $t4, black, dead_by_enemy
	beq $t1, 1, restore_check_enemy
	
	addi $t3, $t3, -8
	lw $t4, 0($t3)
	beq $t4, black, dead_by_enemy
	addi $t3, $t3, 8
	lw $t4, 248($t3)
	beq $t4, black, dead_by_enemy
	lw $t4, 504($t3)
	beq $t4, black, dead_by_enemy
	lw $t4, 760($t3)
	beq $t4, black, dead_by_enemy
	lw $t4, 1016($t3)
	beq $t4, black, dead_by_enemy
	lw $t4, 1272($t3)
	beq $t4, black, dead_by_enemy
																																								
restore_check_enemy:																																																													
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
die_one_life_enemy:
	# erase enemy
	jal erase_enemy
	la $t0, enemy
	li $t1, -1
	sw $t1, 0($t0)
	
	addi $a2, $a2, -1
	beq $a2, 2, erase_third_enemy
	beq $a2, 1, erase_second_enemy
erase_third_enemy:
	li $a0, 232
	jal erase_heart
	j continue_die_one_life_enemy
erase_second_enemy:
	li $a0, 200
	jal erase_heart
	j continue_die_one_life_enemy
continue_die_one_life_enemy:
	jal draw_red_hamster
	addi $v0, $zero, 32		# syscall sleep
	li $a0, 15
	syscall
	jal draw_hamster
	j restore_check_enemy


check_hit_enemy:
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
	# $t0=address of hamster base
	# $t1=color
	sll $t0, $t8, 8
	add $t0, $t9, $t0
	add $t0, $t9, $t0
	add $t0, $t9, $t0
	add $t0, $t9, $t0
	addi $t0, $t0, base_address
	lw $t1, 3328($t0)
	beq $t1, yellow, kill_enemy
	beq $t1, orange, kill_enemy
	lw $t1, 3332($t0)
	beq $t1, yellow, kill_enemy
	beq $t1, orange, kill_enemy
	lw $t1, 3336($t0)
	beq $t1, yellow, kill_enemy
	beq $t1, orange, kill_enemy
	lw $t1, 3340($t0)
	beq $t1, yellow, kill_enemy
	beq $t1, orange, kill_enemy
	lw $t1, 3344($t0)
	beq $t1, yellow, kill_enemy
	beq $t1, orange, kill_enemy
	lw $t1, 3348($t0)
	beq $t1, yellow, kill_enemy
	beq $t1, orange, kill_enemy
	lw $t1, 3352($t0)
	beq $t1, yellow, kill_enemy
	beq $t1, orange, kill_enemy
	j restore_check_hit_enemy
kill_enemy:
	# $t0=address of enemy
	# $t1=-1
	addi $fp, $fp, 50
	jal erase_enemy
	la $t0, enemy
	li $t1, -1
	sw $t1, 0($t0)
	# $t0=address of kill_enemy_num
	# $t1=kill_enemy_num
	la $t0, kill_enemy_num
	lw $t1, 0($t0)
	addi $t1, $t1, 1
	add $a0, $zero, $t1
	jal draw_kill_enemy_num
	beq $t1, win, you_win
restore_check_hit_enemy:
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

draw_nut:
	addi $sp, $sp, -28
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $t3, 12($sp)
	sw $t4, 16($sp)
	sw $t5, 20($sp)
	sw $ra, 24($sp)
	# $a0=index of platform*4
	# $t0=address of platX[$a0]
	# $t1=address of elementPosition[$a0]
	# $t2=platX[$a0]-6, x position of nut
	# $t3=elementPosition[$a0]
	# $t4=address in frame
	# $t5=color
	sll $a0, $a0, 2
	la $t0, platX
	la $t1, elementPosition
	add $t0, $t0, $a0
	add $t1, $t1, $a0
	lw $t2, 0($t0)
	addi $t2, $t2, -6
	lw $t3, 0($t1)
	# if $t3<2 or $t3>61, no drawing
	blt $t3, 2, restore_draw_nut
	bgt $t3, 61, restore_draw_nut
	
	sll $t4, $t2, 8
	add $t4, $t4, $t3
	add $t4, $t4, $t3
	add $t4, $t4, $t3
	add $t4, $t4, $t3
	addi $t4, $t4, base_address
	li $t5, brown
	sw $t5, 0($t4)
	#1
	sw $t5, 248($t4)
	sw $t5, 252($t4)
	sw $t5, 256($t4)
	sw $t5, 260($t4)
	sw $t5, 264($t4)
	#2
	sw $t5, 504($t4)
	sw $t5, 520($t4)
	li $t5, burlywood
	#2
	sw $t5, 508($t4)
	sw $t5, 512($t4)
	sw $t5, 516($t4)
	#3
	sw $t5, 760($t4)
	sw $t5, 764($t4)
	sw $t5, 768($t4)
	sw $t5, 772($t4)
	sw $t5, 776($t4)
	#4
	sw $t5, 1020($t4)
	sw $t5, 1024($t4)
	sw $t5, 1028($t4)
	#5
	sw $t5, 1280($t4)
restore_draw_nut:	
	# restore registers 
	lw $t0, 0($sp)
	lw $t1, 4($sp)
	lw $t2, 8($sp)
	lw $t3, 12($sp)
	lw $t4, 16($sp)
	lw $t5, 20($sp)
	lw $ra, 24($sp)
	addi $sp, $sp, 28
	jr $ra

erase_nut:
	addi $sp, $sp, -28
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $t3, 12($sp)
	sw $t4, 16($sp)
	sw $t5, 20($sp)
	sw $ra, 24($sp)
	# $a0=index of platform*4
	# $t0=address of platX[$a0]
	# $t1=address of elementPosition[$a0]
	# $t2=platX[$a0]-6, x position of nut
	# $t3=elementPosition[$a0]
	# $t4=address in frame
	# $t5=color
	sll $a0, $a0, 2
	la $t0, platX
	la $t1, elementPosition
	add $t0, $t0, $a0
	add $t1, $t1, $a0
	lw $t2, 0($t0)
	addi $t2, $t2, -6
	lw $t3, 0($t1)
	# if $t3<2 or $t3>61, no drawing
	blt $t3, 2, restore_erase_nut
	bgt $t3, 61, restore_erase_nut
	
	sll $t4, $t2, 8
	add $t4, $t4, $t3
	add $t4, $t4, $t3
	add $t4, $t4, $t3
	add $t4, $t4, $t3
	addi $t4, $t4, base_address
	li $t5, skyblue
	sw $t5, 0($t4)
	#1
	sw $t5, 248($t4)
	sw $t5, 252($t4)
	sw $t5, 256($t4)
	sw $t5, 260($t4)
	sw $t5, 264($t4)
	#2
	sw $t5, 504($t4)
	sw $t5, 520($t4)
	
	#2
	sw $t5, 508($t4)
	sw $t5, 512($t4)
	sw $t5, 516($t4)
	#3
	sw $t5, 760($t4)
	sw $t5, 764($t4)
	sw $t5, 768($t4)
	sw $t5, 772($t4)
	sw $t5, 776($t4)
	#4
	sw $t5, 1020($t4)
	sw $t5, 1024($t4)
	sw $t5, 1028($t4)
	#5
	sw $t5, 1280($t4)
restore_erase_nut:	
	# restore registers 
	lw $t0, 0($sp)
	lw $t1, 4($sp)
	lw $t2, 8($sp)
	lw $t3, 12($sp)
	lw $t4, 16($sp)
	lw $t5, 20($sp)
	lw $ra, 24($sp)
	addi $sp, $sp, 28
	jr $ra

draw_carrot:
	addi $sp, $sp, -28
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $t3, 12($sp)
	sw $t4, 16($sp)
	sw $t5, 20($sp)
	sw $ra, 24($sp)
	#restore registers
	# $a0=index of platform*4
	# $t0=address of platX[$a0]
	# $t1=address of elementPosition[$a0]
	# $t2=platX[$a0]-7, x position of carrot
	# $t3=elementPosition[$a0]
	# $t4=address in frame
	# $t5=color
	sll $a0, $a0, 2
	la $t0, platX
	la $t1, elementPosition
	add $t0, $t0, $a0
	add $t1, $t1, $a0
	lw $t2, 0($t0)
	addi $t2, $t2, -7
	lw $t3, 0($t1)
	# if $t3<5 or $t3>61, no drawing
	blt $t3, 5, restore_draw_carrot
	bgt $t3, 61, restore_draw_carrot
	
	sll $t4, $t2, 8
	add $t4, $t4, $t3
	add $t4, $t4, $t3
	add $t4, $t4, $t3
	add $t4, $t4, $t3
	addi $t4, $t4, base_address
	li $t5, lime
	sw $t5, 0($t4)
	sw $t5, 256($t4)
	li $t5, limegreen
	sw $t5, 260($t4)
	li $t5, forestgreen
	sw $t5, 512($t4)
	sw $t5, 516($t4)
	sw $t5, 520($t4)
	li $t5, orange2
	sw $t5, 504($t4)
	sw $t5, 508($t4)
	sw $t5, 756($t4)
	sw $t5, 1008($t4)
	sw $t5, 1260($t4)
	li $t5, darkorange
	sw $t5, 760($t4)
	sw $t5, 764($t4)
	sw $t5, 1012($t4)
	sw $t5, 1016($t4)
	sw $t5, 1264($t4)
	li $t5, tomato
	sw $t5, 768($t4)
	sw $t5, 1020($t4)
	sw $t5, 1024($t4)
	sw $t5, 1268($t4)
	sw $t5, 1272($t4)
	sw $t5, 1516($t4)
	sw $t5, 1520($t4)
restore_draw_carrot:	
	lw $t0, 0($sp)
	lw $t1, 4($sp)
	lw $t2, 8($sp)
	lw $t3, 12($sp)
	lw $t4, 16($sp)
	lw $t5, 20($sp)
	lw $ra, 24($sp)
	addi $sp, $sp, 28
	jr $ra	
	
erase_carrot:
	addi $sp, $sp, -28
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $t3, 12($sp)
	sw $t4, 16($sp)
	sw $t5, 20($sp)
	sw $ra, 24($sp)
	#restore registers
	# $a0=index of platform*4
	# $t0=address of platX[$a0]
	# $t1=address of elementPosition[$a0]
	# $t2=platX[$a0]-7, x position of carrot
	# $t3=elementPosition[$a0]
	# $t4=address in frame
	# $t5=color
	sll $a0, $a0, 2
	la $t0, platX
	la $t1, elementPosition
	add $t0, $t0, $a0
	add $t1, $t1, $a0
	lw $t2, 0($t0)
	addi $t2, $t2, -7
	lw $t3, 0($t1)
	# if $t3<5 or $t3>61, no drawing
	blt $t3, 5, restore_erase_carrot
	bgt $t3, 61, restore_erase_carrot
	
	sll $t4, $t2, 8
	add $t4, $t4, $t3
	add $t4, $t4, $t3
	add $t4, $t4, $t3
	add $t4, $t4, $t3
	addi $t4, $t4, base_address
	li $t5, skyblue
	sw $t5, 0($t4)
	sw $t5, 256($t4)
	sw $t5, 260($t4)

	sw $t5, 512($t4)
	sw $t5, 516($t4)
	sw $t5, 520($t4)

	sw $t5, 504($t4)
	sw $t5, 508($t4)
	sw $t5, 756($t4)
	sw $t5, 1008($t4)
	sw $t5, 1260($t4)

	sw $t5, 760($t4)
	sw $t5, 764($t4)
	sw $t5, 1012($t4)
	sw $t5, 1016($t4)
	sw $t5, 1264($t4)

	sw $t5, 768($t4)
	sw $t5, 1020($t4)
	sw $t5, 1024($t4)
	sw $t5, 1268($t4)
	sw $t5, 1272($t4)
	sw $t5, 1516($t4)
	sw $t5, 1520($t4)
restore_erase_carrot:	
	lw $t0, 0($sp)
	lw $t1, 4($sp)
	lw $t2, 8($sp)
	lw $t3, 12($sp)
	lw $t4, 16($sp)
	lw $t5, 20($sp)
	lw $ra, 24($sp)
	addi $sp, $sp, 28
	jr $ra	
	
check_eat_carrot:
	addi $sp, $sp, -56
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $t3, 12($sp)
	sw $t4, 16($sp)
	sw $t5, 20($sp)
	sw $ra, 24($sp)
	sw $t6, 28($sp)
	sw $t7, 32($sp)
	sw $s3, 36($sp)
	sw $s4, 40($sp)
	sw $s5, 44($sp)
	sw $s6, 48($sp)
	sw $a0, 52($sp)
	#$t0=address of hamster in frame
	#$t1=color
	#$t2=iteration number
	#$t3=address of platX
	#$t4=address of platElement
	#$t5=address of elementPosition
	#$t6=platX[$t2]
	#$t7=platElement[$t2]
	#$s3=position when collision happened
	#$s4=elementPosition[$t2]
	#$s5=carrot position
	#$s6=position difference 
	
	sll $t0, $t8, 8
	add $t0, $t0, $t9
	add $t0, $t0, $t9
	add $t0, $t0, $t9
	add $t0, $t0, $t9
	addi $t0, $t0, base_address
	lw $t1, 1016($t0)
	beq $t1, forestgreen, eat_carrot1
	beq $t1, lime, eat_carrot1
	beq $t1, tomato, eat_carrot1
	beq $t1, orange2, eat_carrot1
	lw $t1, 1020($t0)
	beq $t1, forestgreen, eat_carrot2
	beq $t1, lime, eat_carrot2
	beq $t1, tomato, eat_carrot2
	beq $t1, orange2, eat_carrot2
	lw $t1, 1024($t0)
	beq $t1, forestgreen, eat_carrot3
	beq $t1, lime, eat_carrot3
	beq $t1, tomato, eat_carrot3
	beq $t1, orange2, eat_carrot3
	lw $t1, 1048($t0)
	beq $t1, forestgreen, eat_carrot4
	beq $t1, lime, eat_carrot4
	beq $t1, tomato, eat_carrot4
	beq $t1, orange2, eat_carrot4
	lw $t1, 1052($t0)
	beq $t1, forestgreen, eat_carrot5
	beq $t1, lime, eat_carrot5
	beq $t1, tomato, eat_carrot5
	beq $t1, orange2, eat_carrot5
	lw $t1, 1056($t0)
	beq $t1, forestgreen, eat_carrot6
	beq $t1, lime, eat_carrot6
	beq $t1, tomato, eat_carrot6
	beq $t1, orange2, eat_carrot6
	lw $t1, 1272($t0)
	beq $t1, forestgreen, eat_carrot7
	beq $t1, lime, eat_carrot7
	beq $t1, tomato, eat_carrot7
	beq $t1, orange2, eat_carrot7
	lw $t1, 1276($t0)
	beq $t1, forestgreen, eat_carrot8
	beq $t1, lime, eat_carrot8
	beq $t1, tomato, eat_carrot8
	beq $t1, orange2, eat_carrot8
	lw $t1, 1308($t0)
	beq $t1, forestgreen, eat_carrot9
	beq $t1, lime, eat_carrot9
	beq $t1, tomato, eat_carrot9
	beq $t1, orange2, eat_carrot9
	lw $t1, 1312($t0)
	beq $t1, forestgreen, eat_carrot10
	beq $t1, lime, eat_carrot10
	beq $t1, tomato, eat_carrot10
	beq $t1, orange2, eat_carrot10
	lw $t1, 1528($t0)
	beq $t1, forestgreen, eat_carrot11
	beq $t1, lime, eat_carrot11
	beq $t1, tomato, eat_carrot11
	beq $t1, orange2, eat_carrot11
	lw $t1, 1568($t0)
	beq $t1, forestgreen, eat_carrot12
	beq $t1, lime, eat_carrot12
	beq $t1, tomato, eat_carrot12
	beq $t1, orange2, eat_carrot12
	lw $t1, 1784($t0)
	beq $t1, forestgreen, eat_carrot13
	beq $t1, lime, eat_carrot13
	beq $t1, tomato, eat_carrot13
	beq $t1, orange2, eat_carrot13
	lw $t1, 1824($t0)
	beq $t1, forestgreen, eat_carrot14
	beq $t1, lime, eat_carrot14
	beq $t1, tomato, eat_carrot14
	beq $t1, orange2, eat_carrot14
	lw $t1, 2036($t0)
	beq $t1, forestgreen, eat_carrot15
	beq $t1, lime, eat_carrot15
	beq $t1, tomato, eat_carrot15
	beq $t1, orange2, eat_carrot15
	lw $t1, 2084($t0)
	beq $t1, forestgreen, eat_carrot16
	beq $t1, lime, eat_carrot16
	beq $t1, tomato, eat_carrot16
	beq $t1, orange2, eat_carrot16
	lw $t1, 2292($t0)
	beq $t1, forestgreen, eat_carrot17
	beq $t1, lime, eat_carrot17
	beq $t1, tomato, eat_carrot17
	beq $t1, orange2, eat_carrot17
	lw $t1, 2340($t0)
	beq $t1, forestgreen, eat_carrot18
	beq $t1, lime, eat_carrot18
	beq $t1, tomato, eat_carrot18
	beq $t1, orange2, eat_carrot18
	lw $t1, 2548($t0)
	beq $t1, forestgreen, eat_carrot19
	beq $t1, lime, eat_carrot19
	beq $t1, tomato, eat_carrot19
	beq $t1, orange2, eat_carrot19
	lw $t1, 2596($t0)
	beq $t1, forestgreen, eat_carrot20
	beq $t1, lime, eat_carrot20
	beq $t1, tomato, eat_carrot20
	beq $t1, orange2, eat_carrot20
	lw $t1, 2808($t0)
	beq $t1, forestgreen, eat_carrot21
	beq $t1, lime, eat_carrot21
	beq $t1, tomato, eat_carrot21
	beq $t1, orange2, eat_carrot21
	lw $t1, 2848($t0)
	beq $t1, forestgreen, eat_carrot22
	beq $t1, lime, eat_carrot22
	beq $t1, tomato, eat_carrot22
	beq $t1, orange2, eat_carrot22
	lw $t1, 3064($t0)
	beq $t1, forestgreen, eat_carrot23
	beq $t1, lime, eat_carrot23
	beq $t1, tomato, eat_carrot23
	beq $t1, orange2, eat_carrot23
	lw $t1, 3068($t0)
	beq $t1, forestgreen, eat_carrot24
	beq $t1, lime, eat_carrot24
	beq $t1, tomato, eat_carrot24
	beq $t1, orange2, eat_carrot24
	lw $t1, 3328($t0)
	beq $t1, forestgreen, eat_carrot25
	beq $t1, lime, eat_carrot25
	beq $t1, tomato, eat_carrot25
	beq $t1, orange2, eat_carrot25
	lw $t1, 3332($t0)
	beq $t1, forestgreen, eat_carrot26
	beq $t1, lime, eat_carrot26
	beq $t1, tomato, eat_carrot26
	beq $t1, orange2, eat_carrot26
	lw $t1, 3336($t0)
	beq $t1, forestgreen, eat_carrot27
	beq $t1, lime, eat_carrot27
	beq $t1, tomato, eat_carrot27
	beq $t1, orange2, eat_carrot27
	lw $t1, 3340($t0)
	beq $t1, forestgreen, eat_carrot28
	beq $t1, lime, eat_carrot28
	beq $t1, tomato, eat_carrot28
	beq $t1, orange2, eat_carrot28
	lw $t1, 3088($t0)
	beq $t1, forestgreen, eat_carrot29
	beq $t1, lime, eat_carrot29
	beq $t1, tomato, eat_carrot29
	beq $t1, orange2, eat_carrot29
	lw $t1, 3348($t0)
	beq $t1, forestgreen, eat_carrot30
	beq $t1, lime, eat_carrot30
	beq $t1, tomato, eat_carrot30
	beq $t1, orange2, eat_carrot30
	lw $t1, 3352($t0)
	beq $t1, forestgreen, eat_carrot31
	beq $t1, lime, eat_carrot31
	beq $t1, tomato, eat_carrot31
	beq $t1, orange2, eat_carrot31
	lw $t1, 3100($t0)
	beq $t1, forestgreen, eat_carrot32
	beq $t1, lime, eat_carrot32
	beq $t1, tomato, eat_carrot32
	beq $t1, orange2, eat_carrot32
	lw $t1, 3104($t0)
	beq $t1, forestgreen, eat_carrot33
	beq $t1, lime, eat_carrot33
	beq $t1, tomato, eat_carrot33
	beq $t1, orange2, eat_carrot33
	j restore_eat_carrot
eat_carrot1:
	addi $s3, $t0, 1016
	j eat_carrot
eat_carrot2:
	addi $s3, $t0, 1020
	j eat_carrot
eat_carrot3:
	addi $s3, $t0, 1024
	j eat_carrot
eat_carrot4:
	addi $s3, $t0, 1048
	j eat_carrot
eat_carrot5:
	addi $s3, $t0, 1052
	j eat_carrot
eat_carrot6:
	addi $s3, $t0, 1056
	j eat_carrot
eat_carrot7:
	addi $s3, $t0, 1072
	j eat_carrot
eat_carrot8:	
	addi $s3, $t0, 1076
	j eat_carrot
eat_carrot9:
	addi $s3, $t0, 1308
	j eat_carrot
eat_carrot10:
	addi $s3, $t0, 1312
	j eat_carrot
eat_carrot11:
	addi $s3, $t0, 1528
	j eat_carrot
eat_carrot12:
	addi $s3, $t0, 1568
	j eat_carrot
eat_carrot13:
	addi $s3, $t0, 1784
	j eat_carrot
eat_carrot14:
	addi $s3, $t0, 1824
	j eat_carrot
eat_carrot15:
	addi $s3, $t0, 2036
	j eat_carrot
eat_carrot16:
	addi $s3, $t0, 2084
	j eat_carrot
eat_carrot17:
	addi $s3, $t0, 2292
	j eat_carrot
eat_carrot18:
	addi $s3, $t0, 2340
	j eat_carrot
eat_carrot19:
	addi $s3, $t0, 2548
	j eat_carrot
eat_carrot20:
	addi $s3, $t0, 2596
	j eat_carrot
eat_carrot21:
	addi $s3, $t0, 2808
	j eat_carrot
eat_carrot22:
	addi $s3, $t0, 2848
	j eat_carrot
eat_carrot23:
	addi $s3, $t0, 3064
	j eat_carrot
eat_carrot24:
	addi $s3, $t0, 3068
	j eat_carrot
eat_carrot25:
	addi $s3, $t0, 3328
	j eat_carrot
eat_carrot26:
	addi $s3, $t0, 3332
	j eat_carrot
eat_carrot27:
	addi $s3, $t0, 3336
	j eat_carrot
eat_carrot28:
	addi $s3, $t0, 3340
	j eat_carrot
eat_carrot29:
	addi $s3, $t0, 3088
	j eat_carrot
eat_carrot30:
	addi $s3, $t0, 3348
	j eat_carrot
eat_carrot31:
	addi $s3, $t0, 3352
	j eat_carrot
eat_carrot32:
	addi $s3, $t0, 3100
	j eat_carrot
eat_carrot33:
	addi $s3, $t0, 3104
	j eat_carrot
eat_carrot:
	addi $fp, $fp, 30
	addi $a3, $a3, 1
	jal draw_carrot_num
	li $t2,0
	la $t3, platX
	la $t4, platElement
	la $t5, elementPosition
loop_check_eat_carrot:
	lw $t6, 0($t3)
	lw $t7, 0($t4)
	lw $s4, 0($t5)
	beq $t7, 1, check_erase_carrot
	j next_check_erase_carrot
next_check_erase_carrot:
	addi $t2, $t2, 1
	addi $t3, $t3, 4
	addi $t4, $t4, 4
	addi $t5, $t5, 4
	blt $t2, platNum, loop_check_eat_carrot
	j restore_eat_carrot
check_erase_carrot:
	sll $s5, $t6, 8
	add $s5, $s5, $s4
	add $s5, $s5, $s4
	add $s5, $s5, $s4
	add $s5, $s5, $s4
	addi $s5, $s5, base_address
	sub $s6, $s5, $s3
	# if 0<=$s6<=1520, erase the carrot
	bgt $s6, 1520, next_check_erase_carrot
	blt $s6, 0,next_check_erase_carrot
	addi $a0, $t2, 0
	jal erase_carrot
	li $s6, -1
	sw $s6, 0($t4)
restore_eat_carrot:	
	lw $t0, 0($sp)
	lw $t1, 4($sp)
	lw $t2, 8($sp)
	lw $t3, 12($sp)
	lw $t4, 16($sp)
	lw $t5, 20($sp)
	lw $ra, 24($sp)
	lw $t6, 28($sp)
	lw $t7, 32($sp)
	lw $s3, 36($sp)
	lw $s4, 40($sp)
	lw $s5, 44($sp)
	lw $s6, 48($sp)
	lw $a0, 52($sp)
	addi $sp, $sp, 56
	jr $ra
check_eat_nut:
	addi $sp, $sp, -56
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $t3, 12($sp)
	sw $t4, 16($sp)
	sw $t5, 20($sp)
	sw $ra, 24($sp)
	sw $t6, 28($sp)
	sw $t7, 32($sp)
	sw $s3, 36($sp)
	sw $s4, 40($sp)
	sw $s5, 44($sp)
	sw $s2, 48($sp)
	sw $a0, 52($sp)
	#$t0=address of hamster in frame
	#$t1=color
	#$t2=iteration number
	#$t3=address of platX
	#$t4=address of platElement
	#$t5=address of elementPosition
	#$t6=platX[$t2]
	#$t7=platElement[$t2]
	#$s3=position when collision happened
	#$s4=elementPosition[$t2]
	#$s5=nut position
	#$s2=position difference 
	
	sll $t0, $t8, 8
	add $t0, $t0, $t9
	add $t0, $t0, $t9
	add $t0, $t0, $t9
	add $t0, $t0, $t9
	addi $t0, $t0, base_address
	lw $t1, 1016($t0)
	beq $t1, brown, eat_nut1
	beq $t1, burlywood, eat_nut1
	lw $t1, 1020($t0)
	beq $t1, brown, eat_nut2
	beq $t1, burlywood, eat_nut2
	lw $t1, 1024($t0)
	beq $t1, brown, eat_nut3
	beq $t1, burlywood, eat_nut3
	lw $t1, 1048($t0)
	beq $t1, brown, eat_nut4
	beq $t1, burlywood, eat_nut4
	lw $t1, 1052($t0)
	beq $t1, brown, eat_nut5
	beq $t1, burlywood, eat_nut5
	lw $t1, 1056($t0)
	beq $t1, brown, eat_nut6
	beq $t1, burlywood, eat_nut6
	lw $t1, 1272($t0)
	beq $t1, brown, eat_nut7
	beq $t1, burlywood, eat_nut7
	lw $t1, 1276($t0)
	beq $t1, brown, eat_nut8
	beq $t1, burlywood, eat_nut8
	lw $t1, 1308($t0)
	beq $t1, brown, eat_nut9
	beq $t1, burlywood, eat_nut9
	lw $t1, 1312($t0)
	beq $t1, brown, eat_nut10
	beq $t1, burlywood, eat_nut10
	lw $t1, 1528($t0)
	beq $t1, brown, eat_nut11
	beq $t1, burlywood, eat_nut11
	lw $t1, 1568($t0)
	beq $t1, brown, eat_nut12
	beq $t1, burlywood, eat_nut12
	lw $t1, 1784($t0)
	beq $t1, brown, eat_nut13
	beq $t1, burlywood, eat_nut13
	lw $t1, 1824($t0)
	beq $t1, brown, eat_nut14
	beq $t1, burlywood, eat_nut14
	lw $t1, 2036($t0)
	beq $t1, brown, eat_nut15
	beq $t1, burlywood, eat_nut15
	lw $t1, 2084($t0)
	beq $t1, brown, eat_nut16
	beq $t1, burlywood, eat_nut16
	lw $t1, 2292($t0)
	beq $t1, brown, eat_nut17
	beq $t1, burlywood, eat_nut17
	lw $t1, 2340($t0)
	beq $t1, brown, eat_nut18
	beq $t1, burlywood, eat_nut18
	lw $t1, 2548($t0)
	beq $t1, brown, eat_nut19
	beq $t1, burlywood, eat_nut19
	lw $t1, 2596($t0)
	beq $t1, brown, eat_nut20
	beq $t1, burlywood, eat_nut20
	lw $t1, 2808($t0)
	beq $t1, brown, eat_nut21
	beq $t1, burlywood, eat_nut21
	lw $t1, 2848($t0)
	beq $t1, brown, eat_nut22
	beq $t1, burlywood, eat_nut22
	lw $t1, 3064($t0)
	beq $t1, brown, eat_nut23
	beq $t1, burlywood, eat_nut23
	lw $t1, 3068($t0)
	beq $t1, brown, eat_nut24
	beq $t1, burlywood, eat_nut24
	lw $t1, 3328($t0)
	beq $t1, brown, eat_nut25
	beq $t1, burlywood, eat_nut25
	lw $t1, 3332($t0)
	beq $t1, brown, eat_nut26
	beq $t1, burlywood, eat_nut26
	lw $t1, 3336($t0)
	beq $t1, brown, eat_nut27
	beq $t1, burlywood, eat_nut27
	lw $t1, 3340($t0)
	beq $t1, brown, eat_nut28
	beq $t1, burlywood, eat_nut28
	lw $t1, 3088($t0)
	beq $t1, brown, eat_nut29
	beq $t1, burlywood, eat_nut29
	lw $t1, 3348($t0)
	beq $t1, brown, eat_nut30
	beq $t1, burlywood, eat_nut30
	lw $t1, 3352($t0)
	beq $t1, brown, eat_nut31
	beq $t1, burlywood, eat_nut31
	lw $t1, 3100($t0)
	beq $t1, brown, eat_nut32
	beq $t1, burlywood, eat_nut32
	lw $t1, 3104($t0)
	beq $t1, brown, eat_nut33
	beq $t1, burlywood, eat_nut33
	j restore_eat_nut
eat_nut1:
	addi $s3, $t0, 1016
	j eat_nut
eat_nut2:
	addi $s3, $t0, 1020
	j eat_nut
eat_nut3:
	addi $s3, $t0, 1024
	j eat_nut
eat_nut4:
	addi $s3, $t0, 1048
	j eat_nut
eat_nut5:
	addi $s3, $t0, 1052
	j eat_nut
eat_nut6:
	addi $s3, $t0, 1056
	j eat_nut
eat_nut7:
	addi $s3, $t0, 1072
	j eat_nut
eat_nut8:	
	addi $s3, $t0, 1076
	j eat_nut
eat_nut9:
	addi $s3, $t0, 1308
	j eat_nut
eat_nut10:
	addi $s3, $t0, 1312
	j eat_nut
eat_nut11:
	addi $s3, $t0, 1528
	j eat_nut
eat_nut12:
	addi $s3, $t0, 1568
	j eat_nut
eat_nut13:
	addi $s3, $t0, 1784
	j eat_nut
eat_nut14:
	addi $s3, $t0, 1824
	j eat_nut
eat_nut15:
	addi $s3, $t0, 2036
	j eat_nut
eat_nut16:
	addi $s3, $t0, 2084
	j eat_nut
eat_nut17:
	addi $s3, $t0, 2292
	j eat_nut
eat_nut18:
	addi $s3, $t0, 2340
	j eat_nut
eat_nut19:
	addi $s3, $t0, 2548
	j eat_nut
eat_nut20:
	addi $s3, $t0, 2596
	j eat_nut
eat_nut21:
	addi $s3, $t0, 2808
	j eat_nut
eat_nut22:
	addi $s3, $t0, 2848
	j eat_nut
eat_nut23:
	addi $s3, $t0, 3064
	j eat_nut
eat_nut24:
	addi $s3, $t0, 3068
	j eat_nut
eat_nut25:
	addi $s3, $t0, 3328
	j eat_nut
eat_nut26:
	addi $s3, $t0, 3332
	j eat_nut
eat_nut27:
	addi $s3, $t0, 3336
	j eat_nut
eat_nut28:
	addi $s3, $t0, 3340
	j eat_nut
eat_nut29:
	addi $s3, $t0, 3088
	j eat_nut
eat_nut30:
	addi $s3, $t0, 3348
	j eat_nut
eat_nut31:
	addi $s3, $t0, 3352
	j eat_nut
eat_nut32:
	addi $s3, $t0, 3100
	j eat_nut
eat_nut33:
	addi $s3, $t0, 3104
	j eat_nut
eat_nut:
	addi $fp, $fp, 30
	bge $a2, 3, continue_eat_nut
	addi $a2, $a2, 1
	beq $a2, 2, draw_second_nut
	beq $a2, 3, draw_third_nut
	j continue_eat_nut
draw_second_nut:
	li $a0, 200
	jal draw_heart	
	j continue_eat_nut
draw_third_nut:
	li $a0, 232
	jal draw_heart
	j continue_eat_nut
continue_eat_nut:
	li $t2,0
	la $t3, platX
	la $t4, platElement
	la $t5, elementPosition
loop_check_eat_nut:
	lw $t6, 0($t3)
	lw $t7, 0($t4)
	lw $s4, 0($t5)
	beq $t7, 0, check_erase_nut
	j next_check_erase_nut
next_check_erase_nut:
	addi $t2, $t2, 1
	addi $t3, $t3, 4
	addi $t4, $t4, 4
	addi $t5, $t5, 4
	blt $t2, platNum, loop_check_eat_nut
	j restore_eat_nut
check_erase_nut:
	sll $s5, $t6, 8
	add $s5, $s5, $s4
	add $s5, $s5, $s4
	add $s5, $s5, $s4
	add $s5, $s5, $s4
	addi $s5, $s5, base_address
	sub $s2, $s5, $s3
	# if 0<=$s2<=1500, erase the nut
	bgt $s2, 1500, next_check_erase_nut
	blt $s2, 0,next_check_erase_nut
	addi $a0, $t2, 0
	jal erase_nut
	li $s2, -1
	sw $s2, 0($t4)
restore_eat_nut:	
	lw $t0, 0($sp)
	lw $t1, 4($sp)
	lw $t2, 8($sp)
	lw $t3, 12($sp)
	lw $t4, 16($sp)
	lw $t5, 20($sp)
	lw $ra, 24($sp)
	lw $t6, 28($sp)
	lw $t7, 32($sp)
	lw $s3, 36($sp)
	lw $s4, 40($sp)
	lw $s5, 44($sp)
	lw $s2, 48($sp)
	lw $a0, 52($sp)
	addi $sp, $sp, 56
	jr $ra																																																																																																																																															
collision:	
	bgt $a2, 1, die_one_life_bullet	
	jal draw_red_hamster
	li $a0,168
	jal erase_heart
	li $t1, red
	li $t0, base_address
	addi $t0, $t0, 3356
		#0
	addi $t0, $t0, 256
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	sw $t1, 24($t0)
	sw $t1, 28($t0)
	
	sw $t1, 36($t0)
	sw $t1, 40($t0)
	sw $t1, 48($t0)
	sw $t1, 52($t0)
	sw $t1, 56($t0)
	sw $t1, 60($t0)
	sw $t1, 64($t0)

	sw $t1, 72($t0)
	sw $t1, 76($t0)
	sw $t1, 80($t0)
	sw $t1, 84($t0)
	
	#1
	addi $t0, $t0, 256
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	sw $t1, 24($t0)
	sw $t1, 28($t0)
	
	sw $t1, 36($t0)
	sw $t1, 40($t0)
	sw $t1, 48($t0)
	sw $t1, 52($t0)
	
	sw $t1, 60($t0)
	sw $t1, 64($t0)
	
	sw $t1, 76($t0)
	sw $t1, 80($t0)
	
	#2
	addi $t0, $t0, 256
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	
	sw $t1, 24($t0)
	sw $t1, 28($t0)
	
	sw $t1, 36($t0)
	sw $t1, 40($t0)
	sw $t1, 48($t0)
	sw $t1, 52($t0)
	
	sw $t1, 60($t0)
	sw $t1, 64($t0)
	
	sw $t1, 76($t0)
	sw $t1, 80($t0)
	#3
	addi $t0, $t0, 256
	
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	sw $t1, 12($t0)
	
	sw $t1, 24($t0)
	sw $t1, 28($t0)
	sw $t1, 32($t0)
	sw $t1, 36($t0)
	sw $t1, 40($t0)
	sw $t1, 48($t0)
	sw $t1, 52($t0)
	
	sw $t1, 60($t0)
	sw $t1, 64($t0)
	
	sw $t1, 76($t0)
	sw $t1, 80($t0)
	#4
	addi $t0, $t0, 256
	
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	sw $t1, 24($t0)
	sw $t1, 28($t0)
	
	sw $t1, 36($t0)
	sw $t1, 40($t0)
	sw $t1, 48($t0)
	sw $t1, 52($t0)
	
	sw $t1, 60($t0)
	sw $t1, 64($t0)
	
	sw $t1, 76($t0)
	sw $t1, 80($t0)
	#5
	addi $t0, $t0, 256
	
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	sw $t1, 24($t0)
	sw $t1, 28($t0)
	
	sw $t1, 36($t0)
	sw $t1, 40($t0)
	sw $t1, 48($t0)
	sw $t1, 52($t0)
	
	sw $t1, 60($t0)
	sw $t1, 64($t0)
	
	sw $t1, 76($t0)
	sw $t1, 80($t0)
	#6
	addi $t0, $t0, 256
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	sw $t1, 24($t0)
	sw $t1, 28($t0)
	
	sw $t1, 36($t0)
	sw $t1, 40($t0)
	sw $t1, 48($t0)
	sw $t1, 52($t0)
	
	sw $t1, 60($t0)
	sw $t1, 64($t0)
	
	sw $t1, 76($t0)
	sw $t1, 80($t0)
	#7
	addi $t0, $t0, 256
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	sw $t1, 24($t0)
	sw $t1, 28($t0)
	
	sw $t1, 36($t0)
	sw $t1, 40($t0)
	sw $t1, 48($t0)
	sw $t1, 52($t0)
	sw $t1, 56($t0)
	sw $t1, 60($t0)
	sw $t1, 64($t0)
	
	sw $t1, 76($t0)
	sw $t1, 80($t0)
	#8
	addi $t0, $t0, 256
	#9
	addi $t0, $t0, 256
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	sw $t1, 24($t0)
	sw $t1, 28($t0)
	sw $t1, 36($t0)
	sw $t1, 40($t0)
	sw $t1, 56($t0)
	sw $t1, 60($t0)
	sw $t1, 64($t0)
	sw $t1, 68($t0)
	sw $t1, 72($t0)
	sw $t1, 80($t0)
	sw $t1, 84($t0)
	sw $t1, 92($t0)
	sw $t1, 96($t0)
	sw $t1, 104($t0)
	sw $t1, 108($t0)
	sw $t1, 128($t0)
	sw $t1, 132($t0)
	
	sw $t1, 152($t0)
	sw $t1, 156($t0)
	sw $t1, 160($t0)
	sw $t1, 164($t0)
	sw $t1, 168($t0)
	
	sw $t1, 180($t0)
	sw $t1, 184($t0)
	sw $t1, 176($t0)
	sw $t1, 188($t0)
	
	#10
	addi $t0, $t0, 256
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	sw $t1, 24($t0)
	sw $t1, 28($t0)
	
	sw $t1, 36($t0)
	sw $t1, 40($t0)
	sw $t1, 56($t0)
	sw $t1, 60($t0)
	
	sw $t1, 68($t0)
	sw $t1, 72($t0)
	sw $t1, 80($t0)
	sw $t1, 84($t0)
	sw $t1, 92($t0)
	sw $t1, 96($t0)
	sw $t1, 104($t0)
	sw $t1, 108($t0)
	sw $t1, 128($t0)
	sw $t1, 132($t0)
	
	sw $t1, 152($t0)
	sw $t1, 156($t0)
	
	sw $t1, 164($t0)
	sw $t1, 168($t0)
	
	sw $t1, 180($t0)
	sw $t1, 184($t0)
	#11
	addi $t0, $t0, 256
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	sw $t1, 24($t0)
	sw $t1, 28($t0)
	
	sw $t1, 36($t0)
	sw $t1, 40($t0)
	sw $t1, 56($t0)
	sw $t1, 60($t0)
	
	sw $t1, 68($t0)
	sw $t1, 72($t0)
	sw $t1, 80($t0)
	sw $t1, 84($t0)
	sw $t1, 92($t0)
	sw $t1, 96($t0)
	sw $t1, 104($t0)
	sw $t1, 108($t0)
	sw $t1, 128($t0)
	sw $t1, 132($t0)
	
	sw $t1, 152($t0)
	sw $t1, 156($t0)
	
	
	sw $t1, 180($t0)
	sw $t1, 184($t0)
	#12
	addi $t0, $t0, 256
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	sw $t1, 12($t0)
	
	sw $t1, 28($t0)
	sw $t1, 32($t0)
	sw $t1, 36($t0)
	sw $t1, 40($t0)
	sw $t1, 56($t0)
	sw $t1, 60($t0)
	sw $t1, 64($t0)
	sw $t1, 68($t0)
	
	sw $t1, 80($t0)
	sw $t1, 84($t0)
	sw $t1, 92($t0)
	sw $t1, 96($t0)
	sw $t1, 104($t0)
	sw $t1, 108($t0)
	sw $t1, 128($t0)
	sw $t1, 132($t0)
	
	sw $t1, 152($t0)
	sw $t1, 156($t0)
	sw $t1, 160($t0)
	sw $t1, 164($t0)
	
	
	sw $t1, 180($t0)
	sw $t1, 184($t0)
	#13
	addi $t0, $t0, 256
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	
	sw $t1, 32($t0)
	sw $t1, 36($t0)
	
	sw $t1, 56($t0)
	sw $t1, 60($t0)
	
	sw $t1, 68($t0)
	sw $t1, 72($t0)
	sw $t1, 80($t0)
	sw $t1, 84($t0)
	sw $t1, 92($t0)
	sw $t1, 96($t0)
	sw $t1, 104($t0)
	sw $t1, 108($t0)
	sw $t1, 128($t0)
	sw $t1, 132($t0)
	
	sw $t1, 152($t0)
	sw $t1, 156($t0)
	
	
	sw $t1, 180($t0)
	sw $t1, 184($t0)
	#14
	addi $t0, $t0, 256
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	
	sw $t1, 32($t0)
	sw $t1, 36($t0)
	
	sw $t1, 56($t0)
	sw $t1, 60($t0)
	
	sw $t1, 68($t0)
	sw $t1, 72($t0)
	sw $t1, 80($t0)
	sw $t1, 84($t0)
	sw $t1, 92($t0)
	sw $t1, 96($t0)
	sw $t1, 104($t0)
	sw $t1, 108($t0)
	sw $t1, 128($t0)
	sw $t1, 132($t0)
	
	sw $t1, 152($t0)
	sw $t1, 156($t0)
	
	
	sw $t1, 180($t0)
	sw $t1, 184($t0)
	#15
	addi $t0, $t0, 256
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	
	sw $t1, 32($t0)
	sw $t1, 36($t0)
	
	sw $t1, 56($t0)
	sw $t1, 60($t0)
	
	sw $t1, 68($t0)
	sw $t1, 72($t0)
	sw $t1, 80($t0)
	sw $t1, 84($t0)
	sw $t1, 92($t0)
	sw $t1, 96($t0)
	sw $t1, 104($t0)
	sw $t1, 108($t0)
	sw $t1, 128($t0)
	sw $t1, 132($t0)
	
	sw $t1, 152($t0)
	sw $t1, 156($t0)
	
	sw $t1, 164($t0)
	sw $t1, 168($t0)
	
	sw $t1, 180($t0)
	sw $t1, 184($t0)
	#16
	addi $t0, $t0, 256
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	sw $t1, 12($t0)
	
	sw $t1, 32($t0)
	sw $t1, 36($t0)
	
	sw $t1, 56($t0)
	sw $t1, 60($t0)
	sw $t1, 64($t0)
	sw $t1, 68($t0)
	
	sw $t1, 80($t0)
	sw $t1, 84($t0)
	sw $t1, 88($t0)
	sw $t1, 92($t0)
	sw $t1, 96($t0)
	sw $t1, 104($t0)
	sw $t1, 108($t0)
	sw $t1, 128($t0)
	sw $t1, 132($t0)
	
	sw $t1, 112($t0)
	sw $t1, 116($t0)
	sw $t1, 120($t0)
	sw $t1, 136($t0)
	sw $t1, 140($t0)
	sw $t1, 144($t0)

	sw $t1, 152($t0)
	sw $t1, 156($t0)
	sw $t1, 160($t0)
	sw $t1, 164($t0)
	sw $t1, 168($t0)
	
	sw $t1, 180($t0)
	sw $t1, 184($t0)
																																																	
	j start_quit_at_end																																																																																														
smash:	li $s3, red
	sw $s3, 0($s6)		# paint to red
	li $a0, 168
	jal erase_heart
	li $a0, 200
	jal erase_heart
	li $a0, 232
	jal erase_heart
	jal draw_red_hamster
	li $t1, red
	li $t0, base_address
	addi $t0, $t0, 3332
	#0
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	
	sw $t1, 24($t0)
	sw $t1, 28($t0)
	sw $t1, 32($t0)
	sw $t1, 36($t0)
	sw $t1, 40($t0)
	
	sw $t1, 52($t0)
	sw $t1, 56($t0)

	sw $t1, 64($t0)
	sw $t1, 68($t0)
	
	sw $t1, 76($t0)
	sw $t1, 80($t0)
	sw $t1, 84($t0)
	sw $t1, 88($t0)
	sw $t1, 92($t0)
	
	sw $t1, 100($t0)
	sw $t1, 104($t0)
	sw $t1, 108($t0)
	sw $t1, 112($t0)
	sw $t1, 116($t0)
	
	sw $t1, 124($t0)
	sw $t1, 128($t0)
	sw $t1, 132($t0)
	sw $t1, 136($t0)
	sw $t1, 140($t0)
	
	sw $t1, 148($t0)
	sw $t1, 152($t0)
	sw $t1, 156($t0)
	sw $t1, 160($t0)
	sw $t1, 164($t0)
	
	sw $t1, 172($t0)
	sw $t1, 176($t0)
	sw $t1, 180($t0)
	sw $t1, 184($t0)
	

	#1
	addi $t0, $t0, 256
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	
	sw $t1, 24($t0)
	sw $t1, 28($t0)
	
	sw $t1, 36($t0)
	sw $t1, 40($t0)
	
	sw $t1, 52($t0)
	sw $t1, 56($t0)
	
	sw $t1, 64($t0)
	sw $t1, 68($t0)
	
	sw $t1, 76($t0)
	sw $t1, 80($t0)
	
	sw $t1, 88($t0)
	sw $t1, 92($t0)
	
	sw $t1, 100($t0)
	sw $t1, 104($t0)
	
	sw $t1, 112($t0)
	sw $t1, 116($t0)
	
	sw $t1, 124($t0)
	sw $t1, 128($t0)
	
	sw $t1, 136($t0)
	sw $t1, 140($t0)
	
	sw $t1, 148($t0)
	sw $t1, 152($t0)
	
	sw $t1, 160($t0)
	sw $t1, 164($t0)
	
	sw $t1, 172($t0)
	sw $t1, 176($t0)
	
	sw $t1, 184($t0)
	sw $t1, 188($t0)
	#2
	addi $t0, $t0, 256
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	
	sw $t1, 24($t0)
	sw $t1, 28($t0)
	
	sw $t1, 36($t0)
	sw $t1, 40($t0)
	
	sw $t1, 52($t0)
	sw $t1, 56($t0)
	
	sw $t1, 64($t0)
	sw $t1, 68($t0)
	
	sw $t1, 76($t0)
	sw $t1, 80($t0)
	
	sw $t1, 100($t0)
	sw $t1, 104($t0)
	
	sw $t1, 136($t0)
	sw $t1, 140($t0)
	
	sw $t1, 148($t0)
	sw $t1, 152($t0)
	
	sw $t1, 172($t0)
	sw $t1, 176($t0)
	
	sw $t1, 184($t0)
	sw $t1, 188($t0)
	#3
	addi $t0, $t0, 256
	
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	sw $t1, 12($t0)
	
	sw $t1, 24($t0)
	sw $t1, 28($t0)
	
	sw $t1, 36($t0)
	sw $t1, 40($t0)
	
	sw $t1, 52($t0)
	sw $t1, 56($t0)
	
	sw $t1, 64($t0)
	sw $t1, 68($t0)
	
	sw $t1, 76($t0)
	sw $t1, 80($t0)
	sw $t1, 84($t0)
	sw $t1, 88($t0)
	
	sw $t1, 100($t0)
	sw $t1, 104($t0)
	sw $t1, 108($t0)
	sw $t1, 112($t0)
	
	sw $t1, 128($t0)
	sw $t1, 132($t0)
	sw $t1, 136($t0)
	
	sw $t1, 148($t0)
	sw $t1, 152($t0)
	sw $t1, 156($t0)
	sw $t1, 160($t0)
	
	sw $t1, 172($t0)
	sw $t1, 176($t0)
	
	sw $t1, 184($t0)
	sw $t1, 188($t0)
	#4
	addi $t0, $t0, 256
	
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	
	sw $t1, 24($t0)
	sw $t1, 28($t0)
	
	sw $t1, 36($t0)
	sw $t1, 40($t0)
	
	sw $t1, 52($t0)
	sw $t1, 56($t0)
	
	sw $t1, 64($t0)
	sw $t1, 68($t0)
	
	sw $t1, 76($t0)
	sw $t1, 80($t0)
	
	sw $t1, 100($t0)
	sw $t1, 104($t0)
	
	sw $t1, 124($t0)
	sw $t1, 128($t0)
	
	sw $t1, 148($t0)
	sw $t1, 152($t0)
	
	sw $t1, 172($t0)
	sw $t1, 176($t0)
	
	sw $t1, 184($t0)
	sw $t1, 188($t0)
	#5
	addi $t0, $t0, 256
	
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	
	sw $t1, 24($t0)
	sw $t1, 28($t0)
	
	sw $t1, 36($t0)
	sw $t1, 40($t0)
	
	sw $t1, 52($t0)
	sw $t1, 56($t0)
	
	sw $t1, 64($t0)
	sw $t1, 68($t0)
	
	sw $t1, 76($t0)
	sw $t1, 80($t0)
	
	sw $t1, 100($t0)
	sw $t1, 104($t0)
	
	sw $t1, 124($t0)
	sw $t1, 128($t0)
	
	sw $t1, 148($t0)
	sw $t1, 152($t0)
	
	sw $t1, 172($t0)
	sw $t1, 176($t0)
	
	sw $t1, 184($t0)
	sw $t1, 188($t0)
	#6
	addi $t0, $t0, 256
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	
	sw $t1, 24($t0)
	sw $t1, 28($t0)
	
	sw $t1, 36($t0)
	sw $t1, 40($t0)
	sw $t1, 44($t0)
	
	sw $t1, 52($t0)
	sw $t1, 56($t0)
	
	sw $t1, 64($t0)
	sw $t1, 68($t0)
	
	sw $t1, 76($t0)
	sw $t1, 80($t0)
	
	sw $t1, 88($t0)
	sw $t1, 92($t0)

	sw $t1, 100($t0)
	sw $t1, 104($t0)

	sw $t1, 112($t0)
	sw $t1, 116($t0)
	
	sw $t1, 124($t0)
	sw $t1, 128($t0)
	
	sw $t1, 136($t0)
	sw $t1, 140($t0)
	
	sw $t1, 148($t0)
	sw $t1, 152($t0)
	
	sw $t1, 160($t0)
	sw $t1, 164($t0)
	
	sw $t1, 172($t0)
	sw $t1, 176($t0)
	
	sw $t1, 184($t0)
	sw $t1, 188($t0)
	#7
	addi $t0, $t0, 256
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	
	sw $t1, 24($t0)
	sw $t1, 28($t0)
	sw $t1, 32($t0)
	sw $t1, 36($t0)
	sw $t1, 40($t0)
	
	sw $t1, 52($t0)
	sw $t1, 56($t0)
	sw $t1, 60($t0)
	sw $t1, 64($t0)
	sw $t1, 68($t0)
	
	sw $t1, 76($t0)
	sw $t1, 80($t0)
	sw $t1, 84($t0)
	sw $t1, 88($t0)
	sw $t1, 92($t0)
	
	sw $t1, 100($t0)
	sw $t1, 104($t0)
	sw $t1, 108($t0)
	sw $t1, 112($t0)
	sw $t1, 116($t0)
	
	sw $t1, 124($t0)
	sw $t1, 128($t0)
	sw $t1, 132($t0)
	sw $t1, 136($t0)
	sw $t1, 140($t0)
	
	sw $t1, 148($t0)
	sw $t1, 152($t0)
	sw $t1, 156($t0)
	sw $t1, 160($t0)
	sw $t1, 164($t0)
	
	sw $t1, 172($t0)
	sw $t1, 176($t0)
	sw $t1, 180($t0)
	sw $t1, 184($t0)
	
	#8
	addi $t0, $t0, 256
		#9
	addi $t0, $t0, 256
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	
	sw $t1, 24($t0)
	sw $t1, 28($t0)

	sw $t1, 36($t0)
	sw $t1, 40($t0)
	
	sw $t1, 56($t0)
	sw $t1, 60($t0)
	sw $t1, 64($t0)
	sw $t1, 68($t0)
	sw $t1, 72($t0)

	sw $t1, 80($t0)
	sw $t1, 84($t0)
	sw $t1, 104($t0)
	sw $t1, 108($t0)
	sw $t1, 112($t0)
	sw $t1, 116($t0)
	sw $t1, 120($t0)
	
	sw $t1, 128($t0)
	sw $t1, 132($t0)
	sw $t1, 136($t0)
	sw $t1, 140($t0)
	
	sw $t1, 148($t0)
	sw $t1, 152($t0)
	sw $t1, 156($t0)
	sw $t1, 160($t0)
	sw $t1, 164($t0)
	
	sw $t1, 172($t0)
	sw $t1, 176($t0)
	sw $t1, 180($t0)
	sw $t1, 184($t0)
	sw $t1, 188($t0)
	sw $t1, 196($t0)
	sw $t1, 200($t0)
	sw $t1, 204($t0)
	sw $t1, 208($t0)
	sw $t1, 212($t0)

	sw $t1, 220($t0)
	sw $t1, 224($t0)
	
	sw $t1, 240($t0)
	sw $t1, 244($t0)
	#10
	addi $t0, $t0, 256
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	
	sw $t1, 24($t0)
	sw $t1, 28($t0)
	
	sw $t1, 36($t0)
	sw $t1, 40($t0)
	
	sw $t1, 56($t0)
	sw $t1, 60($t0)
	
	sw $t1, 68($t0)
	sw $t1, 72($t0)
	
	sw $t1, 80($t0)
	sw $t1, 84($t0)
	
	sw $t1, 104($t0)
	sw $t1, 108($t0)
	
	sw $t1, 116($t0)
	sw $t1, 120($t0)
	
	sw $t1, 132($t0)
	sw $t1, 136($t0)
	
	sw $t1, 148($t0)
	sw $t1, 152($t0)
	
	sw $t1, 160($t0)
	sw $t1, 164($t0)
	
	sw $t1, 172($t0)
	sw $t1, 176($t0)
	
	sw $t1, 184($t0)
	sw $t1, 188($t0)
	
	sw $t1, 196($t0)
	sw $t1, 200($t0)
	
	sw $t1, 208($t0)
	sw $t1, 212($t0)
	
	sw $t1, 220($t0)
	sw $t1, 224($t0)
	sw $t1, 228($t0)
	
	sw $t1, 236($t0)
	sw $t1, 240($t0)
	sw $t1, 244($t0)

	#11
	addi $t0, $t0, 256
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	sw $t1, 24($t0)
	sw $t1, 28($t0)
	sw $t1, 36($t0)
	sw $t1, 40($t0)
	sw $t1, 56($t0)
	sw $t1, 60($t0)
	
	sw $t1, 68($t0)
	sw $t1, 72($t0)
	sw $t1, 80($t0)
	sw $t1, 84($t0)
	sw $t1, 104($t0)
	sw $t1, 108($t0)
	
	sw $t1, 116($t0)
	sw $t1, 120($t0)
	sw $t1, 132($t0)
	sw $t1, 136($t0)
	sw $t1, 148($t0)
	sw $t1, 152($t0)
	
	sw $t1, 172($t0)
	sw $t1, 176($t0)
	sw $t1, 184($t0)
	sw $t1, 188($t0)
	sw $t1, 196($t0)
	sw $t1, 200($t0)
	sw $t1, 208($t0)
	sw $t1, 212($t0)
	sw $t1, 220($t0)
	sw $t1, 224($t0)
	sw $t1, 228($t0)
	sw $t1, 232($t0)
	sw $t1, 236($t0)
	sw $t1, 240($t0)
	sw $t1, 244($t0)

	#12
		addi $t0, $t0, 256
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	sw $t1, 12($t0)
	
	sw $t1, 28($t0)
	sw $t1, 32($t0)
	sw $t1, 36($t0)
	sw $t1, 40($t0)
	sw $t1, 56($t0)
	sw $t1, 60($t0)
	sw $t1, 64($t0)
	sw $t1, 68($t0)
	sw $t1, 80($t0)
	sw $t1, 84($t0)
	sw $t1, 104($t0)
	sw $t1, 108($t0)
	sw $t1, 112($t0)
	sw $t1, 116($t0)
	sw $t1, 120($t0)
	sw $t1, 132($t0)
	sw $t1, 136($t0)
	sw $t1, 148($t0)
	sw $t1, 152($t0)
	sw $t1, 156($t0)
	sw $t1, 160($t0)
	
	sw $t1, 172($t0)
	sw $t1, 176($t0)
	sw $t1, 184($t0)
	sw $t1, 188($t0)
	sw $t1, 196($t0)
	sw $t1, 200($t0)
	sw $t1, 204($t0)
	sw $t1, 208($t0)
	
	sw $t1, 220($t0)
	sw $t1, 224($t0)
	
	sw $t1, 232($t0)
	
	sw $t1, 240($t0)
	sw $t1, 244($t0)
	
	#13
	addi $t0, $t0, 256
	sw $t1, 0($t0)
	sw $t1, 4($t0)

	sw $t1, 12($t0)
	sw $t1, 16($t0)
	
	sw $t1, 32($t0)
	sw $t1, 36($t0)
	
	sw $t1, 56($t0)
	sw $t1, 60($t0)
	
	sw $t1, 80($t0)
	sw $t1, 84($t0)
	sw $t1, 104($t0)
	sw $t1, 108($t0)
	
	sw $t1, 116($t0)
	sw $t1, 120($t0)
	sw $t1, 132($t0)
	sw $t1, 136($t0)
	sw $t1, 148($t0)
	sw $t1, 152($t0)
	
	sw $t1, 172($t0)
	sw $t1, 176($t0)
	sw $t1, 184($t0)
	sw $t1, 188($t0)
	sw $t1, 196($t0)
	sw $t1, 200($t0)
	sw $t1, 208($t0)
	sw $t1, 212($t0)
	sw $t1, 220($t0)
	sw $t1, 224($t0)
	
	sw $t1, 240($t0)
	sw $t1, 244($t0)
	#14
	addi $t0, $t0, 256
	sw $t1, 0($t0)
	sw $t1, 4($t0)

	sw $t1, 12($t0)
	sw $t1, 16($t0)
	
	sw $t1, 32($t0)
	sw $t1, 36($t0)
	
	sw $t1, 56($t0)
	sw $t1, 60($t0)
	
	sw $t1, 80($t0)
	sw $t1, 84($t0)
	sw $t1, 104($t0)
	sw $t1, 108($t0)
	
	sw $t1, 116($t0)
	sw $t1, 120($t0)
	sw $t1, 132($t0)
	sw $t1, 136($t0)
	sw $t1, 148($t0)
	sw $t1, 152($t0)
	
	sw $t1, 172($t0)
	sw $t1, 176($t0)
	sw $t1, 184($t0)
	sw $t1, 188($t0)
	sw $t1, 196($t0)
	sw $t1, 200($t0)
	sw $t1, 208($t0)
	sw $t1, 212($t0)
	sw $t1, 220($t0)
	sw $t1, 224($t0)
	
	sw $t1, 240($t0)
	sw $t1, 244($t0)
	#15
	addi $t0, $t0, 256
	sw $t1, 0($t0)
	sw $t1, 4($t0)

	sw $t1, 12($t0)
	sw $t1, 16($t0)
	
	sw $t1, 32($t0)
	sw $t1, 36($t0)
	
	sw $t1, 56($t0)
	sw $t1, 60($t0)
	
	sw $t1, 80($t0)
	sw $t1, 84($t0)
	sw $t1, 104($t0)
	sw $t1, 108($t0)
	
	sw $t1, 116($t0)
	sw $t1, 120($t0)
	sw $t1, 132($t0)
	sw $t1, 136($t0)
	sw $t1, 148($t0)
	sw $t1, 152($t0)
	
	sw $t1, 172($t0)
	sw $t1, 176($t0)
	sw $t1, 184($t0)
	sw $t1, 188($t0)
	sw $t1, 196($t0)
	sw $t1, 200($t0)
	sw $t1, 208($t0)
	sw $t1, 212($t0)
	sw $t1, 220($t0)
	sw $t1, 224($t0)
	
	sw $t1, 240($t0)
	sw $t1, 244($t0)
	#16
	addi $t0, $t0, 256
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	sw $t1, 12($t0)
	
	sw $t1, 32($t0)
	sw $t1, 36($t0)
	
	sw $t1, 56($t0)
	sw $t1, 60($t0)
	
	sw $t1, 80($t0)
	sw $t1, 84($t0)
	sw $t1, 88($t0)
	
	sw $t1, 92($t0)
	sw $t1, 96($t0)
	sw $t1, 104($t0)
	sw $t1, 108($t0)
	
	sw $t1, 116($t0)
	sw $t1, 120($t0)
	sw $t1, 132($t0)
	sw $t1, 136($t0)
	sw $t1, 148($t0)
	sw $t1, 152($t0)
	
	sw $t1, 172($t0)
	sw $t1, 176($t0)
	sw $t1, 180($t0)
	sw $t1, 184($t0)
	sw $t1, 188($t0)
	sw $t1, 196($t0)
	sw $t1, 200($t0)
	sw $t1, 208($t0)
	sw $t1, 212($t0)
	sw $t1, 220($t0)
	sw $t1, 224($t0)
	
	sw $t1, 240($t0)
	sw $t1, 244($t0)
	
	j start_quit_at_end
dead_by_enemy:
	bgt $a2, 1, die_one_life_enemy
	li $a0, 168
	jal erase_heart
	jal draw_red_hamster
	li $t1, red
	li $t0, base_address
	addi $t0, $t0, 3364	
	
		#0
	addi $t0, $t0, 256
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	sw $t1, 28($t0)
	sw $t1, 32($t0)
	sw $t1, 24($t0)
	sw $t1, 36($t0)
	sw $t1, 44($t0)
	sw $t1, 48($t0)
	
	sw $t1, 68($t0)
	sw $t1, 72($t0)
	
	
	sw $t1, 92($t0)
	sw $t1, 96($t0)
	sw $t1, 100($t0)
	sw $t1, 104($t0)
	sw $t1, 108($t0)
	
	sw $t1, 116($t0)
	sw $t1, 120($t0)
	
	sw $t1, 128($t0)
	sw $t1, 124($t0)
	#1
	addi $t0, $t0, 256
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	sw $t1, 28($t0)
	sw $t1, 32($t0)
	
	sw $t1, 44($t0)
	sw $t1, 48($t0)
	
	sw $t1, 68($t0)
	sw $t1, 72($t0)
	
	
	sw $t1, 92($t0)
	sw $t1, 96($t0)
	
	sw $t1, 104($t0)
	sw $t1, 108($t0)
	
	sw $t1, 116($t0)
	sw $t1, 120($t0)
	
	sw $t1, 128($t0)
	sw $t1, 132($t0)
	#2
	addi $t0, $t0, 256
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	sw $t1, 28($t0)
	sw $t1, 32($t0)
	
	sw $t1, 44($t0)
	sw $t1, 48($t0)
	
	sw $t1, 68($t0)
	sw $t1, 72($t0)
	
	
	sw $t1, 92($t0)
	sw $t1, 96($t0)
	
	
	sw $t1, 116($t0)
	sw $t1, 120($t0)
	
	sw $t1, 128($t0)
	sw $t1, 132($t0)
	#3
	addi $t0, $t0, 256
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	sw $t1, 12($t0)
	
	sw $t1, 28($t0)
	sw $t1, 32($t0)
	
	sw $t1, 44($t0)
	sw $t1, 48($t0)
	
	sw $t1, 68($t0)
	sw $t1, 72($t0)
	
	
	sw $t1, 92($t0)
	sw $t1, 96($t0)
	sw $t1, 100($t0)
	sw $t1, 104($t0)
	
	
	sw $t1, 116($t0)
	sw $t1, 120($t0)
	
	sw $t1, 128($t0)
	sw $t1, 132($t0)
	#4
	addi $t0, $t0, 256
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	sw $t1, 28($t0)
	sw $t1, 32($t0)
	
	sw $t1, 44($t0)
	sw $t1, 48($t0)
	
	sw $t1, 68($t0)
	sw $t1, 72($t0)
	
	
	sw $t1, 92($t0)
	sw $t1, 96($t0)
	
	
	sw $t1, 116($t0)
	sw $t1, 120($t0)
	
	sw $t1, 128($t0)
	sw $t1, 132($t0)
	#5
	addi $t0, $t0, 256
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	sw $t1, 28($t0)
	sw $t1, 32($t0)
	
	sw $t1, 44($t0)
	sw $t1, 48($t0)
	
	sw $t1, 68($t0)
	sw $t1, 72($t0)
	
	sw $t1, 92($t0)
	sw $t1, 96($t0)
	
	
	sw $t1, 116($t0)
	sw $t1, 120($t0)
	
	sw $t1, 128($t0)
	sw $t1, 132($t0)
	#6
	addi $t0, $t0, 256
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	sw $t1, 28($t0)
	sw $t1, 32($t0)
	
	sw $t1, 44($t0)
	sw $t1, 48($t0)
	
	sw $t1, 68($t0)
	sw $t1, 72($t0)
	
	
	sw $t1, 92($t0)
	sw $t1, 96($t0)
	
	sw $t1, 104($t0)
	sw $t1, 108($t0)
	
	sw $t1, 116($t0)
	sw $t1, 120($t0)
	
	sw $t1, 128($t0)
	sw $t1, 132($t0)
	#7
	addi $t0, $t0, 256
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	sw $t1, 28($t0)
	sw $t1, 32($t0)
	
	sw $t1, 44($t0)
	sw $t1, 48($t0)
	
	sw $t1, 68($t0)
	sw $t1, 72($t0)
	
	
	sw $t1, 92($t0)
	sw $t1, 96($t0)
	sw $t1, 100($t0)
	sw $t1, 104($t0)
	sw $t1, 108($t0)
	
	sw $t1, 116($t0)
	sw $t1, 120($t0)
	sw $t1, 124($t0)
	sw $t1, 128($t0)
	sw $t1, 52($t0)
	sw $t1, 56($t0)
	
	sw $t1, 60($t0)
	sw $t1, 76($t0)
	sw $t1, 80($t0)
	sw $t1, 84($t0)
	sw $t1, 24($t0)
	sw $t1, 36($t0)
	#8
	addi $t0, $t0, 256

	#9
	addi $t0, $t0, 256
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	sw $t1, 12($t0)
	sw $t1, 16($t0)

	sw $t1, 24($t0)
	sw $t1, 28($t0)
	
	sw $t1, 36($t0)
	sw $t1, 40($t0)
	
	sw $t1, 56($t0)
	sw $t1, 60($t0)
	sw $t1, 64($t0)
	sw $t1, 68($t0)
	sw $t1, 72($t0)
	
	sw $t1, 80($t0)
	sw $t1, 84($t0)
	
	sw $t1, 96($t0)
	sw $t1, 100($t0)
	
	sw $t1, 108($t0)
	sw $t1, 112($t0)
	sw $t1, 116($t0)
	sw $t1, 120($t0)
	sw $t1, 124($t0)
	
	sw $t1, 132($t0)
	sw $t1, 136($t0)
	
	sw $t1, 152($t0)
	sw $t1, 156($t0)
	
	sw $t1, 164($t0)
	sw $t1, 168($t0)
	
	sw $t1, 176($t0)
	sw $t1, 180($t0)
	
	#10
	addi $t0, $t0, 256
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	
	sw $t1, 12($t0)
	sw $t1, 16($t0)

	sw $t1, 24($t0)
	sw $t1, 28($t0)
	
	sw $t1, 36($t0)
	sw $t1, 40($t0)
	
	sw $t1, 56($t0)
	sw $t1, 60($t0)
	
	sw $t1, 68($t0)
	sw $t1, 72($t0)
	
	sw $t1, 80($t0)
	sw $t1, 84($t0)
	sw $t1, 88($t0)
	
	sw $t1, 96($t0)
	sw $t1, 100($t0)
	
	sw $t1, 108($t0)
	sw $t1, 112($t0)
	
	sw $t1, 120($t0)
	sw $t1, 124($t0)
	
	sw $t1, 132($t0)
	sw $t1, 136($t0)
	sw $t1, 140($t0)
	
	sw $t1, 148($t0)
	sw $t1, 152($t0)
	sw $t1, 156($t0)
	
	sw $t1, 164($t0)
	sw $t1, 168($t0)
	
	sw $t1, 176($t0)
	sw $t1, 180($t0)
	
	#11
	addi $t0, $t0, 256
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	
	sw $t1, 12($t0)
	sw $t1, 16($t0)

	sw $t1, 24($t0)
	sw $t1, 28($t0)
	
	sw $t1, 36($t0)
	sw $t1, 40($t0)
	
	sw $t1, 56($t0)
	sw $t1, 60($t0)
	
	
	sw $t1, 80($t0)
	sw $t1, 84($t0)
	sw $t1, 88($t0)
	sw $t1, 92($t0)
	sw $t1, 96($t0)
	sw $t1, 100($t0)
	
	sw $t1, 108($t0)
	sw $t1, 112($t0)
	
	
	sw $t1, 132($t0)
	sw $t1, 136($t0)
	sw $t1, 140($t0)
	sw $t1, 144($t0)
	sw $t1, 148($t0)
	sw $t1, 152($t0)
	sw $t1, 156($t0)
	
	sw $t1, 164($t0)
	sw $t1, 168($t0)
	
	sw $t1, 176($t0)
	sw $t1, 180($t0)
	
	#12
	addi $t0, $t0, 256
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	sw $t1, 12($t0)
	
	sw $t1, 28($t0)
	sw $t1, 32($t0)
	sw $t1, 36($t0)
	sw $t1, 40($t0)
	
	sw $t1, 56($t0)
	sw $t1, 60($t0)
	sw $t1, 64($t0)
	sw $t1, 68($t0)
	
	sw $t1, 80($t0)
	sw $t1, 84($t0)
	
	sw $t1, 92($t0)
	sw $t1, 96($t0)
	sw $t1, 100($t0)
	
	sw $t1, 108($t0)
	sw $t1, 112($t0)
	sw $t1, 116($t0)
	sw $t1, 120($t0)
	
	
	sw $t1, 132($t0)
	sw $t1, 136($t0)
	
	sw $t1, 144($t0)
	
	sw $t1, 152($t0)
	sw $t1, 156($t0)
	
	sw $t1, 168($t0)
	sw $t1, 172($t0)
	sw $t1, 176($t0)
	sw $t1, 180($t0)
	
	#13
	addi $t0, $t0, 256
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	
	sw $t1, 12($t0)
	sw $t1, 16($t0)

	
	sw $t1, 32($t0)
	sw $t1, 36($t0)
	
	
	sw $t1, 56($t0)
	sw $t1, 60($t0)
	
	
	sw $t1, 80($t0)
	sw $t1, 84($t0)
	
	sw $t1, 96($t0)
	sw $t1, 100($t0)
	
	sw $t1, 108($t0)
	sw $t1, 112($t0)
	
	
	sw $t1, 132($t0)
	sw $t1, 136($t0)
	
	sw $t1, 152($t0)
	sw $t1, 156($t0)
	
	
	sw $t1, 172($t0)
	sw $t1, 176($t0)
	
	
	#14
	addi $t0, $t0, 256
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	
	sw $t1, 12($t0)
	sw $t1, 16($t0)

	sw $t1, 32($t0)
	sw $t1, 36($t0)
	
	
	sw $t1, 56($t0)
	sw $t1, 60($t0)
	
	
	sw $t1, 80($t0)
	sw $t1, 84($t0)
	
	sw $t1, 96($t0)
	sw $t1, 100($t0)
	
	sw $t1, 108($t0)
	sw $t1, 112($t0)
	
	
	sw $t1, 132($t0)
	sw $t1, 136($t0)
	
	sw $t1, 152($t0)
	sw $t1, 156($t0)
	
	
	sw $t1, 172($t0)
	sw $t1, 176($t0)
	
	
	#15
	addi $t0, $t0, 256
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	
	sw $t1, 12($t0)
	sw $t1, 16($t0)

	
	sw $t1, 32($t0)
	sw $t1, 36($t0)
	
	sw $t1, 56($t0)
	sw $t1, 60($t0)
	
	sw $t1, 68($t0)
	sw $t1, 72($t0)
	
	sw $t1, 80($t0)
	sw $t1, 84($t0)
	
	sw $t1, 96($t0)
	sw $t1, 100($t0)
	
	sw $t1, 108($t0)
	sw $t1, 112($t0)
	
	sw $t1, 120($t0)
	sw $t1, 124($t0)
	
	sw $t1, 132($t0)
	sw $t1, 136($t0)
	
	sw $t1, 152($t0)
	sw $t1, 156($t0)
	
	sw $t1, 172($t0)
	sw $t1, 176($t0)
	
	
	#16
	addi $t0, $t0, 256
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	sw $t1, 12($t0)
	
	sw $t1, 32($t0)
	sw $t1, 36($t0)
	
	
	sw $t1, 56($t0)
	sw $t1, 60($t0)
	sw $t1, 64($t0)
	sw $t1, 68($t0)
	sw $t1, 72($t0)
	
	sw $t1, 80($t0)
	sw $t1, 84($t0)
	
	sw $t1, 96($t0)
	sw $t1, 100($t0)
	
	sw $t1, 108($t0)
	sw $t1, 112($t0)
	sw $t1, 116($t0)
	sw $t1, 120($t0)
	sw $t1, 124($t0)
	
	sw $t1, 132($t0)
	sw $t1, 136($t0)
	
	sw $t1, 152($t0)
	sw $t1, 156($t0)
	
	sw $t1, 172($t0)
	sw $t1, 176($t0)
	
	
	j start_quit_at_end
END_PROGRAM:
	li 	$t0, base_address	# $t0=the base address for display
	li 	$t1, 4096		# $t1=64*64=4096 units
	li 	$t2, skyblue		# $t2=skyblue color
bg2:	sw   	$t2, 0($t0)		# paint the whole screen to skyblue
	addi 	$t0, $t0, 4 		# advance to next unit position in display
	addi 	$t1, $t1, -1		# decrement number of units
	bnez 	$t1, bg2
	li $t1, black
	li $t0, 5660
	addi $t0, $t0, base_address
	#1
	addi $t0, $t0, 256
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	sw $t1, 12($t0)
	
	sw $t1, 20($t0)
	sw $t1, 24($t0)
	
	sw $t1, 32($t0)
	sw $t1, 36($t0)
	
	sw $t1, 44($t0)
	sw $t1, 48($t0)
	sw $t1, 52($t0)
	sw $t1, 56($t0)
	sw $t1, 60($t0)
	
	sw $t1, 68($t0)
	sw $t1, 72($t0)
	
	sw $t1, 84($t0)
	sw $t1, 88($t0)
	
	sw $t1, 96($t0)
	sw $t1, 100($t0)
	
	sw $t1, 108($t0)
	sw $t1, 112($t0)
	
	sw $t1, 128($t0)
	sw $t1, 132($t0)
	
	sw $t1, 140($t0)
	sw $t1, 144($t0)
	
	sw $t1, 152($t0)
	sw $t1, 156($t0)
	sw $t1, 160($t0)
	sw $t1, 164($t0)
	sw $t1, 168($t0)
	
	sw $t1, 176($t0)
	sw $t1, 180($t0)
	
	sw $t1, 188($t0)
	sw $t1, 192($t0)
	#1
	addi $t0, $t0, 256
	
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	
	sw $t1, 20($t0)
	sw $t1, 24($t0)
	
	sw $t1, 32($t0)
	sw $t1, 36($t0)
	
	sw $t1, 44($t0)
	sw $t1, 48($t0)
	
	sw $t1, 56($t0)
	sw $t1, 60($t0)
	
	sw $t1, 68($t0)
	sw $t1, 72($t0)
	sw $t1, 76($t0)
	sw $t1, 84($t0)
	sw $t1, 88($t0)
	
	sw $t1, 96($t0)
	sw $t1, 100($t0)
	
	sw $t1, 108($t0)
	sw $t1, 112($t0)
	
	sw $t1, 128($t0)
	sw $t1, 132($t0)
	
	sw $t1, 140($t0)
	sw $t1, 144($t0)
	
	sw $t1, 152($t0)
	sw $t1, 156($t0)
	
	sw $t1, 164($t0)
	sw $t1, 168($t0)
	
	sw $t1, 176($t0)
	sw $t1, 180($t0)
	
	sw $t1, 188($t0)
	sw $t1, 192($t0)
	#2
	addi $t0, $t0, 256
	
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	
	sw $t1, 20($t0)
	sw $t1, 24($t0)
	
	sw $t1, 32($t0)
	sw $t1, 36($t0)
	
	sw $t1, 44($t0)
	sw $t1, 48($t0)
	
	sw $t1, 56($t0)
	sw $t1, 60($t0)
	
	sw $t1, 68($t0)
	sw $t1, 72($t0)
	sw $t1, 76($t0)
	sw $t1, 80($t0)
	sw $t1, 84($t0)
	sw $t1, 88($t0)
	
	sw $t1, 96($t0)
	sw $t1, 100($t0)
	
	sw $t1, 108($t0)
	sw $t1, 112($t0)
	
	sw $t1, 128($t0)
	sw $t1, 132($t0)
	
	sw $t1, 140($t0)
	sw $t1, 144($t0)
	
	sw $t1, 152($t0)
	sw $t1, 156($t0)
	
	sw $t1, 164($t0)
	sw $t1, 168($t0)
	
	sw $t1, 176($t0)
	sw $t1, 180($t0)
	
	sw $t1, 188($t0)
	sw $t1, 192($t0)
	#3
	addi $t0, $t0, 256
	
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	
	sw $t1, 20($t0)
	sw $t1, 24($t0)
	sw $t1, 28($t0)
	sw $t1, 32($t0)
	sw $t1, 36($t0)
	
	sw $t1, 44($t0)
	sw $t1, 48($t0)
	sw $t1, 52($t0)
	sw $t1, 56($t0)
	sw $t1, 60($t0)
	
	sw $t1, 68($t0)
	sw $t1, 72($t0)
	
	sw $t1, 80($t0)
	sw $t1, 84($t0)
	sw $t1, 88($t0)
	
	sw $t1, 96($t0)
	sw $t1, 100($t0)
	sw $t1, 104($t0)
	sw $t1, 108($t0)
	
	sw $t1, 136($t0)
	sw $t1, 132($t0)
	
	sw $t1, 140($t0)
	sw $t1, 144($t0)
	
	sw $t1, 152($t0)
	sw $t1, 156($t0)
	
	sw $t1, 164($t0)
	sw $t1, 168($t0)
	
	sw $t1, 176($t0)
	sw $t1, 180($t0)
	
	sw $t1, 188($t0)
	sw $t1, 192($t0)
	#4
	addi $t0, $t0, 256
	
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	
	sw $t1, 20($t0)
	sw $t1, 24($t0)

	sw $t1, 32($t0)
	sw $t1, 36($t0)
	
	sw $t1, 44($t0)
	sw $t1, 48($t0)

	sw $t1, 56($t0)
	sw $t1, 60($t0)
	
	sw $t1, 68($t0)
	sw $t1, 72($t0)
	
	sw $t1, 84($t0)
	sw $t1, 88($t0)
	
	sw $t1, 96($t0)
	sw $t1, 100($t0)
	sw $t1, 112($t0)
	sw $t1, 108($t0)
	
	sw $t1, 136($t0)
	
	
	sw $t1, 140($t0)
	
	sw $t1, 152($t0)
	sw $t1, 156($t0)
	
	sw $t1, 164($t0)
	sw $t1, 168($t0)
	
	sw $t1, 176($t0)
	sw $t1, 180($t0)
	
	sw $t1, 188($t0)
	sw $t1, 192($t0)
	#5
	addi $t0, $t0, 256
	
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	
	sw $t1, 20($t0)
	sw $t1, 24($t0)

	sw $t1, 32($t0)
	sw $t1, 36($t0)
	
	sw $t1, 44($t0)
	sw $t1, 48($t0)

	sw $t1, 56($t0)
	sw $t1, 60($t0)
	
	sw $t1, 68($t0)
	sw $t1, 72($t0)
	
	sw $t1, 84($t0)
	sw $t1, 88($t0)
	
	sw $t1, 96($t0)
	sw $t1, 100($t0)
	sw $t1, 112($t0)
	sw $t1, 108($t0)
	
	sw $t1, 136($t0)
	
	
	sw $t1, 140($t0)
	
	sw $t1, 152($t0)
	sw $t1, 156($t0)
	
	sw $t1, 164($t0)
	sw $t1, 168($t0)
	
	sw $t1, 176($t0)
	sw $t1, 180($t0)
	
	sw $t1, 188($t0)
	sw $t1, 192($t0)
	#6
	addi $t0, $t0, 256
	
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	
	sw $t1, 20($t0)
	sw $t1, 24($t0)

	sw $t1, 32($t0)
	sw $t1, 36($t0)
	
	sw $t1, 44($t0)
	sw $t1, 48($t0)

	sw $t1, 56($t0)
	sw $t1, 60($t0)
	
	sw $t1, 68($t0)
	sw $t1, 72($t0)
	
	sw $t1, 84($t0)
	sw $t1, 88($t0)
	
	sw $t1, 96($t0)
	sw $t1, 100($t0)
	sw $t1, 112($t0)
	sw $t1, 108($t0)
	
	sw $t1, 136($t0)
	
	
	sw $t1, 140($t0)
	
	sw $t1, 152($t0)
	sw $t1, 156($t0)
	
	sw $t1, 164($t0)
	sw $t1, 168($t0)
	
	sw $t1, 176($t0)
	sw $t1, 180($t0)
	
	sw $t1, 188($t0)
	sw $t1, 192($t0)
	#7
	addi $t0, $t0, 256
	
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	
	sw $t1, 20($t0)
	sw $t1, 24($t0)

	sw $t1, 32($t0)
	sw $t1, 36($t0)
	
	sw $t1, 44($t0)
	sw $t1, 48($t0)

	sw $t1, 56($t0)
	sw $t1, 60($t0)
	
	sw $t1, 68($t0)
	sw $t1, 72($t0)
	
	sw $t1, 84($t0)
	sw $t1, 88($t0)
	
	sw $t1, 96($t0)
	sw $t1, 100($t0)
	sw $t1, 112($t0)
	sw $t1, 108($t0)
	
	sw $t1, 136($t0)
	
	
	sw $t1, 140($t0)
	
	sw $t1, 152($t0)
	sw $t1, 156($t0)
	
	sw $t1, 164($t0)
	sw $t1, 168($t0)
	
	sw $t1, 176($t0)
	sw $t1, 180($t0)
	sw $t1, 160($t0)
	sw $t1, 184($t0)
	sw $t1, 188($t0)
	sw $t1, 192($t0)
	#8
	addi $t0, $t0, 256
	#9
		addi $t0, $t0, 256
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	
	sw $t1, 24($t0)
	sw $t1, 28($t0)
	sw $t1, 32($t0)
	sw $t1, 36($t0)
	sw $t1, 40($t0)
	
	sw $t1, 48($t0)
	sw $t1, 52($t0)
	sw $t1, 56($t0)
	sw $t1, 60($t0)
	sw $t1, 64($t0)
	sw $t1, 80($t0)
	sw $t1, 84($t0)
	
	sw $t1, 92($t0)
	sw $t1, 96($t0)
	sw $t1, 104($t0)
	sw $t1, 108($t0)
	sw $t1, 112($t0)
	sw $t1, 116($t0)
	sw $t1, 120($t0)
	sw $t1, 128($t0)
	sw $t1, 132($t0)
	
	sw $t1, 140($t0)
	sw $t1, 144($t0)
	
	sw $t1, 176($t0)
	sw $t1, 180($t0)
	sw $t1, 184($t0)
		
	#10
		addi $t0, $t0, 256
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	
	sw $t1, 24($t0)
	sw $t1, 28($t0)
	
	sw $t1, 36($t0)
	sw $t1, 40($t0)
	
	sw $t1, 48($t0)
	sw $t1, 52($t0)
	
	sw $t1, 60($t0)
	sw $t1, 64($t0)
	sw $t1, 80($t0)
	sw $t1, 84($t0)
	
	sw $t1, 92($t0)
	sw $t1, 96($t0)
	sw $t1, 104($t0)
	sw $t1, 108($t0)
	
	sw $t1, 116($t0)
	sw $t1, 120($t0)
	sw $t1, 128($t0)
	sw $t1, 132($t0)
	
	sw $t1, 140($t0)
	sw $t1, 144($t0)
	sw $t1, 164($t0)
	
	sw $t1, 180($t0)
	sw $t1, 184($t0)
	sw $t1, 188($t0)

	#11
		addi $t0, $t0, 256
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	
	sw $t1, 24($t0)
	sw $t1, 28($t0)
	
	sw $t1, 48($t0)
	sw $t1, 52($t0)
	
	sw $t1, 80($t0)
	sw $t1, 84($t0)
	
	sw $t1, 92($t0)
	sw $t1, 96($t0)
	sw $t1, 104($t0)
	sw $t1, 108($t0)
	
	sw $t1, 116($t0)
	sw $t1, 120($t0)
	sw $t1, 128($t0)
	sw $t1, 132($t0)
	
	sw $t1, 140($t0)
	sw $t1, 144($t0)
	
	
	sw $t1, 184($t0)
	sw $t1, 188($t0)

	#12
		addi $t0, $t0, 256
	
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	sw $t1, 12($t0)
	
	sw $t1, 24($t0)
	sw $t1, 28($t0)
	sw $t1, 32($t0)
	sw $t1, 36($t0)
	
	sw $t1, 48($t0)
	sw $t1, 52($t0)
	sw $t1, 56($t0)
	sw $t1, 60($t0)
	
	sw $t1, 84($t0)
	sw $t1, 88($t0)
	sw $t1, 92($t0)
	sw $t1, 96($t0)
	sw $t1, 104($t0)
	sw $t1, 108($t0)
	
	sw $t1, 116($t0)
	sw $t1, 120($t0)
	sw $t1, 128($t0)
	sw $t1, 132($t0)
	
	sw $t1, 140($t0)
	sw $t1, 144($t0)
	
	sw $t1, 184($t0)
	sw $t1, 188($t0)

	#13
		addi $t0, $t0, 256
	
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	
	sw $t1, 24($t0)
	sw $t1, 28($t0)
	
	sw $t1, 48($t0)
	sw $t1, 52($t0)
	
	sw $t1, 88($t0)
	sw $t1, 92($t0)
	
	sw $t1, 104($t0)
	sw $t1, 108($t0)
	
	sw $t1, 116($t0)
	sw $t1, 120($t0)
	sw $t1, 128($t0)
	sw $t1, 132($t0)
	
	sw $t1, 140($t0)
	sw $t1, 144($t0)
	
	sw $t1, 184($t0)
	sw $t1, 188($t0)

	#14
	addi $t0, $t0, 256
	
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	
	sw $t1, 24($t0)
	sw $t1, 28($t0)
	
	sw $t1, 48($t0)
	sw $t1, 52($t0)
	
	sw $t1, 88($t0)
	sw $t1, 92($t0)
	
	sw $t1, 104($t0)
	sw $t1, 108($t0)
	
	sw $t1, 116($t0)
	sw $t1, 120($t0)
	sw $t1, 128($t0)
	sw $t1, 132($t0)
	
	sw $t1, 140($t0)
	sw $t1, 144($t0)
	
	sw $t1, 184($t0)
	sw $t1, 188($t0)
	#15
		addi $t0, $t0, 256
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	
	sw $t1, 24($t0)
	sw $t1, 28($t0)
	
	sw $t1, 36($t0)
	sw $t1, 40($t0)
	
	sw $t1, 48($t0)
	sw $t1, 52($t0)
	
	sw $t1, 60($t0)
	sw $t1, 64($t0)
	
	sw $t1, 88($t0)
	sw $t1, 92($t0)
	
	sw $t1, 104($t0)
	sw $t1, 108($t0)
	
	sw $t1, 116($t0)
	sw $t1, 120($t0)
	sw $t1, 128($t0)
	sw $t1, 132($t0)
	
	sw $t1, 140($t0)
	sw $t1, 144($t0)
	
	sw $t1, 180($t0)
	sw $t1, 184($t0)
	sw $t1, 188($t0)

	#16	
		addi $t0, $t0, 256
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	
	sw $t1, 24($t0)
	sw $t1, 28($t0)
	sw $t1, 32($t0)
	sw $t1, 36($t0)
	sw $t1, 40($t0)
	
	sw $t1, 48($t0)
	sw $t1, 52($t0)
	sw $t1, 56($t0)
	sw $t1, 60($t0)
	sw $t1, 64($t0)
	
	sw $t1, 88($t0)
	sw $t1, 92($t0)
	
	sw $t1, 104($t0)
	sw $t1, 108($t0)
	sw $t1, 112($t0)
	sw $t1, 116($t0)
	sw $t1, 120($t0)
	sw $t1, 128($t0)
	sw $t1, 132($t0)
	sw $t1, 136($t0)
	sw $t1, 140($t0)
	sw $t1, 144($t0)
	sw $t1, 164($t0)
	sw $t1, 176($t0)
	sw $t1, 180($t0)
	sw $t1, 184($t0)
	

	li $v0, 10 # terminate the program gracefully
	syscall

start_quit_at_end:
	# start, quit
	
	li $t0, base_address
	addi $t0, $t0, 8504
	bne $a0, black, set_red
	li $t1, black
	j draw_start_quit_at_end
set_red:
	li $t1, red
draw_start_quit_at_end:
	#0
	
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	sw $t1, 20($t0)
	sw $t1, 24($t0)
	sw $t1, 28($t0)
	
	sw $t1, 52($t0)
	sw $t1, 56($t0)
	sw $t1, 60($t0)
	sw $t1, 64($t0)
	
	sw $t1, 72($t0)
	sw $t1, 76($t0)
	sw $t1, 80($t0)
	sw $t1, 84($t0)
	sw $t1, 88($t0)
	
	sw $t1, 96($t0)
	sw $t1, 100($t0)
	sw $t1, 104($t0)
	sw $t1, 108($t0)
	sw $t1, 112($t0)
	
	sw $t1, 120($t0)
	sw $t1, 124($t0)
	sw $t1, 128($t0)
	sw $t1, 132($t0)
	
	#1
	addi $t0, $t0, 256
	sw $t1, 0($t0)
	
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	
	sw $t1, 24($t0)
	sw $t1, 28($t0)
	
	sw $t1, 40($t0)
	
	sw $t1, 56($t0)
	sw $t1, 60($t0)
	
	sw $t1, 72($t0)
	sw $t1, 76($t0)
	
	sw $t1, 84($t0)
	sw $t1, 88($t0)
	
	sw $t1, 96($t0)
	sw $t1, 100($t0)
	
	sw $t1, 108($t0)
	sw $t1, 112($t0)
	
	sw $t1, 124($t0)
	sw $t1, 128($t0)
	
	
	#2
	addi $t0, $t0, 256
	sw $t1, 0($t0)
	
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	
	sw $t1, 40($t0)
	
	sw $t1, 56($t0)
	sw $t1, 60($t0)
	
	sw $t1, 72($t0)
	sw $t1, 76($t0)
	
	sw $t1, 84($t0)
	sw $t1, 88($t0)
	
	sw $t1, 96($t0)
	sw $t1, 100($t0)
	
	sw $t1, 108($t0)
	sw $t1, 112($t0)
	
	sw $t1, 124($t0)
	sw $t1, 128($t0)

	
	#3
	addi $t0, $t0, 256
	
	sw $t1, 16($t0)
	sw $t1, 20($t0)
	sw $t1, 24($t0)
	
	sw $t1, 56($t0)
	sw $t1, 60($t0)
	
	sw $t1, 72($t0)
	sw $t1, 76($t0)
	sw $t1, 80($t0)
	sw $t1, 84($t0)
	sw $t1, 88($t0)
	
	sw $t1, 96($t0)
	sw $t1, 100($t0)
	sw $t1, 104($t0)
	sw $t1, 108($t0)
	
	sw $t1, 124($t0)
	sw $t1, 128($t0)

	
	#4
	addi $t0, $t0, 256
	
	sw $t1, 24($t0)
	sw $t1, 28($t0)
	
	sw $t1, 56($t0)
	sw $t1, 60($t0)
	
	sw $t1, 72($t0)
	sw $t1, 76($t0)
	
	sw $t1, 84($t0)
	sw $t1, 88($t0)
	
	sw $t1, 96($t0)
	sw $t1, 100($t0)
	
	sw $t1, 108($t0)
	sw $t1, 112($t0)
	
	sw $t1, 124($t0)
	sw $t1, 128($t0)

	
	#5
	addi $t0, $t0, 256
	sw $t1, 24($t0)
	sw $t1, 28($t0)
	
	sw $t1, 56($t0)
	sw $t1, 60($t0)
	
	sw $t1, 72($t0)
	sw $t1, 76($t0)
	
	sw $t1, 84($t0)
	sw $t1, 88($t0)
	
	sw $t1, 96($t0)
	sw $t1, 100($t0)
	
	sw $t1, 108($t0)
	sw $t1, 112($t0)
	
	sw $t1, 124($t0)
	sw $t1, 128($t0)
	#6
	addi $t0, $t0, 256
		
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	
	sw $t1, 24($t0)
	sw $t1, 28($t0)
	
	sw $t1, 56($t0)
	sw $t1, 60($t0)
	
	sw $t1, 72($t0)
	sw $t1, 76($t0)
	
	sw $t1, 84($t0)
	sw $t1, 88($t0)
	
	sw $t1, 96($t0)
	sw $t1, 100($t0)
	
	sw $t1, 108($t0)
	sw $t1, 112($t0)
	
	
	sw $t1, 124($t0)
	sw $t1, 128($t0)

	
	#7
	addi $t0, $t0, 256
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	sw $t1, 20($t0)
	sw $t1, 24($t0)
	sw $t1, 28($t0)
	
	sw $t1, 56($t0)
	sw $t1, 60($t0)
	
	sw $t1, 72($t0)
	sw $t1, 76($t0)
	
	sw $t1, 84($t0)
	sw $t1, 88($t0)
	
	sw $t1, 96($t0)
	sw $t1, 100($t0)
	
	sw $t1, 108($t0)
	sw $t1, 112($t0)
	
	
	sw $t1, 124($t0)
	sw $t1, 128($t0)
	#8
	addi $t0, $t0, 256
	#9
	addi $t0, $t0, 256
	
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	sw $t1, 20($t0)
	sw $t1, 24($t0)
	sw $t1, 28($t0)
	
	sw $t1, 56($t0)
	sw $t1, 60($t0)
	
	sw $t1, 68($t0)
	sw $t1, 72($t0)
	sw $t1, 80($t0)
	sw $t1, 84($t0)
	sw $t1, 88($t0)
	sw $t1, 92($t0)
	sw $t1, 100($t0)
	sw $t1, 104($t0)
	sw $t1, 108($t0)
	sw $t1, 112($t0)
	
	#10
	addi $t0, $t0, 256
	sw $t1, 0($t0)
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	
	sw $t1, 24($t0)
	sw $t1, 28($t0)
	
	sw $t1, 44($t0)
	sw $t1, 56($t0)
	sw $t1, 60($t0)
	
	sw $t1, 68($t0)
	sw $t1, 72($t0)
	
	sw $t1, 84($t0)
	sw $t1, 88($t0)
	
	sw $t1, 104($t0)
	sw $t1, 108($t0)
	
	
	#11
	addi $t0, $t0, 256
	sw $t1, 0($t0)
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	
	sw $t1, 24($t0)
	sw $t1, 28($t0)
	
	sw $t1, 44($t0)
	sw $t1, 56($t0)
	sw $t1, 60($t0)
	
	sw $t1, 68($t0)
	sw $t1, 72($t0)
	
	sw $t1, 84($t0)
	sw $t1, 88($t0)
	
	sw $t1, 104($t0)
	sw $t1, 108($t0)
	
	
	#12
	addi $t0, $t0, 256
	
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	
	sw $t1, 24($t0)
	sw $t1, 28($t0)
	
	sw $t1, 56($t0)
	sw $t1, 60($t0)
	
	sw $t1, 68($t0)
	sw $t1, 72($t0)
	
	sw $t1, 84($t0)
	sw $t1, 88($t0)
	
	sw $t1, 104($t0)
	sw $t1, 108($t0)
	
	
	#13
	addi $t0, $t0, 256
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	
	sw $t1, 24($t0)
	sw $t1, 28($t0)
	
	sw $t1, 56($t0)
	sw $t1, 60($t0)
	
	sw $t1, 68($t0)
	sw $t1, 72($t0)
	
	sw $t1, 84($t0)
	sw $t1, 88($t0)
	
	sw $t1, 104($t0)
	sw $t1, 108($t0)
	
	#14
	addi $t0, $t0, 256
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	
	sw $t1, 24($t0)
	sw $t1, 28($t0)
	
	sw $t1, 56($t0)
	sw $t1, 60($t0)
	
	sw $t1, 68($t0)
	sw $t1, 72($t0)
	
	sw $t1, 84($t0)
	sw $t1, 88($t0)
	
	sw $t1, 104($t0)
	sw $t1, 108($t0)
	
	#15
	addi $t0, $t0, 256
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	
	sw $t1, 24($t0)
	sw $t1, 28($t0)
	sw $t1, 32($t0)
	sw $t1, 56($t0)
	sw $t1, 60($t0)
	
	sw $t1, 68($t0)
	sw $t1, 72($t0)
	
	sw $t1, 84($t0)
	sw $t1, 88($t0)
	
	sw $t1, 104($t0)
	sw $t1, 108($t0)
	
	#16
	addi $t0, $t0, 256
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	sw $t1, 20($t0)
	sw $t1, 24($t0)
	sw $t1, 28($t0)
	
	sw $t1, 56($t0)
	sw $t1, 60($t0)
	sw $t1, 64($t0)
	sw $t1, 68($t0)
	sw $t1, 72($t0)
	sw $t1, 80($t0)
	sw $t1, 84($t0)
	sw $t1, 88($t0)
	sw $t1, 92($t0)
	sw $t1, 104($t0)
	sw $t1, 108($t0)
check_start_at_end:
	#check user input
	li $t0, 0xffff0000 	# $t0=address of 0xffff0000 
	lw $t1, 0($t0)		# $t1=whether user has input something
	beq $t1, 1, continue_check_start_at_end
	j check_start_at_end
continue_check_start_at_end:
	lw $t1, 4($t0)
	beq $t1, 115, setup	# press 's'
	beq $t1, 113, END_PROGRAM	# press 'q'
	j check_start_at_end

draw_red_hamster:
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
	addi $t1, $zero, black1
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
	li $t1, oldlace1
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
	li $t1, gold1
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
	li $t1, moccasin1
	sw $t1, 516($t0)
	sw $t1, 532($t0)
	sw $t1, 772($t0)
	sw $t1, 788($t0)
	# paint tan to all tan hamster pixels
	# store tan color in $t1
	li $t1, tan1
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
you_win:
	li 	$t0, base_address	# $t0=the base address for display
	li 	$t1, 4096		# $t1=64*64=4096 units
	li 	$t2, skyblue		# $t2=skyblue color
bg3:	sw   	$t2, 0($t0)		# paint the whole screen to skyblue
	addi 	$t0, $t0, 4 		# advance to next unit position in display
	addi 	$t1, $t1, -1		# decrement number of units
	bnez 	$t1, bg3
	li $t1, black
	
	li $t0, base_address
	addi $t0, $t0, 5660
		#0
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	sw $t1, 20($t0)
	sw $t1, 28($t0)
	sw $t1, 32($t0)
	sw $t1, 36($t0)
	sw $t1, 40($t0)
	sw $t1, 44($t0)
	sw $t1, 52($t0)
	sw $t1, 56($t0)
	
	sw $t1, 64($t0)
	sw $t1, 68($t0)
	sw $t1, 84($t0)
	sw $t1, 88($t0)
	
	sw $t1, 104($t0)
	sw $t1, 108($t0)
	sw $t1, 116($t0)
	sw $t1, 120($t0)
	sw $t1, 124($t0)
	sw $t1, 128($t0)
	sw $t1, 136($t0)
	sw $t1, 140($t0)
	
	sw $t1, 152($t0)
	sw $t1, 156($t0)
	sw $t1, 164($t0)
	sw $t1, 168($t0)
	sw $t1, 176($t0)
	sw $t1, 180($t0)
	sw $t1, 188($t0)
	sw $t1, 192($t0)
	#1
	addi $t0, $t0, 256
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	sw $t1, 20($t0)
	sw $t1, 28($t0)
	sw $t1, 32($t0)
	
	sw $t1, 40($t0)
	sw $t1, 44($t0)
	sw $t1, 52($t0)
	sw $t1, 56($t0)
	
	sw $t1, 64($t0)
	sw $t1, 68($t0)
	sw $t1, 84($t0)
	sw $t1, 88($t0)
	
	sw $t1, 104($t0)
	sw $t1, 108($t0)
	
	sw $t1, 120($t0)
	sw $t1, 124($t0)
	
	sw $t1, 136($t0)
	sw $t1, 140($t0)
	sw $t1, 144($t0)
	
	sw $t1, 152($t0)
	sw $t1, 156($t0)
	sw $t1, 164($t0)
	sw $t1, 168($t0)
	sw $t1, 176($t0)
	sw $t1, 180($t0)
	sw $t1, 188($t0)
	sw $t1, 192($t0)
	#2
	addi $t0, $t0, 256
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	sw $t1, 20($t0)
	sw $t1, 28($t0)
	sw $t1, 32($t0)
	
	sw $t1, 40($t0)
	sw $t1, 44($t0)
	sw $t1, 52($t0)
	sw $t1, 56($t0)
	
	sw $t1, 64($t0)
	sw $t1, 68($t0)
	sw $t1, 84($t0)
	sw $t1, 88($t0)
	
	sw $t1, 104($t0)
	sw $t1, 108($t0)
	
	sw $t1, 120($t0)
	sw $t1, 124($t0)
	
	sw $t1, 136($t0)
	sw $t1, 140($t0)
	sw $t1, 144($t0)
	sw $t1, 148($t0)
	sw $t1, 152($t0)
	sw $t1, 156($t0)
	sw $t1, 164($t0)
	sw $t1, 168($t0)
	sw $t1, 176($t0)
	sw $t1, 180($t0)
	sw $t1, 188($t0)
	sw $t1, 192($t0)
	#3
	addi $t0, $t0, 256
	
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	sw $t1, 20($t0)
	sw $t1, 28($t0)
	sw $t1, 32($t0)
	
	sw $t1, 40($t0)
	sw $t1, 44($t0)
	sw $t1, 52($t0)
	sw $t1, 56($t0)
	
	sw $t1, 64($t0)
	sw $t1, 68($t0)
	sw $t1, 84($t0)
	sw $t1, 88($t0)
	
	sw $t1, 104($t0)
	sw $t1, 108($t0)
	
	sw $t1, 120($t0)
	sw $t1, 124($t0)
	
	sw $t1, 136($t0)
	sw $t1, 140($t0)
	
	sw $t1, 148($t0)
	sw $t1, 152($t0)
	sw $t1, 156($t0)
	sw $t1, 164($t0)
	sw $t1, 168($t0)
	sw $t1, 176($t0)
	sw $t1, 180($t0)
	sw $t1, 188($t0)
	sw $t1, 192($t0)
	#4
	addi $t0, $t0, 256
	
	sw $t1, 8($t0)
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	
	sw $t1, 28($t0)
	sw $t1, 32($t0)
	
	sw $t1, 40($t0)
	sw $t1, 44($t0)
	sw $t1, 52($t0)
	sw $t1, 56($t0)
	
	sw $t1, 64($t0)
	sw $t1, 68($t0)
	sw $t1, 84($t0)
	sw $t1, 88($t0)
	
	sw $t1, 96($t0)
	
	sw $t1, 104($t0)
	sw $t1, 108($t0)
	
	sw $t1, 120($t0)
	sw $t1, 124($t0)
	
	sw $t1, 136($t0)
	sw $t1, 140($t0)
	
	sw $t1, 152($t0)
	sw $t1, 156($t0)
	sw $t1, 164($t0)
	sw $t1, 168($t0)
	sw $t1, 176($t0)
	sw $t1, 180($t0)
	sw $t1, 188($t0)
	sw $t1, 192($t0)
	#5
	addi $t0, $t0, 256
	
	sw $t1, 8($t0)
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	
	sw $t1, 28($t0)
	sw $t1, 32($t0)
	
	sw $t1, 40($t0)
	sw $t1, 44($t0)
	sw $t1, 52($t0)
	sw $t1, 56($t0)
	
	sw $t1, 64($t0)
	sw $t1, 68($t0)
	sw $t1, 84($t0)
	sw $t1, 88($t0)
	
	sw $t1, 96($t0)
	
	sw $t1, 104($t0)
	sw $t1, 108($t0)
	
	sw $t1, 120($t0)
	sw $t1, 124($t0)
	
	sw $t1, 136($t0)
	sw $t1, 140($t0)
	
	sw $t1, 152($t0)
	sw $t1, 156($t0)
	
	
	#6
	addi $t0, $t0, 256
	
	sw $t1, 8($t0)
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	
	sw $t1, 28($t0)
	sw $t1, 32($t0)
	
	sw $t1, 40($t0)
	sw $t1, 44($t0)
	sw $t1, 52($t0)
	sw $t1, 56($t0)
	
	sw $t1, 64($t0)
	sw $t1, 68($t0)
	
	sw $t1, 88($t0)
	sw $t1, 92($t0)
	sw $t1, 96($t0)
	sw $t1, 100($t0)
	sw $t1, 104($t0)
	
	
	sw $t1, 120($t0)
	sw $t1, 124($t0)
	
	sw $t1, 136($t0)
	sw $t1, 140($t0)
	
	sw $t1, 152($t0)
	sw $t1, 156($t0)
	sw $t1, 164($t0)
	sw $t1, 168($t0)
	sw $t1, 176($t0)
	sw $t1, 180($t0)
	sw $t1, 188($t0)
	sw $t1, 192($t0)
	#7
	addi $t0, $t0, 256
	
	sw $t1, 8($t0)
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	
	sw $t1, 28($t0)
	sw $t1, 32($t0)
	sw $t1, 36($t0)
	sw $t1, 40($t0)
	sw $t1, 44($t0)
	sw $t1, 52($t0)
	sw $t1, 56($t0)
	sw $t1, 60($t0)
	sw $t1, 64($t0)
	sw $t1, 68($t0)
	
	sw $t1, 92($t0)
	
	sw $t1, 100($t0)
	
	sw $t1, 116($t0)
	sw $t1, 120($t0)
	sw $t1, 124($t0)
	sw $t1, 128($t0)
	sw $t1, 136($t0)
	sw $t1, 140($t0)
	
	sw $t1, 152($t0)
	sw $t1, 156($t0)
	sw $t1, 164($t0)
	sw $t1, 168($t0)
	sw $t1, 176($t0)
	sw $t1, 180($t0)
	sw $t1, 188($t0)
	sw $t1, 192($t0)
	li $a0, black
	j start_quit_at_end

draw_heart:
	addi $sp, $sp, -12
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $ra, 8($sp)
	li $t0, base_address
	addi $t0, $t0,16896
	add $t0, $t0, $a0
	li $t1, red
	
	sw $t1, 0($t0)
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	sw $t1, 252($t0)
	sw $t1, 256($t0)
	sw $t1, 260($t0)
	sw $t1, 264($t0)
	sw $t1, 268($t0)
	sw $t1, 272($t0)
	sw $t1, 276($t0)
	sw $t1, 508($t0)
	sw $t1, 512($t0)
	sw $t1, 516($t0)
	sw $t1, 520($t0)
	sw $t1, 524($t0)
	sw $t1, 528($t0)
	sw $t1, 532($t0)
	sw $t1, 764($t0)
	sw $t1, 768($t0)
	sw $t1, 772($t0)
	sw $t1, 776($t0)
	sw $t1, 780($t0)
	sw $t1, 784($t0)
	sw $t1, 788($t0)
	sw $t1, 1024($t0)
	sw $t1, 1028($t0)
	sw $t1, 1032($t0)
	sw $t1, 1036($t0)
	sw $t1, 1040($t0)
	sw $t1, 1284($t0)
	sw $t1, 1288($t0)
	sw $t1, 1292($t0)
	sw $t1, 1544($t0)
	
	lw $t0, 0($sp)
	lw $t1, 4($sp)
	lw $ra, 8($sp)
	addi $sp, $sp, 12
	jr $ra
erase_heart:
	addi $sp, $sp, -12
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $ra, 8($sp)
	li $t0, base_address
	addi $t0, $t0,16896
	add $t0, $t0, $a0
	li $t1, gray
	
	
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	sw $t1, 252($t0)
	sw $t1, 256($t0)
	sw $t1, 260($t0)
	sw $t1, 264($t0)
	sw $t1, 268($t0)
	sw $t1, 272($t0)
	sw $t1, 276($t0)
	sw $t1, 508($t0)
	sw $t1, 512($t0)
	sw $t1, 516($t0)
	sw $t1, 520($t0)
	sw $t1, 524($t0)
	sw $t1, 528($t0)
	sw $t1, 532($t0)
	sw $t1, 764($t0)
	sw $t1, 768($t0)
	sw $t1, 772($t0)
	sw $t1, 776($t0)
	sw $t1, 780($t0)
	sw $t1, 784($t0)
	sw $t1, 788($t0)
	sw $t1, 1024($t0)
	sw $t1, 1028($t0)
	sw $t1, 1032($t0)
	sw $t1, 1036($t0)
	sw $t1, 1040($t0)
	sw $t1, 1284($t0)
	sw $t1, 1288($t0)
	sw $t1, 1292($t0)
	sw $t1, 1544($t0)
	li $t1, darkgray
	sw $t1, 264($t0)
	sw $t1, 516($t0)
	sw $t1, 776($t0)
	sw $t1, 1036($t0)
	sw $t1, 1288($t0)
	
	
	lw $t0, 0($sp)
	lw $t1, 4($sp)
	lw $ra, 8($sp)
	addi $sp, $sp, 12
	jr $ra	
draw_0:
	addi $sp, $sp, -12
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $ra, 8($sp)
	li $t0, base_address
	addi $t0, $t0,16640
	add $t0, $t0, $a0
	
	li $t1, wordcolor
	
	

	sw $t1, 4($t0)
	sw $t1, 8($t0)
	sw $t1, 12($t0)

	sw $t1, 256($t0)
	sw $t1, 260($t0)

	sw $t1, 268($t0)
	sw $t1, 272($t0)
	sw $t1, 512($t0)
	sw $t1, 516($t0)

	sw $t1, 524($t0)
	sw $t1, 528($t0)
	sw $t1, 768($t0)
	sw $t1, 772($t0)
	sw $t1, 780($t0)
	sw $t1, 784($t0)
	sw $t1, 1024($t0)
	sw $t1, 1028($t0)
	sw $t1, 1036($t0)
	sw $t1, 1040($t0)
	sw $t1, 1280($t0)
	sw $t1, 1284($t0)
	sw $t1, 1292($t0)
	sw $t1, 1296($t0)
	sw $t1, 1536($t0)
	sw $t1, 1540($t0)
	sw $t1, 1548($t0)
	sw $t1, 1552($t0)
	sw $t1, 1796($t0)
	sw $t1, 1800($t0)
	sw $t1, 1804($t0)

	lw $t0, 0($sp)
	lw $t1, 4($sp)
	lw $ra, 8($sp)
	addi $sp, $sp, 12
	jr $ra
draw_1:
	addi $sp, $sp, -12
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $ra, 8($sp)
	li $t0, base_address
	addi $t0, $t0,16640
	add $t0, $t0, $a0
	li $t1, wordcolor
	
	
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	
	sw $t1, 256($t0)
	sw $t1, 260($t0)
	sw $t1, 264($t0)
	
	
	sw $t1, 516($t0)
	sw $t1, 520($t0)
	
	sw $t1, 772($t0)
	sw $t1, 776($t0)
	
	sw $t1, 1028($t0)
	sw $t1, 1032($t0)
	
	sw $t1, 1284($t0)
	sw $t1, 1288($t0)
	
	sw $t1, 1540($t0)
	sw $t1, 1544($t0)
	
	sw $t1, 1792($t0)
	sw $t1, 1796($t0)
	sw $t1, 1800($t0)
	sw $t1, 1804($t0)
	
	
	lw $t0, 0($sp)
	lw $t1, 4($sp)
	lw $ra, 8($sp)
	addi $sp, $sp, 12
	jr $ra
draw_2:
	addi $sp, $sp, -12
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $ra, 8($sp)
	li $t0, base_address
	addi $t0, $t0,16640
	add $t0, $t0, $a0
	li $t1, wordcolor
	
	
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	sw $t1, 12($t0)
	sw $t1, 256($t0)
	sw $t1, 260($t0)
	sw $t1, 268($t0)
	sw $t1, 272($t0)

	sw $t1, 524($t0)
	sw $t1, 528($t0)

	sw $t1, 776($t0)
	sw $t1, 780($t0)

	sw $t1, 1028($t0)
	sw $t1, 1032($t0)

	sw $t1, 1280($t0)
	sw $t1, 1284($t0)

	sw $t1, 1536($t0)
	sw $t1, 1540($t0)
	sw $t1, 1548($t0)
	sw $t1, 1552($t0)
	sw $t1, 1796($t0)
	sw $t1, 1800($t0)
	sw $t1, 1804($t0)
	sw $t1, 1808($t0)
	lw $t0, 0($sp)
	lw $t1, 4($sp)
	lw $ra, 8($sp)
	addi $sp, $sp, 12
	jr $ra	
draw_3:
	addi $sp, $sp, -12
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $ra, 8($sp)
	li $t0, base_address
	addi $t0, $t0,16640
	add $t0, $t0, $a0
	li $t1, wordcolor
	
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	sw $t1, 12($t0)
	sw $t1, 256($t0)
	sw $t1, 260($t0)
	sw $t1, 268($t0)
	sw $t1, 272($t0)

	sw $t1, 524($t0)
	sw $t1, 528($t0)

	sw $t1, 776($t0)
	sw $t1, 780($t0)

	sw $t1, 1036($t0)
	sw $t1, 1040($t0)

	sw $t1, 1292($t0)
	sw $t1, 1296($t0)
	sw $t1, 1536($t0)
	sw $t1, 1540($t0)
	sw $t1, 1548($t0)
	sw $t1, 1552($t0)
	sw $t1, 1796($t0)
	sw $t1, 1800($t0)
	sw $t1, 1804($t0)

	
	lw $t0, 0($sp)
	lw $t1, 4($sp)
	lw $ra, 8($sp)
	addi $sp, $sp, 12
	jr $ra	
draw_4:
	addi $sp, $sp, -12
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $ra, 8($sp)
	li $t0, base_address
	addi $t0, $t0,16640
	add $t0, $t0, $a0
	li $t1, wordcolor
	
	sw $t1, 4($t0)
	sw $t1, 12($t0)
	sw $t1, 256($t0)
	sw $t1, 260($t0)
	sw $t1, 268($t0)
	sw $t1, 272($t0)
	sw $t1, 512($t0)
	sw $t1, 516($t0)
	sw $t1, 524($t0)
	sw $t1, 528($t0)
	sw $t1, 768($t0)
	sw $t1, 772($t0)
	sw $t1, 776($t0)
	sw $t1, 780($t0)
	sw $t1, 784($t0)

	sw $t1, 1036($t0)
	sw $t1, 1040($t0)

	sw $t1, 1292($t0)
	sw $t1, 1296($t0)

	sw $t1, 1548($t0)
	sw $t1, 1552($t0)

	sw $t1, 1804($t0)

	
	lw $t0, 0($sp)
	lw $t1, 4($sp)
	lw $ra, 8($sp)
	addi $sp, $sp, 12
	jr $ra
draw_5:
	addi $sp, $sp, -12
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $ra, 8($sp)
	li $t0, base_address
	addi $t0, $t0,16640
	add $t0, $t0, $a0
	li $t1, wordcolor
	
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	sw $t1, 256($t0)
	sw $t1, 260($t0)
	sw $t1, 268($t0)
	sw $t1, 272($t0)
	sw $t1, 512($t0)
	sw $t1, 516($t0)

	sw $t1, 768($t0)
	sw $t1, 772($t0)
	sw $t1, 776($t0)
	sw $t1, 780($t0)

	sw $t1, 1036($t0)
	sw $t1, 1040($t0)

	sw $t1, 1292($t0)
	sw $t1, 1296($t0)
	sw $t1, 1536($t0)
	sw $t1, 1540($t0)
	sw $t1, 1548($t0)
	sw $t1, 1552($t0)
	sw $t1, 1792($t0)
	sw $t1, 1796($t0)
	sw $t1, 1800($t0)
	sw $t1, 1804($t0)

	
	lw $t0, 0($sp)
	lw $t1, 4($sp)
	lw $ra, 8($sp)
	addi $sp, $sp, 12
	jr $ra
draw_6:
	addi $sp, $sp, -12
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $ra, 8($sp)
	li $t0, base_address
	addi $t0, $t0,16640
	add $t0, $t0, $a0
	li $t1, wordcolor
	
	
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	sw $t1, 12($t0)
	sw $t1, 256($t0)
	sw $t1, 260($t0)
	sw $t1, 268($t0)
	sw $t1, 272($t0)
	sw $t1, 512($t0)
	sw $t1, 516($t0)
	sw $t1, 768($t0)
	sw $t1, 772($t0)
	sw $t1, 776($t0)
	sw $t1, 780($t0)
	sw $t1, 1024($t0)
	sw $t1, 1028($t0)
	sw $t1, 1036($t0)
	sw $t1, 1040($t0)
	sw $t1, 1280($t0)
	sw $t1, 1284($t0)
	sw $t1, 1292($t0)
	sw $t1, 1296($t0)
	sw $t1, 1536($t0)
	sw $t1, 1540($t0)
	sw $t1, 1548($t0)
	sw $t1, 1552($t0)
	sw $t1, 1796($t0)
	sw $t1, 1800($t0)
	sw $t1, 1804($t0)

	lw $t0, 0($sp)
	lw $t1, 4($sp)
	lw $ra, 8($sp)
	addi $sp, $sp, 12
	jr $ra
draw_7:
	addi $sp, $sp, -12
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $ra, 8($sp)
	li $t0, base_address
	addi $t0, $t0,16640
	add $t0, $t0, $a0
	li $t1, wordcolor
	
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	sw $t1, 256($t0)
	sw $t1, 260($t0)
	sw $t1, 268($t0)
	sw $t1, 272($t0)

	sw $t1, 524($t0)
	sw $t1, 528($t0)

	sw $t1, 776($t0)
	sw $t1, 780($t0)
	sw $t1, 784($t0)

	sw $t1, 1032($t0)
	sw $t1, 1036($t0)

	sw $t1, 1284($t0)
	sw $t1, 1288($t0)
	sw $t1, 1292($t0)

	sw $t1, 1540($t0)
	sw $t1, 1544($t0)

	sw $t1, 1800($t0)

	
	lw $t0, 0($sp)
	lw $t1, 4($sp)
	lw $ra, 8($sp)
	addi $sp, $sp, 12
	jr $ra	
draw_8:
	addi $sp, $sp, -12
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $ra, 8($sp)
	li $t0, base_address
	addi $t0, $t0,16640
	add $t0, $t0, $a0
	li $t1, wordcolor
	
	
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	sw $t1, 12($t0)
	sw $t1, 256($t0)
	sw $t1, 260($t0)
	sw $t1, 268($t0)
	sw $t1, 272($t0)
	sw $t1, 512($t0)
	sw $t1, 516($t0)
	sw $t1, 524($t0)
	sw $t1, 528($t0)
	sw $t1, 772($t0)
	sw $t1, 776($t0)
	sw $t1, 780($t0)
	sw $t1, 1024($t0)
	sw $t1, 1028($t0)
	sw $t1, 1036($t0)
	sw $t1, 1040($t0)
	sw $t1, 1280($t0)
	sw $t1, 1284($t0)
	sw $t1, 1292($t0)
	sw $t1, 1296($t0)
	sw $t1, 1536($t0)
	sw $t1, 1540($t0)
	sw $t1, 1548($t0)
	sw $t1, 1552($t0)
	sw $t1, 1796($t0)
	sw $t1, 1800($t0)
	sw $t1, 1804($t0)

	lw $t0, 0($sp)
	lw $t1, 4($sp)
	lw $ra, 8($sp)
	addi $sp, $sp, 12
	jr $ra
draw_9:
	addi $sp, $sp, -12
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $ra, 8($sp)
	li $t0, base_address
	addi $t0, $t0,16640
	add $t0, $t0, $a0
	li $t1, wordcolor
	
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	sw $t1, 12($t0)
	sw $t1, 256($t0)
	sw $t1, 260($t0)
	sw $t1, 268($t0)
	sw $t1, 272($t0)
	sw $t1, 512($t0)
	sw $t1, 516($t0)
	sw $t1, 524($t0)
	sw $t1, 528($t0)
	sw $t1, 772($t0)
	sw $t1, 776($t0)
	sw $t1, 780($t0)
	sw $t1, 784($t0)

	sw $t1, 1036($t0)
	sw $t1, 1040($t0)

	sw $t1, 1292($t0)
	sw $t1, 1296($t0)
	sw $t1, 1536($t0)
	sw $t1, 1540($t0)
	sw $t1, 1548($t0)
	sw $t1, 1552($t0)
	sw $t1, 1796($t0)
	sw $t1, 1800($t0)
	sw $t1, 1804($t0)

	
	lw $t0, 0($sp)
	lw $t1, 4($sp)
	lw $ra, 8($sp)
	addi $sp, $sp, 12
	jr $ra	
draw_carrot_num:
	bgt $a3, 99, you_win
	addi $sp, $sp, -16
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $ra, 12($sp)
	#$t0=lowest digit
	#$t1=highest digit
	#$t2=10
	li $t2, 10
	div $a3, $t2
	mfhi $t0
	mflo $t1
	#erase number
	li $a0, 40
	jal erase_num
	li $a0, 64
	jal erase_num
	# draw $t1 at $a0=40
	# check which digit
	li $a0, 40
	beq $t1, 0, draw0_1
	beq $t1, 1, draw1_1
	beq $t1, 2, draw2_1
	beq $t1, 3, draw3_1
	beq $t1, 4, draw4_1
	beq $t1, 5, draw5_1
	beq $t1, 6, draw6_1
	beq $t1, 7, draw7_1
	beq $t1, 8, draw8_1
	beq $t1, 9, draw9_1
	j draw_lower_digit
draw0_1:jal draw_0
	j draw_lower_digit
draw1_1:jal draw_1
	j draw_lower_digit
draw2_1:jal draw_2
	j draw_lower_digit
draw3_1:jal draw_3
	j draw_lower_digit
draw4_1:jal draw_4
	j draw_lower_digit
draw5_1:jal draw_5
	j draw_lower_digit
draw6_1:jal draw_6
	j draw_lower_digit
draw7_1:jal draw_7
	j draw_lower_digit
draw8_1:jal draw_8
	j draw_lower_digit
draw9_1:jal draw_9
	j draw_lower_digit
	# draw $t0 at $a0=64
draw_lower_digit:
	li $a0, 64
	beq $t0, 0, draw0
	beq $t0, 1, draw1
	beq $t0, 2, draw2
	beq $t0, 3, draw3
	beq $t0, 4, draw4
	beq $t0, 5, draw5
	beq $t0, 6, draw6
	beq $t0, 7, draw7
	beq $t0, 8, draw8
	beq $t0, 9, draw9
	j restore_draw_carrot_num
draw0:	jal draw_0
	j restore_draw_carrot_num
draw1:	jal draw_1
	j restore_draw_carrot_num
draw2:	jal draw_2
	j restore_draw_carrot_num
draw3:	jal draw_3
	j restore_draw_carrot_num
draw4:	jal draw_4
	j restore_draw_carrot_num
draw5:	jal draw_5
	j restore_draw_carrot_num
draw6:	jal draw_6
	j restore_draw_carrot_num
draw7:	jal draw_7
	j restore_draw_carrot_num
draw8:	jal draw_8
	j restore_draw_carrot_num
draw9:	jal draw_9
	j restore_draw_carrot_num
restore_draw_carrot_num:
	lw $t0, 0($sp)
	lw $t1, 4($sp)
	lw $t2, 8($sp)
	lw $ra, 12($sp)
	addi $sp, $sp, 16
	jr $ra	
erase_num:
	addi $sp, $sp, -12
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $ra, 8($sp)
	li $t0, base_address
	addi $t0, $t0,16640
	add $t0, $t0, $a0
	beq $a1, 0, change_color
	li $t1, ground
	j set_color
change_color: li $t1, black	
set_color:	
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	sw $t1, 256($t0)
	sw $t1, 260($t0)
	sw $t1, 264($t0)
	sw $t1, 268($t0)
	sw $t1, 272($t0)
	sw $t1, 512($t0)
	sw $t1, 516($t0)
	sw $t1, 520($t0)
	sw $t1, 524($t0)
	sw $t1, 528($t0)
	sw $t1, 768($t0)
	sw $t1, 772($t0)
	sw $t1, 776($t0)
	sw $t1, 780($t0)
	sw $t1, 784($t0)
	sw $t1, 1024($t0)
	sw $t1, 1028($t0)
	sw $t1, 1032($t0)
	sw $t1, 1036($t0)
	sw $t1, 1040($t0)
	sw $t1, 1280($t0)
	sw $t1, 1284($t0)
	sw $t1, 1288($t0)
	sw $t1, 1292($t0)
	sw $t1, 1296($t0)
	sw $t1, 1536($t0)
	sw $t1, 1540($t0)
	sw $t1, 1544($t0)
	sw $t1, 1548($t0)
	sw $t1, 1552($t0)
	sw $t1, 1792($t0)
	sw $t1, 1796($t0)
	sw $t1, 1800($t0)
	sw $t1, 1804($t0)
	sw $t1, 1808($t0)
	
	lw $t0, 0($sp)
	lw $t1, 4($sp)
	lw $ra, 8($sp)
	addi $sp, $sp, 12
	jr $ra	
draw_kill_enemy_num:
	addi $sp, $sp, -16
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $ra, 12($sp)
	#$t0=lowest digit
	#$t1=highest digit
	#$t2=10
	li $t2, 10
	div $a0, $t2
	mfhi $t0
	mflo $t1
	#erase number
	li $a0, 116
	jal erase_num
	li $a0, 140
	jal erase_num
	# draw $t1 at $a0=116
	# check which digit
	li $a0, 116
	beq $t1, 0, draw0_2
	beq $t1, 1, draw1_2
	beq $t1, 2, draw2_2
	beq $t1, 3, draw3_2
	beq $t1, 4, draw4_2
	beq $t1, 5, draw5_2
	beq $t1, 6, draw6_2
	beq $t1, 7, draw7_2
	beq $t1, 8, draw8_2
	beq $t1, 9, draw9_2
	j draw_lower_digit_nut
draw0_2:jal draw_0
	j draw_lower_digit_nut
draw1_2:jal draw_1
	j draw_lower_digit_nut
draw2_2:jal draw_2
	j draw_lower_digit_nut
draw3_2:jal draw_3
	j draw_lower_digit_nut
draw4_2:jal draw_4
	j draw_lower_digit_nut
draw5_2:jal draw_5
	j draw_lower_digit_nut
draw6_2:jal draw_6
	j draw_lower_digit_nut
draw7_2:jal draw_7
	j draw_lower_digit_nut
draw8_2:jal draw_8
	j draw_lower_digit_nut
draw9_2:jal draw_9
	j draw_lower_digit_nut
	# draw $t0 at $a0=140
draw_lower_digit_nut:
	li $a0, 140
	beq $t0, 0, draw0_0
	beq $t0, 1, draw1_0
	beq $t0, 2, draw2_0
	beq $t0, 3, draw3_0
	beq $t0, 4, draw4_0
	beq $t0, 5, draw5_0
	beq $t0, 6, draw6_0
	beq $t0, 7, draw7_0
	beq $t0, 8, draw8_0
	beq $t0, 9, draw9_0
	j restore_draw_nut_num
draw0_0:jal draw_0
	j restore_draw_nut_num
draw1_0:jal draw_1
	j restore_draw_nut_num
draw2_0:jal draw_2
	j restore_draw_nut_num
draw3_0:jal draw_3
	j restore_draw_nut_num
draw4_0:jal draw_4
	j restore_draw_nut_num
draw5_0:jal draw_5
	j restore_draw_nut_num
draw6_0:jal draw_6
	j restore_draw_nut_num
draw7_0:jal draw_7
	j restore_draw_nut_num
draw8_0:jal draw_8
	j restore_draw_nut_num
draw9_0:jal draw_9
	j restore_draw_nut_num
restore_draw_nut_num:
	lw $t0, 0($sp)
	lw $t1, 4($sp)
	lw $t2, 8($sp)
	lw $ra, 12($sp)
	addi $sp, $sp, 16
	jr $ra
draw_row_64:
	addi $sp, $sp, -8
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	li $t0, 16384
	addi $t0, $t0, base_address
	li $t1, ground
	
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	sw $t1, 20($t0)
	sw $t1, 24($t0)
	sw $t1, 28($t0)
	sw $t1, 32($t0)
	sw $t1, 36($t0)
	sw $t1, 40($t0)
	sw $t1, 44($t0)
	sw $t1, 48($t0)
	sw $t1, 52($t0)
	sw $t1, 56($t0)
	sw $t1, 60($t0)
	sw $t1, 64($t0)
	sw $t1, 68($t0)
	sw $t1, 72($t0)
	sw $t1, 76($t0)
	sw $t1, 80($t0)
	sw $t1, 84($t0)
	sw $t1, 88($t0)
	sw $t1, 92($t0)
	sw $t1, 96($t0)
	sw $t1, 100($t0)
	sw $t1, 104($t0)
	sw $t1, 108($t0)
	sw $t1, 112($t0)
	sw $t1, 116($t0)
	sw $t1, 120($t0)
	sw $t1, 124($t0)
	sw $t1, 128($t0)
	sw $t1, 132($t0)
	sw $t1, 136($t0)
	sw $t1, 140($t0)
	sw $t1, 144($t0)
	sw $t1, 148($t0)
	sw $t1, 152($t0)
	sw $t1, 156($t0)
	sw $t1, 160($t0)
	sw $t1, 164($t0)
	sw $t1, 168($t0)
	sw $t1, 172($t0)
	sw $t1, 176($t0)
	sw $t1, 180($t0)
	sw $t1, 184($t0)
	sw $t1, 188($t0)
	sw $t1, 192($t0)
	sw $t1, 196($t0)
	sw $t1, 200($t0)
	sw $t1, 204($t0)
	sw $t1, 208($t0)
	sw $t1, 212($t0)
	sw $t1, 216($t0)
	sw $t1, 220($t0)
	sw $t1, 224($t0)
	sw $t1, 228($t0)
	sw $t1, 232($t0)
	sw $t1, 236($t0)
	sw $t1, 240($t0)
	sw $t1, 244($t0)
	sw $t1, 248($t0)
	sw $t1, 252($t0)
	sw $t1, 256($t0)
	lw $t0,0($sp)
	lw $t1, 4($sp)
	addi $sp, $sp, 8
	jr $ra	
draw_score:
	bgt $fp, 99999, you_win
	addi $sp, $sp, -36
	sw $t0,0($sp)
	sw $t1,4($sp)
	sw $t2,8($sp)
	sw $t3,12($sp)
	sw $t4,16($sp)
	sw $t5,20($sp)
	sw $t6,24($sp)
	sw $a1, 28($sp)
	sw $ra, 32($sp)
	#$t0=the digit at position 0
	#$t1=the digit at position 1
	#$t2=the digit at position 2
	#$t3=the digit at position 3
	#$t4=the digit at position 4
	#$t5=10
	#$t6=temp number
	li $a1, 0
	li $a0, 3212
	jal erase_num
	li $a0, 3236
	jal erase_num
	li $a0, 3260
	jal erase_num
	li $a0, 3284
	jal erase_num
	li $a0, 3308
	jal erase_num

	li $t5, 10
	div $fp, $t5
	mfhi $t0
	mflo $t6
	div $t6, $t5
	mfhi $t1
	mflo $t6
	div $t6, $t5
	mfhi $t2
	mflo $t6
	div $t6, $t5
	mfhi $t3
	mflo $t4
	#draw $t0
draw_t0:
	li $a0, 3308
	beq $t0,0, d0_0
	beq $t0,1, d0_1
	beq $t0,2, d0_2
	beq $t0,3, d0_3
	beq $t0,4, d0_4
	beq $t0,5, d0_5
	beq $t0,6, d0_6
	beq $t0,7, d0_7
	beq $t0,8, d0_8
	beq $t0,9, d0_9
	j draw_t1
d0_0:	jal draw_0
		j draw_t1
d0_1:	jal draw_1
		j draw_t1
d0_2:	jal draw_2
		j draw_t1
d0_3:	jal draw_3
		j draw_t1
d0_4:	jal draw_4
		j draw_t1
d0_5:	jal draw_5
		j draw_t1
d0_6:	jal draw_6
		j draw_t1
d0_7:	jal draw_7
		j draw_t1
d0_8:	jal draw_8
		j draw_t1
d0_9:	jal draw_9
		j draw_t1	
	
draw_t1:
	li $a0, 3284
	beq $t1,0, d1_0
	beq $t1,1, d1_1
	beq $t1,2, d1_2
	beq $t1,3, d1_3
	beq $t1,4, d1_4
	beq $t1,5, d1_5
	beq $t1,6, d1_6
	beq $t1,7, d1_7
	beq $t1,8, d1_8
	beq $t1,9, d1_9
	j draw_t2
d1_0:	jal draw_0
		j draw_t2
d1_1:	jal draw_1
		j draw_t2
d1_2:	jal draw_2
		j draw_t2
d1_3:	jal draw_3
		j draw_t2
d1_4:	jal draw_4
		j draw_t2
d1_5:	jal draw_5
		j draw_t2
d1_6:	jal draw_6
		j draw_t2
d1_7:	jal draw_7
		j draw_t2
d1_8:	jal draw_8
		j draw_t2
d1_9:	jal draw_9
		j draw_t2	

draw_t2:
	li $a0, 3260
	beq $t2,0, d2_0
	beq $t2,1, d2_1
	beq $t2,2, d2_2
	beq $t2,3, d2_3
	beq $t2,4, d2_4
	beq $t2,5, d2_5
	beq $t2,6, d2_6
	beq $t2,7, d2_7
	beq $t2,8, d2_8
	beq $t2,9, d2_9
	j draw_t3
d2_0:	jal draw_0
		j draw_t3
d2_1:	jal draw_1
		j draw_t3
d2_2:	jal draw_2
		j draw_t3
d2_3:	jal draw_3
		j draw_t3
d2_4:	jal draw_4
		j draw_t3
d2_5:	jal draw_5
		j draw_t3
d2_6:	jal draw_6
		j draw_t3
d2_7:	jal draw_7
		j draw_t3
d2_8:	jal draw_8
		j draw_t3
d2_9:	jal draw_9
		j draw_t3	

draw_t3:
	li $a0, 3236
	beq $t3,0, d3_0
	beq $t3,1, d3_1
	beq $t3,2, d3_2
	beq $t3,3, d3_3
	beq $t3,4, d3_4
	beq $t3,5, d3_5
	beq $t3,6, d3_6
	beq $t3,7, d3_7
	beq $t3,8, d3_8
	beq $t3,9, d3_9
	j draw_t4
d3_0:	jal draw_0
		j draw_t4
d3_1:	jal draw_1
		j draw_t4
d3_2:	jal draw_2
		j draw_t4
d3_3:	jal draw_3
		j draw_t4
d3_4:	jal draw_4
		j draw_t4
d3_5:	jal draw_5
		j draw_t4
d3_6:	jal draw_6
		j draw_t4
d3_7:	jal draw_7
		j draw_t4
d3_8:	jal draw_8
		j draw_t4
d3_9:	jal draw_9
		j draw_t4	

draw_t4:
	li $a0, 3212
	beq $t4,0, d4_0
	beq $t4,1, d4_1
	beq $t4,2, d4_2
	beq $t4,3, d4_3
	beq $t4,4, d4_4
	beq $t4,5, d4_5
	beq $t4,6, d4_6
	beq $t4,7, d4_7
	beq $t4,8, d4_8
	beq $t4,9, d4_9
	j draw_finish
d4_0:	jal draw_0
		j draw_finish
d4_1:	jal draw_1
		j draw_finish
d4_2:	jal draw_2
		j draw_finish
d4_3:	jal draw_3
		j draw_finish
d4_4:	jal draw_4
		j draw_finish
d4_5:	jal draw_5
		j draw_finish
d4_6:	jal draw_6
		j draw_finish
d4_7:	jal draw_7
		j draw_finish
d4_8:	jal draw_8
		j draw_finish
d4_9:	jal draw_9
		j draw_finish			
draw_finish:
	lw $t0,0($sp)
	lw $t1,4($sp)
	lw $t2,8($sp)
	lw $t3,12($sp)
	lw $t4,16($sp)
	lw $t5,20($sp)
	lw $t6,24($sp)
	lw $a1, 28($sp)
	lw $ra, 32($sp)
	addi $sp, $sp, 36
	jr $ra
draw_word_score:
	addi $sp, $sp, -8
	sw $t0, 0($sp)
	sw $t1, 4($sp)

	li $t0, base_address
	addi $t0, $t0,19716
	li $t1, wordcolor
	#0
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	sw $t1, 24($t0)
	sw $t1, 28($t0)
	sw $t1, 32($t0)
	sw $t1, 36($t0)
	sw $t1, 40($t0)
	sw $t1, 48($t0)
	sw $t1, 52($t0)
	sw $t1, 56($t0)
	sw $t1, 60($t0)
	sw $t1, 64($t0)
	sw $t1, 72($t0)
	sw $t1, 76($t0)
	sw $t1, 80($t0)
	sw $t1, 84($t0)
	sw $t1, 88($t0)
	sw $t1, 96($t0)
	sw $t1, 100($t0)
	sw $t1, 104($t0)
	sw $t1, 108($t0)
	sw $t1, 112($t0)
	

	#1
	addi $t0, $t0, 256
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	sw $t1, 24($t0)
	sw $t1, 28($t0)
	sw $t1, 36($t0)
	sw $t1, 40($t0)
	sw $t1, 48($t0)
	sw $t1, 52($t0)
	sw $t1, 60($t0)
	sw $t1, 64($t0)
	sw $t1, 72($t0)
	sw $t1, 76($t0)
	sw $t1, 84($t0)
	sw $t1, 88($t0)
	sw $t1, 96($t0)
	sw $t1, 100($t0)
	sw $t1, 108($t0)
	sw $t1, 112($t0)
	sw $t1, 124($t0)

	#2
		addi $t0, $t0, 256
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	
	sw $t1, 24($t0)
	sw $t1, 28($t0)
	
	sw $t1, 48($t0)
	sw $t1, 52($t0)
	
	sw $t1, 60($t0)
	sw $t1, 64($t0)
	sw $t1, 72($t0)
	sw $t1, 76($t0)
	sw $t1, 84($t0)
	sw $t1, 88($t0)
	sw $t1, 96($t0)
	sw $t1, 100($t0)


	#3
		addi $t0, $t0, 256
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	sw $t1, 12($t0)
	sw $t1, 24($t0)
	sw $t1, 28($t0)
	
	sw $t1, 48($t0)
	sw $t1, 52($t0)
	
	sw $t1, 60($t0)
	sw $t1, 64($t0)
	sw $t1, 72($t0)
	sw $t1, 76($t0)
	sw $t1, 80($t0)
	sw $t1, 84($t0)
	
	sw $t1, 96($t0)
	sw $t1, 100($t0)
	sw $t1, 104($t0)
	sw $t1, 108($t0)
	

	#4
		addi $t0, $t0, 256
	
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	sw $t1, 24($t0)
	sw $t1, 28($t0)
	
	sw $t1, 48($t0)
	sw $t1, 52($t0)
	
	sw $t1, 60($t0)
	sw $t1, 64($t0)
	sw $t1, 72($t0)
	sw $t1, 76($t0)
	
	sw $t1, 84($t0)
	sw $t1, 88($t0)
	sw $t1, 96($t0)
	sw $t1, 100($t0)
	

	#5
		addi $t0, $t0, 256
	
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	sw $t1, 24($t0)
	sw $t1, 28($t0)
	
	sw $t1, 48($t0)
	sw $t1, 52($t0)
	
	sw $t1, 60($t0)
	sw $t1, 64($t0)
	sw $t1, 72($t0)
	sw $t1, 76($t0)
	
	sw $t1, 84($t0)
	sw $t1, 88($t0)
	sw $t1, 96($t0)
	sw $t1, 100($t0)
	

	#6
		addi $t0, $t0, 256
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	sw $t1, 24($t0)
	sw $t1, 28($t0)
	sw $t1, 36($t0)
	sw $t1, 40($t0)
	sw $t1, 48($t0)
	sw $t1, 52($t0)
	sw $t1, 60($t0)
	sw $t1, 64($t0)
	sw $t1, 72($t0)
	sw $t1, 76($t0)
	sw $t1, 84($t0)
	sw $t1, 88($t0)
	sw $t1, 96($t0)
	sw $t1, 100($t0)
	sw $t1, 108($t0)
	sw $t1, 112($t0)
	

	#7
	addi $t0, $t0, 256
	sw $t1, 0($t0)
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	sw $t1, 24($t0)
	sw $t1, 28($t0)
	sw $t1, 32($t0)
	sw $t1, 36($t0)
	sw $t1, 40($t0)
	sw $t1, 48($t0)
	sw $t1, 52($t0)
	sw $t1, 56($t0)
	sw $t1, 60($t0)
	sw $t1, 64($t0)
	sw $t1, 72($t0)
	sw $t1, 76($t0)
	sw $t1, 84($t0)
	sw $t1, 88($t0)
	sw $t1, 96($t0)
	sw $t1, 100($t0)
	sw $t1, 104($t0)
	sw $t1, 108($t0)
	sw $t1, 112($t0)
	sw $t1, 124($t0)


	lw $t0, 0($sp)
	lw $t1, 4($sp)
	addi $sp, $sp, 8
	jr $ra						