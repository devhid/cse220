

.data
.align 2
	numargs: .word 0
	integer: .word 0
	fromBase: .word 0
	toBase: .word 0
	
	error_message: .asciiz "ERROR\n"
	
	# buffer is 32 space characters
	buffer: .ascii "                                "
	newline: .asciiz "\n"

# Helper macro for grabbing command line arguments
.macro load_args
	sw $a0, numargs
	lw $t0, 0($a1) # Load argument from 0th byte into $t0
	sw $t0, integer # Store value in $t0 in integer address
	lw $t0, 4($a1) # Load argument from 4th byte into $t0
	sw $t0, fromBase # Store value in $t0 in fromBase address
	lw $t0, 8($a1) # Load argument from 8th byte into $t0
	sw $t0, toBase # Store value in $t0 in toBase address
.end_macro

.text
.globl main
main:
	load_args()
	
	# throw error if argument length != 3
	bne $a0, 3, exit_error

validate_bases: # checks if toBase and fromBase are in the range [50, 57] U [65, 70] and are 1 character in length	
	# load fromBase and toBase words
	lw $s1, fromBase
	lw $s2, toBase
	
	# throw error if toBase or fromBase character length != 1
	lb $t0, 1($s1)
	bnez $t0, exit_error
	
	lb $t0, 1($s2)
	bnez $t0, exit_error

	# load fromBase and toBase bytes
	lb $s1, 0($s1)
	lb $s2, 0($s2)

	# throw error if toBase or fromBase < 50
	blt $s1, 50, exit_error
	blt $s2, 50, exit_error
	
	# throw error if toBase or fromBase > 70
	bgt $s1 70, exit_error
	bgt $s2, 70, exit_error
	
	# check if fromBase <= 57 or >= 65
	ble $s1, 57, convert_fb_num
	bge $s1, 65, convert_fb_letter

	convert_fb_num: # convert fromBase to number between [2-9]
		addi $s1, $s1, -48 
		j check_toBase
		
	convert_fb_letter: # convert fromBase to number between [10-15]
		addi $s1, $s1, -55 
		j check_toBase
		
	j exit_error
	
	check_toBase: # check if toBase <= 57 or >= 65
	ble $s2, 57, convert_tb_num
	bge $s2, 65, convert_tb_letter
	
	convert_tb_num: # convert toBase to number between [2-9]
		addi $s2, $s2, -48
		j validate_integer
		
	convert_tb_letter: # convert toBase to number between [10-15]
		addi $s2, $s2, -55 
		j validate_integer
		
	j exit_error

validate_integer:
	lw $t0, integer # original copy	
	lw $s0, integer # new copy where the actual integer will be stored
	li $t1, 0 # index that will grab the next bit / will also serve as the length of the integer
	li $t2, 0 # stores byte address for word containing ascii values
	li $t3, 0 # stores byte address for word to contain converted integers
	
	while: 
		# load the next byte
		add $t2, $t1, $t0
		lb $t2, 0($t2)
		
		# if next byte = 0, go on to converting to base 10
		beqz $t2, convert_base_10
		
		# throw error if byte is < 48 or > 70
		blt $t2, 48, exit_error
		bgt $t2, 70, exit_error
		
		# Check if byte is <= 57 or >= 65
		ble $t2, 57, convert_int_num
		bge $t2, 65, convert_int_letter
		
		convert_int_num:
			addi $t2, $t2, -48
			bge $t2, $s1, exit_error # throw error if integer is >= fromBase
			j store_integer
			
		convert_int_letter:
			addi $t2, $t2, -55
			bge $t2, $s1, exit_error # throw error if integer is >= fromBase
			
		store_integer: 
			add $t3, $s0, $t1 # get next byte address
			sb $t2, ($t3) # store byte into new word
			addi $t1, $t1, 1 # increment index by 1
			
			j while
		
	# At this point, $s0 = integer (reversed), $s1 = fromBase, $s2 = toBase, $t0 = length of integer
	
convert_base_10:
	# decimal = digit * fromBase + next digit
	move $s3, $t1 # move length of integer from $t1 to $s3
	
	li $t0, 0 # total
	li $t1, 0 # index for next byte
	li $t2, 0 # stores current byte address
	li $t3, 0 # stores next byte

	base_10_loop:
		mult $t0, $s1 # multiply byte by fromBase
		mflo $t0 # move the result of multiplication into $t0
		
		add $t2, $t1, $s0 # get next byte address
		lb $t3, 0($t2) # load next byte

		add $t0, $t0, $t3 # $t0 = (digit * fromBase + next digit)
		
		addi $t1, $t1, 1 # increment byte index
		beq $t1, $s3 convert_toBase # convert number to "toBase" when index = length (end of integer)
		j base_10_loop
	
convert_toBase:
	move $s0, $t0 # store the integer back into $s0
	la $t0, buffer # load the address of the buffer into $t0
	addi $t0, $t0, 31 # add 31 to the buffer address
	
	li $t1, 0 # remainder
	loop:
		div $s0, $s2 # divide integer by toBase
		mflo $s0 # store quotient in $s0
		mfhi $t1 # stores remainder in $t1
		
		ble, $t1, 9, ascii_48 # convert number to ascii by adding 48 if number is <= 9
		addi $t1, $t1, 55 # convert number to ascii by adding 55 if number is > 9
		
		continue:
		sb $t1, ($t0) # store ascii character at buffer address
		
		beqz $s0, exit_success # once quotient is 0, print out the integer in the new base
		addi $t0, $t0, -1 # decrement the buffer address by 1
		j loop
		
		ascii_48: addi, $t1, $t1, 48
			j continue
		
exit: # terminate the program
	li $v0, 10
	syscall	
	
exit_error: # terminate the program with an error message
	li $v0, 4
	la $a0, error_message # stores error message in $a0 (argument)
	syscall

	j exit 

exit_success: # terminate the program after printing the integer in the new base
	li $v0 4
	la $a0, buffer
	syscall
	
	j exit
