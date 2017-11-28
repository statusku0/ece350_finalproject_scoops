.data

.text
		.globl main

### TODO: 
## - implement previous block structure (to be able to delete previous block position)

#### NOTES:
## "li $reg, number" can be replaced with "addi $reg, $t0, number"

### constants:
## t0 = 0
## 0x10000000 - start pixel

### colorPixel:
## a0 = pixel
## a1 = color

### wait:
## a0 = number of cycles to wait for

### enviornment:
## 0x10040000 - moving block location (32 bit)
## 0x10040020 - moving block color (32 bit)
## 0x10040040 - previous moving block location (32 bit)
## 0x10040060 - previous moving block color (32 bit)


main:    
		## initialize environment

		# initialize moving blocks
	    addi $a0, $t0, 0x10040000
		addi $a1, $t0, 0x10010000
	    addi $a2, $t0, 0x00ff0000

	    jal init_block

	    addi $a0, $t0, 0x10040040
	    addi $a1, $t0, 0x10020000
	    addi $a2, $t0, 0x000000ff

	    jal init_block

	    addi $s0, $t0, 0				# initialize counter
	    addi $s1, $t0, 1000				# set max value for counter

main_loop:
		addi $a0, $t0, 0x10040000
	    jal draw_block					# draw block

	    addi $a0, $t0, 0x10040040
	    jal draw_block					# draw block

	    addi $a0, $t0, 100				
	    jal wait 						# wait a0 cycles

	    addi $a0, $t0, 0x10040000
	    jal move_block					# change block location

	    addi $a0, $t0, 0x10040040
	    jal move_block					# change block location

	    addi $s0, $s0, 1				# increment counter
	    bne $s0, $s1, main_loop			# if counter < max value, loop again

	    j exit							# else, exit

# a0 = location in memory, a1 = pixel location, a2 = color
init_block:
	    add $t4, $t0, $a0
		add $t6, $t0, $a1
	    add $t7, $t0, $a2

	    sw $a1, 0($a0)					# store location of block
	    sw $a2, 4($a0)					# store color of block

	    jr $ra

# a0 = location in memory
move_block:
		addi $sp, $sp, -4
		sw $ra, 0($sp)

	    add $t4, $t0, $a0
	    lw $t6, 0($t4)					# get block location

	    addi $t6, $t6, 4				# increment block location by 1 pixel
	    sw $t6, 0($t4)					# store location of block

	    lw $ra, 0($sp)
	    addi $sp, $sp, 4	
	    jr $ra

# a0 = location in memory
draw_block:
		addi $sp, $sp, -4
		sw $ra, 0($sp)

		add $t1, $t0, $a0

		lw $t4, 0($t1)					# load in block location
		lw $t5, 4($t1)					# load in block color					
		add $a0, $t0, $t4				# set location
		add $a1, $t0, $t5				# set color

		jal colorPixel					# color pixel
		
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		jr $ra  						

wait:   
		addi $t1, $t0, 0				# initialize counter

wait_loop:
		addi $t1, $t1, 1				# increment counter
		bne $t1, $a0, wait_loop 	    # if t1 hasn't reached a0 yet, repeat loop

		jr $ra   						# else, return


colorPixel:
		sw $a1, 0($a0)					# save color in pixel address location
		jr $ra
		

exit:
		li $v0, 10  # Syscall number 10 is to terminate the program
		syscall     # exit now


