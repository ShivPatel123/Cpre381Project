# Test file for MIPS instructions

# .data section
.data



# .text section
.text
.globl main

# Main function
main:
    # Load immediate values into registers
    lui $t0, 0XFFFF                # $t0 = 5

    ori $t0, 0XFFFF

    addi $t0, $t0, 1

    lui $t0, 0XAAAA                # $t0 = 5

    ori $t0, 0XAAAA


halt