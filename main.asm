.data
bitmap: .space 16384

black: .word 0x00000000
hole:  .word 0x00D3D3D3     # Grey
mole:  .word 0x00FF0000     # Red
score: .word 0

.text
.globl main

main:
    # Get game start time
    li $v0, 30
    syscall
    move $s1, $a0         # Save starting time

game_loop:
    # Check if 30 seconds have passed
    jal total_time
    beq $v0, 1, game_over

    # Generate random mole position (1-9)
    li $v0, 42
    li $a0, 0
    li $a1, 9
    syscall
    addi $s4, $a0, 1

    # Draw board
    jal draw_board

    # Wait 3 seconds
    jal delay_user

    j game_loop

game_over:
    li $v0, 10
    syscall


# Function to draw all 9 holes
draw_board:
    la $t0, bitmap
    addi $t0, $t0, 3120
    lw $t1, hole
    li $t2, 0

row:
    li $t3, 0
    move $t4, $t0

col:
    li $t5, 0
    move $t6, $t4

pixel_row:
    li $t7, 0

pixel_col:
    sw $t1, 0($t6)
    addi $t6, $t6, 4
    addi $t7, $t7, 1
    blt $t7, 8, pixel_col

    addi $t6, $t6, 224
    addi $t5, $t5, 1
    blt $t5, 8, pixel_row

    addi $t4, $t4, 64
    addi $t3, $t3, 1
    blt $t3, 3, col

    addi $t0, $t0, 4096
    addi $t2, $t2, 1
    blt $t2, 3, row

    jr $ra


# Check if 30 seconds have passed
total_time:
    li $v0, 30
    syscall

    subu $t0, $a0, $s1    # Time elapsed

    li $v0, 0            # Time not up
    bltu $t0, 30000, time_return

    li $v0, 1            # Time is up

time_return:
    jr $ra


# Wait 3 seconds
delay_user:
    li $v0, 32
    li $a0, 3000
    syscall

    jr $ra


# Add 1 point
point_add:
    lw $t5, score
    addi $t5, $t5, 1
    sw $t5, score

    jr $ra
