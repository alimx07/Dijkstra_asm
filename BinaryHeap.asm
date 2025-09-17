.data 
arr:           .space  1000
size:          .space  4
inputBuffer:   .word -1:20
msg:           .asciiz "Popped: "
newline:       .asciiz "\n"
space:         .asciiz " "
vline:         .asciiz "------------------------------------------"
menuMsg:       .asciiz "Select an operation:\n1. Insert\n2. Pop\n3. Change Priority\n4. print\n5. remove\n6. get_root\n7. Exit\n"
prompt:        .asciiz "Enter your choice: "
sizeMsg:       .asciiz "\nThe size is: "
errorMsg:      .asciiz "\nNo More Value in The Heap"
errorMsg1:     .asciiz "\nInvalid Index Number"
getindex:      .asciiz "\nPlease Enter the Index of Number you want to Change the Prioriy 0-"
inputMsg:      .asciiz "\nEnter The Value"
minValue:      .asciiz "\nThe Min Value in Heap: " 
open:          .asciiz "\n [ "
close :        .asciiz "] \n" 
invalid :      .asciiz "\nInvalid input\n"
insertMsg :    .asciiz "\nInserted successfully \n"
popMsg :       .asciiz "Poped successfully \n"
changeMsg :    .asciiz "\nChanged successfully \n"
type :         .asciiz "\nChoose the the input type for Heap \nN for integer \nC for character"
getindex_remove : .asciiz "\n Enter the Index to remove 0-"
newheap: .asciiz     "New Heap after Remove\n"
noElem:  .asciiz   "\nThere is no Element in the heap\n"
invalidMenuMsg:  .asciiz "\nYou enter invalid Input please, input 1-7 \n "
invalidRangeMsg: .asciiz "\nYou enter invalid Range\n"

.text
main:
#intial size with -1
addi $t1,$0,-1
sw   $t1,size

jal inputtype

jal menu

li $v0,10
syscall

inputtype:
   subi $sp , $sp , 4
   sw $ra , 0($sp)  # restore the stack
   
   li $v0 , 4
   la $a0 , vline
   syscall
   
   li $v0 , 4
   la $a0 , type
   syscall
        
   li $v0 , 4
   la $a0 , newline
   syscall
   
   # Read a character
   li $v0, 8
   la $a0, inputBuffer
   li $a1, 2  # Limit input to 1 character + null terminator
   syscall
        
   # Check if input is exactly one character (excluding null terminator)
   la $t8 , inputBuffer
   lb $t0, 0($t8)  # Load the character into $t0
   lb $t1, 1($t8)  # Should be null terminator
        
   beq $t1, $zero, check_uppercase  # If $t1 is null, input is valid
   j error_handler  # Otherwise, handle error
   
   
   check_uppercase:
    li $t2, 67  # ASCII value of 'C'
    li $t3, 78  # ASCII value of 'N'
    
    beq $t0, $t2,exit_input  # If not equal
    beq $t0, $t3, exit_input  # If not equal

 error_handler:
  
   # Display error message
   li $v0 , 4
   la $a0 , newline
   syscall
   li $v0, 4
   la $a0, invalid
   syscall
   li $v0 , 4
   la $a0 , newline
   syscall
   
   j inputtype  # Optionally loop back to retry
   
   j exit_input
  
 exit_input:
   li $v0 , 4
   la $a0 , newline
   syscall
   move $s7,$t0

   lw $ra , 0($sp)  # restore the stack
   addi $sp , $sp , 4
jr $ra

menu:
    subi $sp , $sp , 4
    sw $ra , 0($sp)

    
    j menu_loop
    
    # Prompt for input
    menu_loop:
    
        li $v0 , 4
        la $a0 , vline
        syscall
        
        li $v0 , 4
        la $a0 , newline
        syscall
        
        li $v0 , 4
        la $a0 , menuMsg
        syscall
        
    	li $v0, 4          # syscall to print string
   	la $a0, prompt     # load address of prompt text
        syscall
        

    	subi $sp, $sp, 8     # adjust stack to make room for 2 items
        sw $ra, 0($sp)     # save register
        sw $s7,4($sp)
      
        li $s7,'N'
        jal checkInput
        
        lw $ra, 0($sp)
        lw $s7, 4($sp)
        addi $sp,$sp,8
        
        beq $v0,$0,invalidMenu
        j validMenu

        invalidMenu:
        li $v0 , 4
        la $a0 , invalidMenuMsg
        syscall
        j   menu_loop

        validMenu:
        move $a0,$v1
    	
    	
    	move $t0 , $0
    	case1: 
    	addi $t0 , $t0 ,1
      	bne $t0 , $a0 , case2
      	jal insert
      	j menu_loop
    	case2:
    	addi $t0 , $t0 ,1
      	bne $t0, $a0 , case3
      	jal extractMin
      	j menu_loop
    	case3:
    	addi $t0 , $t0 ,1
      	bne $t0, $a0 , case4
      	jal changePriority
      	j menu_loop
    	case4:
    	addi $t0 , $t0 ,1
      	bne $t0, $a0 , case5
      	jal print
      	j menu_loop
    	case5:
    	addi $t0 , $t0 ,1
    	bne $t0 , $a0 , case6
    	jal remove
    	j menu_loop
    	case6:
    	addi $t0 , $t0 , 1
    	bne $t0 , $a0 , case7
    	jal getMin
        j menu_loop
        case7:
        add $t0 , $t0 , 1
        bne $t0 , $a0 , case8
        j end
        case8:
    	li $v0 , 4
        la $a0 , invalidMenuMsg
        syscall
        
       li $v0 , 4
       la $a0 , newline
       syscall
      	j menu_loop
    end :
     lw $ra , 0($sp)
     addi $sp , $sp ,4
     li $v0,10
     syscall
jr $ra

     

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

shiftUploop:

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
lw  $t2,arr($v0)       #H[parent(i)]
lw  $t3,arr($t0)       #H[i]

slt $t4,$t3,$t2        #H[parent(i)] > H[i]

and $t5,$t4,$t1
beq $t5,$0,exitShiftup 

#swap(H[parent(i)], H[i]);
sw  $t2,arr($t0)
sw  $t3,arr($v0)
srl $v0,$v0,2

# Update i to parent of i
move $t0,$v0   #i = parent(i);
j shiftUploop

exitShiftup:
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
lw  $t4,arr($t0)        #h[minIndex]
srl $t0,$t0,2

sll $t1,$t1,2
lw  $t5,arr($t1)         #h[l]
srl $t1,$t1,2

#H[minIndex] > H[l]
slt $t6,$t5,$t4    
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
lw $t4,arr($t0)        # h[maxIndex]
srl $t0,$t0,2

sll $t1,$t1,2
lw  $t5,arr($t1)       # h[r]
srl $t1,$t1,2

#H[minIndex] > H[r]
slt $t6,$t5,$t4
and $t6,$t6,$t3
beq $t6,$0,exit2

move $t0,$t1          # minIndex = l;

exit2:

# If i not same as minIndex

beq $a0,$t0,exit3

# swap(H[i], H[minIndex]);
#$a0-->i
#$t0--->maxIndex

sll $a0,$a0,2
lw  $t7,arr($a0)       # $t7 = h[i]


sll $t0,$t0,2
lw  $t4,arr($t0)       # t4 = h[maxIndex]

sw  $t4,arr($a0)       # h[i] = $t4
srl $a0,$a0,2


sw  $t7,arr($t0)       # h[max] = $t7
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



#input $a0
#return true or false $v0
#return  char or int in $v1 
checkInput:

subi $sp,$sp,28
sw   $t0, 0($sp)     # restore register for iterator  
sw   $t1, 4($sp)     # restore register  for string[i]
sw   $t2, 8($sp)     # restore register 
sw   $t3, 12($sp)    # restore register 
sw   $t4, 16($sp)    # restore register 
sw   $t5, 20($sp)    # restore register 
sw   $t6, 24($sp)


 # Read a string
   li $v0, 8
   la $a0, inputBuffer
   li $a1, 20  
   syscall
   move $v1 , $v0
#67   for C
#78   for N
#65   for A
#90   for Z
#48   for '0'

li $t0,0 

bne $s7,'C',conditionOneFalseInit      #if (s7 == 'C')

lb $t1,inputBuffer($0)
sge $t3,$t1,'A'
sle $t4,$t1,'Z'

and $t3,$t3,$t4 #x[0] >= 65 && x[0] <= 90 

addi $t0,$t0,1  
lb $t1,inputBuffer($t0)
seq $t6 , $t1 , '\n'
and $t3 , $t3 , $t6

beq $t3,1,conditioOneTrue
beq $t3 ,0,conditiononeTrue_1


conditiononeTrue_1:
li $v0,0
j exitCheckInput

conditioOneTrue:
li $v0,1
lb $v1,inputBuffer($0)
j exitCheckInput


conditionOneFalseInit:
li $t0,0
lb $t1,inputBuffer($0)# -
bne $t1,'-',postiveContinue
li $t0,1

conditioOneFalse:

postiveContinue:
lb $t1,inputBuffer($t0)
addi $t0,$t0,1 
beq $t1, '\n' , exitNumLoop

sge $t6 , $t1 , '0'
sle $t7 , $t1 , '9'
and $t6 , $t6 , $t7

beq $t6,1,conditioOneFalse

li $v0,0 #      return false;
j exitCheckInput


exitNumLoop:

li $v0,1
subi $sp , $sp , 4
sw $ra , 0($sp)
jal atoi
lw $ra , 0($sp)
addi $sp , $sp ,4
j exitCheckInput


exitCheckInput:
lw   $t0, 0($sp)     # restore register 
lw   $t1, 4($sp)     # restore register 
lw   $t2, 8($sp)     # restore register 
lw   $t3, 12($sp)    # restore register 
lw   $t4, 16($sp)    # restore register 
lw   $t5, 20($sp)    # restore register 
lw   $t6,24($sp)
addi $sp,$sp,28      # adjust stack to 

jr $ra

  
atoi:
    li $v1, 0          # Initialize the result to 0 (accumulator)
    li $t1 , 0
    
    lb $t0, inputBuffer($t1)  # Load the first byte (character) from the string into $t0
    addi $t1, $t1, 1     # Move index to the next character
    bne $t0, '-', check_end_string  # Check if the first character is '-'
    li $t4, 1            # Set negative flag
    lb $t0, inputBuffer($t1)  # Load the next byte (character) if '-' was found
    addi $t1, $t1, 1     # Move index to the next character after '-'

check_end_string:
    beq $t0, '\n', convert_done  # If the character is \n, we're done

atoi_loop:
    subi $t0, $t0, '0'  # Convert ASCII character to integer ('0' -> 0, '1' -> 1, etc.)
    mul $v1, $v1, 10    # Multiply the current result by 10 (shift left by 1 place in decimal)
    add $v1, $v1, $t0   # Add the current digit to the result
    lb $t0, inputBuffer($t1)  # Load the next character into $t0
    addi $t1, $t1, 1    # Move to the next character in the string
    bne $t0, '\n', atoi_loop  # If not null, continue the loop

convert_done:
    beqz $t4, atoi_done # If negative flag is not set, skip negation
    neg $v1, $v1        # Negate the result

atoi_done:
    # $v1 now contains the converted integer
 jr $ra              # Return from main or continue with other code


# Function to insert a new element
# in the Binary Heap
#a0--> parameter
insert:

subi $sp, $sp, 12     # adjust stack to make room for 1 items
sw   $t2, 8($sp)      # save register 
sw   $t1, 4($sp)      # save register 
sw   $t0, 0($sp)      # save register 


li $v0 , 4
la $a0 , inputMsg
syscall

li $v0 , 4
la $a0 , space
syscall

subi $sp, $sp, 4     # adjust stack to make room for 2 items
sw   $ra, 0($sp)     # save register
jal checkInput
lw $ra, 0($sp)
addi $sp,$sp,4

beq $v0,$0,invalidInsert

move $a0,$v1
j validInsert

invalidInsert:
li $v0 , 4
la $a0 , invalid
syscall

j exitInsert
validInsert:

lw   $t0,size     
addi $t0,$t0,1         # siz + 1;


sll  $t0,$t0,2
sw   $v1,arr($t0)      # H[size] = p;
srl  $t0,$t0,2

move $a0,$t0
sw   $t0,size	      



subi $sp, $sp, 4       # adjust stack for 1 items
sw   $ra, 0($sp)       # save the return addres

jal  shiftUp           #Shift Up to maintain heap property
lw   $ra, 0($sp)       #restore the return address
addi $sp, $sp, 4       # adjust stack for 1 items

li $v0 , 4
la $a0 , insertMsg
syscall

exitInsert:
lw $t0, 0($sp)         # restore register $t0 for caller
lw $t1, 4($sp)         # restore register $t0 for caller
lw $t2, 8($sp)         # restore register $t0 for caller
addi $sp,$sp,12         # adjust stack to delete 1 items
jr   $ra


# Function to extract the element with
# minimum priority
# return minimum value in $v0
extractMin:
subi $sp, $sp, 12     # adjust stack to make room for 3 items
sw   $t2, 8($sp)      # save register $t2  H[siz];
sw   $t1, 4($sp)      # save register $t1 size
sw   $t0, 0($sp)      # save register $t0    result = h[0] 

lw $t1,size
beq $t1 , -1 , extractMinError
lw $t0,arr  #h[0]

#  Replace the value at the root
# with the last leaf

sll $t1,$t1,2
lw $t2,arr($t1) #H[siz]
sw $t2,arr # H[0] = H[siz];
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


beq $s6,$0,removeFlag
li $s6,0
j flagCont
removeFlag:
li $v0 , 4
la $a0 , minValue
syscall

move $a0,$t0           # return result in $a0

li $s6,0
subi $sp, $sp, 4     # adjust stack to make room for 2 items
sw   $ra, 0($sp)     # save register
jal printCnfg
lw $ra, 0($sp)
addi $sp,$sp,4

flagCont:
li $v0 , 4
la $a0 , newline
syscall

li $v0 , 4
la $a0 , popMsg
syscall

j extractMinDone
 
extractMinError : 
  li $v0 , 4
  la $a0 , errorMsg
  syscall
  li $v0 , 4
  la $a0 , newline
  syscall
  

extractMinDone:

  move $v0,$t0           # return result in $v0
 lw   $t0, 0($sp)       # restore register $t0 for caller
 lw   $t1, 4($sp)       # restore register $t1 for caller
 lw   $t2, 8($sp)       # restore register $t2 for caller
 addi $sp,$sp,12        # adjust stack to delete 
 jr   $ra



# Function to get value of the current
# maximum element
#retuen size in $v0
getSize:
subi $sp, $sp, 4     # adjust stack to make room for 1 items
sw   $t0, 0($sp)     # save register $t0 for storing size
lw   $t0,size($0)    #load the size from data segement
addi $t0,$t0,1

li   $v0, 4
la   $a0, sizeMsg    # printing size msg
syscall

li   $v0, 1   
move $a0, $t0        # printing the size
syscall

li   $v0, 4
la   $a0, newline    # printing new line
syscall

move $v0,$t0         # move the size in $v0 

lw $t0, 0($sp)       # restore register $t0 for caller
addi $sp,$sp,4       # adjust stack to delete 1 items

jr $ra


#Function to change the priority of an element
#$a0--->i
#$a1--->p

changePriority:

subi $sp, $sp, 16    # adjust stack to make room for 2 items
sw   $ra , 12($sp)
sw   $t0, 8($sp)     # save register $t0 for storing 
sw   $t1, 4($sp)     # save register $t1 for storing ---> oldp
sw   $t2, 0($sp)     # save register $t2 for 

subi $sp, $sp, 4     # adjust stack to make room for 2 items
sw   $ra, 0($sp)     # save register
jal print
lw $ra, 0($sp)
addi $sp,$sp,4


lw $t2 , size
addi $t2,$t2,1
bne $t2,$0,CpConti
li $v0 , 4
la $a0 , noElem
syscall
j exitCp
CpConti:

li $v0 , 4
la $a0 , getindex
syscall

li $v0 , 1
lw $a0 , size
syscall

li $v0 , 4
la $a0 , space
syscall

subi $sp, $sp, 8     # adjust stack to make room for 2 items
sw $ra, 0($sp)      # save register
sw $s7,4($sp)    
li $s7,'N'
jal checkInput
lw $ra, 0($sp)
lw $s7, 4($sp)
addi $sp,$sp,8

move $t0,$v1

beq $v0,$0,invalidChangePType
bge $v1,$t2,invalidRangeChangeP
blt $v1,$0,invalidRangeChangeP

li $v0 , 4
la $a0 , inputMsg
syscall
li $v0 , 4
la $a0 , space
syscall

subi $sp, $sp, 4     # adjust stack to make room for 2 items
sw   $ra, 0($sp)     # save register
jal checkInput
lw $ra, 0($sp)
addi $sp,$sp,4
beq $v0,$0,invalidChangePType
move $a1 , $v1


sll $t0,$t0,2
lw  $t1,arr($t0)    #oldp = $t1 = H[i]
sw  $a1,arr($t0)    #H[i] = p
srl $t0,$t0,2

slt $t2,$a1,$t1     
beq $0,$t2,else0        #if(p < oldp)

subi $sp, $sp, 4       # adjust stack for 1 items
sw $ra, 0($sp)         # save the return addres
move $a0,$t0
jal shiftUp
lw $ra, 0($sp)         #restore the return address 
addi $sp , $sp , 4


li $v0 , 4
la $a0 , changeMsg
j exitCp
 
else0:
subi $sp, $sp, 4       # adjust stack for 1 items
sw $ra, 0($sp)         # save the return address
move $a0,$t0
jal shiftDown
lw $ra, 0($sp)         #restore the return address 
addi $sp , $sp , 4

j exitCp

invalidChangePType:
li $v0 , 4
la $a0 , invalid
syscall
j exitCp

invalidRangeChangeP:
li $v0 , 4
la $a0 , invalidRangeMsg
syscall


exitCp:
lw   $t2, 0($sp)     # restore register $t2 for 
lw   $t1, 4($sp)     # restore register $t1 for storing size
lw   $t0, 8($sp)     # restore register $t0 for caller
lw   $ra , 12($sp)
addi $sp,$sp,16      # adjust stack to delete 1 items

jr $ra





print:
subi $sp, $sp, 20     # adjust stack to make room for 2 items
sw   $t4, 16($sp)     # save register 
sw   $t3, 12($sp)     # save register 
sw   $t2, 8($sp)     # save register 
sw   $t1, 4($sp)     # save register 
sw   $t0, 0($sp)     # save register


lw   $t1,size($0)    # load the size from data segement
move $t0,$0	     # setting the itrator with zero
addi $t1,$t1,1
sll  $t1,$t1,2 	     # multiply size by 4 

li $v0, 4           # syscall to print string
la $a0, newline     # newline
syscall

li   $v0, 4   
la $a0, open        # printing the 
syscall

j    print_loop
print_loop:
bge  $t0, $t1, exit_print_loop
lw   $t2, arr($t0)   # load content of the target element

move $a0,$t2

subi $sp, $sp, 4     # adjust stack to make room for 2 items
sw   $ra, 0($sp)     # save register
jal printCnfg
lw $ra, 0($sp)
addi $sp,$sp,4


li   $v0, 4
la   $a0, space
syscall

addi $t0, $t0, 4

j    print_loop
exit_print_loop:

li   $v0, 4   
la $a0, close        # printing the 
syscall


lw $t0, 0($sp)     # restore register $t0 for caller
lw $t1, 4($sp)     # restore register $t1 for caller
lw $t2, 8($sp)     # restore register $t2 for caller
lw $t3, 12($sp)     # restore register $t3 for calle
lw $t4, 16($sp)     # restore register $t3 for callerr
addi $sp,$sp,20     # adjust stack to delete 3items

jr   $ra


printCnfg:

beq $s7,67,printCharcnfg
beq $s7,78,ptintIntCnfg


printCharcnfg:
li $v0 , 11
syscall

j exitprintCnfg
ptintIntCnfg:
li $v0 , 1
syscall
exitprintCnfg:
jr $ra


# Function to get value of the current
# maximum element
getMin : 
subi $sp , $sp , 8
sw   $t0 , 0($sp)
sw   $t1,  4($sp)

lw  $t1,size($0)
addi $t1,$t1,1
bne $t1,$0,GetMinConti
li $v0 , 4
la $a0 , noElem
syscall
j exitGetMin

GetMinConti:

lw   $t0 , arr     # H[0];  
li $v0 , 4
la $a0 , newline
syscall


move $a0,$t0
subi $sp, $sp, 4     # adjust stack to make room for 2 items
sw   $ra, 0($sp)     # save register
jal printCnfg
lw $ra, 0($sp)
addi $sp,$sp,4

li $v0 , 4
la $a0 , newline
syscall

exitGetMin:
lw   $t0 , 0($sp)
lw   $t1,4($sp)
addi $sp , $sp ,8

jr $ra 




remove:
subi $sp, $sp, 12    # adjust stack to make room for 2 items
sw   $t2, 8($sp)     # save register $t1 
sw   $t1, 4($sp)     # save register $t1 
sw   $t0, 0($sp)     # save register $t0 

subi $sp , $sp , 4
sw  $ra , 0($sp)
jal print
lw  $ra , 0($sp)
addi $sp , $sp , 4

lw  $t2,size($0)
addi $t2,$t2,1
bne $t2,$0,removeConti
li $v0 , 4
la $a0 , noElem
syscall
j exitRemove

removeConti:

li $v0 , 4
la $a0 , getindex_remove
syscall

li $v0 , 1
lw $a0 , size
syscall

li $v0 , 4
la $a0 , space
syscall

subi $sp, $sp, 8     # adjust stack to make room for 2 items
sw $ra, 0($sp)     # save register
sw $s7,4($sp)    
li $s7,'N'
jal checkInput
lw $ra, 0($sp)
lw $s7, 4($sp)
addi $sp,$sp,8
beq $v0,$0,invalidRemoveType
bge $v1,$t2,invalidRangeRemove
blt $v1,$0,invalidRangeRemove

lw $t0,arr        #h[0] 
subi $t0,$t0,1    # h[0] -1 

move $t1,$v1
sll $t1,$t1,2
sw  $t0,arr($t1)       #h[i] = g[0]-1
srl $t1,$t1,2

subi $sp, $sp, 8     # adjust stack to make room for 2 items
sw   $ra, 0($sp)  
sw   $a0 , 4($sp) 
move $a0 , $t1  
jal  shiftUp
lw   $ra, 0($sp)
lw   $a0, 4($sp)
addi $sp, $sp, 8     # adjust stack to make room for 2 items


subi $sp, $sp, 4     # adjust stack to make room for 2 items
sw   $ra, 0($sp)
li $t6 , 1
li $s6,1  #flag
jal extractMin
lw   $ra, 0($sp)
addi $sp, $sp, 4     # adjust stack to make room for 2 items

subi $sp , $sp , 4
sw  $ra , 0($sp)

li $v0 , 4
la $a0 , newline
syscall

li $v0 , 4
la $a0 , newheap
syscall

subi $sp , $sp , 4
sw  $ra , 0($sp)
jal print
lw  $ra , 0($sp)
addi $sp , $sp , 4

j exitRemove

invalidRemoveType:
li $v0 , 4
la $a0 , invalid
syscall
j exitRemove

invalidRangeRemove:
li $v0 , 4
la $a0 , invalidRangeMsg
syscall


exitRemove:
lw $t0, 0($sp)     # restore register $t1 for caller
lw $t1, 4($sp)     # restore register $t0 for caller
lw $t2, 8($sp)
addi $sp,$sp,12     # adjust stack to delete 3items
jr $ra
