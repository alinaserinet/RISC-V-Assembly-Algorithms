.data
matrix: .word 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25


# strings
str_outOfBound:	.asciz	"index out of bound!"
str_LB:		.asciz	"["
str_RB:		.asciz	"]"
str_EQ:		.asciz	" = "
str_SP:		.asciz	" "
str_NL:		.asciz	"\n"
str_TAB:	.asciz	"\t"

.text
# put base-of-matrix in (s0)
# put matrix-rows    in (s1)
# put matrix-cols    in (s2)

la 	s0, matrix			# base-of-matrix in (s0)
li 	s1, 1				# matrix-rows in (s1)
li	s2, 10				# matrix-cols in (s2)

mv	a1, s1
mv	a1, s2
li	a0, -1
jal 	initialMatrix
mv	s0, a0
jal	printMatrix

jal	exit


# 'rows-count' in            (a1)
# 'cols-count' in            (a2)
# 'default-value' in         (a0)
# -------------------------------
# return: base of new matrix (a0)
initialMatrix:
	mul	t1, a1, a2		# 'items-count'(t1) = 'rows-count'(a1) * 'col-count'(a2)
	slli	t0, t1, 2		# 'items-bytes'(t0) = 'items-count'(t1) * 4 'int-size'
	sub	sp, sp, t0		# reducing stack-pointer by the size of items-byte
	mv	t3, a0			# copy default-value to (t3)
	mv	a0, sp			# 'matrix-base'(a0) = stack-pointer
	
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


# 'row-index' in (a0)
# 'col-index' in (a1)
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
	

# number in (a0)
printInt:
	li	a7, 1			# syscall for print int-number
	ecall				# print number
	jalr	zero, 0(ra)		# return
	
# string in (a0)
printStr:
	li	a7, 4			# syscall for print string
	ecall				# print string
	jalr	zero, 0(ra)		# return
	

outOfBound:
	la	a0, str_outOfBound 	# load 'out-of-bound-message' to (a0)
	jal	printStr		# print 'out-of-bound-message'
	jal	exit			# jump to exit

exit:
	
	
	
	
	
