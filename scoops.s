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

		addi $t0, $zero, 0x10000000
		lw $t1, 8($t0)					# get heap pointer

		#-----Instantiates a block object----#
		add $a0, $zero, $t1				# set mem location of block
		addi $a1, $zero, 2				# set block num of rows (in pixels)
		addi $a2, $zero, 5				# set block num of columns (in pixels)
		addi $a3, $zero, 0x10010000		# set block upper left corner
		jal constructBlock			    # construct block

		#-----Increments end-of-heap pointer-----#
		add $t1, $v0, $v1				# increment heap pointer
		sw $t1, 8($t0)					# save heap pointer

		#-----$s0 now refers to the block created above-----#
		add $s0, $zero, $v0 			# save block mem location

		#-----Instantiates a block object----#
		add $a0, $zero, $t1				# set mem location of block
		addi $a1, $zero, 2				# set block num of rows (in pixels)
		addi $a2, $zero, 5				# set block num of columns (in pixels)
		addi $a3, $zero, 0x100100a0		# set block upper left corner
		jal constructBlock			    # construct block

		#-----Increments end-of-heap pointer-----#
		add $t1, $v0, $v1				# increment heap pointer
		sw $t1, 8($t0)					# save heap pointer

		#-----$s1 now refers to the block created above-----#
		add $s1, $zero, $v0 			# save block mem location


#-----Life Cycle of Block-----#
# 1. constructBlock
# 2. drawBlock
# 3. modifyBlock (includes erasing old block)
# 4. go to step 2

move_block_across_screen:
		add $a0, $zero, $s0
		addi $a1, $zero, 0x00ff0000		# set block to be red
		jal drawBlock

		add $a0, $zero, $s1
		addi $a1, $zero, 0x000000ff		# set block to be blue
		jal drawBlock

	    addi $t0, $zero, 0xffff0004
	    lw $a1, 0($t0)					# get keyboard input
		add $a0, $zero, $s0
		jal modifyBlock

		addi $t0, $zero, 0xffff0004
	    lw $a1, 0($t0)					# get keyboard input
	    add $a0, $zero, $s1
		jal modifyBlock

		addi $a0, $zero, 10000			
		jal wait  						# wait 10000 cycles

		j move_block_across_screen


#------BLOCK OBJECT METHODS-----#

# a0 = mem location, a1 = num of rows, a2 = num of columns, a3 = pixel location of upper left corner
constructBlock:							# acts as the "constructor" for the block object
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

		sw $a1, 0($a0)					# save attributes in mem address
		sw $a2, 4($a0)
		sw $a3, 8($a0)

		add $v0, $zero, $a0				# output start mem location
		add $v1, $zero, 12				# output size of object

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

# a0 = mem location of block
drawBlock:
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
		lw $t1, 4($t0)					# get screen column length

		addi $t3, $zero, 0				# init counter for column
		addi $t4, $zero, 0				# init counter for row

		lw $t5, 0($a0)					# get block num of rows
		lw $t6, 4($a0)					# get block num of columns
		lw $t7, 8($a0)					# get block upper left corner location

		add $a0, $zero, $t7 			# set a0 to upper left corner location

drawBlock_helper1:
		addi $t4, $zero, 0 				# reset row counter

		addi $sp, $sp, -4
		sw $a0, 0($sp)					# save a0 from helper1

drawBlock_helper2:
		jal colorPixel					# color pixel
		addi $t4, $t4, 1				# increment row counter
		add $a0, $a0, $t1				# move to pixel + screen 

		bne $t4, $t5, drawBlock_helper2 # if row counter != block num of rows, keep looping in inner loop

		lw $a0, 0($sp)					# restore a0 from helper1
		addi $sp, $sp, 4				

		addi $t3, $t3, 1				# increment column counter
		add $a0, $a0, 4					# move to next pixel

		bne $t3, $t6, drawBlock_helper1 # if column counter != block num of columns, keep looping in outer loop

		lw $ra, 0($sp)					# else, done with drawBlock
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

# a0 = mem location of block
eraseBlock:
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

		addi $a1, $zero, 0x00000000		# set second arg to black
		jal drawBlock

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
modifyBlock:
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

		addi $t1, $zero, 97
	    bne $a1, $t1, modifyBlock_cleanup # if keyboard input not equal to "a", don't do anything

	    addi $sp, $sp, -4
		sw $a0, 36($sp)
		jal eraseBlock					# erase old block
		lw $a0, 36($sp)
		addi $sp, $sp, 4

		lw $t0, 8($a0)					# get location of upper left corner
		addi $t0, $t0, 4				# increment block location by 1 pixel
		sw $t0, 8($a0)					# save block location

modifyBlock_cleanup:

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

# a0 = ASCII char to wait for
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

