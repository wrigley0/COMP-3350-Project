.data
black: .word 0x00000000
hole:  .word 0x00D3D3D3     # Grey
mole:  .word 0x00FF0000     # Red
score: .word 0

.text
.globl main

main:
    li $t0, 0x100100CC    # Starting position
    lw $t1, hole
    li $t2, 0     

    li $v0, 42            # Random int range
    li $a0, 0             # Lower bound of 0
    li $a1, 9             # Upper bound of 9 (0-8)
    syscall

row:
    li $t3, 0           
    move $t4, $t0

col:
    sw $t1, 0($t4)        # Draw hole
    sw $t1, 4($t4)
    sw $t1, 64($t4)
    sw $t1, 68($t4)
    
    addi $t4, $t4, 16    
    addi $t3, $t3, 1
    blt $t3, 3, col

    addi $t0, $t0, 256   
    addi $t2, $t2, 1
    blt $t2, 3, row

    li $v0, 10
    syscall

total_time:
 
    li $a0, 30000            #30000 milliseconds or 30 seconds of total time for lifetime
    syscall

point_add:

    lw $t5, score 
    addi $t5, $t5, 1
    sw $t5, score

    jr $ra                   #return 
    
