.data
matrix:		.word 0, 1, 2, 3
array1:		.word 0, -1, -1, -1
array2:		.word 0, 0, 0, 0

# strings
str_outOfBound:			.asciz	"index out of bound!"
str_TAB:				.asciz	"\t"
str_NL:					.asciz	"\n"
str_line:				.asciz	"\n----------------------------------\n"
str_enterNodesCount:	.asciz	"Enter nodes count: "
str_enterEdge:			.asciz	"\nedge "
str_between:			.asciz	" between "
str_colon:				.asciz	": "
str_distances:			.asciz  "distances:\n"
str_to:					.asciz	" to "


.text

# print message for getting nodes-count
la		a0, str_enterNodesCount
jal		printStr

# read nodes-count: value in (a0)
jal		readInt
mv		s1, a0		# copy recived-value into (s1) for sending to the readGraph

# reading graph
jal		readGraph 	# return: (a0) recived-matrix of graph
mv		s3, a0
# Initialization arguments for 
mv		s0, a0
mv		s2, s1
jal		printMatrix

li		s5, 0
jal		dijkstra

mv		s0, a0
jal		printDistances

jal	exit


# base of graph-matrix in (s3)
# vertex-count(nodes-count) in (s2)
# source in (s5)
# ---------------------------------
# distance-array-base in (a0)
dijkstra:
	addi	sp, sp, -36
	sw		ra, 0(sp)
	
	# store saved-registers
	sw		s0, 4(sp)
	sw		s1, 8(sp)
	sw		s6, 12(sp)
	sw		s7, 16(sp)
	sw		s8, 20(sp)
	sw		s9, 24(sp)
	sw		s10, 28(sp)
	sw		s11, 32(sp)
	
	# Initialization shortest-path-tree-set and save its base in (s6)
	li		a1, 1				# rows-count(a1) = 1 for an array
	mv		a2, s2				# cols-count(a2) = nodes-count(s2)
	jal		matrixAlloc			# create-array, (a0) = base of new array
	mv		s6, a0				# base of shortest-path-tree-set(s6) = base of new array(a0)
	
	# Initialization distances-array and save its base in (s7)
	li		a1, 1				# rows-count(a1) = 1 for an array
	mv		a2, s2				# cols-count(a2) = nodes-count(s2)
	jal		matrixAlloc			# create-array, (a0) = base of new array
	mv		s7, a0				# base of distances-array(s7) = base of new array(a0)
	
	# loop for set all distances = MAX-VALUE, sptSet values = false (0)
	li		t0, 0				# loop counter
	li		t4, 1000				# representation of MAX-VALUE, in unsigned value -1 is Max.
	dijkstra_loop1:
		bge		t0, s2, dijkstra_end1	# checking loop-countr(t0) is less than nodes-count(s2)
		
		# calculating bytes-offset 
		slli	t1, t0, 2				# bytes-offset(t1) = loop-counter'items-offset'(t0) * 4(word-size)
		
		# 'byte-position in shortest-path-tree-set'(t2) = base of shortest-path-tree-set(s6) + bytes-offset(t1)
		add		t2, s6, t1
		sw		zero, 0(t2)				# store '0'(zero) in 'current position of shortest-path-tree-set'(t2)
		
		# if loop-countr(t0) is equal source(s5) dont set distance = MAX-VALUE, distances[source] = 0
		beq		s5, t0, dijkstra_continue1
		
		# 'byte-position in distances'(t2) = 'base of distances'(s7) + bytes-offset(t1)
		add 	t2, s7, t1				
		sw		t4, 0(t2)				# store MAX-VALUE(t4) for 'current position of distances(t2)'
	dijkstra_continue1:
		addi	t0, t0, 1				# increase loop-counter(t0), loop-counter(t0) += 1
		jal		dijkstra_loop1			# jump to loop
	dijkstra_end1:
	mv	s0, s6
	li	s1, 1
	jal	printMatrix
	
	mv	s0, s7
	jal	printMatrix
	la	a0, str_line
	jal	printStr
	
	
	# counter = 0
	li		s8, 1
	dijkstra_loop2:
		# check counter(s8) < nodes-count(s2), else break
		bge		s8, s2, dijkstra_end2
		
		jal		minDistance				# s6:sptSet-base, s7: distance-base, s2: nodes-count, return min-index in (a0)
		
		mv		s0, s6
		li		s1, 1
		mv		a1, a0
		li		a0, 0
		li		a2, 1
		jal		setItem
				
		
		li		s9, 0	# nodes-counter
        dijkstra_loop3:
        	bge		s9, s2, dijkstra_end3

        	# load sptSet[0][nodes-counter(s9)] // sptSet-base in (s6)
        	mv		s0, s6		# copy sptSet-base(s6) in s0, for sending into getItem
        	li		s1, 1		# rows-count(s1) = 1 for an array
        	# cols-count is in (s2)
       		li		a0, 0		# row-index(a0) = 0 for an array
        	mv		a1, s9		# col-index(a1) = nodes-counter(s9)
        	jal		getItem		# getItem from sptSet: return value in (a0)

        	# check sptSet[0][nodes-counter(s9)] == 0, else continue loop3
        	bne		a0, zero, dijkstra_continue3 # {1}

        	# load graph[min-index][nodes-counter(s9)] // graph-base in (s3)
        	mv		s0, s3		# copy graph-base(s3) into (s0) for sending to getItem
        	mv		s1, s2		# rows-count(s1) = cols-count(s2) for graph-matrix.
        	# cols-count is in (s2)
        	mv		a0, s10		# row-index(a0) = min-index(s10)
        	mv		a1, s9		# col-index(a1) = nodes-counter(s9)
        	jal		getItem		# get from graph: return value in (a0)

        	# checking graph[min-index][nodes-counter(s9)] != 0, else continue loop3
        	beq		a0, zero, dijkstra_continue3	# {2}
        	mv		s11, a0

        	# load distance[0][min-index]	// distances-base in (s7)
        	mv		s0, s7			# copy distance-base(s7) into (s0) for sending to getItem
        	li		s1, 1			# rows-count(s1) = 1 for an array
        	# cols-count is in (s2)
        	li		a0, 0			# row-index(a0) = 0 for an array
        	mv		a1, s10			# col-index(a1) = min-index(a10)
        	jal		getItem
        	jal			printInt
        	# checking distance[0][min-index] != MAX-VALUE(-1), else continue loop3
        	addi		t0, a0, -1000
        	beq			t0, zero, dijkstra_continue3 # {3}
			add			s11, s11, a0
        	# sum distance[0][min-index] + graph[min-index][nodes-counter(s9)]
        	jal			printInt
        
        	# load distance[0][nodes-counter(s9)] // distances-base in (s7)
        	mv		s0, s7
        	li		s1, 1
        	# cols-count is in (s2)
        	li		a0, 0
        	mv		a1, s9
        	jal		getItem

        	bge		s11, a0, dijkstra_continue3
        	# set distance[nodes-counter(s9)] = distance[min-index] + graph[min-index][nodes-counter(s9)]
        	
        	mv		s0, s7
        	li		s1, 1
        	li		a0, 0
        	mv		a1, s9
        	mv		a2, s11
        	jal		setItem
        dijkstra_continue3:
        addi	s9, s9, 1
        jal		dijkstra_loop3
        dijkstra_end3:
		
		addi	s8, s8, 1
		jal		dijkstra_loop2
	dijkstra_end2:
	
	mv		a0, s7			# copy distance-array(s7) base into (a0)
	# load saved-registers
	lw		s0, 4(sp)		
	lw		s1, 8(sp)
	lw		s6, 12(sp)
	lw		s7, 16(sp)
	lw		s8, 20(sp)
	lw		s9, 24(sp)
	lw		s10, 28(sp)
	lw		s11, 32(sp)
	
	lw		ra, 0(sp)
	addi	sp, sp, 36
	jalr	zero, 0(ra)
	
	
# base of shortest-path-tree-set in (s6)
# base of distances-array in (s7)
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
	
	sw		s8, 16(sp)
	
	sw		s9, 20(sp)
	
	# values Initialization
	li		s1, 1	     			# rows-count(s1) is equal '1' for an array to send to 'getItem'
	li		s8, -1					# Initialize Max-value = (-1) => in unsigned it's Max-value
	li		s9, -1					# Initialize min-index
	li		s5, 0					# Initialize vertex-counter (v = 0)
	
	
	minDistance_loop:
		bge		s5, s2, minDistance_end		# checking vertex-counter(s5) is less than vertex-count(s2)
		
		# base of shortest-path-tree-set is in (s6), copy it into (s0) for sending to getItem as base-address
		mv		s0, s6
		
		# (s1) = 1, (s2) = vertex-count(nodes-count)
	
		# getting sptSet[0][vertex-counter(a1)]				
		li		a0, 0				# row-index (a0) = '0' for an array
		mv		a1, s5				# col-index (a1) = vertex-counter(s5)
		jal		getItem				# getting sptSet[0][vertex-counter(a1)]
		
		# checking sptSet[0][vertex-counter(a1)] == false, else continue
		bne		a0, zero, minDistance_continue
		
		# base of distances-array is in (s7), copy it into (s0) for sending to getItem as base-address
		mv		s0, s7
		
		# getting distances[0][vertex-counter(a1)]	
		li		a0, 0				# row-index (a0) = '0' for an array
		mv		a1, s5				# col-index (a1) = vertex-counter(s5)
		jal		getItem				# getting distances[0][vertex-counter(a1)]: return value in (a0)
		
		# checking distances[0][vertex-counter(a1)] <= Max-value(s8), else continue
		bltu	s8, a0, minDistance_continue
		
		mv		s8, a0				# Max-value(s5) = distances[0][vertex-counter(s5)]
		mv		s9, s5				# min-index(s9) = vertex-counter(s5)
		
	minDistance_continue:
		addi	s5, s5, 1			# increasing vertex-counter(s5), vertex-counter(s5) += 1
		jal		minDistance_loop
	minDistance_end:
	
	mv		a0, s9					# (a0) = min-index(s9), for return it
	
	# restore return-address: loading it from the stack.
	lw		ra, 0(sp)
	
	# restore saved-register: loading them from the stack.
	lw		s0, 4(sp)
	lw		s1, 8(sp)
	lw		s5, 12(sp)
	lw		s8, 16(sp)
	lw		s9, 20(sp)

	# restore stack-pointer to pervious position.
	addi	sp, sp, 24
	jalr	zero, 0(ra)
	
	
	
# distance array base in (s0)
# count of nodes in (s2)
# source in (s5)
printDistances:
	addi	sp, sp, -12
	# store return-address into stack
	sw		ra, 0(sp)
	
	# save saved-registers into stack
	sw		s1, 4(sp)		# using (s1) for rows-count to send to getItem
	sw		s3, 8(sp)		# using (s3) for loop-counter
	
	# print "distances" string
	la		a0, str_distances
	jal		printStr
	
	# Value initialization
	li		s1, 1			# (s1): rows-count for an array
	li		s3, 0			# (s3): loop-counter
	
	# Loop for iterating distances
	printDistances_loop:
		bgeu	s3, s2, printDistances_end		# Checking loop-counter(s3) < nodes-count(s2), else break
		
		# Print	source-node(s5) name
		mv		a0, s5
		jal		printInt
		
		# Print	" to " string
		la		a0, str_to
		jal		printStr
		
		# Print	destination-node(loop-counter(s3)) name
		mv		a0, s3
		jal		printInt
		
		# Print " : " string
		la		a0, str_colon
		jal		printStr
		
		# Print "\t" string
		la		a0, str_TAB
		jal		printStr
		
		# get distance from distances-array => distances-array[0][loop-counter(s3)]
		# base was in (s0)
		# rows-count was 1 in (s1)
		# cols-count was in (s2)
		li		a0, 0		# row-index is 0 for an array
		mv		a1, s3		# col-index: loop-counter(s3)
		jal		getItem		# return: distance in (a0)
		jal		printInt	# print distance
		
		# Print "\n" string
		la		a0, str_NL
		jal		printStr
		
		# increase loop-counter(s3), loop-counter(s3) += 1
		addi	s3, s3, 1
		
		jal		printDistances_loop	#jump
	printDistances_end:
	# restore return-address from stack
	lw		ra, 0(sp)
	
	# restore saved-registers into stack
	lw		s1, 4(sp)		# using (s1) for rows-count
	lw		s3, 8(sp)		# using (s3) for loop-counter
	
	# restore stack-pointer to pervious position
	addi	sp, sp, 12
	
	jalr	zero, 0(ra)	# return
	
		
# nodes-count in (s1)
# ---------------------------
# return: matrix-base in (a0)
readGraph:
	# increase stack-pointer for saving items
	addi	sp, sp, -20
	
	# store return-address to the stack
	sw		ra, 0(sp)
	
	# stroe saved-registers to the stack
	sw		s0, 4(sp)		# s0 for matrix-base for sending into setItem 
	sw		s2, 8(sp)		# s2 for cols-count for sending into setItem
	sw		s3, 12(sp)		# s3 for rows-counter
	sw		s4, 16(sp)		# s4 for cols-counter
	
	# set 'rows-count'(a1), 'cols-count'(a2) for matrix-alloc arguments.
	mv		a1, s1			# 'rows-count'(a1) = 'nodes-count'(s1)
	mv		a2, s1			# 'cols-count'(a2) = 'nodes-count'(s2)
	jal		matrixAlloc		# allocate a matrix
	
	# save base of new matrix in (s0), for using in setItem.
	mv		s0, a0			# (s0) = 'base of new matrix'(a0)
	
	# save 'nodes-count' in (s2) as cols-count for using in setItem.
	mv		s2, s1			# (s2) = 'nodes-count'(s1)
	
	# Initialization rows-counter(s3)
	li		s3, 0			# rows-counter(s3) = 0
	
	readGraph_loop1:
		# checking rows-counter(s3) is less than < rows-count(s1), else break.
		bge		s3, s1, readGraph_end1
		
		# Initialization cols-counter(s4)
		addi	s4, s3, 1	# cols-counter(s4) = rows-counter(s3) + 1
			readGraph_loop2:
				# checking cols-counter(s4) is less than < cols-count(s2), else break.
				bge		s4, s2, readGraph_end2
				
				# print messages for reading graph edges:
				
				# print "edge "
				la		a0, str_enterEdge	
				jal		printStr		
				
				# print source-node
				mv		a0, s3
				jal		printInt
				
				# print " to "
				la		a0, str_between
				jal		printStr
				
				# print destination-node
				mv		a0, s4
				jal		printInt
				
				# print ":"
				la		a0, str_colon
				jal		printStr
				
				# read edge-weight
				jal		readInt
				
				
				mv		a2, a0			# copy edge--weight(a0) into (a2) as 'item-value' for setItem.
				mv		a0, s3			# copy 'row-counter'(s3) into (a0) as 'row-index' for setItem.
				mv		a1, s4			# copy 'col-counter'(s4) into (a1) as 'col-index' for setItem.
				
				addi	sp, sp, -4
				
				# store argument for using in lower-triangle items setting.
				sw		a2, 0(sp)		# save 'item-value'(a2)
				
				# set item[row-counter][col-counter]
				jal		setItem
				
				# load argument for using in lower-triangle items setting.
				lw		a2, 0(sp)		# load 'item-value'(a2)
				
				addi	sp, sp, 4
				
				# swap 'row-index' and 'col-index' for setItem arguments.
				mv		a0, s4			# copy 'col-counter'(s4) into (a0) as 'row-index' for setItem.
				mv		a1, s3			# copy 'row-counter'(s3) into (a1) as 'col-index' for setItem.
				# set item[col-counter][row-counter]
				jal		setItem
				
				# increase 'col-counter'(s4)
				addi	s4, s4, 1		# 'col-counter'(s4) += 1
				jal		readGraph_loop2	# jump
			readGraph_end2:
			
			# increase 'row-counter'(s3)
			addi	s3, s3, 1			# 'row-counter'(s3) += 1
			jal		readGraph_loop1		# jump
	readGraph_end1:
	mv		a0, s0			# copy base-address into (a0): for return
	# load saved-registers from the stack
	lw		s0, 4(sp)		# s0 for matrix-base for sending into setItem 
	lw		s2, 8(sp)		# s2 for cols-count for sending into setItem
	lw		s3, 12(sp)		# s3 for rows-counter
	lw		s4, 16(sp)		# s4 for cols-counter
	
	# load return-address from the stack
	lw		ra, 0(sp)
	
	# restore stack-pointer to pervious position
	addi	sp, sp, 20
	
	jalr	zero, 0(ra)		# return
		

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
# 'matrix-rows-count' in (s1)
# 'matrix-cols-count' in (s2)
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

# read int from input
# -------------------
# return: int in (a0)
readInt:
	li		a7, 5
	ecall
	jalr	zero, 0(ra)

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
