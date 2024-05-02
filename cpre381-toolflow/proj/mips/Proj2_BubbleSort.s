.data
Arr: .word 1, 3, 2, 5, 4, 0, 7, 6

.text
.globl main

main:
    add $t3, $zero, 8     # Get size of array
	No op
	No op
outer_loop:
    addi $t0, $t3, -1     # Set outer loop counter
    slt $t7, $t0, $zero
	No op
	No op
    bne $t7, $zero, exit        # Exit if array is empty
	No op
No op (flush??)
No op
    la $a0, Arr           # Load array address
    add $t1, $zero, $zero # Clear swap flag

    jal sort         # Execute single pass of bubble sort


    beq $t1, $zero, exit        # Exit if no swaps occurred
	No op
	No op
	No op

    addi $t3, $t3, -1     # Decrement outer loop counter
    j outer_loop          # Continue outer loop
	No op

exit:

    addi $v0, $zero, 10
    syscall
    halt

sort:
    add $t2, $zero, 7     # Set inner loop counter
    add $t4, $zero, 1     # Set increment for array offset

inner_loop:
    lw $s0, 0($a0)        # Load first element
    lw $s1, 4($a0)        # Load second element
	No op
	No op
    slt $t6, $s1, $s0
	No op
No op
    bne $t6, $zero, swap
	No op
No op
No op

    addi $a0, $a0, 4     # Move to next element
    addi $t2, $t2, -1    # Decrement loop counter
    bne $t2, $zero inner_loop # Continue inner loop
    jr $ra               # Return from function
	No op (do we even need one?)

swap:
    sw $s1, 0($a0)       # Store second element at current position
    sw $s0, 4($a0)       # Store first element at next position
    addi $t1, $zero, 1   # Set swap flag
    jr $ra               # Return from function
No op (do we even need one?)
.data
Arr: .word 1, 3, 2, 5, 4, 0, 7, 6

.text
.globl main

main:
    add $t3, $zero, 8     # Get size of array
	No op
	No op
outer_loop:
    addi $t0, $t3, -1     # Set outer loop counter
    slt $t7, $t0, $zero
	No op
	No op
    bne $t7, $zero, exit        # Exit if array is empty
	No op
No op (flush??)
No op
    la $a0, Arr           # Load array address
    add $t1, $zero, $zero # Clear swap flag

    jal sort         # Execute single pass of bubble sort


    beq $t1, $zero, exit        # Exit if no swaps occurred
	No op
	No op
	No op

    addi $t3, $t3, -1     # Decrement outer loop counter
    j outer_loop          # Continue outer loop
	No op

exit:

    addi $v0, $zero, 10
    syscall
    halt

sort:
    add $t2, $zero, 7     # Set inner loop counter
    add $t4, $zero, 1     # Set increment for array offset

inner_loop:
    lw $s0, 0($a0)        # Load first element
    lw $s1, 4($a0)        # Load second element
	No op
	No op
    slt $t6, $s1, $s0
	No op
No op
    bne $t6, $zero, swap
	No op
No op
No op

    addi $a0, $a0, 4     # Move to next element
    addi $t2, $t2, -1    # Decrement loop counter
    bne $t2, $zero inner_loop # Continue inner loop
    jr $ra               # Return from function
	No op (do we even need one?)

swap:
    sw $s1, 0($a0)       # Store second element at current position
    sw $s0, 4($a0)       # Store first element at next position
    addi $t1, $zero, 1   # Set swap flag
    jr $ra               # Return from function
No op (do we even need one?)
