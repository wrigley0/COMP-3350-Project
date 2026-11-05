.data
bitmap: .space 16384

black: .word 0x00000000
hole:  .word 0x00D3D3D3     # Grey
mole:  .word 0x00FF0000     # Red
score: .word 0

.text
.globl main

main:
    la $t0, bitmap
    addi $t0, $t0, 3120    # Starting position
    lw $t1, hole
    li $t2, 0

    li $v0, 42            # Random int range
    li $a0, 0             # Random generator ID
    li $a1, 9             # Range 0-8
    syscall
    move $s0, $a0         # Save random position

    # Generate random mole position (0-8)

    li $v0, 42
    li $a0, 0
    li $a1, 9
    syscall

    # Convert position to 1-9

    addi $s4, $a0, 1 

row:
    li $t3, 0
    move $t4, $t0

col:
    li $t5, 0
    move $t6, $t4

pixel_row:
    li $t7, 0

pixel_col:
    sw $t1, 0($t6)        # Draw grey pixel
    addi $t6, $t6, 4
    addi $t7, $t7, 1
    blt $t7, 8, pixel_col

    addi $t6, $t6, 224    # Next pixel row
    addi $t5, $t5, 1
    blt $t5, 8, pixel_row

    addi $t4, $t4, 64     # Next hole horizontally
    addi $t3, $t3, 1
    blt $t3, 3, col

    addi $t0, $t0, 4096   # Next row of holes
    addi $t2, $t2, 1
    blt $t2, 3, row

    li $v0, 10
    syscall

total_time:
    li $a0, 3000             #3000 millisecnond or 3 seconds of delay for user
    li $a0, 30000            #30000 milliseconds or 30 seconds of total time for lifetime
    syscall

point_add:
    lw $t5, score 
    addi $t5, $t5, 1
    sw $t5, score

    jr $ra                   #return 
    
