.data
bitmap: .space 16384

black: .word 0x00000000
hole:  .word 0x00D3D3D3     # Grey
mole:  .word 0x00FF0000     # Red
hammer: .word 0x000080FF    # Blue
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

    # Draw mole
    jal draw_mole

    # Draw a hammer based on the input
    li $a0, 5 # Temporary user input -- Update after the user input is received
    jal draw_hammer

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


# Function to draw mole at random position
draw_mole:
    # Convert position from 1-9 to 0-8
    addi $t0, $s4, -1

    # Calculate row and column
    li $t1, 3
    div $t0, $t1
    mflo $t2              # Row
    mfhi $t3              # Column

    # Get starting position
    la $t0, bitmap
    addi $t0, $t0, 3120

    # Move to correct row
    sll $t2, $t2, 12
    addu $t0, $t0, $t2

    # Move to correct column
    sll $t3, $t3, 6
    addu $t0, $t0, $t3

    # Save mole starting position
    move $t8, $t0

    # Get mole color
    lw $t1, mole

    # Draw 8x8 mole
    li $t2, 0

mole_row:
    li $t3, 0
    move $t4, $t0

mole_col:
    # Skip the corners
    beq $t2, $zero, check_corner
    li $t5, 7
    beq $t2, $t5, check_corner
    j draw_red

check_corner:
    beq $t3, $zero, skip_pixel
    li $t5, 7
    beq $t3, $t5, skip_pixel

draw_red:
    sw $t1, 0($t4)

skip_pixel:
    addi $t4, $t4, 4
    addi $t3, $t3, 1
    blt $t3, 8, mole_col

    addi $t0, $t0, 256
    addi $t2, $t2, 1
    blt $t2, 8, mole_row

    # Get black color
    lw $t1, black

    # Draw eyes
    sw $t1, 520($t8)
    sw $t1, 532($t8)

    # Draw mouth
    sw $t1, 1288($t8)
    sw $t1, 1292($t8)
    sw $t1, 1296($t8)
    sw $t1, 1300($t8)

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

#===================================================================================================
# draw_hammer procedure starts
#===================================================================================================

draw_hammer:
#======================================
# $a0 = User input
#======================================
   # Load the address of bitmap to $s0
   la $t7, bitmap
   
   # Add hammer color to $s1
   lw $t6, hammer
   
   # $t0=x1, $t1=y1, $t2=width, $t3=height
   li $t0, 12	# x1
   li $t1, 6	# y1
   li $t2, 4	# width
   li $t3, 5	# height
   
   # Add based on the user input
   sub $a0, $a0, 1 # Make 1-9 to 0-8
   div $t4, $a0, 3 # Divide the input by 3 = the index of the row
   mul $t5, $t4, 3 # Multiply the index of the row by 3
   sub $t5, $a0, $t5 # Calculate the remainder
   sll $t5, $t5, 4 # x distance = 16
   addu $t0, $t0, $t5 # Adjust x1
   sll $t4, $t4, 4 # y distance = 16
   addu $t1, $t1, $t4 # Adjust y1
   
   # Get the location of the handle
   div $t5, $t3, 2
   add $t5, $t1, $t5
   
   # $t2=x2 and $t3=y2
   add $t2, $t0, $t2 # x2
   add $t3, $t1, $t3 # y2
   
   # Scale x1, y1, x2, and y2
   sll $t0, $t0, 2 # x1 scale by 4
   sll $t1, $t1, 8 # y1 scale by 512 x 4 / 8
   sll $t2, $t2, 2 # x2 scale by 4
   sll $t3, $t3, 8 # y2 scale by 512 x 4 / 8
   
   # Scale the location of handle
   sll $t5, $t5, 8 # scale the location by 512 x 4 / 8
   
   # Calculate the coordinates
   addu $t1, $t7, $t1 # Row starting address
   addu $t3, $t7, $t3 # Row ending address
   addu $t3, $t3, $t0 # Procedure ending address
   addu $t5, $t7, $t5 # Handle row starting address
   addu $t5, $t5, $t2 # Handle starting address
   addu $t0, $t1, $t0 # Hammer starting address (row)
   addu $t2, $t1, $t2 # Hammer ending address (row)
   
draw_hammer_row:
   
   # Create a pointer
   move $t4, $t0

draw_hammer_column:
   
   # Color the pixel
   sw $t6, ($t4)
   
   # Move to the next pixel
   addiu $t4, $t4, 4
   
   # Check if need to loop
   bne $t4, $t2, draw_hammer_column
   
   # Check if need to draw the handle
   bne $t5, $t4, draw_hammer_column_end
   
   # Color the handle
   sw $t6, 0($t5)
   sw $t6, 4($t5)
   sw $t6, 8($t5)
   sw $t6, 12($t5)
   
draw_hammer_column_end:
   
   # Move on to the next row
   addiu $t0, $t0, 256
   addiu $t2, $t2, 256
   
   # Check if need to loop
   bne $t3, $t0, draw_hammer_row  
   
jr $ra
   
#===================================================================================================
# draw_hammer procedure ends
#===================================================================================================
