.data
matrix: .word 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25

# strings
str_outOfBound:	.asciz	"index out of bound!"
str_LB:		.asciz	"["
str_RB:		.asciz	"]"
str_EQ:		.asciz	" = "

.text

la 	s0, matrix
li 	s1, 5
li 	a0, 2
li	a1, 2
jal	printEdge
jal	exit




# 'matrix-base' in          	(s0)
# 'matrix-size' in          	(s1)
# 'row-index'   in          	(a0) 
# 'col-index'   in          	(a1)
# return: 'edge-value' in   	(a0)
getEdge:
	# save 'return-address' to stack
	addi	sp, sp, -4
	sw	ra, 0(sp)
	
	jal	getEdgeAdrress 		# 'edge-address' in (a0)
	
	# load 'return-address' from stack
	lw	ra, 0(sp)
	addi	sp, sp, 4
	
	lw	a0, 0(a0)		# load 'edge-value' from array[(a0)][(a1)]
	jalr	zero, 0(ra)		# return 'edge-value'


# 'matrix-base' in          	(s0)
# 'matrix-size' in         	(s1)
# 'row-index'   in          	(a0)
# 'col-index'   in          	(a1)
# 'edge-value'  in          	(a2)
setEdge:
	# save 'return-address' to stack
	addi	sp, sp, -4
	sw	ra, 0(sp)
	
	jal	getEdgeAdrress 		# 'edge-address' in (a0)
	
	# load 'return-address' from stack
	lw	ra, 0(sp)
	addi	sp, sp, 4
	
	sw	a2, 0(a0) 		# save 'edge-value' in array[(a0)][(a1)]
	jalr	zero, 0(ra) 		# return
	
	
# 'matrix-base' in          	(s0)
# 'matrix-size' in          	(s1)
# 'row-index'   in          	(a0)
# 'col-index'   in          	(a1)
# return: 'edge-address' in 	(a0)
getEdgeAdrress:
	bgeu	a0, s1, outOfBound 	# check 'row-index' < 'matrix-size'
	bgeu	a1, s1, outOfBound 	# check 'col-index' < 'matrix-size'
	slli	t0, s1, 2		# 'row-size' = `matrix-rows-count` * 4 (int-size)
	mul	t0, t0, a0		# 'row-index' * 'row-size' (to find rows-offset)
	slli	t1, a1, 2		# 'col-index' * 4 (int-size) (to find cols-offset)
	add	t0, s0, t0		# address = base + rows-offset
	add	a0, t0, t1		# address += cols-offset
	jalr	zero, 0(ra)		# return address


# 'matrix-base' in          	(s0)
# 'matrix-size' in          	(s1)
# 'row-index'   in          	(a0)
# 'col-index'   in          	(a1)
printEdge:
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
	jal	getEdge			# get 'edge-value' in (a0)
	jal	printInt		# print 'edge-value'
	
	# load 'return-address' from stack
	lw	ra, 0(sp)
	addi	sp, sp, 4
	
	jalr 	zero, 0(ra)		# return
	

# number	in		(a0)	
printInt:
	li	a7, 1			# syscall for print int-number
	ecall				# print number
	jalr	zero, 0(ra)		# return
	
# string 	in	    	(a0)	
printStr:
	li	a7, 4			# syscall for print string
	ecall				# print string
	jalr	zero, 0(ra)		# return
	

outOfBound:
	la	a0, str_outOfBound 	# load 'out-of-bound-message' to (a0)
	jal	printStr		# print 'out-of-bound-message'
	jal	exit			# jump to exit

exit:
	
	
	
	
	