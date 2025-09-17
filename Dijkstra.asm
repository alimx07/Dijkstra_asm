.data
vertex_count: .word 26
# graph data (adjacent lists) (weight , node ,weight , node , ...,-1)
adj_a: .word 6,'R',7,'T',7,'L',11,'Z',8,'S',-1
adj_b: .word 6,'S',2,'L',9,'Y',-1
adj_c: .word 5,'U',7,'S',-1
adj_d: .word 2,'N',5,'V',7,'J',4,'Z',-1
adj_e: .word 2,'V',3,'W',4,'O',-1
adj_f: .word 2,'Y',8,'K',-1
adj_g: .word 2,'M',9,'S', -1
adj_h: .word 6,'T',5,'Z',-1
adj_i: .word 7,'Q',-1
adj_j: .word 4,'P',7,'D',-1
adj_k: .word 8,'F',8,'U',10,'S',-1
adj_l: .word 7,'A',5,'T',2,'B',-1
adj_m: .word 2,'G',4,'R',-1
adj_n: .word 2,'D',-1
adj_o: .word 1,'W',4,'E',-1
adj_p: .word 4,'J',6,'W',-1
adj_q: .word 5,'Z',7,'I',-1
adj_r: .word 4,'M',6,'A',-1
adj_s: .word 10,'K',8,'A',6,'B',7 ,'C',9,'G' , -1
adj_t: .word 6,'H',5,'L',7,'A',-1
adj_u: .word 8,'K',5,'C',-1
adj_v: .word 5,'D',2,'E',6,'X',-1
adj_w: .word 6,'P',3,'E',1,'O',-1
adj_x: .word 6,'V',-1
adj_y: .word 2,'F',9,'B',-1
adj_z: .word 5,'H',5,'Q',4,'D',11,'A',-1

graph: .space 104
dist: .word 9999:26                   # Distance array for each vertex
parents:  .word -1:26                     # parent array 
pq: .space 1000                           # Priority queue storage (max 64 entries, each 8 bytes)
size: .space 1                         # Current size of the priority queue
input: .space 2

inputPrompt: .asciiz "Enter Start Vertex(A-Z): "
error_msg: .asciiz "Invalid Input\n"
end_dijkstra: .asciiz "All Distances Calculated Successfully\n"
outputMsg: .asciiz "Node     Distance:\n "
exitMsg: .asciiz "Exit...\n"
space: .asciiz "       "
newline: .asciiz "\n"
success_msg: .asciiz "Valid input\n"
line : .asciiz " --> "
pathMsg : .asciiz "    Path : "

.text
.globl main
main:

   jal graph_init
   jal input_user
   jal dijkstra
   jal print_distances
   
   li $v0 , 4
   la $a0 , exitMsg
   syscall
   
   li $v0 , 10
   syscall
   
input_user:
   subi $sp , $sp , 4
   sw  $ra , 0($sp) 
   j input_loop
  
input_loop:

   li $v0 , 4
   la $a0 , inputPrompt
   syscall 
        
   # Read a character
   li $v0, 8
   la $a0, input
   li $a1, 2  # Limit input to 1 character + null terminator
   syscall
        
   # Check if input is exactly one character (excluding null terminator)
   la $t8 , input
   lb $t0, 0($t8)  # Load the character into $t0
   lb $t1, 1($t8)  # Should be null terminator
        
   beq $t1, $zero, check_uppercase  # If $t1 is null, input is valid
   j error_handler  # Otherwise, handle error

check_uppercase:
    # Check if the character is between 'A' and 'Z'
    li $t2, 65  # ASCII value of 'A'
    li $t3, 90  # ASCII value of 'Z'
    blt $t0, $t2, error_handler  # If less than 'A'
    bgt $t0, $t3, error_handler  # If greater than 'Z'
    
   li $v0 , 4
   la $a0 , newline
   syscall
   j exit_input

error_handler:
   # Display error message
   li $v0 , 4
   la $a0 , newline
   syscall
   li $v0, 4
   la $a0, error_msg
   syscall
   li $v0 , 4
   la $a0 , newline
   syscall
   j input_loop  # Optionally loop back to retry

   
exit_input:

  move $a0 , $t0  # start vertex to be passed to next function
  lw $ra , 0($sp)  # restore the stack
  addi $sp , $sp , 4
  jr $ra
   


dijkstra:

  subi $sp , $sp , 4
  sw $ra , 0($sp)
  
  la $s4 dist
  la $s5 , graph
  la $s6 , adj_a
  la $s7 , size
  
  subi $t0 , $0 , 1
  sw $t0 , size
  
  subi $a0 , $a0 ,65
  sll $t0 , $a0 , 2 #offset calculation
  add $t0 , $s4 , $t0
  
  sw $0 , 0($t0) # dist[start] = 0
  
  sll $a0 , $a0 , 16
  jal insert # insert (0,startnode)

  

  jal dijkstra_loop_init
  
  
  
  lw $ra , 0($sp)
  addi $sp , $sp , 4
  
   
  jr $ra 

dijkstra_loop_init:

   subi $sp , $sp , 4
   sw $ra , 0($sp)
   
   j dijkstra_loop
   
dijkstra_loop : 

   li $t0 , 1
   lw $t1 , size
   
   slti $t1 , $t1 , 0
   

   beq $t1 , $t0 , exit_dijkstra_loop
   

   jal extractMin

   
   srl $s0 , $v0 , 16  # get node which in the upper 16 bits
   andi $s1 , $v0 , 0xffff # and with 111....11 to get the value of lower 16 bit (weight)
   
 
  
   subi $sp , $sp ,4
   lw $ra , 0($sp)
   jal nested_dijkstra
   sw $ra ,0($sp)
   addi $sp , $sp , 4
   

    
   j dijkstra_loop
   

   
exit_dijkstra_loop:
   li $v0 , 4
   la $a0 , end_dijkstra
   syscall
   li $v0 , 4
   la $a0 , newline
   syscall
   lw $ra , 0($sp)
   addi $sp , $sp , 4
   jr $ra 


nested_dijkstra:

   subi $sp , $sp , 4
   sw $ra , 0($sp)
   
   sll $t1 , $s0 , 2
   add $t0 , $s5 , $t1
   lw $t8 , 0($t0) 
   
   li $t7 , 0
   

   j nested_dijkstra_loop
   

   

# $t7 pointer in adjlist everyloop += 2
# $t0 ww
# $t1 v

nested_dijkstra_loop:

   sll $t3 , $t7 , 2
   add $t3 , $t3 , $t8
   
   lw $t0 , 0($t3)  # ww
   
   subi $t9 , $0 , 1
   beq $t0 , $t9 , exit_nested
   
   addi $t3 , $t3 , 4
   
   lw $t1 , 0($t3) # v
   subi $t1 , $t1 , 65
   

   sll $t3 , $t1 , 2
   add $t3 , $t3 , $s4
   
   lw $s2 , 0($t3) # dist[v]
   
   sll $t3 , $s0 , 2
   add $t3 , $t3 , $s4
   
   lw $t4 , 0($t3) # dist[node]

   
   add $s3 , $t4 , $t0 
   
   slt $t2 , $s3 , $s2
   
   li $t3 , 1
   
   beq $t2 , $t3 , insert_init
   
   addi $t7 , $t7 , 2
   
   j nested_dijkstra_loop
   

exit_nested:
   lw $ra , 0($sp)
   addi $sp , $sp , 4

   jr $ra 


insert_init: 

  
  sll $t2 , $t1 , 2
  sw  $s0 , parents($t2)                 ############ Modified here
  add $t2 , $t2 , $s4
  
  sw $s3 , 0($t2)  # swap
  move $s2 , $s3
  
  sll $a0 , $t1 , 16  # node in leftmost 16 bits ( $t1 node )
  or $a0 , $a0 , $t0  # add in first 16 bits the weight ($t0 weight)
  
  subi $sp , $sp , 4
  sw $ra , 0($sp)
  jal insert  # insert(dist[v] ,v)
  lw $ra , 0($sp)
  addi $sp , $sp , 4

  
  addi $t7 , $t7 , 2
   
  j nested_dijkstra_loop
   
print_distances:

  sub $sp , $sp , 4
  sw $ra , 0($sp)
  li $v0 , 4
  la $a0 , outputMsg
  syscall
  la $t9 , dist
  lw $t8 , vertex_count
  move $t0 , $0
  jal print_loop
  lw $ra , 0($sp)
  add $sp , $sp , 4
  jr $ra
  
  
print_loop:
   
   sub $sp , $sp , 4
   sw $ra , 0($sp)
   
   beq $t0 , $t8 , end_print_loop
   addi $t6 , $t0 , 65
   li $v0 , 11
   move $a0 , $t6
   syscall 
   
   li $v0 , 4
   la $a0 , space
   syscall
   
   sll $t1 , $t0 , 2
   add $t1 , $t9 , $t1
   
   li $v0 , 1
   lw $a0 , 0($t1)
   syscall 
   
    ################################## ----->>>>    call the function here 
    li $v0 , 4
    la $a0 , pathMsg 
    syscall 
   
    move $a0 , $t0 
   
   subi $sp , $sp , 8 
   sw   $ra ,4($sp) 
   sw   $a0 ,0($sp) 
   
   jal print_path
   
   lw   $ra ,4($sp) 
   lw   $a0 ,0($sp)  
   addi $sp , $sp , 8 
   #####################################
   
   addi $t0 , $t0 , 1
   
   li $v0 , 4
   la $a0 , newline
   syscall
   
   j print_loop
   
   
end_print_loop:
   
   lw $ra 0($sp)
   add $sp , $sp , 4
   
   jr $ra
   
#################################################   ---->>>> the function 
print_path: 
subi $sp , $sp , 8 
sw   $ra , 4($sp)  
sw   $a0 , 0($sp)

bne  $a0 , -1 , rec_function 
addi $sp , $sp , 8 
jr   $ra

rec_function :
sll $s5, $a0 ,2
lw  $a0 , parents($s5) 
jal print_path 

 li $v0 , 4
 la $a0 , line
 syscall  
 

lw   $ra , 4($sp)  
lw   $a0 , 0($sp) 
addi $sp ,$sp ,8   
 
 li $v0 , 11
 addi $a0 , $a0 , 65 
 move $a0 , $a0 
 syscall 

jr $ra    
#########################################################3
   
graph_init:
    la $t0, graph    # Load the base address of the graph

    la $t1, adj_a    # Load the address of adj_a
    sw $t1, 0($t0)   # Store the address in graph[0]

    addi $t0, $t0, 4 # Move to the next element in the graph
    la $t1, adj_b    # Load the address of adj_b
    sw $t1, 0($t0)   # Store the address in graph[1]

    addi $t0, $t0, 4 # Next element
    la $t1, adj_c    # Load the address of adj_c
    sw $t1, 0($t0)

    addi $t0, $t0, 4
    la $t1, adj_d
    sw $t1, 0($t0)

    addi $t0, $t0, 4
    la $t1, adj_e
    sw $t1, 0($t0)

    addi $t0, $t0, 4
    la $t1, adj_f
    sw $t1, 0($t0)

    addi $t0, $t0, 4
    la $t1, adj_g
    sw $t1, 0($t0)

    addi $t0, $t0, 4
    la $t1, adj_h
    sw $t1, 0($t0)

    addi $t0, $t0, 4
    la $t1, adj_i
    sw $t1, 0($t0)

    addi $t0, $t0, 4
    la $t1, adj_j
    sw $t1, 0($t0)

    addi $t0, $t0, 4
    la $t1, adj_k
    sw $t1, 0($t0)

    addi $t0, $t0, 4
    la $t1, adj_l
    sw $t1, 0($t0)

    addi $t0, $t0, 4
    la $t1, adj_m
    sw $t1, 0($t0)

    addi $t0, $t0, 4
    la $t1, adj_n
    sw $t1, 0($t0)

    addi $t0, $t0, 4
    la $t1, adj_o
    sw $t1, 0($t0)

    addi $t0, $t0, 4
    la $t1, adj_p
    sw $t1, 0($t0)

    addi $t0, $t0, 4
    la $t1, adj_q
    sw $t1, 0($t0)

    addi $t0, $t0, 4
    la $t1, adj_r
    sw $t1, 0($t0)

    addi $t0, $t0, 4
    la $t1, adj_s
    sw $t1, 0($t0)

    addi $t0, $t0, 4
    la $t1, adj_t
    sw $t1, 0($t0)

    addi $t0, $t0, 4
    la $t1, adj_u
    sw $t1, 0($t0)

    addi $t0, $t0, 4
    la $t1, adj_v
    sw $t1, 0($t0)

    addi $t0, $t0, 4
    la $t1, adj_w
    sw $t1, 0($t0)

    addi $t0, $t0, 4
    la $t1, adj_x
    sw $t1, 0($t0)

    addi $t0, $t0, 4
    la $t1, adj_y
    sw $t1, 0($t0)

    addi $t0, $t0, 4
    la $t1, adj_z
    sw $t1, 0($t0)

    jr $ra   # Return to caller

   
  
   
################################################################################################################################

   
#$a0 -- i
# Function to return the index of the parent
# parent node of a given node
#retuen in $v0
parent:

subi $sp, $sp, 4     # adjust stack to make room for 1 items
sw   $a0, 0($sp)     # save register $a0

subi $a0,$a0,1	     # i-1
srl  $a0,$a0,1       #(i-1)/2
move $v0,$a0         # return at $v0

lw   $a0, 0($sp)     # restore $a0
addi $sp, $sp, 4     # restore stack or 1 items

jr   $ra

#$a0 -- i
# Function to return the index of the left child
# left child of the given node
#retuen in $v0
leftChild:
subi $sp, $sp, 4     # adjust stack to make room for 1 items
sw   $a0, 0($sp)     # save register $a0

sll  $a0,$a0,1       #2*i
addi $a0,$a0,1	     #2*i + 1 
move $v0,$a0	     # return at $v0

lw   $a0, 0($sp)     # restore $a0
addi $sp, $sp, 4     # restore stack or 1 items

jr   $ra

#$a0 -- i
# Function to return the index of the right child
# right child of the given node
#retuen in $v0
rightChild:

subi $sp, $sp, 4     # adjust stack to make room for 1 items
sw   $a0, 0($sp)     # save register $a0

sll $a0,$a0,1        #2*i
addi $a0,$a0,2	     #2*i + 2 
move $v0,$a0	     # return at $v0

lw   $a0, 0($sp)     # restore $a0
addi $sp, $sp, 4     # restore stack or 1 items


jr   $ra

#$a0 -- i
# Function to shift up the node in order
# to maintain the heap property
# don't have a retuen value
shiftUp:
subi $sp, $sp, 24     # adjust stack to make room for 5 items
sw   $t5, 20($sp)     # save register $t5
sw   $t4, 16($sp)     # save register $t4 
sw   $t3, 12($sp)     # save register $t3  H[i]
sw   $t2, 8($sp)      # save register $t2  --> H[parent(i)]
sw   $t1, 4($sp)      # save register $t1 for conditioning
sw   $t0, 0($sp)      # save register $t0  for i

move $t0,$a0

loop:

#if(0 < i && H[parent(i)] < H[i])
slt $t1,$0,$t0         #0 < i

subi $sp, $sp,8        # adjust stack for 2 items
sw   $ra, 4($sp)       # save the return addres
sw   $a0,0($sp)	       # save the parmeter register

move $a0,$t0
jal parent             #parent(i)

lw $a0,0($sp)          # restore the parmeter register
lw $ra, 4($sp)         #restore the return address 
addi $sp, $sp, 8       # adjust stack for 2 items 


sll $t0,$t0,2          #adjust offset
sll $v0,$v0,2	       #adjust offset
lw  $t2,pq($v0)       #H[parent(i)]
lw  $t3,pq($t0)       #H[i]

andi $t5 , $t2 , 0xffff # 1011110111   --> and 1111 --> 0111
andi $t6 , $t3 , 0xffff

slt $t4,$t6,$t5        #H[parent(i)] > H[i]

and $t7,$t4,$t1
beq $t7,$0,exit0 

#swap(H[parent(i)], H[i]);
sw  $t2,pq($t0)
sw  $t3,pq($v0)
srl $v0,$v0,2

# Update i to parent of i
move $t0,$v0   #i = parent(i);
j loop

exit0:
lw   $t0, 0($sp)     # restore register $t0 for caller
lw   $t1, 4($sp)     # restore register $t1 for caller
lw   $t2, 8($sp)     # restore register $t2 for caller
lw   $t3, 12($sp)    # restore register $t3 for caller
lw   $t4, 16($sp)    # restore register $t4 for caller
lw   $t5, 20($sp)    # restore register $t5 for caller
addi $sp,$sp,24      # adjust stack to delete 5items

jr   $ra


# Function to shift down the node in
# order to maintain the heap property
# don't have a retuen value
shiftDown:
subi $sp, $sp,32      # adjust stack to make room for 8 items
sw   $t7, 28($sp)     # save register $t7  h[i]
sw   $t6, 24($sp)     # save register $t6  for condition
sw   $t5, 20($sp)     # save register $t5  h[l] or h[r]
sw   $t4, 16($sp)     # save register $t4  h[minIndex] 
sw   $t3, 12($sp)     # save register $t3  for condition
sw   $t2, 8($sp)      # save register $t2  for size
sw   $t1, 4($sp)      # save register $t1  for l --> leftChild or r --> rightChild
sw   $t0, 0($sp)      # save register $t0  for maxIndex

move $t0,$a0

subi $sp, $sp, 4       # adjust stack for 1 items
sw $ra, 0($sp)         # save the return addres
jal leftChild          # leftChild(i)
move $t1,$v0 	       # l = leftChild(i)
lw $ra, 0($sp)         #restore the return address 
addi $sp, $sp, 4       # restore stack for 1 items


# if (l <= siz && H[minIndex] > H[l])
lw $t2,size

sle $t3,$t1,$t2         #l <= size
sll $t0,$t0,2
lw  $t4,pq($t0)        #h[minIndex]
srl $t0,$t0,2

sll $t1,$t1,2
lw  $t5,pq($t1)         #h[l]
srl $t1,$t1,2

andi $t7 , $t4 , 32767
andi $t8 , $t5 , 32767
#H[minIndex] > H[l]
slt $t6,$t8,$t7    
and $t6,$t6,$t3
beq $t6,$0,exit1
move $t0,$t1  	       # minIndex = r;
exit1:

subi $sp, $sp, 4       # adjust stack for 1 items
sw $ra, 0($sp)         # save the return addres
jal rightChild	       # rightChild(i);
move $t1,$v0	       # r = rightChild(i);
lw $ra, 0($sp)         # restore the return address 
addi $sp, $sp, 4       # restore stack for 1 items

# if (l <= siz && H[minIndex] > H[r])
sle $t3,$t1,$t2        # r <= size

sll $t0,$t0,2
lw $t4,pq($t0)        # h[maxIndex]
srl $t0,$t0,2

sll $t1,$t1,2
lw  $t5,pq($t1)       # h[r]
srl $t1,$t1,2

sll $t7 , $t4,16
sll $t8 , $t5,16
#H[minIndex] > H[r]
slt $t6,$t8,$t7
and $t6,$t6,$t3
beq $t6,$0,exit2

move $t0,$t1          # minIndex = l;

exit2:

# If i not same as maxIndex

beq $a0,$t0,exit3

# swap(H[i], H[minIndex]);
#$a0-->i
#$t0--->maxIndex

sll $a0,$a0,2
lw  $t7,pq($a0)       # $t7 = h[i]


sll $t0,$t0,2
lw  $t4,pq($t0)       # t4 = h[maxIndex]

sw  $t4,pq($a0)       # h[i] = $t4
srl $a0,$a0,2


sw  $t7,pq($t0)       # h[max] = $t7
srl $t0,$t0,2

subi $sp, $sp, 8       # adjust stack for 2 items
sw   $ra, 4($sp)       # save the return addres
sw   $a0, 0($sp)       # save the paramter
move $a0,$t0           # put maxIndex in $a0
jal shiftDown
lw $a0, 0($sp)         # restore the paramter
lw $ra, 4($sp)         #restore the return address 
addi $sp, $sp, 8       # restore stack for 1 items 


exit3:
lw   $t0, 0($sp)     # restore register $t0 for caller
lw   $t1, 4($sp)     # restore register $t1 for caller
lw   $t2, 8($sp)     # restore register $t2 for caller
lw   $t3, 12($sp)    #restore register  $t3 for caller
lw   $t4, 16($sp)    # restore register $t4 for caller
lw   $t5, 20($sp)    # restore register $t5 for caller
lw   $t6, 24($sp)    # restore register $t6 for caller
lw   $t7, 28($sp)    # restore register $t7 for caller
addi $sp,$sp,32      # adjust stack to delete 8 items
jr $ra

# Function to insert a new element
# in the Binary Heap
#a0--> parameter
insert:

subi $sp, $sp, 4      # adjust stack to make room for 1 items
sw   $t0, 0($sp)      # save register $t0 for storing size

lw   $t2,size     
addi $t2,$t2,1         # siz + 1;

sll  $t2,$t2,2
sw   $a0,pq($t2)      # H[size] = p;
srl  $t2,$t2,2

move $a0,$t2
sw   $t2,size	       # size = size + 1;
move $a0,$t2

subi $sp, $sp, 4       # adjust stack for 1 items
sw   $ra, 0($sp)       # save the return addres
jal  shiftUp           #Shift Up to maintain heap property
lw   $ra, 0($sp)       #restore the return address
addi $sp, $sp, 4       # adjust stack for 1 items

lw $t0, 0($sp)         # restore register $t0 for caller
addi $sp,$sp,4         # adjust stack to delete 1 items
jr   $ra


# Function to extract the element with
# minimum priority
# return minimum value in $v0
extractMin:
subi $sp, $sp, 12     # adjust stack to make room for 3 items
sw   $t2, 8($sp)      # save register $t2  H[siz];
sw   $t1, 4($sp)      # save register $t1 size
sw   $t0, 0($sp)      # save register $t0    result = h[0] 

lw $t0,pq  #h[0]

#  Replace the value at the root
# with the last leaf
lw $t1,size
sll $t1,$t1,2
lw $t2,pq($t1) #H[siz]
sw $t2,pq # H[0] = H[siz];
srl $t1,$t1,2

subi $t1,$t1,1   # siz - 1
sw $t1,size      # siz = siz - 1

#Shift down the replaced element
#to maintain the heap property

subi $sp, $sp, 8       # adjust stack for 1 items
sw $ra, 4($sp)         # save the return addres
sw $a0, 0($sp)         # save the return addres
li $a0,0
jal shiftDown	       #shiftDown(0)
lw $a0, 0($sp)         #restore the return address 
lw $ra, 4($sp)         #restore the return address 
addi $sp, $sp, 8       # restore stack for 1 items

move $v0,$t0           # return result in $v0

lw   $t0, 0($sp)       # restore register $t0 for caller
lw   $t1, 4($sp)       # restore register $t1 for caller
lw   $t2, 8($sp)       # restore register $t2 for caller
addi $sp,$sp,12        # adjust stack to delete 
jr   $ra
   
   
   
   
   
   
   
   
 
