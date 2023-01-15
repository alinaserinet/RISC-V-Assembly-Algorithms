.data
matrix:		.word 0, 1, 2, 3, 0, 1, 2, 3, 0

# strings
str_outOfBound:		.asciz	"index out of bound!"
str_TAB:			.asciz	"\t"
str_NL:				.asciz	"\n"
str_line:			.asciz	"----------------------------------\n"

.text

li		s2, 5
li		s1, 2
jal		dijkstra



jal	exit

# base of graph-matrix in (s0)
# vertex-count(nodes-count) in (s2)
# source in (s1)
dijkstra:
	addi	sp, sp, -4
	sw		ra, 0(sp)
	# Initialization shortest-path-tree-set and save its base in (s3)
	li		a1, 1				# rows-count(a1) = 1 for an array
	mv		a2, s2				# cols-count(a2) = nodes-count(s1)
	jal		matrixAlloc			# create-array, (a0) = base of new array
	mv		s3, a0				# base of shortest-path-tree-set(s3) = base of new array(a0)
	
	# Initialization distances-array and save its base in (s4)
	li		a1, 1				# rows-count(a1) = 1 for an array
	mv		a2, s2				# cols-count(a2) = nodes-count(s1)
	jal		matrixAlloc			# create-array, (a0) = base of new array
	mv		s4, a0				# base of distances-array(s4) = base of new array(a0)
	
	# loop for set all distances = MAX-VALUE, sptSet values = false (0)
	li		t0, 0				# loop counter
	li		t4, -1				# representation of MAX-VALUE, in unsigned value -1 is Max.
	dijkstra_loop1:
		bge		t0, s2, dijkstra_end1	# checking loop-countr(t0) is less than nodes-count(s2)
		
		# calculating bytes-offset 
		slli	t1, t0, 2				# bytes-offset(t1) = loop-counter'items-offset'(t0) * 4(word-size)
		
		# 'byte-position in shortest-path-tree-set'(t2) = base of shortest-path-tree-set(s3) + bytes-offset(t1)
		add		t2, s3, t1
		sw		zero, 0(t2)				# store '0'(zero) in 'current position of shortest-path-tree-set'(t2)
		
		# if loop-countr(t0) is equal source(s1) dont set distance = MAX-VALUE, distances[source] = 0
		beq		s1, t0, dijkstra_continue1
		
		# 'byte-position in distances'(t2) = 'base of distances'(s4) + bytes-offset(t1)
		add 	t2, s4, t1				
		sw		t4, 0(t2)				# store MAX-VALUE(t4) in 'current position of distances(t2)'
	dijkstra_continue1:
		addi	t0, t0, 1				# increase loop-counter(t0), loop-counter(t0) += 1
		jal		dijkstra_loop1			# jump to loop
	dijkstra_end1:
	
	mv		s0, s3
	li		s1, 1
	jal		printMatrix
	
	la		a0, str_line
	jal		printStr
	
	mv		s0, s4
	jal		printMatrix
	
	lw		ra, 0(sp)
	addi	sp, sp, 4
	
	jalr	zero, 0(ra)
	
	
# base of shortest-path-tree-set in (s3)
# base of distances-array in (s4)
# vertex-count(nodes-count) in (s2)
# --------------------------------------
# return min-index in (a0)
minDistance:
	# store return-address in stack
	addi	sp, sp, -24
	sw		ra, 0(sp)
	
	# store save-register (s0) in the stacke, for using (s0) to sent it to getItem as base-address
	sw		s0, 4(sp)
	
	# store save-register (s1) in the stack, for using (s1) to send it to getItem  as rows-count
	sw		s1, 8(sp)
	
	# store saved-registers in stack
	sw		s5, 12(sp)
	sw		s6, 16(sp)
	sw		s7, 20(sp)
	
	# values Initialization
	li		s1, 1	     			# rows-count(s1) is equal '1' for an array to send to 'getItem'
	li		s5, -1					# Initialize min-value = (-1) => in unsigned it's Max-value
	li		s6, -1					# Initialize min-index
	li		s7, 0					# Initialize vertex-counter (v = 0)
	
	
	minDistance_loop:
		bge		s7, s2, minDistance_end		# checking vertex-counter is less than vertex-count
		
		# base of shortest-path-tree-set is in (s3), copy it into (s0) for sending to getItem as base-address
		mv		s0, s3
		
		# (s1) = 1, (s2) = vertex-count(nodes-count)
	
		# getting sptSet[0][vertex-counter(a1)]				
		li		a0, 0				# row-index (a0) = '0' for an array
		mv		a1, s7				# col-index (a1) = vertex-counter(s7)
		jal		getItem				# getting sptSet[0][vertex-counter(a1)]
		
		# checking sptSet[0][vertex-counter(a1)] == false, else continue
		bne		a0, zero, minDistance_continue	
		
		# base of distances-array is in (s4), copy it into (s0) for sending to getItem as base-address
		mv		s0, s4
		
		# getting distances[0][vertex-counter(a1)]	
		li		a0, 0				# row-index (a0) = '0' for an array
		mv		a1, s7				# col-index (a1) = vertex-counter(s7)
		jal		getItem				#getting distances[0][vertex-counter(a1)]
		
		# checking distances[0][vertex-counter(a1)] <= min-value(s5), else continue
		bltu	s5, a0, minDistance_continue
		
		mv		s5, a0				# min-value(s5) = distances[0][vertex-counter(s7)]
		mv		s6, s7				# min-index(s6) = vertex-counter(s7)
		
	minDistance_continue:
		addi	s7, s7, 1			# increasing vertex-counter(s7), vertex-counter(s7) += 1
	minDistance_end:
	
	mv		a0, s6					# (a0) = min-index(s6), for return it
	
	# restore return-address: loading it from the stack.
	lw		ra, 0(sp)
	
	# restore saved-register: loading them from the stack.
	lw		s0, 4(sp)
	lw		s1, 8(sp)
	lw		s5, 12(sp)
	lw		s6, 16(sp)
	lw		s7, 20(sp)
	
	# restore stack-pointer to pervious position.
	addi	sp, sp, 24
	jalr	zero, 0(ra)

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
