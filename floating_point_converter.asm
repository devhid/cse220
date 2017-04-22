
.text

##############################
# PART 1 FUNCTIONS
##############################

char2digit:
    move $t0, $a0 # load argument in $t0: char c
    blt $t0, 48, C2D_ERROR # throw error if ascii number < 48
    bgt $t0, 57, C2D_ERROR # throw error if ascii number > 57
    
    addi $t0, $t0, -48 # convert ascii string to integer in [0, 9]
    j C2D_CONTINUE # jump to skip the error because our input is valid
    
    C2D_ERROR:
    	li $t0, -1 # store value of -1 into result because input is invalid
    
    C2D_CONTINUE:
    	add $v0, $t0, $0 # store our converted ascii into $v0
    	
   	jr $ra    

memchar2digit:
    move $t0, $a0 # load argument in $t0: char *c
    lb $t0, 0($t0) # load 0th byte from memory address
    
    blt $t0, 48, MC2D_ERROR # throw error if ascii number < 48
    bgt $t0, 57, MC2D_ERROR # throw error if ascii number > 57
    
    addi $t0, $t0, -48 # convert ascii string to integer in [0, 9]
    j MC2D_CONTINUE # jump to skip the error because our input is valid
    
    MC2D_ERROR:
    	li $t0, -1 # store value of -1 into result because input is invalid
    
    MC2D_CONTINUE:
    	add $v0, $t0, $0 # store our converted ascii into $v0

    	jr $ra

fromExcessk:
	move $t0, $a0 # load argument in $t0: int value
	move $t1, $a1 # load argument in $t1: int k
	
	bltz $t0, FEK_ERROR # throw error if value < 0
	blez $t1, FEK_ERROR # throw error if k <= 0
	j FEK_SUCCESS
	
	FEK_ERROR:
	li $v0, -1 # set return value #1 to error (-1)
	move $v1, $t0 # set return value #2 to the same value entered
	jr $ra
	
	FEK_SUCCESS:
	li $v0, 0 # set return value #1 to success (0)
	sub $v1, $t0, $t1 # set return value #2 to value - k
    	
   	jr $ra
printNbitBinary:
    	addi $sp, $sp, -16 # allocate 3 bytes of memory into stack pointer
    	sw $t0, 0($sp) # preserve value of $t0 into stack pointer
    	sw $t1, 4($sp) # preserve value of $t1 into stack pointer
    	sw $t2, 8($sp) # preserve value of $t2 into stack pointer
    	sw $t3, 12($sp) # preserve value of $t3 into stack pointer
    	
	move $t0, $a0 # load argument in $t0: int value
	move $t1, $a1 # load argument in $t1: int m
	
	blt $t1, 1, PNB_ERROR # throw error if m < 1
	bgt $t1, 32, PNB_ERROR # throw error if m > 32
	j PNB_SUCCESS
	
	PNB_ERROR:
	li $t3, -1 # set return value to error (-1)
	j PNB_END
	
	PNB_SUCCESS:
	li $t3, 0 # set return value to success (0)
		
	li $t2, 32 # load 32 into $t2
	sub $t2, $t2, $t1 # $t2 = 32 - m
		
	sllv $t0, $t0, $t2 # value = left shift of 32 - m bits
	PNB_LOOP:
		blez $t1, PNB_END # end loop if m <= 0
		bltz $t0, PRINT_1 # if value < 0, print 1
		j PRINT_0
		
		PRINT_0:
			li $v0, 1 # read_integer mode
			li $a0, 0 # loads 0 to print
			syscall
			j PNB_LOOP_CONTINUE
			
		PRINT_1:
			li $v0, 1 # read integer mode
			li $a0, 1 # loads 1 to print
			syscall
			j PNB_LOOP_CONTINUE
				
		PNB_LOOP_CONTINUE:
			sll $t0, $t0, 1 # shift value left 1 bit
			addi $t1, $t1, -1 # m = m - 1
			j PNB_LOOP
			
		j PNB_END
	PNB_END:
	move $v0, $t3 # get return value back into $v0
    	addi $sp, $sp, 16 # deallocate 4 bytes of memory from stack
    	jr $ra

##############################
# PART 2 FUNCTIONS
##############################

BTOF_ERROR:
li $v0, -1
li $v1, 9 # represents the unspecified value.
jr $ra

btof:	
    	## store special values as words
       	move $s0, $a0 # load the inputted ascii string
       	
       	la $s1, posZero
	li $s2, 0 # counter
       	POS_ZERO_BTOF:
       		add $s3, $s2, $a0
       		lb $s3, ($s3)
       		
       		add $s4, $s1, $s2 
       		lb $s4, ($s4)
       		beq $s3, 0, INPUT_POS_ZERO
       		bne $s3, $s4, CHECK_NEG_ZERO
       		addi $s2, $s2, 1
       		j POS_ZERO_BTOF

       	INPUT_POS_ZERO:
       	li $v1, 0x00000000
       	j BTOF_RETURN_SPECIAL
       	
       	CHECK_NEG_ZERO:
       	la $s1, negZero
	li $s2, 0 # counter
       	NEG_ZERO_BTOF:
       		add $s3, $s2, $a0
       		lb $s3, ($s3)
       		
       		add $s4, $s1, $s2 
       		lb $s4, ($s4)
       		beq $s3, 0, INPUT_NEG_ZERO
       		bne $s3, $s4, CHECK_NAN
       		addi $s2, $s2, 1
       		j NEG_ZERO_BTOF

       	INPUT_NEG_ZERO:
       	li $v1, 0x80000000
       	j BTOF_RETURN_SPECIAL
       	
       	CHECK_NAN:
       	la $s1, temp
       	lb $s2, 0($s0)
       	sb $s2, 0($s1)
       	lb $s2, 1($s0)
       	sb $s2, 1($s1)
       	lb $s2, 2($s0)
       	sb $s2, 2($s1)
       	lb $s2, 3($s0)
       	sb $s2, 3($s1)
       	lw $s1, ($s1)
       	move $s0, $s1
       	
  	lw $s1, notANumber
       	xor $s2, $s0, $s1
       	bnez $s2, CHECK_POS_INF
	li $v1, 0x7FFFFFFF
	j BTOF_RETURN_SPECIAL
	        	
       	CHECK_POS_INF:
  	lw $s1, posInfinity
       	xor $s2, $s0, $s1
       	bnez $s2, CHECK_NEG_INF
       	li $v1, 0x7F800000 
       	j BTOF_RETURN_SPECIAL
       	
       	CHECK_NEG_INF:
  	lw $s1, negInfinity
       	xor $s2, $s0, $s1
       	bnez $s2, BTOF_VALIDATE_2
       	li $v1, 0xFF800000
       	j BTOF_RETURN_SPECIAL
       	
       	BTOF_RETURN_SPECIAL:
      	li $v0, 0
       	jr $ra
    	
    	BTOF_VALIDATE_2:
    	# loop through binary digits to validate them.
    	# valid ascii: 43 (+), 45 (-), 46, 48, 49
    	move $s0, $a0 # load string of binary digits as a word into $s0
    	li $s2, 0
    	BTOF_LOOP_VALIDATE:
    		add $s1, $s2, $s0 # get next address
    		lb $s1, 0($s1) # load 0th byte
    		beq $s1, 0, BTOF_GET_SIGN # end when you reach newline character
    		
    		blt $s1, 43, BTOF_ERROR # throw error if s1 < 43
    		beq $s1, 44, BTOF_ERROR # throw error if s1 == 43
       		beq $s1, 47, BTOF_ERROR # throw errof if s1 == 47
       		bgt $s1, 49, BTOF_ERROR # check if s1 > 49
       		
       		beq $s1, 43, CHECK_FIRST_CHAR
		beq $s1, 45, CHECK_FIRST_CHAR
		j BTOF_CONTINUE_VALIDATION
		
       		CHECK_FIRST_CHAR:
       		bgt $s2, 0, BTOF_ERROR

       		BTOF_CONTINUE_VALIDATION:
       		addi $s2, $s2, 1 # increment address by 1
       		j BTOF_LOOP_VALIDATE
    	
    	BTOF_GET_SIGN:
    	li $v0, 0 # return value = 0, because success
    	
    	# at this point, you can reuse $s1 and $s2
    	# sign bit will be the msb of the 0th byte
    	lb $s1 0($s0) # 0th byte
    	
    	sll $s1, $s1, 24 # shift 24 bits to the let to mask the 0th byte (the sign)
    	li $s2, 0x2D000000 # load the hexadecimal that is equal to a minus (-) sign
    	seq $s1, $s1, $s2 # if byte =  minus (-) sign, set $s1 (sign) to 1, otherwise set to 0
    	sll $s1, $s1, 31 # shift 31 bits to left to place sign in msb
    	move $v1, $s1 
        
        BTOF_GET_POWER:
        # at this point, $s1, holds the sign
        # we can reuse $s2
        
        move $s0, $a0
        li $s2, 0 # index / will also serve as length
        BTOF_POWER_LOOP:
        	add $s3, $s0, $s2
        	lb $s3, ($s3)
        	beq $s3, 49, BTOF_GET_ACTUAL_POWER
        	beq $s3, 46, BTOF_GET_ACTUAL_POWER
        	addi $s2, $s2, 1
        	j BTOF_POWER_LOOP 
        
        # at this point, $s1 locates where the leftmost '1' is or the binary point, '.'
        # also, $s3 stores '1' or '.'
        BTOF_GET_ACTUAL_POWER:
        li $s4, 0 # stores actual power
        addi $s2, $s2, 1
        move $s5, $s2 # stores same value as index, let's call it "distance"
       
        beq $s3, 49, BTOF_1_POWER # check if digit = '1'
        j BTOF_DOT_POWER
 
        BTOF_DOT_POWER:
        	add $s6, $s5, $s0
        	lb $s6, 0($s6)
        	beq $s6, 49, BTOF_DOT_POWER_CONT
        	beq $s6, 0, INPUT_POS_ZERO
        	addi $s5, $s5, 1 # increment distance
        	addi $s4, $s4, -1 # decrement power
        	j BTOF_DOT_POWER 
        j BTOF_GET_EXPONENT
       
        BTOF_1_POWER:
        	add $s6, $s2, $s0
        	lb $s6, 0($s6)
        	beq $s6, 46, BTOF_GET_EXPONENT
        	addi $s2, $s2, 1 # increment index
        	addi $s4, $s4, 1 # increment power
        	j BTOF_1_POWER
        
        BTOF_DOT_POWER_CONT:
        addi $s4, $s4, -1
        addi $s5, $s5, 1
        
        BTOF_GET_EXPONENT:
        # at this point, we need $s0, $s1, and $s5, $s4
        move $s2, $s4 # move power to $s2
        move $t8, $s3
        move $s3, $s5 # move distance to $s3
        
        addi $s2, $s2, 127 # $s2 is now the full exponent
        sll $s2, $s2, 23 # shift exponent bits to msb - 1 position
        or $s1, $s1, $s2 # store sign + exponent into $s4, first 9 bits occupied
        
        BTOF_GET_FRACTION:
        move $s2, $s3 # s2 now contains distance
        # used: $s0, $s1, $s2

        move $s0, $a0
        
        beq $t8, 49, SKIP_ADD_DISTANCE_1
        addi $s2, $s2, 2
        
        SKIP_ADD_DISTANCE_1:
        add $s0, $s0, $s2
        li $s3, 0 # register to store fraction
        li $s4, 0 # counter
       
        BTOF_FRACTION_LOOP:
        	beq $s4, 23, EXIT_FRACTION_LOOP
        	
        	add $s5, $s4, $s0
        	lb $s5, 0($s5)
        	beq $s5, 46, SKIP_PERIOD
        	
        	move $a0, $s5
		
		addi $sp, $sp, -12
		sw $v0, 0($sp)
                sw $a0, 4($sp)
                sw $ra, 8($sp)
                
        	jal char2digit
        	
		lw $ra, 8($sp)
        	
        	li $s6, 1
        	seq $s7, $v0, $s6
        	
                lw $a0, 4($sp)
        	lw $v0, 0($sp)
        	addi $sp, $sp, 12
        	
        	or $s3, $s3, $s7
        	sll $s3, $s3, 1
        	
        	SKIP_PERIOD:
        	addi $s4, $s4, 1

		j BTOF_FRACTION_LOOP
        EXIT_FRACTION_LOOP:
        or $s1, $s1, $s3
        move $v1, $s1
    	jr $ra

print_parts:
    	move $s0, $a0 				# load floating point number
    	
    	separateBits:
    	andi $s1, $s0, 0x80000000 		# get sign bit
    	andi $s2, $s0, 0x7F800000 		# get exponent
    	andi $s3, $s0, 0x007FFFFF		# get fraction
    	
    	printSignBit:
    	srl $s1, $s1, 31			# shift sign bit to lsb
    	
    	move $a0, $s1				#----
    	li $v0, 1				# print sign bit
    	syscall					#----
    	
	la $a0, space				#---- 
    	li $v0, 4				# print space
    	syscall					#----
    	
    	printSign:				# will print the sign (+ or -) next to the sign bit
    	beqz $s1, printPlus
    	j printMinus
    	
    	printPlus:
	la $a0, plus				#---- 
    	li $v0, 4				# print +
    	syscall					#----  
    	j printNewline	
    	
    	printMinus:
	la $a0, negative			#---- 
    	li $v0, 4				# print -
    	syscall					#----  	
    	
    	printNewline:				
    	la $a0, newLine				#----
    	li $v0, 4				# print new line
    	syscall					#----
   
   	printExponent:
   	srl $s2, $s2, 23			# shift exponent to msb
   	
   	move $a0, $s2				# move exponent to printNbitBinary value argument
   	li $a1, 8				# set number of bits to be printed out to 8
   	
      	addi $sp, $sp, -4			# allocates 1 byte of space to stack pointer
      	sw $ra, 0($sp)				# preserve return address
      	
   	jal printNbitBinary			# prints the exponent
   	
   	lw $ra 0($sp)				# restores value of return address
      	addi $sp, $sp, 4			# deallocates 1 byte of space from stack pointer
   	
   	la $a0, space				#----
    	li $v0, 4				# print space
    	syscall					#----
    	
    	move $a0, $s2				#----
    	li $v0, 1				# prints decimal version of exponent
    	syscall					#----
    	
    	la $a0, newLine				#----
    	li $v0, 4				# print new line
    	syscall					#----
    	
    	printFraction:
   	move $a0, $s3				# move fraction to printNbitBinary value argument
   	li $a1, 23				# set number of bits to be printed out to 8
   	
      	addi $sp, $sp, -4			# allocates 1 byte of space to stack pointer
      	sw $ra, 0($sp)				# preserve return address
      	
   	jal printNbitBinary			# prints the exponent
   	
   	lw $ra 0($sp)				# restores value of return address
      	addi $sp, $sp, 4			# deallocates 1 byte of space from stack pointer
   	
   	la $a0, space				#----
    	li $v0, 4				# print space
    	syscall					#----
    	
    	move $a0, $s3				#----
    	li $v0, 1				# prints decimal version of fraction
    	syscall					#----
    	
	#--[  check if floating point = special value  ]--#
	xori $t4, $s0, 0x00000000		# check if floating point = +0.0
	beqz $t4, setReturnZero
	
	xori $t4, $s0, 0x80000000		# check if floating point = -0.0
	beqz $t4, setReturnZero
	
	xori $t4, $s0, 0x7FFFFFFF		# check if floating point = NaN
	beqz $t4, setReturnZero
	
	xori $t4, $s0, 0x7F800000		# check if floating point = +Inf
	beqz $t4, setReturnZero
	
	xori $t4, $s0, 0xFF800000		# check if floating point = +Inf
	beqz $t4, setReturnZero
    	j checkSign
    	
    	setReturnZero:
	li $v0, 0
	jr $ra
	
	checkSign:
	beq $s1, 1, setNegativeOne
	j setPositiveOne
	
	setNegativeOne:
	li $v0, -1
	jr $ra
	
	setPositiveOne:
	li $v0, 1
	
	move $a0, $s0 # restore value of $a0
	
   	jr $ra

print_binary_product:
    	move $s0, $a0

	#--[  check if floating point = special value  ]--#
	xori $t4, $s0, 0x00000000		# check if floating point = +0.0
	beqz $t4, specialValue
	
	xori $t4, $s0, 0x80000000		# check if floating point = -0.0
	beqz $t4, specialValue
	
	xori $t4, $s0, 0x7FFFFFFF		# check if floating point = NaN
	beqz $t4, specialValue
	
	xori $t4, $s0, 0x7F800000		# check if floating point = +Inf
	beqz $t4, specialValue
	
	xori $t4, $s0, 0xFF800000		# check if floating point = +Inf
	beqz $t4, specialValue
	j separateBits2
	
	specialValue:
	li $v0, 0
	jr $ra
    
    	separateBits2:
    	andi $s1, $s0, 0x80000000 		# get sign bit
    	andi $s2, $s0, 0x7F800000 		# get exponent
  	andi $s3, $s0, 0x007FFFFF		# get fraction
  	
  	la $a0, newLine
  	li $v0, 4
  	syscall
  	
  	printSign2:				# will print the sign (+ or -) next to the sign bit
    	beqz $s1, printPlus2
    	j printMinus2
    	
    	printPlus2:
	la $a0, plus				
    	li $v0, 4				# print +
    	syscall					 
    	j printFloatingPoint	
    	
    	printMinus2:
	la $a0, negative			 
    	li $v0, 4				# print -
    	syscall						
    	
    	printFloatingPoint:
    	li $a0, 1
    	li $v0, 1
    	syscall
    	
    	la $a0, dot				# print binary point
    	li $v0, 4
    	syscall
  
  	move $a0, $s3				# move fraction into $a0
  	
  	addi $sp, $sp, -4			# allocate 1 byte of space into stack pointer
  	sw $ra 0($sp)				# preserve return address
  	
  	jal printNbitBinary			# print fractional binary digits
  	
  	lw $ra 0($sp)  				# restore return address
 	addi $sp, $sp, 4			# deallocate 1 byte of space from stack pointer

	la $a0, space				# print space
    	li $v0, 4
    	syscall 	
 	
    	la $a0, product				# print multiplication sign
    	li $v0, 4
    	syscall   

	la $a0, space				# print space
    	li $v0, 4
    	syscall     	
    	    	    	
    	li $a0, 2				# print 2
    	li $v0, 1
    	syscall
    	
    	la $a0, carrot				# print exponential sign	
    	li $v0, 4
    	syscall
    	
    	srl $a0, $s2, 23			# shift exponent to lsb and load into argument #1
    	li $a1, 127 				# load 127 into argument #2
    	
  	addi $sp, $sp, -4			# allocate 1 byte of space into stack pointer
  	sw $ra 0($sp)				# preserve return address
  	
  	jal fromExcessk				# calculate k by calling fromExcessk
  	
  	lw $ra 0($sp)  				# restore return address
 	addi $sp, $sp, 4			# deallocate 1 byte of space from stack pointer
 	
 	move $s4, $v1				# move value of k into $s4
 	bgez $s4, printPlus3			# if k >=0, print +, otherwise just print the result.
 	j printExponentFinal
 	
 	printPlus3:
 	la $a0, plus
 	li $v0, 4
 	syscall
    	  
    	printExponentFinal:
    	move $a0, $s4
    	li $v0, 1
    	syscall
    	       
   	jr $ra



#################################################################
# Student defined data section
#################################################################
.data
.align 2  # Align next items to word boundary
#place all data declarations here
posZero: .asciiz "+0.0"
.align 2
negZero: .asciiz "-0.0"
.align 2
notANumber: .ascii "NaN"
.align 2
posInfinity: .asciiz "+Inf"
.align 2
negInfinity: .asciiz "-Inf"
.align 2
plus: .asciiz "+"
.align 2
negative: .asciiz "-"
.align 2
dot: .asciiz "."
.align 2
carrot: .asciiz "^"
.align 2
product: .asciiz "x"
.align 2
space: .asciiz " "
.align 2
newLine: .asciiz "\n"
.align 2
temp: .word 0



