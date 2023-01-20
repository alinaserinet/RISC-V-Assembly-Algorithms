.data

# strings
str_outOfBound:			.asciz	"index out of bound!"
str_TAB:			.asciz	"\t"
str_NL:				.asciz	"\n"
str_line:			.asciz	"\n----------------------------------\n"
str_enterNodesCount:		.asciz	"Enter nodes count: "
str_enterEdge:			.asciz	"\nedge "
str_between:			.asciz	" between "
str_colon:			.asciz	": "
str_distances:			.asciz  "distances:\n"
str_to:				.asciz	" to "
str_enterSrc:			.asciz  "Enter source node: "

# define MAX_VALUE
.eqv	MAX	0xfffffff

.text
li	s10, MAX			# loading MAX-VALUE in (s10)


la	a0, str_enterNodesCount		# loading "Enter nodes count: " string for printing
jal	printStr			# printing "Enter nodes count: " string


jal	readInt				# reading nodes-count, int-number will be in (a0)

mv	s1, a0				# 'nodes-count'(s1) = 'returned number from readInt'(a0)
					
					# 'readGraph nodes-count argumnet'(a0) = 'returned number from readInt'(a0)
jal	readGraph 			# reading graph from console, 'base of adjacency matrix' will be in (a0)

mv	s0, a0				# 'base of adjacency matrix'(s0) = 'returned number from readInt'(a0)

					# 'printMatrix base argumnet'(a0) = 'base of adjacency matrix'(a0)
mv	a1, s1				# 'printMatrix rows argumnet'(a1) = 'nodes-count'(s1)
mv	a2, s1				# 'printMatrix cols argumnet'(a2) = 'nodes-count'(s1)

jal	printMatrix			# printing adjacency matrix

la	a0, str_enterSrc		# loading "Enter source node: " string for printing
jal	printStr			# printing "Enter source node: " string

jal	readInt				# reading source-node, int-number will be in (a0)

mv	s2, a0				# 'source-node'(s2) = 'returned number from readInt'(a0)

mv	a0, s0				# 'dijkstra adjacency-matrix-base argument'(a0) = 'base of adjacency matrix'(s0)
mv	a1, s1				# 'dijkstra nodes-count argument'(a1) = 'nodes-count'(s1)
mv	a2, s2				# 'dijkstra source-node argument'(a2) = 'source-node'(s2)
jal	dijkstra			# run dijkstra algorithm, 'distance-array-base' will be in (a0)

mv	a1, s1				# 'printDistances nodes-count argument'(a1) = 'nodes-count'(s1)
mv	a5, s2				# 'printDistances source-node argument'(a5) = 'source-node'(s2)
jal	printDistances			# printing distances-array

jal	exit				# exit by code 0


# ----------------------------------------------------
# Dijkstra algorithm for finding shortest paths
# ----------------------------------------------------
# ------------------- parameters ---------------------	
# 'adjacency-matrix-base' in          (a0)
# 'nodes-count' in                    (a1)
# 'source node' in		      (a2)
# ----------------------------------------------------
# return: 'distance-array-base' in    (a0)
# ----------------------------------------------------
dijkstra:
	bge	a2, a1, outOfBound	# checking source(a2) is less than nodes-count(a1), else break
	addi	sp, sp, -36		# reducing stack-pointer
	sw	ra, 0(sp)		# saving return-address
	
	sw	s0, 4(sp)		# (s0) for keeping 'adjacency-matrix-base'
	sw	s2, 8(sp)		# (s2) for keeping 'nodes-count'
	sw	s3, 12(sp)		# (s3) for keeping 'loop-counter'
	sw	s4, 16(sp)		# (s4) for keeping 'nodes-counter'
	sw	s5, 20(sp)		# (s5) for keeping 'source-node' and 'min-index'
	sw	s6, 24(sp)		# (s6) for keeping 'base of shortest-path-tree-set'
	sw	s7, 28(sp)		# (s7) for keeping 'base of distances'
	sw	s8, 32(sp)		# (s8) for keeping a temp var in loop3
	
	mv	s0, a0			# 'adjacency-matrix-base'(s0) = 'adjacency-matrix-base parameter'(a0)
	mv	s2, a1			# 'nodes-count'(s2) = 'nodes-count parameter'(a1)
	mv	s5, a2			# 'source-node'(s5) = 'source-node parameter'(a2)
	
	# Initialization shortest-path-tree-set and save its base in (s6)
	li	a1, 1			# 'matrixAlloc rows-count'(a1) = 1 for all array
	mv	a2, s2			# 'matrixAlloc rows-count'(a2) = 'nodes-count'(s2)
	jal	matrixAlloc		# allocating new array for shortest-path-tree-set, base will be in (a0)
	mv	s6, a0			# 'base of shortest-path-tree-set'(s6) = 'returned base from matrixAlloc'(a0)
	
	# Initialization distances-array and save its base in (s7)
	li	a1, 1			# 'matrixAlloc rows-count'(a1) = 1 for all array
	mv	a2, s2			# 'matrixAlloc rows-count'(a2) = 'nodes-count'(s2)
	jal	matrixAlloc		# allocating new array for distances, base will be in (a0)
	mv	s7, a0			# 'base of distances'(s7) = 'returned base from matrixAlloc'(a0)
	
	li	s4, 0			# initialzation 'nodes-counter'(s4) = 0
	dijkstra_loop1:
		# checking 'nodes-counter'(s4) is less than 'nodes-count'(s2), else break.
		bge	s4, s2, dijkstra_end1
		
		slli	t0, s4, 2			# 'bytes-offset'(t0) = 'nodes-counter'(items-offset)(s4) * 'word-size'(4)
		
		add	t1, s6, t0			# 'byte-position in shortest-path-tree-set'(t1) = 'base of shortest-path-tree-set'(s6) + 'bytes-offset'(t0)
		sw	zero, 0(t1)			# storing 'zero'(0) in 'current position of shortest-path-tree-set'(t1)
		
		# checking 'nodes-counter'(s4) == 'source-node'(s5) countinue, the distance for source-node is 'zero'(0).
		beq	s4, s5, dijkstra_continue1
		
		add 	t1, s7, t0			# 'byte-position in distances'(t1) = 'base of distances'(s7) + 'bytes-offset'(t0)	
		sw	s10, 0(t1)			# storing 'MAX_VALUE'(s10) in 'current position of distances'(t1)
		
	dijkstra_continue1:
		addi	s4, s4, 1			# 'nodes-counter'(s4) += 1
		jal	dijkstra_loop1			# jump to loop1
	dijkstra_end1:
	
	
	li	s3, 1			# initialzation 'loop-counter'(s3) = 1
	dijkstra_loop2:
		# checking 'counter'(s3) is less than 'nodes-count'(s2), else break.
		bge	s3, s2, dijkstra_end2
		
		mv	a0, s6 		# 'minDistance base of shortest-path-tree-set argument'(a0) = 'base of shortest-path-tree-set'(s6)
		mv	a1, s7 		# 'minDistance base of distances argument'(a1) = 'base of distances'(s7)
		mv	a2, s2		# 'minDistance nodes-count'(a2) = 'nodes-count'(s2)
		
		jal	minDistance	# calculating min-distance, 'min-index' will be in (a0)
		
		mv	s5, a0		# 'min-index'(s5) = 'returned min-index'(a0) by minDistance
		
		# set sptSet[0][min-index] = 1
		mv	a0, s6		# 'setItem base argument'(a0) = 'base of shortest-path-tree-set'(s6)
		li	a1, 1		# 'setItem rows argument'(a1) = 1 for all arrays
		mv	a2, s2		# 'setItem cols argument'(a2) = 'nodes-count'(s2)
		li	a3, 0		# 'setItem row-index argument'(a3) = 0 for all arrays
		mv	a4, s5		# 'setItem col-index argument'(a4) = 'min-index'(s5)
		li	a5, 1		# 'setItem item-value argument'(a5) = 1
		
		jal	setItem		# setting sptSet[0][min-index] = 1
				
		li	s4, 0		# nodes-counter
        	dijkstra_loop3:
        		# checking 'nodes-counter'(s4) is less than 'nodes-count'(s2), else break.
        		bge	s4, s2, dijkstra_end3

			mv	a0, s6		# 'getItem base argument'(a0) = 'base of shortest-path-tree-set'(s6)		
			li	a1, 1		# 'getItem rows argument'(a1) = 1 for all arrays		
			mv	a2, s2		# 'getItem cols argument'(a2) = 'nodes-count'(s2)
			li	a3, 0		# 'getItem row-index argument'(a3) = 0 for all arrays		
			mv	a4, s4		# 'getItem col-index argument'(a4) = 'nodes-counter'(s4)
		
        		jal	getItem		# getItem 'sptSet[0][nodes-counter]', it will be in (a0)

			# checking 'sptSet[0][nodes-counter]'(a0) == 0,  else continue loop3
        		bne	a0, zero, dijkstra_continue3 # {1}

			mv	a0, s0		# 'getItem base argument'(a0) = 'adjacency-matrix-base'(s0)
			mv	a1, s2		# 'getItem rows argument'(a1) = 'nodes-count'(s2)
			mv	a2, s2		# 'getItem cols argument'(a2) = 'nodes-count'(s2)
			mv	a3, s5		# 'getItem row-index argument'(a3) = 'min-index'(s5)
			mv	a4, s4		# 'getItem col-index argument'(a4) = 'nodes-counter'(s4)
		
        		jal	getItem		# getting 'adjacency-matrix[min-index][nodes-counter]', it will be in (a0)

			# checking 'adjacency-matrix[min-index][nodes-counter]'(a0) != 0,  else continue loop3
        		beq	a0, zero, dijkstra_continue3	# {2}
        		
        		mv	s8, a0		# var(s8) for sum of 'adjacency-matrix[min-index][nodes-counter]' and 'distance[0][min-index]' = 'adjacency-matrix[min-index][nodes-counter]'(a0)

			mv	a0, s7		# 'getItem base argument'(a0) = 'distances-base'(s7)
			li	a1, 1		# 'getItem rows argument'(a1) = 1 for all arrays
			mv	a2, s2		# 'getItem cols argument'(a2) = 'nodes-count'(s2)
			li	a3, 0		# 'getItem row-index argument'(a3) = 0 for all arrays
			mv	a4, s5		# 'getItem col-index argument'(a4) = 'min-index'(s5)
        		
        		jal	getItem		# getting distance[0][min-index], it will be in (a0)
			
			# checking 'distance[0][min-index]'(a0) != MAX-VALUE(s10), else continue loop3
        		beq	a0, s10, dijkstra_continue3 # {3}
        		
			add	s8, s8, a0	# var(s8) for sum of 'adjacency-matrix[min-index][nodes-counter]' and 'distance[0][min-index]' += 'distance[0][min-index]'(a0)
			
			mv	a0, s7		# 'getItem base argument'(a0) = 'distances-base'(s7)
			li	a1, 1		# 'getItem rows argument'(a1) = 1 for all arrays
			mv	a2, s2		# 'getItem cols argument'(a2) = 'nodes-count'(s2)
			li	a3, 0		# 'getItem row-index argument'(a3) = 0 for all arrays
			mv	a4, s4		# 'getItem col-index argument'(a4) = 'nodes-counter'(s4)
			
			jal	getItem		# getting distance[0][nodes-counter], it will be in (a0)
			
			# checking 'adjacency-matrix[min-index][nodes-counter] + distance[0][min-index]'(s8) is less than 'distance[0][nodes-counter]'(a0), else continue loop3
        		bge	s8, a0, dijkstra_continue3
        		
        		mv	a0, s7		# 'setItem base argument'(a0) = 'distances-base'(s7)
        		li	a1, 1		# 'setItem rows argument'(a1) = 1 for all arrays
        		mv	a2, s2		# 'setItem cols argument'(a2) = 'nodes-count'(s2)
        		li	a3, 0		# 'setItem row-index argument'(a3) = 0 for all arrays
        		mv	a4, s4		# 'setItem col-index argument'(a4) = 'nodes-counter'(s4)
        		mv	a5, s8		# 'setItem item-value argument'(a5) = 'adjacency-matrix[min-index][nodes-counter] + distance[0][min-index]'(s8)
        		
        		jal	setItem		# setting 'distance[0][nodes-counter]'
        		
        		dijkstra_continue3:
        		addi	s4, s4, 1	# 'nodes-counter'(s4) += 1
        		jal	dijkstra_loop3	# jump to loop3
        	dijkstra_end3:	
		addi	s3, s3, 1	# 'loop-counter'(s3) += 1
		jal	dijkstra_loop2	# jump to loop2
	dijkstra_end2:
	
	mv	a0, s7			# 'distances-base return'(a0) = 'distances-base'(s7)
	
	# restoring saved-registers
	
	lw	s0, 4(sp)		# (s0) for keeping 'adjacency-matrix-base'
	lw	s2, 8(sp)		# (s2) for keeping 'nodes-count'
	lw	s3, 12(sp)		# (s3) for keeping 'loop-counter'
	lw	s4, 16(sp)		# (s4) for keeping 'nodes-counter'
	lw	s5, 20(sp)		# (s5) for keeping 'source-node' and 'min-index'
	lw	s6, 24(sp)		# (s6) for keeping 'base of shortest-path-tree-set'
	lw	s7, 28(sp)		# (s7) for keeping 'base of distances'
	lw	s8, 32(sp)		# (s8) for keeping a temp var in loop3
	
	lw	ra, 0(sp)		# restoring return-address
	addi	sp, sp, 36		# restoring stack-pointer to pervious position
	
	jalr	zero, 0(ra)		# return, base of distances in (a0)
	
	
# ----------------------------------------------------
# Finding min-distance
# ----------------------------------------------------
# ------------------- parameters ---------------------	
# 'base of shortest-path-tree-set' in (a0)
# 'base of distances-array' in        (a1)
# 'nodes-count' in                    (a2)
# ----------------------------------------------------
# return: 'min-index' in (a0)
# ----------------------------------------------------
minDistance:
	addi	sp, sp, -28		# reducing stack-pointer
	
	sw	ra, 0(sp)		# saving return-address in the stack
	
	# storing saved-registers into the stack
	
	sw	s0, 4(sp)		# (s0) for keeping 'base of shortest-path-tree-set'
	sw	s1, 8(sp)		# (s1) for keeping 'base of distances-array'
	sw	s2, 12(sp)		# (s2) for keeping 'nodes-count'
	sw	s4, 16(sp)		# (s4) for keeping 'nodes-counter' (loop-counter)
	sw	s5, 20(sp)		# (s5) for keeping 'min-value'
	sw	s6, 24(sp)		# (s6) for keeping 'min-index'
	
	mv	s0, a0			# 'base of shortest-path-tree-set'(s0) = 'base of shortest-path-tree-set parameter'(a0)
	mv	s1, a1			# 'base of distances-array'(s1) = 'base of distances-array parameter'(a1)
	mv	s2, a2			# 'nodes-count'(s2) = 'nodes-count parameter'(a2)
		
	mv	s5, s10			# initialzation 'min-value'(s5) = 'MAX_VALUE'(s10)
	li	s6, -1			# initialzation 'min-index'(s6) = -1
	
	li	s4, 0			# initialzation 'nodes-counter'(s4) = 0
	
	minDistance_loop:
		# checking 'nodes-counter'(s4) is less than 'nodes-count'(s2), else break.
		bge	s4, s2, minDistance_end
		
		mv	a0, s0				# 'getItem base argument'(a0) = 'base of shortest-path-tree-set'(s0)
		li	a1, 1				# 'getItem rows argument'(a1) = 1 for all arrays
		mv	a2, s2				# 'getItem cols argument'(a2) = 'nodes-count'(s2)
		li	a3, 0				# 'getItem row-index argument'(a3) = 0 for all arrays
		mv	a4, s4				# 'getItem col-index argument'(a4) = 'nodes-counter'(s4)
		
		jal	getItem				# getting sptSet[0][nodes-counter], it will be in (a0)
		
		# checking 'sptSet[0][nodes-counter]'(a0) == 'false'(0), else continue.
		bne	a0, zero, minDistance_continue
		
		mv	a0, s1				# 'getItem base argument'(a0) = 'base of distances-array'(s1)
		li	a1, 1				# 'getItem rows argument'(a1) = 1 for all arrays
		mv	a2, s2				# 'getItem cols argument'(a2) = 'nodes-count'(s2)
		li	a3, 0				# 'getItem row-index argument'(a3) = 0 for all arrays
		mv	a4, s4				# 'getItem col-index argument'(a4) = 'nodes-counter'(s4)
		
		jal	getItem				# getting distances[0][vertex-counter], it will be in (a0)
		
		# checking 'distances[0][nodes-counter]'(a0) <= min-value(s5), else continue.
		blt 	s5, a0, minDistance_continue
		
		mv	s5, a0				# 'min-value'(s5) = 'distances[0][nodes-counter]'(a0)
		mv	s6, s4				# 'min-index'(s6) = 'nodes-counter'(s4)
		
	minDistance_continue:
		addi	s4, s4, 1			# 'nodes-counter'(s4) += 1
		jal	minDistance_loop		# jump to loop
	minDistance_end:
	
	mv	a0, s6			# 'min-index return'(a0) = 'min-index'(s6)
	
	# restoring saved-registers from the stack
	
	lw	s0, 4(sp)		# (s0) for keeping 'base of shortest-path-tree-set'
	lw	s1, 8(sp)		# (s1) for keeping 'base of distances-array'
	lw	s2, 12(sp)		# (s2) for keeping 'nodes-count'
	lw	s4, 16(sp)		# (s4) for keeping 'nodes-counter' (loop-counter)
	lw	s5, 20(sp)		# (s5) for keeping 'min-value'
	lw	s6, 24(sp)		# (s6) for keeping 'min-index'
	
	lw	ra, 0(sp)		# restoring return-address from the stack
	addi	sp, sp, 28		# restore stack-pointer to pervious position
	
	jalr	zero, 0(ra)		# return, 'min-index' in (a0)
	
	
# ----------------------------------------------------
# printing shortest distances from a specific source
# ----------------------------------------------------
# ------------------- parameters ---------------------	
# 'base of adjacency matrix' in (a0)
# 'nodes-count'	             in (a1)
# 'source-node'              in (a5)
# ----------------------------------------------------
# void
# ----------------------------------------------------
printDistances:
	addi	sp, sp, -20		# reducing stack-pointer	
			
	sw	ra, 0(sp)		# saving return-address in the stack
	
	# storing saved-registers into the stack
	
	sw	s0, 4(sp)		# (s0) for keeping 'adjacency-matrix-base'
	sw	s2, 8(sp)		# (s2) for keeping 'nodes-count'(cols-count)
	sw	s4, 12(sp)		# (s4) for keeping 'cols-counter' (loop-counter)
	sw	s5, 16(sp)		# (s5) for keeping 'source-node'
	
	mv	s0, a0			# 'adjacency-matrix-base'(s0) = 'adjacency-matrix-base parameter'(a0)
	mv	s2, a1			# 'nodes-count'(s2) = 'nodes-count parameter'(a1)
	mv	s5, a5			# 'source-node'(s5) = 'source-node parameter'(a5)
	la	a0, str_distances	# load "distances:" string for printing
	jal	printStr		# printing "distances:" string
	
	li	s4, 0			# initialzation 'cols-counter'(s4) = 0
	
	printDistances_loop:
		bgeu	s4, s2, printDistances_end	# Checking 'cols-counter'(s4) < 'nodes-count'(s2), else break
		
		mv	a0, s5				# 'int-item'(a0) for printing = 'source-node'(s5)
		jal	printInt			# printing source node
		
		la	a0, str_to			# loading " to " string for printing
		jal	printStr			# printing " to " string
		
		mv	a0, s4				# 'int-item'(a0) for printing = 'rows-counter'(s4) => it's destination node
		jal	printInt			# printing destination node
		
		la	a0, str_colon			# loading " : " string for printing
		jal	printStr			# printing " : " string
		
		la	a0, str_TAB			# loading "\t" string for printing
		jal	printStr			# printing "\t" string
		
		mv	a0, s0				# 'getItem base argument'(a0) = 'adjacency-matrix-base'(s0)
		li	a1, 1				# 'getItem rows argument'(a1) = 1 for all arrays
		mv	a2, s2				# 'getItem cols argument'(a2) = 'nodes-count'(s2)
		li	a3, 0				# 'getItem row-index argument'(a3) = 0 for all arrays
		mv	a4, s4				# 'getItem col-index argument'(a4) = 'cols-counter'(s4)
		
		jal	getItem				# getting distance[0][cols-counter], it will be in (a0)
		jal	printInt			# printing distance[0][cols-counter]
		
		la	a0, str_NL			# loading "\n" string for printing
		jal	printStr			# printing "\n" string
		
		addi	s4, s4, 1			# 'cols-counter'(s4) += 1
		
		jal	printDistances_loop		# jump to loop
	printDistances_end:
	# restore return-address from stack
	
	
	# restoring saved-registers from the stack
	
	lw	s0, 4(sp)		# (s0) for keeping 'adjacency-matrix-base'
	lw	s2, 8(sp)		# (s2) for keeping 'nodes-count'(cols-count)
	lw	s4, 12(sp)		# (s4) for keeping 'cols-counter' (loop-counter)
	lw	s5, 16(sp)		# (s5) for keeping 'source-node'
	
	lw	ra, 0(sp)		# restoring return-address from the stack
	addi	sp, sp, 20		# restore stack-pointer to pervious position
	
	jalr	zero, 0(ra)		# return, void
	
	
# ----------------------------------------------------
# allocating adjacency matrix and get items from input
# ----------------------------------------------------
# ------------------- parameters ---------------------	
# 'nodes-count' in (a0)
# ----------------------------------------------------
# return: 'base of adjacency matrix' in (a0)
# ----------------------------------------------------
readGraph:
	addi	sp, sp, -24		# reducing stack-pointer
	
	sw	ra, 0(sp)		# saving return-address in the stack
	
	# storing saved-registers into the stack
	
	sw	s0, 4(sp)		# (s0) for keeping 'adjacency-matrix-base'
	sw	s1, 8(sp)		# (s1) for keeping 'nodes-count'
	sw	s3, 12(sp)		# (s3) for keeping 'rows-counter'
	sw	s4, 16(sp)		# (s4) for keeping 'cols-counter'
	sw	s5, 20(sp)		# (s5) for keeping 'edge-value'
	
	# saving nodes-count in a saved-register for using in the loops
	mv	s1, a0			# 'nodes-count'(s1) = 'nodes-count-parameter'(a0)
	
	# arguments for allocating the adjacency matrix
	mv	a1, a0			# 'matrix-rows'(a1) = 'nodes-count'(a0)
	mv	a2, a0			# 'cols-count'(a2)  = 'nodes-count'(a0)
	jal	matrixAlloc		# allocating the adjacency matrix, base of it will be in (a0)
	
	mv	s0, a0			# 'adjacency-matrix-base'(s0) = allocated matrix(a0)
	
	
	li	s3, 0			# initialzation 'rows-counter'(s3) = 0
	
	readGraph_loop1:
		# checking 'rows-counter'(s3) is less than 'nodes-count'(s1), else break
		bge	s3, s1, readGraph_end1
		
		addi	s4, s3, 1	# initialzation 'cols-counter'(s4) = 'rows-counter'(s3) + 1
			readGraph_loop2:
				# checking 'cols-counter'(s4) is less than 'nodes-count'(s1), else break.
				bge	s4, s1, readGraph_end2
				
				# printing messages for reading graph edges
				
				la	a0, str_enterEdge	# loading "edge " string for printing
				jal	printStr		# printing "edge " string
				
				mv	a0, s3			# 'int-item'(a0) for print = 'rows-counter'(s2)	=> it's source node
				jal	printInt		# printing source node
				
				la	a0, str_between		# loading " to " string for printing
				jal	printStr		# printing " to " string
				
				mv	a0, s4			# 'int-item'(a0) for print = 'cols-counter'(s3) => it's destination node
				jal	printInt		# printing destination node
				
				
				la	a0, str_colon		# loading ":" string for printing
				jal	printStr		# printing ":" string
				
				# reading edge-value from input
				jal	readInt			# reading edge-value, it will be in (a0)
				
				mv	s5, a0			# 'edge-value'(s5) = 'input-value'(a0)
				
				# preparation arguments for upper triangular setItem 
				mv	a0, s0			# 'setItem base argument'(a0) = 'adjacency-matrix-base'(s0)
				mv	a1, s1			# 'setItem rows argument'(a1) = 'nodes-count'(s1)
				mv	a2, s1			# 'setItem cols argument'(a2) = 'nodes-count'(s1)
				mv	a3, s3			# 'setItem row-index argument'(a3) = 'rows-counter'(s3)
				mv	a4, s4			# 'setItem col-index argument'(a4) = 'cols-counter'(s4)
				mv	a5, s5			# 'setItem item-value argument'(a5) = 'edge-value'(s5)
				
				jal	setItem			# setting edge-value upper triangular
				
				# preparation arguments for lower triangular setItem		
				mv	a0, s0			# 'setItem base argument'(a0) = 'adjacency-matrix-base'(s0)
				mv	a1, s1			# 'setItem rows argument'(a1) = 'nodes-count'(s1)
				mv	a2, s1			# 'setItem cols argument'(a2) = 'nodes-count'(s1)
				mv	a3, s4			# 'setItem row-index argument'(a3) = 'cols-counter'(s4)
				mv	a4, s3			# 'setItem col-index argument'(a4) = 'rows-counter'(s3)
				mv	a5, s5			# 'setItem item-value argument'(a5) = 'edge-value'(s5)
				
				jal	setItem			# setting edge-value for lower triangular
				
				addi	s4, s4, 1		# 'cols-counter'(s4) += 1
				jal	readGraph_loop2		# jump to loop2
			readGraph_end2:
			
			addi	s3, s3, 1			# 'row-counter'(s3) += 1
			jal	readGraph_loop1			# jump to loop1
	readGraph_end1:
	mv		a0, s0		# return-value(a0) = 'adjacency-matrix-base'(s0)
	
	# restoring saved-registers from the stack
	
	lw	s0, 4(sp)		# (s0) for keeping 'adjacency-matrix-base'
	lw	s1, 8(sp)		# (s1) for keeping 'nodes-count'
	lw	s3, 12(sp)		# (s3) for keeping 'rows-counter'
	lw	s4, 16(sp)		# (s4) for keeping 'cols-counter'
	lw	s5, 20(sp)		# (s5) for keeping 'edge-value'
	
	lw	ra, 0(sp)		# restoring return-address from the stack
	
	addi	sp, sp, 24		# restore stack-pointer to pervious position
	
	jalr	zero, 0(ra)		# return, 'base of adjacency matrix' in (a0)
		
		
# ----------------------------------------------------
# allocating new matrix from the heap
# ----------------------------------------------------
# ------------------- parameters ---------------------
# 'matrix-rows' in  (a1)
# 'matrix-cols' in  (a2)
# ----------------------------------------------------
# return: base of allocated matrix in (a0)
# ----------------------------------------------------
matrixAlloc:
	slli	a0, a2, 2		# row-bytes(a0) = matrix-cols(a2) * 4 => each row needs cols * 4 bytes
	mul	a0, a0, a1		# matrix-bytes(a1) = matrix-rows(a1) * row-bytes(a0)
	
	li, 	a7, 9			# loading syscall 9 for allocating from the heap
	ecall				# run allocating syscall
	
	jalr	ra, 0(ra)		# return, base of allocated matrix in (a0)

# ----------------------------------------------------
# getting an item from matrix by row-index, col-index
# ----------------------------------------------------
# ------------------- parameters ---------------------
# 'matrix-base' in (a0)
# 'matrix-rows' in (a1)
# 'matrix-cols' in (a2)
# 'row-index'   in (a3)
# 'col-index'   in (a4)
# ----------------------------------------------------
# return: 'item-value' in (a0)
# ----------------------------------------------------
getItem:
	addi	sp, sp, -4		# reducing stack-pointer
	sw	ra, 0(sp)		# saving return-address in the stack
	
	jal	getItemAddress 		# calculating item-address, it will be in (a0)
	
	lw	a0, 0(a0)		# loading item-value from calculated address, it will be in (a0)
	
	lw	ra, 0(sp)		# restoring return-address from the stack
	addi	sp, sp, 4		# increasing stack-pointer
	
	jalr	zero, 0(ra)		# return, item-value in (a0)
	
	
# ----------------------------------------------------
# Setting an item in matrix by row-index, col-index
# ----------------------------------------------------
# ------------------- parameters ---------------------
# 'matrix-base' in (a0)
# 'matrix-rows' in (a1)
# 'matrix-cols' in (a2)
# 'row-index'   in (a3)
# 'col-index'   in (a4)
# 'item-value'  in (a5)
# ----------------------------------------------------
# void
# ----------------------------------------------------
setItem:
	addi	sp, sp, -4		# reducing stack-pointer
	sw	ra, 0(sp)		# saving return-address in the stack
	
	jal	getItemAddress 		# calculating item-address, item-address will be in (a0)
	
	sw	a5, 0(a0) 		# saving item-value(a5) for calculated address
	
	lw	ra, 0(sp)		# restoring return-address from the stack
	addi	sp, sp, 4		# restoring stack-pointer to the previous position
	
	jalr	zero, 0(ra) 		# return, void
	
	
# ----------------------------------------------------
# Getting bytes-address for an item in matrix
# ----------------------------------------------------
# ------------------- parameters ---------------------
# 'matrix-base' in (a0)
# 'matrix-rows' in (a1)
# 'matrix-cols' in (a2)
# 'row-index'   in (a3)
# 'col-index'   in (a4)
# ----------------------------------------------------
# return: 'item-address' in (a0)
# ----------------------------------------------------
getItemAddress:
	bge	a3, a1, outOfBound	# check row-index(a3) < matrix-rows(a1), else out-of-bound
	bge	a4, a2, outOfBound 	# check col-index(a4) < matrix-cols(a2)
	
	slli	t0, a2, 2		# row-bytes(t0) = matrix-cols(a2) * 4 (int-size)
	mul	t0, a3, t0		# rows-offset(t0) = row-index(a3) * row-bytes(t0)
	slli	t1, a4, 2		# cols-offset(t1) = col-index(a4) * 4 (int-size)
	add	t0, a0, t0		# row-address(t0) = matrix-base(a0) + rows-offset(t0)
	add	a0, t0, t1		# address(a0) = row-address(t0) + cols-offset(t1)
	
	jalr	zero, 0(ra)		# return, item-address in (a0)


# ----------------------------------------------------
# Printing matrix to the console
# ----------------------------------------------------
# ------------------- parameters ---------------------
# 'matrix-base' in (a0)
# 'matrix-rows' in (a1)
# 'matrix-cols' in (a2)
# ----------------------------------------------------
# void
# ----------------------------------------------------
printMatrix:
	addi	sp, sp, -24		# reducing stack-pointer
	
	sw	ra, 0(sp)		# saving return-address in the stack
	
	# saving saved-register in the stack
	sw	s0, 4(sp)		# (s0) for keeping 'matrix-base'
	sw	s1, 8(sp)		# (s1) for keeping 'matrix-rows'
	sw	s2, 12(sp)		# (s2) for keeping 'matrix-cols'
	sw	s3, 16(sp)		# (s3) for keeping 'rows-counter'
	sw	s4, 20(sp)		# (s4) for keeping 'cols-counter'
	
	mv	s0, a0			# 'matrix-base'(s0) = 'matrix-base-parameter'(a0)
	mv	s1, a1			# 'matrix-rows'(s1) = 'matrix-rows-parameter'(a1)
	mv	s2, a2			# 'matrix-cols'(s2) = 'matrix-cols-parameter'(a1)
	
	li	s3, 0			# initialzation 'rows-counter'(s3) = 0
	printMatrix_loop1:
		# checking 'rows-counter'(s3) is less than 'matrix-rows'(s1), else break
		bge	s3, s1, printMatrix_end1
		
		li	s4, 0		# initialzation 'cols-counter'(s4) = 0
		printMatrix_loop2:
			# checking 'cols-counter'(s4) is less than 'matrix-cols'(s2), else break
			bge	s4, s2, printMatrix_end2
			
			# preparation arguments for getItem, matrix[rows-counter][cols-counter]
			mv	a0, s0		# 'getItem base-address argument'(a0) = 'matrix-base'(s0)
			mv	a1, s1		# 'getItem rows argument'(a1) = 'matrix-rows'(s1)
			mv	a2, s2		# 'getItem cols argument'(a2) = 'matrix-cols'(s2)
			mv	a3, s3		# 'getItem row-index argument'(a3) = 'rows-counter'(s3)
			mv	a4, s4		# 'getItem col-index argument'(a4) = 'cols-counter'(s4)
			
			jal	getItem		# getting matrix[rows-counter][cols-counter], it will be in (a0)
			jal	printInt	# printing matrix[rows-counter][cols-counter] to the console
			
			la	a0, str_TAB	# loading "\t" string for printing
			jal	printStr	# printing "\t" string
			
			addi	s4, s4, 1	# 'cols-counter'(s4) += 1
			jal	printMatrix_loop2 	# jump to loop2
		printMatrix_end2:
		
		la	a0, str_NL		# loading "\n" string for printing
		jal	printStr		# printing "\n" string
		
		addi	s3, s3, 1		# 'rows-counter'(s3) += 1
		jal	printMatrix_loop1	# jump to loop1
	printMatrix_end1:
	
	# restoring saved-register from the stack
	lw	s0, 4(sp)		# (s0) for keeping 'matrix-base'
	lw	s1, 8(sp)		# (s1) for keeping 'matrix-rows'
	lw	s2, 12(sp)		# (s2) for keeping 'matrix-cols'
	lw	s3, 16(sp)		# (s3) for keeping 'rows-counter'
	lw	s4, 20(sp)		# (s4) for keeping 'cols-counter'
	
	lw	ra, 0(sp)		# restoring return-address in the stack
	addi	sp, sp, 24		# restoring stack-pointer to the previous position
	
	jalr 	zero, 0(ra)		# return, void


# ----------------------------------------------------
# Reading int number from the console
# ----------------------------------------------------
# ------------------- parameters ---------------------
# N/A
# ----------------------------------------------------
# return: int number in (a0)
# ----------------------------------------------------
readInt:
	li	a7, 5			# loading syscal(5) for reading int to the (a7)
	ecall				# reading int-number from the console, it will be in (a0)
	
	jalr	zero, 0(ra)		# return, int-number in (a0)


# ----------------------------------------------------
# Printing int number to the console
# ----------------------------------------------------
# ------------------- parameters ---------------------
# 'int-number' in (a0)
# ----------------------------------------------------
# void
# ----------------------------------------------------
printInt:
	li	a7, 1			# load syscal(1) to the (a7) for printing int 
	ecall				# printing int-number to the console
	
	jalr	zero, 0(ra)		# return, void
	
	
# ----------------------------------------------------
# Printing string to the console
# ----------------------------------------------------
# ------------------- parameters ---------------------
# 'string' in (a0)
# ----------------------------------------------------
# void
# ----------------------------------------------------
printStr:
	li	a7, 4			# load syscal(4) to the (a7) for printing string
	ecall				# printing string to the console
	
	jalr	zero, 0(ra)		# return, void
	
	
# ----------------------------------------------------
# Occurring out of bound error, exiting by code 1
# ----------------------------------------------------
# ------------------- parameters ---------------------
# N/A
# ----------------------------------------------------
# void
# ----------------------------------------------------
outOfBound:
	la	a0, str_outOfBound 	# loading 'out-of-bound-message' string
	jal	printStr		# printing 'out-of-bound-message' string
	
	li	a0, 1			# loading exit-code 1
	li	a7, 93			# load syscal(93) to the (a7) for exiting program
	ecall				# exit program by code 1


# ----------------------------------------------------
# Exiting program by normal flow
# ----------------------------------------------------
# ------------------- parameters ---------------------
# N/A
# ----------------------------------------------------
# void
# ----------------------------------------------------
exit:
	li	a0, 0			# loading exit-code 0
	li	a7, 93			# load syscal(93) to the (a7) for exiting program
	ecall				# exit program by code 0
