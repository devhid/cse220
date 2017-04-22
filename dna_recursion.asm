

.text

.macro call_func1(%label, %arg0)
    addi $sp, $sp, -8
    sw $a0, 0($sp)
    sw $ra, 4($sp)

    move $a0, %arg0
    jal %label

    lw $ra, 4($sp)
    lw $a0, 0($sp)
    addi $sp, $sp, 8
.end_macro

.macro call_func2(%label, %arg0, %arg1)
    addi $sp, $sp, -12
    sw $a0, 0($sp)
    sw $a1, 4($sp)
    sw $ra, 8($sp)

    move $a0, %arg0
    move $a1, %arg1
    jal %label

    lw $ra, 8($sp)
    lw $a1, 4($sp)
    lw $a0, 0($sp)
    addi $sp, $sp, 12
.end_macro


match_glob:
    
    call_func1(only_wildcard, $a1)
    bnez $v0, mg_seq_pat_equal_uc

    call_func1(length, $a0)
    move $v1, $v0
    li $v0, 1
    jr $ra

    mg_seq_pat_equal_uc:
        call_func2(array_equal, $a0, $a1)
        bnez $v0, mg_seq_pat_empty
        li $v0, 1
        li $v1, 0
	jr $ra
	
    mg_seq_pat_empty:
        call_func2(length_xor, $a0, $a1)
        beqz $v0, mg_char_equal
        li $v0, 0
        li $v1, 0
        jr $ra
     
    mg_char_equal:
        lb $s0, 0($a0)
        lb $s1, 0($a1)
        
        beq $s0, '*', mg_ce_check_pat

        bge $s0, 97, mg_ce_check_pat
        addi $s0, $s0, 32

        mg_ce_check_pat:
        beq $s1, '*', mg_ce_continue
        bge $s1, 97, mg_ce_continue
        addi $s1, $s1, 32 

        mg_ce_continue:
        bne $s0, $s1, mg_char_glob

        # performs seq.substring(1) and pat.substring(1)
        addi $s0, $a0, 1
        addi $s1, $a1, 1

        addi $sp, $sp, -12
        sw $a0, 0($sp)
        sw $a1, 4($sp)
        sw $ra, 8($sp)

	move $a0, $s0
	move $a1, $s1
        jal match_glob

        lw $ra, 8($sp)
        lw $a1, 4($sp)
        lw $a0, 0($sp)
        addi $sp, $sp, 12
        
        jr $ra
        
    mg_char_glob:
        lb $s0, 0($a1)
        beq $s0, '*', mg_cb_check
        
        li $v0, 0
        li $v1, 0
        jr $ra

        mg_cb_check:
            # pat = pat.substring(1)
            addi $s0, $a1, 1

            addi $sp, $sp, -12
            sw $a0, 0($sp)
            sw $a1, 4($sp)
            sw $ra, 8($sp)

	    move $a1, $s0
            jal match_glob

            lw $ra, 8($sp)
            lw $a1, 4($sp)
            lw $a0, 0($sp)
            addi $sp, $sp, 12

            bne $v0, 1, mg_cb_check_else
            jr $ra
            
            mg_cb_check_else:
                # seq = seq.substring(1)
                addi $s0, $a0, 1

                addi $sp, $sp, -12
                sw $a0, 0($sp)
                sw $a1, 4($sp)
                sw $ra, 8($sp)
		
		        move $a0, $s0
                jal match_glob

                lw $ra, 8($sp)
                lw $a1, 4($sp)
                lw $a0, 0($sp)
                addi $sp, $sp, 12

                addi $v1, $v1, 1
                jr $ra                


save_perm:
    # $a0 = char[] dst
    # $a1 = char[] seq	

    li $t0, 0
    li $t4, 0
    sp_loop:
        add $t1, $t4, $a0
        add $t2, $t0, $a1

        lb $t3, 0($t2)
        sb $t3, 0($t1)

        lb $t3, 1($t2)
        sb $t3, 1($t1)
        
        lb $t3, 2($t2)
        beqz $t3, sp_end
        li $t3, '-'
        sb $t3, 2($t1)
    
        addi $t0, $t0, 2
        addi $t4, $t4, 3
        j sp_loop

    sp_end:
        li $t3, '\n'
        sb $t3, 2($t1)
        
        addi $v0, $t1, 3
        jr $ra

construct_candidates:
    li $t0, 2
    div $a2, $t0
    mfhi $t0
    beqz $t0, cc_even

    addi $t0, $a2, -1
    add $t0, $t0, $a1
    lb $t0, ($t0)

    bne $t0, 'A', cc_check_T
    li $t1, 'T'
    sb $t1, 0($a0)
    li $v0, 1
    jr $ra

    cc_check_T:
    bne $t0, 'T', cc_check_C
    li $t1, 'A'
    sb $t1, 0($a0)
    li $v0, 1
    jr $ra

    cc_check_C:
    bne $t0, 'C', cc_else
    li $t1, 'G'
    sb $t1, 0($a0)
    li $v0, 1
    jr $ra

    cc_else:
    li $t1, 'C'
    sb $t1, 0($a0)
    li $v0, 1
    jr $ra

    cc_even:
        li $t0, 'A'
        sb $t0, 0($a0)

        li $t0, 'C'
        sb $t0, 1($a0)

        li $t0, 'G'
        sb $t0, 2($a0)

        li $t0, 'T'
        sb $t0, 3($a0)

        li $v0, 4
        jr $ra


permutations:
    # $a0 = char[] seq
    # $a1 = int n
    # $a2 = char[] res
    # $a3 = int length

    perm_length_zero:
        bnez $a3, perm_length_odd	# check if length is odd if length != 0
        j perm_return_error		# throw error because length = 0

    perm_length_odd:
        li $t5, 2			# load 2
        div $a3, $t5			# length / 2
        mfhi $t5			# get the remainder of length / 2
        beq $t5, 1, perm_return_error	# if remainder = 1, throw error
        j perm_save			# otherwise, check if n == length

    perm_return_error:
        li $v0, -1
        li $v1, 0
        jr $ra

    perm_save:
    	bne $a1, $a3, perm_else		# if n != length
        
        # add_null
        add $t5, $a0, $a3		# $s0 = seq + length
        sb $0, ($t5)			# store \0 at $s0
	#----------	
	
	addi $sp, $sp, -4		
	sw $ra, 0($sp)			# save $ra
	
	move $a1, $a0			# arg 1 = seq
	move $a0, $a2			# arg 0 = res
	jal save_perm
	
	lw $ra, 0($sp)			# restore $ra
	addi $sp, $sp, 4
	
        move $v1, $v0			# $v1 = next ($v0 contains next because of save_perm call)
        li $v0, 0			# $v0 = 0
        jr $ra
    
    perm_else:
        addi $sp, $sp, -20		# add -20 because I need to save 4 registers (4 bytes) and allocate 4 bytes for char[] candidates
        
        sw $a0, 4($sp)			# preserve seq
        sw $a1, 8($sp)			# preserve n
        sw $a2, 12($sp)			# preserve seq
        sw $ra, 16($sp)			# preserve $ra

        move $a2, $a1			# arg2 = n
        move $a1, $a0			# arg1 = seq
        move $a0, $sp			# arg0 = candidates ($sp)
      
        jal construct_candidates
        
        lw $ra, 16($sp)			# restore $ra
        lw $a2, 12($sp)			# restore res
        lw $a1, 8($sp)			# restore n
        lw $a0, 4($sp)			# restore seq

        move $t5, $v0		# number of candidates 

        li $t6, 0		# loop counter
        perm_else_loop:
            beq $t6, $t5, perm_return
            
            add $t7, $sp, $t6	# address for candidates[i]
            lb $t8, ($t7)       # candidates[i]

            add $t9, $a0, $a1	# address for seq[n]
            sb $t8, ($t9)       # seq[n] = candidates[i]
            
            addi $sp, $sp, -20
            sw $t5, 0($sp)	# preserve number of candidates
            sw $t6, 4($sp)	# preserve counter
            sw $a1, 8($sp)	# preserve n
            sw $a0, 12($sp)
            sw $ra, 16($sp)	# preserve ra

            addi $a1, $a1, 1	# n = n + 1
            jal permutations

	    lw $ra, 16($sp)	# restore ra
	    lw $a0, 12($sp)
            lw $a1, 8($sp)	# restore n
            lw $t6, 4($sp)	# restore counter
            lw $t5, 0($sp)	# restore number of candidates
            addi $sp, $sp, 20

            move $a2, $v1	# res = $v1
            
            addi $t6, $t6, 1	# increment loop counter
            j perm_else_loop

    perm_return:
        addi $sp, $sp, 20
        li $v0, 0		# $v0 = 0
        move $v1, $a2		# $v1 = res
        jr $ra

# HELPER FUNCTIONS FOR MATCH_GLOB #
only_wildcard:
    addi $sp, $sp, -4
    sw $s0, 0($sp)

    # checks if the character is an '*'
    lb $s0, 0($a0)
    bne $s0, '*', ow_false

    # checks if the length of the string is 1
    lb $s0, 1($a0)
    bnez $s0, ow_false

    # return 0 if success
    ow_end:
        li $v0, 0
        j ow_restore

    # return -1 if string doesn't only contain a wildcard
    ow_false:
        li $v0, -1
        j ow_restore

    # restore original values in $s register
    ow_restore:
        lw $s0, 0($sp)
        addi $sp, $sp, 4

        jr $ra

length:
    addi $sp, $sp, -8
    sw $s0, 0($sp)			
    sw $s1, 4($sp)			

    li $s0, 0				
    li $s1, 0

    length_loop:
        add $s1, $s0, $a0		
        lb $s1, ($s1)			
        beqz, $s1, length_end		
        addi $s0, $s0, 1		
        j length_loop			
    
    length_end:
        move $v0, $s0
        j length_restore			
        
    length_restore:
        lw $s0, 0($sp)			
        lw $s1, 4($sp)				
        addi $sp, $sp, 8			
        
        jr $ra 

length_xor:
    addi $sp, $sp, -8
    sw $s0, 0($sp)
    sw $s1, 4($sp)
    
    move $s0, $a0
    move $s1, $a1
    
    call_func1(length, $s0)
    move $s0, $v0
    bnez $s0, lx_seq_zero
   
    li $s0, 1
    j lx_check_pat
    
    lx_seq_zero: li $s0, 0
    
    lx_check_pat: 
        call_func1(length, $s1)
        move $s1, $v0
        bnez $s1, lx_pat_zero
        
        li $s1, 1
        j lx_end
        
        lx_pat_zero: li $s1, 0
    
    lx_end:
        xor $v0, $s0, $s1
        j lx_restore
    	
    lx_restore:
        lw $s0, 0($sp)
        lw $s1, 4($sp)
    	addi $sp, $sp, 8
    	
    	jr $ra
    
array_equal:
    addi $sp, $sp, -12
    sw $s0, 0($sp)
    sw $s1, 4($sp)
    sw $s2, 8($sp)
    
    move $s0, $a0
    move $s1, $a1
    
    # check if the length of both strings are equal
    call_func1(length, $s0)
    move $s0, $v0
    
    call_func1(length, $s1)
    bne $s0, $v0, ae_false

    li $s0, 0
    ae_loop:
        beq $s0, $v0, ae_end
        
        # load character from both strings
        add $s1, $s0, $a0
        add $s2, $s0, $a1
        lb $s1, 0($s1)
        lb $s2, 0($s2)
        
        # check if the characters are equal
        bne $s1, $s2, ae_false
        
        addi $s0, $s0, 1
	j ae_loop
	
    ae_false:
        li $v0, -1
        j ae_restore

    ae_end:
        li $v0, 0
        j ae_restore

    ae_restore:
        lw $s0, 0($sp)
        lw $s1, 4($sp)
        lw $s2, 8($sp)
        addi $sp, $sp, 12
        
        jr $ra

.data
