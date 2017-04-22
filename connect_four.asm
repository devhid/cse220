##############################################################
# DO NOT DECLARE A .DATA SECTION IN YOUR HW. IT IS NOT NEEDED
##############################################################

.text

##############################
# Part I FUNCTIONS
##############################

set_slot:
# load arguments 5, 6, and 7 from stack
    lw $t0, 0($sp)							# $t0 = int col
    lw $t1, 4($sp)							# $t1 = char c
    lw $t2, 8($sp)							# $t2 = int turn_number

# preserve original values in $s registers
    addi $sp, $sp, -16
    sw $s0, 0($sp)
    sw $s1, 4($sp)
    sw $s2, 8($sp)
    sw $s3, 12($sp)
    
# load arguments 1-4 into $s registers
    move $s0, $a0								# $s0 = slot[][] board
    move $s1, $a1								# $s1 = int num_rows
    move $s2, $a2								# $s2 = int num_cols
    move $s3, $a3								# $s3 = int row
 
# throw error if num_rows or num_cols is < 0       
    bltz $s1, ss_error
    bltz $s2, ss_error

# throw error if row < 0 or row > num_rows - 1     
    bltz $s3, ss_error
    addi $s1, $s1, -1
    bgt $s3, $s1, ss_error
    
# throw error if col < 0 or col > num_cols - 1
    bltz $t0, ss_error
    addi $s1, $s2, -1    
    bgt $t0, $s1, ss_error

# throw error if 'c'(89) isn't 'Y'(82), 'R' or '.'(46)
    ss_check_yellow: 
    bne $t1, 89, ss_check_red
    j ss_check_turn_num
    
    ss_check_red:    
    bne $t1, 82, ss_check_period
    j ss_check_turn_num
    
    ss_check_period: 
    bne $t1, 46, ss_error
    
# throw error if turn_num is < 0 or > 255                                                            
    ss_check_turn_num: 
    bltz $t2, ss_error
    bgt $t2, 255, ss_error
    
# calculate address of where the slot should be inserted
    sll $s1, $s2, 1							# $s1 = num_cols * 2 (size of object)
    mul $s1, $s1, $s3							# $s1 = row_size * i
    sll $t0, $t0, 1							# $t0 = j * 2 (size of object)
    add $s1, $s1, $t0							# $s1 = (row_size * i) + (2 * j) 
    add $s0, $s0, $s1     						# $s0 = base_address + (row_size * i) + (2 * j)

# store c and turn_number at address
    sb $t2, ($s0)							# stores turn_number in lower byte
    sb $t1, 1($s0)    							# stores c in upper byte

# jump to end with success
    j ss_end
    
ss_error:
# return -1 for error
    li $v0, -1
    j ss_restore
    
ss_end: 
# return 0 for success
    li $v0, 0
    j ss_restore
    
ss_restore:
# restore original values of $s registers
    lw $s0, 0($sp)
    lw $s1, 4($sp)
    lw $s2, 8($sp)
    lw $s3, 12($sp)
    addi $sp, $sp, 16

    jr $ra

get_slot:
# load argument 5 from stack
    lw $t0, 0($sp)							# $t0 = int col

# preserve original values in $s registers
    addi $sp, $sp, -16
    sw $s0, 0($sp)
    sw $s1, 4($sp)
    sw $s2, 8($sp)
    sw $s3, 12($sp)
    
# load arguments 1-4 into $s registers
    move $s0, $a0
    move $s1, $a1
    move $s2, $a2
    move $s3, $a3
 
# throw error if num_rows or num_cols is < 0       
    bltz $s1, gs_error
    bltz $s2, gs_error

# throw error if row < 0 or row > num_rows - 1     
    bltz $s3, gs_error
    addi $s1, $s1, -1
    bgt $s3, $s1, gs_error
    
# throw error if col < 0 or col > num_cols - 1
    bltz $t0, gs_error
    addi $s1, $s2, -1    
    bgt $t0, $s1, gs_error
    
# calculate address of where the slot should be inserted
    sll $s1, $s2, 1							# $s1 = num_cols * 2 (size of object)
    mul $s1, $s1, $s3							# $s1 = row_size * i
    sll $t0, $t0, 1							# $t0 = j * 2 (size of object)
    add $s1, $s1, $t0							# $s1 = (row_size * i) + (2 * j) 
    add $s0, $s0, $s1     						# $s0 = base_address + (row_size * i) + (2 * j)

# store c and turn_number at address
    lbu $s1, ($s0)							# stores turn_number in lower byte
    lb $s2, 1($s0)    							# stores c in upper byte

# jump to end with success
    j gs_end

gs_error:
    li $v0, -1
    li $v1, -1
    j gs_restore
    
gs_end:
# return (piece, turn) at address
    move $v0, $s2
    move $v1, $s1
    j gs_restore


gs_restore:
# restore original value of $s registers
   lw $s0, 0($sp)
   lw $s1, 4($sp)
   lw $s2, 8($sp)
   lw $s3, 12($sp)
   addi $sp, $sp, 16
   
   jr $ra

clear_board:
# preserve original values of $s registers
    addi $sp, $sp, -28
    sw $s0, 0($sp)
    sw $s1, 4($sp)
    sw $s2, 8($sp)
    sw $s3, 12($sp)
    sw $s4, 16($sp)
    sw $s5, 20($sp)
    sw $s6, 24($sp)
    
# load arguments 1, 2, and 3
    move $s0, $a0							# $s0 = slot[][] board
    move $s1, $a1							# $s1 = int num_rows
    move $s2, $a2							# $s2 = int num_cols
    
# throw error if num_rows < 0 or num_cols < 0
    bltz $s1, cb_error
    bltz $s2, cb_error
        
# loop through board and set object to '.' and turn_number to 0
    li $s3, 0								# row counter
    li $s4, 0								# col counter
    li $s5, 46								# char = '.'
    li $s6, 0								# turn_number = 0
    									
    cb_row_loop:
        beq $s3, $s1, cb_column_loop					# check next column when you reach end of row
        
        # load arguments 1-4
        move $a0, $s0
        move $a1, $s1
        move $a2, $s2
        move $a3, $s3
        
        # load arguments 5-7 and save return address
        addi $sp, $sp, -16
        sw $s4, 0($sp)
        sw $s5, 4($sp)
        sw $s6, 8($sp)
     
        sw $ra, 12($sp)
        
        jal set_slot
        
   	lw $ra, 12($sp)
   	
   	addi $sp, $sp, 16
   	
   	addi $s3, $s3, 1						# increment row counter
        j cb_row_loop
   
   cb_column_loop:
       addi $s4, $s4, 1							# increment column counter
       beq $s4, $s2, cb_end						# end loop after last column
       li $s3, 0							# reset row counter
       
       j cb_row_loop
       
cb_error:
# return -1 because of error        
    li $v0, -1
    j cb_restore
                                
cb_end:    
# return 0 because of success
    li $v0, 0
    j cb_restore
    
cb_restore:
# restore original values of $s registers
    lw $s0, 0($sp)
    lw $s1, 4($sp)
    lw $s2, 8($sp)
    lw $s3, 12($sp)
    lw $s4, 16($sp)
    lw $s5, 20($sp)
    lw $s6, 24($sp)
    addi $sp, $sp, 28
    jr $ra


##############################
# Part II FUNCTIONS
##############################

load_board:
# preserve original values in $s registers
    addi $sp, $sp, -32
    sw $s0, 0($sp)
    sw $s1, 4($sp) 
    sw $s2, 8($sp)
    sw $s3, 12($sp)
    sw $s4, 16($sp)
    sw $s5, 20($sp)
    sw $s6, 24($sp)
    sw $s7, 28($sp)

# load arguments into $s registers       
    move $s0, $a0							# $s0 = slot[][] baord
    move $s4, $a1							# $s1 = char[] filename
    
# open the file
    move $a0, $s4
    li $a1, 0
    li $v0, 13
    syscall

# throw error if file opening failed
    bltz $v0, lb_error

# store file descriptor in $t0
    move $s7, $v0

# read file to get the num_rows and num_cols
    addi $sp, $sp, -5
    
    move $a0, $s7
    move $a1, $sp
    li $a2, 5
    li $v0, 14
    syscall
    
    # throw error if file reading failed
    bltz $v0, lb_error_5
    
    # get the num_rows
    lb $s1, 0($sp)
    andi $s1, $s1, 0x0F
    li $s2, 10
    mul $s1, $s1, $s2
    
    lb $s2, 1($sp)          
    andi $s2, $s2, 0x0F
    
    add $s1, $s1, $s2 
    
    # get the num_cols
    lb $s2, 2($sp)
    andi $s2, $s2, 0x0F
    li $s3, 10
    mul $s2, $s2, $s3
    
    lb $s3, 3($sp)          
    andi $s3, $s3, 0x0F
    
    add $s2, $s2, $s3
    
    # reduce the stack space
    addi $sp, $sp, 5
    
# throw error if num_rows or num_cols = 0
    beqz $s1, lb_error
    beqz $s2, lb_error
    
# read the file and setup the baord        
    move $t0, $s0
    move $t1, $s1
    move $t2, $s2
    
    lb_loop:
        addi $sp, $sp, -9
        
        move $a0, $s7
        move $a1, $sp
        li $a2, 9
        li $v0, 14
        syscall
        
        # throw error if file reading failed
   	bltz $v0, lb_error_9
    
        lb $s0, 0($sp)
        beqz $s0, lb_end
    
	# use bits 0-1 for row
    	lb $s0, 0($sp)
    	andi $s0, $s0, 0x0F
    	li $s6, 10
    	mul $s0, $s0, $s6
    
    	lb $s1, 1($sp)          
    	andi $s1, $s1, 0x0F
    
    	add $s0, $s0, $s1
    	
    		# throw error if row < 0 or row > num_rows - 1
    	bltz $s0, lb_error_9
    	addi $s6, $t1, -1
    	bgt $s0, $s6, lb_error_9
    	
    	move $a3, $s0
    	
	# save all the chars from the current stack offset
    	lb $s0, 2($sp)
    	lb $s1, 3($sp)
    	lb $s2, 4($sp)
    	lb $s3, 5($sp)
    	lb $s4, 6($sp)
    	lb $s5, 7($sp)
    	
        addi $sp, $sp, 9
    	
    	# make space for last 3 arguments + return address
    	addi $sp, $sp, -28
    	
	# use bits 2-3 for col
    	andi $s0, $s0, 0x0F
    	li $s6, 10
    	mul $s0, $s0, $s6
             
    	andi $s1, $s1, 0x0F
    
    	add $s0, $s0, $s1
    	
    		# throw error if col < 0 or col > num_cols - 1
    	bltz $s0, lb_error_28
    	addi $s6, $t2, -1
    	bgt $s0, $s6, lb_error_28
    	
    	sw $s0, 0($sp)
    	
	# use bit 4 for piece
        sw $s2, 4($sp) 
	
	# use bits 5-7 for turn_number
	andi $s3, $s3, 0x0F
    	li $s6, 100
    	mul $s3, $s3, $s6
             
    	andi $s4, $s4, 0x0F
    	li $s6, 10
    	mul $s4, $s4, $s6
    	
    	andi $s5, $s5, 0x0F
    
    	add $s3, $s3, $s4
    	add $s3, $s3, $s5
    	
    	bltz $s3, lb_error_28
   	bgt $s3, 255, lb_error_28
    	
    	sw $s3, 8($sp)
    
    	# load arguments 1-3
    	move $a0, $t0
    	move $a1, $t1
    	move $a2, $t2
    	
    	# save return address
    	sw $t0, 12($sp)
    	sw $t1, 16($sp) 
	sw $t2, 20($sp)
  
    	sw $ra, 24($sp)
    	
    	jal set_slot
    	
    	lw $ra, 24($sp)
    	
    	lw $t2, 20($sp)
    	lw $t1, 16($sp)
    	lw $t0, 12($sp)    	
    	
    	addi $sp, $sp, 28
   
        j lb_loop          
       
    j lb_end

lb_error_5:
    addi $sp, $sp, 5
    j lb_error

lb_error_9:
    addi $sp, $sp, 9
    j lb_error

lb_error_28:
    addi $sp, $sp, 28
    j lb_error                      
            
lb_error:
    li $v0, -1
    li $v1, -1
    j lb_restore
    
lb_end:
# decrement stack by 9 because we added by 9 when opening file
    addi $sp, $sp, 9

# close the file    
    move $a0, $s7
    li $v0, 16
    syscall  
    
    move $v0, $t1
    move $v1, $t2
    j lb_restore
    
lb_restore:
# restore original values of $s registers
    lw $s0, 0($sp)
    lw $s1, 4($sp)
    lw $s2, 8($sp)
    lw $s3, 12($sp)
    lw $s4, 16($sp)
    lw $s5, 20($sp)
    lw $s6, 24($sp)
    lw $s7, 28($sp)

    addi $sp, $sp, 32
    
    jr $ra

save_board:
# preserve original values in $s registers
    addi $sp, $sp, -24
    sw $s0, 0($sp)
    sw $s1, 4($sp)
    sw $s3, 8($sp)
    sw $s4, 12($sp)
    sw $s5, 16($sp)
    sw $s6, 20($sp)
    
# load arguments 1-4
    move $s0, $a0							# $s0 = slot[][] board
    move $s1, $a1							# $s1 = int num_rows
    move $s2, $a2							# $s2 = int num_cols
    move $s3, $a3							# $s3 = char[] filename
    
# throw error if num_rows or num_cols < 0
    bltz $s1, sb_error
    bltz $s2, sb_error
    
# open file
    move $a0, $s3
    li $a1, 1
    li $v0, 13
    syscall

    # throw error if file opening failed    
    bltz $v0, sb_error
    move $s7, $v0
    
# get first line information
sb_get_row:
    li $t0, 10
    div $s1, $t0
    mflo $s4
    addi $s4, $s4, 48
    mfhi $s5
    addi $s5, $s5, 48
        
sb_write_row:
    addi $sp, $sp, -2
    sb $s4, 0($sp)
    sb $s5, 1($sp)
    
    li $v0, 15
    move $a0, $s7
    move $a1, $sp
    li $a2, 2
    syscall
    
    addi $sp, $sp, 2
    bltz $v0, sb_error
    
    j sb_get_column

sb_get_column:  
    li $t0, 10
    div $s2, $t0
    mflo $s4
    addi $s4, $s4, 48
    mfhi $s5
    addi $s5, $s5, 48

sb_write_column:
    addi $sp, $sp, -3
    sb $s4, 0($sp)
    sb $s5, 1($sp)
    
    # write newline at end
    li $t0, '\n'
    sb $t0, 2($sp)
    
    li $v0, 15
    move $a0, $s7
    move $a1, $sp
    li $a2, 3
    syscall
    
    addi $sp, $sp, 3
    bltz $v0, sb_error

sb_each_slot: # you can use $s5, $s6
    li $s3, 0								# row counter
    li $s4, 0								# column counter
    li $t1, 0								# pieces on the board
    
    sb_column_loop:
        beq $s4, $s2, sb_row_loop
        
        move $a0, $s0
        move $a1, $s1
        move $a2, $s2
        move $a3, $s3
        
        addi $sp, $sp, -12
        sw $s4, 0($sp)
        sw $t1, 4($sp)
        sw $ra, 8($sp)
        
        jal get_slot
        
        lw $t1, 4($sp)
        lw $ra, 8($sp)
        addi $sp, $sp, 12
        
        beq $v0, 46, sb_skip_write
        
        addi $sp, $sp, -9
        
	sb_convert_row:
	li $t0, 10
    	div $s3, $t0
    	mflo $s6
    	addi $s6, $s6, 48
   	mfhi $s5
   	addi $s5, $s5, 48
   	
   	sb $s6, 0($sp)
   	sb $s5, 1($sp)
   	
	sb_convert_column:
	li $t0, 10
    	div $s4, $t0
    	mflo $s6
    	addi $s6, $s6, 48
   	mfhi $s5
   	addi $s5, $s5, 48
   	
   	sb $s6, 2($sp)
   	sb $s5, 3($sp)
        
        sb_write_piece:
        sb $v0, 4($sp)       
        
        sb_write_turn_num:
        li $t0, 100
        div $v1, $t0
        mflo $s5
        addi $s5, $s5, 48
        sb $s5, 5($sp)
        mfhi $s5
        
        li $t0, 10
        div $s5, $t0
        mflo $s5
        addi $s5, $s5, 48
        sb $s5 6($sp)
        
        mfhi $s5
        addi $s5, $s5, 48
        sb $s5 7($sp)
        
        sb_write_newline:
        li $s5, '\n'
        sb $s5 8($sp)
        
        li $v0, 15
        move $a0, $s7
        move $a1, $sp
        li $a2, 9
        syscall
        
	addi $sp, $sp, 9
        bltz $v0, sb_error
        
        addi $t1, $t1, 1
        
        sb_skip_write:
        addi $s4, $s4, 1
        j sb_column_loop
                
    sb_row_loop:
        addi $s3, $s3, 1
        beq $s3, $s1, sb_end
        li $s4, 0
        
        j sb_column_loop
             
sb_error:
# return -1 if error occurs
    li $v0, -1
    j sb_restore
    
sb_end:
    # close the file
    li $v0, 16
    move $a0, $s7
    syscall
    
    move $v0, $t1
    j sb_restore
    
sb_restore:
# restore original values of $s registers
    lw $s0, 0($sp)
    lw $s1, 4($sp)
    lw $s3, 8($sp)
    lw $s4, 12($sp)
    lw $s5, 16($sp)
    lw $s6, 20($sp)    
    addi $sp, $sp, -24
        
    jr $ra

validate_board:
    # Define your code here
    ###########################################
    # DELETE THIS CODE.
    li $v0, -200
    ##########################################
    jr $ra

##############################
# Part III FUNCTIONS
##############################

display_board:
# preserve original value of $s registers
    addi $sp, $sp, -20
    sw $s0, 0($sp)
    sw $s1, 4($sp)
    sw $s2, 8($sp)
    sw $s3, 12($sp)
    sw $s4, 16($sp)
    
# load arguments
    move $s0, $a0							# $s0 = slot[][] board
    move $s1, $a1							# $s1 = int num_rows
    move $s2, $a2							# $s2 = int num_cols
    
    bltz $s1, db_error
    bltz $s2, db_error
    
    addi $s3, $s1, -1							# row counter
    li $s4, 0								# column counter
    
    db_column_loop:
        beq $s4, $s2, db_row_loop					# print next row when current row is finished
        
        # load arguments 1-4
        move $a0, $s0
        move $a1, $s1
        move $a2, $a2
        move $a3, $s3
        
        # load argument 5
        addi $sp, $sp, -8
        sw $s4, 0($sp)
        sw $ra, 4($sp)
        
        jal get_slot
        
        lw $ra, 4($sp)
        addi $sp, $sp, 8
        
        # print the piece located at that spot
        move $a0, $v0
        li $v0, 11
        syscall
        
        addi $s4, $s4, 1						# increment row counter
        j db_column_loop
    
    db_row_loop:
        beqz $s3, db_end						# end loop when column = num_columns
        addi $s3, $s3, -1						# increment column counter
        li $s4, 0							# reset row counter
        
        li $v0, 11							# print character mode
        li $a0, 10							# store newline (\n) as character
        syscall
        
        j db_column_loop
        
db_error:
    li $v0, -1
    j db_restore
        
db_end:
    li $v0, 0
    j db_restore
    
db_restore:
    lw $s0, 0($sp)
    lw $s1, 4($sp)
    lw $s2, 8($sp)
    lw $s3, 12($sp)
    lw $s4, 16($sp)
    addi $sp, $sp, 20
    
    jr $ra

drop_piece:
# load arguments 5 and 6
    lw $t0, 0($sp)							# $t0 = char piece
    lw $t1, 4($sp)							# $t1 = int turn_number
    
# preserve original values of $s registers
    addi $sp, $sp, -16
    sw $s0, 0($sp)
    sw $s1, 4($sp)
    sw $s2, 8($sp)
    sw $s3, 12($sp)

# load arguments 1-4    
    move $s0, $a0							# $s0 = slot[][] board
    move $s1, $a1							# $s1 = int num_rows
    move $s2, $a2							# $s2 = int num_cols
    move $s3, $a3							# $s3 = in col
    
# throw error if num_rows < 0 or num_cols < 0
    bltz $s1, dp_error
    bltz $s2, dp_error

# throw error if col < 0 or col > num_cols - 1
    bltz $s3, dp_error
    addi $s4, $s2, -1    
    bgt $s3, $s4, dp_error

# throw error if 'c' isn't 'Y'(89) or 'R'(82)
    dp_check_yellow: 
    bne $t0, 89, dp_check_red
    j dp_check_turn_num
    
    dp_check_red:    
    bne $t0, 82, dp_error
    
# throw error if turn_num is > 255                                                            
    dp_check_turn_num: 
    bgt $t1, 255, dp_error    

# throw error if column is full already
    move $a0, $s0
    move $a1, $s1
    move $a2, $s2
    addi $a3, $s1, -1
    
    addi $sp, $sp, -16
    sw $s3, 0($sp)
    sw $t0, 4($sp)
    sw $t1, 8($sp)
    sw $ra, 12($sp)
    
    jal get_slot
    
    lw $ra, 12($sp)
    lw $t1, 8($sp)
    lw $t0, 4($sp)
    addi $sp, $sp, 16
    
    bne $v0, 46, dp_error

# initialize loop variables        
    addi $s4, $s1, -1						# row counter, $s4 - num_rows - 1
    
    dp_loop:
        move $a0, $s0
    	move $a1, $s1
    	move $a2, $s2
    	addi $a3, $s4, -1
    
    	addi $sp, $sp, -16
    	sw $s3, 0($sp)
    	sw $t0, 4($sp)
    	sw $t1, 8($sp)
    	sw $ra, 12($sp)
    
    	jal get_slot
    
    	lw $ra, 12($sp)
    	lw $t1, 8($sp)
    	lw $t0, 4($sp)
    	addi $sp, $sp, 16  
    	
    	beqz $s4, dp_end
    	bne $v0, 46, dp_end
    	
    	addi $s4, $s4, -1
    	j dp_loop   

dp_error:
    li $v0, -1
    j dp_restore

dp_end:
    move $a0, $s0
    move $a1, $s1
    move $a2, $s2
    move $a3, $s4
    
    addi $sp, $sp, -16
    sw $s3, 0($sp)
    sw $t0, 4($sp)
    sw $t1, 8($sp)
    sw $ra, 12($sp)
    
    jal set_slot
    
    lw $ra, 12($sp)
    addi $sp, $sp, 16    
    
    li $v0, 0
    j dp_restore
    
dp_restore:
    lw $s0, 0($sp)
    lw $s1, 4($sp)
    lw $s2, 8($sp)
    lw $s3, 12($sp) 
    addi $sp, $sp, -16
    
    jr $ra

undo_piece:
# preserve original values in $s registers
    addi $sp, $sp, -28
    sw $s0, 0($sp)
    sw $s1, 4($sp)
    sw $s2, 8($sp)
    sw $s3, 12($sp)
    sw $s4, 16($sp)
    sw $s5, 20($sp)
    sw $s6, 24($sp)

# load arguments         
    move $s0, $a0							# $s0 = slot[][] board
    move $s1, $a1							# $s1 = int num_rows
    move $s2, $a2							# $s2 = int num_cols
    
# throw error if num_rows < 0 or num_cols < 0
    bltz $s1, up_error
    bltz $s2, up_error
    
    li $s3, 0								# column counter
    li $s4, 0								# row counter
    li $s5, 46								# max char
    li $s6, 0								# max turn_number
    
    up_column_loop:
        beq $s3, $s2, up_row_loop
        
        move $a0, $s0
        move $a1, $s1
        move $a2, $s2
        move $a3, $s4
        
        addi $sp, $sp, -16
        sw $s3, 0($sp)
        sw $t2, 4($sp)
        sw $t3, 8($sp)
        sw $ra, 12($sp)
        
        jal get_slot
        
        lw $ra, 12($sp)
        lw $t3, 8($sp)
        lw $t2, 4($sp)
        addi $sp, $sp, 16
        
        ble $v1, $s6, up_column_loop_cont
        move $s5, $v0
        move $s6, $v1
        
        # store row and col of max
        move $t2, $s3
        move $t3, $s4 
        
        up_column_loop_cont:
        addi $s3, $s3, 1
        j up_column_loop
        
    up_row_loop:
        addi $s4, $s4, 1
        beq $s4, $s1, up_end
        li $s3, 0
        j up_column_loop
    
up_error:
    li $v0, 46
    li $v1, -1
    j up_restore

up_end:
    beq $s5, 46, up_error
    
    move $a0, $s0
    move $a1, $s1
    move $a2, $s2
    move $a3, $t3
    
    li $t0, 46
    li $t1, 0
    addi $sp, $sp -16
    sw $t2, 0($sp)
    sw $t0, 4($sp)
    sw $t1, 8($sp)
    sw $ra, 12($sp)
    
    jal set_slot
    
    lw $ra, 12($sp)
    addi $sp, $sp, 16
    
    move $v0, $s5
    move $v1, $s6
    
    j up_restore

up_restore:    
    lw $s0, 0($sp)
    lw $s1, 4($sp)
    lw $s2, 8($sp)
    lw $s3, 12($sp)
    lw $s4, 16($sp)    
    lw $s5, 20($sp)
    lw $s6, 24($sp)
    addi $sp, $sp, 28

    jr $ra

check_winner:
# preserve original values in $s registers
    addi $sp, $sp, -20
    sw $s0, 0($sp)
    sw $s1, 4($sp)
    sw $s2, 8($sp)
    sw $s3, 12($sp)
    
# load arguments
    move $s0, $a0							# $s0 = slot[][] board
    move $s1, $a1							# $s1 = int num_rows
    move $s2, $a2 							# $s2 = int num_cols
    
    addi $s5, $s2, -4							# $s5 = num_cols - 4
    li $s3, 0								# column counter
    li $s4, 0								# row counter
    cw_column_loop_hor:
        bgt $s3, $s5, cw_row_loop_hor

        # get 1st piece        
        move $a0, $s0
        move $a1, $s1
        move $a2, $s2
        move $a3, $s3
        
        addi $sp, $sp -8
        sw $s4, 0($sp)
        sw $ra, 4($sp)
        
        jal get_slot
        
        lw $ra, 4($sp)
        addi $sp, $sp, 8
        
        beq $v0, 46, cw_column_loop_hor_cont
        move $t0, $v0

        # get 2nd piece        
        move $a0, $s0
        move $a1, $s1
        move $a2, $s2
        move $a3, $s3
        
        addi $t4, $s4, 1
        
        addi $sp, $sp -12
        sw $t4, 0($sp)
        sw $t0, 4($sp)
        sw $ra, 8($sp)
        
        jal get_slot
        
        lw $ra, 8($sp)
        lw $t0, 4($sp)
        addi $sp, $sp, 12
        
        beq $v0, 46, cw_column_loop_hor_cont
        move $t1, $v0
        
        # get 3rd piece        
        move $a0, $s0
        move $a1, $s1
        move $a2, $s2
        move $a3, $s3
        
        addi $t4, $s4, 2
        
        addi $sp, $sp -16
        sw $t4, 0($sp)
        sw $t0, 4($sp)
        sw $t1, 8($sp)
        sw $ra, 12($sp)
        
        jal get_slot
        
        lw $ra, 12($sp)
        lw $t1, 8($sp)
        lw $t0, 4($sp)
        
        addi $sp, $sp, 16
        
        beq $v0, 46, cw_column_loop_hor_cont
        move $t2, $v0
        
        # get 4th piece        
        move $a0, $s0
        move $a1, $s1
        move $a2, $s2
        move $a3, $s3
        
        addi $t4, $s4, 3
        
        addi $sp, $sp -20
        sw $t4, 0($sp)
        sw $t0, 4($sp)
        sw $t1, 8($sp)
        sw $t2, 12($sp)
        sw $ra, 16($sp)
        
        jal get_slot
        
        lw $ra, 16($sp)
        lw $t2, 12($sp)
        lw $t1, 8($sp)
        lw $t0, 4($sp)
        
        addi $sp, $sp, 20

        beq $v0, 46, cw_column_loop_hor_cont     
        move $t3, $v0
        
        bne $t0, $t1, cw_column_loop_hor_cont 
        bne $t1, $t2, cw_column_loop_hor_cont
        bne $t2, $t3, cw_column_loop_hor_cont
        move $v0, $t0
        j cw_end
        
        cw_column_loop_hor_cont:
        addi $s3, $s3, 1
        j cw_column_loop_hor
      
    cw_row_loop_hor:
        addi $s4, $s4, 1
        beq $s4, $s1, cw_vertical_check
        li $s3, 0
        
        j cw_column_loop_hor

cw_vertical_check:
    addi $s5, $s1, -4							# $s5 = num_rows - 4
    li $s3, 0								# row counter
    li $s4, 0                						# column counter
    cw_row_loop_vert:
        bgt $s3, $s5, cw_column_loop_vert
        
 	# get 1st piece        
        move $a0, $s0
        move $a1, $s1
        move $a2, $s2
        addi $a3, $s3, 0
        
        addi $sp, $sp -8
        sw $s4, 0($sp)
        sw $ra, 4($sp)
        
        jal get_slot
        
        lw $ra, 4($sp)
        addi $sp, $sp, 8
        
        beq $v0, 46, cw_row_loop_vert_cont
        move $t0, $v0
        
 	# get 2nd piece        
        move $a0, $s0
        move $a1, $s1
        move $a2, $s2
        addi $a3, $s3, 1
        
        addi $sp, $sp -12
        sw $s4, 0($sp)
        sw $t0, 4($sp)
        sw $ra, 8($sp)
        
        jal get_slot
        
        lw $ra, 8($sp)
        lw $t0, 4($sp)
        
        addi $sp, $sp, 12
        
        beq $v0, 46, cw_row_loop_vert_cont
        move $t1, $v0
        
 	# get 3rd piece        
        move $a0, $s0
        move $a1, $s1
        move $a2, $s2
        addi $a3, $s3, 2
        
        addi $sp, $sp -16
        sw $s4, 0($sp)
        sw $t0, 4($sp)
        sw $t1, 8($sp)
        sw $ra, 12($sp)
        
        jal get_slot
        
        lw $ra, 12($sp)
        lw $t1, 8($sp)
        lw $t0, 4($sp)
        addi $sp, $sp, 16
        
        beq $v0, 46, cw_row_loop_vert_cont
        move $t2, $v0
        
 	# get 4th piece        
        move $a0, $s0
        move $a1, $s1
        move $a2, $s2
        addi $a3, $s3, 3
        
        addi $sp, $sp -20
        sw $s4, 0($sp)
        sw $t0, 4($sp)
        sw $t1, 8($sp)
        sw $t2, 12($sp)
        sw $ra, 16($sp)
        
        jal get_slot
        
        lw $ra, 16($sp)
        lw $t2, 12($sp)
        lw $t1, 8($sp)
        lw $t0, 4($sp)
        addi $sp, $sp, 20
        
        beq $v0, 46, cw_row_loop_vert_cont
        move $t3, $v0
        
        bne $t0, $t1, cw_row_loop_vert_cont
        bne $t1, $t2, cw_row_loop_vert_cont
        bne $t2, $t3, cw_row_loop_vert_cont
        move $v0, $t0
        j cw_end
        
        cw_row_loop_vert_cont:
        addi $s3, $s3, 1
        
        j cw_row_loop_vert
      
    cw_column_loop_vert:
        addi $s4, $s4, 1
        beq $s4, $s2, cw_no_winner
        li $s3, 0
        
        j cw_row_loop_vert  
    
cw_no_winner:
# return '.' if there was no winner
    li $v0, 46
    j cw_restore
    
cw_end:
    j cw_restore

cw_restore:
    lw $s0, 0($sp)
    lw $s1, 4($sp)
    lw $s2, 8($sp)
    lw $s3, 12($sp)    
    addi $sp, $sp, 20
    
    jr $ra

##############################
# EXTRA CREDIT FUNCTION
##############################


check_diagonal_winner:
    # Define your code here
    ###########################################
    # DELETE THIS CODE.
    li $v0, -200
    ##########################################
    jr $ra



##############################################################
# DO NOT DECLARE A .DATA SECTION IN YOUR HW. IT IS NOT NEEDED
##############################################################
