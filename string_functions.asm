
.text

##############################
# FUNCTIONS
##############################

indexOf:
    # preserve original values
    addi $sp, $sp, -16			# Allocate 3 bytes of memory in stack frame
    sw $s0, 0($sp)			# Preserve original value of $s0
    sw $s1, 4($sp)			# Preserve original value of $s1
    sw $s2, 8($sp)			# Preserve original value of $s2
    sw $s3, 12($sp)			# Preserve original value of $s3
    
    # load arguments into $s registers
    move $s0, $a0			# s0 : char[] str
    move $s1, $a1			# s1 : char ch
    move $s2, $a2			# s2 : int startIndex
    
    bltz $s2, ioEndNotFound		# Return -1 because startIndex is negative 
  
    ioLoop:         
        add $s3, $s2, $s0		# Byte address to load next char (starting index = $s2)
        lb $s3, ($s3)			# Loads byte into $s4
        beq $s3, $s1, ioEndFound	# Ends loop if we find our character
        beqz $s3, ioEndNotFound		# Ends loop if we reach null terminator 
        addi $s2, $s2, 1		# Increments byte index
        j ioLoop			# Loop through the char array
    
ioEndFound:
    move $v0, $s2			# Returns index of found character.
    j ioEnd				# Jump to final function operations
        
ioEndNotFound:
    li $v0, -1				# Return -1 because char was not found.
    j ioEnd				# Jump to final function operations
    
ioEnd:
    lw $s0, 0($sp)			# Restore original value of $s0
    lw $s1, 4($sp)			# Restore original value of $s1
    lw $s2, 8($sp)			# Restore original value of $s2    
    lw $s3, 12($sp)			# Restore original value of $s3
    addi $sp, $sp, 16			# Deallocate 3 bytes of memory in stack frame
    
    jr $ra				# End function
   
replaceAllChar:
    # preserve original values
    addi $sp, $sp, -32			# Allocate 8 bytes of memory in stack frame
    sw $s0, 0($sp)			# Preserve original value of $s0
    sw $s1, 4($sp)			# Preserve original value of $s1
    sw $s2, 8($sp)			# Preserve original value of $s2
    sw $s3, 12($sp)			# Preserve original value of $s3
    sw $s4, 16($sp)			# Preserve original value of $s4
    sw $s5, 20($sp)			# Preserve original value of $s5
    sw $s6, 24($sp)			# Preserve original value of $s6
    sw $s7, 28($sp)			# Preserve original value of $s7
    
    # load arguments into $s registers
    move $s0, $a0			# s0 : char[] str
    move $s1, $a1			# s1 : char[] pattern
    move $s2, $a2			# s2 : char replacement    

    # check if the str is empty
    lb $s3, 0($s0)			# Get the first character from str
    beqz $s3, racEndError		# Jump because str is empty
    
    # check if pattern is empty
    lb $s3, 0($s1)			# Get the first character from pattern
    beqz $s3, racEndError		# Jump because pattern is empty
    
    j racStart				# Jump to start the replacement process
    
racEndError:
    move $v0, $s0			# Return the original string because str is empty
    li $v1, -1				# Return -1 because str is empty		
    j racRestore			# End function
    
racStart:
    # declare loop variables
    li $s3, 0				# outer byte index
    li $s4, 0				# inner byte index
    li $s7, 0				# number of replacements performed
    
    racOuterLoop:
        add $s5, $s3, $s0		# Byte address to load next char for str
        lb $s5, ($s5)			# Loads byte into $s5
        beqz $s5, racEnd		# Ends loop if we reach null terminator 
        j racInnerLoop			# Jump to inner loop to check each char in pattern
    
        racContinueOuterLoop:
        addi $s3, $s3, 1		# Increments byte index
        li $s4, 0			# Resets inner byte index
        j racOuterLoop			# Loop through the char array
        
    racInnerLoop:
        add $s6, $s4, $s1		# Byte address to load next char for pattern
        lb $s6, ($s6)			# Load first character of new address into $s6
        beq $s6, $s5, racReplace	# Replaces the char if string matches pattern
        beqz $s6, racContinueOuterLoop	# If not, load next char in outer loop.
        addi $s4, $s4, 1		# Increment inner byte index
        j racInnerLoop			# Loop through the pattern array
        
racReplace:
    add $s6, $s3, $s0			# Gets the byte address of the character to be replaced
    sb $s2, ($s6)			# Substitutes the replacement into the string         
    addi $s7, $s7, 1			# Increments number of replacements performed by 1
    j racContinueOuterLoop		# Jumps back to outer loop
    	
racEnd:
    move $v0, $s0			# Return address of replaced string
    move $v1, $s7			# Return number of replacements performed
    j racRestore
    	
racRestore:                      
    lw $s0, 0($sp)			# Restore original value of $s0
    lw $s1, 4($sp)			# Restore original value of $s1
    lw $s2, 8($sp)			# Restore original value of $s2
    lw $s3, 12($sp)			# Restore original value of $s3
    lw $s4, 16($sp)			# Restore original value of $s4
    lw $s5, 20($sp)			# Restore original value of $s5
    lw $s6, 24($sp)			# Restore original value of $s6
    lw $s7, 28($sp)			# Restore original value of $s7 
    addi $sp, $sp, 32			# Deallocate 8 bytes of memory in stack frame				

    jr $ra				# End function
    
countOccurrences:
    # preserve original values
    addi $sp, $sp, -28			# Allocate 7 bytes of memory in stack frame
    sw $s0, 0($sp)			# Preserve original value of $s0
    sw $s1, 4($sp)			# Preserve original value of $s1
    sw $s2, 8($sp)			# Preserve original value of $s2
    sw $s3, 12($sp)			# Preserve original value of $s3
    sw $s4, 16($sp)			# Preserve original value of $s4
    sw $s5, 20($sp)			# Preserve original value of $s5
    sw $s6, 24($sp)			# Preserve original value of $s6
        
    # load arguments into $s registers
    move $s0, $a0			# s0 : char[] str
    move $s1, $a1			# s1 : char[] searchChars

    # check if the str is empty
    lb $s2, 0($s0)			# Get the first character from str
    beqz $s2, coEndError		# Jump because str is empty
    
    # check if pattern is empty
    lb $s2, 0($s1)			# Get the first character from pattern
    beqz $s2, coEndError		# Jump because pattern is empty

    j coStart				# Start the checking process
    
coEndError:       
    li $v0, 0				# Return 0 because str or searchChars is empty
    j coRestore				# End function

coStart:
    # declare loop variables
    li $s2, 0				# outer byte index
    li $s3, 0				# inner byte index
    li $s6, 0				# number of occurences performed
    
    coOuterLoop:
        add $s4, $s2, $s0		# Byte address to load next char for str
        lb $s4, ($s4)			# Loads byte into $s4
        beqz $s4, coEnd			# Ends loop if we reach null terminator 
        j coInnerLoop			# Jump to inner loop to check each char in searchChars
    
        coContinueOuterLoop:
        addi $s2, $s2, 1		# Increments byte index
        li $s3, 0			# Resets inner byte index
        j coOuterLoop			# Loop through the char array
        
    coInnerLoop:
        add $s5, $s3, $s1		# Byte address to load next char for pattern
        lb $s5, ($s5)			# Load first character of new address into $s5
        beq $s5, $s4, coIncrementCount	# Increment number of occurences if string matches pattern
        beqz $s5, coContinueOuterLoop	# If we reach end of searchChars, load next char in outer loop.
        addi $s3, $s3, 1		# Increment inner byte index
        j coInnerLoop			# Loop through the pattern array
        
coIncrementCount:       
    addi $s6, $s6, 1			# Increments number of occurences by 1
    j coContinueOuterLoop		# Jumps back to outer loop        
            
coEnd:
    move $v0, $s6			# Return number of occurences
    j coRestore    			# Jump to restore the saved values and end the function
    
coRestore:
    lw $s0, 0($sp)			# Restore original value of $s0
    lw $s1, 4($sp)			# Restore original value of $s1
    lw $s2, 8($sp)			# Restore original value of $s2
    lw $s3, 12($sp)			# Restore original value of $s3
    lw $s4, 16($sp)			# Restore original value of $s4
    lw $s5, 20($sp)			# Restore original value of $s5
    lw $s6, 24($sp)			# Restore original value of $s6
    addi $sp, $sp, 28			# Deallocate 7 bytes of memory in stack frame				

    jr $ra				# End function
    
length:
    addi $sp, $sp, -12			# Allocate 3 byte of memory into stack frame
    sw $s0, 0($sp)			# Preserve value of $s0
    sw $s1, 4($sp)			# Preserve value of $s1
    sw $s2, 8($sp)			# Preserve value of $s2
    
    move $s0, $a0			# Grab the starting address of a string from first argument
    
    li $s1, 0				# Will store length of the string
    li $s2, 0				# New byte address for the string
    lengthLoop:
        add $s2, $s1, $s0		# Calculate new byte address
        lb $s2, ($s2)			# Load next char
        beqz, $s2, lengthEnd		# Returns the length of the string
        addi $s1, $s1, 1		# Increment length by 1.
        j lengthLoop			# Continue the loop. 
    
lengthEnd:
    move $v0, $s1			# Store the length of the string into $v0
    
    lw $s0, 0($sp)			# Restore the value of $s0
    lw $s1, 4($sp)			# Restore the value of $s1
    lw $s2, 8($sp)			# Restore the value of $s2
    
    addi $sp, $sp, 12			# Deallocate 3 bytes of memory from the stack frame
    jr $ra   				# End the function

storeInDst:
    addi $sp, $sp, -20			# Allocate 5 bytes of memory into stack frame
    sw $s0, 0($sp)			# Preserve the value of $s0
    sw $s1, 4($sp)			# Preserve the value of $s1
    sw $s2, 8($sp)			# Preserve the value of $s2
    sw $s3, 12($sp)			# Preserve the value of $s3
    sw $s4, 16($sp)			# Preserve the value of $s4
    
    move $s0, $a0			# Store the address of dst in $s0
    move $s1, $a1			# Store the address of the replacement string in $s1
    
    li $s2, 0				# Store the byte index for the replacement string
    li $s3, 0				# Store the next byte address/char for replacement string
    li $s4, 0				# Store the next byte address/char for dst 
    sidLoop:
        add $s3, $s2, $s1		# Get next byte address for replacement string character
        add $s4, $s2, $s0		# Get next byte address for dst character
        lb $s3, ($s3)			# Get next char from replacement string
        beqz $s3, sidEnd		# End the function if null terminator is reached
        sb $s3, ($s4)			# Store the next char in dst
        addi $s2, $s2, 1		# Increment the byte index
        j sidLoop
        
sidEnd:
    move $v0, $s0			# Return the address of dst
       
    lw $s0, 0($sp)			# Restore the value of $s0
    lw $s1, 4($sp)			# Restore the value of $s1			
    lw $s2, 8($sp)			# Restore the value of $s2
    lw $s3, 12($sp)			# Restore the value of $s3
    lw $s4, 16($sp)			# Restore the value of $s4
    addi $sp, $sp, 20			# Allocate 5 bytes of memory into stack frame
    
    jr $ra     
                               
replaceAllSubstr:
    # load arguments into $t registers
    move $t0, $a0			# $t0 : char[] dst
    move $t1, $a1			# $t1 : int dstLen
    move $t2, $a2			# $t2 : char[] str
    move $t3, $a3			# $t3 : char[] searchChars
    lw $t4, 0($sp)			# $t4 : char[] replaceStr
    
    # check if str is empty
    lb $t5, 0($t2)			# Store the first char of char[] str into $t5 
    beqz $t5, rasEndError		# If the char is \0, then throw error.
    
    # check if searchChars is empty
    lb $t5, 0($t3)			# Store the first char of char[] searchCharts into $t5 
    beqz $t5, rasEndError		# If the char is \0, then throw error.
    
##----## Check if modified string length <= dstLen ##----##
    
    # Get the length of char[] str
    move $a0, $t2			# Set char[] str as first argument.
    
    addi $sp, $sp, -24			# Allocate 6 bytes of memory to stack frame			
    sw $ra, 0($sp)			# Preserve return address
    
    # Preserve the $t registers that are needed after function call
    sw $t0, 4($sp)
    sw $t1, 8($sp)
    sw $t2, 12($sp)
    sw $t3, 16($sp)
    sw $t4, 20($sp)
    
    jal length				# Call length function to get length of str
    
    lw $ra, 0($sp)			# Restore value of return address
    
    # Restore the $t registers after function call
    lw $t0, 4($sp)
    lw $t1, 8($sp)
    lw $t2, 12($sp)
    lw $t3, 16($sp)
    lw $t4, 20($sp)
    addi $sp, $sp, 24			# Deallocate 6 bytes of memory
    
    move $t5, $v0			# Store the length of str into $t5
    
    # Get the length of char[] replaceStr
    move $a0, $t4			# Set char[] replaceStr as first argument.
        
    addi $sp, $sp, -28			# Allocate 7 bytes of memory to stack frame			
    sw $ra, 0($sp)			# Preserve return address
    
    # Preserve the $t registers that are needed after function call
    sw $t0, 4($sp)
    sw $t1, 8($sp)
    sw $t2, 12($sp)
    sw $t3, 16($sp)
    sw $t4, 20($sp)
    sw $t5, 24($sp)
    
    jal length				# Call length function to get length of replaceStr
    
    lw $ra, 0($sp)			# Restore value of return address
    
    # Restore the $t registers after function call
    lw $t0, 4($sp)
    lw $t1, 8($sp)
    lw $t2, 12($sp)
    lw $t3, 16($sp)
    lw $t4, 20($sp)
    lw $t5, 24($sp)
    addi $sp, $sp, 28			# Deallocate 7 bytes of memory
    
    move $t6, $v0			# Store the length of str into $t6
    
##---## Checks if modified string length is valid ##---##
    move $a0, $t2			# Load char[] str into first argument
    move $a1, $t3			# Load char[] searchChars into second argument
    
    addi $sp, $sp, -32			# Allocate 8 bytes of memory to stack frame			
    sw $ra, 0($sp)			# Preserve return address
    
    # Preserve the $t registers that are needed after function call
    sw $t0, 4($sp)
    sw $t1, 8($sp)
    sw $t2, 12($sp)
    sw $t3, 16($sp)
    sw $t4, 20($sp)
    sw $t5, 24($sp)
    sw $t6, 28($sp)
    
    jal countOccurrences		# Call countOccurrences to get number of replacements
    
    lw $ra, 0($sp)			# Restore value of return address
    
    # Restore the $t registers after function call
    lw $t0, 4($sp)
    lw $t1, 8($sp)
    lw $t2, 12($sp)
    lw $t3, 16($sp)
    lw $t4, 20($sp)
    lw $t5, 24($sp)
    lw $t6, 28($sp)
    addi $sp, $sp, 32			# Deallocate 8 bytes of memory
    
    sub $t5, $t5, $v0			# $t5 = strLen - countOccurrences 
    mul $t7, $t6, $v0			# $t7 = replaceStrLen * countOccurrences
    add $t5, $t5, $t7			# $t5 = $t5 + (countOccurrences * replaceStrLen)
    addi $t5, $t5, 1			# Add 1 to account for null terminator character
    bgt $t5, $t1, rasEndError		# Throw error if $t5 (modified string length) > dstLen
    j rasStart				# Jump to the actual core method process
    
rasStart:
    move $t1, $t6			# Store replaceStr length in $t1
    move $v1, $v0			# Store the number of replacements in $v1
    
    ##---## At this point, the only registers that cannot be changed are: $t0, $t1, $t2, $t3, $t4 ##---##
    
    li $t5, 0				# Stores outer loop byte index
    li $t6, 0				# Next char for char[] str
    li $t7, 0				# Stores inner loop byte index
    li $t8, 0       			# Next char for char[] searchChars
    move $t9, $t0			# Will store address for dst
    
    rasStrLoop:
        add $t6, $t5, $t2		# Gets next byte address for next char in char[] str
        lb $t6, 0($t6)			# Gets next byte for next char in char[] str
        beqz $t6, rasAddNullTerm	# End Loop when null terminator is reached
        j rasSearchCharLoop		# Check the searchChars against the current char
        
        rasContinueStrLoop:
        li $t7, 0			# Reset inner byte index		
        addi $t5, $t5, 1		# Increment byte index
        j rasStrLoop			# Continue loop
   
    rasSearchCharLoop:
        add $t8, $t7, $t3		# Gets next byte address for next char in char[] searchChars
        lb $t8, 0($t8)			# Gets next byte for next char in char[] searchChars
        beqz $t8, rasDstStoreChar	# Store the char in dst if no match was found.
	beq $t8, $t6, rasDstReplaceChar	# Store the replacement for the char in dst.	
        addi $t7, $t7, 1		# Increment byte index
        j rasSearchCharLoop		# Continue loop

rasDstStoreChar:
    sb $t6, 0($t9)			# Store original char in dst
    addi $t9, $t9, 1			# Increment dst address by 1
    j rasContinueStrLoop      		# Continue looping through the string
                              
rasDstReplaceChar:
    move $a0, $t9			# Move dst address into first function argument
    move $a1, $t4			# Move replacStr address into second function argument
    
    addi $sp, $sp, -44			# Allocate 11 bytes of memory to stack frame			
    sw $ra, 0($sp)			# Preserve return address
    
    # Preserve the $t registers that are needed after function call
    sw $t0, 4($sp)
    sw $t1, 8($sp)
    sw $t2, 12($sp)
    sw $t3, 16($sp)
    sw $t4, 20($sp)
    sw $t5, 24($sp)
    sw $t6, 28($sp)
    sw $t7, 32($sp)
    sw $t8, 36($sp)
    sw $t9, 40($sp)
    
    jal storeInDst			# Call storeInDst to store the replacement characters in dst
    
    lw $ra, 0($sp)			# Restore value of return address
    
    # Restore the $t registers after function call
    lw $t0, 4($sp)
    lw $t1, 8($sp)
    lw $t2, 12($sp)
    lw $t3, 16($sp)
    lw $t4, 20($sp)
    lw $t5, 24($sp)
    lw $t6, 28($sp)
    lw $t7, 32($sp)
    lw $t8, 36($sp)
    lw $t9, 40($sp)
    addi $sp, $sp, 44			# Deallocate 11 bytes of memory
    
    add $t9, $t9, $t1			# Increment the dst address by length of replacement string
    j rasContinueStrLoop		# Continue looping through the string
    
rasEndError:        
    move $v0, $t0			# Store the address for dst in $v0 (first return value)
    li $v1, -1				# Store -1 in $v0 (second return value)
    jr $ra				# Jump to end function

rasAddNullTerm:
    sb $0, ($t9)			# Place a null terminator at the end of the dst string 		
    j rasEnd				# Jump to end function
    
rasEnd:
    move $v0, $t0			# Store the address pointing to dst in $v0
    jr $ra				# End function

split:
    move $t0, $a0			# $t0 : char[] dst
    move $t1, $a1			# $t1 : int dstLen
    move $t2, $a2			# $t2 : char[] str
    move $t3, $a3    			# $t3 : char delimiter
    
    # check if str is empty
    lb $t4, 0($t2)			# Load the first character of char[] str
    beqz $t4, splitEndError		# Throw an error because str was empty.
    
    # check if the delimiter is not in str
    move $a0, $t2			# Store the string in first argument
    move $a1, $t3			# Store the delimiter in second argument
    move $a2, $0			# Store 0 as the startIndex
    
    addi $sp, $sp, -20			# Allocate 5 bytes of memory to stack frame
    sw $ra, 0($sp)			# Preserve the return address
    
    # Preserve the t registers that are needed after function call 
    sw $t0, 4($sp)
    sw $t1, 8($sp)
    sw $t2, 12($sp)
    sw $t3, 16($sp)
    
    jal indexOf				# Call indexOf to see if the string contains the delimiter
    
    lw $ra, 0($sp)			# Restore value of return address
    
    # Restore the $t registers after function call
    lw $t0, 4($sp)
    lw $t1, 8($sp)
    lw $t2, 12($sp)
    lw $t3, 16($sp)
    
    addi $sp, $sp, 20			# Deallocate 5 bytes of memory from stack pointer
    
    beq, $v0, -1, splitEndNoDelimiter	# If no delimiter is found, jump to splitEndNoDelimiter
    j splitStart			# If it is found, jump to splitStart to begin the core function process
    
splitStart:
    move $a0, $t2			# Store char[] str in first argument
    move $a1, $t3			# Store char delimiter in second argument
    
    addi $sp, $sp, -20			# Allocate 5 bytes of memory to stack frame
    sw $ra, 0($sp)			# Preserve the return address
    
    # Preserve the t registers that are needed after function call 
    sw $t0, 4($sp)
    sw $t1, 8($sp)
    sw $t2, 12($sp)
    sw $t3, 16($sp)
    
    jal countOccurrences2		# Call co2 to get number of occurrences
    
    lw $ra, 0($sp)			# Restore value of return address
    
    # Restore the $t registers after function call
    lw $t0, 4($sp)
    lw $t1, 8($sp)
    lw $t2, 12($sp)
    lw $t3, 16($sp)
    
    addi $sp, $sp, 20			# Deallocate 5 bytes of memory from stack pointer
    
    # Calculate the number maximum number of memory addresses allowed
    addi $t4, $v0, 1			# $t4 = countOccurrences + 1
    bgt $t4, $t1, splitMaxIsDstLen	# if $t4 > dstLen, then maxAddresses = dstLen
    li $t1, 0				# Set $t1 to 0 because str was completely tokenized.
    j splitTokenize			# Start tokenizing process
    
    splitMaxIsDstLen:
    move $t4, $t1			# Set max addresses to dstLen
    li $t1, -1				# Set $t1 to -1 because str wasnt completely tokenized
    
    # At this point, We are using $t0 - $t4 where $t1 = success/fail tokenizing and $t4 = maxAddresses
splitTokenize:
    li $t5, 0				# count number of memory addresses
    li $t6, 0				# firstIndex
    li $t7, 0    			# secondIndex
    li $t8, 0				# will store copy of str address
    move $t9, $t0			# copy of dst address    
    
    splitLoop:
        add $t8, $t6, $t2		# Get new address for token
        sw $t8, ($t9)			# Store memory address in dst
        
        addi $t5, $t5, 1		# counter = counter + 1        
        
        # Get index of delimiter by calling indexOF
        move $a0, $t2			# Store char[] str in first argument
    	move $a1, $t3			# Store char delimiter in second argument
        move $a2, $t6			# Start the index at firstIndex
        
    	addi $sp, $sp, -44		# Allocate 11 bytes of memory to stack frame
    	sw $ra, 0($sp)			# Preserve the return address
    
    	# Preserve the t registers that are needed after function call 
    	sw $t0, 4($sp)
    	sw $t1, 8($sp)
    	sw $t2, 12($sp)
    	sw $t3, 16($sp)
    	sw $t4, 20($sp)
    	sw $t5, 24($sp)
    	sw $t6, 28($sp)
    	sw $t7, 32($sp)
    	sw $t8, 36($sp)
    	sw $t9, 40($sp)
    
   	jal indexOf			# Call co2 to get number of occurrences
    
    	lw $ra, 0($sp)			# Restore value of return address
    
    	# Restore the $t registers after function call
    	lw $t0, 4($sp)
    	lw $t1, 8($sp)
    	lw $t2, 12($sp)
    	lw $t3, 16($sp)
    	lw $t4, 20($sp)
    	lw $t5, 24($sp)
    	lw $t6, 28($sp)
    	lw $t7, 32($sp)
    	lw $t8, 36($sp)
    	lw $t9, 40($sp)
    
    	addi $sp, $sp, 44		# Deallocate 11 bytes of memory from stack pointer
        
        move $t7, $v0			# Move index to $t7
        beq $t7, -1, splitEnd    	# Jump to end function if delimIndex = -1
        beq $t5, $t4, splitEnd 		# Jump to end function if counter == maxMemAddressess
        
        add $t8, $t2, $t7		# Get address of delimiter in str
        sb $0, ($t8) 			# Store \0 at that location
        
        addi $t6, $t7, 1		# firstIndex = secondIndex + 1
        addi $t9, $t9, 4		# Increment dst address by 4 (because we are storing words)
        j splitLoop			# Jump to loop again
        
splitEndNoDelimiter:
    li $v0, 1				# Since the entire string is token, store 1 for number of tokens
    li $v1, 0				# Since tokenizing was successful, store 0 for second return value
    
    sw $t2, 0($t0)			# Store the memory address of the string in dst.
    
    jr $ra	 			# End the function

splitEndError:
    li $v0, 0				# Store 0 in first return value because no addresses in dst
    li $v1, -1				# Store -1 in second return value because str was empty.
    
    jr $ra				# End the function    
    
splitEnd:        
    move $v0, $t4			# Store number of memory addresses tokenized for 1st return value
    move $v1, $t1			# Return success/fail complete tokenizing for second value
    
    jr $ra				# End the function
    
countOccurrences2:
    # preserve original values
    addi $sp, $sp, -20			# Allocate 3 bytes of memory in stack frame
    sw $s0, 0($sp)			# Preserve original value of $s0
    sw $s1, 4($sp)			# Preserve original value of $s1
    sw $s2, 8($sp)			# Preserve original value of $s2
    sw $s3, 12($sp)			# Preserve original value of $s3
    sw $s4, 16($sp)			# Preserve original value of $s4
    
    # load arguments into $s registers
    move $s0, $a0			# s0 : char[] str
    move $s1, $a1			# s1 : char ch
    
    # initialize loop variables
    li $s2, 0				# byte index
    li $s4, 0				# counter for replacements
    co2Loop:         
        add $s3, $s2, $s0		# Byte address to load next char (starting index = $s2)
        lb $s3, ($s3)			# Loads byte into $s3
        beq $s3, $s1, co2Increment	# Increases counter if we find char
        beqz $s3, co2End		# Ends loop if we reach null terminator 
        
        co2ContinueLoop:
        addi $s2, $s2, 1		# Increments byte index
        j co2Loop			# Loop through the char array
    
co2Increment:
    addi $s4, $s4, 1			# Increments number of occurrences
    j co2ContinueLoop			# Continue char loop
    
co2End:
    move $v0, $s4			# Returns number of occurrences for that char
    
    lw $s0, 0($sp)			# Restore original value of $s0
    lw $s1, 4($sp)			# Restore original value of $s1
    lw $s2, 8($sp)			# Restore original value of $s2    
    lw $s3, 12($sp)			# Restore original value of $s3
    lw $s4, 16($sp)
    addi $sp, $sp, 20			# Deallocate 4 bytes of memory in stack frame
    
    jr $ra				# End function
