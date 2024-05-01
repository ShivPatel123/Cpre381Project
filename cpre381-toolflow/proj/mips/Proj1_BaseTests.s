# Test file for MIPS instructions

# .data section
.data

# Define variables for testing
var1: .word 10
var2: .word 5

# .text section
.text
.globl main

# Main function
main:
    # Load immediate values into registers
    li $t0, 5                # $t0 = 5
    li $t1, 2                # $t1 = 2
    
    # Test add instruction
    add $s0, $t0, $t1        # $s0 = $t0 + $t1

    # Test addi instruction
    addi $s1, $t0, 3         # $s1 = $t0 + 3

    # Test addiu instruction
    addiu $s2, $t0, 1        # $s2 = $t0 + 1

    # Test addu instruction
    addu $s3, $t0, $t1       # $s3 = $t0 + $t1

    # Test and instruction
    and $s4, $t0, $t1        # $s4 = $t0 & $t1

    # Test andi instruction
    andi $s5, $t0, 1         # $s5 = $t0 & 1

    # Test lui instruction
    lui $s6, 0x1234          # $s6 = 0x12340000

    # Test lw instruction
    lw $s7, var1             # $s7 = Memory[var1]

    # Test nor instruction
    nor $s8, $t0, $t1        # $s8 = ~($t0 | $t1)

    # Test xor instruction
    xor $s9, $t0, $t1        # $s9 = $t0 ^ $t1

    # Test xori instruction
    xori $s10, $t0, 1        # $s10 = $t0 ^ 1

    # Test or instruction
    or $s11, $t0, $t1        # $s11 = $t0 | $t1

    # Test ori instruction
    ori $s12, $t0, 1         # $s12 = $t0 | 1

    # Test slt instruction
    slt $s13, $t0, $t1       # $s13 = ($t0 < $t1) ? 1 : 0

    # Test slti instruction
    slti $s14, $t0, 6        # $s14 = ($t0 < 6) ? 1 : 0

    # Test sll instruction
    sll $s15, $t0, 2         # $s15 = $t0 << 2

    # Test srl instruction
    srl $s16, $t0, 2         # $s16 = $t0 >> 2 (logical)

    # Test sra instruction
    sra $s17, $t0, 2         # $s17 = $t0 >> 2 (arithmetic)

    # Test sw instruction
    sw $t0, var2             # Memory[var2] = $t0

    # Test sub instruction
    sub $s18, $t0, $t1       # $s18 = $t0 - $t1

    # Test subu instruction
    subu $s19, $t0, $t1      # $s19 = $t0 - $t1 (unsigned)

    # Test beq instruction
    beq $t0, $t1, label1     # Branch to label1 if $t0 == $t1

    # Test bne instruction
    bne $t0, $t1, label2     # Branch to label2 if $t0 != $t1

    # Test j instruction
    j label3                  # Jump to label3 unconditionally

    # Test jal instruction
    jal label4                # Jump and link to label4

    # Test jr instruction
    jr $ra                    # Jump to address in $ra

    # Test lb instruction
    lb $t2, var1              # Load byte from memory[var1] into $t2

    # Test lh instruction
    lh $t3, var1              # Load half-word from memory[var1] into $t3

    # Test lbu instruction
    lbu $t4, var1             # Load byte (unsigned) from memory[var1] into $t4

    # Test lhu instruction
    lhu $t5, var1             # Load half-word (unsigned) from memory[var1] into $t5

    # Test sllv instruction
    sllv $s20, $t0, $t1      # $s20 = $t0 << $t1 (logical)

    # Test srlv instruction
    srlv $s21, $t0, $t1      # $s21 = $t0 >> $t1 (logical)

    # Test srav instruction
    srav $s22, $t0, $t1      # $s22 = $t0 >> $t1 (arithmetic)

    # End of main function
    # End of program
    j $ra                     # Jump back to caller

# Labels for branching and jumping
label1:
    # Branch target for beq instruction
    nop                      # No operation
    j $ra                    # Jump back to caller

label2:
    # Branch target for bne instruction
    nop                      # No operation
    j $ra                    # Jump back to caller

label3:
    # Jump target for j instruction
    nop                      # No operation
    j $ra                    # Jump back to caller

label4:
    # Jump target for jal instruction
    nop                      # No operation
    j $ra                    # Jump back to caller
