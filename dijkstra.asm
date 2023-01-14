.data

# strings
str_outOfBound:		.asciz	"index out of bound!"
str_LB:			.asciz	"["
str_RB:			.asciz	"]"
str_EQ:			.asciz	" = "
str_SP:			.asciz	" "
str_NL:			.asciz	"\n"
str_TAB:		.asciz	"\t"
str_enterGraph:		.asciz	"Enter Graph:"
str_enterNodesLen: 	.asciz	"Enter count of nodes:\n"

.text
# put base-of-matrix in (s0)
# put matrix-rows    in (s1)
# put matrix-cols    in (s2)
jal	readGraph

jal	exit


readGraph:
	addi	sp, sp, -4
	sw	ra, 0(sp)
	la	a0, str_enterNodesLen
	jal	printStr
	jal	readInt
	mv	a1, a0
	mv	a2, a0
	mv	s1, a1
	mv	s2, a2
	li	a0, 0
	jal	initialMatrix
	mv	s0, a0
	jal	printMatrix
	
	lw	ra, 0(sp)
	addi	sp, sp, 4
	jalr	zero, 0(ra)
	

# 'rows-count' in            (a1)
# 'cols-count' in            (a2)
# 'default-value' in         (a0)
# -------------------------------
# return: base of new matrix (a0)
initialMatrix:
	mul	t1, a1, a2		# 'items-count'(t1) = 'rows-count'(a1) * 'col-count'(a2)
	slli	t0, t1, 2		# 'items-bytes'(t0) = 'items-count'(t1) * 4 'int-size'
	sub	gp, gp, t0		# reducing global-pointer by the size of items-byte
	mv	t3, a0			# copy default-value to (t3)
	mv	a0, gp			# 'matrix-base'(a0) = stack-pointer
	
	# save 'return-address' to stack
	addi	sp, sp, -4
	sw	ra, 0(sp)
	
	mv	t0, a0			# 'bytes-counter'(t0) = 'matrix-base'(a0)
	li	t2, 0			# 'items-counter'(t2) = 0
	initialMatrix_loop:
		bge	t2, t1, initialMatrix_end	# check items-counter(t2) < items-count(t1)
		sw	t3, 0(t0)			# store default-value to current byte-address
		addi	t0, t0, 4			# bytes-counter += 4
		addi	t2, t2, 1			# items-counter += 1
		jal	initialMatrix_loop		# jump to loop
	initialMatrix_end:
	# load 'return-address' from stack
	lw	ra, 0(sp)
	addi	sp, sp, 4
	
	jalr	zero, 0(ra)		# return - base-of-matrix in (a0)
	

# 'matrix-base' in (s0)
# 'matrix-rows' in (s1)
# 'matrix-cols' in (s2)
# 'row-index'   in (a0)
# 'col-index'   in (a1)
# ----------------------------
# return: 'edge-value' in (a0)
getItem:
	# save 'return-address' to stack
	addi	sp, sp, -4
	sw	ra, 0(sp)
	
	jal	getItemAddress 		# 'edge-address' in (a0)
	
	# load 'return-address' from stack
	lw	ra, 0(sp)
	addi	sp, sp, 4
	
	lw	a0, 0(a0)		# load 'edge-value' from array[(a0)][(a1)]
	jalr	zero, 0(ra)		# return 'edge-value'

# 'matrix-base' in (s0)
# 'matrix-rows' in (s1)
# 'matrix-cols' in (s2)
# 'row-index'   in (a0)
# 'col-index'   in (a1)
# 'item-value'  in (a2)
setItem:
	# save 'return-address' to stack
	addi	sp, sp, -4
	sw	ra, 0(sp)
	
	jal	getItemAddress 		# 'item-address' in (a0)
	
	# load 'return-address' from stack
	lw	ra, 0(sp)
	addi	sp, sp, 4
	
	sw	a2, 0(a0) 		# save 'item-value' in array[(a0)][(a1)]
	jalr	zero, 0(ra) 		# return
	
	

# 'matrix-base' in (s0)
# 'matrix-rows' in (s1)
# 'matrix-cols' in (s2)
# 'row-index'   in (a0)
# 'col-index'   in (a1)
# ------------------------------
# return: 'edge-address' in (a0)
getItemAddress:
	bgeu	a0, s1, outOfBound	# check 'row-index' < 'matrix-rows'
	bgeu	a1, s2, outOfBound 	# check 'col-index' < 'matrix-cols'
	slli	t0, s2, 2		# 'row-bytes' = `matrix-cols` * 4 (int-size)
	mul	t0, t0, a0		# 'row-index' * 'row-size' (to find rows-offset)
	slli	t1, a1, 2		# 'col-index' * 4 (int-size) (to find cols-offset)
	add	t0, s0, t0		# address = base + rows-offset
	add	a0, t0, t1		# address += cols-offset
	jalr	zero, 0(ra)		# return address

# 'matrix-base' in (s0)
# 'matrix-rows' in (s1)
# 'matrix-cols' in (s2)
printMatrix:
	# save 'return-address' to stack
	addi	sp, sp, -4
	sw	ra, 0(sp)
	
	li	t0, 0		# 'row-counter'(t0) = 0
	printMatrix_loop1:
		# check 'row-counter'(t0) < 'matrix-size'(s1)
		bgeu	t0, s1, printMatrix_end1
		li	t1, 0		# 'col-counter' (t1) = 0
		printMatrix_loop2:
			# check 'col-counter'(t1) < 'matrix-cols'(s2)
			bgeu	t1, s2, printMatrix_end2
			
			# save 'row-counter'(t0) and 'col-counter'(t1) to stack
			addi	sp, sp, -8
			sw	t0, 0(sp)
			sw	t1, 4(sp)
			
			# initialization arguments for 'getItem'
			mv	a0, t0		# copy 'row-counter'(t0) to 'a0'
			mv	a1, t1		# copy 'col-counter'(t1) to 'a1'
			
			jal	getItem		# get item = [a0][a1]
			jal	printInt	# print current item
			
			# print tab'\t' after item
			la	a0, str_TAB
			jal	printStr
			
			# load 'row-counter'(t0) and 'col-counter'(t1) from stack
			lw	t0, 0(sp)
			lw	t1, 4(sp)
			addi	sp, sp, 8
			
			addi	t1, t1, 1	# 'col-counter'(t1) += 1
			jal	printMatrix_loop2 # jump to loop2
		printMatrix_end2:
		
		# print new-line'\n' after row
		la	a0, str_NL
		jal	printStr
		
		addi	t0, t0, 1		# 'row-counter'(t0) += 1
		jal	printMatrix_loop1	# jump to loop1
	printMatrix_end1:
	
	# load 'return-address' from stack
	lw	ra, 0(sp)
	addi	sp, sp, 4
	
	jalr 	zero, 0(ra)		# return


# 'matrix-base' in (s0)
# 'matrix-rows' in (s1)
# 'matrix-cols' in (s2)
# 'row-index'   in (a0)
# 'col-index'   in (a1)
printItem:
	# save 'return-address' to stack
	addi	sp, sp, -4
	sw	ra, 0(sp)
	
	# copy 'row-index' to (t0)
	mv	t0, a0
	
	# print "[row-index]"
	# print "["
	la	a0, str_LB
	jal	printStr
	# print 'row-index'
	mv	a0, t0
	jal	printInt		
	# print "]"
	la	a0, str_RB
	jal	printStr
	
	# print "[col-index]"
	# print "["
	la	a0, str_LB
	jal	printStr
	# print 'col-index'
	mv	a0, a1
	jal	printInt		
	# print "]"
	la	a0, str_RB
	jal	printStr
		
	# print "="
	la	a0, str_EQ
	jal	printStr
	
	mv	a0, t0			# set 'row-index' in (a0)
	jal	getItem			# get 'item-value' in (a0)
	jal	printInt		# print 'edge-value'
	
	# load 'return-address' from stack
	lw	ra, 0(sp)
	addi	sp, sp, 4
	
	jalr 	zero, 0(ra)		# return
	
	
# string-base in (a0)
# -----------------------
# reverse string in place
strReverseInPlace:
	# save return-address to stack
	addi	sp, sp, -4
	sw	ra, 0(sp)
	
	mv	t1, a0			# copy string-base(a0) to (t1)
	
	# loop for finding end-of-string
	strReverse_loop1:
		lbu	t0, 0(t1)	# load current char
		beq	t0, zero, strReverse_end1	# check current-char is equal to '\0'
		addi	t1, t1, 1	# current-char-address (t1) += 1
		jal	strReverse_loop1	# jump
	strReverse_end1:
	# reduce t1 to skip '\0'
	addi	t1, t1, -1
	mv	t0, a0			# copy string-base(a0) to (t0)
	
	# loop for swap chars
	strReverse_loop2:
		bge	t0, t1, strReverse_end2	# check t0 < t1
		lbu	t2, 0(t0)	# load first-char
		lbu	t3, 0(t1)	# load last-char
		
		# swap first and last chars
		sb	t2, 0(t1)	
		sb	t3, 0(t0)
		
		addi	t0, t0, 1	# (t0) += 1
		addi	t1, t1, -1	# (t1) -= 1
		jal	strReverse_loop2	# jump
	strReverse_end2:
	
	# load return-address from stack
	lw	ra, 0(sp)
	addi	sp, sp, 4
	
	jalr	zero, 0(ra)		# return


# 'string'   in (a0)
# ----------------------------
# return: 'number' in (a0)
strToNum:
	# save return-address to stack
	addi	sp, sp, -4
	sw	ra, 0(sp)
	
	# reverse string
	jal	strReverseInPlace

	mv	t0, a0			# copy string-base to (t0)
	li	a0, 0			# initial final-number
	li	t2, 1			# (t2) for pow
	li	t3, 10			# (t3) for 10 number
	strToNum_loop:
		lbu	t1, 0(t0)	# load current-char
		beq	t1, zero, strToNum_end 	# check char equal to '\0'
		
		# check char is less than '0'
		addi	t4, t1, -48
		blt	t4, zero, strToNum_continue
		
		# check char is greater than '9'
		addi	t4, t1, -57
		blt	zero, t4, strToNum_continue
		
		andi 	t1, t1, 0xf	# (t1) = AND char with 1111 to remove extra bits
		mul	t1, t1, t2	# (t1) = (t1) * pow(t2)
		add	a0, a0, t1	# final-number(a0) += (t1)
		mul	t2, t2, t3	# (t2)pow *= 10
		strToNum_continue:
		addi	t0, t0, 1	# (t0) += 1 to get next char address
		jal	strToNum_loop	# jump
	strToNum_end:
	lbu	t1, -1(t0)		# load first-char in string
	
	# check first-char in string is equal to '-'
	addi	t1, t1, -45
	bne	t1, zero, strToNum_next
	
	# first-char = '-' => final-number *= -1
	li	t2, -1			
	mul	a0, a0, t2
	strToNum_next:
	
	# load return-address from stack
	lw	ra, 0(sp)
	addi	sp, sp, 4
	
	jalr	zero, 0(ra)		# return
	

# number in (a0)
printInt:
	li	a7, 1			# syscall for print int-number
	ecall				# print number
	jalr	zero, 0(ra)		# return
	
readInt:
	li	a7, 5
	ecall
	jalr	zero, 0(ra)
	
	
# string in (a0)
printStr:
	li	a7, 4			# syscall for print string
	ecall				# print string
	jalr	zero, 0(ra)		# return
	
	
# string-length in a1
# ---------------------------
# return: string-base in (a0)	
readStr:
	sub	gp, gp, a1		# reduce global-pointer for saving string
	mv	a0, gp			# string-base(a0) = global-base
	li	a7, 8			# load 8 for read-string syscall
	ecall				# read string
	jalr	zero, 0(ra)		# return
	

outOfBound:
	la	a0, str_outOfBound 	# load 'out-of-bound-message' to (a0)
	jal	printStr		# print 'out-of-bound-message'
	jal	exit			# jump to exit

exit:
	
	
	
	
	
