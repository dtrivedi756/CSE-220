#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################

.text

load_board:

    addi $sp, $sp, -32					# Allocates space in the stack to store the $s registers.
    sw $s0, 0($sp)					# Stores the $s0 register on the stack.
    sw $s1, 4($sp)					# Stores the $s1 register on the stack.
    sw $s2, 8($sp)					# Stores the $s2 register on the stack.
    sw $s3, 12($sp)					# Stores the $s3 register on the stack.
    sw $s4, 16($sp)					# Stores the $s4 register on the stack.
    sw $s5, 20($sp)					# Stores the $s5 register on the stack.
    sw $s6, 24($sp)					# Stores the $s6 register on the stack.
    sw $s7, 28($sp)					# Stores the $s7 register on the stack.
    addi $sp, $sp, -1					# Allocates space in the stack to store the bytes read from the file.
    move $s7, $sp					# Moves the stack pointer to the $s7 register.
    move $s0, $a0					# Moves the reference to the board struct to the $s0 register.
    move $s1, $a1					# Moves the filename to the $s1 register.
    li $s2, 0						# Keeps track of the number of invalid characters in the file.
    li $s3, 0						# Keeps track of the number of O's in the file.
    li $s4, 0						# Keeps track of the number of X's in the file.
    move $a0, $a1					# Stores the filename in the $a0 register.
    li $a1, 0						# Loads the read-only flag in the $a1 register.
    li $a2, 0						# Sets the mode value to zero in the $a2 register.
    li $v0, 13						# Loads service number 13 in the $v0 register.
    syscall						# Makes a system call to open the file.
    move $s5, $v0					# Moves the file descriptor to the $s5 register.
    blt $s5, $0, getNegativeOne				# If the file descriptor is negative, then jump to the label.
    li $t1, 0						# Helps to keep track if the number of rows and columns have been read.
    li $t2, 0						# Helps to restore the base address of the board struct.
    li $t7, 0						# Keeps track if the process of reading the rows/columns is finished or not.
    li $t4, 0						# Holds the integer value of the number of rows/columns.
    
    readRowsAndColumnsFromFile:
    	move $a0, $s5					# Moves the file descriptor to the $a0 register.
	move $a1, $s7					# Stores the input buffer which is the reference to the stack pointer.
	li $a2, 1					# Stores the maximum number of characters to read.
	li $v0, 14					# Loads service number 14 in the $v0 register.
	syscall						# Makes a system call in order to read from the file.
	move $t0, $v0					# Moves the number of characters read to the $t0 register.
	beq $t0, $0, setTheReturnValue			# If the number of characters read is zero, then jump to the label.
    	lbu $t3, 0($s7)					# Gets the character read from the file.
    	beq $t3, '\n', restoreValues			# If the end of line character has been reached, then jump to the label.
    	addi $t1, $t1, 1				# Adds one to the count.
    	beq $t1, 2, setToCorrectInteger			# If the count is 2, then jump to the label.
    	addi $t3, $t3, -48				# Converts the character into an integer.
    	add $t4, $t3, $t4				# Adds the integer that represents the number of rows/columns.
    	blt $t1, 2, readRowsAndColumnsFromFile		# If the count is less than 2, then jump back to the label/loop.
    	
    restoreValues:
    	beq $t1, 1, setToCorrectIntegerLengthOne	# If the count is 1, then jump to the label.
    	li $t1, 0					# Keeps track of the number of characters read from the board in the file.
    	li $t4, 0					# Restores the value of the $t4 register.
    	beq $t3, '\n', readRowsAndColumnsFromFile	# If the end of line character has been reached, then jump to the label/loop.
    	addi $t7, $t7, 1				# Adds one to the $t7 register to keep track if the rows/columns are read.
    	blt $t7, 2, readRowsAndColumnsFromFile		# If the $t7 register is not = to 2, then jump back to the label/loop.
    	add $s0, $s0, $t2				# Restores the base address of the board struct.
    	lw $t5, 0($s0)					# Stores the number of rows in the board.
    	lw $t6, 4($s0)					# Stores the number of columns in the board.
    	mul $t4, $t5, $t6 				# Stores the number of characters in the board.
    	addi $s0, $s0, 8				# Moves to the correct base address before moving on to the next label/loop.
    	j readBoardStructFromFile			# Jumps to the label/loop.
    	
    setToCorrectIntegerLengthOne:
     	sw $t4, 0($s0)					# Stores the number of rows/columns in the board struct.
    	addi $s0, $s0, 4				# Moves on to the next 4 bytes in the board struct.
    	addi $t2, $t2, -4				# Adds -4 to the $t2 register in order to restore the address of board struct.
    	li $t1, 0					# Keeps track of the number of characters read from the board in the file.
    	li $t4, 0					# Restores the value of $t4.
    	addi $t7, $t7, 1				# Adds one to the $t7 register to keep track if the rows/columns are read.
    	blt $t7, 2, readRowsAndColumnsFromFile		# If the $t7 register is not = to 2, then jump back to the label/loop.
    	add $s0, $s0, $t2				# Restores the base address of the board struct.
    	lw $t5, 0($s0)					# Stores the number of rows in the board.
    	lw $t6, 4($s0)					# Stores the number of columns in the board.
    	mul $t4, $t5, $t6 				# Stores the number of characters in the board.
    	addi $s0, $s0, 8				# Moves to the correct base address before moving on to the next label/loop.
    	j readBoardStructFromFile			# Jumps to the label/loop.
    	
    setToCorrectInteger:
    	li $t6, 10					# Stores 10 in the $t6 register.			
    	mul $t4, $t4, $t6				# Multiplies the $t4 register by 10.
    	addi $t3, $t3, -48				# Converts the character into an integer.
    	add $t4, $t3, $t4				# Adds the integer that represents the number of rows/columns.
    	sw $t4, 0($s0)					# Stores the number of rows/columns in the board struct.
    	addi $s0, $s0, 4				# Moves on to the next 4 bytes in the board struct.
    	addi $t2, $t2, -4				# Adds -4 to the $t2 register in order to restore the address of board struct.
    	j restoreValues					# Jumps to the restoreValues label.
    	
    readBoardStructFromFile:
    	beq $t1, $t4, setTheReturnValue			# If the count reaches the number of characters in the board, jump to label.
    	move $a0, $s5					# Moves the file descriptor to the $a0 register.
	move $a1, $s0					# Stores the input buffer which is the board struct.
	li $a2, 1					# Stores the maximum number of characters to read.
	li $v0, 14					# Loads service number 14 in the $v0 register.
	syscall						# Makes a system call in order to read from the file.
	move $t0, $v0					# Moves the number of characters read to the $t0 register.
	beq $t0, $0, setTheReturnValue			# If the number of characters read is zero, then jump to the label.
	lbu $t5, 0($s0)					# Gets the character stored in the board struct.
	beq $t5, '\n', readBoardStructFromFile		# If the end of line character is read, then jump back to the label/loop.
	addi $t1, $t1, 1				# Adds one to the count for the number of characters read.
	addi $s0, $s0, 1				# Adds one to the address of the board struct to store the next character.
	addi $t2, $t2, -1				# Helps to restore the base address of the board struct.
	beq $t5, 'O', addOneToNumOfOs			# If the character is an 'O', then jump to the label.
	beq $t5, 'X', addOneToNumOfXs			# If the character is an 'X', then jump to the label.
	beq $t5, '.', readBoardStructFromFile		# If the character is a '.', then jump back to the label/loop.
	bne $t5, '.', changeCharacter			# If the character is not an 'O', 'X', or '.', then jump to the label.
	
    addOneToNumOfOs:	
    	addi $s3, $s3, 1				# Adds one to the count for the number of O's in the board.
    	j readBoardStructFromFile			# Jumps back to the label/loop.
    	
    addOneToNumOfXs:
    	addi $s4, $s4,	1				# Adds one to the count for the number of X's in the board.
    	j readBoardStructFromFile			# Jumps back to the label/loop.
    	
    changeCharacter:
    	addi $s0, $s0, -1				# Adds -1 to the address of the board struct to store the character.
	addi $t2, $t2, 1				# Helps to restore the base address of the board struct.
    	li $t6, '.'					# Stores the period in the $t6 register.
    	sb $t6, 0($s0)					# Stores the period in the board struct.
    	addi $s2, $s2, 1				# Adds one to the count for the number of invalid characters in the board.
    	addi $s0, $s0, 1				# Adds one to the address of the board struct to store the next character.
	addi $t2, $t2, -1				# Helps to restore the base address of the board struct.
    	j readBoardStructFromFile			# Jumps back to the label/loop.
    	
    setTheReturnValue:
    	sll $s4, $s4, 8					# Shifts the number of X's to the left by 8.
    	add $s4, $s4, $s3				# Adds the number of O's to the $s4 register.
    	sll $s4, $s4, 8					# Shifts the number of X's to the left by 8.
    	add $s4, $s4, $s2				# Adds the number of invalid characters to the $s4 register.
    	move $s6, $s4					# Moves the result to the $s6 register.
    	j returnCount					# Jumps to the returnCount label.
    	
    getNegativeOne:
    	li $s6, -1					# Stores negative one in the $s6 register.
    	
    returnCount:
    	add $s0, $s0, $t2				# Restores the base address of the board struct argument.
    	move $a0, $s0					# Restores the reference to the board struct argument.
    	move $a1, $s1					# Restores the filename.
    	move $v0, $s6					# Moves the return value to the $v0 register.
    	addi $sp, $sp, 1				# Deallocates space from the stack.
    	lw $s0, 0($sp)					# Loads the $s0 register from the stack.
    	lw $s1, 4($sp)					# Loads the $s1 register from the stack.
    	lw $s2, 8($sp)					# Loads the $s2 register from the stack.
   	lw $s3, 12($sp)					# Loads the $s3 register from the stack.
    	lw $s4, 16($sp)					# Loads the $s4 register from the stack.
    	lw $s5, 20($sp)					# Loads the $s5 register from the stack.
    	lw $s6, 24($sp)					# Loads the $s6 register from the stack.
    	lw $s7, 28($sp)					# Loads the $s7 register from the stack.
    	addi $sp, $sp, 32				# Deallocates space from the stack.
    	jr $ra						# Returns the result back to the caller.
    
    
get_slot:
	
    addi $sp, $sp, -16					# Allocates space in the stack to store the $s registers.
    sw $s1, 0($sp)					# Stores the $s1 register in the stack.
    sw $s2, 4($sp)					# Stores the $s2 register in the stack.
    sw $s3, 8($sp)					# Stores the $s3 register in the stack.
    sw $s4, 12($sp)					# Stores the $s4 register in the stack.	
    lw $s1, 0($a0)					# Loads the number of rows from the board struct into the $s1 register.
    lw $s2, 4($a0)					# Loads the number of columns from the board struct into the $s2 register.
    blt $a1, $0, returnNegativeOne			# If the row index is less than 0, then return -1.
    bge $a1, $s1, returnNegativeOne			# If the row index is >= to the number of rows, then return -1.
    blt $a2, $0, returnNegativeOne			# If the column index is less than 0, then return -1.
    bge $a2, $s2, returnNegativeOne			# If the column index is >= to the number of columns, then return -1.
    li $s3, 0						# The $s3 register will store the base address of the character from the board.
    add $s3, $s3, $a0					# Adds the base address of the board struct to the $s3 register.
    addi $s3, $s3, 8					# Adds 8 to the address in order to access the contents of the board.
    mul $t0, $a1, $s2					# Multiplies the row index by the number of columns.
    add $s3, $s3, $t0					# Adds the result of the multiplication to the $s3 register.
    add $s3, $s3, $a2					# Adds the column index to the $s3 register.
    lbu $s4, 0($s3)					# Gets the character located at the row and column indices.
    j returnCharOrNegativeOne				# Jumps to the label to return the character back to the caller.
    
    returnNegativeOne:
    	li $s4, -1					# Stores -1 in the $s4 register to return back to the caller later.
    	
    returnCharOrNegativeOne:
    	move $v0, $s4					# Moves the result to the $v0 register.
    	lw $s1, 0($sp)					# Loads the $s1 register from the stack.
    	lw $s2, 4($sp)					# Loads the $s2 register from the stack.
    	lw $s3, 8($sp)					# Loads the $s3 register from the stack.
    	lw $s4, 12($sp)					# Loads the $s4 register from the stack.
    	addi $sp, $sp, 16				# Deallocates space from the stack.
    	jr $ra						# Returns the result back to the caller.


set_slot:
	
    addi $sp, $sp, -16					# Allocates space in the stack to store the $s registers.
    sw $s1, 0($sp)					# Stores the $s1 register in the stack.
    sw $s2, 4($sp)					# Stores the $s2 register in the stack.
    sw $s3, 8($sp)					# Stores the $s3 register in the stack.
    sw $s4, 12($sp)					# Stores the $s4 register in the stack.
    lw $s1, 0($a0)					# Loads the number of rows from the board struct into the $s1 register.
    lw $s2, 4($a0)					# Loads the number of columns from the board struct into the $s2 register.
    blt $a1, $0, negativeOne				# If the row index is less than 0, then return -1.
    bge $a1, $s1, negativeOne				# If the row index is >= to the number of rows, then return -1.
    blt $a2, $0, negativeOne				# If the column index is less than 0, then return -1.
    bge $a2, $s2, negativeOne				# If the column index is >= to the number of columns, then return -1.
    li $s3, 0						# The $s3 register will store the base address of the character from the board.
    add $s3, $s3, $a0					# Adds the base address of the board struct to the $s3 register.
    addi $s3, $s3, 8					# Adds 8 to the address in order to access the contents of the board.
    mul $t0, $a1, $s2					# Multiplies the row index by the number of columns.
    add $s3, $s3, $t0					# Adds the result of the multiplication to the $s3 register.
    add $s3, $s3, $a2					# Adds the column index to the $s3 register.
    sb $a3, 0($s3)					# Sets the character at the row and column indices.
    move $s4, $a3					# Moves the character to the $s4 register.
    j returnResult					# Jumps to the label to return the character back to the caller.
    
    negativeOne:
    	li $s4, -1					# Stores -1 in the $s4 register to return back to the caller later.
    	
    returnResult:
    	move $v0, $s4					# Moves the result to the $v0 register.
    	lw $s1, 0($sp)					# Loads the $s1 register from the stack.
    	lw $s2, 4($sp)					# Loads the $s2 register from the stack.
    	lw $s3, 8($sp)					# Loads the $s3 register from the stack.
    	lw $s4, 12($sp)					# Loads the $s4 register from the stack.
    	addi $sp, $sp, 16				# Deallocates space from the stack.
    	jr $ra						# Returns the result back to the caller.


place_piece:
   
   	addi $sp, $sp, -20				# Allocates space in the stack to store the $s registers.
   	sw $s0, 0($sp)					# Stores the $s0 register in the stack.
    	sw $s1, 4($sp)					# Stores the $s1 register in the stack.
    	sw $s2, 8($sp)					# Stores the $s2 register in the stack.
    	sw $s3, 12($sp)					# Stores the $s3 register in the stack.
    	sw $s4, 16($sp)					# Stores the $s4 register in the stack.
   	beq $a3, 'X', beginToPlacePiece			# If the character is equal to 'X', then jump to the label.
   	beq $a3, 'O', beginToPlacePiece			# If the character is equal to 'O', then jump to the label.
   	bne $a3, 'O', setResultToNegativeOne		# If the character is not 'X' nor 'O', then return -1.
   	
   	beginToPlacePiece: 
    		lw $s1, 0($a0)				# Loads the number of rows from the board struct into the $s1 register.
    		lw $s2, 4($a0)				# Loads the number of columns from the board struct into the $s2 register.
    		blt $a1, $0, setResultToNegativeOne	# If the row index is less than 0, then return -1.
    		bge $a1, $s1, setResultToNegativeOne	# If the row index is >= to the number of rows, then return -1.
    		blt $a2, $0, setResultToNegativeOne	# If the column index is less than 0, then return -1.
    		bge $a2, $s2, setResultToNegativeOne	# If the column index is >= to the number of columns, then return -1.
    		li $s3, 0				# The $s3 register will store the base address of the character from the board.
    		add $s3, $s3, $a0			# Adds the base address of the board struct to the $s3 register.
    		addi $s3, $s3, 8			# Adds 8 to the address in order to access the contents of the board.
    		mul $t0, $a1, $s2			# Multiplies the row index by the number of columns.
    		add $s3, $s3, $t0			# Adds the result of the multiplication to the $s3 register.
    		add $s3, $s3, $a2			# Adds the column index to the $s3 register.
    		lbu $s4, 0($s3)				# Gets the character stored at the particular indices.
    		beq $s4, 'X', setResultToNegativeOne	# If the character is already a player piece, then return -1.
   		beq $s4, 'O', setResultToNegativeOne	# If the character is already a player piece, then return -1.
    		addi $sp, $sp, -4			# Allocates space in the stack to the store the $ra register.
    		sw $ra, 0($sp)				# Stores the $ra register in the stack.
    		jal set_slot				# Calls the set_slot function.
    		lw $ra, 0($sp)				# Restores the value of the $ra register.
    		addi $sp, $sp, 4			# Deallocates space from the stack.
    		move $s0, $v0				# Moves the result from the set_slot function to the $s0 register.
    		j returnValue				# Jumps to the returnValue label.
    
    setResultToNegativeOne:
    	li $s0, -1					# Stores -1 in the $s0 register.
    
    returnValue:
    	move $v0, $s0					# Moves the result to the $v0.
    	lw $s0, 0($sp)					# Loads the $s0 register from the stack.
    	lw $s1, 4($sp)					# Loads the $s1 register from the stack.
    	lw $s2, 8($sp)					# Loads the $s2 register from the stack.
    	lw $s3, 12($sp)					# Loads the $s3 register from the stack.
    	lw $s4, 16($sp)					# Loads the $s4 register from the stack.
    	addi $sp, $sp, 20				# Deallocates space from the stack.
    	jr $ra						# Returns the result back to the caller.	
    

game_status:
	
    addi $sp, $sp, -32					# Allocates space in the stack to store the $s register.
    sw $s0, 0($sp)					# Stores the $s0 register on the stack.
    sw $s1, 4($sp)					# Stores the $s1 register on the stack.
    sw $s2, 8($sp)					# Stores the $s2 register on the stack.
    sw $s3, 12($sp)					# Stores the $s3 register on the stack.
    sw $s4, 16($sp)					# Stores the $s4 register on the stack.
    sw $s5, 20($sp)					# Stores the $s5 register on the stack.
    sw $s6, 24($sp)					# Stores the $s6 register on the stack.
    sw $s7, 28($sp)					# Stores the $s7 register on the stack.
    move $s0, $a0					# Moves the reference to the board struct to the $s0 register.
    lw $s1, 0($a0)					# Gets the number of rows in the board struct.
    lw $s2, 4($a0)					# Gets the number of columns in the board struct.
    mul $s3, $s1, $s2					# Gets the total number of characters stored in the board struct.
    addi $s0, $s0, 8					# Moves on to the base address of the elements in the board.
    li $s4, 0						# Keeps track of the number of characters read from the board struct.
    li $s6, 0						# Stores the number of X's in the board struct.
    li $s7, 0						# Stores the number of O's in the board struct.
    
    loopThroughBoardStruct:
    	beq $s4, $s3, returnNums			# If the whole board has been read then return the results.
    	lbu $s5, 0($s0)					# Gets the character from the board struct.
    	addi $s0, $s0, 1				# Moves on to the next character in the board struct.
    	beq $s5, '\n', loopThroughBoardStruct		# If the end of line character is reached, then jump back to the label/loop.
    	addi $s4, $s4, 1				# Adds one to the number of characters read from the board struct.
    	beq $s5, 'X', addToNumOfXs			# If the character is an 'X', then jump to the label.
    	beq $s5, 'O', addToNumOfOs			# If the character is an 'O', then jump to the label.
    	bne $s5, 'O', loopThroughBoardStruct		# If the character is neither 'X' nor 'O', then jump back to the label/loop.
    	
    addToNumOfXs:
    	addi $s6, $s6, 1				# Adds one to the number of X's in the board struct.
    	j loopThroughBoardStruct			# Jumps back to the label/loop.
    	
    addToNumOfOs:
    	addi $s7, $s7, 1				# Adds one to the number of O's in the board struct.
    	j loopThroughBoardStruct			# Jumps back to the label/loop.
    	
    returnNums:
    	move $v0, $s6					# Moves the number of X's to the $v0 register.
    	move $v1, $s7					# Moves the number of O's to the $v1 register.
    	lw $s0, 0($sp)					# Loads the $s0 register from the stack.
    	lw $s1, 4($sp)					# Loads the $s1 register from the stack.
    	lw $s2, 8($sp)					# Loads the $s2 register from the stack.
   	lw $s3, 12($sp)					# Loads the $s3 register from the stack.
    	lw $s4, 16($sp)					# Loads the $s4 register from the stack.
    	lw $s5, 20($sp)					# Loads the $s5 register from the stack.
    	lw $s6, 24($sp)					# Loads the $s6 register from the stack.
    	lw $s7, 28($sp)					# Loads the $s7 register from the stack.
    	addi $sp, $sp, 32				# Deallocates space from the stack.
    	jr $ra						# Return the results back to the caller.


check_horizontal_capture:
	
	addi $sp, $sp, -24				# Allocates space in the stack to store the $s registers.
    	sw $s0, 0($sp)					# Stores the $s0 register on the stack.
    	sw $s2, 4($sp)					# Stores the $s2 register on the stack.
    	sw $s4, 8($sp)					# Stores the $s4 register on the stack.
    	sw $s5, 12($sp)					# Stores the $s5 register on the stack.
    	sw $s6, 16($sp)					# Stores the $s6 register on the stack.
    	sw $s7, 20($sp)					# Stores the $s7 register on the stack.
	move $s2, $a2					# Moves the column index to the $s2 register.
	move $s7, $a3					# Moves the player's character to the $s7 register.
	lw $s4, 0($a0)					# Gets the number of rows in the board struct.
	lw $s5, 4($a0)					# Gets the number of columns in the board struct.
	li $s6, 0					# Keeps track of the number of captured pieces.
	blt $a1, $0, returnNegativeOneAsResult		# If the row index is < 0, then jump to the label.
	bge $a1, $s4, returnNegativeOneAsResult		# If the row index is >= to the number of rows, then jump to the label.
	blt $a2, $0, returnNegativeOneAsResult		# If the column index is < 0, then jump to the label.
	bge $a2, $s5, returnNegativeOneAsResult		# If the column index is >= to the number of columns, then jump to the label.
	beq $a3, 'X', opponentPlayerO			# If the player's character is 'X', then jump to the label.
	beq $a3, 'O', opponentPlayerX			# If the player's character is 'O', then jump to the label.
	bne $a3, 'O', returnNegativeOneAsResult		# If the player's character is neither 'X' nor 'O', then jump to the label.
	
	opponentPlayerO:
		li $s0, 'O'				# Stores the opponent player 'O' in the $s0 register.
		j checkIfSlotIsEqualToPlayer		# Jumps to the label.
		
	opponentPlayerX:
		li $s0, 'X'				# Stores the opponent player 'X' in the $s0 register & jumps to the next label.

 	checkIfSlotIsEqualToPlayer:
 		addi $sp, $sp, -4			# Allocates space in the stack to store the $ra register.
 		sw $ra, 0($sp)				# Stores the $ra register in the stack.
 		jal get_slot				# Calls the get_slot function.
 		lw $ra, 0($sp)				# Restores the value of the $ra register from the stack.
 		addi $sp, $sp, 4			# Deallocates space from the stack.
 		move $t0, $v0				# Moves the result of the get_slot function to the $t0 register.
 		bne $t0, $a3, returnNegativeOneAsResult	# If the character returned is not equal to the player, then jump to the label.
 		beq $t0, $a3, horizontalLeftCheck	# If the character returned is equal to the player, then jump to the label.
 		
 	horizontalLeftCheck:
 		addi $sp, $sp, -4			# Allocates space in the stack to store the $ra register.
 		sw $ra, 0($sp)				# Stores the $ra register in the stack.
 		addi $a2, $a2, -1			# Subtracts the column index by 1.
 		jal get_slot				# Calls the get_slot function.
 		lw $ra, 0($sp)				# Restores the value of the $ra register from the stack.
 		addi $sp, $sp, 4			# Deallocates space from the stack.
 		move $t0, $v0				# Moves the result of the get_slot function to the $t0 register.	
 		bne $t0, $s0, horizontalRightCheck	# If the character returned is not equal to the opponent, then jump to label.
 		addi $a2, $a2, -1			# Subtracts the column index by 1.
 		addi $sp, $sp, -4			# Allocates space in the stack to store the $ra register.
 		sw $ra, 0($sp)				# Stores the $ra register in the stack.
 		jal get_slot				# Calls the get_slot function.
 		lw $ra, 0($sp)				# Restores the value of the $ra register from the stack.
 		addi $sp, $sp, 4			# Deallocates space from the stack.
 		move $t0, $v0				# Moves the result of the get_slot function to the $t0 register.
 		bne $t0, $s0, horizontalRightCheck	# If the character returned is not equal to the opponent, then jump to label.
 		addi $a2, $a2, -1			# Subtracts the column index by 1.
 		addi $sp, $sp, -4			# Allocates space in the stack to store the $ra register.
 		sw $ra, 0($sp)				# Stores the $ra register in the stack.
 		jal get_slot				# Calls the get_slot function.
 		lw $ra, 0($sp)				# Restores the value of the $ra register from the stack.
 		addi $sp, $sp, 4			# Deallocates space from the stack.
 		move $t0, $v0				# Moves the result of the get_slot function to the $t0 register.	
 		bne $t0, $a3, horizontalRightCheck	# If the character returned is not equal to the player, then jump to the label.
 		move $a2, $s2				# Restores the column index to its original value.
 		addi $a2, $a2, -1			# Subtracts the column index by 1.
 		li $a3, '.'				# Stores '.' in the $a3 register.
 		addi $sp, $sp, -4			# Allocates space in the stack to store the $ra register.
 		sw $ra, 0($sp)				# Stores the $ra register in the stack.
 		jal set_slot				# Calls the set_slot function.
 		lw $ra, 0($sp)				# Restores the value of the $ra register from the stack.
 		addi $sp, $sp, 4			# Deallocates space from the stack.
 		addi $a2, $a2, -1			# Subtracts the column index by 1.
 		addi $sp, $sp, -4			# Allocates space in the stack to store the $ra register.
 		sw $ra, 0($sp)				# Stores the $ra register in the stack.
 		jal set_slot				# Calls the set_slot function.
 		move $a3, $s7				# Restores the player's character to its original value.
 		lw $ra, 0($sp)				# Restores the value of the $ra register from the stack.
 		addi $sp, $sp, 4			# Deallocates space from the stack.
 		addi $s6, $s6, 2			# Adds the result by 2.
 		
 	horizontalRightCheck:
 		move $a2, $s2				# Restores the column index to its original value.
 		addi $sp, $sp, -4			# Allocates space in the stack to store the $ra register.
 		sw $ra, 0($sp)				# Stores the $ra register in the stack.
 		addi $a2, $a2, 1			# Adds the column index by 1.
 		jal get_slot				# Calls the get_slot function.
 		lw $ra, 0($sp)				# Restores the value of the $ra register from the stack.
 		addi $sp, $sp, 4			# Deallocates space from the stack.
 		move $t0, $v0				# Moves the result of the get_slot function to the $t0 register.	
 		bne $t0, $s0, returnHorizontalCaptures	# If the character returned is not equal to the opponent, then jump to label.
 		addi $a2, $a2, 1			# Adds the column index by 1.
 		addi $sp, $sp, -4			# Allocates space in the stack to store the $ra register.
 		sw $ra, 0($sp)				# Stores the $ra register in the stack.
 		jal get_slot				# Calls the get_slot function.
 		lw $ra, 0($sp)				# Restores the value of the $ra register from the stack.
 		addi $sp, $sp, 4			# Deallocates space from the stack.
 		move $t0, $v0				# Moves the result of the get_slot function to the $t0 register.
 		bne $t0, $s0, returnHorizontalCaptures	# If the character returned is not equal to the opponent, then jump to label.
 		addi $a2, $a2, 1			# Adds the column index by 1.
 		addi $sp, $sp, -4			# Allocates space in the stack to store the $ra register.
 		sw $ra, 0($sp)				# Stores the $ra register in the stack.
 		jal get_slot				# Calls the get_slot function.
 		lw $ra, 0($sp)				# Restores the value of the $ra register from the stack.
 		addi $sp, $sp, 4			# Deallocates space from the stack.
 		move $t0, $v0				# Moves the result of the get_slot function to the $t0 register.	
 		bne $t0, $a3, returnHorizontalCaptures	# If the character returned is not equal to the player, then jump to the label.
 		move $a2, $s2				# Restores the column index to its original value.
 		addi $a2, $a2, 1			# Adds the column index by 1.
 		li $a3, '.'				# Stores '.' in the $a3 register.
 		addi $sp, $sp, -4			# Allocates space in the stack to store the $ra register.
 		sw $ra, 0($sp)				# Stores the $ra register in the stack.
 		jal set_slot				# Calls the set_slot function.
 		lw $ra, 0($sp)				# Restores the value of the $ra register from the stack.
 		addi $sp, $sp, 4			# Deallocates space from the stack.
 		addi $a2, $a2, 1			# Adds the column index by 1.
 		addi $sp, $sp, -4			# Allocates space in the stack to store the $ra register.
 		sw $ra, 0($sp)				# Stores the $ra register in the stack.
 		jal set_slot				# Calls the set_slot function.
 		move $a2, $s2				# Restores the column index to its original value.
 		move $a3, $s7				# Restores the player's character to its original value.
 		lw $ra, 0($sp)				# Restores the value of the $ra register from the stack.
 		addi $sp, $sp, 4			# Deallocates space from the stack.
 		addi $s6, $s6, 2			# Adds the result by 2.
 		j returnHorizontalCaptures		# Returns the result.
 			
 	returnNegativeOneAsResult:
 		li $s6, -1				# Stores -1 in the $s6 register.
 		
 	returnHorizontalCaptures:
 		move $v0, $s6				# Moves the result to the $v0 register.
 		move $a2, $s2				# Restores the column index to its original value.
 		move $a3, $s7				# Restores the player's character to its original value.
 		lw $s0, 0($sp)				# Loads the $s0 register from the stack.
    		lw $s2, 4($sp)				# Loads the $s2 register from the stack.
    		lw $s4, 8($sp)				# Loads the $s4 register from the stack.
    		lw $s5, 12($sp)				# Loads the $s5 register from the stack.
    		lw $s6, 16($sp)				# Loads the $s6 register from the stack.
    		lw $s7, 20($sp)				# Loads the $s7 register from the stack.
    		addi $sp, $sp, 24			# Deallocates space from the stack.
 		jr $ra					# Returns the result back to the caller.
 	
 		 
check_vertical_capture:
	
	addi $sp, $sp, -24				# Allocates space in the stack to store the $s registers.
    	sw $s0, 0($sp)					# Stores the $s0 register on the stack.
    	sw $s2, 4($sp)					# Stores the $s2 register on the stack.
    	sw $s4, 8($sp)					# Stores the $s4 register on the stack.
    	sw $s5, 12($sp)					# Stores the $s5 register on the stack.
    	sw $s6, 16($sp)					# Stores the $s6 register on the stack.
    	sw $s7, 20($sp)					# Stores the $s7 register on the stack.
    	move $s2, $a1					# Moves the row index to the $s2 register.
	move $s7, $a3					# Moves the player's character to the $s7 register.
	lw $s4, 0($a0)					# Gets the number of rows in the board struct.
	lw $s5, 4($a0)					# Gets the number of columns in the board struct.
	li $s6, 0					# Keeps track of the number of captured pieces.
	blt $a1, $0, returnNegativeOneCaptures		# If the row index is < 0, then jump to the label.
	bge $a1, $s4, returnNegativeOneCaptures		# If the row index is >= to the number of rows, then jump to the label.
	blt $a2, $0, returnNegativeOneCaptures		# If the column index is < 0, then jump to the label.
	bge $a2, $s5, returnNegativeOneCaptures		# If the column index is >= to the number of columns, then jump to the label.
	beq $a3, 'X', opponentO				# If the player's character is 'X', then jump to the label.
	beq $a3, 'O', opponentX				# If the player's character is 'O', then jump to the label.
	bne $a3, 'O', returnNegativeOneCaptures		# If the player's character is neither 'X' nor 'O', then jump to the label.
	
	opponentO:
		li $s0, 'O'				# Stores the opponent player 'O' in the $s0 register.
		j checkIfSlotIsPlayerChar		# Jumps to the label.
		
	opponentX:
		li $s0, 'X'				# Stores the opponent player 'X' in the $s0 register & jumps to the next label.

 	checkIfSlotIsPlayerChar:
 		addi $sp, $sp, -4			# Allocates space in the stack to store the $ra register.
 		sw $ra, 0($sp)				# Stores the $ra register in the stack.
 		jal get_slot				# Call the get_slot function.
 		lw $ra, 0($sp)				# Restores the value of the $ra register from the stack.
 		addi $sp, $sp, 4			# Deallocates space from the stack.
 		move $t0, $v0				# Moves the result of the get_slot function to the $t0 register.
 		bne $t0, $a3, returnNegativeOneCaptures # If the character returned is not equal to the player, then jump to the label.
 		beq $t0, $a3, verticalUpCheck		# If the character returned is equal to the player, then jump to the label.
 		
 	verticalUpCheck:
 		addi $sp, $sp, -4			# Allocates space in the stack to store the $ra register.
 		sw $ra, 0($sp)				# Stores the $ra register in the stack.
 		addi $a1, $a1, -1			# Subtracts the row index by 1.
 		jal get_slot				# Calls the get_slot function.
 		lw $ra, 0($sp)				# Restores the value of the $ra register from the stack.
 		addi $sp, $sp, 4			# Deallocates space from the stack.
 		move $t0, $v0				# Moves the result of the get_slot function to the $t0 register.	
 		bne $t0, $s0, verticalDownCheck		# If the character returned is not equal to the opponent, then jump to label.
 		addi $a1, $a1, -1			# Subtracts the row index by 1.
 		addi $sp, $sp, -4			# Allocates space in the stack to store the $ra register.
 		sw $ra, 0($sp)				# Stores the $ra register in the stack.
 		jal get_slot				# Calls the get_slot function.
 		lw $ra, 0($sp)				# Restores the value of the $ra register from the stack.
 		addi $sp, $sp, 4			# Deallocates space from the stack.
 		move $t0, $v0				# Moves the result of the get_slot function to the $t0 register.
 		bne $t0, $s0, verticalDownCheck		# If the character returned is not equal to the opponent, then jump to label.
 		addi $a1, $a1, -1			# Subtracts the row index by 1.
 		addi $sp, $sp, -4			# Allocates space in the stack to store the $ra register.
 		sw $ra, 0($sp)				# Stores the $ra register in the stack.
 		jal get_slot				# Calls the get_slot function.
 		lw $ra, 0($sp)				# Restores the value of the $ra register from the stack.
 		addi $sp, $sp, 4			# Deallocates space from the stack.
 		move $t0, $v0				# Moves the result of the get_slot function to the $t0 register.	
 		bne $t0, $a3, verticalDownCheck		# If the character returned is not equal to the player, then jump to the label.
 		move $a1, $s2				# Restores the row index to its original value.
 		addi $a1, $a1, -1			# Subtracts the row index by 1.
 		li $a3, '.'				# Stores '.' in the $a3 register.
 		addi $sp, $sp, -4			# Allocates space in the stack to store the $ra register.
 		sw $ra, 0($sp)				# Stores the $ra register in the stack.
 		jal set_slot				# Calls the set_slot function.
 		lw $ra, 0($sp)				# Restores the value of the $ra register from the stack.
 		addi $sp, $sp, 4			# Deallocates space from the stack.
 		addi $a1, $a1, -1			# Subtracts the row index by 1.
 		addi $sp, $sp, -4			# Allocates space in the stack to store the $ra register.
 		sw $ra, 0($sp)				# Stores the $ra register in the stack.
 		jal set_slot				# Calls the set_slot function.
 		move $a3, $s7				# Restores the player's character to its original value.
 		lw $ra, 0($sp)				# Restores the value of the $ra register from the stack.
 		addi $sp, $sp, 4			# Deallocates space from the stack.
 		addi $s6, $s6, 2			# Adds the result by 2.
 		
 	verticalDownCheck:
 		move $a1, $s2				# Restores the row index to its original value.
 		addi $sp, $sp, -4			# Allocates space in the stack to store the $ra register.
 		sw $ra, 0($sp)				# Stores the $ra register in the stack.
 		addi $a1, $a1, 1			# Adds the row index by 1.
 		jal get_slot				# Calls the get_slot function.
 		lw $ra, 0($sp)				# Restores the value of the $ra register from the stack.
 		addi $sp, $sp, 4			# Deallocates space from the stack.
 		move $t0, $v0				# Moves the result of the get_slot function to the $t0 register.	
 		bne $t0, $s0, returnVerticalCaptures	# If the character returned is not equal to the opponent, then jump to label.
 		addi $a1, $a1, 1			# Adds the row index by 1.
 		addi $sp, $sp, -4			# Allocates space in the stack to store the $ra register.
 		sw $ra, 0($sp)				# Stores the $ra register in the stack.
 		jal get_slot				# Calls the get_slot function.
 		lw $ra, 0($sp)				# Restores the value of the $ra register from the stack.
 		addi $sp, $sp, 4			# Deallocates space from the stack.
 		move $t0, $v0				# Moves the result of the get_slot function to the $t0 register.
 		bne $t0, $s0, returnVerticalCaptures	# If the character returned is not equal to the opponent, then jump to label.
 		addi $a1, $a1, 1			# Adds the row index by 1.
 		addi $sp, $sp, -4			# Allocates space in the stack to store the $ra register.
 		sw $ra, 0($sp)				# Stores the $ra register in the stack.
 		jal get_slot				# Calls the get_slot function.
 		lw $ra, 0($sp)				# Restores the value of the $ra register from the stack.
 		addi $sp, $sp, 4			# Deallocates space from the stack.
 		move $t0, $v0				# Moves the result of the get_slot function to the $t0 register.	
 		bne $t0, $a3, returnVerticalCaptures	# If the character returned is not equal to the player, then jump to the label.
 		move $a1, $s2				# Restores the row index to its original value.
 		addi $a1, $a1, 1			# Adds the row index by 1.
 		li $a3, '.'				# Stores '.' in the $a3 register.
 		addi $sp, $sp, -4			# Allocates space in the stack to store the $ra register.
 		sw $ra, 0($sp)				# Stores the $ra register in the stack.
 		jal set_slot				# Calls the set_slot function.
 		lw $ra, 0($sp)				# Restores the value of the $ra register from the stack.
 		addi $sp, $sp, 4			# Deallocates space from the stack.
 		addi $a1, $a1, 1			# Adds the row index by 1.
 		addi $sp, $sp, -4			# Allocates space in the stack to store the $ra register.
 		sw $ra, 0($sp)				# Stores the $ra register in the stack.
 		jal set_slot				# Calls the set_slot function.
 		move $a1, $s2				# Restores the row index to its original value.
 		move $a3, $s7				# Restores the player's character to its original value.
 		lw $ra, 0($sp)				# Restores the value of the $ra register from the stack.
 		addi $sp, $sp, 4			# Deallocates space from the stack.
 		addi $s6, $s6, 2			# Adds the result by 2.
 		j returnVerticalCaptures		# Returns the result.
 			
 	returnNegativeOneCaptures:
 		li $s6, -1				# Stores -1 in the $s6 register.
 		
 	returnVerticalCaptures:
 		move $v0, $s6				# Moves the result to the $v0 register.
 		move $a1, $s2				# Restores the row index to its original value.
 		move $a3, $s7				# Restores the player's character to its original value.
 		lw $s0, 0($sp)				# Loads the $s0 register from the stack.
    		lw $s2, 4($sp)				# Loads the $s2 register from the stack.
    		lw $s4, 8($sp)				# Loads the $s4 register from the stack.
    		lw $s5, 12($sp)				# Loads the $s5 register from the stack.
    		lw $s6, 16($sp)				# Loads the $s6 register from the stack.
    		lw $s7, 20($sp)				# Loads the $s7 register from the stack.
    		addi $sp, $sp, 24			# Deallocates space from the stack.
 		jr $ra					# Returns the result back to the caller.


check_diagonal_capture:

	addi $sp, $sp, -28				# Allocates space in the stack to store the $s registers.
    	sw $s0, 0($sp)					# Stores the $s0 register on the stack.
    	sw $s1, 4($sp)					# Stores the $s1 register on the stack.
    	sw $s2, 8($sp)					# Stores the $s2 register on the stack.
    	sw $s4, 12($sp)					# Stores the $s4 register on the stack.
    	sw $s5, 16($sp)					# Stores the $s5 register on the stack.
    	sw $s6, 20($sp)					# Stores the $s6 register on the stack.
    	sw $s7, 24($sp)					# Stores the $s7 register on the stack.
    	move $s0, $a1					# Moves the row index to the $s0 register.
    	move $s2, $a2					# Moves the column index to the $s2 register.
    	move $s4, $a3					# Moves the player's character to the $s4 register.
    	lw $s5, 0($a0)					# Gets the number of rows in the board struct.
    	lw $s6, 4($a0)					# Gets the number of columns in the board struct.
    	li $s1, 0					# Keeps track of the number of captured pieces.
    	blt $s0, $0, returnNegativeOneAsValue		# If the row index is < 0, then jump to the label.
    	bge $s0, $s5, returnNegativeOneAsValue		# If the row index is >= the number of rows, then jump to the label.
    	blt $s2, $0, returnNegativeOneAsValue		# If the column index is < 0, then jump to the label.
    	bge $s2, $s6, returnNegativeOneAsValue		# If the column index is >= the number of columns, then jump to the label.
	beq $s4, 'X', getOpponentWhichIsO		# If the player's character is 'X', then jump to the label.
	beq $s4, 'O', getOpponentWhichIsX		# If the player's character is 'O', then jump to the label.
	bne $s4, 'O', returnNegativeOneAsValue		# If the player's character is neither 'X' nor 'O', then jump to the label.
	
	getOpponentWhichIsO:
		li $s7, 'O'				# Stores the character 'O' in the $s7 register.
		j checkIfValidPlayer			# Jumps to the label.
		
	getOpponentWhichIsX:
		li $s7, 'X'				# Stores the character 'X' in the $s7 register and jumps to the following label.
	
	checkIfValidPlayer:
		addi $sp, $sp, -4			# Allocates space in the stack to store the $ra register.
		sw $ra, 0($sp)				# Stores the $ra register in the stack.
		jal get_slot				# Calls the get_slot function.
		move $t0, $v0				# Moves the returned result to the $t0 register.
		lw $ra, 0($sp)				# Restores the value of the $ra register.
		addi $sp, $sp, 4			# Deallocates space from the stack.	
		bne $t0, $s4, returnNegativeOneAsValue	# If the player's character != to the returned value, then jump to the label.	
		
	checkNorthEastDiagonal:
		addi $a1, $a1, -1			# Subtracts one from the row index.
		addi $a2, $a2, 1			# Adds one to the column index.
		addi $sp, $sp, -4			# Allocates space in the stack to store the $ra register.
		sw $ra, 0($sp)				# Stores the $ra register in the stack.
		jal get_slot				# Calls the get_slot function.
		move $t0, $v0				# Moves the returned result to the $t0 register.
		lw $ra, 0($sp)				# Restores the value of the $ra register.
		addi $sp, $sp, 4			# Deallocates space from the stack.	 	
		bne $t0, $s7, checkNorthWestDiagonal	# If the opponent's character != to the returned value, then jump to the label.
		addi $a1, $a1, -1			# Subtracts one from the row index.
		addi $a2, $a2, 1			# Adds one to the column index.
		addi $sp, $sp, -4			# Allocates space in the stack to store the $ra register.
		sw $ra, 0($sp)				# Stores the $ra register in the stack.
		jal get_slot				# Calls the get_slot function.
		move $t0, $v0				# Moves the returned result to the $t0 register.
		lw $ra, 0($sp)				# Restores the value of the $ra register.
		addi $sp, $sp, 4			# Deallocates space from the stack.	 	
		bne $t0, $s7, checkNorthWestDiagonal	# If the opponent's character != to the returned value, then jump to the label.
		addi $a1, $a1, -1			# Subtracts one from the row index.
		addi $a2, $a2, 1			# Adds one to the column index.
		addi $sp, $sp, -4			# Allocates space in the stack to store the $ra register.
		sw $ra, 0($sp)				# Stores the $ra register in the stack.
		jal get_slot				# Calls the get_slot function.
		move $t0, $v0				# Moves the returned result to the $t0 register.
		lw $ra, 0($sp)				# Restores the value of the $ra register.
		addi $sp, $sp, 4			# Deallocates space from the stack.	 	
		bne $t0, $s4, checkNorthWestDiagonal	# If the player's character != to the returned value, then jump to the label.					
 		move $a1, $s0				# Restores the row index.
 		move $a2, $s2				# Restores the column index.
 		addi $a1, $a1, -1			# Subtracts one from the row index.
		addi $a2, $a2, 1			# Adds one to the column index.
		li $a3, '.'				# Stores the period character in the $a3 register.
		addi $sp, $sp, -4			# Allocates space in the stack to store the $ra register.
		sw $ra, 0($sp)				# Stores the $ra register in the stack.
		jal set_slot				# Calls the set_slot function. 
		addi $a1, $a1, -1			# Subtracts one from the row index.
		addi $a2, $a2, 1			# Adds one to the column index.
		lw $ra, 0($sp)				# Restores the value of the $ra register.
		addi $sp, $sp, 4			# Deallocates space from the stack.	
		addi $sp, $sp, -4			# Allocates space in the stack to store the $ra register.
		sw $ra, 0($sp)				# Stores the $ra register in the stack.
		jal set_slot				# Calls the set_slot function.
		lw $ra, 0($sp)				# Restores the value of the $ra register.
		addi $sp, $sp, 4			# Deallocates space from the stack.	 
		addi $s1, $s1, 2			# Adds 2 to the number of captured pieces.
		
	checkNorthWestDiagonal:
		move $a1, $s0				# Restores the row index.
		move $a2, $s2				# Restores the column index.
		move $a3, $s4				# Restores the player's character.
		addi $a1, $a1, -1			# Subtracts one from the row index.
		addi $a2, $a2, -1			# Subtracts one from the column index.
		addi $sp, $sp, -4			# Allocates space in the stack to store the $ra register.
		sw $ra, 0($sp)				# Stores the $ra register in the stack.
		jal get_slot				# Calls the get_slot function.
		move $t0, $v0				# Moves the returned result to the $t0 register.
		lw $ra, 0($sp)				# Restores the value of the $ra register.
		addi $sp, $sp, 4			# Deallocates space from the stack.	 	
		bne $t0, $s7, checkSouthEastDiagonal	# If the opponent's character != to the returned value, then jump to the label.
		addi $a1, $a1, -1			# Subtracts one from the row index.
		addi $a2, $a2, -1			# Subtracts one from the column index.
		addi $sp, $sp, -4			# Allocates space in the stack to store the $ra register.
		sw $ra, 0($sp)				# Stores the $ra register in the stack.
		jal get_slot				# Calls the get_slot function.
		move $t0, $v0				# Moves the returned result to the $t0 register.
		lw $ra, 0($sp)				# Restores the value of the $ra register.
		addi $sp, $sp, 4			# Deallocates space from the stack.	 	
		bne $t0, $s7, checkSouthEastDiagonal	# If the opponent's character != to the returned value, then jump to the label.
		addi $a1, $a1, -1			# Subtracts one from the row index.
		addi $a2, $a2, -1			# Subtracts one from the column index.
		addi $sp, $sp, -4			# Allocates space in the stack to store the $ra register.
		sw $ra, 0($sp)				# Stores the $ra register in the stack.
		jal get_slot				# Calls the get_slot function.
		move $t0, $v0				# Moves the returned result to the $t0 register.
		lw $ra, 0($sp)				# Restores the value of the $ra register.
		addi $sp, $sp, 4			# Deallocates space from the stack.	 	
		bne $t0, $s4, checkSouthEastDiagonal	# If the player's character != to the returned value, then jump to the label.					
 		move $a1, $s0				# Restores the row index.
 		move $a2, $s2				# Restores the column index.
 		addi $a1, $a1, -1			# Subtracts one from the row index.
		addi $a2, $a2, -1			# Subtracts one from the column index.
		li $a3, '.'				# Stores the period character in the $a3 register.
		addi $sp, $sp, -4			# Allocates space in the stack to store the $ra register.
		sw $ra, 0($sp)				# Stores the $ra register in the stack.
		jal set_slot				# Calls the set_slot function. 
		addi $a1, $a1, -1			# Subtracts one from the row index.
		addi $a2, $a2, -1			# Subtracts one from the column index.
		lw $ra, 0($sp)				# Restores the value of the $ra register.
		addi $sp, $sp, 4			# Deallocates space from the stack.	
		addi $sp, $sp, -4			# Allocates space in the stack to store the $ra register.
		sw $ra, 0($sp)				# Stores the $ra register in the stack.
		jal set_slot				# Calls the set_slot function.
		lw $ra, 0($sp)				# Restores the value of the $ra register.
		addi $sp, $sp, 4			# Deallocates space from the stack.	 
		addi $s1, $s1, 2			# Adds 2 to the number of captured pieces.
		
	checkSouthEastDiagonal:
		move $a1, $s0				# Restores the row index.
		move $a2, $s2				# Restores the column index.
		move $a3, $s4				# Restores the player's character.
		addi $a1, $a1, 1			# Adds one to the row index.
		addi $a2, $a2, 1			# Adds one to the column index.
		addi $sp, $sp, -4			# Allocates space in the stack to store the $ra register.
		sw $ra, 0($sp)				# Stores the $ra register in the stack.
		jal get_slot				# Calls the get_slot function.
		move $t0, $v0				# Moves the returned result to the $t0 register.
		lw $ra, 0($sp)				# Restores the value of the $ra register.
		addi $sp, $sp, 4			# Deallocates space from the stack.	 	
		bne $t0, $s7, checkSouthWestDiagonal	# If the opponent's character != to the returned value, then jump to the label.
		addi $a1, $a1, 1			# Adds one to the row index.
		addi $a2, $a2, 1			# Adds one to the column index.
		addi $sp, $sp, -4			# Allocates space in the stack to store the $ra register.
		sw $ra, 0($sp)				# Stores the $ra register in the stack.
		jal get_slot				# Calls the get_slot function.
		move $t0, $v0				# Moves the returned result to the $t0 register.
		lw $ra, 0($sp)				# Restores the value of the $ra register.
		addi $sp, $sp, 4			# Deallocates space from the stack.	 	
		bne $t0, $s7, checkSouthWestDiagonal	# If the opponent's character != to the returned value, then jump to the label.
		addi $a1, $a1, 1			# Adds one to the row index.
		addi $a2, $a2, 1			# Adds one to the column index.
		addi $sp, $sp, -4			# Allocates space in the stack to store the $ra register.
		sw $ra, 0($sp)				# Stores the $ra register in the stack.
		jal get_slot				# Calls the get_slot function.
		move $t0, $v0				# Moves the returned result to the $t0 register.
		lw $ra, 0($sp)				# Restores the value of the $ra register.
		addi $sp, $sp, 4			# Deallocates space from the stack.	 	
		bne $t0, $s4, checkSouthWestDiagonal	# If the player's character != to the returned value, then jump to the label.					
 		move $a1, $s0				# Restores the row index.
 		move $a2, $s2				# Restores the column index.
 		addi $a1, $a1, 1			# Adds one to the row index.
		addi $a2, $a2, 1			# Adds one to the column index.
		li $a3, '.'				# Stores the period character in the $a3 register.
		addi $sp, $sp, -4			# Allocates space in the stack to store the $ra register.
		sw $ra, 0($sp)				# Stores the $ra register in the stack.
		jal set_slot				# Calls the set_slot function. 
		addi $a1, $a1, 1			# Adds one to the row index.
		addi $a2, $a2, 1			# Adds one to the column index.
		lw $ra, 0($sp)				# Restores the value of the $ra register.
		addi $sp, $sp, 4			# Deallocates space from the stack.	
		addi $sp, $sp, -4			# Allocates space in the stack to store the $ra register.
		sw $ra, 0($sp)				# Stores the $ra register in the stack.
		jal set_slot				# Calls the set_slot function.
		lw $ra, 0($sp)				# Restores the value of the $ra register.
		addi $sp, $sp, 4			# Deallocates space from the stack.	 
		addi $s1, $s1, 2			# Adds 2 to the number of captured pieces.
		
	checkSouthWestDiagonal:
		move $a1, $s0				# Restores the row index.
		move $a2, $s2				# Restores the column index.
		move $a3, $s4				# Restores the player's character.
		addi $a1, $a1, 1			# Adds one to the row index.
		addi $a2, $a2, -1			# Subtracts one from the column index.
		addi $sp, $sp, -4			# Allocates space in the stack to store the $ra register.
		sw $ra, 0($sp)				# Stores the $ra register in the stack.
		jal get_slot				# Calls the get_slot function.
		move $t0, $v0				# Moves the returned result to the $t0 register.
		lw $ra, 0($sp)				# Restores the value of the $ra register.
		addi $sp, $sp, 4			# Deallocates space from the stack.	 	
		bne $t0, $s7, returnDiagonalCapture	# If the opponent's character != to the returned value, then jump to the label.
		addi $a1, $a1, 1			# Adds one to the row index.
		addi $a2, $a2, -1			# Subtracts one from the column index.
		addi $sp, $sp, -4			# Allocates space in the stack to store the $ra register.
		sw $ra, 0($sp)				# Stores the $ra register in the stack.
		jal get_slot				# Calls the get_slot function.
		move $t0, $v0				# Moves the returned result to the $t0 register.
		lw $ra, 0($sp)				# Restores the value of the $ra register.
		addi $sp, $sp, 4			# Deallocates space from the stack.	 	
		bne $t0, $s7, returnDiagonalCapture	# If the opponent's character != to the returned value, then jump to the label.
		addi $a1, $a1, 1			# Adds one to the row index.
		addi $a2, $a2, -1			# Subtracts one from the column index.
		addi $sp, $sp, -4			# Allocates space in the stack to store the $ra register.
		sw $ra, 0($sp)				# Stores the $ra register in the stack.
		jal get_slot				# Calls the get_slot function.
		move $t0, $v0				# Moves the returned result to the $t0 register.
		lw $ra, 0($sp)				# Restores the value of the $ra register.
		addi $sp, $sp, 4			# Deallocates space from the stack.	 	
		bne $t0, $s4, returnDiagonalCapture	# If the player's character != to the returned value, then jump to the label.					
 		move $a1, $s0				# Restores the row index.
 		move $a2, $s2				# Restores the column index.
 		addi $a1, $a1, 1			# Adds one to the row index.
		addi $a2, $a2, -1			# Subtracts one from the column index.
		li $a3, '.'				# Stores the period character in the $a3 register.
		addi $sp, $sp, -4			# Allocates space in the stack to store the $ra register.
		sw $ra, 0($sp)				# Stores the $ra register in the stack.
		jal set_slot				# Calls the set_slot function. 
		addi $a1, $a1, 1			# Adds one to the row index.
		addi $a2, $a2, -1			# Subtracts one from the column index.
		lw $ra, 0($sp)				# Restores the value of the $ra register.
		addi $sp, $sp, 4			# Deallocates space from the stack.	
		addi $sp, $sp, -4			# Allocates space in the stack to store the $ra register.
		sw $ra, 0($sp)				# Stores the $ra register in the stack.
		jal set_slot				# Calls the set_slot function.
		lw $ra, 0($sp)				# Restores the value of the $ra register.
		addi $sp, $sp, 4			# Deallocates space from the stack.	 
		move $a1, $s0				# Restores the row index.
		move $a2, $s2				# Restores the column index.
		move $a3, $s4				# Restores the player's character.
		addi $s1, $s1, 2			# Adds 2 to the number of captured pieces.
		j returnDiagonalCapture			# Jumps to the returnDiagonalCapture label.
		
	 returnNegativeOneAsValue:
	 	li $s1, -1				# Stores -1 in the $s1 register.
	 	
	 returnDiagonalCapture:
	 	move $v0, $s1				# Moves the result to the $v0 register.
	 	move $a1, $s0				# Restores the row index.
		move $a2, $s2				# Restores the column index.
		move $a3, $s4				# Restores the player's character.
	 	lw $s0, 0($sp)				# Loads the $s0 register from the stack.
    		lw $s1, 4($sp)				# Loads the $s1 register from the stack.
    		lw $s2, 8($sp)				# Loads the $s2 register from the stack.
    		lw $s4, 12($sp)				# Loads the $s4 register from the stack.
    		lw $s5, 16($sp)				# Loads the $s5 register from the stack.
    		lw $s6, 20($sp)				# Loads the $s6 register from the stack.
    		lw $s7, 24($sp)				# Loads the $s7 register from the stack.
    		addi $sp, $sp, 28			# Deallocates space from the stack.
	 	jr $ra					# Returns the result back to the caller.	


check_horizontal_winner:
	
	addi $sp, $sp, -32				# Allocates space in the stack to store the $s registers.
   	sw $s0, 0($sp)					# Stores the $s0 register on the stack.
   	sw $s1, 4($sp)					# Stores the $s1 register on the stack.
   	sw $s2, 8($sp)					# Stores the $s2 register on the stack.
   	sw $s3, 12($sp)					# Stores the $s3 register on the stack.
   	sw $s4, 16($sp)					# Stores the $s4 register on the stack.
   	sw $s5, 20($sp)					# Stores the $s5 register on the stack.
   	sw $s6, 24($sp)					# Stores the $s6 register on the stack.
   	sw $s7, 28($sp)					# Stores the $s7 register on the stack.
    	move $s1, $a1					# Moves the player's character to the $s1 register.
    	lw $s2, 0($a0)					# Gets the number of rows in the board struct.
    	lw $s4, 4($a0)					# Gets the number of columns in the board struct.
    	mul $s0, $s2, $s4				# Gets the total number of characters in the board struct.
    	li $s5, 0					# Stores the row index for the win.
    	li $s6, 0					# Stores the column index for the win.
    	li $s7, 0					# Keeps track of the number of characters that are read.
    	li $s3, 0					# Keeps track if 5 player's characters are read.
    	li $t3, 0					# Keeps track of the number of columns read.
    	li $a1, 0					# Stores the initial row index to check for a horizontal win.
    	li $a2, 0					# Stores the initial column index to check for a horizontal win.
    	beq $s1, 'X', checkHorizontal			# If the player's character is 'X', then jump to the label.
    	beq $s1, 'O', checkHorizontal			# If the player's character is 'O', then jump to the label.
    	bne $s1, 'O', returnNegativeOnes		# If the player's character is neither 'X' nor 'O', then jump to the label.
    	
    	checkHorizontal:
    		beq $s7, $s0, returnNegativeOnes	# If the # of chars read = total # of chars in the board struct, jump to label.
    		beq $t3, $s4, resetColumnNumber		# If the columns read is equal to the total number of columns, jump to label.
    		addi $sp, $sp, -4			# Allocates space in the stack to store the $ra register.
    		sw $ra, 0($sp)				# Stores the $ra register in the stack.
    		jal get_slot				# Calls the get_slot function.
    		move $t2, $v0				# Moves the returned result to the $t2 register.
    		lw $ra, 0($sp)				# Restores the value of the $ra register.
		addi $sp, $sp, 4			# Deallocates space from the stack.	
    		addi $s7, $s7, 1			# Adds one to the number of characters read. 
    		addi $a2, $a2, 1			# Adds one to the column index.
    		addi $t3, $t3, 1			# Adds one to the number of columns read.
    		beq $t2, $s1, addOneToCharsRead		# If the character is the player's character, then jump to the label.
    		bne $t2, $s1, resetCount		# If the character is not the player's character, then jump to the label. 
    		
    	resetColumnNumber:
    		li $a2, 0				# Resets the column index to zero.
    		addi $a1, $a1, 1			# Moves on to the next row in the board struct.
    		li $s3, 0				# Resets the value of the count.
    		li $t3, 0				# Resets the number of columns read.
    		j checkHorizontal			# Jumps back to the label/loop.
    	
    	addOneToCharsRead:
    		addi $s3, $s3, 1			# Adds one to the count.
    		bge $s3, 5, setTheReturnValues		# If the count is >= 5, then jump to the label.
    		j checkHorizontal			# Jumps back to the label/loop.
    		
    	resetCount:
    		li $s3, 0				# Resets the count to 0.
    		j checkHorizontal			# Jumps back to the label/loop.
    		
    	setTheReturnValues:
    		move $s5, $a1				# Moves the row index to the $s5 register.
    		addi $a2, $a2, -5			# Subtracts 5 from the column index.
    		move $s6, $a2				# Moves the column index to the $s6 register.
    		j returnValues				# Jumps to the returnValues label.
    	
    	returnNegativeOnes:
    		li $s5, -1				# Stores -1 in the $s5 register.
    		li $s6, -1				# Stores -1 in the $s6 register.
    		
    	returnValues:
    		move $a1, $s1				# Restores the player's character argument.
    		move $v0, $s5				# Moves the row index to the $v0 register.
    		move $v1, $s6				# Moves the column index to the $v1 register.
    		lw $s0, 0($sp)				# Loads the $s0 register from the stack.
    		lw $s1, 4($sp)				# Loads the $s1 register from the stack.
    		lw $s2, 8($sp)				# Loads the $s2 register from the stack.
   		lw $s3, 12($sp)				# Loads the $s3 register from the stack.
    		lw $s4, 16($sp)				# Loads the $s4 register from the stack.
    		lw $s5, 20($sp)				# Loads the $s5 register from the stack.
    		lw $s6, 24($sp)				# Loads the $s6 register from the stack.
    		lw $s7, 28($sp)				# Loads the $s7 register from the stack.
    		addi $sp, $sp, 32			# Deallocates space from the stack.
    		jr $ra					# Return the results back to the caller.


check_vertical_winner:

	addi $sp, $sp, -32				# Allocates space in the stack to store the $s registers.
    	sw $s0, 0($sp)					# Stores the $s0 register on the stack.
    	sw $s1, 4($sp)					# Stores the $s1 register on the stack.
    	sw $s2, 8($sp)					# Stores the $s2 register on the stack.
    	sw $s3, 12($sp)					# Stores the $s3 register on the stack.
    	sw $s4, 16($sp)					# Stores the $s4 register on the stack.
    	sw $s5, 20($sp)					# Stores the $s5 register on the stack.
    	sw $s6, 24($sp)					# Stores the $s6 register on the stack.
   	sw $s7, 28($sp)					# Stores the $s7 register on the stack.
    	move $s1, $a1					# Moves the player's character to the $s1 register.
    	lw $s2, 0($a0)					# Gets the number of rows in the board struct.
    	lw $s4, 4($a0)					# Gets the number of columns in the board struct.
    	mul $s0, $s2, $s4				# Gets the total number of characters in the board struct.
    	li $s5, 0					# Stores the row index for the win.
    	li $s6, 0					# Stores the column index for the win.
    	li $s7, 0					# Keeps track of the number of characters that are read.
    	li $s3, 0					# Keeps track if 5 player's characters are read.
    	li $t3, 0					# Keeps track of the number of rows read.
    	li $a1, 0					# Stores the initial row index to check for a vertical win.
    	li $a2, 0					# Stores the initial column index to check for a vertical win.
    	beq $s1, 'X', checkVertical			# If the player's character is 'X', then jump to the label.
    	beq $s1, 'O', checkVertical			# If the player's character is 'O', then jump to the label.
    	bne $s1, 'O', returnNegativeOneResult		# If the player's character is neither 'X' nor 'O', then jump to the label.
    	
    	checkVertical:
    		beq $s7, $s0, returnNegativeOneResult	# If the # of chars read = total # of chars in the board struct, jump to label.
    		beq $t3, $s2, resetRowNum		# If the rows read is equal to the total number of rows, jump to label.
    		addi $sp, $sp, -4			# Allocates space in the stack to store the $ra register.
    		sw $ra, 0($sp)				# Stores the $ra register in the stack.
    		jal get_slot				# Calls the get_slot function.
    		move $t2, $v0				# Moves the returned result to the $t2 register.
    		lw $ra, 0($sp)				# Restores the value of the $ra register.
		addi $sp, $sp, 4			# Deallocates space from the stack.	
    		addi $s7, $s7, 1			# Adds one to the number of characters read. 
    		addi $a1, $a1, 1			# Adds one to the row index.
    		addi $t3, $t3, 1			# Adds one to the number of rows read.
    		beq $t2, $s1, addOneToReadChars		# If the character is the player's character, then jump to the label.
    		bne $t2, $s1, resetRegister		# If the character is not the player's character, then jump to the label. 
    		
    	resetRowNum:
    		li $a1, 0				# Resets the row index to zero.
    		addi $a2, $a2, 1			# Moves on to the next column in the board struct.
    		li $s3, 0				# Resets the value of the count.
    		li $t3, 0				# Resets the number of rows read.
    		j checkVertical				# Jumps back to the label/loop.
    	
    	addOneToReadChars:
    		addi $s3, $s3, 1			# Adds one to the count.
    		bge $s3, 5, setTheResults		# If the count is >= 5, then jump to the label.
    		j checkVertical				# Jumps back to the label/loop.
    		
    	resetRegister:
    		li $s3, 0				# Resets the count to 0.
    		j checkVertical				# Jumps back to the label/loop.
    		
    	setTheResults:
    		move $s6, $a2				# Moves the column index to the $s6 register.
    		addi $a1, $a1, -5			# Subtracts 5 from the row index.
    		move $s5, $a1				# Moves the row index to the $s5 register.
    		j returnIndices				# Jumps to the returnIndices label.
    	
    	returnNegativeOneResult:
    		li $s5, -1				# Stores -1 in the $s5 register.
    		li $s6, -1				# Stores -1 in the $s6 register.
    		
    	returnIndices:
    		move $a1, $s1				# Restores the player's character argument.
    		move $v0, $s5				# Moves the row index to the $v0 register.
    		move $v1, $s6				# Moves the column index to the $v1 register.
    		lw $s0, 0($sp)				# Loads the $s0 register from the stack.
    		lw $s1, 4($sp)				# Loads the $s1 register from the stack.
    		lw $s2, 8($sp)				# Loads the $s2 register from the stack.
   		lw $s3, 12($sp)				# Loads the $s3 register from the stack.
    		lw $s4, 16($sp)				# Loads the $s4 register from the stack.
    		lw $s5, 20($sp)				# Loads the $s5 register from the stack.
    		lw $s6, 24($sp)				# Loads the $s6 register from the stack.
    		lw $s7, 28($sp)				# Loads the $s7 register from the stack.
    		addi $sp, $sp, 32			# Deallocates space from the stack.
    		jr $ra					# Return the results back to the caller.
    		

check_sw_ne_diagonal_winner:
	
	addi $sp, $sp, -32				# Allocates space in the stack to store the $s register.
    	sw $s0, 0($sp)					# Stores the $s0 register on the stack.
    	sw $s1, 4($sp)					# Stores the $s1 register on the stack.
    	sw $s2, 8($sp)					# Stores the $s2 register on the stack.
    	sw $s3, 12($sp)					# Stores the $s3 register on the stack.
    	sw $s4, 16($sp)					# Stores the $s4 register on the stack.
    	sw $s5, 20($sp)					# Stores the $s5 register on the stack.
    	sw $s6, 24($sp)					# Stores the $s6 register on the stack.
    	sw $s7, 28($sp)					# Stores the $s7 register on the stack.
    	move $s1, $a1					# Moves the player's character to the $s1 register.
    	lw $s6, 0($a0)					# Gets the total number of rows in the board struct.
    	lw $s7, 4($a0)					# Gets the total number of columns in the board struct.
    	mul $s0, $s6, $s7				# Stores the total number of characters in the board struct.
    	addi $s6, $s6, -1				# Gets the last row index in the board struct.
    	addi $s7, $s7, -1				# Gets the last column index in the board struct.
    	li $s2, 0					# Saves the starting row index.
    	li $s3, 0					# Saves the starting column index.
    	li $s4, 0					# Keeps track if 5 player's characters have been read.
    	li $s5, 0					# Keeps track of the total number of characters traversed.
    	li $a1, 0					# Stores the 0 row index in the $a1 register.
    	li $a2, 0					# Stores the 0 column index in the $a2 register.
    	beq $s1, 'X', checkFromSouthWest		# If the player's character is 'X', then jump to the label.
    	beq $s1, 'O', checkFromSouthWest		# If the player's character is 'O', then jump to the label.
    	bne $s1, 'O', getNegativeOneAsValues		# If the player's character is neither 'X' nor 'O', then jump to the label.
    	
    	checkFromSouthWest:
    		beq $s5, $s0, getNegativeOneAsValues	# If all of the characters have been read, then jump to the label.
    		addi $sp, $sp, -4			# Allocates space in the stack to store the $ra register.
    		sw $ra, 0($sp)				# Stores the $ra register in the stack.
    		jal get_slot				# Calls the get_slot function.
    		lw $ra, 0($sp)				# Restores the value of the $ra register.
    		addi $sp, $sp, 4			# Deallocates space from the stack.
    		move $t7, $v0				# Moves the result of the get_slot function to the $t7 register.
    		addi $s5, $s5, 1			# Adds one to the total number of characters read.
    		beq $t7, $s1, addOneToNumOfCharsRead	# If the result = the player's character, then jump to the label.
    		bne $t7, $s1, setRowAndColumnIndices	# If the result != the player's character, then jump to the label.
    		
    	addOneToNumOfCharsRead:
    		addi $s4, $s4, 1			# Adds one to the count.
    		bge $s4, 5, setTheReturnIndices		# If the count >= 5, then jump to the label.
    		addi $a1, $a1, -1			# Subtracts 1 from the row index.
    		addi $a2, $a2, 1			# Adds 1 to the column index.
    		blt $a1, $0, resetRowAndColumn		# If the row index < 0, then jump to the label.
    		bgt $a2, $s7, resetRowAndColumn		# If the column index > columns - 1, then jump to the label.
    		j checkFromSouthWest			# Otherwise, jumps back to the label/loop.
    		
    	setRowAndColumnIndices:
    		li $s4, 0				# Resets the count to 0.
    		addi $a1, $a1, -1			# Subtracts 1 from the row index.
    		addi $a2, $a2, 1			# Adds 1 to the column index.
    		blt $a1, $0, resetRowAndColumn		# If the row index < 0, then jump to the label.
    		bgt $a2, $s7, resetRowAndColumn		# If the column index > columns - 1, then jump to the label.
    		j checkFromSouthWest			# Otherwise, jumps back to the label/loop.
    		
    	resetRowAndColumn:
    		li $s4, 0				# Resets the count to 0.
    		beq $s2, $s6, addToTheColumnIndex	# If the row index reaches the last index, then jump to the label.
    		addi $s2, $s2, 1			# Adds one to the row index.
    		move $a1, $s2				# Moves the row index to the proper argument.
    		move $a2, $s3				# Moves the column index to the proper argument.
    		j checkFromSouthWest			# Jumps back to the label/loop.
    		
    	addToTheColumnIndex: 
    		addi $s3, $s3, 1			# Adds one to the column index.
    		move $a1, $s2				# Moves the row index to the proper argument.
    		move $a2, $s3				# Moves the column index to the proper argument.
    		j checkFromSouthWest			# Jumps back to the label/loop.
    		
    	setTheReturnIndices:
    		addi $a1, $a1, 4			# Adds 4 to the row index to get the proper result.
    		addi $a2, $a2, -4			# Subtracts 4 from the column index to get the proper result.
    		move $s2, $a1				# Moves the row index to the $s2 register.
    		move $s3, $a2				# Moves the column index to the $s3 register.
    		j returnSouthWestWinner			# Jumps to the label in order to return the results.
    	
    	getNegativeOneAsValues:
    		li $s2, -1				# Stores -1 in the $s2 register.
    		li $s3, -1 				# Stores -1 in the $s3 register.
    		
    	returnSouthWestWinner:
    		move $a1, $s1				# Restores the player's character argument.
    		move $v0, $s2				# Stores the resulting row index in the $v0 register.
    		move $v1, $s3				# Stores the resulting column index in the $v1 register.
    		lw $s0, 0($sp)				# Loads the $s0 register from the stack.
    		lw $s1, 4($sp)				# Loads the $s1 register from the stack.
    		lw $s2, 8($sp)				# Loads the $s2 register from the stack.
   		lw $s3, 12($sp)				# Loads the $s3 register from the stack.
    		lw $s4, 16($sp)				# Loads the $s4 register from the stack.
    		lw $s5, 20($sp)				# Loads the $s5 register from the stack.
    		lw $s6, 24($sp)				# Loads the $s6 register from the stack.
    		lw $s7, 28($sp)				# Loads the $s7 register from the stack.
    		addi $sp, $sp, 32			# Deallocates space from the stack.
    		jr $ra					# Return the results back to the caller.
    	

check_nw_se_diagonal_winner:
    	
    	addi $sp, $sp, -32				# Allocates space in the stack to store the $s registers.
    	sw $s0, 0($sp)					# Stores the $s0 register on the stack.
    	sw $s1, 4($sp)					# Stores the $s1 register on the stack.
    	sw $s2, 8($sp)					# Stores the $s2 register on the stack.
    	sw $s3, 12($sp)					# Stores the $s3 register on the stack.
    	sw $s4, 16($sp)					# Stores the $s4 register on the stack.
    	sw $s5, 20($sp)					# Stores the $s5 register on the stack.
    	sw $s6, 24($sp)					# Stores the $s6 register on the stack.
    	sw $s7, 28($sp)					# Stores the $s7 register on the stack.
    	move $s1, $a1					# Moves the player's character to the $s1 register.
    	lw $s6, 0($a0)					# Gets the total number of rows in the board struct.
    	lw $s7, 4($a0)					# Gets the total number of columns in the board struct.
    	mul $s0, $s6, $s7				# Stores the total number of characters in the board struct.
    	addi $s6, $s6, -1				# Gets the last row index in the board struct.
    	addi $s7, $s7, -1				# Gets the last column index in the board struct.
    	move $s2, $s6					# Saves the starting row index.
    	li $s3, 0					# Saves the starting column index.
    	li $s4, 0					# Keeps track if 5 player's characters have been read.
    	li $s5, 0					# Keeps track of the total number of characters traversed.
    	move $a1, $s6					# Stores the last row index in the $a1 register.
    	li $a2, 0					# Stores the 0 column index in the $a2 register.
    	beq $s1, 'X', checkFromNorthWest		# If the player's character is 'X', then jump to the label.
    	beq $s1, 'O', checkFromNorthWest		# If the player's character is 'O', then jump to the label.
    	bne $s1, 'O', getNegativeOneAsReturnValues	# If the player's character is neither 'X' nor 'O', then jump to the label.
    	
    	checkFromNorthWest:
    		beq $s5, $s0, getNegativeOneAsValues	# If all of the characters have been read, then jump to the label.
    		addi $sp, $sp, -4			# Allocates space in the stack to store the $ra register.
    		sw $ra, 0($sp)				# Stores the $ra register in the stack.
    		jal get_slot				# Calls the get_slot function.
    		lw $ra, 0($sp)				# Restores the value of the $ra register.
    		addi $sp, $sp, 4			# Deallocates space from the stack.
    		move $t7, $v0				# Moves the result of the get_slot function to the $t7 register.
    		addi $s5, $s5, 1			# Adds one to the total number of characters read.
    		beq $t7, $s1, addOneToPlayerCharsRead	# If the returned result = player's character, then jump to the label.
    		bne $t7, $s1, setTheIndices		# If the returned result != player's character, then jump to the label.
    		
    	addOneToPlayerCharsRead:
    		addi $s4, $s4, 1			# Adds one to the count.
    		bge $s4, 5, setTheReturnValuesOfIndices	# If the count >= 5, then jump to the label.
    		addi $a1, $a1, 1			# Adds one to the row index.
    		addi $a2, $a2, 1			# Adds one to the column index.
    		bgt $a1, $s6, resetToTheProperIndices	# If the row index is > the last row index, then jump to the label.
    		bgt $a2, $s7, resetToTheProperIndices	# If the column index is > the last column index, then jump to the label.
    		j checkFromNorthWest			# Otherwise, jumps back to the label/loop.
    		
    	setTheIndices:
    		li $s4, 0				# Resets the count to 0.
    		addi $a1, $a1, 1			# Adds one to the row index.
    		addi $a2, $a2, 1			# Adds one to the column index.
    		bgt $a1, $s6, resetToTheProperIndices	# If the row index is > the last row index, then jump to the label.
    		bgt $a2, $s7, resetToTheProperIndices	# If the column index is > the last column index, then jump to the label.
    		j checkFromNorthWest			# Otherwise, jumps back to the label/loop.
    		
    	resetToTheProperIndices:
    		li $s4, 0				# Resets the count to 0.
    		beq $s2, $0, setTheColumnIndex		# If the row index reaches 0, then jump to the label.
    		addi $s2, $s2, -1			# Subtracts the row index by 1.
    		move $a1, $s2				# Moves the row index to the proper argument.
    		move $a2, $s3				# Moves the column index to the proper argument.
    		j checkFromNorthWest			# Jumps back to the label/loop.
    		
    	setTheColumnIndex:
    		addi $s3, $s3, 1			# Adds one to the column index.
    		move $a1, $s2				# Moves the row index to the proper argument.
    		move $a2, $s3				# Moves the column index to the proper argument.
    		j checkFromNorthWest			# Jumps back to the label/loop.	
    		
    	setTheReturnValuesOfIndices:
    		addi $a1, $a1, -4			# Subtracts 4 from the row index to get the proper result.
    		addi $a2, $a2, -4			# Subtracts 4 from the column index to get the proper result.
    		move $s2, $a1				# Moves the row index to the $s2 register.
    		move $s3, $a2				# Moves the column index to the $s3 register.
    		j returnNorthWestWinner			# Jumps to the label in order to return the results.

    	getNegativeOneAsReturnValues:
    		li $s2, -1				# Stores -1 in the $s2 register.
    		li $s3, -1 				# Stores -1 in the $s3 register.
    		
    	returnNorthWestWinner:
    		move $a1, $s1				# Restores the player's character argument.
    		move $v0, $s2				# Stores the resulting row index in the $v0 register.
    		move $v1, $s3				# Stores the resulting column index in the $v1 register.
    		lw $s0, 0($sp)				# Loads the $s0 register from the stack.
    		lw $s1, 4($sp)				# Loads the $s1 register from the stack.
    		lw $s2, 8($sp)				# Loads the $s2 register from the stack.
   		lw $s3, 12($sp)				# Loads the $s3 register from the stack.
    		lw $s4, 16($sp)				# Loads the $s4 register from the stack.
    		lw $s5, 20($sp)				# Loads the $s5 register from the stack.
    		lw $s6, 24($sp)				# Loads the $s6 register from the stack.
    		lw $s7, 28($sp)				# Loads the $s7 register from the stack.
    		addi $sp, $sp, 32			# Deallocates space from the stack.
    		jr $ra					# Return the results back to the caller.

simulate_game:

    	move $s1, $a1					# Moves the filename to the $s1 register.
    	move $s2, $a2					# Moves the series of turns in the game to the $s2 register.
    	move $t9, $a2					# Stores a copy of the series of turns in the game in the $t9 register.
    	move $s3, $a3					# Moves the maximum number of turns to simulate to the $s3 register.
    	li $s4, 0					# Stores the first return value.
    	li $s5, -1					# Stores the second return value.
    	li $s0, 0					# Stores the value of game_over.
    	li $s7, 0					# Stores the number of turns encoded in the turns array.
    	li $t8, 0					# Stores the number of turns we have attempted to play so far.
    	li $s6, 0					# Stores the number of valid turns.
    	
    	getLength:
    		lbu $t0, 0($a2)				# Get the characters from the null-terminated string that represents the turns.
    		beq $t0, '\0', endGetLength		# If the character is null, then jump to the label.
    		addi $s7, $s7, 1			# Otherwise, adds one to the length of the string.
    		addi $a2, $a2, 1			# Moves on to the next character in the string.
    		j getLength				# Jumps back to the label/loop.
    		
    	endGetLength:
    		move $a2, $s2					# Restores the base address of the string that represents turns.
    		li $t1, 5					# Stores 5 in the $t1 register.
    		div $s7, $t1					# Divides the length of turns by 5.
    		mflo $s7					# Stores the quotient in the $s7 register. 
    		addi $sp, $sp, -4				# Deallocates space from the stack in order to store the $ra register.
    		sw $ra, 0($sp)					# Stores the $ra register on the stack.
    		jal load_board					# Calls the load_board function.
    		lw $ra, 0($sp)					# Restores the value of the $ra register.
    		addi $sp, $sp, 4				# Deallocates space from the stack.
    		move $t0, $v0					# Moves the returned result to the $t0 register.
    		beq $t0, -1, returnZeroAndNegativeOne		# If the returned result is -1, then jump to the label.
    		
    	whileLoop:
    		beq $s0, 1, returnFinalWinner			# If game_over = true, then jump to the label.
    		bge $s6, $s3, returnFinalWinner			# If the valid_num_turns >= num_turns_to_play, then jump to the label.
    		bge $t8, $s7, returnFinalWinner			# If the turn_number >= turns_length, then jump to the label.
    		lbu $t2, 0($t9)					# Gets the player's character from the string.
    		beq $t2, '\0', returnFinalWinner		# If the player's character is null, then jump to the label.
    		lbu $t3, 1($t9)					# Gets the player's row index from the string.
    		addi $t3, $t3, -48				# Converts the character to an integer.
    		li $t4, 10					# Stores 10 in the $t4 register.
    		mul $t3, $t4, $t3				# Multiplies the integer by 10.
    		lbu $t5, 2($t9)					# Gets the player's row index from the string.
    		addi $t5, $t5, -48				# Converts the character to an integer.
    		add $t3, $t3, $t5				# Adds the integer to the player's row index.
    		lbu $t4, 3($t9)					# Gets the player's column index from the string.
    		addi $t4, $t4, -48				# Converts the character to an integer.
    		li $t5, 10					# Stores 10 in the $t5 register.
    		mul $t4, $t4, $t5				# Multiplies the integer by 10.
    		lbu $t6, 4($t9)					# Gets the player's column index from the string.
    		addi $t6, $t6, -48				# Converts the character to an integer.
    		add $t4, $t4, $t6				# Adds the integer to the player's column index.
    		addi $t9, $t9, 5				# Moves on to the next turn.
    		addi $t8, $t8, 1				# Adds one to the turn_number.
    		beq $t2, 'X', startGame				# If the player's character is 'X', then jump to the label.
    		beq $t2, 'O', startGame				# If the player's character is 'O', then jump to the label.
    		bne $t2, 'O', whileLoop				# If the player's character is neither 'X' nor 'O', jump back to loop.
    		
    	startGame:
    		lw $t5, 0($a0)					# Gets the number of rows in the board struct.
    		lw $t6, 4($a0)					# Gets the number of columns in the board struct.
    		bge $t3, $t5, whileLoop				# If the row index >= number of rows, then jump back to the loop.
    		bge $t4, $t6, whileLoop				# If the column index >= number of columns, then jump back to the loop.
    		addi $sp, $sp, -4				# Deallocates space from the stack in order to store the $ra register.
    		sw $ra, 0($sp)					# Stores the $ra register on the stack.
    		move $a1, $t3					# Moves the row index to the proper argument.
    		move $a2, $t4					# Moves the column index to the proper argument.
    		move $a3, $t2					# Moves the player's character to the proper argument.
    		jal place_piece					# Calls the place_piece function.
    		lw $ra, 0($sp)					# Restores the value of the $ra register.
    		addi $sp, $sp, 4				# Deallocates space from the stack.
    		move $t6, $v0					# Moves the result of the function call to the $t6 register.
    		addi $s4, $s4, 1				# Adds one to the number of valid turns.
    		addi $s6, $s6, 1				# Adds one to the number of valid turns.
    		beq $t6, -1, whileLoop				# If the returned result is -1, then jump back to the loop.
    		addi $sp, $sp, -4				# Deallocates space from the stack in order to store the $ra register.
    		sw $ra, 0($sp)					# Stores the $ra register on the stack.
    		jal check_horizontal_capture			# Calls the check_horizontal_capture function.
    		lw $ra, 0($sp)					# Restores the value of the $ra register.
    		addi $sp, $sp, 4				# Deallocates space from the stack.
    		addi $sp, $sp, -4				# Deallocates space from the stack in order to store the $ra register.
    		sw $ra, 0($sp)					# Stores the $ra register on the stack.
    		jal check_vertical_capture			# Calls the check_vertical_capture function.
    		lw $ra, 0($sp)					# Restores the value of the $ra register.
    		addi $sp, $sp, 4				# Deallocates space from the stack.
    		addi $sp, $sp, -4				# Deallocates space from the stack in order to store the $ra register.
    		sw $ra, 0($sp)					# Stores the $ra register on the stack.
    		jal check_diagonal_capture			# Calls the check_diagonal_capture function.
    		lw $ra, 0($sp)					# Restores the value of the $ra register.
    		addi $sp, $sp, 4				# Deallocates space from the stack.
    		
    		horizontalWinnerOrNot:
    			move $a1, $a3				# Moves the player's character to the proper argument.
    			addi $sp, $sp, -4			# Deallocates space from the stack in order to store the $ra register.
    			sw $ra, 0($sp)				# Stores the $ra register on the stack.
    			jal check_horizontal_winner		# Calls the check_horizontal_winner function.
    			lw $ra, 0($sp)				# Restores the value of the $ra register.
    			addi $sp, $sp, 4			# Deallocates space from the stack.
    			move $t6, $v0				# Moves the first result to the $t6 register.
    			move $t7, $v1				# Moves the second result to the $t7 register.
    			beq $t6, -1, verticalWinnerOrNot	# If the first result is -1, then jump to the label.
    			beq $t7, -1, verticalWinnerOrNot	# If the second result is -1, then jump to the label.
    			li $s0, 1				# Sets game_over to 1 (true).
    			move $s5, $a1				# Moves the winner of the game to the $s5 register.
    			j returnFinalWinner			# Jumps to the label.
    			
    		verticalWinnerOrNot:
    			addi $sp, $sp, -4			# Deallocates space from the stack in order to store the $ra register.
    			sw $ra, 0($sp)				# Stores the $ra register on the stack.
    			jal check_vertical_winner		# Calls the check_vertical_winner function.
    			lw $ra, 0($sp)				# Restores the value of the $ra register.
    			addi $sp, $sp, 4			# Deallocates space from the stack.
    			move $t6, $v0				# Moves the first result to the $t6 register.
    			move $t7, $v1				# Moves the second result to the $t7 register.
    			beq $t6, -1, firstDiagonalWinnerOrNot	# If the first result is -1, then jump to the label.
    			beq $t7, -1, firstDiagonalWinnerOrNot	# If the second result is -1, then jump to the label.
    			li $s0, 1				# Sets game_over to 1 (true).
    			move $s5, $a1				# Moves the winner of the game to the $s5 register.
    			j returnFinalWinner			# Jumps to the label.
    			
    		firstDiagonalWinnerOrNot:
    			addi $sp, $sp, -4			# Deallocates space from the stack in order to store the $ra register.
    			sw $ra, 0($sp)				# Stores the $ra register on the stack.
    			jal check_sw_ne_diagonal_winner		# Calls the check_sw_ne_diagonal_winner function.
    			lw $ra, 0($sp)				# Restores the value of the $ra register.
    			addi $sp, $sp, 4			# Deallocates space from the stack.
    			move $t6, $v0				# Moves the first result to the $t6 register.
    			move $t7, $v1				# Moves the second result to the $t7 register.
    			beq $t6, -1, secondDiagonalWinnerOrNot	# If the first result is -1, then jump to the label.
    			beq $t7, -1, secondDiagonalWinnerOrNot	# If the second result is -1, then jump to the label.
    			li $s0, 1				# Sets game_over to 1 (true).
    			move $s5, $a1				# Moves the winner of the game to the $s5 register.
    			j returnFinalWinner			# Jumps to the label.
    		
    		secondDiagonalWinnerOrNot:
    			addi $sp, $sp, -4			# Deallocates space from the stack in order to store the $ra register.
    			sw $ra, 0($sp)				# Stores the $ra register on the stack.
    			jal check_nw_se_diagonal_winner		# Calls the check_nw_se_diagonal_winner function.
    			lw $ra, 0($sp)				# Restores the value of the $ra register.
    			addi $sp, $sp, 4			# Deallocates space from the stack.
    			move $t6, $v0				# Moves the first result to the $t6 register.
    			move $t7, $v1				# Moves the second result to the $t7 register.
    			beq $t6, -1, tieOrNot			# If the first result is -1, then jump to the label.
    			beq $t7, -1, tieOrNot			# If the second result is -1, then jump to the label.
    			li $s0, 1				# Set game_over to 1 (true).
    			move $s5, $a1				# Moves the winner of the game to the $s5 register.
    			j returnFinalWinner			# Jumps to the label.
    			
    		tieOrNot:
    			addi $sp, $sp, -4			# Deallocates space from the stack in order to store the $ra register.
    			sw $ra, 0($sp)				# Stores the $ra register on the stack.
    			jal game_status				# Calls the check_nw_se_diagonal_winner function.
    			lw $ra, 0($sp)				# Restores the value of the $ra register.
    			addi $sp, $sp, 4			# Deallocates space from the stack.	
    			move $t6, $v0				# Moves the first result to the $t6 register.
    			move $t7, $v1				# Moves the second result to the $t7 register.
    			add $t0, $t6, $t7			# Adds the two results together and stores it in the $t0 register.
    			lw $t1, 0($a0)				# Stores the number of rows in the board struct.
    			lw $t2, 4($a0)				# Stores the number of columns in the board struct.
    			mul $t1, $t1, $t2			# Gets the total number of characters in the board struct.
    			beq $s0, 1, returnFinalWinner		# If the game is over, then jump to the label.
    			bne $t1, $t0, whileLoop			# If results added together != total num of chars, jump back to loop.
    			li $s0, 1				# Otherwise, game_over is true.
    			li $s5, -1				# Stores -1 in the $s5 register.
    			j returnFinalWinner			# Jumps to the label.
    	
    	returnZeroAndNegativeOne:
    		li $s4, 0				# Stores 0 in the $s4 register.
    		li $s5, -1				# Stores -1 in the $s5 register.
    		
    	returnFinalWinner:
    		move $a1, $s1				# Restores the value of the argument.
    		move $a2, $s2				# Restores the value of the argument.
    		move $a3, $s3				# Restores the value of the argument.
    		move $v0, $s4				# Moves the first result to the $v0 register.
    		move $v1, $s5				# Moves the second result to the $v1 register.
    		jr $ra					# Return the results back to the caller.
