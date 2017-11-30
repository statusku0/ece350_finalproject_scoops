.data

.text
		.globl main

# TODO: implement platform moving left (and appearing on right side of screen)

# Bitmap display: 512 by 256 pixels, unit pixel width/height = 32, base address for display = 0x10010000

# Global Mem:
# 0x10000000 = screen row length
# 0x10000004 = screen column length
# 0x10000008 = pointer to end of heap

main:
		jal initVars					# initialize constants/global pointers

		#-----Instantiates a block object----#
		addi $a0, $zero, 1				# set block num of rows (in pixels)
		addi $a1, $zero, 5				# set block num of columns (in pixels)
		addi $a2, $zero, 0x100101a0		# set block upper left corner
		addi $a3, $zero, 0x00ff0000     # set block to be red
		jal Block_construct			    # construct block

		#-----$s0 now refers to the block created above-----#
		add $s0, $zero, $v0 			# save block mem location

		#-----Instantiates a block object----#
		addi $a0, $zero, 2				# set block num of rows (in pixels)
		addi $a1, $zero, 5				# set block num of columns (in pixels)
		addi $a2, $zero, 0x100100a0		# set block upper left corner
		addi $a3, $zero, 0x000000ff		# set block to be blue
		jal Block_construct			    # construct block

		#-----$s1 now refers to the block created above-----#
		add $s1, $zero, $v0 			# save block mem location

		#-----Instantiates a Platform object----#
		addi $a0, $zero, 5				
		addi $a1, $zero, 0x0000f0ff
		jal Platform_construct			    # construct platform

		#-----$s2 now refers to the platform created above-----#
		add $s2, $zero, $v0 			# save block mem location


#-----Life Cycle of Block-----#
# 1. Block_construct
# 2. Block_modify (includes erasing old block and drawing new one)
# 3. go to step 2

move_block_across_screen:
	    addi $t0, $zero, 0xffff0004
	    lw $a1, 0($t0)					# get keyboard input
		add $a0, $zero, $s0
		jal Block_modify

		addi $t0, $zero, 0xffff0004
	    lw $a1, 0($t0)					# get keyboard input
	    add $a0, $zero, $s1
		jal Block_modify

		addi $t0, $zero, 0xffff0004
	    lw $a1, 0($t0)					# get keyboard input
	    add $a0, $zero, $s2
		jal Platform_modify

		addi $a0, $zero, 10000			
		jal wait  						# wait 10000 cycles

		j move_block_across_screen

#------PLATFORM OBJECT METHODS------#
# a0 = length of platform, a1 = color
Platform_construct:
		addi $sp, $sp, -36
		sw $ra, 0($sp)
		sw $s0, 4($sp)
		sw $s1, 8($sp)
		sw $s2, 12($sp)
		sw $s3, 16($sp)
		sw $s4, 20($sp)
		sw $s5, 24($sp)
		sw $s6, 28($sp)
		sw $s7, 32($sp)

		add $s0, $zero, $a0
		add $s1, $zero, $a1

		add $a0, $zero, 1
		add $a1, $zero, $s0
		add $a2, $zero, 0x10010000		# place platform at start of screen
		add $a3, $zero, $s1
		jal Block_construct

		lw $ra, 0($sp)
		lw $s0, 4($sp)
		lw $s1, 8($sp)
		lw $s2, 12($sp)
		lw $s3, 16($sp)
		lw $s4, 20($sp)
		lw $s5, 24($sp)
		lw $s6, 28($sp)
		lw $s7, 32($sp)
		addi $sp, $sp, 36

		jr $ra

# a0 = mem location of block, a1 = keyboard input
Platform_modify:
		addi $sp, $sp, -36
		sw $ra, 0($sp)
		sw $s0, 4($sp)
		sw $s1, 8($sp)
		sw $s2, 12($sp)
		sw $s3, 16($sp)
		sw $s4, 20($sp)
		sw $s5, 24($sp)
		sw $s6, 28($sp)
		sw $s7, 32($sp)

		add $s0, $zero, $a0				# save mem location of block to s0 
		add $s1, $zero, $a1				# save keyboard input to s1

		addi $t1, $zero, 100
	    bne $s1, $t1, Platform_modify_check2 # if keyboard input not equal to "d", go to next check

		add $a0, $zero, $s0				# set first arg to block mem location
		# addi $a1, $zero, 0x00000000		# set second arg to black
		# addi $a2, $zero, 0				# set to erase column 0
		addi $a1, $zero, 0
		jal Platform_erase					# erase old block

		add $a0, $zero, $s0
		jal Block_moveRight

Platform_modify_check2:
		addi $t2, $zero, 97
		bne $s1, $t2, Platform_modify_draw # if keyboard input not equal to "a", don't do anything

		add $a0, $zero, $s0				# set first arg to block mem location
		# addi $a1, $zero, 0x00000000		# set second arg to black
		lw $t2, 4($s0)					# set to erase last column of block
		addi $a1, $t2, -1				# Block_erase uses "start index at 0" convention
		jal Platform_erase					# erase old block

		add $a0, $zero, $s0
		jal Block_moveLeft

Platform_modify_draw:
		add $a0, $zero, $s0
		jal Platform_draw 					# draw new block

		lw $ra, 0($sp)
		lw $s0, 4($sp)
		lw $s1, 8($sp)
		lw $s2, 12($sp)
		lw $s3, 16($sp)
		lw $s4, 20($sp)
		lw $s5, 24($sp)
		lw $s6, 28($sp)
		lw $s7, 32($sp)
		addi $sp, $sp, 36

		jr $ra

# a0 = mem location of platform
Platform_draw:
		addi $sp, $sp, -36
		sw $ra, 0($sp)
		sw $s0, 4($sp)
		sw $s1, 8($sp)
		sw $s2, 12($sp)
		sw $s3, 16($sp)
		sw $s4, 20($sp)
		sw $s5, 24($sp)
		sw $s6, 28($sp)
		sw $s7, 32($sp)

		add $s0, $zero, $a0
		add $s3, $zero, $a1
		add $s4, $zero, $a2
		add $s5, $zero, $a3

		addi $t0, $zero, 0x10000000
		lw $t1, 4($t0)					# get screen width

		addi $t3, $zero, 0				# init counter for column
		addi $t4, $zero, 0				# init counter for row

		lw $t5, 0($s0)					# get block num of rows
		lw $t6, 4($s0)					# get block num of columns
		lw $t7, 8($s0)					# get block upper left corner location
		lw $t8, 12($s0)					# get block color

		add $s1, $zero, $t7 			# set s1 to upper left corner location

		add $t9, $t1, 0x10010000		# get address of end of row
		blt $t7, $t9, Platform_draw_helper1 # if upper left corner location not past end of row, continue as normal
		sub $t7, $t7, $t1				# else, move upper corner to corner - row length
		sw $t7, 8($s0)					# save new upper corner

Platform_draw_helper1:
		addi $t4, $zero, 0 				# reset row counter
		add $s2, $zero, $s1

		#---- makes platform stay in one row ----#
		addi $t0, $zero, 0x10000000
		lw $t2, 4($t0)					# get screen width
		add $t9, $t2, 0x10010000		# get address of end of row
		blt $s2, $t9, Platform_draw_cont # if column not past end of row, continue as normal
		sub $s2, $s2, $t2				# else, move to column - row length 

Platform_draw_cont:
		addi $t0, $zero, 1
		bne $s3, $t0, Platform_draw_helper2 # if "color select column" is not 1, continue as normal

		add $t8, $zero, $s5				# else 
		bne $t3, $s4, Platform_draw_notColoring # if column counter not equal to select column, skip coloring

Platform_draw_helper2:
		add $a0, $zero, $s2				# set pixel location
		add $a1, $zero, $t8			    # set pixel color
		jal colorPixel					# color pixel
		addi $t4, $t4, 1				# increment row counter
		add $s2, $s2, $t1				# move to pixel + screen 

		bne $t4, $t5, Platform_draw_helper2 # if row counter != block num of rows, keep looping in inner loop	

Platform_draw_notColoring:
		addi $t3, $t3, 1				# increment column counter
		add $s1, $s1, 4					# move to next pixel

		bne $t3, $t6, Platform_draw_helper1 # if column counter != block num of columns, keep looping in outer loop

		lw $ra, 0($sp)					# else, done with Block_draw
		lw $s0, 4($sp)
		lw $s1, 8($sp)
		lw $s2, 12($sp)
		lw $s3, 16($sp)
		lw $s4, 20($sp)
		lw $s5, 24($sp)
		lw $s6, 28($sp)
		lw $s7, 32($sp)
		addi $sp, $sp, 36

		jr $ra

# a0 = mem location of platform, a1 = column to erase
Platform_erase:
		addi $sp, $sp, -36
		sw $ra, 0($sp)
		sw $s0, 4($sp)
		sw $s1, 8($sp)
		sw $s2, 12($sp)
		sw $s3, 16($sp)
		sw $s4, 20($sp)
		sw $s5, 24($sp)
		sw $s6, 28($sp)
		sw $s7, 32($sp)

		add $s0, $zero, $a1

		addi $a1, $zero, 1
		add $a2, $zero, $s0 
		add $a3, $zero, 0x00000000
		jal Platform_draw

		lw $ra, 0($sp)	
		lw $s0, 4($sp)
		lw $s1, 8($sp)
		lw $s2, 12($sp)
		lw $s3, 16($sp)
		lw $s4, 20($sp)
		lw $s5, 24($sp)
		lw $s6, 28($sp)
		lw $s7, 32($sp)
		addi $sp, $sp, 36

		jr $ra


#------BLOCK OBJECT METHODS-----#

# a0 = num of rows, a1 = num of columns, a2 = pixel location of upper left corner, a3 = color, v0 = mem location, v1 = size of object (bytes)
Block_construct:							# acts as the "constructor" for the block object
		addi $sp, $sp, -36
		sw $ra, 0($sp)
		sw $s0, 4($sp)
		sw $s1, 8($sp)
		sw $s2, 12($sp)
		sw $s3, 16($sp)
		sw $s4, 20($sp)
		sw $s5, 24($sp)
		sw $s6, 28($sp)
		sw $s7, 32($sp)

		addi $t0, $zero, 0x10000000
		lw $t1, 8($t0)					# get heap pointer

		sw $a0, 0($t1)					# save attributes in mem address
		sw $a1, 4($t1)
		sw $a2, 8($t1)
		sw $a3, 12($t1)

		add $v0, $zero, $t1				# output start mem location
		add $v1, $zero, 16				# output size of object (MAKE SURE THIS IS THE CORRECT SIZE)

		#-----Increments end-of-heap pointer-----#
		add $t1, $v0, $v1				# increment heap pointer
		sw $t1, 8($t0)					# save heap pointer

		lw $ra, 0($sp)
		lw $s0, 4($sp)
		lw $s1, 8($sp)
		lw $s2, 12($sp)
		lw $s3, 16($sp)
		lw $s4, 20($sp)
		lw $s5, 24($sp)
		lw $s6, 28($sp)
		lw $s7, 32($sp)
		addi $sp, $sp, 36

		jr $ra

#--------------#

# a0 = mem location of block, a1 = color select column, a2 = column to color, a3 = color of selected column 
Block_draw:
		addi $sp, $sp, -36
		sw $ra, 0($sp)
		sw $s0, 4($sp)
		sw $s1, 8($sp)
		sw $s2, 12($sp)
		sw $s3, 16($sp)
		sw $s4, 20($sp)
		sw $s5, 24($sp)
		sw $s6, 28($sp)
		sw $s7, 32($sp)

		add $s0, $zero, $a0
		add $s3, $zero, $a1
		add $s4, $zero, $a2
		add $s5, $zero, $a3

		addi $t0, $zero, 0x10000000
		lw $t1, 4($t0)					# get screen column length

		addi $t3, $zero, 0				# init counter for column
		addi $t4, $zero, 0				# init counter for row

		lw $t5, 0($s0)					# get block num of rows
		lw $t6, 4($s0)					# get block num of columns
		lw $t7, 8($s0)					# get block upper left corner location
		lw $t8, 12($s0)					# get block color

		add $s1, $zero, $t7 			# set s1 to upper left corner location

Block_draw_helper1:
		addi $t4, $zero, 0 				# reset row counter
		add $s2, $zero, $s1

		addi $t0, $zero, 1
		bne $s3, $t0, Block_draw_helper2 # if "color select column" is not 1, continue as normal

		add $t8, $zero, $s5				# else 
		bne $t3, $s4, Block_draw_notColoring # if column counter not equal to select column, skip coloring

Block_draw_helper2:
		add $a0, $zero, $s2				# set pixel location
		add $a1, $zero, $t8			    # set pixel color
		jal colorPixel					# color pixel
		addi $t4, $t4, 1				# increment row counter
		add $s2, $s2, $t1				# move to pixel + screen 

		bne $t4, $t5, Block_draw_helper2 # if row counter != block num of rows, keep looping in inner loop	

Block_draw_notColoring:
		addi $t3, $t3, 1				# increment column counter
		add $s1, $s1, 4					# move to next pixel

		bne $t3, $t6, Block_draw_helper1 # if column counter != block num of columns, keep looping in outer loop

		lw $ra, 0($sp)					# else, done with Block_draw
		lw $s0, 4($sp)
		lw $s1, 8($sp)
		lw $s2, 12($sp)
		lw $s3, 16($sp)
		lw $s4, 20($sp)
		lw $s5, 24($sp)
		lw $s6, 28($sp)
		lw $s7, 32($sp)
		addi $sp, $sp, 36

		jr $ra

#--------------#

# a0 = mem location of block, a1 = column to erase
Block_erase:
		addi $sp, $sp, -36
		sw $ra, 0($sp)
		sw $s0, 4($sp)
		sw $s1, 8($sp)
		sw $s2, 12($sp)
		sw $s3, 16($sp)
		sw $s4, 20($sp)
		sw $s5, 24($sp)
		sw $s6, 28($sp)
		sw $s7, 32($sp)

		add $s0, $zero, $a1

		addi $a1, $zero, 1
		add $a2, $zero, $s0 
		add $a3, $zero, 0x00000000
		jal Block_draw

		lw $ra, 0($sp)	
		lw $s0, 4($sp)
		lw $s1, 8($sp)
		lw $s2, 12($sp)
		lw $s3, 16($sp)
		lw $s4, 20($sp)
		lw $s5, 24($sp)
		lw $s6, 28($sp)
		lw $s7, 32($sp)
		addi $sp, $sp, 36

		jr $ra


#--------------#

# a0 = mem location of block, a1 = keyboard input
Block_modify:
		addi $sp, $sp, -36
		sw $ra, 0($sp)
		sw $s0, 4($sp)
		sw $s1, 8($sp)
		sw $s2, 12($sp)
		sw $s3, 16($sp)
		sw $s4, 20($sp)
		sw $s5, 24($sp)
		sw $s6, 28($sp)
		sw $s7, 32($sp)

		add $s0, $zero, $a0				# save mem location of block to s0 
		add $s1, $zero, $a1				# save keyboard input to s1

		addi $t1, $zero, 100
	    bne $s1, $t1, Block_modify_check2 # if keyboard input not equal to "d", go to next check

		add $a0, $zero, $s0				# set first arg to block mem location
		# addi $a1, $zero, 0x00000000		# set second arg to black
		# addi $a2, $zero, 0				# set to erase column 0
		addi $a1, $zero, 0
		jal Block_erase					# erase old block

		add $a0, $zero, $s0
		jal Block_moveRight

Block_modify_check2:
		addi $t2, $zero, 97
		bne $s1, $t2, Block_modify_draw # if keyboard input not equal to "a", don't do anything

		add $a0, $zero, $s0				# set first arg to block mem location
		# addi $a1, $zero, 0x00000000		# set second arg to black
		lw $t2, 4($s0)					# set to erase last column of block
		addi $a1, $t2, -1				# Block_erase uses "start index at 0" convention
		jal Block_erase					# erase old block

		add $a0, $zero, $s0
		jal Block_moveLeft

Block_modify_draw:
		add $a0, $zero, $s0
		jal Block_draw 					# draw new block

		lw $ra, 0($sp)
		lw $s0, 4($sp)
		lw $s1, 8($sp)
		lw $s2, 12($sp)
		lw $s3, 16($sp)
		lw $s4, 20($sp)
		lw $s5, 24($sp)
		lw $s6, 28($sp)
		lw $s7, 32($sp)
		addi $sp, $sp, 36

		jr $ra

# a0 = mem location of block
Block_moveRight:
		addi $sp, $sp, -36
		sw $ra, 0($sp)
		sw $s0, 4($sp)
		sw $s1, 8($sp)
		sw $s2, 12($sp)
		sw $s3, 16($sp)
		sw $s4, 20($sp)
		sw $s5, 24($sp)
		sw $s6, 28($sp)
		sw $s7, 32($sp)

		lw $t0, 8($a0)					# get location of upper left corner
		addi $t0, $t0, 4				# increment block location RIGHT by 1 pixel
		sw $t0, 8($a0)					# save block location

		lw $ra, 0($sp)
		lw $s0, 4($sp)
		lw $s1, 8($sp)
		lw $s2, 12($sp)
		lw $s3, 16($sp)
		lw $s4, 20($sp)
		lw $s5, 24($sp)
		lw $s6, 28($sp)
		lw $s7, 32($sp)
		addi $sp, $sp, 36

		jr $ra

# a0 = mem location of block
Block_moveLeft:
		addi $sp, $sp, -36
		sw $ra, 0($sp)
		sw $s0, 4($sp)
		sw $s1, 8($sp)
		sw $s2, 12($sp)
		sw $s3, 16($sp)
		sw $s4, 20($sp)
		sw $s5, 24($sp)
		sw $s6, 28($sp)
		sw $s7, 32($sp)

		lw $t0, 8($a0)					# get location of upper left corner
		addi $t0, $t0, -4				# increment block location LEFT by 1 pixel
		sw $t0, 8($a0)					# save block location

		lw $ra, 0($sp)
		lw $s0, 4($sp)
		lw $s1, 8($sp)
		lw $s2, 12($sp)
		lw $s3, 16($sp)
		lw $s4, 20($sp)
		lw $s5, 24($sp)
		lw $s6, 28($sp)
		lw $s7, 32($sp)
		addi $sp, $sp, 36

		jr $ra


#-----UTILITIES-----#

# a0 = pixel location, a1 = color
colorPixel:
		addi $sp, $sp, -36
		sw $ra, 0($sp)
		sw $s0, 4($sp)
		sw $s1, 8($sp)
		sw $s2, 12($sp)
		sw $s3, 16($sp)
		sw $s4, 20($sp)
		sw $s5, 24($sp)
		sw $s6, 28($sp)
		sw $s7, 32($sp)

		sw $a1, 0($a0)					# save color in pixel address location

		lw $ra, 0($sp)
		lw $s0, 4($sp)
		lw $s1, 8($sp)
		lw $s2, 12($sp)
		lw $s3, 16($sp)
		lw $s4, 20($sp)
		lw $s5, 24($sp)
		lw $s6, 28($sp)
		lw $s7, 32($sp)
		addi $sp, $sp, 36

		jr $ra 

#--------------#

# a0 = cycles to wait for
wait:   
		addi $t1, $zero, 0				# initialize counter

wait_loop:
		addi $t1, $t1, 1				# increment counter
		bne $t1, $a0, wait_loop 	    # if t1 hasn't reached a0 yet, repeat loop

		jr $ra   						# else, return

#--------------#

# initializes constants/global pointers
initVars:
		addi $sp, $sp, -36
		sw $ra, 0($sp)
		sw $s0, 4($sp)
		sw $s1, 8($sp)
		sw $s2, 12($sp)
		sw $s3, 16($sp)
		sw $s4, 20($sp)
		sw $s5, 24($sp)
		sw $s6, 28($sp)
		sw $s7, 32($sp)

		addi $t0, $zero, 32
		addi $t1, $zero, 64
		addi $t2, $zero, 0x10000000
		sw $t0, 0($t2)					# store screen row length (in bits)
		sw $t1, 4($t2)					# store screen column length (in bits)

		addi $t0, $zero, 0x10040000		
		sw $t0, 8($t2)					# store pointer to end of heap

		lw $ra, 0($sp)
		lw $s0, 4($sp)
		lw $s1, 8($sp)
		lw $s2, 12($sp)
		lw $s3, 16($sp)
		lw $s4, 20($sp)
		lw $s5, 24($sp)
		lw $s6, 28($sp)
		lw $s7, 32($sp)
		addi $sp, $sp, 36

		jr $ra

