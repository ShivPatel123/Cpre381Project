.data
Arr: .word 1, 3, 2, 5, 4, 0, 7, 6

.text
.globl main

main:
    addi $t3, $zero, 8     # Get size of array
	nop
	nop
    nop
outer_loop:
    addi $t0, $t3, -1     # Set outer loop counter
    nop
    nop
    nop
    slt $t7, $t0, $zero
    nop
	nop
	nop
    bne $t7, $zero, exit        # Exit if array is empty
	nop
nop
nop
    #la $a0, Arr           # Load array address
    lui $a0, 0x1001

    add $t1, $zero, $zero # Clear swap flag

    jal sort         # Execute single pass of bubble sort
    nop
    nop

    beq $t1, $zero, exit        # Exit if no swaps occurred
	nop
	nop
	nop

    addi $t3, $t3, -1     # Decrement outer loop counter
    j outer_loop          # Continue outer loop
	nop
    nop

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
	nop
	nop
    nop
    slt $t6, $s1, $s0
	nop
    nop
nop
    bne $t6, $zero, swap
	nop
nop
nop

    addi $a0, $a0, 4     # Move to next element
    addi $t2, $t2, -1    # Decrement loop counter
    nop
    nop
    nop
    bne $t2, $zero inner_loop # Continue inner loop
    nop
    nop
    nop
    jr $ra               # Return from function
	nop
    nop

swap:
    sw $s1, 0($a0)       # Store second element at current position
    sw $s0, 4($a0)       # Store first element at next position
    addi $t1, $zero, 1   # Set swap flag
    jr $ra               # Return from function
nop
nop
