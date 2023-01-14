.data
matrix:		.word 0, 1, 2, 3, 0, 1, 2, 3, 0

# strings
str_outOfBound:	.asciz	"index out of bound!"

.text

li	a1, 3
li	a2, 3
mv	s1, a1
mv	s2, a2
jal	matrixAlloc
mv	s0, a0
li	a0, -1
jal	matrixSetAll
li	a0, 1
li	a1, 2
jal	getItem
jal	printInt




jal	exit

# 'matrix-base' in (s0)
# 'matrix-rows' in (s1)
# 'matrix-cols'	in (s2)
# ---------------------
# 'value' in 	   (a0)
matrixSetAll:
	addi	sp, sp, -4
	sw		ra, 0(sp)
	
	mul		t0, s1, s2
	slli	t0, t0, 2
	add		t0, s0, t0
	mv		t1, s0
	matrixSetAll_loop:
		bge		t1, t0, matrixSetAll_end
		sw		a0, 0(t1)
		addi	t1, t1, 4
		jal		matrixSetAll_loop
	matrixSetAll_end:
	lw		ra, 0(sp)
	addi	sp, sp, 4
	jalr	zero, 0(ra)
		

# 'rows-count' in  (a1)
# 'cols-count' in  (a2)
# ---------------------------------------
# return: base of allocated matrix in (a0)
matrixAlloc:
	slli	a0, a2, 2			# each row need 'cols * 4' bytes
	mul		a0, a0, a1			# matrix need 'row-bytes * rows-count' bytes
	li, 	a7, 9				# syscall for allocate heap memmory
	ecall						# run syscall
	jalr	ra, 0(ra)			# return


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
	
	jal	getItemAddress 			# 'edge-address' in (a0)
	
	# load 'return-address' from stack
	lw	ra, 0(sp)
	addi	sp, sp, 4
	
	lw	a0, 0(a0)				# load 'edge-value' from array[(a0)][(a1)]
	jalr	zero, 0(ra)			# return 'edge-value'
	

# 'matrix-base' in (s0)
# 'matrix-rows' in (s1)
# 'matrix-cols' in (s2)
# 'row-index'   in (a0)
# 'col-index'   in (a1)
# 'item-value'  in (a2)
setItem:
	# save 'return-address' to stack
	addi	sp, sp, -4
	sw		ra, 0(sp)
	
	jal	getItemAddress 			# 'item-address' in (a0)
	
	# load 'return-address' from stack
	lw		ra, 0(sp)
	addi	sp, sp, 4
	
	sw		a2, 0(a0) 			# save 'item-value' in array[(a0)][(a1)]
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