.data

.text
		.globl main

# Bitmap display: 512 by 256 pixels, unit pixel width/height = 32, base address for display = 0x10008000

# Global Mem:
# 0x10000000 = screen row length
# 0x10000004 = screen column length
# 0x10000008 = pointer to end of heap
# 0x1000000c = player 1 input
# 0x10000010 = player 2 input
# 0x10000014 = 1 if want screen flip, 0 otherwise

main:
		jal initVars					# initialize constants/global pointers

		#-----Instantiates a block object----#
		addi $a0, $zero, 1				# set block num of rows (in pixels)
		addi $a1, $zero, 3				# set block num of columns (in pixels)
		addi $a2, $zero, 0		
		addi $a3, $zero, 15   
		jal Block_construct			    # construct block

		#-----$s0 now refers to the block created above-----#
		add $s0, $zero, $v0 			# save block mem location

		#-----Instantiates a block object----#
		addi $a0, $zero, 1				# set block num of rows (in pixels)
		addi $a1, $zero, 3				# set block num of columns (in pixels)
		addi $a2, $zero, 29		
		addi $a3, $zero, 15   
		jal Block_construct			    # construct block

		#-----$s1 now refers to the block created above-----#
		add $s1, $zero, $v0 			# save block mem location

		addi $a0, $zero, 4
		jal FoodSet_construct

		add $s3, $zero, $v0

		addi $a0, $zero, 3
		jal FoodSet_construct

		add $s4, $zero, $v0


		#-----Set up game clock------#
		addi $s5, $zero, 0				# s5 = global cycle counter

move_block_across_screen:
		
		#-----Check collision with s0 platform-----#
		add $a0, $zero, $s0
		add $a1, $zero, $s3
		jal detectCollisionBlockFoodSet # check platform collision with s3 FoodSet
		add $a0, $zero, $v0
		jal interpretCollision

		add $a0, $zero, $s0
		add $a1, $zero, $s4
		jal detectCollisionBlockFoodSet # check platform collision with s4 FoodSet
		add $a0, $zero, $v0
		jal interpretCollision

		#-----Check collision with s1 platform-----#
		add $a0, $zero, $s1
		add $a1, $zero, $s3
		jal detectCollisionBlockFoodSet # check platform collision with s3 FoodSet
		add $a0, $zero, $v0
		jal interpretCollision

		add $a0, $zero, $s1
		add $a1, $zero, $s4
		jal detectCollisionBlockFoodSet # check platform collision with s4 FoodSet
		add $a0, $zero, $v0
		jal interpretCollision

	    addi $t0, $zero, 0xffff0004
	    lw $a0, 0($t0)					# get keyboard input
	    jal storeKeyboardInput

		add $a0, $zero, $s0
		addi $a1, $zero, 0x1000000c
		addi $a2, $zero, 0x0000ff00
		addi $a3, $zero, 100			# key 1 = "d"
		addi $v1, $zero, 97				# key 2 = "a"
		jal Block_modify

		add $a0, $zero, $s1
		addi $a1, $zero, 0x10000010
		addi $a2, $zero, 0x00551a8b
		addi $a3, $zero, 108			# key 1 = "l"
		addi $v1, $zero, 106		    # key 2 = "j"
		jal Block_modify

		add $a0, $zero, $s3
		jal FoodSet_modify

		addi $t0, $zero, 5
		blt $s5, $t0, move_block_across_screen_wait

		add $a0, $zero, $s4
		jal FoodSet_modify

move_block_across_screen_wait:
		addi $a0, $zero, 100			
		jal wait  						# wait a number of cycles
		addi $s5, $s5, 1				# increment global counter

		j move_block_across_screen

#--------#
# a0 = food type
interpretCollision:
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

		addi $s0, $zero, 0
		addi $s1, $zero, 1
		addi $s2, $zero, 2

		bne $a0, $s0, interpretCollision_check2
		addi $a0, $zero, 31
		addi $a1, $zero, 7
		addi $a2, $zero, 0x00228b22		# dark green
		jal colorPixel

interpretCollision_check2:
		bne $a0, $s1, interpretCollision_check3
		addi $a0, $zero, 0
		addi $a1, $zero, 7
		addi $a2, $zero, 0x008b0000		# red
		jal colorPixel

interpretCollision_check3:
		bne $a0, $s2, interpretCollision_end
		jal eraseScreen					# erase screen
		addi $t0, $zero, 1
		addi $t1, $zero, 0x10000000
		lw $t2, 20($t1)					
		bne $t2, $zero, interpretCollision_check3_makeZero # if flip screen = 1, then make flip screen = 0
		sw $t0, 20($t1)									   # else, make flip screen = 1
		j interpretCollision_end

interpretCollision_check3_makeZero:
		sw $zero, 20($t1)				
		j interpretCollision_end

interpretCollision_end:  
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
		
		add $a0, $zero, $v0 			# random x coord
		jal getRandomZeroOrOneOrTwo
		add $a1, $zero, $v0				# random type
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
		addi $s0, $s0, 20			# increment by size of one Food object
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

# a0 = mem location of FoodSet, a1 = keyboard input
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

		add $s0, $zero, $a0			# s0 = mem location of FoodSet
		add $s5, $zero, $s0			# s5 = s0
		lw $s1, 0($s0)				# s1 = number of Food objects
		addi $s0, $s0, 4			# s0 = mem location of Food objects

		addi $s2, $zero, 0			# s2 = counter

		j FoodSet_modify_reset		# check if FoodSet needs to be reset

FoodSet_modify_Food_modify_loop:
		add $a0, $zero, $s0
		jal Food_modify
		
		addi $s2, $s2, 1			# increment counter
		addi $s0, $s0, 20			# increment by size of one Food object
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

# a0 = x coordinate of upper left corner, a1 = type (0 for good, 1 for bad), v0 = mem location, v1 = size of object (bytes)
Food_construct:
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

		add $s0, $zero, $a1			# s0 = type

		add $a2, $zero, $a0
		addi $a0, $zero, 1			# num of rows = 1
		addi $a1, $zero, 1			# num of cols = 1
		addi $a3, $zero, -1			# y coord of upper left corner = -1
		jal Block_construct

		add $s1, $zero, $v0			# s1 = mem location
		add $s2, $zero, $v1			# s2 = size of object

		jal getHeapPointer	
		sw $s0, 0($v0)				# save type
		addi $v0, $v0, 4			# increment heap pointer
		add $a0, $zero, $v0
		jal saveHeapPointer

		add $v0, $zero, $s1
		addi $v1, $s2, 4

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

# a0 = mem location of Food, a1 = keyboard input
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
		jal Food_getType
		bne $v0, $zero, Food_modify_pickColor_1
		j Food_modify_pickColor_0

Food_modify_draw:
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

Food_modify_pickColor_0:
		addi $a1, $zero, 0x00ff0000     # red
		j Food_modify_draw

Food_modify_pickColor_1:
		addi $t0, $zero, 1
		bne $v0, $t0, Food_modify_pickColor_2
		addi $a1, $zero, 0x00ffff00     # yellow
		j Food_modify_draw

Food_modify_pickColor_2:
		addi $a1, $zero, 0x00ffa500		# orange
		j Food_modify_draw
#-------#

# a0 = mem location of Food
Food_getType:
		lw $v0, 16($a0)
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

# a0 = mem location of block, a1 = mem location of keyboard input, a2 = color, a3 = key 1 to look for, a4 = key 2 to look for
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
		lw $s1, 0($a1)					# save keyboard input to s1
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

	    bne $s1, $a3, Block_modify_check2 # if keyboard input not equal to key 1, go to next check

	    add $a0, $zero, $s3
	    add $a1, $zero, $s4
	    add $a2, $zero, $s5
	    addi $a3, $zero, 1
	    addi $v1, $zero, 0x00000000
		jal colorRect

		add $a0, $zero, $s0
		jal Block_moveRight

Block_modify_check2:
		bne $s1, $v1, Block_modify_draw # if keyboard input not equal to key 2, don't do anything

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

        add $v0, $zero, 0x10008000	# v0 = output address

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

		addi $t0, $zero, 16
		addi $t1, $zero, 32
		addi $t2, $zero, 0x10000000
		sw $t0, 0($t2)					# store screen height (in pixels)
		sw $t1, 4($t2)					# store screen width (in pixels)

		addi $t0, $zero, 0x10040000		
		sw $t0, 8($t2)					# store pointer to end of heap

		addi $t0, $zero, 0
		sw $t0, 12($t2)					# place to store random 0 or 1

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

getHeapPointer:
		addi $t0, $zero, 0x10000000
		lw $v0, 8($t0)					# get heap pointer

		jr $ra


#------------#

# a0 = heap pointer to save
saveHeapPointer:
		addi $t0, $zero, 0x10000000
		sw $a0, 8($t0)					# save heap pointer

		jr $ra
		
#------------#

# right now, this just alternates between 0 and 1 and 2
getRandomZeroOrOneOrTwo:
		addi $t0, $zero, 0x10000000
		lw $t1, 12($t0)

		addi $t2, $zero, 1
		blt $t2, $t1, getRandomZeroOrOneOrTwo_makeZero	# if t1 > 1 (i.e. t1 >= 2) reset
		addi $t1, $t1, 1

getRandomZeroOrOneOrTwo_return:
		sw $t1, 12($t0)
		add $v0, $zero, $t1
		jr $ra

getRandomZeroOrOneOrTwo_makeZero:
		addi $t1, $zero, 0
		j getRandomZeroOrOneOrTwo_return
		



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

		jal checkIfOutOfBounds
		bne $v0, $zero, colorRect_end	# if rectangle out of bounds, don't color it

		addi $t0, $zero, 0x10000000
		lw $t1, 20($t0)
		addi $t2, $zero, 1
		bne $t1, $t2, colorRect_init	# if flip screen = 0, continue as normal

		jal getScreenHeight
		sub $s1, $v0, $s1  			    # else, flip y coord
		sub $s1, $s1, $s2 				# make it y coord of upper left corner

colorRect_init:
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

colorRect_end:
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


#---------#

# a0 = block 1, a1 = block 2, v0 = 0 if no collision, 1 if collision
isCollision:
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

		add $s0, $zero, $a0			# s0 = block 1
		add $s1, $zero, $a1         # s1 = block 2

		add $a0, $zero, $s0	
		jal Block_getYCoordUpperLeft
		add $s2, $zero, $v0			# s2 = y coord of top of block 1

		add $a0, $zero, $s0
		jal Block_getNumRows
		add $s4, $zero, $v0
		add $s4, $s4, $s2
		addi $s4, $s4, -1			# s4 = y coord of bottom of block 1

		add $a0, $zero, $s1
		jal Block_getYCoordUpperLeft
		add $s3, $zero, $v0			# s3 = y coord of top of block 2

		add $a0, $zero, $s1
		jal Block_getNumRows
		add $s5, $zero, $v0
		add $s5, $s5, $s3
		addi $s5, $s5, -1			# s5 = y coord of bottom of block 2

		addi $v0, $zero, 0

		bne $s3, $s4, isCollision_check2
		j isCollision_Xcheck

isCollision_check2:
		bne $s5, $s2, isCollision_end
		j isCollision_Xcheck

isCollision_Xcheck:
		add $a0, $zero, $s0
		jal Block_getXCoordUpperLeft
		add $s2, $zero, $v0			# s2 = block 1: x coord of upper left corner

		add $a0, $zero, $s0
		jal Block_getNumCols
		add $s3, $s2, $v0
		addi $s3, $s3, -1			
		add $a0, $zero, $s3
		jal fixXCoord
		add $s3, $zero, $v0         # s3 = block 1: x coord of right side

		add $a0, $zero, $s1
		jal Block_getXCoordUpperLeft
		add $s4, $zero, $v0			# s4 = block 2: x coord of upper left corner

		add $a0, $zero, $s1
		jal Block_getNumCols
		add $s5, $s4, $v0
		addi $s5, $s5, -1
		add $a0, $zero, $s5			
		jal fixXCoord
		add $s5, $zero, $v0			# s5 = block 2: x coord of right side

		addi $v0, $zero, 0

		blt $s3, $s4, isCollision_Xcheck2
		blt $s5, $s2, isCollision_end
		addi $v0, $zero, 1

isCollision_Xcheck2:
        blt $s2, $s5, isCollision_end
        addi $v0, $zero, 1

isCollision_end:
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
# a0 = block (platform), a1 = FoodSet, v0 = if collision, type of Food hit; if no collision, -1
detectCollisionBlockFoodSet:
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

		add $s3, $zero, $a0			# s3 = block (platform)
		add $s0, $zero, $a1			# s0 = mem location of FoodSet
		add $s5, $zero, $s0			# s5 = s0
		lw $s1, 0($s0)				# s1 = number of Food objects
		addi $s0, $s0, 4			# s0 = mem location of Food objects

		addi $s2, $zero, 0			# s2 = counter

		addi $s6, $zero, -1			# set default value

detectCollisionBlockFoodSet_loop:
		add $a0, $zero, $s0
		add $a1, $zero, $s3
		jal isCollision
		bne $v0, $zero, detectCollisionBlockFoodSet_setOut # collision detected, set output
		
		addi $s2, $s2, 1			# increment counter
		addi $s0, $s0, 20			# increment by size of one Food object
		blt $s2, $s1, detectCollisionBlockFoodSet_loop

detectCollisionBlockFoodSet_end:
		add $v0, $zero, $s6
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

detectCollisionBlockFoodSet_setOut:
		add $a0, $zero, $s0
		jal Food_getType
		add $s6, $zero, $v0
		j detectCollisionBlockFoodSet_end

#---------#
# a0 = keyboard input
storeKeyboardInput:
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

		add $s0, $zero, $a0			# s0 = keyboard input
		addi $s1, $zero, 100		# s1 = "d"
		addi $s2, $zero, 97			# s2 = "a"
		addi $s3, $zero, 108
		addi $s4, $zero, 106
		addi $s5, $zero, 0x10000000 

		bne $s0, $s1, storeKeyboardInput_player1_check2
		sw $s0, 12($s5)				# store player 1 input

storeKeyboardInput_player1_check2:
		bne $s0, $s2, storeKeyboardInput_player2_check1
		sw $s0, 12($s5)				# store player 1 input

storeKeyboardInput_player2_check1:
		bne $s0, $s3, storeKeyboardInput_player2_check2
		sw $s0, 16($s5)				# store player 2 input

storeKeyboardInput_player2_check2:
		bne $s0, $s4, storeKeyboardInput_end
		sw $s0, 16($s5)				# store player 2 input

storeKeyboardInput_end:
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
eraseScreen:
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

		jal getScreenHeight
		add $s0, $zero, $v0			# s0 = screen height
		jal getScreenWidth
		add $s1, $zero, $v0			# s1 = screen width

		addi $a0, $zero, 0
		addi $a1, $zero, 0
		add $a2, $zero, $s0
		add $a3, $zero, $s1
		addi $v1, $zero, 0x00000000
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

#---------#

# (currently assumes upper left corner is within bounds and only checks that block fits in screen vertically)
# a0 = x coord of upper left corner, a1 = y coord of upper left corner, a2 = num of rows, a3 = num of columns, v0 = 0 if not out of bounds, 1 if so
checkIfOutOfBounds:
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

		add $s1, $zero, $a1			# s1 = y coord of upper left corner
		add $s2, $zero, $a2			# s2 = num of rows

		jal getScreenHeight
		add $s0, $zero, $v0			# s0 = screen height

		addi $v0, $zero, 0

		add $t0, $s1, $s2
		addi $t0, $t0, -1
		blt $t0, $s0, checkIfOutOfBounds_end
		addi $v0, $zero, 1

checkIfOutOfBounds_end:
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
