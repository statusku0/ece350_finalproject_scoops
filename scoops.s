.data

.text
		.globl main

# Bitmap display: 512 by 256 pixels, unit pixel width/height = 32, base address for display = 0x10010000

# Global Mem:
# 0x10000000 = screen row length
# 0x10000004 = screen column length
# 0x10000008 = pointer to end of heap

main:
		jal initVars					# initialize constants/global pointers

		#-----Instantiates a block object----#
		addi $a0, $zero, 1				# set block num of rows (in pixels)
		addi $a1, $zero, 3				# set block num of columns (in pixels)
		addi $a2, $zero, 0		
		addi $a3, $zero, 7   
		jal Block_construct			    # construct block

		#-----$s0 now refers to the block created above-----#
		add $s0, $zero, $v0 			# save block mem location

		addi $a0, $zero, 4
		jal FoodSet_construct

		add $s3, $zero, $v0

		addi $a0, $zero, 3
		jal FoodSet_construct

		add $s4, $zero, $v0


		#-----Set up game clock------#
		addi $s5, $zero, 0				# s5 = global cycle counter

move_block_across_screen:

	    addi $t0, $zero, 0xffff0004
	    lw $a1, 0($t0)					# get keyboard input
		add $a0, $zero, $s0
		addi $a2, $zero, 0x000000ff
		jal Block_modify

		add $a0, $zero, $s3
		addi $a2, $zero, 0x00ff0000
		jal FoodSet_modify

		addi $t0, $zero, 5
		blt $s5, $t0, move_block_across_screen_wait

		add $a0, $zero, $s4
		addi $a2, $zero, 0x00fa0a00
		jal FoodSet_modify

move_block_across_screen_wait:
		addi $a0, $zero, 1000			
		jal wait  						# wait a number of cycles
		addi $s5, $s5, 1				# increment global counter

		j move_block_across_screen

#------FOODSET OBJECT METHODS------#

# a0 = number of objects in set, v0 = mem location of FoodSet, v1 = size of FoodSet
FoodSet_construct:
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
		lw $s1, 8($t0)					# get heap pointer

		add $s4, $zero, $s1				# s4 = initial heap pointer

		add $s3, $zero, $a0				# s3 = num of objects
		sw $s3, 0($s1)					# save num of objects
		addi $s1, $s1, 4				# increment heap pointer
		sw $s1, 8($t0)					# save heap pointer		

		addi $s0, $zero, 0				# s0 = counter
		addi $s2, $zero, 0				# s2 used to generate "random" x coord


FoodSet_construct_food_loop:

		addi $s2, $s2, 13				
		add $a0, $zero, $s2
		jal fixXCoord
		
		addi $a0, $zero, 1				# num of rows = 1
		addi $a1, $zero, 1				# num of cols = 1
		add $a2, $zero, $v0 			# random x coord			
		addi $a3, $zero, -1				# y coord of upper left corner = -1
		jal Food_construct

		add $s1, $v0, $v1				# increment heap pointer
		sw $s1, 8($t0)					# save heap pointer		

		addi $s0, $s0, 1
		blt $s0, $s3, FoodSet_construct_food_loop

		addi $t0, $zero, 0x10000000
		sw $s1, 8($t0)					# save heap pointer

		add $v0, $zero, $s4				# save mem address of FallingSet
		sub $v1, $s1, $s4				# save size of whole FallingSet
		
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

#---------#
# a0 = mem location of FoodSet
FoodSet_reset:
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

		add $s0, $zero, $a0			# s0 = mem location of FoodSet
		lw $s1, 0($s0)				# s1 = number of Food objects
		addi $s0, $s0, 4			# s0 = mem location of Food objects

		addi $s2, $zero, 0			# s2 = counter

		addi $s3, $zero, 0			# s3 used to generate "random" x coord

FoodSet_reset_loop:
		add $a0, $zero, $s0
		addi $a1, $zero, -1
		jal Block_saveYCoordUpperLeft # change y coord of upper left corner to -1

		addi $s3, $s3, 11
		add $a0, $zero, $s3
		jal fixXCoord
		add $a0, $zero, $s0
		add $a1, $zero, $v0
		jal Block_saveXCoordUpperLeft # re-randomize x coord			
		
		addi $s2, $s2, 1			# increment counter
		addi $s0, $s0, 16			# increment by size of one Food object
		blt $s2, $s1, FoodSet_reset_loop

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
	

#---------#

# a0 = mem location of FoodSet, a1 = keyboard input, a2 = color
FoodSet_modify:
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

		add $s3, $zero, $a2			# s3 = color

		add $s0, $zero, $a0			# s0 = mem location of FoodSet
		add $s5, $zero, $s0			# s5 = s0
		lw $s1, 0($s0)				# s1 = number of Food objects
		addi $s0, $s0, 4			# s0 = mem location of Food objects

		addi $s2, $zero, 0			# s2 = counter

		j FoodSet_modify_reset		# check if FoodSet needs to be reset

FoodSet_modify_Food_modify_loop:
		add $a0, $zero, $s0
		add $a2, $zero, $s3
		jal Food_modify
		
		addi $s2, $s2, 1			# increment counter
		addi $s0, $s0, 16			# increment by size of one Food object
		blt $s2, $s1, FoodSet_modify_Food_modify_loop

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

FoodSet_modify_reset:
		add $a0, $zero, $s0
		jal Block_getYCoordUpperLeft

		add $s4, $zero, $v0			# s4 = y coord 

		jal getScreenHeight
		blt $s4, $v0, FoodSet_modify_Food_modify_loop

		add $a0, $zero, $s5
		jal FoodSet_reset

		j FoodSet_modify_Food_modify_loop



#------FOOD OBJECT METHODS------#

# a0 = num of rows, a1 = num of columns, a2 = x coordinate of upper left corner, a3 = y coordinate of upper left corner, v0 = mem location, v1 = size of object (bytes)
Food_construct:
		addi $sp, $sp, -4
		sw $ra, 0($sp)

		jal Block_construct

		lw $ra, 0($sp)
		addi $sp, $sp, 4
	    jr $ra

#------#

# a0 = mem location of Food, a1 = keyboard input, a2 = color
Food_modify:
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
		add $s2, $zero, $a2				# s2 = color

		add $a0, $zero, $s0
	    jal Block_getXCoordUpperLeft
	    add $s3, $zero, $v0					# s3 = x coord of upper left corner
	    jal Block_getYCoordUpperLeft
	    add $s4, $zero, $v0					# s4 = y coord of upper left corner
	    jal Block_getNumRows				
	    add $s5, $zero, $v0					# s5 = num of rows
	    jal Block_getNumCols
	    add $s6, $zero, $v0					# s6 = num of cols

	    add $a0, $zero, $s3
	    add $a1, $zero, $s4
	    addi $a2, $zero, 1
	    add $a3, $zero, $s6
	    addi $v1, $zero, 0x00000000
		jal colorRect

		add $a0, $zero, $s0
		jal Block_moveDown

		add $a0, $zero, $s0
		add $a1, $zero, $s2
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



#------BLOCK OBJECT METHODS-----#

# a0 = num of rows, a1 = num of columns, a2 = x coordinate of upper left corner, a3 = y coordinate of upper left corner, v0 = mem location, v1 = size of object (bytes)
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

#------#

# a0 = mem address of Block
Block_getNumRows:
		lw $v0, 0($a0)
		jr $ra

#------#

# a0 = mem address of Block
Block_getNumCols:
		lw $v0, 4($a0)
		jr $ra

#------#

# a0 = mem address of Block
Block_getXCoordUpperLeft:
		lw $v0, 8($a0)
		jr $ra

#------#

# a0 = mem address of Block
Block_getYCoordUpperLeft:
		lw $v0, 12($a0)
		jr $ra

#------#
# a0 = mem address of block, a1 = x coord
Block_saveXCoordUpperLeft:
		sw $a1, 8($a0)
		jr $ra

#------#
# a0 = mem address of block, a1 = y coord
Block_saveYCoordUpperLeft:
		sw $a1, 12($a0)
		jr $ra

#------#

# a0 = mem address of Block
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

		add $s0, $zero, $a0		# s0 = Block

		add $a0, $zero, $s0
		jal Block_getXCoordUpperLeft
		add $s1, $zero, $v0		# s1 = x coord of upper left corner

	    addi $s1, $s1, -1 		# s1 = s1 - 1
	    add $a0, $zero, $s1
	    jal fixXCoord
	    add $s1, $zero, $v0     # s1 = fixed x coord

	    add $a0, $zero, $s0
	    add $a1, $zero, $s1
	    jal Block_saveXCoordUpperLeft

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

#------#

# a0 = mem address of Block
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

		add $s0, $zero, $a0		# s0 = Block

		add $a0, $zero, $s0
		jal Block_getXCoordUpperLeft
		add $s1, $zero, $v0		# s1 = x coord of upper left corner

	    addi $s1, $s1, 1 		# s1 = s1 + 1
	    add $a0, $zero, $s1
	    jal fixXCoord
	    add $s1, $zero, $v0     # s1 = fixed x coord

	    add $a0, $zero, $s0
	    add $a1, $zero, $s1
	    jal Block_saveXCoordUpperLeft

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

#------#

# a0 = mem address of Block
Block_moveDown:
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

		add $s0, $zero, $a0		# s0 = Block

		add $a0, $zero, $s0
		jal Block_getYCoordUpperLeft
		add $s1, $zero, $v0		# s1 = y coord of upper left corner

	    addi $s1, $s1, 1 		# s1 = s1 + 1

	    add $a0, $zero, $s0
	    add $a1, $zero, $s1
	    jal Block_saveYCoordUpperLeft

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

# a0 = mem location of block, a1 = color
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
		add $s1, $zero, $a1

		lw $a0, 8($s0)
		lw $a1, 12($s0)
		lw $a2, 0($s0)
		lw $a3, 4($s0)
		add $v1, $zero, $s1
		jal colorRect

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

# a0 = mem location of block, a1 = keyboard input, a2 = color
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
		add $s2, $zero, $a2				# s2 = color

		add $a0, $zero, $s0
	    jal Block_getXCoordUpperLeft
	    add $s3, $zero, $v0					# s3 = x coord of upper left corner
	    jal Block_getYCoordUpperLeft
	    add $s4, $zero, $v0					# s4 = y coord of upper left corner
	    jal Block_getNumRows				
	    add $s5, $zero, $v0					# s5 = num of rows
	    jal Block_getNumCols
	    add $s6, $zero, $v0					# s6 = num of cols

		addi $t1, $zero, 100
	    bne $s1, $t1, Block_modify_check2 # if keyboard input not equal to "d", go to next check

	    add $a0, $zero, $s3
	    add $a1, $zero, $s4
	    add $a2, $zero, $s5
	    addi $a3, $zero, 1
	    addi $v1, $zero, 0x00000000
		jal colorRect

		add $a0, $zero, $s0
		jal Block_moveRight

Block_modify_check2:
		addi $t2, $zero, 97
		bne $s1, $t2, Block_modify_draw # if keyboard input not equal to "a", don't do anything

		add $a0, $s3, $s6
		add $a1, $zero, $s4
	    add $a2, $zero, $s5
	    addi $a3, $zero, 1
	    addi $v1, $zero, 0x00000000
		jal colorRect

		add $a0, $zero, $s0
		jal Block_moveLeft

Block_modify_draw:
		add $a0, $zero, $s0
		add $a1, $zero, $s2
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

#---------------#


#-----UTILITIES-----#

# a0 = x coord, a1 = y coord, v0 = address of (x, y) pixel location
getAddressFromCoordinate:
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

        add $s0, $zero, $a0			# s0 = x coord 
        add $s1, $zero, $a1			# s1 = y coord

        jal getScreenWidthInBytes
        add $s4, $zero, $v0			# s4 = screen width in bytes

        add $s2, $zero, 0			# s2 = x counter
        add $s3, $zero, 0			# s3 = y counter

        add $v0, $zero, 0x10010000	# v0 = output address

        blt $s2, $s0, getAddressFromCoordinate_xLoop
		j getAddressFromCoordinate_xLoop_end

getAddressFromCoordinate_xLoop:
		addi $v0, $v0, 4			# add 4 bytes
		addi $s2, $s2, 1			# increment counter
		blt $s2, $s0, getAddressFromCoordinate_xLoop

getAddressFromCoordinate_xLoop_end:

		blt $s3, $s1, getAddressFromCoordinate_yLoop
		j getAddressFromCoordinate_yLoop_end
		
getAddressFromCoordinate_yLoop:
		add $v0, $v0, $s4			# add screen width (in bytes)
		addi $s3, $s3, 1			# increment counter
		blt $s3, $s1, getAddressFromCoordinate_yLoop

getAddressFromCoordinate_yLoop_end:
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

#--------#

# a0 = x coord, a1 = y coord, a2 = color
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

		jal getAddressFromCoordinate
		sw $a2, 0($v0)					# save color in pixel address location

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

#-------#

# a0 = x coord, v0 = fixed x coord
fixXCoord:
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

		jal getScreenWidth
		add $s0, $zero, $v0			# s0 = screen width in pixels

		blt $a0, $s0, fixXCoord_check2 # if x coord < s0, proceed to check2

fixXCoord_sub_loop:
		sub $a0, $a0, $s0
		blt $s0, $a0, fixXCoord_sub_loop

fixXCoord_check2:
		addi $t0, $a0, 1
		bne $t0, $zero, fixXCoord_end # if x coord + 1 != 0, go to end
		sub $a0, $zero, $a0
		sub $a0, $s0, $a0

fixXCoord_end:
		add $v0, $zero, $a0

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

#------#

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

		addi $t0, $zero, 8
		addi $t1, $zero, 16
		addi $t2, $zero, 0x10000000
		sw $t0, 0($t2)					# store screen height (in pixels)
		sw $t1, 4($t2)					# store screen width (in pixels)

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

#------------#

getScreenHeight:
		addi $t0, $zero, 0x10000000
		lw $v0, 0($t0)

		jr $ra

#------------#

getScreenWidth:
		addi $t0, $zero, 0x10000000
		lw $v0, 4($t0)

		jr $ra


#------------#

# v0 = screen width in bytes
getScreenWidthInBytes:
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

		jal getScreenWidth
		add $s0, $zero, $v0		# s0 = screen width in pixels

		add $v0, $zero, 0

		addi $s1, $zero, 0		# s1 = counter

		blt $s1, $s0, getScreenWidthInBytes_loop
		j getScreenWidthInBytes_loop_end

getScreenWidthInBytes_loop:
		addi $v0, $v0, 4
		addi $s1, $s1, 1
		blt $s1, $s0, getScreenWidthInBytes_loop

getScreenWidthInBytes_loop_end:
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
#------------#
# a0 = x coord of upper left corner, a1 = y coord of upper left corner, a2 = num of rows, a3 = num of columns, v1 = color (v1 is treated as an input)
colorRect:
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

		add $s0, $zero, $a0	 			# s0 = x coord of upper left corner
		add $s1, $zero, $a1				# s1 = y coord of upper left corner
		add $s2, $zero, $a2				# s2 = num of rows
		add $s3, $zero, $a3				# s3 = num of columns

		add $a0, $zero, $s0
		add $a1, $zero, $s1
		jal getAddressFromCoordinate
		add $s4, $zero, $v0				# s4 = address of upper left corner

		addi $s5, $zero, 0				# s5 = row counter
		addi $s6, $zero, 0				# s6 = column counter
		add $s7, $zero, $s0			# s7 = x coord

		jal getScreenWidthInBytes
		add $t2, $zero, $v0				# t2 = screen width in bytes

colorRect_loopCol:
		add $a0, $zero, $s7
		jal fixXCoord
		add $t0, $zero, $v0

		add $t1, $zero, $s4			   # current = s4		
		addi $s5, $zero, 0			   # reset row counter	   

		blt $t0, $s7, colorRect_adjust # if fixed x coord < original x coord, adjust s7 and s4
		blt $s7, $t0, colorRect_adjust # if fixed x coord > original x coord, adjust s7 and s4

colorRect_loopRow:
		sw $v1, 0($t1)					# color pixel
		addi $s5, $s5, 1				# increment row counter
		add $t1, $t1, $t2				# increment address by screen width
		blt $s5, $s2, colorRect_loopRow # if row counter < num of rows, keep looping in loopRow

		addi $s6, $s6, 1				# increment column counter
	    addi $s4, $s4, 4				# increment upper left corner forward
	    addi $s7, $s7, 1				# increment x coord

		blt $s6, $s3, colorRect_loopCol # if column counter < num of cols, keep looping in loopCol

		lw $ra, 0($sp)					# else, done with colorRect
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

colorRect_adjust:
		add $s7, $zero, $t0				# make s7 equal to new x coord
		add $a0, $zero, $s7
		add $a1, $zero, $s1
		jal getAddressFromCoordinate
		add $s4, $zero, $v0				# adjust upper left corner
		add $t1, $zero, $s4				# adjust t1 = s4

		j colorRect_loopRow
		

